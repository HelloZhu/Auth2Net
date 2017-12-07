//
//  DownloadRequest.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/30.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "DownloadRequest.h"

@implementation DownloadRequest
- (NSString *)baseUrl
{
    return @"https://videodownloader.ummy.net";
}

- (NSString *)requestUrl
{
    return @"/assets/mac/ummy_1.59.dmg";
}

- (ESDRequestMethod)requestMethod
{
    return ESDRequestMethodDownloadFile;
}

- (AuthTokenType)needTokenType
{
    return AuthTokenType_None;
}

- (NSString *)downloadFileTargetPath
{
    return [NSHomeDirectory() stringByAppendingString:@"/Documents/test.dmg"];
}


@end
