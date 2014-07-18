/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import "AWSService.h"
#import "AWSCognitoHandlers.h"

@class AWSCognitoDataset;
@class AWSCognitoCredentialsProvider;
@class BFTask;

@interface AWSCognito : AWSService

/**
 * Posted when the synchronization is started.
 * The notification sender is an instance of AWSCognitoClient. The userInfo 
 * contains the dataset name.
 * @discussion This notification is posted once per synchronization.
 * The notification is posted on the Grand Central Dispatch
 * DISPATCH_QUEUE_PRIORITY_DEFAULT queue. The user interface should not be
 * modified on the thread.
 */
extern NSString *const AWSCognitoDidStartSynchronizeNotification;
/**
 * Posted when the synchronization is finished with or without errors.
 * The notification sender is an instance of AWSCognitoClient. The userInfo 
 * contains the dataset name.
 * @discussion This notification is posted once per synchronization.
 * The notification is posted on the Grand Central Dispatch
 * DISPATCH_QUEUE_PRIORITY_DEFAULT queue. The user interface should not be
 * modified on the thread.
 */
extern NSString *const AWSCognitoDidEndSynchronizeNotification;
/**
 * Posted when values are changed to the value from the remote data store. The notification 
 * sender is an instance of AWSCognitoClient. The userInfo contains the dataset name and 
 * an NSArray of changed keys.
 * @discussion This notification may be posted multiple times per synchronization.
 * The notification is posted on the Grand Central Dispatch
 * DISPATCH_QUEUE_PRIORITY_DEFAULT queue. The user interface should not be
 * modified on the thread.
 */
extern NSString *const AWSCognitoDidChangeLocalValueFromRemoteNotification;
/**
 * Posted when locally changed values are pushed to the remote store. The notification
 * sender is an instance of AWSCognitoClient. The userInfo contains the dataset name and
 * an NSArray of changed keys.
 * @discussion This notification may be posted multiple times per synchronization.
 * The notification is posted on the Grand Central Dispatch
 * DISPATCH_QUEUE_PRIORITY_DEFAULT queue. The user interface should not be
 * modified on the thread.
 */
extern NSString *const AWSCognitoDidChangeRemoteValueNotification;
/**
 * Posted when the synchronization for the for the dataset failed. The notification
 * sender is an instance of AWSCognitoClient. The userInfo contains the dataset name
 * and error.
 * @discussion This notification may be posted multiple times per synchronization.
 * The notification is posted on the Grand Central Dispatch
 * DISPATCH_QUEUE_PRIORITY_DEFAULT queue. The user interface should not be
 * modified on the thread.
 */
extern NSString *const AWSCognitoDidFailToSynchronizeNotification;

/**
 * The error domain for AWSCognito errors.
 * <ul>
 * <li>AWSCognitoErrorUnknown - Unknow error.</li>
 * <li>AWSCognitoErrorRemoteDataStorageFailed - The Amazon Cognito call temporarily failed.</li>
 * <li>AWSCognitoErrorInvalidDataValue - The Amazon Cognito call failed. The value for the
 * key is invalid and has been deleted from the local database.</li>
 * <li>AWSCognitoErrorDataSizeLimitExceeded - The Amazon Cognito call failed. A
 * dataset has exceeded the max dataset size.</li>
 * <li>AWSCognitoErrorLocalDataStorageFailed - The SQLite call failed.</li>
 * <li>AWSCognitoErrorIllegalArgument - The input value is invalid.</li>
 * <li>AWSCognitoErrorConflictRetriesExhausted - The number of attempts to resolve a conflict 
 * has exceeded the max number of retries.</li>
 * <li>AWSCognitoErrorWiFiNotAvailable - WiFi is required and not currently available.</li>
 * </ul>
 */
