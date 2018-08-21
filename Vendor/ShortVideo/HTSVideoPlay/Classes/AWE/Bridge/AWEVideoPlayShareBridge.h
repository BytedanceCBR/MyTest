//
//  HTSVideoPlayShareBridge.h
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AWEVideoPlayShareBridgeShareType) {
    AWEVideoPlayShareBridgeShareTypeDefault = 0,
    AWEVideoPlayShareBridgeShareTypeWeixinShare = 1,
    AWEVideoPlayShareBridgeShareTypeWeixinMoment = 2,
    AWEVideoPlayShareBridgeShareTypeSinaWeibo = 3,
    AWEVideoPlayShareBridgeShareTypeQQZone = 4,
    AWEVideoPlayShareBridgeShareTypeQQShare = 5,
    AWEVideoPlayShareBridgeShareTypeCopy = 6,
    AWEVideoPlayShareBridgeShareTypeMore = 1000,
};

@class TTShortVideoModel;
@interface AWEVideoPlayShareBridge : NSObject

+ (void)shareVideo:(TTShortVideoModel *)videoModel shareType:(AWEVideoPlayShareBridgeShareType)shareType controller:(nullable UIViewController *)controller;

+ (void)startListenShareWithBlock:(void(^)(id _Nullable params))block;

+ (void)stopListenShare;

+ (void)loadImageWithUrl:(NSString *)urlStr completion:(void(^)(UIImage *image))completion;

@end

NS_ASSUME_NONNULL_END
