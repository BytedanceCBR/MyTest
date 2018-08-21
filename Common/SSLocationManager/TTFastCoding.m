//
//  TTFastCoding.m
//  homework
//
//  Created by panxiang on 14-7-17.
//  Copyright (c) 2014年 panxiang. All rights reserved.
//

#import "TTFastCoding.h"
#import "NSObject+TTFastCoding.h"
#import <objc/runtime.h>


//static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 3; // 3 天

@implementation TTFastCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[self encodePropertiesWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	[self decodePropertiesWithCoder:aDecoder];
	return self;
}

+ (instancetype)getInstance
{
    return [self read];
}

+ (NSString *)fileName
{
    return NSStringFromClass([self class]);
}

- (void)save
{
    [self saveWithFileName:[[self class] fileName]];
}

+ (instancetype)readNoInit
{
    return [self readWithFileNameNoInit:[self fileName]];
}

+ (instancetype)read
{
    return [self readWithFileName:[self fileName]];
}

+ (void)deleteFile
{
    [self deleteFileWithFileName:[self fileName]];
}

+ (NSString *)classPathName:(NSString *)fileName
{
    if (fileName.length > 0) {
        return [NSStringFromClass([self class]) stringByAppendingPathComponent:fileName];
    }
    else
    {
        return NSStringFromClass([self class]);
    }
}

- (NSString *)classPathName:(NSString *)fileName
{
    return [[self class] classPathName:fileName];
}

+ (instancetype)readWithFileNameNoInit:(NSString *)fileName
{
    id object = [[TTFileManager sharedInstance_tt] readObjectFromDirectroy:[TTFastCoding customDirectory] fileName:[self classPathName:fileName]];
    return object;
}

+ (SKDirectory)customDirectory
{
    return SKDirectory_default;
}

+ (instancetype)readWithFileName:(NSString *)fileName
{
    id object = [[TTFileManager sharedInstance_tt] readObjectFromDirectroy:[TTFastCoding customDirectory] fileName:[self classPathName:fileName]];
    return object;
}

+ (void)deleteFileWithFileName:(NSString *)fileName
{
    [[TTFileManager sharedInstance_tt] deleteObjectFromDirectroy:[TTFastCoding customDirectory] fileName:[self classPathName:fileName]];
}

- (void)saveWithFileName:(NSString *)fileName
{
    NSMutableArray *items = [NSMutableArray arrayWithArray:[fileName componentsSeparatedByString:@"/"]];
    [items removeLastObject];
    NSString *directory = [items componentsJoinedByString:@"/"];
    
    [[TTFileManager sharedInstance_tt] createDirectoryWithName:[self classPathName:directory] inDic:[TTFastCoding customDirectory]];
    [[TTFileManager sharedInstance_tt] storeObject:self inDirectroy:[TTFastCoding customDirectory] fileName:[self classPathName:fileName]];
}

+ (void)deleteAllInDirectory:(NSString *)directory
{
    if (directory) {
        [[TTFileManager sharedInstance_tt] deleteObjectsFromDirectory:[TTFastCoding customDirectory] inSubDirectory:directory];
    }
}

@end

@implementation TTFastCoding (Cache)

static NSMutableArray *files;
+ (void)registerAutoCleanDirectory:(NSString *)directory
{
    [files addObject:directory];
}

+ (void)cleanExpirationFile
{
    if (!files) {
        files = [NSMutableArray array];
    }
    NSMutableArray *directory = [NSMutableArray arrayWithArray:[[TTFileManager sharedInstance_tt] contentsOfDirectoryInDirectory:
                                                                [TTFastCoding customDirectory]]];
    [directory addObjectsFromArray:files];
    [directory enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
    }];
    
}

@end