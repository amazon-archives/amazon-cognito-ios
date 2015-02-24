# AWSCognitoSync CHANGELOG

## 2.1.0

### Misc Updates
* Added `+ registerSERVICEWithConfiguration:forKey:`, `+ SERVICEForKey:`, and `+ removeSERVICEForKey:` to the service client. See the service client header for further details.
* Deprecated `- initWithConfiguration:` in the service client.
* Updated the framework name from `AWSCognitoSync.framework` to `AWSCognito.framework`.

### Resolved Issues
* Updated the copyright year from 2014 to 2015.
* Removed deprecated `synchronize` method from `UICKeyChainStore`.

## 1.0.8

### New Features
* Added an ability to override the default push platform in Amazon Cognito Sync to explicitly set it to APNS or APNS Sandbox.

### Resolved Issues
* Fixed a bug which caused resource conflicts in certain scenarios if you updated a record in the middle of a synchronization.
