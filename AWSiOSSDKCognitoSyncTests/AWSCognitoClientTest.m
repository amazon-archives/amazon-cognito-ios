/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#if AWS_TEST_COGNITO_CLIENT

#import <XCTest/XCTest.h>
#import "AWSCore.h"
#import "Cognito.h"
#import "CognitoTestUtils.h"
#import "AWSCognitoSQLiteManager.h"

@interface AWSCognitoClientTest : XCTestCase
@end


NSString *_notificationDataset = @"notifications";
NSString *_notificationKey = @"notification";
BOOL _startReceived = NO;
BOOL _endReceived = NO;
BOOL _remoteChangeReceived = NO;
BOOL _localChangeReceived = NO;
BOOL _failedReceived = NO;

@implementation AWSCognitoClientTest
+ (void)setUp {    
    [CognitoTestUtils createFBAccount];
    [CognitoTestUtils createIdentityPool];
    
    
    AWSCognitoCredentialsProvider *provider = [AWSCognitoCredentialsProvider credentialsWithRegionType:AWSRegionUSEast1
                                                                                             accountId:[CognitoTestUtils accountId]
                                                                                        identityPoolId:[CognitoTestUtils identityPoolId]
                                                                                         unauthRoleArn:[CognitoTestUtils unauthRoleArn]
                                                                                           authRoleArn:[CognitoTestUtils authRoleArn]];

    
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:provider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

+ (void)tearDown {
    [[AWSCognito defaultCognito] wipe];
    [CognitoTestUtils deleteFBAccount];
    [CognitoTestUtils deleteIdentityPool];
}

- (void)forceUpdate:(NSString *)datasetName withKey:(NSString *)key {
    // generate a remote update
    AWSCognitoSyncService *client = [AWSCognitoSyncService defaultCognitoSyncService];
    
    AWSCognitoSyncServiceListRecordsRequest *list = [AWSCognitoSyncServiceListRecordsRequest new];
    list.datasetName = datasetName;
    list.identityId = ((AWSCognitoCredentialsProvider *)client.configuration.credentialsProvider).identityId;
    list.identityPoolId = ((AWSCognitoCredentialsProvider *)client.configuration.credentialsProvider).identityPoolId;
    [[[[client listRecords:list] continueWithBlock:^id(BFTask *task) {
        AWSCognitoSyncServiceListRecordsResponse *listResponse = task.result;
        
        AWSCognitoSyncServiceRecordPatch *patch = [AWSCognitoSyncServiceRecordPatch new];
        patch.key = key;
        patch.syncCount = listResponse.datasetSyncCount;
        patch.value = @"forced";
        patch.op = AWSCognitoSyncServiceOperationReplace;
        
        AWSCognitoSyncServiceUpdateRecordsRequest *update = [AWSCognitoSyncServiceUpdateRecordsRequest new];
        update.identityId = ((AWSCognitoCredentialsProvider *)client.configuration.credentialsProvider).identityId;
        update.identityPoolId = ((AWSCognitoCredentialsProvider *)client.configuration.credentialsProvider).identityPoolId;
        update.datasetName = datasetName;
        update.recordPatches = [NSArray arrayWithObject:patch];
        update.syncSessionToken = listResponse.syncSessionToken;
        return [client updateRecords:update];
    }] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"Could not write update");
        return nil;
    }] waitUntilFinished];
}

- (void)testSynchronize {
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"mydataset"];
    [dataset setString:@"on" forKey:@"wifi"];
    [[dataset synchronize] waitUntilFinished];
    for(AWSCognitoRecord * record in [dataset getAllRecords]){
        //ensure there are no dirty records after sync.
        if(record.isDirty == YES){
            XCTFail(@"Dirty record after sync: %@", record.recordId);
        }
    }
    // check the sync count to make sure it incremented (go all the way back to the DB)
    dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"mydataset"];
    XCTAssertTrue([dataset.lastSyncCount intValue] == 1, @"sync count should have incremented");
}

- (void)testSynchronizeOnConnectivity {
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"testSyncOnConnect"];
    [dataset setString:@"on" forKey:@"wifi"];
    [[dataset synchronizeOnConnectivity] waitUntilFinished];
    for(AWSCognitoRecord * record in [dataset getAllRecords]){
        //ensure there are no dirty records after sync.
        if(record.isDirty == YES){
            XCTFail(@"Dirty record after sync: %@", record.recordId);
        }
    }
    // check the sync count to make sure it incremented (go all the way back to the DB)
    dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"testSyncOnConnect"];
    XCTAssertTrue([dataset.lastSyncCount intValue] == 1, @"sync count should have incremented");
}

