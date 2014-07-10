/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import "AWSCognitoDataset.h"
#import "AWSCognitoUtil.h"
#import "AWSCognitoConstants.h"
#import "AWSCognito.h"
#import "AWSCognitoRecord_Internal.h"
#import "AWSCognitoSQLiteManager.h"
#import "AWSCognitoConflict_Internal.h"
#import "AZLogging.h"
#import "AWSCognitoRecord.h"
#import "CognitoSyncService.h"

@interface AWSCognitoDatasetMetadata()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *lastSyncCount;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *dataStorage;
@property (nonatomic, strong) NSString *lastModifiedBy;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSNumber *numRecords;

@end

@implementation AWSCognitoDatasetMetadata

-(id)initWithDatasetName:(NSString *) datasetName dataSource:(AWSCognitoSQLiteManager *)manager {
    [manager initializeDatasetTables:datasetName];
    if (self = [super init]) {
        _name = datasetName;
        [manager loadDatasetMetadata:self error:nil];
    }
    return self;
}

@end

@interface AWSCognitoDataset()
@property (nonatomic, strong) NSString *syncSessionToken;
@property (nonatomic, strong) AWSCognitoSQLiteManager *sqliteManager;

@property (nonatomic, strong) AWSCognitoSyncService *cognitoService;

@property (nonatomic, strong) NSNumber *currentSyncCount;
@property (nonatomic, strong) NSDictionary *records;

@end

@implementation AWSCognitoDataset

-(id)initWithDatasetName:(NSString *) datasetName sqliteManager:(AWSCognitoSQLiteManager *)sqliteManager cognitoService:(AWSCognitoSyncService *)cognitoService{
    if(self = [super initWithDatasetName:datasetName dataSource:sqliteManager]) {
        _sqliteManager = sqliteManager;
        _cognitoService = cognitoService;
    }
    return self;
}

#pragma mark - CRUD operations

- (NSString *)stringForKey:(NSString *)aKey
{
    NSString *string = nil;
    NSError *error = nil;
    AWSCognitoRecord *record = [self getRecordById:aKey error:&error];
    if(error || (!record.data.string))
    {
        AZLogDebug(@"Error: %@", error);
    }
    
    string = record.data.string;
    
    return string;
}

- (void)setString:(NSString *)aString forKey:(NSString *)aKey
{
    AWSCognitoRecordValue *data = [[AWSCognitoRecordValue alloc] initWithString:aString];
    AWSCognitoRecord *record = [[AWSCognitoRecord alloc] initWithId:aKey
                                              data:data];
    
    //do some limit checks
    if([self sizeForRecord:record] > AWSCognitoMaxDatasetSize){
        AZLogDebug(@"Error: Record would exceed max dataset size");
        return;
    }
    
    if([self sizeForString:aKey] > AWSCognitoMaxKeySize){
        AZLogDebug(@"Error: Key size too large, max is %d bytes", AWSCognitoMaxKeySize);
        return;
    }
    
    if([self sizeForString:aKey] < AWSCognitoMinKeySize){
        AZLogDebug(@"Error: Key size too small, min is %d byte", AWSCognitoMinKeySize);
        return;
    }

    
    if([self sizeForString:aString] > AWSCognitoMaxDatasetSize){
        AZLogDebug(@"Error: Value size too large, max is %d bytes", AWSCognitoMaxRecordValueSize);
        return;
    }
    
    int numRecords = [[self.sqliteManager numRecords:self.name] intValue];
    
    //if you have the max # of records and you aren't replacing an existing one
    if(numRecords == AWSCognitoMaxNumRecords && !([self recordForKey:aKey] == nil)){
        AZLogDebug(@"Error: Too many records, max is %d", AWSCognitoMaxNumRecords);
        return;
    }
   
    NSError *error = nil;
    if(![self putRecord:record error:&error])
    {
        AZLogDebug(@"Error: %@", error);
    }
}

