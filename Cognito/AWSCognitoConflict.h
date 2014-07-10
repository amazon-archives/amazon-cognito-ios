/**
 * Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 */

#import <Foundation/Foundation.h>

@class AWSCognitoRecord;

@interface AWSCognitoResolvedConflict : NSObject
@end

@interface AWSCognitoRecordTuple : NSObject
@property (nonatomic, readonly) AWSCognitoRecord *localRecord;
@property (nonatomic, readonly) AWSCognitoRecord *remoteRecord;
@end

@interface AWSCognitoConflict : AWSCognitoRecordTuple

-(AWSCognitoResolvedConflict *) resolveWithLocalRecord;
-(AWSCognitoResolvedConflict *) resolveWithRemoteRecord;
-(AWSCognitoResolvedConflict *) resolveWithValue:(NSString *)value;
@end

