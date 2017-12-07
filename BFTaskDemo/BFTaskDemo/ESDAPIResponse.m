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

@end
