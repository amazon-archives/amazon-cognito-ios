/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import "AWSNetworking.h"
#import "AWSModel.h"

FOUNDATION_EXPORT NSString *const AWSCognitoSyncErrorDomain;

typedef NS_ENUM(NSInteger, AWSCognitoSyncErrorType) {
    AWSCognitoSyncErrorUnknown,
    AWSCognitoSyncErrorIncompleteSignature,
    AWSCognitoSyncErrorInvalidClientTokenId,
    AWSCognitoSyncErrorMissingAuthenticationToken,
    AWSCognitoSyncErrorInternalError,
    AWSCognitoSyncErrorInvalidParameter,
    AWSCognitoSyncErrorLimitExceeded,
    AWSCognitoSyncErrorNotAuthorized,
    AWSCognitoSyncErrorResourceConflict,
    AWSCognitoSyncErrorResourceNotFound,
    AWSCognitoSyncErrorTooManyRequests,
};

typedef NS_ENUM(NSInteger, AWSCognitoSyncOperation) {
    AWSCognitoSyncOperationUnknown,
    AWSCognitoSyncOperationReplace,
    AWSCognitoSyncOperationRemove,
};

@class AWSCognitoSyncDataset;
@class AWSCognitoSyncDeleteDatasetRequest;
@class AWSCognitoSyncDeleteDatasetResponse;
@class AWSCognitoSyncDescribeDatasetRequest;
@class AWSCognitoSyncDescribeDatasetResponse;
@class AWSCognitoSyncDescribeIdentityPoolUsageRequest;
@class AWSCognitoSyncDescribeIdentityPoolUsageResponse;
@class AWSCognitoSyncDescribeIdentityUsageRequest;
@class AWSCognitoSyncDescribeIdentityUsageResponse;
@class AWSCognitoSyncIdentityPoolUsage;
@class AWSCognitoSyncIdentityUsage;
@class AWSCognitoSyncListDatasetsRequest;
@class AWSCognitoSyncListDatasetsResponse;
@class AWSCognitoSyncListIdentityPoolUsageRequest;
@class AWSCognitoSyncListIdentityPoolUsageResponse;
@class AWSCognitoSyncListRecordsRequest;
@class AWSCognitoSyncListRecordsResponse;
@class AWSCognitoSyncRecord;
@class AWSCognitoSyncRecordPatch;
@class AWSCognitoSyncUpdateRecordsRequest;
@class AWSCognitoSyncUpdateRecordsResponse;

@interface AWSCognitoSyncDataset : AWSModel

@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSNumber *dataStorage;
@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *lastModifiedBy;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSNumber *numRecords;

@end

@interface AWSCognitoSyncDeleteDatasetRequest : AWSRequest

@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;

@end

@interface AWSCognitoSyncDeleteDatasetResponse : AWSModel

@property (nonatomic, strong) AWSCognitoSyncDataset *dataset;

@end

@interface AWSCognitoSyncDescribeDatasetRequest : AWSRequest

@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;

@end

@interface AWSCognitoSyncDescribeDatasetResponse : AWSModel

@property (nonatomic, strong) AWSCognitoSyncDataset *dataset;

@end

@interface AWSCognitoSyncDescribeIdentityPoolUsageRequest : AWSRequest

@property (nonatomic, strong) NSString *identityPoolId;

@end

@interface AWSCognitoSyncDescribeIdentityPoolUsageResponse : AWSModel

@property (nonatomic, strong) AWSCognitoSyncIdentityPoolUsage *identityPoolUsage;

@end

@interface AWSCognitoSyncDescribeIdentityUsageRequest : AWSRequest

@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;

@end

@interface AWSCognitoSyncDescribeIdentityUsageResponse : AWSModel

@property (nonatomic, strong) AWSCognitoSyncIdentityUsage *identityUsage;

@end

@interface AWSCognitoSyncIdentityPoolUsage : AWSModel

@property (nonatomic, strong) NSNumber *dataStorage;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSNumber *syncSessionsCount;

@end

@interface AWSCognitoSyncIdentityUsage : AWSModel

@property (nonatomic, strong) NSNumber *dataStorage;
@property (nonatomic, strong) NSNumber *datasetCount;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSDate *lastModifiedDate;

@end

@interface AWSCognitoSyncListDatasetsRequest : AWSRequest

@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSString *maxResults;
@property (nonatomic, strong) NSString *nextToken;

@end

@interface AWSCognitoSyncListDatasetsResponse : AWSModel

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSArray *datasets;
@property (nonatomic, strong) NSString *nextToken;

@end

@interface AWSCognitoSyncListIdentityPoolUsageRequest : AWSRequest

@property (nonatomic, strong) NSString *maxResults;
@property (nonatomic, strong) NSString *nextToken;

@end

@interface AWSCognitoSyncListIdentityPoolUsageResponse : AWSModel

@property (nonatomic, strong) NSNumber *count;
@property (nonatomic, strong) NSArray *identityPoolUsages;
@property (nonatomic, strong) NSNumber *maxResults;
@property (nonatomic, strong) NSString *nextToken;

@end

@interface AWSCognitoSyncListRecordsRequest : AWSRequest

@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSString *lastSyncCount;
@property (nonatomic, strong) NSString *maxResults;
@property (nonatomic, strong) NSString *nextToken;
@property (nonatomic, strong) NSString *syncSessionToken;

@end

@interface AWSCognitoSyncListRecordsResponse : AWSModel

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

@interface AWSCognitoSyncRecord : AWSModel

@property (nonatomic, strong) NSDate *deviceLastModifiedDate;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *lastModifiedBy;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, strong) NSNumber *syncCount;
@property (nonatomic, strong) NSString *value;

@end

@interface AWSCognitoSyncRecordPatch : AWSModel

@property (nonatomic, strong) NSDate *deviceLastModifiedDate;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) AWSCognitoSyncOperation op;
@property (nonatomic, strong) NSNumber *syncCount;
@property (nonatomic, strong) NSString *value;

@end

@interface AWSCognitoSyncUpdateRecordsRequest : AWSRequest

@property (nonatomic, strong) NSString *clientContext;
@property (nonatomic, strong) NSString *datasetName;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSArray *recordPatches;
@property (nonatomic, strong) NSString *syncSessionToken;

@end

@interface AWSCognitoSyncUpdateRecordsResponse : AWSModel

@property (nonatomic, strong) NSArray *records;

@end
