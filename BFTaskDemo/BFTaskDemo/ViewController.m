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
//
//    LoginRequest *loginRequest = [[LoginRequest alloc] init];
//    [ESDOAuth2Manager fetchPWDTokenWithUserName:@"14458250055" pwd:@"9cbf8a4dcb8e30682b927f352d6559a0" success:^(AFOAuthCredential *credential) {
//
//        [[ESDAPINetManager sharedInstance] taskWithRequest:loginRequest progress:^(NSProgress *downloadProgress) {
//
//        } success:^(ESDAPIResponse *apiResponse) {
//
//        } failure:^(ESDAPIResponse *apiResponse) {
//
//        }];
//
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//
//    }];
    
   
    
    
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
    
    BOOL shouldStopHUD = YES;
    if ([ESDAPINetManager allTasks].count){
        for (ESDRequest *req in [ESDAPINetManager allTasks]) {
            if ([req shouldShowProgress]) {
                shouldStopHUD = NO;
                break;
            }
        }
    }
    
    
}

- (void)requestFail:(ESDRequest *)request response:(ESDAPIResponse *)response
{
    NSLog(@"%s - %@ ;%ld", __func__, [request requestUrl],[ESDAPINetManager allTasks].count);
}



@end
