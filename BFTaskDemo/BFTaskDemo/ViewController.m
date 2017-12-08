//
//  ViewController.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/22.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "ViewController.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"
#import "AFNetworking.h"
#import "DCFHttpManager.h"
#import "AFOAuth2Manager.h"
#import "ESDAPINetManager.h"
#import "TestRequest.h"
#import "LoginRequest.h"
#import "ESDOAuth2Manager.h"
#import "DownloadRequest.h"
#import "ESDLoginAPIProtocol.h"

@interface ViewController ()<ESDAPINetManagerDelegate>
@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.manager = [AFHTTPSessionManager manager];
    
    
    
}
- (IBAction)testNet:(id)sender {
    
//    NSString *path = @"http://temp1.api.zac-esd.zhongan.com.cn/api/Service/HomePageConfig?platform=Ios";
    
    TestRequest *request = [[TestRequest alloc] init];
    request.retryCount = 0;
    request.delegate = self;
    
    [[ESDAPINetManager sharedInstance] taskWithRequest:request progress:^(NSProgress *downloadProgress) {
        
    } success:^(ESDAPIResponse *apiResponse) {
        
    } failure:^(ESDAPIResponse *apiResponse) {
        
    }];
    
    LoginRequest *loginRequest = [[LoginRequest alloc] init];
    [ESDOAuth2Manager fetchPWDTokenWithUserName:@"14458250055" pwd:@"9cbf8a4dcb8e30682b927f352d6559a0" success:^(AFOAuthCredential *credential) {

        [[ESDAPINetManager sharedInstance] taskWithRequest:loginRequest progress:^(NSProgress *downloadProgress) {

        } success:^(ESDAPIResponse *apiResponse) {

        } failure:^(ESDAPIResponse *apiResponse) {

        }];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
    ESDRequest *testReq = [ESDRequest new];
    if ([testReq conformsToProtocol:@protocol(ESDLoginAPIProtocol)]) {
        id <ESDLoginAPIProtocol> req = testReq;
        
    }
    
    
//    DownloadRequest *downloadRequest = [[DownloadRequest alloc] init];
//    [[ESDAPINetManager sharedInstance] taskWithRequest:downloadRequest progress:^(NSProgress *downloadProgress) {
//
//    } success:^(ESDAPIResponse *apiResponse) {
//
//    } failure:^(ESDAPIResponse *apiResponse) {
//
//    }];
}

- (void)requestWillStart:(ESDRequest *)request
{
    NSLog(@"%s - %@", __func__, [request requestUrl]);
}

- (void)requestSuccess:(ESDRequest *)request response:(ESDAPIResponse *)response
{
    NSLog(@"%s - %@ ;%ld", __func__, [request requestUrl],[ESDAPINetManager allTasks].count);
    
}

- (void)requestFail:(ESDRequest *)request response:(ESDAPIResponse *)response
{
    NSLog(@"%s - %@ ;%ld", __func__, [request requestUrl],[ESDAPINetManager allTasks].count);
}

- (void)test
{
    BFTaskCompletionSource *refreshTokenCS = [BFTaskCompletionSource taskCompletionSource];
    
    
    [[refreshTokenCS.task continueWithSuccessBlock:^id(BFTask *task) {
        
        
        
        return nil;
        
    }] continueWithBlock:^id (BFTask *task) {
        
        if (task.error) {
           
        }
        return nil;
    }];
}

- (BFTask *)executeEndPointAsync :(NSString *)url parameters:(id)parameters {
    BFTaskCompletionSource *BFTask = [BFTaskCompletionSource taskCompletionSource];
    
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    self.manager.responseSerializer = responseSerializer;
    
    [self.manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        //do something, save response
        [BFTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [BFTask setError:error];
    }];
    
    return BFTask.task;
}

@end
