/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#if AWS_TEST_COGNITO_SYNC_SERVICE

#import <XCTest/XCTest.h>
#import "AWSCore.h"
#import "Cognito.h"
#import "CognitoTestUtils.h"

@interface AWSCognitoSyncServiceTests : XCTestCase

@end

NSString *_identityId;
AWSCognitoSyncService *_client;

@implementation AWSCognitoSyncServiceTests

+ (void)setUp {
    //[AZLogger defaultLogger].logLevel = AZLogLevelVerbose;
    [CognitoTestUtils createIdentityPool];
    
    AWSCognitoCredentialsProvider *provider = [AWSCognitoCredentialsProvider credentialsWithRegionType:AWSRegionUSEast1
                                                                                             accountId:[CognitoTestUtils accountId]
                                                                                        identityPoolId:[CognitoTestUtils identityPoolId]
                                                                                         unauthRoleArn:[CognitoTestUtils unauthRoleArn]
                                                                                           authRoleArn:[CognitoTestUtils authRoleArn]];

    [[provider refresh] waitUntilFinished];
    _identityId = provider.identityId;
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:provider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    // Can't use default because default config was probably written earlier
    _client = [[AWSCognitoSyncService alloc] initWithConfiguration:configuration];
}

+ (void)tearDown {
    [CognitoTestUtils deleteIdentityPool];
}

- (void)testExample {
    
    AWSCognitoSyncServiceListRecordsRequest *request = [AWSCognitoSyncServiceListRecordsRequest new];
    request.datasetName = @"mydataset";
    request.identityPoolId = [CognitoTestUtils identityPoolId];
    request.identityId = _identityId;

    [[[_client listRecords:request] continueWithBlock:^id(BFTask *task) {
        AWSCognitoSyncServiceListRecordsResponse *response = task.result;
        XCTAssertNotNil(response, @"response should not be nil");
        return nil;
    }] waitUntilFinished];
}

- (void)testExampleFailed {
    AWSStaticCredentialsProvider *provider = [AWSStaticCredentialsProvider credentialsWithCredentialsFilename:@"credentials"];
    AWSServiceConfiguration * configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:provider];
    AWSCognitoSyncService *client = [[AWSCognitoSyncService alloc] initWithConfiguration:configuration];
    
    AWSCognitoSyncServiceDescribeDatasetRequest *request = [AWSCognitoSyncServiceDescribeDatasetRequest new];
    request.datasetName = @"wrongname"; //Wrong DatasetName
    request.identityPoolId = [CognitoTestUtils identityPoolId];
    request.identityId = _identityId;
    
    [[[client describeDataset:request] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error,@"expected error but got nil");
        XCTAssertEqual(AWSCognitoSyncServiceErrorResourceNotFound, task.error.code, @"expected AWSCognitoSyncServiceErrorResourceNotFound Error but got: %ld",(long)task.error.code);
        
        return nil;
    }] waitUntilFinished];
}

- (void)testSyncSessionToken {
    AWSStaticCredentialsProvider *provider = [AWSStaticCredentialsProvider credentialsWithCredentialsFilename:@"credentials"];
    AWSServiceConfiguration * configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:provider];
    AWSCognitoSyncService *client = [[AWSCognitoSyncService alloc] initWithConfiguration:configuration];
    
    // Do any initial list to get a token
    AWSCognitoSyncServiceListRecordsRequest *listRequest = [AWSCognitoSyncServiceListRecordsRequest new];
    listRequest.datasetName = @"tokentest";
    listRequest.identityPoolId = [CognitoTestUtils identityPoolId];
    listRequest.identityId = _identityId;
    listRequest.lastSyncCount = @"0";
    
    __block NSString *_sessionToken = nil;
    [[[client listRecords:listRequest] continueWithBlock:^id(BFTask *task) {
        AWSCognitoSyncServiceListRecordsResponse *result = task.result;
        _sessionToken = result.syncSessionToken;
        return nil;
    }] waitUntilFinished];
    
    XCTAssertNotNil(_sessionToken, @"Couldn't get a session token");
    
    // Retry the list with the token
    listRequest.syncSessionToken = _sessionToken;
    
    [[[client listRecords:listRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"Error from list w/session token: %@", task.error);
        return nil;
    }] waitUntilFinished];
    
    // Create an update request, use the token
    AWSCognitoSyncServiceRecordPatch *patch = [AWSCognitoSyncServiceRecordPatch new];
    patch.key = @"tokenkey";
    patch.syncCount = [NSNumber numberWithInt:0];
    patch.value = @"forced";
    patch.op = AWSCognitoSyncServiceOperationReplace;
    
    AWSCognitoSyncServiceUpdateRecordsRequest *updateRequest = [AWSCognitoSyncServiceUpdateRecordsRequest new];
    updateRequest.datasetName = @"tokentest";
    updateRequest.identityPoolId = [CognitoTestUtils identityPoolId];
    updateRequest.identityId = _identityId;
    updateRequest.syncSessionToken = _sessionToken;
    updateRequest.recordPatches = [NSArray arrayWithObject:patch];
    
    [[[client updateRecords:updateRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNil(task.error, @"Error from update w/session token: %@", task.error);
        return nil;
    }] waitUntilFinished];
    
    // Now that the token was used to push, listing again should fail
    [[[client listRecords:listRequest] continueWithBlock:^id(BFTask *task) {
        XCTAssertNotNil(task.error, @"Should have gotten error");
        return nil;
    }] waitUntilFinished];
}

@end

#endif