- (BOOL)putRecord:(AWSCognitoRecord *)record error:(NSError **)error
{
    if(record == nil || record.data == nil || record.recordId == nil)
    {
        if(error != nil)
        {
            *error = [AWSCognitoUtil errorIllegalArgument:@""];
        }
        return NO;
    }
    
    return [self.sqliteManager putRecord:record datasetName:self.name error:error];
}

- (AWSCognitoRecord *)recordForKey: (NSString *)aKey
{
    NSError *error = nil;
    
    AWSCognitoRecord * result = [self getRecordById:aKey error:&error];
    if(!result)
    {
        AZLogDebug(@"Error: %@", error);
    }
    return result;
}

- (AWSCognitoRecord *)getRecordById:(NSString *)recordId error:(NSError **)error
{
    if(recordId == nil)
    {
        if(error != nil)
        {
            *error = [AWSCognitoUtil errorIllegalArgument:@""];
        }
        return nil;
    }
    
    AWSCognitoRecord *fetchedRecord = [self.sqliteManager getRecordById:recordId
                                                     datasetName:(NSString *)self.name
                                                           error:error];
    
    if (fetchedRecord.data.type == AWSCognitoRecordValueTypeDeleted)
    {
        fetchedRecord = nil;
    }
    
    return fetchedRecord;
}

- (BOOL)removeRecordById:(NSString *)recordId error:(NSError **)error
{
    if(recordId == nil)
    {
        if(error != nil)
        {
            *error = [AWSCognitoUtil errorIllegalArgument:@""];
        }
        return NO;
    }
    
    return [self.sqliteManager flagRecordAsDeletedById:recordId
                                           datasetName:(NSString *)self.name
                                                 error:error];
}

- (NSArray *)getAllRecords
{
    NSArray *allRecords = nil;
    
    allRecords = [self.sqliteManager allRecords:self.name];
    
    return allRecords;
}

- (NSDictionary *)getAll
{
    NSArray *allRecords = nil;
    NSMutableDictionary *recordsAsDictionary = [NSMutableDictionary dictionary];
    
    allRecords = [self.sqliteManager allRecords:self.name];
    for (AWSCognitoRecord *record in allRecords) {
        // ignore any deleted/invalid data where that data satisfies any of the following
        // type is 'deleted'
        // dirty count is -1
        // value is nil
        // value is empty string
        if (record.data.type == AWSCognitoRecordValueTypeDeleted || record.dirtyCount == AWSCognitoNotSyncedDeletedRecordDirty ||
            record.data.string == nil || record.data.string.length == 0) {
            continue;
        }
        [recordsAsDictionary setObject:record.data.string forKey:record.recordId];
    }
    
    return recordsAsDictionary;
}

- (void)removeObjectForKey:(NSString *)aKey
{
    NSError *error = nil;
    if(![self removeRecordById:aKey error:&error])
    {
        AZLogDebug(@"Error: %@", error);
    }
}

- (void)clear
{
    NSError *error = nil;
    if(![self.sqliteManager deleteDataset:self.name error:&error])
    {
        AZLogDebug(@"Error: %@", error);
    }
}

