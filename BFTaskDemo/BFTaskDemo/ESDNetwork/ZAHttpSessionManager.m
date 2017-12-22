//
//  ZAHttpSessionManager.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "ZAHttpSessionManager.h"

/**[AFHTTPSessionManager manager] 会造成内存泄露，使用单例可以解决 */

@implementation ZAHttpSessionManager
+ (instancetype)shareInstance
{
    static ZAHttpSessionManager *sessionManager= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sessionManager == nil) {
            sessionManager = [ZAHttpSessionManager manager];
            sessionManager.operationQueue.maxConcurrentOperationCount = 4;
            //manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
//            sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
//                                                                                             @"text/html",
//                                                                                             @"text/json",
//                                                                                             @"text/plain",
//                                                                                             @"text/javascript",
//                                                                                             @"text/xml",
//                                                                                             @"image/*"]];
        }
    });
    
    return sessionManager;
}
@end
