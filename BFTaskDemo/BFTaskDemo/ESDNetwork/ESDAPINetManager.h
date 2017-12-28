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


/** 结构
 
 ESDAPINetManager 发起API请求 -- 使用ZANetworking封装
 ESDRequest 请求配置信息
 ESDAPIResponse 返回结果
 
 BFTask 用于处理 多个请求同时发起时，此时accessToken过期了，刷新accessToken过程中，使这些请求任务处于等待状态，accessToken获取成功后继续执行这些等待的任务
 ESDOAuth2Manager 请求token，使用AFOAuth2Manager进行封装
 
 */

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
