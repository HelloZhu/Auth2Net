//
//  ESDAPINetManager.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "ESDAPINetManager.h"
#import "BFTask.h"
#import "AFOAuth2Manager.h"
#import "AFOAuthCredential.h"
#import "BFTaskCompletionSource.h"
#import "ESDOAuth2Manager.h"
#import "ESDLoginAPIProtocol.h"

typedef NS_ENUM(NSInteger, FetchTokenType) {
    FetchClientToken = 0,
    FetchPWDToken,
    RefreshToken,
};


@interface ESDAPINetManager ()
@property (nonatomic, strong) BFTaskCompletionSource *tokenCS;
@property (nonatomic, strong) NSMutableArray *taskRequestArr;
@end

@implementation ESDAPINetManager

+ (instancetype)sharedInstance
{
    static ESDAPINetManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ESDAPINetManager alloc] init];
    });
    return manager;
}

- (NSURLSessionTask *)taskWithRequest:(ESDRequest *)request progress:(APINetProgress)progress success:(APIResponseSuccess)success failure:(APIResponseFail)failure
{
    [ESDAPINetManager executeWillStartDelegate:request];
    [self saveTask:request];
    if ([ZANetworking networkReachabilityStatus] == AFNetworkReachabilityStatusUnknown) {
        [self removeTask:request];
        dispatch_async(dispatch_get_main_queue(), ^{
            ESDAPIResponse *resp = [[ESDAPIResponse alloc] init];
            resp.msg = @"Network Error";
            [ESDAPINetManager executeFailDelegate:request response:resp];
            if (failure) {
                failure(resp);
            }
        });
        return nil;
    }
    
    if ([request shouldCancelExecutingSameRequest]) {
        [ESDAPINetManager cancelRequest:request];
    }
    
    ESDAPINetManager *manager = [ESDAPINetManager sharedInstance];
    AuthTokenType tokenType = [request needTokenType];
    AFOAuthCredential *credential = nil;
    if (tokenType != AuthTokenType_None) {
        credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kAFOAuth2TokenType_Client];
        if (tokenType == AuthTokenType_Password) {
            credential = [AFOAuthCredential retrieveCredentialWithIdentifier:kAFOAuth2TokenType_PWD];
            BOOL notContainPWDAuth = ((!credential || !credential.accessToken) && !credential.refreshToken);
            if (notContainPWDAuth) {
                [self removeTask:request];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ESDAPIResponse *resp = [[ESDAPIResponse alloc] init];
                    resp.msg = @"Not Contain password oauth info";
                    [ESDAPINetManager executeFailDelegate:request response:resp];
                    if (failure) {
                        failure(resp);
                    }
                });
                return nil;
            }
        }
        
        if (!credential || !credential.accessToken || credential.expired) {
            FetchTokenType fetchTokenType = FetchClientToken;
            if (credential.expired && credential.refreshToken) {
                fetchTokenType = RefreshToken;
            }
            BFTaskCompletionSource *fetchTokenCS = [BFTaskCompletionSource taskCompletionSource];
            [manager handleToken:fetchTokenCS fetchType:fetchTokenType refreshToken:credential.refreshToken];
            
            [[fetchTokenCS.task continueWithSuccessBlock:^id(BFTask *task) {
                [[ESDAPINetManager sharedInstance] taskWithRequest:request progress:progress success:success failure:failure];
                return nil;
            }] continueWithBlock:^id (BFTask *task) {
                if (task.error) {
                    [self removeTask:request];
                    ESDAPIResponse *fetchTokenFailResp = [[ESDAPIResponse alloc] init];
                    fetchTokenFailResp.error = task.error;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [ESDAPINetManager executeFailDelegate:request response:fetchTokenFailResp];
                        if (failure) {
                            failure(fetchTokenFailResp);
                        }
                    });
                }
                return nil;
            }];
            return nil;
        }
    }
    
    NSURLSessionTask *task = [manager dataTaskWithRequest:request credential:credential progress:progress success:^(NSURLResponse *response, id responseObject) {
        [self removeTask:request];
        [ESDAPINetManager handleSuccessWithRequest:request response:response responseObject:responseObject success:success];
    } failure:^(NSURLResponse *response, NSError *error) {
        [self removeTask:request];
        [ESDAPINetManager handleFailure:response error:error requset:request progress:progress success:success failure:failure refreshToken:credential.refreshToken];
    }];
    return task;
}

