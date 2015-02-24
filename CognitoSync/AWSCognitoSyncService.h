/**
 Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>
#import "AWSCognitoSyncModel.h"

@class BFTask;

/**
 <fullname>Amazon Cognito Sync</fullname><p>Amazon Cognito Sync provides an AWS service and client library that enable cross-device syncing of application-related user data. High-level client libraries are available for both iOS and Android. You can use these libraries to persist data locally so that it's available even if the device is offline. Developer credentials don't need to be stored on the mobile device to access the service. You can use Amazon Cognito to obtain a normalized user ID and credentials. User data is persisted in a dataset that can store up to 1 MB of key-value pairs, and you can have up to 20 datasets per user identity.</p><p>With Amazon Cognito Sync, the data stored for each identity is accessible only to credentials assigned to that identity. In order to use the Cognito Sync service, you need to make API calls using credentials retrieved with <a href="http://docs.aws.amazon.com/cognitoidentity/latest/APIReference/Welcome.html">Amazon Cognito Identity service</a>.</p>
 */
@interface AWSCognitoSync : AWSService

/**
 The service configuration used to instantiate this service client.
 
 @warning Once the client is instantiated, do not modify the configuration object. It may cause unspecified behaviors.
 */
@property (nonatomic, strong, readonly) AWSServiceConfiguration *configuration;

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[AWSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
         AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
          AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                          identityPoolId:@"YourIdentityPoolId"];
          AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                               credentialsProvider:credentialsProvider];
          [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

          return YES;
      }

 Then call the following to get the default service client:

 *Swift*

     let CognitoSync = AWSCognitoSync.defaultCognitoSync()

 *Objective-C*

     AWSCognitoSync *CognitoSync = [AWSCognitoSync defaultCognitoSync];

 @return The default service client.
 */
+ (instancetype)defaultCognitoSync;

/**
 Creates a service client with the given service configuration and registers it for the key.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         AWSCognitoSync.registerCognitoSyncWithConfiguration(configuration, forKey: "USWest2CognitoSync")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [AWSCognitoSync registerCognitoSyncWithConfiguration:configuration forKey:@"USWest2CognitoSync"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let CognitoSync = AWSCognitoSync(forKey: "USWest2CognitoSync")

 *Objective-C*

     AWSCognitoSync *CognitoSync = [AWSCognitoSync CognitoSyncForKey:@"USWest2CognitoSync"];

 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.

 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerCognitoSyncWithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerCognitoSyncWithConfiguration:forKey:` before invoking this method. If `+ registerCognitoSyncWithConfiguration:forKey:` has not been called in advance or the key does not exist, this method returns `nil`.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         AWSCognitoSync.registerCognitoSyncWithConfiguration(configuration, forKey: "USWest2CognitoSync")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [AWSCognitoSync registerCognitoSyncWithConfiguration:configuration forKey:@"USWest2CognitoSync"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let CognitoSync = AWSCognitoSync(forKey: "USWest2CognitoSync")

 *Objective-C*

     AWSCognitoSync *CognitoSync = [AWSCognitoSync CognitoSyncForKey:@"USWest2CognitoSync"];

 @param key A string to identify the service client.

 @return An instance of the service client.
 */
+ (instancetype)CognitoSyncForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.
 
 @warning Before calling this method, make sure no method is running on this client.
 
 @param key A string to identify the service client.
 */
+ (void)removeCognitoSyncForKey:(NSString *)key;

/**
 Instantiates the service client with the given service configuration.
 
 @warning This method has been deprecated. Use `+ registerCognitoSyncWithConfiguration:forKey:` and `+ CognitoSyncForKey:` instead.
 
 @warning Once the client is instantiated, do not modify the configuration object. It may cause unspecified behaviors.
 
 @warning Unlike the singleton method, you are responsible for maintaining a strong reference to this object. If the service client is released before completing a service request, the request may fail with unspecified errors.
 
 @param configuration The service configuration object.
 
 @return An instance of the service client.
 */
- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration __attribute__ ((deprecated("Use '+ registerCognitoSyncWithConfiguration:forKey:' and '+ CognitoSyncForKey:' instead.")));

/**
 Deletes the specific dataset. The dataset will be deleted permanently, and the action can't be undone. Datasets that this dataset was merged with will no longer report the merge. Any consequent operation on this dataset will result in a ResourceNotFoundException.
 
 @param request A container for the necessary parameters to execute the DeleteDataset service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncDeleteDatasetResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncDeleteDatasetRequest
 @see AWSCognitoSyncDeleteDatasetResponse
 */
- (BFTask *)deleteDataset:(AWSCognitoSyncDeleteDatasetRequest *)request;

/**
 Gets metadata about a dataset by identity and dataset name. The credentials used to make this API call need to have access to the identity data. With Amazon Cognito Sync, each identity has access only to its own data. You should use Amazon Cognito Identity service to retrieve the credentials necessary to make this API call.
 
 @param request A container for the necessary parameters to execute the DescribeDataset service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncDescribeDatasetResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncDescribeDatasetRequest
 @see AWSCognitoSyncDescribeDatasetResponse
 */
- (BFTask *)describeDataset:(AWSCognitoSyncDescribeDatasetRequest *)request;

/**
 Gets usage details (for example, data storage) about a particular identity pool.
 
 @param request A container for the necessary parameters to execute the DescribeIdentityPoolUsage service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncDescribeIdentityPoolUsageResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncDescribeIdentityPoolUsageRequest
 @see AWSCognitoSyncDescribeIdentityPoolUsageResponse
 */
- (BFTask *)describeIdentityPoolUsage:(AWSCognitoSyncDescribeIdentityPoolUsageRequest *)request;

