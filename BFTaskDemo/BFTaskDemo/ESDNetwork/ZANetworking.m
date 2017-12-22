//
//  ZANetworking.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "ZANetworking.h"
#import "ZAHttpSessionManager.h"

@interface ZANetworking ()
@property (nonatomic, strong) ZAHttpSessionManager *manager;
@property (nonatomic, assign) ZARequestType requestSerializerType;
@property (nonatomic, assign) ZAResponseType responseSerializerType;
@property (nonatomic, strong) NSDictionary *httpHeaders;
@property (nonatomic, assign) NSUInteger timeout;
@property (nonatomic, strong) NSMutableDictionary *allTaskDic;
@property (nonatomic, assign) AFNetworkReachabilityStatus networkReachabilityStatus;
@end

@implementation ZANetworking

- (instancetype)init
{
    if (self = [super init]) {
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        _networkReachabilityStatus = AFNetworkReachabilityStatusReachableViaWWAN;
        _timeout = 60;
    }
    return self;
}

+ (instancetype)shareInstance
{
    static ZANetworking *network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (network == nil) {
            network = [[ZANetworking alloc] init];
        }
    });
    
    return network;
}

- (NSMutableDictionary *)allTaskDic
{
    if (!_allTaskDic) {
        _allTaskDic = [[NSMutableDictionary alloc] init];
    }
    return _allTaskDic;
}

- (ZAHttpSessionManager *)manager {
    
    ZAHttpSessionManager *manager = [ZAHttpSessionManager shareInstance];
    
    if (self.requestSerializerType == kZARequestTypeJSON) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }else if (self.requestSerializerType == kZARequestTypePlainText){
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    if (self.responseSerializerType == kZAResponseTypeJSON) {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }else if (self.responseSerializerType == kZAResponseTypeXML){
        manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }else{
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    for (id key in self.httpHeaders.allKeys) {
        if (key && (self.httpHeaders[key])) {
            [manager.requestSerializer setValue:self.httpHeaders[key] forHTTPHeaderField:key];
        }
    }
    
    manager.requestSerializer.timeoutInterval = self.timeout;
    _manager = manager;
    
    return manager;
}

#pragma mark - config
+ (void)setTimeout:(NSUInteger)timeout {
    [ZANetworking shareInstance].timeout = timeout;
}

+ (void)configRequestType:(ZARequestType)requestType
             responseType:(ZAResponseType)responseType{
    
    [ZANetworking shareInstance].requestSerializerType = requestType;
    [ZANetworking shareInstance].responseSerializerType = responseType;
}

+ (void)configHttpHeaders:(NSDictionary *)httpHeaders {
    [ZANetworking shareInstance].httpHeaders = httpHeaders;
}

#pragma mark - task

+ (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters progress:(ZANetworkProgress)progress success:(ZANetworkSuccess)success failure:(ZANetworkFailure)failure
{
    NSString *taskID = [ZANetworking taskID:URLString params:parameters];
    ZAHttpSessionManager *manager = [[ZANetworking shareInstance] manager];
    NSURLSessionDataTask *task = [manager GET:URLString parameters:parameters
                                          progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                              
                                              if (success) {success(task.response, responseObject);}
                                              [ZANetworking removeTaskWithID:taskID];
                                              
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        if (failure) {failure(task.response, error);}
        [ZANetworking removeTaskWithID:taskID];
    }];
    
    [ZANetworking saveTaskWithID:taskID task:task];
    
    return task;
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters progress:(ZANetworkProgress)progress success:(ZANetworkSuccess)success failure:(ZANetworkFailure)failure
{
    NSString *taskID = [ZANetworking taskID:URLString params:parameters];
    ZAHttpSessionManager *manager = [[ZANetworking shareInstance] manager];
    NSURLSessionDataTask *task = [manager POST:URLString parameters:parameters
                                     progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                         
                                         if (success) {success(task.response, responseObject);}
                                         [ZANetworking removeTaskWithID:taskID];
                                         
                                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                         
                                         if (failure) {failure(task.response, error);}
                                         [ZANetworking removeTaskWithID:taskID];
                                     }];
    
    [ZANetworking saveTaskWithID:taskID task:task];
    
    return task;
}

+ (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)URLString parameters:(NSDictionary *)parameters targetPath:(NSString *)targetFilePath progress:(ZANetworkProgress)progress success:(ZANetworkSuccess)success failure:(ZANetworkFailure)failure
{
    NSString *taskID = [ZANetworking taskID:URLString params:parameters];
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    downloadRequest = [[AFJSONRequestSerializer serializer] requestBySerializingRequest:downloadRequest withParameters:parameters error:nil];
    
    ZAHttpSessionManager *manager = [[ZANetworking shareInstance] manager];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:downloadRequest progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:targetFilePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(response, error);
            }
        }else{
            if (success) {
                success(response, filePath.absoluteString);
            }
        }
        [ZANetworking removeTaskWithID:taskID];
    }];
    [task resume];
    [ZANetworking saveTaskWithID:taskID task:task];
    return task;
}

