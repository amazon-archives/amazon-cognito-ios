/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import "AWSService.h"
#import "AWSCognitoSyncServiceModel.h"

@class BFTask;

/**
 * 
 */
@interface AWSCognitoSyncService : AWSService

@property (nonatomic, strong, readonly) AWSServiceConfiguration *configuration;

+ (instancetype)defaultCognitoSyncService;

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration;

- (BFTask *)deleteDataset:(AWSCognitoSyncServiceDeleteDatasetRequest *)request;

- (BFTask *)describeDataset:(AWSCognitoSyncServiceDescribeDatasetRequest *)request;

- (BFTask *)describeIdentityPoolUsage:(AWSCognitoSyncServiceDescribeIdentityPoolUsageRequest *)request;

- (BFTask *)describeIdentityUsage:(AWSCognitoSyncServiceDescribeIdentityUsageRequest *)request;

- (BFTask *)listDatasets:(AWSCognitoSyncServiceListDatasetsRequest *)request;

- (BFTask *)listIdentityPoolUsage:(AWSCognitoSyncServiceListIdentityPoolUsageRequest *)request;

- (BFTask *)listRecords:(AWSCognitoSyncServiceListRecordsRequest *)request;

- (BFTask *)updateRecords:(AWSCognitoSyncServiceUpdateRecordsRequest *)request;

@end
