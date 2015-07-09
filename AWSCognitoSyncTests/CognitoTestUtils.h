/**
 Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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
