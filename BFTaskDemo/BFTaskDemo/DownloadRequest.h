//
//  DownloadRequest.h
//  BFTaskDemo
//
//  Created by ap2 on 2017/11/30.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "ESDRequest.h"

@interface DownloadRequest : ESDRequest
@property (nonatomic, strong) NSArray *downloadFileIDs;

+ (void)downloadWithRequest:(DownloadRequest *)request success:(void(^)(NSArray *results))success failure:(void(^)(ESDAPIResponse *apiResponse))failure;

@end
