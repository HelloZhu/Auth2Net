//
//  UIImageView+ESDDownloadIMG.h
//  BFTaskDemo
//
//  Created by ap2 on 2017/12/29.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadRequest;

@interface UIImageView (ESDDownloadIMG)

- (DownloadRequest *)esd_setImageWithFileID:(NSString *)fileID
                          placeholderImage:(UIImage *)placeholder
                                 completed:(void(^)(UIImage *image, BOOL success))completion;
@end
