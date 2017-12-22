//
//  FileConfig.h
//  ESD
//
//  Created by ap2 on 17/2/9.
//  Copyright © 2017年 zac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESDFileConfig : NSObject
@property (nonatomic, copy) NSString *filePath;//可以配置filePath，也可以配置fileData 其中的一个
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *name;

@end
