//
//  TTTabBarController.h
//  TestUniversaliOS6
//
//  Created by Nick Yu on 3/3/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTabBarController.h"

//typedef NS_ENUM(NSUInteger, TTTabbarIndex) {
//    TTTabbarIndexNews = 0,
//    TTTabbarIndexVideo = 1,
//    TTTabbarIndexForum = 2, //关心或话题或者微头条
//    TTTabbarIndexMine = 3
//};

extern NSString * const TTArticleTabBarControllerChangeSelectedIndexNotification;

@interface TTArticleTabBarController : TTTabBarController

- (BOOL)isShowingConcernOrForumTab;

- (void)didChangeCategory;

+ (NSString *)tabStayStringForIndex:(NSUInteger)index;

- (BOOL)isTipsShowing;

- (void)reloadTheme;

- (void)updateTabBarControllerWithAutoJump:(BOOL)autoJump;

@end

@interface QuickLoginDelegate : NSObject

@end