- (NSURLSessionTask *)dataTaskWithRequest:(ESDRequest *)request credential:(AFOAuthCredential *)credential progress:(ZANetworkProgress)progress success:(ZANetworkSuccess)success failure:(ZANetworkFailure)failure
{
    ESDRequestMethod method = [request requestMethod];
    NSDictionary *parameters = [request requestArgument];
    NSString *baseURLString = [request baseUrl];
    NSString *URLString = [request requestUrl];
    URLString = [NSString stringWithFormat:@"%@%@",baseURLString, URLString];
    
    NSMutableDictionary *allHeaderFileds = [NSMutableDictionary dictionary];
    NSDictionary *httpHeader = [request HttpHeaderArgument];
    if (httpHeader.count) {
        [allHeaderFileds addEntriesFromDictionary:httpHeader];
    }
    
    if (credential.accessToken) {
        NSString *authorization = [NSString stringWithFormat:@"Bearer %@", credential.accessToken];
        NSDictionary *OAuth2Dict =@{@"Authorization":authorization};
        [allHeaderFileds addEntriesFromDictionary:OAuth2Dict];
    }
    
    [ZANetworking configHttpHeaders:allHeaderFileds];
    [ZANetworking configRequestType:[request requestSerializerType] responseType:[request responseSerializerType]];
    [ZANetworking setTimeout:[request timeout]];
    
    NSURLSessionTask *task = nil;
    if (method == ESDRequestMethodGet) {
        task = [ZANetworking GET:URLString parameters:parameters progress:progress success:success failure:failure];
    }else if (method == ESDRequestMethodPost){
        task = [ZANetworking POST:URLString parameters:parameters progress:progress success:success failure:failure];
    }else if (method == ESDRequestMethodUploadFile){
        ESDFileConfig *fileINF = [request uploadFileINFO];
        task = [ZANetworking uploadWithURLString:URLString parameters:parameters filePath:fileINF.filePath filename:fileINF.fileName name:fileINF.name mimeType:fileINF.mimeType progress:progress success:success fail:failure];
    }else if (method == ESDRequestMethodDownloadFile){
        NSString *targetPath = [request downloadFileTargetPath];
        task = [ZANetworking downloadWithURLString:URLString parameters:parameters targetPath:targetPath progress:progress success:success failure:failure];
    }
    
    return task;
}

+ (void)handleSuccessWithRequest:(ESDRequest *)request response:(NSURLResponse *)response responseObject:(id)responseObject success:(APIResponseSuccess)success
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    ESDAPIResponse *apiResponse = [[ESDAPIResponse alloc] init];
   
    NSInteger code = 0;
    NSString *msg = nil;
    NSDictionary *data = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]){
        NSDictionary *responeDic = (NSDictionary *)responseObject;
        code = [[responeDic objectForKey:@"ResponseStatus"] integerValue];
        msg = [responeDic objectForKey:@"ResponseDetails"];
        data = [responeDic objectForKey:@"ResponseData"];
        apiResponse.respondObject = data;
    }else{
         apiResponse.respondObject = responseObject;
    }
    apiResponse.ApiStatusCode = code;
    apiResponse.msg = msg;
    apiResponse.httpStatusCode = httpResponse.statusCode;
    apiResponse.headerField = httpResponse.allHeaderFields;
    apiResponse.URLResponse = response;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ESDAPINetManager executeSuccessDelegate:request response:apiResponse];
        if (success){
            success(apiResponse);
        }
    });
}