FOUNDATION_EXPORT NSString *const AWSCognitoErrorDomain;
typedef NS_ENUM(NSInteger, AWSCognitoErrorType) {
    AWSCognitoErrorUnknown = 0,
    AWSCognitoErrorRemoteDataStorageFailed = -1000,
    AWSCognitoErrorInvalidDataValue = -1001,
    AWSCognitoErrorUserDataSizeLimitExceeded = -1002,
    AWSCognitoErrorLocalDataStorageFailed = -2000,
    AWSCognitoErrorIllegalArgument = -3000,
    AWSCognitoAuthenticationFailed = -4000,
    AWSCognitoErrorTaskCanceled = -5000,
    AWSCognitoErrorConflictRetriesExhausted = -6000,
    AWSCognitoErrorWiFiNotAvailable = -7000
};

@property (nonatomic, strong, readonly) AWSServiceConfiguration *configuration;

/**
 * A conflict resolution handler that will receive calls when there is a
 * conflict during a sync operation.  A conflict will occur when both remote and
 * local data have been updated since the last sync time.
 * When not explicitly set, we will use the default conflict resolution of
 * 'last writer wins', where the data most recently updated will be persisted.
 * This handler will be propagated to any AWSCognitoDataset opened by this client.
 */
@property (nonatomic, strong) AWSCognitoRecordConflictHandler conflictHandler;

/**
 * A deleted dataset handler. This handler will be called during a synchronization
 * when the remote service indicates that a dataset has been deleted.
 * Returning YES from the handler will cause the service to recreate the dataset
 * on the remote on the next synchronization. Returning NO or leaving this property
 * nil will cause the client to delete the dataset locally.
 * This handler will be propagated to any AWSCognitoDataset opened by this client.
 */
@property (nonatomic, strong) AWSCognitoDatasetDeletedHandler datasetDeletedHandler;

/**
 * A merged dataset handler. This handler will be called during a synchronization
 * when the remote service indicates that other datasets should be merged with this one.
 * Merged datasets should be fetched, their data overlayed locally and then removed.
 * Failing to implement this handler will result in merged datasets remaining on the 
 * service indefinitely.
 * This handler will be propagated to any AWSCognitoDataset opened by this client.
 */
@property (nonatomic, strong) AWSCognitoDatasetMergedHandler datasetMergedHandler;

/**
 * The identifier used for this client in Amazon Cognito.  If not supplied
 * Amazon Cognito will create a random GUID for the device.
 */
@property (nonatomic, strong) NSString *deviceId;

/**
 * The number of times to attempt a synchronization before failing. This will
 * be set on any AWSCognitoDatasets opened with this client. Defaults to 5 if not set.
 */
@property (nonatomic, assign) uint32_t synchronizeRetries;

/**
 * Only synchronize if device is on a WiFi network. Defaults to NO if not set.
 */
@property (nonatomic, assign) BOOL synchronizeOnWiFiOnly;

/**
 * Initialize the instance with the supplied service config.
 * Will return nil if the credentials provider is not an instance of
 * AWSCognitoCredentials provider.
 */
- (instancetype)initWithConfiguration:(AWSServiceConfiguration *)configuration;

/**
 * Return a singleton instance of the AWSCognito client with the default service config.
 * Will return nil if the credentials provider is not an instance of
 * AWSCognitoCredentials provider.
 */
+ (AWSCognito *)defaultCognito;

/**
 *  Opens an existing dataset or creates a new one.
 */
- (AWSCognitoDataset *)openOrCreateDataset:(NSString *)datasetName;

/**
 * List all datasets our client is aware of. Call refreshDatasetMetadata to ensure
 * the client has knowledge of all datasets available on the remote store.
 */
- (NSArray *)listDatasets;

/**
 *  List all of the datasets.  Returns a BFTask. The result of this task will be an array of AWSCognitoDatasetMetadata objects.
 */
- (BFTask *)refreshDatasetMetadata;

/**
 * Wipe all cached data.
 */
- (void)wipe;

/**
 * Get the default, last writer wins conflict handler
 */
+ (AWSCognitoRecordConflictHandler) defaultConflictHandler;

@end