- (void)testGet {
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"testget"];
    [dataset setString:@"on" forKey:@"wifi"];
    NSArray *records = [dataset getAllRecords];
    XCTAssertTrue(records.count == 1, @"should be one record");
    if (records.count > 0) {
        AWSCognitoRecord *record = [records objectAtIndex:0];
        XCTAssertTrue([record.recordId isEqualToString:@"wifi"], @"Unexpected record id");
        XCTAssertTrue([record.data.string isEqualToString:@"on"], @"Unexpected value");
    }
    NSDictionary *recordsAsDictionary = [dataset getAll];
    XCTAssertTrue(recordsAsDictionary.count == 1, @"should be one record");
    XCTAssertTrue([[recordsAsDictionary objectForKey:@"wifi"] isEqualToString:@"on"], @"Could not find key in dictionary");
    [dataset clear];
}

- (void)testRemove {
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"testremove"];
    // add a value and sync
    [dataset setString:@"on" forKey:@"wifi"];
    [[dataset synchronize] waitUntilFinished];
    // now remove it
    [dataset removeObjectForKey:@"wifi"];
    
    // list the records, record should still show up
    NSArray *records = [dataset getAllRecords];
    XCTAssertTrue(records.count == 1, @"should be one record");
    if (records.count > 0) {
        AWSCognitoRecord *record = [records objectAtIndex:0];
        XCTAssertTrue([record.recordId isEqualToString:@"wifi"], @"Unexpected record id");
        XCTAssertTrue([record isDirty], @"Record should be dirty");
    }
    
    // dictionary should be empty
    NSDictionary *recordsAsDictionary = [dataset getAll];
    XCTAssertTrue(recordsAsDictionary.count == 0, @"should be no records in the dictionary");
    [[dataset synchronize] waitUntilFinished];
    
    // list the records again, should be empty
    records = [dataset getAllRecords];
    XCTAssertTrue(records.count == 1, @"should be one record");
    
    // dictionary should still be empty 
    recordsAsDictionary = [dataset getAll];
    XCTAssertTrue(recordsAsDictionary.count == 0, @"should be no records in the dictionary");
    [dataset clear];
    [[dataset synchronize] waitUntilFinished];
}

- (void)testClear {
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"todelete"];
    [dataset setString:@"on" forKey:@"wifi"];
    [dataset synchronize];
    [dataset clear];
    [[dataset synchronize] waitUntilFinished];
    for(AWSCognitoRecord * record in [dataset getAllRecords]){
       XCTFail(@"Record exists after deletion: %@", record.recordId);
    }
}

- (void)testListDatasets {
    NSArray *datasets = [[AWSCognito defaultCognito] listDatasets];
    NSUInteger oldCount = [datasets count];
    
    // add a new dataset
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"newlocal"];
    [dataset setString:@"on" forKey:@"wifi"];
    datasets = [[AWSCognito defaultCognito] listDatasets];
    
    NSUInteger newCount = [datasets count];
    XCTAssertTrue(oldCount + 1 == newCount, @"number of datasets should have increased");
}

- (void)testRefreshDatasetMetadata {
    __block NSUInteger count;
    [[[[AWSCognito defaultCognito] refreshDatasetMetadata] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"Error in listDatasets [%@]", task.error);
        NSArray *datasets = task.result;
        for(AWSCognitoSyncServiceDataset * dataset in datasets){
            NSLog(@"Dataset: %@",[dataset datasetName]);
        }
        count = datasets.count;
        return nil;
    }] waitUntilFinished];
    
    // add a new dataset
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:@"newremote"];
    [dataset setString:@"on" forKey:@"wifi"];
    [[dataset synchronize] waitUntilFinished];
    
    [[[[AWSCognito defaultCognito] refreshDatasetMetadata] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"Error in listDatasets [%@]", task.error);
        NSArray *datasets = task.result;
        for(AWSCognitoSyncServiceDataset * dataset in datasets){
            NSLog(@"Dataset: %@",[dataset datasetName]);
        }
        XCTAssertTrue(count + 1 == datasets.count, @"number of datasets should have increased");
        return nil;
    }] waitUntilFinished];
}