#pragma mark - Get all data

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionary];
    for(AWSCognitoRecord *record in [self getAllRecords])
    {
        id value = [AWSCognitoUtil retrieveValue:record.data];
        if(value)
        {
            [mutableDictionary setValue:value forKey:record.recordId];
        }
    }
    
    if([mutableDictionary count] > 0)
    {
        return [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    else
    {
        return nil;
    }
}

#pragma mark - Size operations

- (long) size {
    NSArray * allRecords = [self getAllRecords];
    long size = 0;
    if(allRecords != nil){
        for (AWSCognitoRecord *record in allRecords) {
            size += [self sizeForRecord:record];
        }
    }
    return size;
}

- (long) sizeForKey: (NSString *) aKey {
    return [self sizeForRecord:[self recordForKey:aKey]];
}

- (long) sizeForRecord:(AWSCognitoRecord *) aRecord {
    if(aRecord == nil){
        return 0;
    }
    
    //get the size of the key
    long sizeOfKey = [self sizeForString:aRecord.recordId];
    
    //if it has been deleted, just return the size of the key
    if(aRecord.data.type == AWSCognitoRecordValueTypeDeleted){
        return sizeOfKey;
    }
    
    //return size of key + size of value
    return sizeOfKey + [self sizeForString:aRecord.data.string];
}

- (long) sizeForString:(NSString *) aString{
    if(aString == nil){
        return 0;
    }
    return [aString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - Synchronize

/**
 * The pull part of our sync
 * 1. Do a list records, overlay changes
 * 2. Resolve conflicts
 */
-(BFTask *)syncPull:(int)remainingAttempts {
    
    //list records that have changed since last sync
    AWSCognitoSyncServiceListRecordsRequest *request = [AWSCognitoSyncServiceListRecordsRequest new];
    request.identityPoolId = ((AWSCognitoCredentialsProvider *)self.cognitoService.configuration.credentialsProvider).identityPoolId;
    request.identityId = ((AWSCognitoCredentialsProvider *)self.cognitoService.configuration.credentialsProvider).identityId;
    request.datasetName = self.name;
    request.lastSyncCount = [NSString stringWithFormat:@"%lld", [self.currentSyncCount longLongValue]];
    request.syncSessionToken = self.syncSessionToken;
    
    self.lastSyncCount = self.currentSyncCount;
    
    return [[self.cognitoService listRecords:request] continueWithBlock:^id(BFTask *task) {
        if (task.isCancelled) {
            NSError *error = [NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoErrorTaskCanceled userInfo:nil];
            [self postDidFailToSynchronizeNotification:error];
            return [BFTask taskWithError:error];
        }else if(task.error){
            AZLogError(@"Unable to list records: %@", task.error);
            return task;
        }else {
            NSError *error;
            NSMutableArray *conflicts = [NSMutableArray new];
            // collect updates to write in a transaction
            NSMutableArray *nonConflictRecords = [NSMutableArray new];
            NSMutableArray *existingRecords = [NSMutableArray new];
            // keep track of record names for notificaiton
            NSMutableArray *changedRecordNames = [NSMutableArray new];
            AWSCognitoSyncServiceListRecordsResponse *response = task.result;
            self.syncSessionToken = response.syncSessionToken;
            
            // check the response if dataset is present. If not and we have
            // a local sync count, the dataset was deleted.
            // Also check to see if the dataset was deleted and recreated
            // sinc our last sync
            if ((self.lastSyncCount != 0 && ![response.datasetExists boolValue]) ||
                ([response.datasetDeletedAfterRequestedSyncCount boolValue])) {
                
                // if the developer has implemented the handler, call it
                // and if they return NO, we clear data, otherwise we assume the
                // dataset should be recreated
                if (self.datasetDeletedHandler && !self.datasetDeletedHandler(self.name)) {
                    // delete the record data
                    [self.sqliteManager deleteDataset:self.name error:nil];
                    
                    // if the dataset doesn't exist on the remote, clear the
                    // metadata and return. The push will be a no-op
                    if (![response.datasetExists boolValue]) {
                        [self.sqliteManager deleteMetadata:self.name error:nil];
                        return nil;
                    }
                }
                [self.sqliteManager resetSyncCount:self.name error:nil];
                self.lastSyncCount = 0;
                self.currentSyncCount = 0;
            }
            
            // check the response for merged datasets, call the appropriate handler
            if (response.mergedDatasetNames && self.datasetMergedHandler) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    self.datasetMergedHandler(self.name, response.mergedDatasetNames);
                });
            }
            
            if(response.records){
                // get the dataset sync count for updating the last sync count
                self.lastSyncCount = response.datasetSyncCount;
                for(AWSCognitoSyncServiceRecord *record in response.records){
                    [existingRecords addObject:record.key];
                    [changedRecordNames addObject:record.key];
                    
                    //overlay local with remote if local isn't dirty
                    AWSCognitoRecord * existing = [self.sqliteManager getRecordById:record.key datasetName:self.name error:&error];
                    AWSCognitoRecord * newRecord = [[AWSCognitoRecord alloc] initWithId:record.key data:[[AWSCognitoRecordValue alloc]initWithString:record.value]];
                    newRecord.syncCount = [record.syncCount longLongValue];
                    newRecord.lastModifiedBy = record.lastModifiedBy;
                    newRecord.lastModified = record.lastModifiedDate;
                    if(newRecord.lastModifiedBy == nil){
                        newRecord.lastModifiedBy = @"Unknown";
                    }
                    
                    // separate conflicts from non-conflicts
                    if(!existing || existing.isDirty==NO || [existing.data.string isEqualToString:record.value]){
                        [nonConflictRecords addObject: [[AWSCognitoRecordTuple alloc] initWithLocalRecord:existing remoteRecord:newRecord]];
                    }
                    else{
                        //conflict resolution
                        AZLogInfo(@"Record %@ is dirty with value: %@ and can't be overwritten, flagging for conflict resolution",existing.recordId,existing.data.string);
                        [conflicts addObject: [[AWSCognitoConflict alloc] initWithLocalRecord:existing remoteRecord:newRecord]];
                    }
                }
                
                NSMutableArray *resolvedConflicts = [NSMutableArray arrayWithCapacity:[conflicts count]];
                //if there are conflicts start conflict resolution
                if([conflicts count] > 0){
                    if(self.conflictHandler == nil) {
                        self.conflictHandler = [AWSCognito defaultConflictHandler];
                    }
                    
                    for (AWSCognitoConflict *conflict in conflicts) {
                        AWSCognitoResolvedConflict *resolved = self.conflictHandler(self.name,conflict);
                        
                        // no resolution to conflict abort synchronization
                        if (resolved == nil) {
                            NSError *error = [NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoErrorTaskCanceled userInfo:nil];
                            [self postDidFailToSynchronizeNotification:error];
                            return [BFTask taskWithError:error];
                        }
                        
                        [resolvedConflicts addObject:resolved];
                    }
                }
                
                if (nonConflictRecords.count > 0 || resolvedConflicts.count > 0) {
                    // attempt to write all remote changes
                    if([self.sqliteManager updateWithRemoteChanges:self.name nonConflicts:nonConflictRecords resolvedConflicts:resolvedConflicts error:&error]) {
                        // successfully wrote data, notify interested parties
                        [self postDidChangeLocalValueFromRemoteNotification:changedRecordNames];
                    }
                    else {
                        [self postDidFailToSynchronizeNotification:error];
                        return [BFTask taskWithError:error];
                    }
                }
                
                // update our local sync count
                if(self.currentSyncCount < self.lastSyncCount){
                    [self.sqliteManager updateLastSyncCount:self.name syncCount:self.lastSyncCount lastModifiedBy:response.lastModifiedBy];
                }
                
            }
        }
        
        return nil;
    }];
    
}


