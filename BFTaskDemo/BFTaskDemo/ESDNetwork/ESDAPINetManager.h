//
//  ESDAPINetManager.h
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDRequest.h"
#import "ESDAPIResponse.h"
#import "ZANetworking.h"

/** 用法
 TestRequest *request = [[TestRequest alloc] init];
 request.retryCount = 0; //失败重发请求次数
 request.delegate = self; //设置网络回调代理
 
 [[ESDAPINetManager sharedInstance] taskWithRequest:request progress:^(NSProgress *downloadProgress) {
 
 } success:^(ESDAPIResponse *apiResponse) {
 
 } failure:^(ESDAPIResponse *apiResponse) {
 
 }];
 */


typedef void(^APINetProgress)(NSProgress *downloadProgress);

@protocol ESDAPINetManagerDelegate <NSObject>

@optional
- (void)requestWillStart:(ESDRequest *)request;
- (void)requestSuccess:(ESDRequest *)request response:(ESDAPIResponse *)response;
- (void)requestFail:(ESDRequest *)request response:(ESDAPIResponse *)response;

@end

@interface ESDAPINetManager : NSObject

+ (instancetype)sharedInstance;

- (NSURLSessionTask *)taskWithRequest:(ESDRequest *)requset progress:(APINetProgress)progress success:(APIResponseSuccess)success failure:(APIResponseFail)failure;
+ (NSArray *)allTasks;
@end
