/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import "AWSCognito.h"
#import "AWSCredentialsProvider.h"
#import "AWSCognitoRecord_Internal.h"
#import "AWSCognitoSQLiteManager.h"
#import "AWSCognitoDataset.h"
#import "AWSCognitoConstants.h"
#import "AWSCognitoUtil.h"
#import "CognitoSync.h"
#import "AWSCognitoDataset_Internal.h"
#import "AWSLogging.h"
#import "AWSCognitoHandlers.h"
#import "AWSCognitoConflict_Internal.h"
#import "UICKeyChainStore.h"

NSString *const AWSCognitoDidStartSynchronizeNotification = @"com.amazon.cognito.AWSCognitoDidStartSynchronizeNotification";
NSString *const AWSCognitoDidEndSynchronizeNotification = @"com.amazon.cognito.AWSCognitoDidEndSynchronizeNotification";
NSString *const AWSCognitoDidChangeLocalValueFromRemoteNotification = @"com.amazon.cognito.AWSCognitoDidChangeLocalValueFromRemoteNotification";
NSString *const AWSCognitoDidChangeRemoteValueNotification = @"com.amazon.cognito.AWSCognitoDidChangeRemoteValueNotification";
NSString *const AWSCognitoDidFailToSynchronizeNotification = @"com.amazon.cognito.AWSCognitoDidFailToSynchronizeNotification";
NSString *const AWSCognitoUnknownDataTypeNotification = @"com.amazon.cognito.AWSCognitoUnknownDataTypeNotification";

// For the cognito client to communicate to open datasets
NSString *const AWSCognitoIdentityIdChangedInternalNotification = @"com.amazonaws.services.cognitoidentity.AWSCognitoIdentityIdChangedInternalNotification";

NSString *const AWSCognitoErrorDomain = @"com.amazon.cognito.AWSCognitoErrorDomain";

static UICKeyChainStore *keychain = nil;

static AWSCognitoSyncPlatform _pushPlatform;

@interface AWSCognito()
{
}

@property (nonatomic, strong) AWSCognitoSQLiteManager *sqliteManager;
@property (nonatomic, strong) AWSCognitoSync *cognitoService;
@property (nonatomic, strong) AWSCognitoCredentialsProvider *cognitoCredentialsProvider;
@property (nonatomic, strong) UICKeyChainStore *keychain;

@end

@implementation AWSCognito

#pragma mark - Setups

+ (void) initialize {
    keychain = [UICKeyChainStore keyChainStoreWithService:[NSString stringWithFormat:@"%@.%@", [NSBundle mainBundle].bundleIdentifier, [AWSCognito class]]];
    _pushPlatform = [AWSCognitoUtil pushPlatform];
}

