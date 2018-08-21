//
//  TTUGCShareUtil.h
//  Article
//
//  Created by 王霖 on 17/2/21.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FRThreadEntity;
@class Thread;
@class FRConcernEntity;

typedef NS_ENUM(NSUInteger, TTUGCShareSourceType) {
    TTUGCShareSourceTypeConcern = 0,
    TTUGCShareSourceTypeForum,
    TTUGCShareSourceTypeThread
};

@interface TTUGCShareUtil : NSObject

/// 获取帖子分享缩略图
+ (nullable UIImage *)shareThumbImageForThread:(Thread *)thread;

/// 获取帖子分享缩略图URL
+ (nullable NSString *)shareThumbImageURLForThread:(Thread *)thread;

/// 获取关心分享缩略图
+ (nullable UIImage *)shareThumbImageForConcernEntity:(FRConcernEntity *)concernEntity;

/// 获取关心分享缩略图URL
+ (nullable NSString *)shareThumbImageURLForConcernEntity:(FRConcernEntity *)concernEntity;

@end

NS_ASSUME_NONNULL_END
