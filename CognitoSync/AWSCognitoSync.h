/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import "AWSService.h"
#import "AWSCognitoSyncModel.h"

@class BFTask;

/**
 *
 */
@interface AWSCognitoSync : AWSService

@property (nonatomic, strong, readonly) AWSServiceConfiguration *configuration;

+ (instancetype)defaultCognitoSync;

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration;

- (BFTask *)deleteDataset:(AWSCognitoSyncDeleteDatasetRequest *)request;

- (BFTask *)describeDataset:(AWSCognitoSyncDescribeDatasetRequest *)request;

- (BFTask *)describeIdentityPoolUsage:(AWSCognitoSyncDescribeIdentityPoolUsageRequest *)request;

- (BFTask *)describeIdentityUsage:(AWSCognitoSyncDescribeIdentityUsageRequest *)request;

- (BFTask *)listDatasets:(AWSCognitoSyncListDatasetsRequest *)request;

- (BFTask *)listIdentityPoolUsage:(AWSCognitoSyncListIdentityPoolUsageRequest *)request;

- (BFTask *)listRecords:(AWSCognitoSyncListRecordsRequest *)request;

- (BFTask *)updateRecords:(AWSCognitoSyncUpdateRecordsRequest *)request;

@end
