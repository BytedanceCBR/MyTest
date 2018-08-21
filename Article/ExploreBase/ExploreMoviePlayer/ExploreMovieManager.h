//
//  ExploreMovieManager.h
//  Article
//
//  Created by Zhang Leonardo on 15-3-5.
//
//

#import <Foundation/Foundation.h>
#import "ExploreVideoModel.h"
#import "ExploreVideoSP.h"
#import "TTGroupModel.h"


typedef NS_ENUM(NSInteger, TTVideoPlayRetryPolicy)
{
    TTVideoPlayRetryPolicyNone,
    TTVideoPlayRetryPolicyRetryOne,
    TTVideoPlayRetryPolicyRetryAll
};

@interface TTVideoURLRequestInfo : NSObject
@property(nonatomic, copy) NSString *videoID;
@property(nonatomic, assign) ExploreVideoSP sp;
@property(nonatomic, assign) TTVideoPlayType playType;
@property(nonatomic, copy) NSString *itemID;
@property(nonatomic, copy) NSString *categoryID;
@property(nonatomic, copy) NSString *adID;//广告ID，服务端用来区分是广告视频还是普通视频，以决定是否返回贴片
@end

@protocol ExploreMovieManagerDelegate;

@interface ExploreMovieManager : NSObject

@property(nonatomic, weak)id<ExploreMovieManagerDelegate>delegate;
@property(nonatomic, copy, readonly) NSString *videoRequestUrl;
@property(nonatomic, assign) BOOL isFeedUrl;//从feed拿url播放,不用at统计

- (void)fetchURLInfoWithRequestInfo:(TTVideoURLRequestInfo *)info;

- (void)cancelOperation;

+ (void)saveleTVUserKey:(NSString *)userKey;
+ (void)saveLeTVSecretKey:(NSString *)secretKey;

+ (void)saveToutiaoVideoUserKey:(NSString *)userKey;
+ (void)saveToutiaoVideoSecretKey:(NSString *)secretKey;

// 表示视频url请求失败后重试第二地址的间隔，单位是秒
+ (NSInteger)videoPlayRetryInterval;
+ (void)saveVideoPlayRetryInterval:(NSInteger)interval;

// 表示视频url请求失败后重试策略，0代表不重试，1代表重试1次，2代表重试所有地址
+ (TTVideoPlayRetryPolicy)videoPlayRetryPolicy;
+ (void)saveVideoPlayRetryPolicy:(NSInteger)policy;

// 表示视频url请求超时时长，单位秒
+ (NSInteger)videoPlayTimeoutInterval;
+ (void)saveVideoPlayTimeoutInterval:(NSInteger)interval;

// 视频加载非超时失败重试
+ (void)setRetryLoadWhenFailed:(BOOL)bRetry;
+ (BOOL)isRetryLoadWhenFailed;

@end

@protocol ExploreMovieManagerDelegate <NSObject>

- (void)manager:(ExploreMovieManager *)manager errorDict:(NSDictionary *)errorDict videoModel:(ExploreVideoModel *)videoModel;

@end
