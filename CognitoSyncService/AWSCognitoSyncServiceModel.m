/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import "AWSCognitoSyncServiceModel.h"
#import "AZCategory.h"

NSString *const AWSCognitoSyncServiceErrorDomain = @"com.amazonaws.AWSCognitoSyncServiceErrorDomain";

@implementation AWSCognitoSyncServiceDataset

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

@implementation AWSCognitoSyncServiceDeleteDatasetRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"datasetName" : @"DatasetName",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncServiceDeleteDatasetResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"dataset" : @"Dataset",
             };
}

+ (NSValueTransformer *)datasetJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncServiceDataset class]];
}

@end

@implementation AWSCognitoSyncServiceDescribeDatasetRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"datasetName" : @"DatasetName",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncServiceDescribeDatasetResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"dataset" : @"Dataset",
             };
}

+ (NSValueTransformer *)datasetJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncServiceDataset class]];
}

@end

@implementation AWSCognitoSyncServiceDescribeIdentityPoolUsageRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncServiceDescribeIdentityPoolUsageResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolUsage" : @"IdentityPoolUsage",
             };
}

+ (NSValueTransformer *)identityPoolUsageJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncServiceIdentityPoolUsage class]];
}

@end

@implementation AWSCognitoSyncServiceDescribeIdentityUsageRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncServiceDescribeIdentityUsageResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityUsage" : @"IdentityUsage",
             };
}

+ (NSValueTransformer *)identityUsageJSONTransformer {
	return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncServiceIdentityUsage class]];
}

@end

@implementation AWSCognitoSyncServiceIdentityPoolUsage

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

@implementation AWSCognitoSyncServiceIdentityUsage

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

@implementation AWSCognitoSyncServiceListDatasetsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             @"maxResults" : @"MaxResults",
             @"nextToken" : @"NextToken",
             };
}

@end

@implementation AWSCognitoSyncServiceListDatasetsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"count" : @"Count",
             @"datasets" : @"Datasets",
             @"nextToken" : @"NextToken",
             };
}

+ (NSValueTransformer *)datasetsJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncServiceDataset class]];
}

@end

@implementation AWSCognitoSyncServiceListIdentityPoolUsageRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"maxResults" : @"MaxResults",
             @"nextToken" : @"NextToken",
             };
}

@end

@implementation AWSCognitoSyncServiceListIdentityPoolUsageResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"count" : @"Count",
             @"identityPoolUsages" : @"IdentityPoolUsages",
             @"maxResults" : @"MaxResults",
             @"nextToken" : @"NextToken",
             };
}

+ (NSValueTransformer *)identityPoolUsagesJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncServiceIdentityPoolUsage class]];
}

@end

@implementation AWSCognitoSyncServiceListRecordsRequest

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

@implementation AWSCognitoSyncServiceListRecordsResponse

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
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncServiceRecord class]];
}

@end

@implementation AWSCognitoSyncServiceRecord

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

@implementation AWSCognitoSyncServiceRecordPatch

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
            return @(AWSCognitoSyncServiceOperationReplace);
        }
        if ([value isEqualToString:@"remove"]) {
            return @(AWSCognitoSyncServiceOperationRemove);
        }
        return @(AWSCognitoSyncServiceOperationUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case AWSCognitoSyncServiceOperationReplace:
                return @"replace";
            case AWSCognitoSyncServiceOperationRemove:
                return @"remove";
            case AWSCognitoSyncServiceOperationUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation AWSCognitoSyncServiceUpdateRecordsRequest

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
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncServiceRecordPatch class]];
}

@end

@implementation AWSCognitoSyncServiceUpdateRecordsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"records" : @"Records",
             };
}

+ (NSValueTransformer *)recordsJSONTransformer {
	return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncServiceRecord class]];
}

@end
