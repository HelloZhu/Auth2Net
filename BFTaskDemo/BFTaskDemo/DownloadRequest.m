//
//  DownloadRequest.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/30.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "DownloadRequest.h"
#import "ESDAPINetManager.h"

@interface DownloadRequest ()

@end

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

+ (void)downloadWithRequest:(DownloadRequest *)request success:(void(^)(NSArray *results))success failure:(void(^)(ESDAPIResponse *apiResponse))failure
{
    NSArray *localPaths = nil;
    NSArray *shouldDownloadfileIDs = nil;
    
    if (!shouldDownloadfileIDs.count) {
        success(localPaths);
        return;
    }
    
    [[ESDAPINetManager sharedInstance] taskWithRequest:request progress:nil success:^(ESDAPIResponse *apiResponse) {
        
        NSString *path = apiResponse.respondObject;
//        [[path unzip] to dir];
        NSMutableArray *newpaths = nil;
        [newpaths addObjectsFromArray:localPaths];
        success(newpaths);
        
    } failure:failure];
}

@end