+ (instancetype)defaultCognito {
    if (![AWSServiceManager defaultServiceManager].defaultServiceConfiguration) {
        return nil;
    }

    // Cognito needs an AWSCognitoCredentialsProvider
    if (![[AWSServiceManager defaultServiceManager].defaultServiceConfiguration.credentialsProvider isKindOfClass:[AWSCognitoCredentialsProvider class]]) {
        return nil;
    }
    
    static AWSCognito *_defaultCognito = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultCognito = [[AWSCognito alloc] initWithConfiguration:[AWSServiceManager defaultServiceManager].defaultServiceConfiguration];
    });
    
    return _defaultCognito;
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration
{
    // Cognito needs an AWSCognitoCredentialsProvider
    if (![configuration.credentialsProvider isKindOfClass:[AWSCognitoCredentialsProvider class]]) {
        return nil;
    }
    
    if (self = [super init]) {
        _configuration = [configuration copy];
        _cognitoCredentialsProvider = _configuration.credentialsProvider;

        // set other default values
        NSString * serviceDeviceId = [AWSCognito cognitoDeviceId];
        _deviceId = (serviceDeviceId) == nil ? @"LOCAL" : serviceDeviceId;
        _synchronizeRetries = AWSCognitoMaxSyncRetries;
        _synchronizeOnWiFiOnly = AWSCognitoSynchronizeOnWiFiOnly;
        
        _conflictHandler = [AWSCognito defaultConflictHandler];
        _sqliteManager = [[AWSCognitoSQLiteManager alloc] initWithIdentityId:_cognitoCredentialsProvider.identityId deviceId:_deviceId];
        _cognitoService = [[AWSCognitoSync alloc] initWithConfiguration:configuration];
        // register to know when the identity on our provider changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(identityChanged:) name:AWSCognitoIdentityIdChangedNotification object:_cognitoCredentialsProvider.identityProvider];
        

    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AWSCognitoDataset *)openOrCreateDataset:(NSString * ) datasetName{
    AWSCognitoDataset *dataset = [[AWSCognitoDataset alloc] initWithDatasetName:datasetName
                                                                  sqliteManager:self.sqliteManager
                                                                 cognitoService:self.cognitoService];
    dataset.conflictHandler = self.conflictHandler;
    dataset.datasetDeletedHandler = self.datasetDeletedHandler;
    dataset.datasetMergedHandler = self.datasetMergedHandler;
    dataset.synchronizeRetries = self.synchronizeRetries;
    dataset.synchronizeOnWiFiOnly = self.synchronizeOnWiFiOnly;
    
    // register the dataset to receive notifications from this instance when the identity changes
    [[NSNotificationCenter defaultCenter] addObserver:dataset selector:@selector(identityChanged:) name:AWSCognitoIdentityIdChangedInternalNotification object:self];
    
    return dataset;
}

- (void)wipe {
    [self.sqliteManager deleteAllData];
    [self.cognitoCredentialsProvider clearKeychain];
}

- (BFTask *)refreshDatasetMetadata {
    return [[[self.cognitoCredentialsProvider getIdentityId] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            return [BFTask taskWithError:[NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoAuthenticationFailed userInfo:nil]];
        }
        AWSCognitoSyncListDatasetsRequest *request = [AWSCognitoSyncListDatasetsRequest new];
        request.identityPoolId = self.cognitoCredentialsProvider.identityPoolId;
        request.identityId = self.cognitoCredentialsProvider.identityId;
        return [self.cognitoService listDatasets:request];
    }] continueWithBlock:^id(BFTask *task) {
        if(task.isCancelled){
            return [BFTask taskWithError:[NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoErrorTaskCanceled userInfo:nil]];
        }else if(task.error){
            AWSLogError(@"Unable to list datasets: %@", task.error);
            return task;
        }else {
            AWSCognitoSyncListDatasetsResponse* response = task.result;
            [self.sqliteManager putDatasetMetadata: response.datasets error:nil];
            return [BFTask taskWithResult:response.datasets];
        }
    }];
}

- (NSArray *)listDatasets {
    return [self.sqliteManager getDatasets:nil];
}

- (void) setDeviceId:(NSString *)deviceId {
    self.sqliteManager.deviceId = deviceId;
    _deviceId = deviceId;
}

- (void)identityChanged:(NSNotification *)notification {
    AWSLogDebug(@"IdentityChanged");
    NSString *oldId = [notification.userInfo objectForKey:AWSCognitoNotificationPreviousId];
    NSString *newId = [notification.userInfo objectForKey:AWSCognitoNotificationNewId];
    
    NSError *error;
    
    if ([self.sqliteManager reparentDatasets:oldId withNewId:newId error:&error]) {
        // update the id for the sqlitemanager
        self.sqliteManager.identityId = newId;
        
        // Now that we've udpated the data, notify open datasets
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:AWSCognitoIdentityIdChangedInternalNotification
                                                                object:self
                                                              userInfo:notification.userInfo];
        });
    }
    else {
        // TODO: How do we surface this error?
    }
}

+(NSString *) cognitoDeviceId {
    return keychain[[AWSCognitoUtil deviceIdKey:_pushPlatform]];
}

+(NSString *) cognitoDeviceIdentity {
    return keychain[[AWSCognitoUtil deviceIdentityKey:_pushPlatform]];
}

