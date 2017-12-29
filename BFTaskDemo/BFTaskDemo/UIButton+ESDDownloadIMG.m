//
//  UIButton+ESDDownloadIMG.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/12/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "UIButton+ESDDownloadIMG.h"
#import "DownloadRequest.h"

@implementation UIButton (ESDDownloadIMG)

- (DownloadRequest *)esd_setImageWithFileID:(NSString *)fileID forState:(UIControlState)state
{
   return [self esd_setImageWithFileID:fileID forState:state placeholderImage:nil completion:nil];
}

- (DownloadRequest *)esd_setImageWithFileID:(NSString *)fileID forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage completion:(void(^)(UIImage *image , BOOL success))completion
{
    if (!fileID) {return nil;}
    if (placeholderImage) {
        [self setImage:placeholderImage forState:state];
    }
    
    __weak __typeof(self)wself = self;
    DownloadRequest *request = [[DownloadRequest alloc] init];
    request.downloadFileIDs = @[fileID];
    [DownloadRequest downloadWithRequest:request success:^(NSArray *results) {
        __strong __typeof(wself)strongSelf = wself;
        UIImage *resultIMG = nil;
        if (results.count) {
            UIImage *resultIMG = [UIImage imageWithContentsOfFile:[results firstObject]];
            if (resultIMG) {
                dispatch_async(dispatch_get_main_queue(), ^{
                     [strongSelf setImage:resultIMG forState:state];
                });
            }
        }
        if (completion) {completion(resultIMG, YES);}
        
    } failure:^(ESDAPIResponse *apiResponse) {
        if (completion) {completion(nil, NO);}
    }];
    return request;
}

- (DownloadRequest *)esd_setBackgroundImageWithFileID:(NSString *)fileID forState:(UIControlState)state
{
    return [self esd_setBackgroundImageWithFileID:fileID forState:state placeholderImage:nil completion:nil];
}

- (DownloadRequest *)esd_setBackgroundImageWithFileID:(NSString *)fileID forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage completion:(void(^)(UIImage *image , BOOL success))completion
{
    if (!fileID) {return nil;}
    if (placeholderImage) {
        [self setImage:placeholderImage forState:state];
    }
    __weak __typeof(self)wself = self;
    DownloadRequest *request = [[DownloadRequest alloc] init];
    request.downloadFileIDs = @[fileID];
    [DownloadRequest downloadWithRequest:request success:^(NSArray *results) {
        __strong __typeof(wself)strongSelf = wself;
        UIImage *resultIMG = nil;
        if (results.count) {
            UIImage *resultIMG = [UIImage imageWithContentsOfFile:[results firstObject]];
            if (resultIMG) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf setBackgroundImage:resultIMG forState:state];
                });
            }
        }
        if (completion) {completion(resultIMG, YES);}
        
    } failure:^(ESDAPIResponse *apiResponse) {
        if (completion) {completion(nil, NO);}
    }];
    return request;
}

@end
