//
//  ESDAuth2Manager.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "ESDOAuth2Manager.h"

static NSString *const kClientID = @"";
static NSString *const kSecret   = @"";

const NSUInteger kFetchClientTokenRetryCount = 0;
const NSUInteger kFetchPWDTokenRetryCount = 0;
const NSUInteger kRefreshTokenRetryCount = 0;

@interface ESDOAuth2Manager ()
@property (nonatomic, strong) AFOAuth2Manager *manager;
@property (nonatomic, copy) NSString *baseURLString;
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) NSInteger fetchClientTokenRetryCount;
@property (nonatomic, assign) NSInteger fetchPWDTokenRetryCount;
@property (nonatomic, assign) NSInteger refreshTokenRetryCount;

@end


@implementation ESDOAuth2Manager

- (instancetype)init
{
    if (self = [super init]) {
        _fetchPWDTokenRetryCount = kFetchPWDTokenRetryCount;
        _fetchClientTokenRetryCount = kFetchClientTokenRetryCount;
        _refreshTokenRetryCount = kRefreshTokenRetryCount;
    }
    return self;
}


+ (instancetype)sharedInstance
{
    static ESDOAuth2Manager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ESDOAuth2Manager alloc] init];
    });
    return manager;
}

+ (void)setBaseURL:(NSString *)baseURL
{
    [ESDOAuth2Manager sharedInstance].baseURLString = baseURL;
}

+ (void)setURLString:(NSString *)urlString
{
    [ESDOAuth2Manager sharedInstance].URLString = urlString;
}

- (AFOAuth2Manager *)manager
{
    if (!_manager) {
        _manager = [AFOAuth2Manager managerWithBaseURL:[NSURL URLWithString:self.baseURLString] clientID:kClientID secret:kSecret];
        _manager.useHTTPBasicAuthentication = NO;
    }
    return _manager;
}

+ (void)fetchClientTokenWithSuccess:(OAuth2Success)success failure:(OAuth2Fail)failure
{
    NSString *URLString = [ESDOAuth2Manager sharedInstance].URLString;
    [[ESDOAuth2Manager sharedInstance].manager authenticateUsingOAuthWithURLString:URLString scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
        [AFOAuthCredential storeCredential:credential withIdentifier:kAFOAuth2TokenType_Client];
        [ESDOAuth2Manager sharedInstance].fetchClientTokenRetryCount = kFetchClientTokenRetryCount;
        if (success) {success(credential);}
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [ESDOAuth2Manager sharedInstance].fetchClientTokenRetryCount--;
        if ([ESDOAuth2Manager sharedInstance].fetchClientTokenRetryCount >= 0) {
            [ESDOAuth2Manager fetchClientTokenWithSuccess:success failure:failure];
            return;
        }
        NSError *cusError = [ESDOAuth2Manager failError:task error:error fetchType:@"fetchClientToken"];
        if (failure) {
            failure(task, cusError);
        }
    }];
}

+ (void)fetchPWDTokenWithUserName:(NSString *)username pwd:(NSString *)pwd success:(OAuth2Success)success failure:(OAuth2Fail)failure
{
    NSString *URLString = [ESDOAuth2Manager sharedInstance].URLString;
    [[ESDOAuth2Manager sharedInstance].manager authenticateUsingOAuthWithURLString:URLString username:username password:pwd scope:nil success:^(AFOAuthCredential * _Nonnull credential) {
        [AFOAuthCredential storeCredential:credential withIdentifier:kAFOAuth2TokenType_PWD];
        [ESDOAuth2Manager sharedInstance].fetchPWDTokenRetryCount = kFetchPWDTokenRetryCount;
        if (success) {success(credential);}
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [ESDOAuth2Manager sharedInstance].fetchPWDTokenRetryCount--;
        if ([ESDOAuth2Manager sharedInstance].fetchPWDTokenRetryCount >= 0) {
            [ESDOAuth2Manager fetchPWDTokenWithUserName:username pwd:pwd success:success failure:failure];
            return;
        }
        NSError *cusError = [ESDOAuth2Manager failError:task error:error fetchType:@"fetchPWDToken"];
        if (failure) {
            failure(task, cusError);
        }
    }];
}

+ (void)refreshTokenWithLocalCredential:(AFOAuthCredential *)localCredential success:(OAuth2Success)success failure:(OAuth2Fail)failure
{
    NSString *URLString = [ESDOAuth2Manager sharedInstance].URLString;
    [[ESDOAuth2Manager sharedInstance].manager authenticateUsingOAuthWithURLString:URLString refreshToken:localCredential.refreshToken success:^(AFOAuthCredential * _Nonnull credential) {
        [AFOAuthCredential storeCredential:credential withIdentifier:credential.tokenType];
        [ESDOAuth2Manager sharedInstance].refreshTokenRetryCount = kRefreshTokenRetryCount;
        if (success) {success(credential);}
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [ESDOAuth2Manager sharedInstance].refreshTokenRetryCount--;
        if ([ESDOAuth2Manager sharedInstance].refreshTokenRetryCount >= 0) {
            [ESDOAuth2Manager refreshTokenWithLocalCredential:localCredential success:success failure:failure];
            return;
        }
        [AFOAuthCredential deleteCredentialWithIdentifier:localCredential.tokenType];
        NSError *cusError = [ESDOAuth2Manager failError:task error:error fetchType:@"refreshToken"];
        if (failure) {
            failure(task, cusError);
        }
    }];
}

+ (NSError *)failError:(NSURLSessionDataTask *)task error:(NSError *)error fetchType:(NSString *)fetchType
{
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)task.response;
    NSString *msg = @"";
    if (fetchType) {
        msg = fetchType;
    }
    
    NSDictionary *errorInfo = @{NSLocalizedFailureReasonErrorKey:msg};
    NSError *ownError = [NSError errorWithDomain:NSCocoaErrorDomain code:httpResp.statusCode userInfo:errorInfo];
    return ownError;
}





@end
