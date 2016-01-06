//
// Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "AWSCognitoSyncModel.h"
#import <AWSCore/AWSCategory.h>

NSString *const AWSCognitoSyncErrorDomain = @"com.amazonaws.AWSCognitoSyncErrorDomain";

@implementation AWSCognitoSyncBulkPublishRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncBulkPublishResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncCognitoStreams

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"roleArn" : @"RoleArn",
             @"streamName" : @"StreamName",
             @"streamingStatus" : @"StreamingStatus",
             };
}

+ (NSValueTransformer *)streamingStatusJSONTransformer {
    return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"ENABLED"]) {
            return @(AWSCognitoSyncStreamingStatusEnabled);
        }
        if ([value isEqualToString:@"DISABLED"]) {
            return @(AWSCognitoSyncStreamingStatusDisabled);
        }
        return @(AWSCognitoSyncStreamingStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case AWSCognitoSyncStreamingStatusEnabled:
                return @"ENABLED";
            case AWSCognitoSyncStreamingStatusDisabled:
                return @"DISABLED";
            case AWSCognitoSyncStreamingStatusUnknown:
            default:
                return nil;
        }
    }];
}

@end

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
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)lastModifiedDateJSONTransformer {
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
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
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncDataset class]];
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
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncDataset class]];
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
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncIdentityPoolUsage class]];
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
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncIdentityUsage class]];
}

@end

@implementation AWSCognitoSyncGetBulkPublishDetailsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncGetBulkPublishDetailsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"bulkPublishCompleteTime" : @"BulkPublishCompleteTime",
             @"bulkPublishStartTime" : @"BulkPublishStartTime",
             @"bulkPublishStatus" : @"BulkPublishStatus",
             @"failureMessage" : @"FailureMessage",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

+ (NSValueTransformer *)bulkPublishCompleteTimeJSONTransformer {
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)bulkPublishStartTimeJSONTransformer {
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)bulkPublishStatusJSONTransformer {
    return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"NOT_STARTED"]) {
            return @(AWSCognitoSyncBulkPublishStatusNotStarted);
        }
        if ([value isEqualToString:@"IN_PROGRESS"]) {
            return @(AWSCognitoSyncBulkPublishStatusInProgress);
        }
        if ([value isEqualToString:@"FAILED"]) {
            return @(AWSCognitoSyncBulkPublishStatusFailed);
        }
        if ([value isEqualToString:@"SUCCEEDED"]) {
            return @(AWSCognitoSyncBulkPublishStatusSucceeded);
        }
        return @(AWSCognitoSyncBulkPublishStatusUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case AWSCognitoSyncBulkPublishStatusNotStarted:
                return @"NOT_STARTED";
            case AWSCognitoSyncBulkPublishStatusInProgress:
                return @"IN_PROGRESS";
            case AWSCognitoSyncBulkPublishStatusFailed:
                return @"FAILED";
            case AWSCognitoSyncBulkPublishStatusSucceeded:
                return @"SUCCEEDED";
            case AWSCognitoSyncBulkPublishStatusUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation AWSCognitoSyncGetCognitoEventsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncGetCognitoEventsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"events" : @"Events",
             };
}

@end

@implementation AWSCognitoSyncGetIdentityPoolConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncGetIdentityPoolConfigurationResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"cognitoStreams" : @"CognitoStreams",
             @"identityPoolId" : @"IdentityPoolId",
             @"pushSync" : @"PushSync",
             };
}

+ (NSValueTransformer *)cognitoStreamsJSONTransformer {
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncCognitoStreams class]];
}

+ (NSValueTransformer *)pushSyncJSONTransformer {
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncPushSync class]];
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
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
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
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
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
	return [NSValueTransformer awsmtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncDataset class]];
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
	return [NSValueTransformer awsmtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncIdentityPoolUsage class]];
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
	return [NSValueTransformer awsmtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncRecord class]];
}

@end