- (void)testSyncNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncStartNotification:) name:AWSCognitoDidStartSynchronizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncEndNotification:) name:AWSCognitoDidEndSynchronizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncRemoteChangedNotification:) name:AWSCognitoDidChangeRemoteValueNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncLocalChangedNotification:) name:AWSCognitoDidChangeLocalValueFromRemoteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncFailedNotification:) name:AWSCognitoDidFailToSynchronizeNotification object:nil];
    
    // create a dataset
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:_notificationDataset];
    [dataset setString:@"old" forKey:_notificationKey];
    
    // call a sync
    [[dataset synchronize] waitUntilFinished];
    
    XCTAssertTrue(_startReceived, @"Did not get start notification");
    XCTAssertTrue(_endReceived, @"Did not get end notification");
    XCTAssertTrue(_remoteChangeReceived, @"Did not get remote changed notification");
    
    [self forceUpdate:_notificationDataset withKey:_notificationKey];
    
    [[dataset synchronize] waitUntilFinished];
    
    XCTAssertTrue(_localChangeReceived, @"Did not get local changed notification");
    
    // reset the value
    [dataset setString:@"old" forKey:_notificationKey];
    [[dataset synchronize] waitUntilFinished];
    
    // set a conflict handler to force a sync failure
    dataset.conflictHandler = ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
        return nil;
    };
    
    // create a conflict
    [dataset setString:@"new" forKey:_notificationKey];
    [self forceUpdate:_notificationDataset withKey:_notificationKey];
    
    // this should fail
    [[dataset synchronize] waitUntilFinished];
    
    XCTAssertTrue(_failedReceived, @"Did not get sync failed notification");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // delete the dataset
    [dataset clear];
    [[dataset synchronize] waitUntilFinished];
}

- (void)testConflictHandler {
    __block BOOL handlerCalled = NO;
    NSString *myDataset = @"testconflict";
    NSString *key = @"conflict";
    
    // create a dataset
    AWSCognitoDataset* dataset = [[AWSCognito defaultCognito] openOrCreateDataset:myDataset];
    [dataset setString:@"old" forKey:key];
    
    [[dataset synchronize] waitUntilFinished];
    
    // create a conflict
    [self forceUpdate:myDataset withKey:key];
    [dataset setString:@"new" forKey:key];
    
    // set a conflict handler
    dataset.conflictHandler = ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
        XCTAssertTrue([datasetName isEqualToString:myDataset], @"Dataset doesn't match");
        XCTAssertTrue([conflict.remoteRecord.recordId isEqualToString:conflict.localRecord.recordId], @"Key's for conflict don't match");
        XCTAssertTrue([conflict.remoteRecord.recordId isEqualToString:key], @"Conflicting record doesn't match key");
        handlerCalled = YES;
        return nil;
    };
    
    [[dataset synchronize] waitUntilFinished];
    
    XCTAssertTrue(handlerCalled, @"Conflict handler wasn't called");
    AWSCognitoRecord *record = [dataset recordForKey:key];
    XCTAssertTrue(record.dirty, @"Record is not dirty");
    
    // set a different handler
    dataset.conflictHandler = ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
        return [conflict resolveWithLocalRecord];
    };
    [[dataset synchronize] waitUntilFinished];
    
    // our local change should be persisted
    record = [dataset recordForKey:key];
    XCTAssertFalse(record.dirty, @"Record is dirty");
    XCTAssertTrue([record.data.string isEqualToString:@"new"]);
    
    [dataset clear];
    [[dataset synchronize] waitUntilFinished];
}

-(void)testDatasetDeletedHandler {
    __block NSString *myDatasetName = @"testdelete";
    
    // create a dataset with data and sync it
    AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:myDatasetName];
    [dataset setString:@"foo" forKey:@"bar"];
    [[dataset synchronize] waitUntilFinished];
    
    
    // delete the dataset with the low level client
    AWSCognitoSyncService *client = [AWSCognitoSyncService defaultCognitoSyncService];
    AWSCognitoSyncServiceDeleteDatasetRequest *deleteDataset = [AWSCognitoSyncServiceDeleteDatasetRequest new];
    deleteDataset.datasetName = myDatasetName;
    deleteDataset.identityId = ((AWSCognitoCredentialsProvider *)client.configuration.credentialsProvider).identityId;
    deleteDataset.identityPoolId = ((AWSCognitoCredentialsProvider *)client.configuration.credentialsProvider).identityPoolId;
    [[client deleteDataset:deleteDataset] waitUntilFinished];
    
    
    __block BOOL _handlerCalled = NO;
    
    // set our handler to return YES so the dataset will be recreated
    dataset.datasetDeletedHandler = ^BOOL (NSString *datasetName) {
        XCTAssertTrue([myDatasetName isEqualToString:datasetName], @"dataset names do not match");
        _handlerCalled = YES;
        return YES;
    };
    
    // sync again
    [[dataset synchronize] waitUntilFinished];
    
    // make sure the handler was called
    XCTAssertTrue(_handlerCalled, @"handler was not called");
    
    // check to see our data is still there
    NSString *value = [dataset stringForKey:@"bar"];
    XCTAssertTrue([value isEqualToString:@"foo"]);
    
    _handlerCalled = NO;
    // set the handler to return NO so it will be deleted
    dataset.datasetDeletedHandler = ^BOOL (NSString *datasetName) {
        XCTAssertTrue([myDatasetName isEqualToString:datasetName], @"dataset names do not match");
        _handlerCalled = YES;
        return NO;
    };
    
    // delete it again
    [[client deleteDataset:deleteDataset] waitUntilFinished];
    
    // sync again
    [[dataset synchronize] waitUntilFinished];
    
    // make sure the handler was called
    XCTAssertTrue(_handlerCalled, @"handler was not called");
    
    // check to see that our data is no longer there
    value = [dataset stringForKey:@"bar"];
    XCTAssertNil(value, @"value was not deleted");
}

