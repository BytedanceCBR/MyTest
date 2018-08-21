//
//  TTShareModuleBridge.h
//  Article
//
//  Created by 王霖 on 6/13/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTShareModuleBridgeShareType) {
    TTShareModuleBridgeShareTypeDefault = 0,
    TTShareModuleBridgeShareTypeWeixinShare = 1,
    TTShareModuleBridgeShareTypeWeixinMoment = 2,
    TTShareModuleBridgeShareTypeSinaWeibo = 3,
    TTShareModuleBridgeShareTypeQQZone = 4,
    TTShareModuleBridgeShareTypeQQShare = 5,
    TTShareModuleBridgeShareTypeCopy = 6,
    TTShareModuleBridgeShareTypeMore = 1000,
};
/**
 *  TTShareModuleBridge设计给火山直播插件调用头条分享模块时使用。
 *  由于头条的分享Pod还没有完成，暂时使用这种tricky的方式给火山直播插件提供分享功能。
 */
@interface TTShareModuleBridge : NSObject

/**
 *  获取单例
 *
 *  @return 单例
 */
+ (instancetype)shareInstance;

/**
 *  注册分享动作
 */
- (void)registerShareAction;

/**
 *  移除分享动作
 */
- (void)removeShareAction;

@end