+ (NSURLSessionUploadTask *)uploadFileWithhURLString:(NSString *)URLString parameters:(NSDictionary *)parameters fromFilePath:(NSString *)fromFilePath progress:(ZANetworkProgress)progress success:(ZANetworkSuccess)success failure:(ZANetworkFailure)failure
{
    NSString *taskID = [ZANetworking taskID:URLString params:parameters];
    ZAHttpSessionManager *manager = [[ZANetworking shareInstance] manager];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    request = [[AFJSONRequestSerializer serializer] requestBySerializingRequest:request withParameters:parameters error:nil];
    
    NSURLSessionUploadTask *task = [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:fromFilePath] progress:progress completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure(response, error);
            }
        }else{
            if (success) {
                success(response, responseObject);
            }
        }
        [ZANetworking removeTaskWithID:taskID];
    }];
    [task resume];
    [ZANetworking saveTaskWithID:taskID task:task];
    
    return task;
}

+ (NSURLSessionTask *)uploadWithURLString:(NSString *)URLString
                               parameters:(NSDictionary *)parameters
                                filePath:(NSString *)filePath
                                filename:(NSString *)fileName
                                    name:(NSString *)name
                                mimeType:(NSString *)mimeType
                                progress:(ZANetworkProgress)progress
                                 success:(ZANetworkSuccess)success
                                    fail:(ZANetworkFailure)failure
{
    NSString *taskID = [ZANetworking taskID:URLString params:parameters];
    ZAHttpSessionManager *manager = [[ZANetworking shareInstance] manager];
    NSURLSessionTask *task = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:name fileName:fileName mimeType:mimeType error:nil];
    } progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task.response,responseObject);
        }
        [ZANetworking removeTaskWithID:taskID];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task.response, error);
        }
        [ZANetworking removeTaskWithID:taskID];
    }];
    [task resume];
    return task;
}

+ (NSURLSessionTask *)uploadWithURLString:(NSString *)URLString
                               parameters:(NSDictionary *)parameters
                                 fileData:(NSData *)fileData
                                 filename:(NSString *)fileName
                                     name:(NSString *)name
                                 mimeType:(NSString *)mimeType
                                 progress:(ZANetworkProgress)progress
                                  success:(ZANetworkSuccess)success
                                     fail:(ZANetworkFailure)failure
{
    NSString *taskID = [ZANetworking taskID:URLString params:parameters];
    ZAHttpSessionManager *manager = [[ZANetworking shareInstance] manager];
    NSURLSessionTask *task = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
    } progress:progress success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(task.response,responseObject);
        }
        [ZANetworking removeTaskWithID:taskID];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(task.response, error);
        }
        [ZANetworking removeTaskWithID:taskID];
    }];
    [task resume];
    return task;
}

+ (void)cancelTaskWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters
{
    if ([ZANetworking isNullString:URLString]){return;}
    @synchronized(self) {
        NSString *key = [ZANetworking taskID:URLString params:parameters];
        if (key){
            NSURLSessionTask *oldSession = [[ZANetworking shareInstance].allTaskDic objectForKey:key];
            if (oldSession && [oldSession isKindOfClass:[NSURLSessionTask class]]) {
                [oldSession cancel];
            }
        }
    };
}

+ (void)saveTaskWithID:(NSString *)taskID task:(NSURLSessionTask *)task
{
    if (taskID && task) {
        [[ZANetworking shareInstance].allTaskDic setObject:task forKey:taskID];
    }
}

+ (void)removeTaskWithID:(NSString *)taskID
{
    if (taskID) {
        [[ZANetworking shareInstance].allTaskDic removeObjectForKey:taskID];
    }
}

+ (void)detectNet:(void(^)(AFNetworkReachabilityStatus status))statusChangeBlock
{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [ZANetworking shareInstance].networkReachabilityStatus = status;
        if (statusChangeBlock) {
            statusChangeBlock(status);
        }
    }];
    [manager startMonitoring];
}

+ (AFNetworkReachabilityStatus)networkReachabilityStatus
{
   return [ZANetworking shareInstance].networkReachabilityStatus;
}

#pragma mark - Utils
+ (BOOL)isNullString:(NSString *)string
{
    BOOL correct = (string && [string isKindOfClass:[NSString class]] && string.length);
    return !correct;
}

+ (NSString *)md5FromString:(NSString *)string
{
    if (string == nil || ![string isKindOfClass:[NSString class]]){
        return nil;
    }
    const char *cStr = [string UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, (CC_LONG)(strlen(cStr)), result );
    NSString *md5String = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0],result[1],result[2],result[3],
                           result[4],result[5],result[6],result[7],
                           result[8],result[9],result[10],result[11],
                           result[12],result[13],result[14],result[15]];
    return md5String;
}

+ (NSString *)taskID:(NSString *)url params:(NSDictionary *)params
{
    if ([self isNullString:url]) {return nil;}
    NSString *text = url;
    if ([params isKindOfClass:[NSDictionary class]] && params.count && params.description){
        text = [url stringByAppendingString:params.description];
    }
    return [self md5FromString:text];
}

@end
