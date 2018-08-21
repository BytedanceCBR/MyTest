//
//  SettingVIew.h
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSViewBase.h"
#import <TTAccountBusiness.h>



#define kSettingViewWillAppearNotification @"kSettingViewWillAppearNotification"
#define kSettingViewWillDisappearNotification @"kSettingViewWillDisappearNotification"
#define kSettingViewRegistPushNotification @"kSettingViewRegistPushNotification"


@class SettingView;
@protocol SettingViewDelegate <NSObject>

- (void)padSettingViewDidSelectedCell:(SettingView*)settingView;

@end

@interface SettingView : SSViewBase
<
TTAccountMulticastProtocol
>

@property (nonatomic, weak) NSObject<SettingViewDelegate> *delegate;

- (void)refreshContent;

+ (NSUInteger)settingNewPointBadgeNumber;

@end
