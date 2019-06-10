//
//  TTPushResourceMgr.h
//  Article
//
//  Created by liuzuopeng on 11/07/2017.
//
//

#import <Foundation/Foundation.h>



@interface TTPushResourceMgr : NSObject

/**
 *  预加载多个图片
 */
+ (void)prefetchImageWithURLStrings:(NSArray<NSString *> *)imageURLStrings
                         completion:(void (^)(BOOL fullCompleted /** 是否全部成功 */))completedHandler;

/**
 *  下载多个图片
 */
+ (void)downloadImageWithURLStrings:(NSArray<NSString *> *)imageURLStrings
                         completion:(void (^)(NSDictionary<NSString *, NSNumber *> *flagsMapper /** url是否下载成功 */,
                                              NSDictionary<NSString *, UIImage *> *imagesMapper /** url下载成功对应的image*/))completedHandler;


/** 下载图片资源 */
+ (void)downloadImageWithURLString:(NSString *)imageURLString
                        completion:(void (^)(UIImage *image, BOOL success))completedHandler;

/** 读取图片(优先读缓存然后读磁盘)，不存在则下载 */
+ (UIImage *)cachedImageForURLString:(NSString *)imageURLString;

/** 检查是否存在 */
+ (BOOL)cachedImageExistsForURLString:(NSString *)imageURLString;

@end
