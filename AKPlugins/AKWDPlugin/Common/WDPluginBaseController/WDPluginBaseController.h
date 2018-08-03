//
//  WDPluginBaseController.h
//  Article
//
//  Created by ZhangLeonardo on 16/1/5.
//
//

#import "SSViewControllerBase.h"

@interface WDPluginBaseController : SSViewControllerBase

/**
 *  发送页面的完成停留时间， 包括进入子页面的时间
 *
 *  @param duration 页面的完成停留时间， 包括进入子页面的时间
 */
- (void)_sendPageStayTime:(NSTimeInterval)duration;

/**
 *  发送页面的停留时间， 只计算当前页面给用户展示的时间
 *
 *  @param duration 页面的停留时间, 只计算当前页面给用户展示的时间
 */
- (void)_sendCurrentPageStayTime:(NSTimeInterval)duration;

/**
 *  回到前台
 *
 *  @param notification 回到前台通知
 */
- (void)_willEnterForeground:(NSNotification *)notification;

/**
 *  进入后台
 *
 *  @param notification 进入后台通知
 */
- (void)_didEnterBackground:(NSNotification *)notification;


@end