-(void)testDatasetDeletedHandlerOnResurrect {
    __block NSString *myDatasetName = @"testresurrection";
    
    // create a dataset with data and sync it
    AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:myDatasetName];
    [dataset setString:@"foo" forKey:@"bar"];
    [[dataset synchronize] waitUntilFinished];
    
    // delete the dataset with the low level client
    AWSCognitoSyncService *client = [AWSCognitoSyncService defaultCognitoSyncService];
    AWSCognitoSyncServiceDeleteDatasetRequest *deleteDataset = [AWSCognitoSyncServiceDeleteDatasetRequest new];
    deleteDataset.datasetName = myDatasetName;
    deleteDataset.identityId = ((AWSCognitoCredentialsProvider *)client.configuration.credentialsProvider).identityId;
    deleteDataset.identityPoolId = ((AWSCognitoCredentialsProvider *)client.configuration.credentialsProvider).identityPoolId;
    [[client deleteDataset:deleteDataset] waitUntilFinished];
    
    [self forceUpdate:myDatasetName withKey:@"baz"];
    
    // sync again
    [[dataset synchronize] waitUntilFinished];
    
    // check to see our data is still there
    NSString *value = [dataset stringForKey:@"bar"];
    XCTAssertTrue([value isEqualToString:@"foo"]);
    value = [dataset stringForKey:@"baz"];
    XCTAssertTrue([value isEqualToString:@"forced"]);
    
    __block BOOL _handlerCalled = NO;
    // set the handler to return NO so it will be deleted
    dataset.datasetDeletedHandler = ^BOOL (NSString *datasetName) {
        XCTAssertTrue([myDatasetName isEqualToString:datasetName], @"dataset names do not match");
        _handlerCalled = YES;
        return NO;
    };
    
    // set a value that will be deleted
    [dataset setString:@"deleteme" forKey:@"deleteme"];
    
    // delete and resurrect it again
    [[client deleteDataset:deleteDataset] waitUntilFinished];
    [self forceUpdate:myDatasetName withKey:@"baz"];
    
    // sync again
    [[dataset synchronize] waitUntilFinished];
    
    // make sure the handler was called
    XCTAssertTrue(_handlerCalled, @"handler was not called");
    
    // check to see that our data is no longer there
    value = [dataset stringForKey:@"deleteme"];
    XCTAssertNil(value, @"value was not deleted");
    value = [dataset stringForKey:@"baz"];
    XCTAssertTrue([value isEqualToString:@"forced"]);
}

