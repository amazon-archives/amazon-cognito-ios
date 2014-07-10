/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>

@interface CognitoTestUtils : NSObject

+ (void)createFBAccount;
+ (void)createIdentityPool;
+ (void)deleteFBAccount;
+ (void)deleteIdentityPool;
+ (NSString *) accountId;
+ (NSString *) unauthRoleArn;
+ (NSString *) authRoleArn;
+ (NSString *) identityPoolId;
+ (NSString *) facebookToken;

@end