/**
 Gets usage information for an identity, including number of datasets and data usage.
 
 @param request A container for the necessary parameters to execute the DescribeIdentityUsage service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncDescribeIdentityUsageResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncDescribeIdentityUsageRequest
 @see AWSCognitoSyncDescribeIdentityUsageResponse
 */
- (BFTask *)describeIdentityUsage:(AWSCognitoSyncDescribeIdentityUsageRequest *)request;

/**
 <p>Gets the configuration settings of an identity pool.</p>
 
 @param request A container for the necessary parameters to execute the GetIdentityPoolConfiguration service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncGetIdentityPoolConfigurationResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncGetIdentityPoolConfigurationRequest
 @see AWSCognitoSyncGetIdentityPoolConfigurationResponse
 */
- (BFTask *)getIdentityPoolConfiguration:(AWSCognitoSyncGetIdentityPoolConfigurationRequest *)request;

/**
 Lists datasets for an identity. The credentials used to make this API call need to have access to the identity data. With Amazon Cognito Sync, each identity has access only to its own data. You should use Amazon Cognito Identity service to retrieve the credentials necessary to make this API call.
 
 @param request A container for the necessary parameters to execute the ListDatasets service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncListDatasetsResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncListDatasetsRequest
 @see AWSCognitoSyncListDatasetsResponse
 */
- (BFTask *)listDatasets:(AWSCognitoSyncListDatasetsRequest *)request;

/**
 Gets a list of identity pools registered with Cognito.
 
 @param request A container for the necessary parameters to execute the ListIdentityPoolUsage service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncListIdentityPoolUsageResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncListIdentityPoolUsageRequest
 @see AWSCognitoSyncListIdentityPoolUsageResponse
 */
- (BFTask *)listIdentityPoolUsage:(AWSCognitoSyncListIdentityPoolUsageRequest *)request;

/**
 Gets paginated records, optionally changed after a particular sync count for a dataset and identity. The credentials used to make this API call need to have access to the identity data. With Amazon Cognito Sync, each identity has access only to its own data. You should use Amazon Cognito Identity service to retrieve the credentials necessary to make this API call.
 
 @param request A container for the necessary parameters to execute the ListRecords service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncListRecordsResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorTooManyRequests`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncListRecordsRequest
 @see AWSCognitoSyncListRecordsResponse
 */
- (BFTask *)listRecords:(AWSCognitoSyncListRecordsRequest *)request;

/**
 <p>Registers a device to receive push sync notifications.</p>
 
 @param request A container for the necessary parameters to execute the RegisterDevice service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncRegisterDeviceResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`, `AWSCognitoSyncErrorInvalidConfiguration`.
 
 @see AWSCognitoSyncRegisterDeviceRequest
 @see AWSCognitoSyncRegisterDeviceResponse
 */
- (BFTask *)registerDevice:(AWSCognitoSyncRegisterDeviceRequest *)request;

/**
 <p>Sets the necessary configuration for push sync.</p>
 
 @param request A container for the necessary parameters to execute the SetIdentityPoolConfiguration service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncSetIdentityPoolConfigurationResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncSetIdentityPoolConfigurationRequest
 @see AWSCognitoSyncSetIdentityPoolConfigurationResponse
 */
- (BFTask *)setIdentityPoolConfiguration:(AWSCognitoSyncSetIdentityPoolConfigurationRequest *)request;

/**
 <p>Subscribes to receive notifications when a dataset is modified by another device.</p>
 
 @param request A container for the necessary parameters to execute the SubscribeToDataset service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncSubscribeToDatasetResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`, `AWSCognitoSyncErrorInvalidConfiguration`.
 
 @see AWSCognitoSyncSubscribeToDatasetRequest
 @see AWSCognitoSyncSubscribeToDatasetResponse
 */
- (BFTask *)subscribeToDataset:(AWSCognitoSyncSubscribeToDatasetRequest *)request;

/**
 <p>Unsubscribe from receiving notifications when a dataset is modified by another device.</p>
 
 @param request A container for the necessary parameters to execute the UnsubscribeFromDataset service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncUnsubscribeFromDatasetResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorInternalError`, `AWSCognitoSyncErrorInvalidConfiguration`.
 
 @see AWSCognitoSyncUnsubscribeFromDatasetRequest
 @see AWSCognitoSyncUnsubscribeFromDatasetResponse
 */
- (BFTask *)unsubscribeFromDataset:(AWSCognitoSyncUnsubscribeFromDatasetRequest *)request;

/**
 Posts updates to records and add and delete records for a dataset and user. The credentials used to make this API call need to have access to the identity data. With Amazon Cognito Sync, each identity has access only to its own data. You should use Amazon Cognito Identity service to retrieve the credentials necessary to make this API call.
 
 @param request A container for the necessary parameters to execute the UpdateRecords service method.
 
 @return An instance of `BFTask`. On successful execution, `task.result` will contain an instance of `AWSCognitoSyncUpdateRecordsResponse`. On failed execution, `task.error` may contain an `NSError` with `AWSCognitoSyncErrorDomain` domian and the following error code: `AWSCognitoSyncErrorInvalidParameter`, `AWSCognitoSyncErrorLimitExceeded`, `AWSCognitoSyncErrorNotAuthorized`, `AWSCognitoSyncErrorResourceNotFound`, `AWSCognitoSyncErrorResourceConflict`, `AWSCognitoSyncErrorTooManyRequests`, `AWSCognitoSyncErrorInternalError`.
 
 @see AWSCognitoSyncUpdateRecordsRequest
 @see AWSCognitoSyncUpdateRecordsResponse
 */
- (BFTask *)updateRecords:(AWSCognitoSyncUpdateRecordsRequest *)request;

@end
