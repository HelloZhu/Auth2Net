//
//  ZAHttpSessionManager.h
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface ZAHttpSessionManager : AFHTTPSessionManager
+ (instancetype)shareInstance;
@end
