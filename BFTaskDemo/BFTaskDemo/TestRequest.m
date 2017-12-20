//
//  TestRequest.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/29.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "TestRequest.h"

@implementation TestRequest

- (NSString *)baseUrl
{
    return @"https://api.anhewang.com";
}

- (NSString *)requestUrl
{
    return @"/OAuth/Token";
}

- (ESDRequestMethod)requestMethod
{
    return ESDRequestMethodPost;
}

- (AuthTokenType)needTokenType
{
    return AuthTokenType_None;
}



@end
