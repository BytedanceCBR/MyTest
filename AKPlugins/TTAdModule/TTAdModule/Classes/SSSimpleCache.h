//
//  SSSimpleCache.h
//  Gallery
//
//  Created by Zhang Leonardo on 12-6-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    该类中使用的TTImageInfosModel，一定要存在URI， 其他的可以没有
 
 */
@class TTImageInfosModel;
@interface SSSimpleCache : NSObject

+ (SSSimpleCache *)sharedCache;

//不能保证cache一定存在， 其检查cached的plist， 不检查磁盘文件。
- (BOOL)quickCheckIsCacheExist:(NSString *)url;
- (BOOL)quickCheckIsImageInfosModelExist:(TTImageInfosModel *)model;  //- (BOOL)quickCheckIsArrayCacheExist:(NSArray *)URLAndHeaders;

- (BOOL)isCacheExist:(NSString *)url;
- (BOOL)isImageInfosModelCacheExist:(TTImageInfosModel *)model;
- (BOOL)isImageCacheExist:(NSString *)uri;


- (NSString *)fileCachePathIfExist:(NSString *)url;
- (NSString *)imageInfoModelCachePathIfExist:(TTImageInfosModel *)model;

- (void)clearCache;
- (void)startGarbageCollection DEPRECATED_MSG_ATTRIBUTE("废弃");
- (void)stopGarbageCollection DEPRECATED_MSG_ATTRIBUTE("废弃");

///**
// *  进入前台的时候调用
// */
//- (void)enterForegroundClear;

/**
 *  enterBackground的时候在queue中调用
 */
- (void)enterBackgroundClear;

//asynchronous method
- (void)setData:(NSData*)data forKey:(NSString*)key;
- (void)setData:(NSData *)data forImageInfosModel:(TTImageInfosModel *)model;
- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
- (void)setData:(NSData *)data forImageInfosModel:(TTImageInfosModel *)model withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (void)removeCacheForUrl:(NSString *)url;
- (NSData *)dataForUrl:(NSString *)url;

- (NSData *)dataForImageInfosModel:(TTImageInfosModel *)model; //- (NSData *)dataForURLAndHeaders:(NSArray *)URLAndHeaders;

///...
- (void)setData:(NSData *)data forVideoId:(NSString *)videoId;
+ (BOOL)isVideoCacheExistWithVideoId:(NSString *)videoId;
+ (NSString *)cachePath4VideoWithVideoId:(NSString *)videoId;

// in MB
+ (float)cacheSize;
+ (BOOL)hasCacheSize;

@end
