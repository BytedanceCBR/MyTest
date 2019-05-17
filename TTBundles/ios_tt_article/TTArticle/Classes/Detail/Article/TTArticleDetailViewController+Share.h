//
//  TTArticleDetailViewController+Share.h
//  Article
//
//  Created by muhuai on 2017/7/30.
//
//

#import <Foundation/Foundation.h>
#import "TTArticleDetailViewController.h"
#import "TTActivityShareManager.h" //Share系列
#import "SSActivityView.h"
#import "ArticleShareManager.h"
#import <TTShareManager.h>

@interface TTArticleDetailViewController (Share)<SSActivityViewDelegate, UIActionSheetDelegate, TTActivityShareManagerDelegate,TTShareManagerDelegate>
@property(nonatomic, strong) SSActivityView *navMoreShareView;
@property(nonatomic, strong) SSActivityView *toolbarShareView;
@property(nonatomic, strong) TTActivityShareManager *activityActionManager;
//当前分享面板来源，navBar上moreButton或toolbar上分享
@property(nonatomic, assign) TTShareSourceObjectType curShareSourceType;

- (void)p_showMorePanel;

- (void)p_willShowSharePannel;

- (void)p_willChangeArticleFavoriteState;
@end
