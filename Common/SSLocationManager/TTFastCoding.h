//
//  TTFastCoding.h
//  homework
//
//  Created by panxiang on 14-7-17.
//  Copyright (c) 2014年 panxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTFileManager.h"

@interface TTFastCoding : NSObject<NSCoding ,Singleton>
@property (strong, nonatomic) NSString *etag;
+ (instancetype)read;
+ (instancetype)readNoInit;
- (void)save;
+ (void)deleteFile;

//指定 file name
+ (instancetype)readWithFileName:(NSString *)fileName;
+ (instancetype)readWithFileNameNoInit:(NSString *)fileName;//如果读取为nil就返回nil.不初始化.
+ (void)deleteFileWithFileName:(NSString *)fileName;
- (void)saveWithFileName:(NSString *)fileName;
+ (void)deleteAllInDirectory:(NSString *)directory;

//for subclass 自定义存储的位置. 默认 SKDirectory_default
+ (SKDirectory)customDirectory;
@end

@interface TTFastCoding (Cache)
+ (void)registerAutoCleanDirectory:(NSString *)directory;
+ (void)cleanExpirationFile;
@end
