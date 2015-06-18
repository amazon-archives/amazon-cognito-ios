/**
 Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#if AWS_TEST_COGNITO_SYNC_SERVICE

#import <XCTest/XCTest.h>
#import "AWSCore.h"
#import "AWSCognito.h"
#import "CognitoTestUtils.h"

@interface AWSCognitoSyncTests : XCTestCase

@end

NSString *_identityId;

@implementation AWSCognitoSyncTests

+ (void)setUp {
    [CognitoTestUtils createIdentityPool];

    AWSCognitoCredentialsProvider *provider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                             identityId:nil
                                                                                              accountId:[CognitoTestUtils accountId]
                                                                                         identityPoolId:[CognitoTestUtils identityPoolId]
                                                                                          unauthRoleArn:[CognitoTestUtils unauthRoleArn]
                                                                                            authRoleArn:[CognitoTestUtils authRoleArn]
                                                                                                 logins:nil];
    [[provider refresh] waitUntilFinished];
    _identityId = provider.identityId;
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:provider];

    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    // Can't use default because default config was probably written earlier
    [AWSCognitoSync registerCognitoSyncWithConfiguration:configuration forKey:@"AWSCognitoSyncTests"];
}

+ (void)tearDown {
    [CognitoTestUtils deleteIdentityPool];
}

- (void)testExample {

    AWSCognitoSyncListRecordsRequest *request = [AWSCognitoSyncListRecordsRequest new];
    request.datasetName = @"mydataset";
    request.identityPoolId = [CognitoTestUtils identityPoolId];
    request.identityId = _identityId;

    [[[[AWSCognitoSync CognitoSyncForKey:@"AWSCognitoSyncTests"] listRecords:request] continueWithBlock:^id(AWSTask *task) {
        AWSCognitoSyncListRecordsResponse *response = task.result;
        XCTAssertNotNil(response, @"response should not be nil");
        return nil;
    }] waitUntilFinished];
}

- (void)testExampleFailed {
    AWSStaticCredentialsProvider *provider = [[AWSStaticCredentialsProvider alloc] initWithCredentialsFilename:@"credentials"];
    AWSServiceConfiguration * configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:provider];
    [AWSCognitoSync registerCognitoSyncWithConfiguration:configuration forKey:@"testExampleFailed"];
    AWSCognitoSync *client = [AWSCognitoSync CognitoSyncForKey:@"testExampleFailed"];

    AWSCognitoSyncDescribeDatasetRequest *request = [AWSCognitoSyncDescribeDatasetRequest new];
    request.datasetName = @"wrongname"; //Wrong DatasetName
    request.identityPoolId = [CognitoTestUtils identityPoolId];
    request.identityId = _identityId;

    [[[client describeDataset:request] continueWithBlock:^id(AWSTask *task) {
        XCTAssertNotNil(task.error,@"expected error but got nil");
        XCTAssertEqual(AWSCognitoSyncErrorResourceNotFound, task.error.code, @"expected AWSCognitoSyncErrorResourceNotFound Error but got: %ld",(long)task.error.code);

        return nil;
    }] waitUntilFinished];

    [AWSCognitoSync removeCognitoSyncForKey:@"testExampleFailed"];
}

- (void)testSyncSessionToken {
    // Do any initial list to get a token
    AWSCognitoSyncListRecordsRequest *listRequest = [AWSCognitoSyncListRecordsRequest new];
    listRequest.datasetName = @"tokentest";
    listRequest.identityPoolId = [CognitoTestUtils identityPoolId];
    listRequest.identityId = _identityId;
    listRequest.lastSyncCount = @0;

    __block NSString *_sessionToken = nil;
    [[[[AWSCognitoSync CognitoSyncForKey:@"AWSCognitoSyncTests"] listRecords:listRequest] continueWithBlock:^id(AWSTask *task) {
        XCTAssertNil(task.error, @"Error: [%@].", task.error);
        AWSCognitoSyncListRecordsResponse *result = task.result;
        _sessionToken = result.syncSessionToken;
        return nil;
    }] waitUntilFinished];

    XCTAssertNotNil(_sessionToken, @"Couldn't get a session token");

    // Retry the list with the token
    listRequest.syncSessionToken = _sessionToken;

    [[[[AWSCognitoSync CognitoSyncForKey:@"AWSCognitoSyncTests"] listRecords:listRequest] continueWithBlock:^id(AWSTask *task) {
        XCTAssertNil(task.error, @"Error from list w/session token: %@", task.error);
        return nil;
    }] waitUntilFinished];

    // Create an update request, use the token
    AWSCognitoSyncRecordPatch *patch = [AWSCognitoSyncRecordPatch new];
    patch.key = @"tokenkey";
    patch.syncCount = [NSNumber numberWithInt:0];
    patch.value = @"forced";
    patch.op = AWSCognitoSyncOperationReplace;

    AWSCognitoSyncUpdateRecordsRequest *updateRequest = [AWSCognitoSyncUpdateRecordsRequest new];
    updateRequest.datasetName = @"tokentest";
    updateRequest.identityPoolId = [CognitoTestUtils identityPoolId];
    updateRequest.identityId = _identityId;
    updateRequest.syncSessionToken = _sessionToken;
    updateRequest.recordPatches = [NSArray arrayWithObject:patch];

    [[[[AWSCognitoSync CognitoSyncForKey:@"AWSCognitoSyncTests"] updateRecords:updateRequest] continueWithBlock:^id(AWSTask *task) {
        XCTAssertNil(task.error, @"Error from update w/session token: %@", task.error);
        return nil;
    }] waitUntilFinished];

    // Now that the token was used to push, listing again should fail
    [[[[AWSCognitoSync CognitoSyncForKey:@"AWSCognitoSyncTests"] listRecords:listRequest] continueWithBlock:^id(AWSTask *task) {
        XCTAssertNotNil(task.error, @"Should have gotten error");
        return nil;
    }] waitUntilFinished];
}

@end

#endif
