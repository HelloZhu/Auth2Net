//
//  UIButton+ESDDownloadIMG.h
//  BFTaskDemo
//
//  Created by ap2 on 2017/12/28.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESDAPINetManagerDelegate;
@class DownloadRequest;

@interface UIButton (ESDDownloadIMG)

- (DownloadRequest *)esd_setImageWithFileID:(NSString *)fileID forState:(UIControlState)state;

- (DownloadRequest *)esd_setImageWithFileID:(NSString *)fileID forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage completion:(void(^)(UIImage *image , BOOL success))completion;

- (DownloadRequest *)esd_setBackgroundImageWithFileID:(NSString *)fileID forState:(UIControlState)state;

- (DownloadRequest *)esd_setBackgroundImageWithFileID:(NSString *)fileID forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage completion:(void(^)(UIImage *image , BOOL success))completion;

@end
