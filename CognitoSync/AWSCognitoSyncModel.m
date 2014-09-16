/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import "AWSCognitoSyncModel.h"
#import "AWSCategory.h"

NSString *const AWSCognitoSyncErrorDomain = @"com.amazonaws.AWSCognitoSyncErrorDomain";

@implementation AWSCognitoSyncDataset

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"creationDate" : @"CreationDate",
             @"dataStorage" : @"DataStorage",
             @"datasetName" : @"DatasetName",
             @"identityId" : @"IdentityId",
             @"lastModifiedBy" : @"LastModifiedBy",
             @"lastModifiedDate" : @"LastModifiedDate",
             @"numRecords" : @"NumRecords",
             };
}

+ (NSValueTransformer *)creationDateJSONTransformer {
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)lastModifiedDateJSONTransformer {
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

@end

@implementation AWSCognitoSyncDeleteDatasetRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"datasetName" : @"DatasetName",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncDeleteDatasetResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"dataset" : @"Dataset",
             };
}

+ (NSValueTransformer *)datasetJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncDataset class]];
}

@end

@implementation AWSCognitoSyncDescribeDatasetRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"datasetName" : @"DatasetName",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncDescribeDatasetResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"dataset" : @"Dataset",
             };
}

+ (NSValueTransformer *)datasetJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncDataset class]];
}

@end

@implementation AWSCognitoSyncDescribeIdentityPoolUsageRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncDescribeIdentityPoolUsageResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolUsage" : @"IdentityPoolUsage",
             };
}

+ (NSValueTransformer *)identityPoolUsageJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncIdentityPoolUsage class]];
}

@end

@implementation AWSCognitoSyncDescribeIdentityUsageRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncDescribeIdentityUsageResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityUsage" : @"IdentityUsage",
             };
}

+ (NSValueTransformer *)identityUsageJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncIdentityUsage class]];
}

@end

@implementation AWSCognitoSyncIdentityPoolUsage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"dataStorage" : @"DataStorage",
             @"identityPoolId" : @"IdentityPoolId",
             @"lastModifiedDate" : @"LastModifiedDate",
             @"syncSessionsCount" : @"SyncSessionsCount",
             };
}

+ (NSValueTransformer *)lastModifiedDateJSONTransformer {
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

@end

@implementation AWSCognitoSyncIdentityUsage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"dataStorage" : @"DataStorage",
             @"datasetCount" : @"DatasetCount",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             @"lastModifiedDate" : @"LastModifiedDate",
             };
}

+ (NSValueTransformer *)lastModifiedDateJSONTransformer {
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

@end

@implementation AWSCognitoSyncListDatasetsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             @"maxResults" : @"MaxResults",
             @"nextToken" : @"NextToken",
             };
}

@end

@implementation AWSCognitoSyncListDatasetsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"count" : @"Count",
             @"datasets" : @"Datasets",
             @"nextToken" : @"NextToken",
             };
}

+ (NSValueTransformer *)datasetsJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncDataset class]];
}

@end

@implementation AWSCognitoSyncListIdentityPoolUsageRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"maxResults" : @"MaxResults",
             @"nextToken" : @"NextToken",
             };
}

@end

@implementation AWSCognitoSyncListIdentityPoolUsageResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"count" : @"Count",
             @"identityPoolUsages" : @"IdentityPoolUsages",
             @"maxResults" : @"MaxResults",
             @"nextToken" : @"NextToken",
             };
}

+ (NSValueTransformer *)identityPoolUsagesJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncIdentityPoolUsage class]];
}

@end

@implementation AWSCognitoSyncListRecordsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"datasetName" : @"DatasetName",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             @"lastSyncCount" : @"LastSyncCount",
             @"maxResults" : @"MaxResults",
             @"nextToken" : @"NextToken",
             @"syncSessionToken" : @"SyncSessionToken",
             };
}

@end

@implementation AWSCognitoSyncListRecordsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"count" : @"Count",
             @"datasetDeletedAfterRequestedSyncCount" : @"DatasetDeletedAfterRequestedSyncCount",
             @"datasetExists" : @"DatasetExists",
             @"datasetSyncCount" : @"DatasetSyncCount",
             @"lastModifiedBy" : @"LastModifiedBy",
             @"mergedDatasetNames" : @"MergedDatasetNames",
             @"nextToken" : @"NextToken",
             @"records" : @"Records",
             @"syncSessionToken" : @"SyncSessionToken",
             };
}

+ (NSValueTransformer *)recordsJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncRecord class]];
}

@end

@implementation AWSCognitoSyncRecord

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"deviceLastModifiedDate" : @"DeviceLastModifiedDate",
             @"key" : @"Key",
             @"lastModifiedBy" : @"LastModifiedBy",
             @"lastModifiedDate" : @"LastModifiedDate",
             @"syncCount" : @"SyncCount",
             @"value" : @"Value",
             };
}

+ (NSValueTransformer *)deviceLastModifiedDateJSONTransformer {
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)lastModifiedDateJSONTransformer {
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

@end

@implementation AWSCognitoSyncRecordPatch

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"deviceLastModifiedDate" : @"DeviceLastModifiedDate",
             @"key" : @"Key",
             @"op" : @"Op",
             @"syncCount" : @"SyncCount",
             @"value" : @"Value",
             };
}

+ (NSValueTransformer *)deviceLastModifiedDateJSONTransformer {
	return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)opJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"replace"]) {
            return @(AWSCognitoSyncOperationReplace);
        }
        if ([value isEqualToString:@"remove"]) {
            return @(AWSCognitoSyncOperationRemove);
        }
        return @(AWSCognitoSyncOperationUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case AWSCognitoSyncOperationReplace:
                return @"replace";
            case AWSCognitoSyncOperationRemove:
                return @"remove";
            case AWSCognitoSyncOperationUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation AWSCognitoSyncUpdateRecordsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"clientContext" : @"ClientContext",
             @"datasetName" : @"DatasetName",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             @"recordPatches" : @"RecordPatches",
             @"syncSessionToken" : @"SyncSessionToken",
             };
}

+ (NSValueTransformer *)recordPatchesJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncRecordPatch class]];
}

@end

@implementation AWSCognitoSyncUpdateRecordsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"records" : @"Records",
             };
}

+ (NSValueTransformer *)recordsJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncRecord class]];
}

@end
