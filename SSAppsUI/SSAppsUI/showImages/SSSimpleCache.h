//
//  SSSimpleCache.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSImageInfosModel.h"

/*
    该类中使用的SSImageInfosModel，一定要存在URI， 其他的可以没有
 
 */

@interface SSSimpleCache : NSObject

+ (SSSimpleCache *)sharedCache;

//不能保证cache一定存在， 其检查cached的plist， 不检查磁盘文件。
- (BOOL)quickCheckIsCacheExist:(NSString *)url;
- (BOOL)quickCheckIsImageInfosModelExist:(SSImageInfosModel *)model;  //- (BOOL)quickCheckIsArrayCacheExist:(NSArray *)URLAndHeaders;

- (BOOL)isCacheExist:(NSString *)url;
- (BOOL)isImageInfosModelCacheExist:(SSImageInfosModel *)model;

- (NSString *)fileCachePathIfExist:(NSString *)url;
- (NSString *)imageInfoModelCachePathIfExist:(SSImageInfosModel *)model;

- (void)clearCache;
- (void)startGarbageCollection;
- (void)stopGarbageCollection;

//asynchronous method
- (void)setData:(NSData*)data forKey:(NSString*)key;
- (void)setData:(NSData *)data forImageInfosModel:(SSImageInfosModel *)model;

- (void)removeCacheForUrl:(NSString *)url;
- (NSData *)dataForUrl:(NSString *)url;

- (NSData *)dataForImageInfosModel:(SSImageInfosModel *)model; //- (NSData *)dataForURLAndHeaders:(NSArray *)URLAndHeaders;


// in MB
+ (float)cacheSize;
+ (BOOL)hasCacheSize;

@end