+ (void)handleFailure:(NSURLResponse *)httpResponse
                error:(NSError *)error
              requset:(ESDRequest *)requset
             progress:(APINetProgress)progress
              success:(APIResponseSuccess)success
              failure:(APIResponseFail)failure
         refreshToken:(NSString *)refreshToken
{
    NSHTTPURLResponse *response = (NSHTTPURLResponse*)httpResponse;
    if(response.statusCode == 401) {
        BFTaskCompletionSource *refreshTokenCS = [BFTaskCompletionSource taskCompletionSource];
        [[ESDAPINetManager sharedInstance] handleToken:refreshTokenCS fetchType:RefreshToken refreshToken:refreshToken];
        [[refreshTokenCS.task continueWithSuccessBlock:^id(BFTask *task) {
            [[ESDAPINetManager sharedInstance] taskWithRequest:requset progress:progress success:success failure:failure];
            return nil;
        }] continueWithBlock:^id (BFTask *task) {
            if (task.error) {
                ESDAPIResponse *fetchTokenFailResp = [[ESDAPIResponse alloc] init];
                fetchTokenFailResp.error = error;
                fetchTokenFailResp.httpStatusCode = error.code;
                fetchTokenFailResp.msg = error.localizedFailureReason;
                fetchTokenFailResp.URLResponse = response;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ESDAPINetManager executeFailDelegate:requset response:fetchTokenFailResp];
                    if (failure) {
                        failure(fetchTokenFailResp);
                    }
                });
            }
            return nil;
        }];
    } else {
        requset.retryCount--;
        if (requset.retryCount >= 0) {
            [[ESDAPINetManager sharedInstance] taskWithRequest:requset progress:progress success:success failure:failure];
        }else{
            ESDAPIResponse *apiFailResp = [[ESDAPIResponse alloc] init];
            apiFailResp.error = error;
            apiFailResp.httpStatusCode = response.statusCode;
            apiFailResp.URLResponse = response;
            apiFailResp.msg = error.localizedDescription;
            dispatch_async(dispatch_get_main_queue(), ^{
                [ESDAPINetManager executeFailDelegate:requset response:apiFailResp];
                if (failure) {
                    failure(apiFailResp);
                }
            });
        }
    }
}

- (void)handleToken:(BFTaskCompletionSource *)cs fetchType:(FetchTokenType)type refreshToken:(NSString *)refreshToken
{
    if(self.tokenCS == nil || self.tokenCS.task.completed || self.tokenCS.task.cancelled) {
        self.tokenCS = [BFTaskCompletionSource taskCompletionSource];
        if (type == FetchClientToken) {
            [ESDOAuth2Manager fetchClientTokenWithSuccess:^(AFOAuthCredential *credential) {
                [self.tokenCS setResult:credential];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self.tokenCS setError:error];
            }];
        }else if (type == RefreshToken) {
            if (!refreshToken) {
                NSError *refreshTokenError = [NSError errorWithDomain:NSCocoaErrorDomain code:-200 userInfo:@{NSLocalizedDescriptionKey:@"refreshToken is null"}];
                [self.tokenCS setError:refreshTokenError];
                return;
            }
            [ESDOAuth2Manager refreshTokenWithRefreshToken:refreshToken success:^(AFOAuthCredential *credential) {
                [self.tokenCS setResult:credential];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [self.tokenCS setError:error];
            }];
        }
    }
    
    [self.tokenCS.task continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            [cs setError:task.error];
        } else {
            [cs setResult:nil];
        }
        return nil;
    }];
}

+ (void)cancelRequest:(ESDRequest *)request
{
    NSDictionary *parameters = [request requestArgument];
    NSString *baseURLString = [request baseUrl];
    NSString *URLString = [request requestUrl];
    URLString = [NSString stringWithFormat:@"%@%@",baseURLString, URLString];
    [ZANetworking cancelTaskWithURL:URLString parameters:parameters];
}

+ (void)executeWillStartDelegate:(ESDRequest *)request
{
    if (request.delegate && [request.delegate respondsToSelector:@selector(requestWillStart:)]) {
        [request.delegate requestWillStart:request];
    }
}

+ (void)executeSuccessDelegate:(ESDRequest *)request response:(ESDAPIResponse *)response
{
    if (request.delegate && [request.delegate respondsToSelector:@selector(requestSuccess:response:)]) {
        [request.delegate requestSuccess:request response:response];
    }
}

+ (void)executeFailDelegate:(ESDRequest *)request response:(ESDAPIResponse *)response
{
    if (request.delegate && [request.delegate respondsToSelector:@selector(requestFail:response:)]) {
        [request.delegate requestFail:request response:response];
    }
}

- (void)saveTask:(ESDRequest *)request
{
    @synchronized(self) {
        if (request) {
            [self.taskRequestArr addObject:request];
        }
    };
}

- (void)removeTask:(ESDRequest *)request
{
    @synchronized(self) {
        if (request && [self.taskRequestArr containsObject:request]) {
            [self.taskRequestArr removeObject:request];
        }
    };
}

+ (NSArray *)allTasks
{
    return [ESDAPINetManager sharedInstance].taskRequestArr;
}

@end