-(void)testDatasetMergedHandlerLocal {
    //[[((AWSCognitoCredentialsProvider *)[AWSCognito defaultCognito].configuration.credentialsProvider) getIdentityId] waitUntilFinished];
    __block NSString *myDatasetName = @"testmerge";
    
    // Create a sqlitemanager with a different ID
    AWSCognitoSQLiteManager *manager = [[AWSCognitoSQLiteManager alloc] initWithIdentityId:@"otherid" deviceId:@"tester"];
    [manager initializeDatasetTables:myDatasetName];
    
    // Create a dataset in different ID
    AWSCognitoRecordValue* on = [[AWSCognitoRecordValue alloc] initWithString:@"on"];
    AWSCognitoRecord* record = [[AWSCognitoRecord alloc] initWithId:@"wifi" data:on];
    [manager putRecord:record datasetName:myDatasetName error:nil];
    
    // Reparent the dataset
    [manager reparentDatasets:@"otherid" withNewId:((AWSCognitoCredentialsProvider *)[AWSCognito defaultCognito].configuration.credentialsProvider).identityId error:nil];
    
    // Open the same dataset name in our ID
    AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:myDatasetName];
    
    __block BOOL _handlerCalled = NO;
    __block NSString *_mergedDatasetName = nil;
    
    // Register merge handler
    dataset.datasetMergedHandler = ^(NSString *datasetName, NSArray *datasets) {
        _handlerCalled = YES;
        XCTAssertTrue([datasetName isEqualToString:myDatasetName], @"dataset name doesn't match");
        XCTAssertTrue(datasets.count == 1, @"There should only be one merged dataset");
        _mergedDatasetName = [datasets objectAtIndex:0];
    };
    
    // Sync the dataset
    [[dataset synchronize] waitUntilFinished];
    
    // Check handler (should have run)
    XCTAssertTrue(_handlerCalled, @"Handler never ran");
    XCTAssertNotNil(_mergedDatasetName, @"should have gotten a dataset name");
    
    // Clear the merged dataset
    AWSCognitoDataset *mergedDataset = [[AWSCognito defaultCognito] openOrCreateDataset:_mergedDatasetName];
    [mergedDataset clear];
    [[mergedDataset synchronize] waitUntilFinished];
    
    // reset the handler (shouldn't run this time
    dataset.datasetMergedHandler = ^(NSString *datasetName, NSArray *datasets) {
        XCTFail(@"Handler shouldn't have run");
    };
    
    // Sync the dataset
    [[dataset synchronize] waitUntilFinished];
    
    // Clean up
    [dataset clear];
    [[dataset synchronize] waitUntilFinished];
}

-(void)testDatasetMergedHandlerRemote {
    // TODO: can we test the mergedatasets from the service?
}

#pragma mark - Notifications

-(void)syncStartNotification:(NSNotification *) notification {
    NSString *datasetName = [notification.userInfo objectForKey:@"dataset"];
    XCTAssertNotNil(datasetName, @"Notification should have dataset");
    XCTAssertTrue([datasetName isEqualToString:_notificationDataset], @"'%@' doesn't match expected '%@' for datasetname", datasetName, _notificationDataset);
    _startReceived = YES;
}

-(void)syncEndNotification:(NSNotification *) notification {
    NSString *datasetName = [notification.userInfo objectForKey:@"dataset"];
    XCTAssertNotNil(datasetName, @"Notification should have dataset");
    XCTAssertTrue([datasetName isEqualToString:_notificationDataset], @"'%@' doesn't match expected '%@' for datasetname", datasetName, _notificationDataset);
    _endReceived = YES;
}

-(void)syncRemoteChangedNotification:(NSNotification *) notification {
    NSString *datasetName = [notification.userInfo objectForKey:@"dataset"];
    NSArray *keys = [notification.userInfo objectForKey:@"keys"];
    XCTAssertNotNil(datasetName, @"Notification should have dataset");
    XCTAssertNotNil(keys, @"Notification should a have a list of keys");
    XCTAssertTrue(keys.count == 1, @"Should have only been a single modified key");
    XCTAssertTrue([datasetName isEqualToString:_notificationDataset], @"'%@' doesn't match expected '%@' for datasetname", datasetName, _notificationDataset);
    if (keys.count > 0) {
        NSString *changedKey = [keys objectAtIndex:0];
        XCTAssertTrue([changedKey isEqualToString:_notificationKey], @"'%@' doesn't match expected '%@' for key", changedKey, _notificationKey);
    }
    _remoteChangeReceived = YES;
}

-(void)syncLocalChangedNotification:(NSNotification *) notification {
    NSString *datasetName = [notification.userInfo objectForKey:@"dataset"];
    NSArray *keys = [notification.userInfo objectForKey:@"keys"];
    XCTAssertNotNil(datasetName, @"Notification should have dataset");
    XCTAssertNotNil(keys, @"Notification should a have a list of keys");
    XCTAssertTrue(keys.count == 1, @"Should have only been a single modified key");
    XCTAssertTrue([datasetName isEqualToString:_notificationDataset], @"'%@' doesn't match expected '%@' for datasetname", datasetName, _notificationDataset);
    if (keys.count > 0) {
        NSString *changedKey = [keys objectAtIndex:0];
        XCTAssertTrue([changedKey isEqualToString:_notificationKey], @"'%@' doesn't match expected '%@' for key", changedKey, _notificationKey);
    }
    _localChangeReceived = YES;
}

-(void)syncFailedNotification:(NSNotification *) notification {
    NSString *datasetName = [notification.userInfo objectForKey:@"dataset"];
    XCTAssertTrue([datasetName isEqualToString:_notificationDataset], @"'%@' doesn't match expected '%@' for datasetname", datasetName, _notificationDataset);
    _failedReceived = YES;
}

@end

#endif