-(BFTask *)registerDevice:(NSData *) deviceToken {
    const unsigned char* bytes = (const unsigned char*)[deviceToken bytes];
    NSMutableString * devTokenHex = [[NSMutableString alloc] initWithCapacity:2*deviceToken.length];
    for(int i=0; i<deviceToken.length; i++){
        [devTokenHex appendFormat:@"%02X",bytes[i]];
    }
    return [self registerDeviceInternal:devTokenHex];
}

-(BFTask *)registerDeviceInternal:(NSString *) deviceToken {
    return [[[self.cognitoCredentialsProvider getIdentityId] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            return [BFTask taskWithError:[NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoAuthenticationFailed userInfo:nil]];
        }
        
        NSString *currentDeviceId = [AWSCognito cognitoDeviceId];
        NSString *currentDeviceIdentity = [AWSCognito cognitoDeviceIdentity];
        if(currentDeviceId && currentDeviceIdentity && [self.cognitoCredentialsProvider.identityId isEqualToString:currentDeviceIdentity]){
            return [BFTask taskWithResult:currentDeviceId];
        }
        AWSCognitoSyncRegisterDeviceRequest* request = [AWSCognitoSyncRegisterDeviceRequest new];
        request.platform = _pushPlatform;
        request.token = deviceToken;
        request.identityPoolId = self.cognitoCredentialsProvider.identityPoolId;
        request.identityId = self.cognitoCredentialsProvider.identityId;
        return [self.cognitoService registerDevice:request];
    }] continueWithBlock:^id(BFTask *task) {
        if(task.isCancelled){
            return [BFTask taskWithError:[NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoErrorTaskCanceled userInfo:nil]];
        }else if(task.error){
            AWSLogError(@"Unable to register device: %@", task.error);
            return task;
        }else {
            AWSCognitoSyncRegisterDeviceResponse* response = task.result;
            keychain[[AWSCognitoUtil deviceIdKey:_pushPlatform]] = response.deviceId;
            keychain[[AWSCognitoUtil deviceIdentityKey:_pushPlatform]] = self.cognitoCredentialsProvider.identityId;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if ([UICKeyChainStore instancesRespondToSelector:@selector(synchronize)])
                 [keychain synchronize];
#pragma clang diagnostic pop
            [self setDeviceId:response.deviceId];
            return [BFTask taskWithResult:response.deviceId];
        }
    }];
}

+(void)setPushPlatform:(AWSCognitoSyncPlatform) pushPlatform {
    _pushPlatform = pushPlatform;
}

+(AWSCognitoSyncPlatform)pushPlatform {
    return _pushPlatform;
}

-(BFTask *)subscribe:(NSArray *) datasetNames {
    NSMutableArray *tasks = [NSMutableArray new];
    for (NSString * datasetName in datasetNames) {
        [tasks addObject:[[self openOrCreateDataset:datasetName] subscribe]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

-(BFTask *)subscribeAll {
    return [self subscribe:[self listDatasets]];
}

-(BFTask *)unsubscribe:(NSArray *) datasetNames {
    NSMutableArray *tasks = [NSMutableArray new];
    for (NSString * datasetName in datasetNames) {
        [tasks addObject:[[self openOrCreateDataset:datasetName] unsubscribe]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

-(BFTask *)unsubscribeAll {
    return [self unsubscribe:[self listDatasets]];
}

+ (AWSCognitoRecordConflictHandler) defaultConflictHandler {
    return ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
        AWSLogDebug(@"Last writer wins conflict resolution for dataset %@", datasetName);
        if (conflict.remoteRecord == nil || [conflict.localRecord.lastModified compare:conflict.remoteRecord.lastModified] == NSOrderedDescending)
        {
            return [[AWSCognitoResolvedConflict alloc] initWithLocalRecord: conflict];
        }
        else
        {
            return [[AWSCognitoResolvedConflict alloc] initWithRemoteRecord: conflict];
        }
    };
}

@end
