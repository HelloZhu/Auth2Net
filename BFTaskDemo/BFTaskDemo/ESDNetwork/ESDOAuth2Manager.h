//
//  ESDAuth2Manager.h
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "AFOAuth2Manager.h"

typedef void(^OAuth2Success)(AFOAuthCredential *credential);
typedef void(^OAuth2Fail)(NSURLSessionDataTask *task ,NSError *error);

@interface ESDOAuth2Manager : NSObject

+ (instancetype)sharedInstance;

+ (void)setBaseURL:(NSString *)baseURL;
+ (void)setURLString:(NSString *)urlString;

+ (void)fetchClientTokenWithSuccess:(OAuth2Success)success failure:(OAuth2Fail)failure;
+ (void)fetchPWDTokenWithUserName:(NSString *)username pwd:(NSString *)pwd success:(OAuth2Success)success failure:(OAuth2Fail)failure;
+ (void)refreshTokenWithLocalCredential:(AFOAuthCredential *)localCredential success:(OAuth2Success)success failure:(OAuth2Fail)failure;
@end
