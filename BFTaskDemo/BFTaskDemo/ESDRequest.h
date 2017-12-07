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

@interface ESDRequest : NSObject

@property (nonatomic , weak) id<ESDAPINetManagerDelegate> delegate;
@property (nonatomic , assign) NSInteger retryCount;

/**以下方法子类可重写*/
- (NSString *)baseUrl;
- (NSString *)requestUrl;
- (NSUInteger)timeout;
- (ZARequestType)requestSerializerType;
- (ZAResponseType)responseSerializerType;
- (ESDRequestMethod)requestMethod;
- (NSDictionary *)HttpHeaderArgument;
- (NSDictionary *)requestArgument;
- (AuthTokenType)needTokenType;
- (BOOL)shouldCancelExecutingSameRequest;
//需上传的文件的信息
- (ESDFileConfig *)uploadFileINFO;
- (NSArray *)uploadfilePaths;
- (NSString *)downloadFileTargetPath;

- (NSString *)progressHUDText;
- (BOOL)shouldShowProgress;

//请求名字描述
- (NSString *)requestDescription;
@end
