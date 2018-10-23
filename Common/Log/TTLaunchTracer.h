//
//  TTLaunchTracer.h
//  NewsLite
//
//  Created by leo on 2018/9/18.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, TTAppLaunchFrom) {
    /// 初始状态
    TTAPPLaunchFromInitialState = 0,
    /// 用户手动点击进入app
    TTAPPLaunchFromUserClick = 1,
    /// 用户通过push点击进入app
    TTAPPLaunchFromRemotePush = 2,
    /// 用户通过widget点击进入app
    TTAPPLaunchFromWidget = 3,
    /// 用户通过sptlight点击进入app
    TTAPPLaunchFromSpotlight = 4,
    /// 用户通过外部app唤醒进入app
    TTAPPLaunchFromExternal = 5,
    /// 用户手动切回前台
    TTAPPLaunchFromBackground = 6,
};

@interface TTLaunchTracer : NSObject
@property (nonatomic, assign) TTAppLaunchFrom launchFromType;
@property (nonatomic, assign) NSInteger badgeNumber;
+ (instancetype)shareInstance;

- (void)setLaunchFrom:(TTAppLaunchFrom) from;

- (void)writeEvent;

- (void)setBadgeNumber:(NSInteger) badgeNumber;

- (void)willEnterForeground;

@end
