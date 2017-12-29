//
//  UIImageView+ESDDownloadIMG.m
//  BFTaskDemo
//
//  Created by ap2 on 2017/12/29.
//  Copyright © 2017年 ap2. All rights reserved.
//

#import "UIImageView+ESDDownloadIMG.h"
#import "DownloadRequest.h"

@implementation UIImageView (ESDDownloadIMG)
- (DownloadRequest *)esd_setImageWithFileID:(NSString *)fileID
          placeholderImage:(UIImage *)placeholder
                 completed:(void(^)(UIImage *image, BOOL success))completion
{
    if (!fileID) {return nil;}
    if (placeholder) {
        self.image = placeholder;
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
                    strongSelf.image = resultIMG;
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
