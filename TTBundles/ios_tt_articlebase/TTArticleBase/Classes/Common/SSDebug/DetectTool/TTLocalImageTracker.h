//
//  UIImage+LocalImageTracker.h
//  Article
//
//  Created by xushuangqing on 06/09/2017.
//

#import <UIKit/UIKit.h>


/**
 监控本地图片使用情况
 上报策略：端监控初始化完成时上报一次，攒50个图或者退后台上报一次
 */
@interface TTLocalImageTracker : NSObject

+ (instancetype)sharedTracker;
- (void)setup;

@end