/**
 * The push part of the sync
 * 1. Write any changes to remote
 * 2. Restart sync if errors occur
 */
-(BFTask *)syncPush:(int)remainingAttempts {
    
    //if there are no pending conflicts
    NSMutableArray *patches = [NSMutableArray new];
    NSError *error;
    self.records = [self.sqliteManager recordsUpdatedAfterLastSync:self.name error:&error];
    
    //collect local changes
    for(AWSCognitoRecord *record in self.records.allValues){
        AWSCognitoSyncServiceRecordPatch *patch = [AWSCognitoSyncServiceRecordPatch new];
        patch.key = record.recordId;
        patch.syncCount = [NSNumber numberWithLongLong: record.syncCount];
        patch.value = record.data.string;
        patch.op = (record.data.type == AWSCognitoRecordValueTypeDeleted)?AWSCognitoSyncServiceOperationRemove : AWSCognitoSyncServiceOperationReplace;
        [patches addObject:patch];
    }
    
    // if there were local changes
    if([patches count] > 0){
        // don't push local changes if they are guaranteed to fail due to dataset size
        if([self size] > AWSCognitoMaxDatasetSize){
            NSError *error = [NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoErrorUserDataSizeLimitExceeded userInfo:nil];
            [self postDidFailToSynchronizeNotification:error];
            return [BFTask taskWithError:error];
        }

        AWSCognitoSyncServiceUpdateRecordsRequest *request = [AWSCognitoSyncServiceUpdateRecordsRequest new];
        request.identityId = ((AWSCognitoCredentialsProvider *)self.cognitoService.configuration.credentialsProvider).identityId;
        request.identityPoolId = ((AWSCognitoCredentialsProvider *)self.cognitoService.configuration.credentialsProvider).identityPoolId;
        request.datasetName = self.name;
        request.recordPatches = patches;
        request.syncSessionToken = self.syncSessionToken;
        return [[self.cognitoService updateRecords:request] continueWithBlock:^id(BFTask *task) {
            NSNumber * currentSyncCount = self.lastSyncCount;
            BOOL okToUpdateSyncCount = YES;
            if(task.isCancelled){
                NSError *error = [NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoErrorTaskCanceled userInfo:nil];
                [self postDidFailToSynchronizeNotification:error];
                return [BFTask taskWithError:error];
            }else if(task.error){
                if(task.error.code == AWSCognitoSyncServiceErrorResourceConflict){
                    AZLogInfo("Conflicts existed on update, restarting synchronize.");
                    return [self synchronizeInternal:remainingAttempts-1];
                }
                else {
                    AZLogError(@"An error occured attempting to update records: %@",task.error);
                }
                return task;
            }else{
                AWSCognitoSyncServiceUpdateRecordsResponse * response = task.result;
                if(response.records) {
                    NSMutableArray *changedRecords = [NSMutableArray new];
                    NSMutableArray *changedRecordsNames = [NSMutableArray new];
                    for (AWSCognitoSyncServiceRecord * record in response.records) {
                        [changedRecordsNames addObject:record.key];
                        AWSCognitoRecord * newRecord = [[AWSCognitoRecord alloc] initWithId:record.key data:[[AWSCognitoRecordValue alloc]initWithString:record.value]];
                        
                        // Check to see if the sync count on the result is only one more than our current sync
                        // count. This means that we were the only update and we can safely fastforward
                        // If not, we'll keep sync count the same so we pull down updates that occurred between
                        // push and pull.
                        if(record.syncCount.longLongValue > currentSyncCount.longLongValue + 1){
                            okToUpdateSyncCount = NO;
                        }
                        newRecord.syncCount = [record.syncCount longLongValue];
                        newRecord.dirtyCount = 0;
                        
                        AWSCognitoRecord * existingRecord = [self.records objectForKey:record.key];
                        newRecord.lastModifiedBy = existingRecord.lastModifiedBy;
                        
                        [changedRecords addObject:[[AWSCognitoRecordTuple alloc] initWithLocalRecord:existingRecord remoteRecord:newRecord]];
                    }
                    NSError *error;
                    if([self.sqliteManager updateLocalRecordMetadata:self.name records:changedRecords error:&error]) {
                        // successfully wrote the update notify interested parties
                        [self postDidChangeRemoteValueNotification:changedRecordsNames];
                        if(okToUpdateSyncCount){
                            //if we only increased the sync count by 1, fast forward the last sync count to our update sync count
                            [self.sqliteManager updateLastSyncCount:self.name syncCount:[NSNumber numberWithLongLong:currentSyncCount.longLongValue+1] lastModifiedBy:nil];
                        }
                    } else {
                        [self postDidFailToSynchronizeNotification:error];
                        return [BFTask taskWithError:error];
                    }
                }
            }
            return nil;
        }];
    }
    return nil;
}

