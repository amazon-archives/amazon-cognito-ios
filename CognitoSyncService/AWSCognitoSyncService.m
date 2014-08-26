/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import "AWSCognitoSyncService.h"
#import "AWSNetworking.h"
#import "AWSCategory.h"
#import "AWSNetworking.h"
#import "AWSSignature.h"
#import "AWSService.h"
#import "AWSNetworking.h"
#import "AWSURLRequestSerialization.h"
#import "AWSURLResponseSerialization.h"
#import "AWSURLRequestRetryHandler.h"

@interface AWSCognitoSyncServiceResponseSerializer : AWSJSONResponseSerializer

@property (nonatomic, assign) Class outputClass;

+ (instancetype)serializerWithOutputClass:(Class)outputClass;

@end

@implementation AWSCognitoSyncServiceResponseSerializer

#pragma mark - Service errors

static NSDictionary *errorCodeDictionary = nil;
+ (void)initialize {
    errorCodeDictionary = @{
                            @"IncompleteSignature" : @(AWSCognitoSyncServiceErrorIncompleteSignature),
                            @"InvalidClientTokenId" : @(AWSCognitoSyncServiceErrorInvalidClientTokenId),
                            @"MissingAuthenticationToken" : @(AWSCognitoSyncServiceErrorMissingAuthenticationToken),
                            @"InternalErrorException" : @(AWSCognitoSyncServiceErrorInternalError),
                            @"InvalidParameterException" : @(AWSCognitoSyncServiceErrorInvalidParameter),
                            @"LimitExceededException" : @(AWSCognitoSyncServiceErrorLimitExceeded),
                            @"NotAuthorizedException" : @(AWSCognitoSyncServiceErrorNotAuthorized),
                            @"ResourceConflictException" : @(AWSCognitoSyncServiceErrorResourceConflict),
                            @"ResourceNotFoundException" : @(AWSCognitoSyncServiceErrorResourceNotFound),
                            @"TooManyRequestsException" : @(AWSCognitoSyncServiceErrorTooManyRequests),
                            };
}

+ (instancetype)serializerWithOutputClass:(Class)outputClass {
    AWSCognitoSyncServiceResponseSerializer *serializer = [AWSCognitoSyncServiceResponseSerializer new];
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
                    *error = [NSError errorWithDomain:AWSCognitoSyncServiceErrorDomain
                                                 code:[[errorCodeDictionary objectForKey:errorTypeHeader] integerValue]
                                             userInfo:userInfo];
                }
                return responseObject;
            } else if (errorTypeHeader) {
                if (error) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : [responseObject objectForKey:@"message"]?[responseObject objectForKey:@"message"]:[NSNull null], NSLocalizedFailureReasonErrorKey: errorTypeStr};
                    *error = [NSError errorWithDomain:AWSCognitoSyncServiceErrorDomain
                                                 code:AWSCognitoSyncServiceErrorUnknown
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

@interface AWSCognitoSyncServiceRequestRetryHandler : AWSURLRequestRetryHandler

@end

@implementation AWSCognitoSyncServiceRequestRetryHandler

- (AWSNetworkingRetryType)shouldRetry:(uint32_t)currentRetryCount
                             response:(NSHTTPURLResponse *)response
                                 data:(NSData *)data
                                error:(NSError *)error {
    AWSNetworkingRetryType retryType = [super shouldRetry:currentRetryCount
                                                 response:response
                                                     data:data
                                                    error:error];
    if(retryType == AWSNetworkingRetryTypeShouldNotRetry
       && [error.domain isEqualToString:AWSCognitoSyncServiceErrorDomain]
       && currentRetryCount < self.maxRetryCount) {
        switch (error.code) {
            case AWSCognitoSyncServiceErrorIncompleteSignature:
            case AWSCognitoSyncServiceErrorInvalidClientTokenId:
            case AWSCognitoSyncServiceErrorMissingAuthenticationToken:
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

@interface AWSCognitoSyncService()

@property (nonatomic, strong) AWSNetworking *networking;
@property (nonatomic, strong) AWSServiceConfiguration *configuration;
@property (nonatomic, strong) AWSEndpoint *endpoint;

@end

@implementation AWSCognitoSyncService

+ (instancetype)defaultCognitoSyncService {
    if (![AWSServiceManager defaultServiceManager].defaultServiceConfiguration) {
        return nil;
    }

    static AWSCognitoSyncService *_defaultCognitoIdentityService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultCognitoIdentityService = [[AWSCognitoSyncService alloc] initWithConfiguration:[AWSServiceManager defaultServiceManager].defaultServiceConfiguration];
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
        _configuration.retryHandler = [[AWSCognitoSyncServiceRequestRetryHandler alloc] initWithMaximumRetryCount:_configuration.maxRetryCount];
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
    networkingRequest.responseSerializer = [AWSCognitoSyncServiceResponseSerializer serializerWithOutputClass:outputClass];

    return [self.networking sendRequest:networkingRequest];
}

#pragma mark - Service method

- (BFTask *)deleteDataset:(AWSCognitoSyncServiceDeleteDatasetRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodDELETE
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"DeleteDataset"
                   outputClass:[AWSCognitoSyncServiceDeleteDatasetResponse class]];
}

- (BFTask *)describeDataset:(AWSCognitoSyncServiceDescribeDatasetRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"DescribeDataset"
                   outputClass:[AWSCognitoSyncServiceDescribeDatasetResponse class]];
}

- (BFTask *)describeIdentityPoolUsage:(AWSCognitoSyncServiceDescribeIdentityPoolUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"DescribeIdentityPoolUsage"
                   outputClass:[AWSCognitoSyncServiceDescribeIdentityPoolUsageResponse class]];
}

- (BFTask *)describeIdentityUsage:(AWSCognitoSyncServiceDescribeIdentityUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"DescribeIdentityUsage"
                   outputClass:[AWSCognitoSyncServiceDescribeIdentityUsageResponse class]];
}

- (BFTask *)listDatasets:(AWSCognitoSyncServiceListDatasetsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"ListDatasets"
                   outputClass:[AWSCognitoSyncServiceListDatasetsResponse class]];
}

- (BFTask *)listIdentityPoolUsage:(AWSCognitoSyncServiceListIdentityPoolUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"ListIdentityPoolUsage"
                   outputClass:[AWSCognitoSyncServiceListIdentityPoolUsageResponse class]];
}

- (BFTask *)listRecords:(AWSCognitoSyncServiceListRecordsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}/records"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"ListRecords"
                   outputClass:[AWSCognitoSyncServiceListRecordsResponse class]];
}

- (BFTask *)updateRecords:(AWSCognitoSyncServiceUpdateRecordsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@"AWSCognitoSyncService"
                 operationName:@"UpdateRecords"
                   outputClass:[AWSCognitoSyncServiceUpdateRecordsResponse class]];
}

@end
