//
//  DCFHttpManager.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/22.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "DCFHttpManager.h"
#import "BFTaskCompletionSource.h"
#import "AFNetworking.h"
#import "BFTask.h"

#define kRefreshTokenRetryCount 3

@interface DCFHttpManager()
@property (nonatomic, strong) BFTaskCompletionSource *refreshTokenCS;
@property (nonatomic) NSInteger refreshTokenRetryCount;
@property (nonatomic, copy) NSString *res_token;
@property (nonatomic, copy) NSString *ac_token;
@end

@implementation DCFHttpManager

+ (instancetype)sharedInstance
{
   
    static DCFHttpManager *ma = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ma = [[DCFHttpManager alloc] init];
    });
    
    return ma;
}
-(void)GET:(NSString *)urlString parameters:(nullable id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    self.refreshTokenRetryCount = 3;
    
    if (self.ac_token == nil)
    {
        BFTaskCompletionSource *fetchTokenCS = [BFTaskCompletionSource taskCompletionSource];
        
        [self fetchToken:fetchTokenCS];
        
        [[fetchTokenCS.task continueWithSuccessBlock:^id(BFTask *task) {
            
            [[DCFHttpManager sharedInstance] GET:urlString parameters:parameters success:success failure:failure];
            
            return nil;
            
        }] continueWithBlock:^id (BFTask *task) {
            
            if (task.error) {
                failure(task.error);
            }
            return nil;
        }];
        
        return;
    }

    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"708233cd-a705-44cf-8d18-b191822552c2" forHTTPHeaderField:@"EsdApi-Access-Key"];
    NSString *bear = [@"Bearer " stringByAppendingString:self.ac_token];
    [manager.requestSerializer setValue:bear forHTTPHeaderField:@"Authorization"];
    
    
    [manager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse*)task.response;
        if(response.statusCode == 401) {
            
            BFTaskCompletionSource *refreshTokenCS = [BFTaskCompletionSource taskCompletionSource];
            
            [self refreshToken:refreshTokenCS];
            
            [[refreshTokenCS.task continueWithSuccessBlock:^id(BFTask *task) {
                
                [[DCFHttpManager sharedInstance] GET:urlString parameters:parameters success:success failure:failure];
                
                return nil;
                
            }] continueWithBlock:^id (BFTask *task) {
                
                if (task.error) {
                    failure(task.error);
                }
                return nil;
            }];
            return;
            
        } else {
            
//            NSString *errorMsg = [NSString stringWithFormat:@"%@ - req:%@ - res:%@", urlString, parameters, response];
            failure(error);
        }
    }];
}

- (void)fetchToken:(BFTaskCompletionSource *)cs
{
    if(self.refreshTokenCS == nil || self.refreshTokenCS.task.completed || self.refreshTokenCS.task.cancelled) {
        
        self.refreshTokenCS = [BFTaskCompletionSource taskCompletionSource];
        
        //refresh token request
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setObject: @"client_credentials"    forKey:@"grant_type"];
        [dic setObject: @"612d3306-e70f-438f-9319-e5b1319a4f26" forKey:@"client_id"];
        [dic setObject: @"gyfrhBLx7GgdJff4gCpxrg==" forKey:@"client_secret"];
        
        [manager POST:@"http://temp1.zac-esd.zhongan.com.cn/OAuth/Token" parameters:dic  progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            self.refreshTokenRetryCount = kRefreshTokenRetryCount;
            
            NSDictionary *result = (NSDictionary *)responseObject;
            NSString *access_token = [result objectForKey:@"access_token"];
            NSString *refresh_token = [result objectForKey:@"refresh_token"];
            self.res_token = refresh_token;
            self.ac_token = access_token;
            [self.refreshTokenCS setResult:access_token];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            self.refreshTokenRetryCount --; //retry count --
            if(self.refreshTokenRetryCount < 0) {
                [self.refreshTokenCS setError:error];  //超过尝试次数直接error返回
            } else {
                [[DCFHttpManager sharedInstance] fetchToken:self.refreshTokenCS];
            }
            
        }];
    }
    
    [self.refreshTokenCS.task continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            [cs setError:task.error];
        } else {
            [cs setResult:nil];
        }
        return nil;
    }];
}

-(void)refreshToken:(BFTaskCompletionSource *)cs
{
    if(self.refreshTokenCS == nil || self.refreshTokenCS.task.completed || self.refreshTokenCS.task.cancelled) {
        
        self.refreshTokenCS = [BFTaskCompletionSource taskCompletionSource];
        
        //refresh token request
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setObject: @"refresh_token"    forKey:@"grant_type"];
        [dic setObject: @"612d3306-e70f-438f-9319-e5b1319a4f26" forKey:@"client_id"];
        [dic setObject: @"gyfrhBLx7GgdJff4gCpxrg==" forKey:@"client_secret"];
        [dic setObject: self.res_token   forKey:@"refresh_token"];
        
        [manager POST:@"http://temp1.zac-esd.zhongan.com.cn/OAuth/Token" parameters:dic  progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            self.refreshTokenRetryCount = kRefreshTokenRetryCount;
            NSDictionary *result = (NSDictionary *)responseObject;
            NSString *access_token = [result objectForKey:@"access_token"];
            NSString *refresh_token = [result objectForKey:@"refresh_token"];
            self.res_token = refresh_token;
            self.ac_token = access_token;
            [self.refreshTokenCS setResult:access_token];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            self.refreshTokenRetryCount --; //retry count --
            if(self.refreshTokenRetryCount < 0) {
                [self.refreshTokenCS setError:error];  //超过尝试次数直接error返回
            } else {
                [self.refreshTokenCS setError:error];
                [[DCFHttpManager sharedInstance] refreshToken:self.refreshTokenCS];
            }
            
        }];
    }
    
    [self.refreshTokenCS.task continueWithBlock:^id(BFTask *task) {
        if(task.error) {
            [cs setError:task.error];
        } else {
            [cs setResult:nil];
        }
        return nil;
    }];
}
@end
