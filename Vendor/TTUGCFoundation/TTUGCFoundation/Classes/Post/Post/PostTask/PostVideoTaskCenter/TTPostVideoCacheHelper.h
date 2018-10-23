//
//  TTPostVideoCacheHelper.h
//  Article
//
//  Created by 王霖 on 16/10/25.
//
//

#import <Foundation/Foundation.h>

extern  NSString * const kTTVideoCacheHelperTitleKey;
extern  NSString * const kTTVideoCacheHelperTitleRichSpanKey;
extern  NSString * const kTTVideoCacheHelperTitleInfoKey;

@interface TTPostVideoCacheHelper : NSObject

+ (nullable instancetype)sharedHelper;

///每当有一个task生成，需要使用到某个videoPath的时候，retain这个videoPath
- (void)retainVideoAtPath:(nullable NSString *)videoPath;
///每当有一个task被删除/发送完成，则release这个videoPath，当videoPath的"retainCount"为0时，真正删除这个video
- (void)releaseVideoAtPath:(nullable NSString *)videoPath;
///每当有一个task发送完成，加入延时（一天）删除队列
- (void)addVideoCacheWith:(nullable NSString *)gid url:(nullable NSString *)url;
///APP启动会调用，删除过期的视频
- (void)deleteVideoCacheIfNeed;

//获取缓存的标题信息
- (nullable NSDictionary *)getTitleInfo;
//缓存标题信息
- (void)cacheTitleInfo:(nullable NSDictionary *)titleInfo;

@end
