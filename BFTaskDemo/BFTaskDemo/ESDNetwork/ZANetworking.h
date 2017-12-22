//
//  ZANetworking.h
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFNetworkReachabilityManager.h"

typedef NS_ENUM(NSUInteger, ZAResponseType) {
    kZAResponseTypeJSON = 1, // 默认
    kZAResponseTypeXML  = 2, // XML
    kZAResponseTypeData = 3
};

typedef NS_ENUM(NSUInteger, ZARequestType) {
    kZARequestTypeJSON = 1, // 默认
    kZARequestTypePlainText = 2 // 普通text/html
};

typedef void(^ZANetworkSuccess)(NSURLResponse *response, id  responseObject);
typedef void(^ZANetworkFailure)(NSURLResponse *response, NSError *error);
typedef void(^ZANetworkProgress)(NSProgress *progress);

@interface ZANetworking : NSObject

+ (void)setTimeout:(NSUInteger)timeout;
+ (void)configRequestType:(ZARequestType)requestType responseType:(ZAResponseType)responseType;
+ (void)configHttpHeaders:(NSDictionary *)httpHeaders;

+ (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters progress:(ZANetworkProgress)progress success:(ZANetworkSuccess)success failure:(ZANetworkFailure)failure;
+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters progress:(ZANetworkProgress)progress success:(ZANetworkSuccess)success failure:(ZANetworkFailure)failure;

+ (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)URLString
                                         parameters:(NSDictionary *)parameters
                                         targetPath:(NSString *)targetFilePath
                                           progress:(ZANetworkProgress)progress
                                            success:(ZANetworkSuccess)success
                                            failure:(ZANetworkFailure)failure;

+ (NSURLSessionUploadTask *)uploadFileWithhURLString:(NSString *)URLString
                                          parameters:(NSDictionary *)parameters
                                        fromFilePath:(NSString *)fromFilePath
                                            progress:(ZANetworkProgress)progress
                                             success:(ZANetworkSuccess)success
                                             failure:(ZANetworkFailure)failure;

+ (NSURLSessionTask *)uploadWithURLString:(NSString *)URLString
                               parameters:(NSDictionary *)parameters
                                 filePath:(NSString *)filePath
                                 filename:(NSString *)fileName
                                     name:(NSString *)name
                                 mimeType:(NSString *)mimeType
                                 progress:(ZANetworkProgress)progress
                                  success:(ZANetworkSuccess)success
                                     fail:(ZANetworkFailure)failure;

+ (NSURLSessionTask *)uploadWithURLString:(NSString *)URLString
                               parameters:(NSDictionary *)parameters
                                 fileData:(NSData *)fileData
                                 filename:(NSString *)fileName
                                     name:(NSString *)name
                                 mimeType:(NSString *)mimeType
                                 progress:(ZANetworkProgress)progress
                                  success:(ZANetworkSuccess)success
                                     fail:(ZANetworkFailure)failure;


+ (void)cancelTaskWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters;
+ (void)detectNet:(void(^)(AFNetworkReachabilityStatus status))statusChangeBlock;
+ (AFNetworkReachabilityStatus)networkReachabilityStatus;
+ (NSString *)taskID:(NSString *)url params:(NSDictionary *)params;
@end