@implementation AWSCognitoSyncPushSync

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"applicationArns" : @"ApplicationArns",
             @"roleArn" : @"RoleArn",
             };
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
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)lastModifiedDateJSONTransformer {
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
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
	return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSNumber *number) {
        return [NSDate dateWithTimeIntervalSince1970:[number doubleValue]];
    } reverseBlock:^id(NSDate *date) {
        return [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)opJSONTransformer {
    return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
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

@implementation AWSCognitoSyncRegisterDeviceRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             @"platform" : @"Platform",
             @"token" : @"Token",
             };
}

+ (NSValueTransformer *)platformJSONTransformer {
    return [AWSMTLValueTransformer reversibleTransformerWithForwardBlock:^NSNumber *(NSString *value) {
        if ([value isEqualToString:@"APNS"]) {
            return @(AWSCognitoSyncPlatformApns);
        }
        if ([value isEqualToString:@"APNS_SANDBOX"]) {
            return @(AWSCognitoSyncPlatformApnsSandbox);
        }
        if ([value isEqualToString:@"GCM"]) {
            return @(AWSCognitoSyncPlatformGcm);
        }
        if ([value isEqualToString:@"ADM"]) {
            return @(AWSCognitoSyncPlatformAdm);
        }
        return @(AWSCognitoSyncPlatformUnknown);
    } reverseBlock:^NSString *(NSNumber *value) {
        switch ([value integerValue]) {
            case AWSCognitoSyncPlatformApns:
                return @"APNS";
            case AWSCognitoSyncPlatformApnsSandbox:
                return @"APNS_SANDBOX";
            case AWSCognitoSyncPlatformGcm:
                return @"GCM";
            case AWSCognitoSyncPlatformAdm:
                return @"ADM";
            case AWSCognitoSyncPlatformUnknown:
            default:
                return nil;
        }
    }];
}

@end

@implementation AWSCognitoSyncRegisterDeviceResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"deviceId" : @"DeviceId",
             };
}

@end

@implementation AWSCognitoSyncSetCognitoEventsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"events" : @"Events",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncSetIdentityPoolConfigurationRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"cognitoStreams" : @"CognitoStreams",
             @"identityPoolId" : @"IdentityPoolId",
             @"pushSync" : @"PushSync",
             };
}

+ (NSValueTransformer *)cognitoStreamsJSONTransformer {
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncCognitoStreams class]];
}

+ (NSValueTransformer *)pushSyncJSONTransformer {
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncPushSync class]];
}

@end

@implementation AWSCognitoSyncSetIdentityPoolConfigurationResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"cognitoStreams" : @"CognitoStreams",
             @"identityPoolId" : @"IdentityPoolId",
             @"pushSync" : @"PushSync",
             };
}

+ (NSValueTransformer *)cognitoStreamsJSONTransformer {
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncCognitoStreams class]];
}

+ (NSValueTransformer *)pushSyncJSONTransformer {
	return [NSValueTransformer awsmtl_JSONDictionaryTransformerWithModelClass:[AWSCognitoSyncPushSync class]];
}

@end

@implementation AWSCognitoSyncSubscribeToDatasetRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"datasetName" : @"DatasetName",
             @"deviceId" : @"DeviceId",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncSubscribeToDatasetResponse

@end

@implementation AWSCognitoSyncUnsubscribeFromDatasetRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"datasetName" : @"DatasetName",
             @"deviceId" : @"DeviceId",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             };
}

@end

@implementation AWSCognitoSyncUnsubscribeFromDatasetResponse

@end

@implementation AWSCognitoSyncUpdateRecordsRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"clientContext" : @"ClientContext",
             @"datasetName" : @"DatasetName",
             @"deviceId" : @"DeviceId",
             @"identityId" : @"IdentityId",
             @"identityPoolId" : @"IdentityPoolId",
             @"recordPatches" : @"RecordPatches",
             @"syncSessionToken" : @"SyncSessionToken",
             };
}

+ (NSValueTransformer *)recordPatchesJSONTransformer {
	return [NSValueTransformer awsmtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncRecordPatch class]];
}

@end

@implementation AWSCognitoSyncUpdateRecordsResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
             @"records" : @"Records",
             };
}

+ (NSValueTransformer *)recordsJSONTransformer {
	return [NSValueTransformer awsmtl_JSONArrayTransformerWithModelClass:[AWSCognitoSyncRecord class]];
}

@end
