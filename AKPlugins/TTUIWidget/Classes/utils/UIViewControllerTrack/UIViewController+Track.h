//
//  UIViewController+Track.h
//  TestAutoLayout
//
//  Created by yuxin on 9/11/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//
//  说明： 这个类提供了一个VC 页面停留时长的统计，替换了willappear 和 willDisappear。
//  使用的时候需要把 ttTrakStayEnable 打开YES， 使用ttTrackStayTime来发统计事件
//

#import <UIKit/UIKit.h>

/**
 *  若页面需要处理App进入后台的stay_page统计时，不需要监听UIApplication通知，实现协议方法即可。
 */
@protocol TTUIViewControllerTrackProtocol <NSObject>

@optional
- (void)trackEndedByAppWillEnterBackground;
- (void)trackStartedByAppWillEnterForground;
@end

@interface UIViewController (Track) <TTUIViewControllerTrackProtocol>

@property (nonatomic, assign) IBInspectable BOOL ttTrackStayEnable;

@property (nonatomic, assign) NSTimeInterval ttTrackStayTime;

@property (nonatomic, assign) NSTimeInterval ttTrackStartTime;

-(void)tt_resetStayTime;

@end