-(BFTask *)synchronize {
    [self postDidStartSynchronizeNotification];
    
    [self checkForLocalMergedDatasets];
    
    self.syncSessionToken = nil;
    
    AWSCognitoCredentialsProvider *cognitoCredentials = self.cognitoService.configuration.credentialsProvider;
    return [[[cognitoCredentials getIdentityId] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSError *error = [NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoAuthenticationFailed userInfo:nil];
            [self postDidFailToSynchronizeNotification:error];
            return [BFTask taskWithError:error];
        }
        return [self synchronizeInternal:self.synchronizeRetries];
    }] continueWithBlock:^id(BFTask *task) {
        [self postDidEndSynchronizeNotification];
        return task;
    }];
}

-(BFTask *)synchronizeInternal:(int)remainingAttempts {
    if(remainingAttempts == 0){
        AZLogError(@"Conflict retries exhausted");
        NSError *error = [NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoErrorConflictRetriesExhausted userInfo:nil];
        [self postDidFailToSynchronizeNotification:error];
        return [BFTask taskWithError:error];
    }
    
    //used for determining if we can fast forward the last sync count after update
    self.currentSyncCount = [self.sqliteManager lastSyncCount:self.name];
    
    //delete the dataset if it no longer exists
    if([self.currentSyncCount intValue] == -1){
        AWSCognitoSyncServiceDeleteDatasetRequest *request = [AWSCognitoSyncServiceDeleteDatasetRequest new];
        request.identityPoolId = ((AWSCognitoCredentialsProvider *)self.cognitoService.configuration.credentialsProvider).identityPoolId;
        request.identityId = ((AWSCognitoCredentialsProvider *)self.cognitoService.configuration.credentialsProvider).identityId;
        request.datasetName = self.name;
        return [[self.cognitoService deleteDataset:request]continueWithBlock:^id(BFTask *task) {
            if(task.isCancelled) {
                NSError *error = [NSError errorWithDomain:AWSCognitoErrorDomain code:AWSCognitoErrorTaskCanceled userInfo:nil];
                [self postDidFailToSynchronizeNotification:error];
                return [BFTask taskWithError:error];
            } else if(task.error && task.error.code != AWSCognitoSyncServiceErrorResourceNotFound){
                AZLogError(@"Unable to delete dataset: %@", task.error);
                return task;
            } else {
                [self.sqliteManager deleteMetadata:self.name error:nil];
                return nil;
            }
        }];
    }
    
    return [[self syncPull:remainingAttempts] continueWithSuccessBlock:^id(BFTask *task) {
        return [self syncPush:remainingAttempts];
    }];
}

