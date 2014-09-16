/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import "AWSCognitoSync.h"
#import "AWSNetworking.h"
#import "AWSCategory.h"
#import "AWSNetworking.h"
#import "AWSSignature.h"
#import "AWSService.h"
#import "AWSNetworking.h"
#import "AWSURLRequestSerialization.h"
#import "AWSURLResponseSerialization.h"
#import "AWSURLRequestRetryHandler.h"

NSString *const AWSCognitoSyncDefinitionFileName = @"css-2014-06-30";

@interface AWSCognitoSyncResponseSerializer : AWSJSONResponseSerializer

@property (nonatomic, assign) Class outputClass;

+ (instancetype)serializerWithOutputClass:(Class)outputClass
                                 resource:(NSString *)resource
                               actionName:(NSString *)actionName;

@end

@implementation AWSCognitoSyncResponseSerializer

#pragma mark - Service errors

static NSDictionary *errorCodeDictionary = nil;
+ (void)initialize {
    errorCodeDictionary = @{
                            @"IncompleteSignature" : @(AWSCognitoSyncErrorIncompleteSignature),
                            @"InvalidClientTokenId" : @(AWSCognitoSyncErrorInvalidClientTokenId),
                            @"MissingAuthenticationToken" : @(AWSCognitoSyncErrorMissingAuthenticationToken),
                            @"InternalErrorException" : @(AWSCognitoSyncErrorInternalError),
                            @"InvalidParameterException" : @(AWSCognitoSyncErrorInvalidParameter),
                            @"LimitExceededException" : @(AWSCognitoSyncErrorLimitExceeded),
                            @"NotAuthorizedException" : @(AWSCognitoSyncErrorNotAuthorized),
                            @"ResourceConflictException" : @(AWSCognitoSyncErrorResourceConflict),
                            @"ResourceNotFoundException" : @(AWSCognitoSyncErrorResourceNotFound),
                            @"TooManyRequestsException" : @(AWSCognitoSyncErrorTooManyRequests),
                            };
}

+ (instancetype)serializerWithOutputClass:(Class)outputClass
                                 resource:(NSString *)resource
                               actionName:(NSString *)actionName {
    AWSCognitoSyncResponseSerializer *serializer = [AWSCognitoSyncResponseSerializer serializerWithResource:resource actionName:actionName];
    serializer.outputClass = outputClass;

    return serializer;
}

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                originalRequest:(NSURLRequest *)originalRequest
                 currentRequest:(NSURLRequest *)currentRequest
                           data:(id)data
                          error:(NSError *__autoreleasing *)error {
    id responseObject = [super responseObjectForResponse:response
                                         originalRequest:originalRequest
                                          currentRequest:currentRequest
                                                    data:data
                                                   error:error];
    if (!*error && [responseObject isKindOfClass:[NSDictionary class]]) {
        NSString *errorTypeStr = [[response allHeaderFields] objectForKey:@"x-amzn-ErrorType"];
        NSString *errorTypeHeader = [[errorTypeStr componentsSeparatedByString:@":"] firstObject];

        if ([errorTypeStr length] > 0 && errorTypeHeader) {
            if (errorCodeDictionary[errorTypeHeader]) {
                if (error) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [responseObject objectForKey:@"message"]?[responseObject objectForKey:@"message"]:[NSNull null], NSLocalizedFailureReasonErrorKey: errorTypeStr};
                    *error = [NSError errorWithDomain:AWSCognitoSyncErrorDomain
                                                 code:[[errorCodeDictionary objectForKey:errorTypeHeader] integerValue]
                                             userInfo:userInfo];
                }
                return responseObject;
            } else if (errorTypeHeader) {
                if (error) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [responseObject objectForKey:@"message"]?[responseObject objectForKey:@"message"]:[NSNull null], NSLocalizedFailureReasonErrorKey: errorTypeStr};
                    *error = [NSError errorWithDomain:AWSCognitoSyncErrorDomain
                                                 code:AWSCognitoSyncErrorUnknown
                                             userInfo:userInfo];
                }
                return responseObject;
            }
        }

        if (self.outputClass) {
            responseObject = [MTLJSONAdapter modelOfClass:self.outputClass
                                       fromJSONDictionary:responseObject
                                                    error:error];
        }
    }

    return responseObject;
}

@end

@interface AWSCognitoSyncRequestRetryHandler : AWSURLRequestRetryHandler

@end

@implementation AWSCognitoSyncRequestRetryHandler

- (AWSNetworkingRetryType)shouldRetry:(uint32_t)currentRetryCount
                             response:(NSHTTPURLResponse *)response
                                 data:(NSData *)data
                                error:(NSError *)error {
    AWSNetworkingRetryType retryType = [super shouldRetry:currentRetryCount
                                                 response:response
                                                     data:data
                                                    error:error];
    if(retryType == AWSNetworkingRetryTypeShouldNotRetry
       && [error.domain isEqualToString:AWSCognitoSyncErrorDomain]
       && currentRetryCount < self.maxRetryCount) {
        switch (error.code) {
            case AWSCognitoSyncErrorIncompleteSignature:
            case AWSCognitoSyncErrorInvalidClientTokenId:
            case AWSCognitoSyncErrorMissingAuthenticationToken:
                retryType = AWSNetworkingRetryTypeShouldRefreshCredentialsAndRetry;
                break;

            default:
                break;
        }
    }

    return retryType;
}

@end

@interface AWSRequest()

