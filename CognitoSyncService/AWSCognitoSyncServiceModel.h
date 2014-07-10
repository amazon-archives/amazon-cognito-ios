/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import "AWSNetworking.h"
#import "AZModel.h"

FOUNDATION_EXPORT NSString *const AWSCognitoSyncServiceErrorDomain;

typedef NS_ENUM(NSInteger, AWSCognitoSyncServiceErrorType) {
    AWSCognitoSyncServiceErrorUnknown,
    AWSCognitoSyncServiceErrorIncompleteSignature,
    AWSCognitoSyncServiceErrorInvalidClientTokenId,
    AWSCognitoSyncServiceErrorMissingAuthenticationToken,
    AWSCognitoSyncServiceErrorInternalError,
    AWSCognitoSyncServiceErrorInvalidParameter,
    AWSCognitoSyncServiceErrorLimitExceeded,
    AWSCognitoSyncServiceErrorNotAuthorized,
    AWSCognitoSyncServiceErrorResourceConflict,
    AWSCognitoSyncServiceErrorResourceNotFound,
    AWSCognitoSyncServiceErrorTooManyRequests,
};

typedef NS_ENUM(NSInteger, AWSCognitoSyncServiceOperation) {
    AWSCognitoSyncServiceOperationUnknown,
    AWSCognitoSyncServiceOperationReplace,
    AWSCognitoSyncServiceOperationRemove,
};

@class AWSCognitoSyncServiceDataset;
@class AWSCognitoSyncServiceDeleteDatasetRequest;
@class AWSCognitoSyncServiceDeleteDatasetResponse;
@class AWSCognitoSyncServiceDescribeDatasetRequest;
@class AWSCognitoSyncServiceDescribeDatasetResponse;
@class AWSCognitoSyncServiceDescribeIdentityPoolUsageRequest;
@class AWSCognitoSyncServiceDescribeIdentityPoolUsageResponse;
@class AWSCognitoSyncServiceDescribeIdentityUsageRequest;
@class AWSCognitoSyncServiceDescribeIdentityUsageResponse;
@class AWSCognitoSyncServiceIdentityPoolUsage;
@class AWSCognitoSyncServiceIdentityUsage;
@class AWSCognitoSyncServiceListDatasetsRequest;
@class AWSCognitoSyncServiceListDatasetsResponse;
@class AWSCognitoSyncServiceListIdentityPoolUsageRequest;
@class AWSCognitoSyncServiceListIdentityPoolUsageResponse;
@class AWSCognitoSyncServiceListRecordsRequest;
@class AWSCognitoSyncServiceListRecordsResponse;
@class AWSCognitoSyncServiceRecord;
@class AWSCognitoSyncServiceRecordPatch;
@class AWSCognitoSyncServiceUpdateRecordsRequest;
@class AWSCognitoSyncServiceUpdateRecordsResponse;

@interface AWSCognitoSyncServiceDataset : AZModel

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *dataStorage;
@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *lastModifiedBy;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSNumber *numRecords;

@end

@interface AWSCognitoSyncServiceDeleteDatasetRequest : AWSRequest

@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;

@end

@interface AWSCognitoSyncServiceDeleteDatasetResponse : AZModel

@property (nonatomic, strong) AWSCognitoSyncServiceDataset *dataset;

@end

@interface AWSCognitoSyncServiceDescribeDatasetRequest : AWSRequest

@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;

@end

@interface AWSCognitoSyncServiceDescribeDatasetResponse : AZModel

@property (nonatomic, strong) AWSCognitoSyncServiceDataset *dataset;

@end

@interface AWSCognitoSyncServiceDescribeIdentityPoolUsageRequest : AWSRequest

@property (nonatomic, strong) NSString *identityPoolId;

@end

@interface AWSCognitoSyncServiceDescribeIdentityPoolUsageResponse : AZModel

@property (nonatomic, strong) AWSCognitoSyncServiceIdentityPoolUsage *identityPoolUsage;

@end

@interface AWSCognitoSyncServiceDescribeIdentityUsageRequest : AWSRequest

@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;

@end

@interface AWSCognitoSyncServiceDescribeIdentityUsageResponse : AZModel

@property (nonatomic, strong) AWSCognitoSyncServiceIdentityUsage *identityUsage;

@end

@interface AWSCognitoSyncServiceIdentityPoolUsage : AZModel

@property (nonatomic, strong) NSNumber *dataStorage;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSNumber *syncSessionsCount;

@end

@interface AWSCognitoSyncServiceIdentityUsage : AZModel

@property (nonatomic, strong) NSNumber *dataStorage;
@property (nonatomic, strong) NSNumber *datasetCount;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSDate *lastModifiedDate;

@end

@interface AWSCognitoSyncServiceListDatasetsRequest : AWSRequest

@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSString *maxResults;
@property (nonatomic, strong) NSString *nextToken;

@end

@interface AWSCognitoSyncServiceListDatasetsResponse : AZModel

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSArray *datasets;
@property (nonatomic, strong) NSString *nextToken;

@end

@interface AWSCognitoSyncServiceListIdentityPoolUsageRequest : AWSRequest

@property (nonatomic, strong) NSString *maxResults;
@property (nonatomic, strong) NSString *nextToken;

@end

@interface AWSCognitoSyncServiceListIdentityPoolUsageResponse : AZModel

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSArray *identityPoolUsages;
@property (nonatomic, strong) NSNumber *maxResults;
@property (nonatomic, strong) NSString *nextToken;

@end

@interface AWSCognitoSyncServiceListRecordsRequest : AWSRequest

@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSString *lastSyncCount;
@property (nonatomic, strong) NSString *maxResults;
@property (nonatomic, strong) NSString *nextToken;
@property (nonatomic, strong) NSString *syncSessionToken;

@end

@interface AWSCognitoSyncServiceListRecordsResponse : AZModel

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSNumber *datasetDeletedAfterRequestedSyncCount;
@property (nonatomic, strong) NSNumber *datasetExists;
@property (nonatomic, strong) NSNumber *datasetSyncCount;
@property (nonatomic, strong) NSString *lastModifiedBy;
@property (nonatomic, strong) NSArray *mergedDatasetNames;
@property (nonatomic, strong) NSString *nextToken;
@property (nonatomic, strong) NSArray *records;
@property (nonatomic, strong) NSString *syncSessionToken;

@end

@interface AWSCognitoSyncServiceRecord : AZModel

@property (nonatomic, strong) NSDate *deviceLastModifiedDate;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *lastModifiedBy;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSNumber *syncCount;
@property (nonatomic, strong) NSString *value;

@end

@interface AWSCognitoSyncServiceRecordPatch : AZModel

@property (nonatomic, strong) NSDate *deviceLastModifiedDate;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) AWSCognitoSyncServiceOperation op;
@property (nonatomic, strong) NSNumber *syncCount;
@property (nonatomic, strong) NSString *value;

@end

@interface AWSCognitoSyncServiceUpdateRecordsRequest : AWSRequest

@property (nonatomic, strong) NSString *clientContext;
@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSArray *recordPatches;
@property (nonatomic, strong) NSString *syncSessionToken;

@end

@interface AWSCognitoSyncServiceUpdateRecordsResponse : AZModel

@property (nonatomic, strong) NSArray *records;

@end

