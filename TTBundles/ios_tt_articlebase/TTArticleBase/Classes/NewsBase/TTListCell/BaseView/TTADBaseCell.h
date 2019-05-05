//
//  TTADBaseCell.h
//  Article
//
//  Created by 杨心雨 on 16/8/24.
//
//

#import "ExploreActionButton.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellBase.h"
#import "ExploreItemActionManager.h"
#import "SSActivityView.h"
#import "SSThemed.h"
#import "TTADActionView.h"
#import "TTADInfoView.h"
#import "TTActionPopView.h"
#import "TTActivityShareManager.h"
#import "TTAlphaThemedButton.h"
#import "TTArticleFunctionView.h"
#import "TTArticleInfoView.h"
#import "TTArticlePicView.h"
#import "TTLabel.h"
#import "TTTableViewBaseCellView.h"
#import "TTTouchContext.h"
#import "TTVideoCellActionBar.h"

/**
 Cell {view + layout + data}
 */
@interface TTADBaseCell : ExploreCellBase <TTMoreViewProtocol, TTDislikePopViewDelegate, TTFunctionViewProtocol, TTInfoViewProtocol, SSActivityViewDelegate>

@property (nonatomic, strong) TTArticleFunctionView * _Nonnull functionView;
@property (nonatomic, strong) SSThemedButton * _Nonnull moreView;
@property (nonatomic, strong) TTLabel * _Nonnull titleView;
@property (nonatomic, strong) TTArticlePicView * _Nonnull picView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull sourceName;
@property (nonatomic, strong) ExploreActionButton * _Nonnull actionButton;
@property (nonatomic, strong) TTArticleInfoView * _Nonnull infoView;
@property (nonatomic, strong) TTADInfoView * _Nonnull adInfoView;
@property (nonatomic, strong) TTAlphaThemedButton * _Nonnull accessoryButton;
@property (nonatomic, strong) TTADActionView * _Nonnull adActionView;
@property (nonatomic, strong) SSThemedView * _Nonnull bottomLineView;
@property (nonatomic, strong) SSThemedView * _Nonnull bottomSepView;//视频频道底部分割线
@property (nonatomic, strong) SSThemedLabel * _Nonnull videoTitleLabel;
@property (nonatomic, strong) TTVideoCellActionBar * _Nonnull actionBar;
@property (nonatomic, strong) UIImageView * _Nonnull topMaskView;
@property (nonatomic, assign) BOOL isViewHighlighted;
@property (nonatomic, strong) ExploreItemActionManager * _Nonnull itemActionManager;
@property (nonatomic, strong) TTActivityShareManager * _Nonnull activityActionManager;
@property (nonatomic, strong) SSActivityView * _Nullable phoneShareView;
@property (nonatomic, strong) ExploreOrderedData * _Nullable orderedData;
@property (nonatomic, strong) ExploreOriginalData * _Nullable originalData;
@property (nonatomic) BOOL readPersistAD;
@property (nonatomic, strong) NSDictionary * _Nonnull extraDic;

- (void)updateFunctionView;
- (void)updateTitleView:(CGFloat)fontSize isAction:(BOOL)isAction;
- (void)updateTitleViewWithAction:(BOOL)isAction;
- (void)updateTitleView;
- (void)updatePicView;
- (void)updateSourceView;
- (void)updateActionView;
- (void)updateInfoView;
- (void)updateADInfoView;
- (void)updateADActionView;
- (void)updateBottomLineView;
- (void)updateVideoTitleLabel;
- (void)updateTopMaskView;
- (void)layoutMoreView;
- (void)updateActionBar;

+ (CGFloat)preferredContentTextSize;

- (void)accessoryButtonClicked:(id _Nullable)sender;
- (void)downloadButtonActionFired:(id _Nullable)sender;

- (void)showMenu;

@end

@interface TTADBaseCell (TTAdCellLayoutInfo) <TTAdCellLayoutInfo>
- (nonnull NSDictionary *)adCellLayoutInfo;
@end
