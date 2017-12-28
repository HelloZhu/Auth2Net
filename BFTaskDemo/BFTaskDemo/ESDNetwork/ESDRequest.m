//
//  ESDRequest.m
//  AuthNet
//
//  Created by ap2 on 16/11/30.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import "ESDRequest.h"

@interface ESDRequest ()

@end

@implementation ESDRequest

- (instancetype)init
{
    if (self = [super init]) {
        _retryCount = 0;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    ESDRequest *request = [[ESDRequest allocWithZone:zone] init];
    request.delegate = self.delegate;
    request.retryCount = self.retryCount;
    return request;
}

- (void)dealloc
{
    _delegate = nil;
}




- (NSString *)baseUrl
{
    return @"";
}

- (NSString *)requestUrl
{
    return @"";
}

- (NSDictionary *)requestArgument
{
    return @{};
}

//认证参数
- (NSDictionary *)requestAuthArgument
{
    return @{};
}

- (NSDictionary *)HttpHeaderArgument
{
    
    return @{};
}

- (NSUInteger)timeout
{
    return 60;
}

- (ESDRequestMethod)requestMethod
{
    return ESDRequestMethodPost;
}

- (AuthTokenType)needTokenType
{
    return AuthTokenType_Client;
}


/**下载文件配置*/
/**下载文件所需要存储的路径*/
- (NSString *)downloadFileTargetPath
{
    return @"";
}

//需上传的文件的信息
- (ESDFileConfig *)uploadFileINFO
{
    return nil;
}

- (ZARequestType)requestSerializerType
{
    return kZARequestTypeJSON;
}

- (ZAResponseType)responseSerializerType
{
    return kZAResponseTypeJSON;
}

- (BOOL)shouldCancelExecutingSameRequest
{
    return YES;
}

- (BOOL)shouldContinueIfHasExecutingSameRequest
{
    return NO;
}
- (NSString *)progressHUDText
{
    return @"";
}
- (BOOL)shouldShowProgress
{
    return YES;
}
- (NSString *)requestDescription
{
    return @"";
}

@end
