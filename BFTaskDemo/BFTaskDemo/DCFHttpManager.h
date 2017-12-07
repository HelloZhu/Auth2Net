//
//  DCFHttpManager.h
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/22.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCFHttpManager : NSObject
+ (instancetype)sharedInstance;
- (void)GET:(NSString *)urlString parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure;
@end
