//
//  ESDAPIResponse.m
//  ESD
//
//  Created by ap2 on 16/12/15.
//  Copyright © 2016年 zac. All rights reserved.
//

#import "ESDAPIResponse.h"

@implementation ESDAPIResponse

- (instancetype)init
{
    if (self = [super init])
    {
        _httpStatusCode = 200;
        _ApiStatusCode = 0;
        _msg = nil;
        _error = nil;
        _respondObject = nil;
        _headerField = nil;
        _URLResponse = nil;
    }
    return self;
}

+ (instancetype)successResponse:(id)respondObject httpStatusCode:(NSInteger)httpStatusCode ApiStatusCode:(NSInteger)ApiStatusCode msg:(NSString *)msg
{
    ESDAPIResponse *response = [[ESDAPIResponse alloc] init];
    response.respondObject = respondObject;
    response.httpStatusCode = httpStatusCode;
    response.ApiStatusCode = ApiStatusCode;
    response.msg = msg;
    return response;
}
+ (instancetype)failResponse:(NSURLResponse *)URLResponse httpStatusCode:(NSInteger)httpStatusCode error:(NSError *)error msg:(NSString *)msg
{
    ESDAPIResponse *response = [[ESDAPIResponse alloc] init];
    response.URLResponse = URLResponse;
    response.httpStatusCode = httpStatusCode;
    response.error = error;
    response.msg = msg;
    return response;
}


@end
