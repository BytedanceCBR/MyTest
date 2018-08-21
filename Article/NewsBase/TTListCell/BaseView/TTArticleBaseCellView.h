//
//  TTArticleBaseCellView.h
//  Article
//
//  Created by 杨心雨 on 16/8/23.
//
//

#import "TTTableViewBaseCellView.h"
#import "TTLabel.h"
#import "TTArticleFunctionView.h"
#import "TTArticleCommentView.h"
#import "TTArticlePicView.h"
#import "TTArticleInfoView.h"
#import "TTArticleTagView.h"
#import "ExploreItemActionManager.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "TTActionPopView.h"

@interface TTArticleBaseCellView : TTTableViewBaseCellView <TTMoreViewProtocol, TTDislikePopViewDelegate, TTFunctionViewProtocol, TTInfoViewProtocol, SSActivityViewDelegate>

@property (nonatomic, strong) TTArticleFunctionView * _Nonnull functionView;
@property (nonatomic, strong) SSThemedButton * _Nonnull moreView;
@property (nonatomic, strong) TTLabel * _Nonnull titleView;
@property (nonatomic, strong) TTLabel * _Nonnull abstractView;
@property (nonatomic, strong) TTArticleCommentView * _Nonnull commentView;
@property (nonatomic, strong) TTArticlePicView * _Nonnull picView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull liveTextView;
@property (nonatomic, strong) TTArticleInfoView * _Nonnull infoView;
@property (nonatomic, strong) SSThemedView * _Nonnull bottomLineView;
@property (nonatomic, strong) TTArticleTagView * _Nonnull tagView;
@property (nonatomic) BOOL isViewHighlighted;
@property (nonatomic, strong) ExploreItemActionManager * _Nonnull itemActionManager;
@property (nonatomic, strong) TTActivityShareManager * _Nonnull activityActionManager;
@property (nonatomic, strong) SSActivityView * _Nullable phoneShareView;
@property (nonatomic, strong) NSDictionary * _Nonnull extraDic;

- (void)readModeChanged:(NSNotification * _Nullable)notification;
- (void)subscribeStatusChanged:(NSNotification * _Nullable)notification;

- (void)updateFunctionView;
- (void)updateTagView;
- (void)updateTitleView:(CGFloat)fontSize isBold:(BOOL)isBold lineHeight:(CGFloat)lineHeight firstLineIndent:(CGFloat)firstLineIndent;
- (void)updateTitleView;
- (void)updateAbstractView;
- (void)updateCommentView;
- (void)updatePicView;
- (void)updateInfoView;
- (void)updateBottomLineView;

- (void)layoutMoreViewWithCenter:(BOOL)center;
- (void)layoutMoreView;

- (void)showMenu;

@end
