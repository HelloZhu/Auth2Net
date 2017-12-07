//
//  LoginRequest.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/30.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "LoginRequest.h"

@implementation LoginRequest
- (NSString *)baseUrl
{
    return @"";
}

- (NSString *)requestUrl
{
    return @"/api/account/login";
}

- (ESDRequestMethod)requestMethod
{
    return ESDRequestMethodPost;
}

- (NSDictionary *)requestArgument
{
    return @{};
}

- (AuthTokenType)needTokenType
{
    return AuthTokenType_Password;
}

- (NSDictionary *)HttpHeaderArgument
{
    return @{};
}

#pragma mark - <ESDLoginAPIProtocol>
- (NSString *)account
{
    return @"";
}
- (NSString *)password
{
    return @"";
}


@end
