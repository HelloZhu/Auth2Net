//
//  ESDRequest.h
//  AuthNet
//
//  Created by ap2 on 16/11/30.
//  Copyright © 2016年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESDAPIResponse.h"
#import "ESDFileConfig.h"
#import "ZANetworking.h"

@protocol ESDAPINetManagerDelegate;

typedef NS_ENUM(NSInteger, ESDRequestMethod) {
    ESDRequestMethodGet = 0,
    ESDRequestMethodPost,
    ESDRequestMethodUploadFile,
    ESDRequestMethodDownloadFile
};

typedef NS_ENUM(NSInteger , AuthTokenType){
    
    AuthTokenType_None,
    AuthTokenType_Client,
    AuthTokenType_Password
};

@interface ESDRequest : NSObject<NSCopying>

//该Request的请求结果响应代理
@property (nonatomic , weak) id<ESDAPINetManagerDelegate> delegate;

//请求失败后，重新发起的次数
@property (nonatomic , assign) NSInteger retryCount;

/**以下方法子类可重写*/

- (NSString *)baseUrl;

//API地址
- (NSString *)requestUrl;

//超时时间
- (NSUInteger)timeout;

//请求参数序列类型
- (ZARequestType)requestSerializerType;

//请求结果序列化类型
- (ZAResponseType)responseSerializerType;

//请求方法
- (ESDRequestMethod)requestMethod;

//请求头参数
- (NSDictionary *)HttpHeaderArgument;

//请求参数
- (NSDictionary *)requestArgument;

//接口需要什么类型的token
- (AuthTokenType)needTokenType;

//任务组中已经有正在执行的相同的请求，是否取消正在执行请求
- (BOOL)shouldCancelExecutingSameRequest;

//任务组中已经有正在执行的相同的请求，是否发起新的请求
- (BOOL)shouldContinueIfHasExecutingSameRequest;

//需上传的文件的信息
- (ESDFileConfig *)uploadFileINFO;

//下载文件时，保存的文件路径:/var/.../test.jpg
- (NSString *)downloadFileTargetPath;

//发起请求时的指示器：“ 正在加载...”
- (NSString *)progressHUDText;

//是否显示加载指示器
- (BOOL)shouldShowProgress;

//请求名字描述
- (NSString *)requestDescription;

@end
