//
//  AppDelegate.h
//  Video
//
//  Created by Tianhang Yu on 12-7-15.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobClick.h"

@interface VideoBaseDelegate : UIResponder <UIApplicationDelegate, MobClickDelegate>

@property (nonatomic, retain) UIWindow *window;

- (NSString *)appKey;
- (NSString *)umTrackAppKey;
- (NSString*)weixinAppID;
- (void)showFeedbackViewController;

// should call in subclass's didFinishLaunchingWithOptions method when rootViewController has been added
- (void)handleApplicationLaunchOptionRemoteNotification:(NSDictionary *)launchOptions;
@end