#pragma mark IdentityMerge

- (void)identityChanged:(NSNotification *)notification {
    AZLogDebug(@"IdentityChanged");
    
    // by the point we are called, all datasets will have been reparented
    [self checkForLocalMergedDatasets];
}

- (void) checkForLocalMergedDatasets {
    if (self.datasetMergedHandler) {
        // check if we have any local merge datasets
        NSArray *localMergeDatasets =  [self.sqliteManager getMergeDatasets:self.name error:nil];
        if (localMergeDatasets) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.datasetMergedHandler(self.name, localMergeDatasets);
            });
        }
    }
}

#pragma mark Notifications

- (void)postDidStartSynchronizeNotification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AWSCognitoDidStartSynchronizeNotification
                                                            object:self
                                                          userInfo:@{@"dataset": self.name}];
    });
}

- (void)postDidEndSynchronizeNotification
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AWSCognitoDidEndSynchronizeNotification
                                                            object:self
                                                          userInfo:@{@"dataset": self.name}];
    });
}

- (void)postDidChangeLocalValueFromRemoteNotification:(NSArray *)changedValues
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AWSCognitoDidChangeLocalValueFromRemoteNotification
                                                            object:self
                                                          userInfo:@{@"dataset": self.name,
                                                                     @"keys": changedValues}];
    });
}

- (void)postDidChangeRemoteValueNotification:(NSArray *)changedValues
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AWSCognitoDidChangeRemoteValueNotification
                                                            object:self
                                                          userInfo:@{@"dataset": self.name,
                                                                     @"keys": changedValues}];
    });
}

- (void)postDidFailToSynchronizeNotification:(NSError *)error
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:AWSCognitoDidFailToSynchronizeNotification
                                                            object:self
                                                          userInfo:@{@"dataset": self.name,
                                                                     @"error": error}];
    });
}

@end
