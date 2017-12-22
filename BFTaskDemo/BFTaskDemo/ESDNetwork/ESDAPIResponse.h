//
//  ESDAPIResponse.h
//  ESD
//
//  Created by ap2 on 16/12/15.
//  Copyright © 2016年 zac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESDAPIResponse;

typedef NS_ENUM(NSInteger, APIRespondCode) {
    APIRespondCode_Success = 0,
};


typedef void(^APIResponseSuccess)(ESDAPIResponse *apiResponse);
typedef void(^APIResponseFail)(ESDAPIResponse *apiResponse);

@interface ESDAPIResponse : NSObject
@property (nonatomic, assign) NSInteger httpStatusCode;
@property (nonatomic, assign) NSInteger ApiStatusCode;
@property (nonatomic, strong) id respondObject;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSDictionary *headerField;
@property (nonatomic, strong) NSURLResponse *URLResponse;

+ (instancetype)successResponse:(id)respondObject httpStatusCode:(NSInteger)httpStatusCode ApiStatusCode:(NSInteger)ApiStatusCode msg:(NSString *)msg;
+ (instancetype)failResponse:(NSURLResponse *)URLResponse httpStatusCode:(NSInteger)httpStatusCode error:(NSError *)error msg:(NSString *)msg;

@end
