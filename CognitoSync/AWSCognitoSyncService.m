/**
 Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
#import "AWSSynchronizedMutableDictionary.h"

NSString *const AWSCognitoSyncDefinitionFileName = @"cognito-sync-2014-06-30";

@interface AWSCognitoSyncResponseSerializer : AWSJSONResponseSerializer

@end

@implementation AWSCognitoSyncResponseSerializer

#pragma mark - Service errors

static NSDictionary *errorCodeDictionary = nil;
+ (void)initialize {
    errorCodeDictionary = @{
                            @"IncompleteSignature" : @(AWSCognitoSyncErrorIncompleteSignature),
                            @"InvalidClientTokenId" : @(AWSCognitoSyncErrorInvalidClientTokenId),
                            @"MissingAuthenticationToken" : @(AWSCognitoSyncErrorMissingAuthenticationToken),
                            @"AlreadyStreamedException" : @(AWSCognitoSyncErrorAlreadyStreamed),
                            @"DuplicateRequestException" : @(AWSCognitoSyncErrorDuplicateRequest),
                            @"InternalErrorException" : @(AWSCognitoSyncErrorInternalError),
                            @"InvalidConfigurationException" : @(AWSCognitoSyncErrorInvalidConfiguration),
                            @"InvalidLambdaFunctionOutputException" : @(AWSCognitoSyncErrorInvalidLambdaFunctionOutput),
                            @"InvalidParameterException" : @(AWSCognitoSyncErrorInvalidParameter),
                            @"LambdaThrottledException" : @(AWSCognitoSyncErrorLambdaThrottled),
                            @"LimitExceededException" : @(AWSCognitoSyncErrorLimitExceeded),
                            @"NotAuthorizedErrorException" : @(AWSCognitoSyncErrorNotAuthorized),
                            @"ResourceConflictException" : @(AWSCognitoSyncErrorResourceConflict),
                            @"ResourceNotFoundException" : @(AWSCognitoSyncErrorResourceNotFound),
                            @"TooManyRequestsException" : @(AWSCognitoSyncErrorTooManyRequests),
                            };
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

static AWSSynchronizedMutableDictionary *_serviceClients = nil;

+ (instancetype)defaultCognitoSync {
    if (![AWSServiceManager defaultServiceManager].defaultServiceConfiguration) {
        return nil;
    }

    static AWSCognitoSync *_defaultCognitoSync = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _defaultCognitoSync = [[AWSCognitoSync alloc] initWithConfiguration:AWSServiceManager.defaultServiceManager.defaultServiceConfiguration];
#pragma clang diagnostic pop
    });

    return _defaultCognitoSync;
}

+ (void)registerCognitoSyncWithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _serviceClients = [AWSSynchronizedMutableDictionary new];
    });
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [_serviceClients setObject:[[AWSCognitoSync alloc] initWithConfiguration:configuration]
                        forKey:key];
#pragma clang diagnostic pop
}

+ (instancetype)CognitoSyncForKey:(NSString *)key {
    return [_serviceClients objectForKey:key];
}

+ (void)removeCognitoSyncForKey:(NSString *)key {
    [_serviceClients removeObjectForKey:key];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"`- init` is not a valid initializer. Use `+ defaultCognitoSync` or `+ CognitoSyncForKey:` instead."
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = [configuration copy];

        _endpoint = [[AWSEndpoint alloc] initWithRegion:_configuration.regionType
                                                service:AWSServiceCognitoService
                                           useUnsafeURL:NO];

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


    NSMutableDictionary *headers = [NSMutableDictionary new];

    networkingRequest.headers = headers;
    networkingRequest.HTTPMethod = HTTPMethod;
    networkingRequest.requestSerializer = [[AWSJSONRequestSerializer alloc] initWithResource:AWSCognitoSyncDefinitionFileName
                                                                                  actionName:operationName
                                                                              classForBundle:[self class]];
    networkingRequest.responseSerializer = [[AWSCognitoSyncResponseSerializer alloc] initWithResource:AWSCognitoSyncDefinitionFileName
                                                                                           actionName:operationName
                                                                                          outputClass:outputClass
                                                                                       classForBundle:[self class]];
    return [self.networking sendRequest:networkingRequest];
}

#pragma mark - Service method

- (BFTask *)bulkPublish:(AWSCognitoSyncBulkPublishRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/bulkpublish"
                  targetPrefix:@""
                 operationName:@"BulkPublish"
                   outputClass:[AWSCognitoSyncBulkPublishResponse class]];
}

- (BFTask *)deleteDataset:(AWSCognitoSyncDeleteDatasetRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodDELETE
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@""
                 operationName:@"DeleteDataset"
                   outputClass:[AWSCognitoSyncDeleteDatasetResponse class]];
}

- (BFTask *)describeDataset:(AWSCognitoSyncDescribeDatasetRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@""
                 operationName:@"DescribeDataset"
                   outputClass:[AWSCognitoSyncDescribeDatasetResponse class]];
}

- (BFTask *)describeIdentityPoolUsage:(AWSCognitoSyncDescribeIdentityPoolUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}"
                  targetPrefix:@""
                 operationName:@"DescribeIdentityPoolUsage"
                   outputClass:[AWSCognitoSyncDescribeIdentityPoolUsageResponse class]];
}

- (BFTask *)describeIdentityUsage:(AWSCognitoSyncDescribeIdentityUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}"
                  targetPrefix:@""
                 operationName:@"DescribeIdentityUsage"
                   outputClass:[AWSCognitoSyncDescribeIdentityUsageResponse class]];
}

- (BFTask *)getBulkPublishDetails:(AWSCognitoSyncGetBulkPublishDetailsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/getBulkPublishDetails"
                  targetPrefix:@""
                 operationName:@"GetBulkPublishDetails"
                   outputClass:[AWSCognitoSyncGetBulkPublishDetailsResponse class]];
}

- (BFTask *)getCognitoEvents:(AWSCognitoSyncGetCognitoEventsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/events"
                  targetPrefix:@""
                 operationName:@"GetCognitoEvents"
                   outputClass:[AWSCognitoSyncGetCognitoEventsResponse class]];
}

- (BFTask *)getIdentityPoolConfiguration:(AWSCognitoSyncGetIdentityPoolConfigurationRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/configuration"
                  targetPrefix:@""
                 operationName:@"GetIdentityPoolConfiguration"
                   outputClass:[AWSCognitoSyncGetIdentityPoolConfigurationResponse class]];
}

- (BFTask *)listDatasets:(AWSCognitoSyncListDatasetsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets"
                  targetPrefix:@""
                 operationName:@"ListDatasets"
                   outputClass:[AWSCognitoSyncListDatasetsResponse class]];
}

- (BFTask *)listIdentityPoolUsage:(AWSCognitoSyncListIdentityPoolUsageRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools"
                  targetPrefix:@""
                 operationName:@"ListIdentityPoolUsage"
                   outputClass:[AWSCognitoSyncListIdentityPoolUsageResponse class]];
}

- (BFTask *)listRecords:(AWSCognitoSyncListRecordsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodGET
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}/records"
                  targetPrefix:@""
                 operationName:@"ListRecords"
                   outputClass:[AWSCognitoSyncListRecordsResponse class]];
}

- (BFTask *)registerDevice:(AWSCognitoSyncRegisterDeviceRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/identity/{IdentityId}/device"
                  targetPrefix:@""
                 operationName:@"RegisterDevice"
                   outputClass:[AWSCognitoSyncRegisterDeviceResponse class]];
}

- (BFTask *)setCognitoEvents:(AWSCognitoSyncSetCognitoEventsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/events"
                  targetPrefix:@""
                 operationName:@"SetCognitoEvents"
                   outputClass:nil];
}

- (BFTask *)setIdentityPoolConfiguration:(AWSCognitoSyncSetIdentityPoolConfigurationRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/configuration"
                  targetPrefix:@""
                 operationName:@"SetIdentityPoolConfiguration"
                   outputClass:[AWSCognitoSyncSetIdentityPoolConfigurationResponse class]];
}

- (BFTask *)subscribeToDataset:(AWSCognitoSyncSubscribeToDatasetRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}/subscriptions/{DeviceId}"
                  targetPrefix:@""
                 operationName:@"SubscribeToDataset"
                   outputClass:[AWSCognitoSyncSubscribeToDatasetResponse class]];
}

- (BFTask *)unsubscribeFromDataset:(AWSCognitoSyncUnsubscribeFromDatasetRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodDELETE
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}/subscriptions/{DeviceId}"
                  targetPrefix:@""
                 operationName:@"UnsubscribeFromDataset"
                   outputClass:[AWSCognitoSyncUnsubscribeFromDatasetResponse class]];
}

- (BFTask *)updateRecords:(AWSCognitoSyncUpdateRecordsRequest *)request {
    return [self invokeRequest:request
                    HTTPMethod:AWSHTTPMethodPOST
                     URLString:@"/identitypools/{IdentityPoolId}/identities/{IdentityId}/datasets/{DatasetName}"
                  targetPrefix:@""
                 operationName:@"UpdateRecords"
                   outputClass:[AWSCognitoSyncUpdateRecordsResponse class]];
}

@end