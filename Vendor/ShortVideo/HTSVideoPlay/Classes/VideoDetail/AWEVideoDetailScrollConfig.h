//
//  AWEVideoDetailScrollConfig.h
//  Pods
//
//  Created by Zuyang Kou on 17/07/2017.
//
//

#import <Foundation/Foundation.h>

// iOS 不支持不滑动的情况 http://settings.byted.org/static/main/index.html#/app_settings/item_detail?id=664

typedef NS_ENUM(NSUInteger, AWEVideoDetailScrollDirection) {
    AWEVideoDetailScrollDirectionHorizontal = 1,
    AWEVideoDetailScrollDirectionVertical,
};

@interface AWEVideoDetailScrollConfig : NSObject

+ (AWEVideoDetailScrollDirection)direction;

@end