@property (nonatomic, strong) AWSNetworkingRequest *internalRequest;

@end

@interface AWSCognitoSync()

@property (nonatomic, strong) AWSNetworking *networking;
@property (nonatomic, strong) AWSServiceConfiguration *configuration;
@property (nonatomic, strong) AWSEndpoint *endpoint;

@end

@implementation AWSCognitoSync

+ (instancetype)defaultCognitoSync {
    if (![AWSServiceManager defaultServiceManager].defaultServiceConfiguration) {
        return nil;
    }

    static AWSCognitoSync *_defaultCognitoIdentityService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultCognitoIdentityService = [[AWSCognitoSync alloc] initWithConfiguration:[AWSServiceManager defaultServiceManager].defaultServiceConfiguration];
    });

    return _defaultCognitoIdentityService;
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = [configuration copy];

        _endpoint = [AWSEndpoint endpointWithRegion:_configuration.regionType
                                            service:AWSServiceCognitoService];

        AWSSignatureV4Signer *signer = [AWSSignatureV4Signer signerWithCredentialsProvider:_configuration.credentialsProvider
                                                                                  endpoint:_endpoint];

        _configuration.baseURL = _endpoint.URL;
        _configuration.requestSerializer = [AWSJSONRequestSerializer new];
        _configuration.requestInterceptors = @[[AWSNetworkingRequestInterceptor new], signer];
        _configuration.retryHandler = [[AWSCognitoSyncRequestRetryHandler alloc] initWithMaximumRetryCount:_configuration.maxRetryCount];
        _configuration.headers = @{@"Host" : _endpoint.hostName,
                                   @"Content-Type" : @"application/x-amz-json-1.1"};

        _networking = [AWSNetworking networking:_configuration];
    }

    return self;
}

- (BFTask *)invokeRequest:(AWSRequest *)request
               HTTPMethod:(AWSHTTPMethod)HTTPMethod
                URLString:(NSString *) URLString
             targetPrefix:(NSString *)targetPrefix
            operationName:(NSString *)operationName
              outputClass:(Class)outputClass {
    if (!request) {
        request = [AWSRequest new];
    }

    AWSNetworkingRequest *networkingRequest = request.internalRequest;
    if (request) {
        networkingRequest.parameters = [[MTLJSONAdapter JSONDictionaryFromModel:request] aws_removeNullValues];
    } else {
        networkingRequest.parameters = @{};
    }

    NSMutableDictionary *parameters = [NSMutableDictionary new];
    __block NSString *blockSafeURLString = [URLString copy];
    [networkingRequest.parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *stringToFind = [NSString stringWithFormat:@"{%@}", key];
        if ([blockSafeURLString rangeOfString:stringToFind].location == NSNotFound) {
            [parameters setObject:obj forKey:key];
        } else {
            blockSafeURLString = [blockSafeURLString stringByReplacingOccurrencesOfString:stringToFind
                                                                               withString:obj];
        }
    }];
    networkingRequest.parameters = parameters;

    NSMutableDictionary *headers = [NSMutableDictionary new];
    headers[@"X-Amz-Target"] = [NSString stringWithFormat:@"%@.%@", targetPrefix, operationName];

    networkingRequest.headers = headers;
    networkingRequest.URLString = blockSafeURLString;
    networkingRequest.HTTPMethod = HTTPMethod;
    networkingRequest.responseSerializer = [AWSCognitoSyncResponseSerializer serializerWithOutputClass:outputClass
                                                                                              resource:@""
                                                                                            actionName:operationName];
    
    networkingRequest.requestSerializer = [AWSJSONRequestSerializer serializerWithResource:AWSCognitoSyncDefinitionFileName
                                                                                actionName:operationName];

    return [self.networking sendRequest:networkingRequest];
}

#pragma mark - Service method

- (BFTask *)deleteDataset:(AWSCognitoSyncDeleteDatasetRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodDELETE
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"DeleteDataset"
                   outputClass:[AWSCognitoSyncDeleteDatasetResponse class]];
}

- (BFTask *)describeDataset:(AWSCognitoSyncDescribeDatasetRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"DescribeDataset"
                   outputClass:[AWSCognitoSyncDescribeDatasetResponse class]];
}

- (BFTask *)describeIdentityPoolUsage:(AWSCognitoSyncDescribeIdentityPoolUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"DescribeIdentityPoolUsage"
                   outputClass:[AWSCognitoSyncDescribeIdentityPoolUsageResponse class]];
}

- (BFTask *)describeIdentityUsage:(AWSCognitoSyncDescribeIdentityUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"DescribeIdentityUsage"
                   outputClass:[AWSCognitoSyncDescribeIdentityUsageResponse class]];
}

- (BFTask *)listDatasets:(AWSCognitoSyncListDatasetsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"ListDatasets"
                   outputClass:[AWSCognitoSyncListDatasetsResponse class]];
}

- (BFTask *)listIdentityPoolUsage:(AWSCognitoSyncListIdentityPoolUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"ListIdentityPoolUsage"
                   outputClass:[AWSCognitoSyncListIdentityPoolUsageResponse class]];
}

- (BFTask *)listRecords:(AWSCognitoSyncListRecordsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}/records"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"ListRecords"
                   outputClass:[AWSCognitoSyncListRecordsResponse class]];
}

- (BFTask *)updateRecords:(AWSCognitoSyncUpdateRecordsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"UpdateRecords"
                   outputClass:[AWSCognitoSyncUpdateRecordsResponse class]];
}

@end
