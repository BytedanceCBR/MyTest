//
//  TTLayOutCellViewBase.h
//  Article
//
//  Created by 王双华 on 16/10/13.
//
//

// 头像在上和在下（未来包括话题），无图、右图、组图、大图的UI控件以及更新数据的基类

#import "ExploreCellViewBase.h"
#import "TTActionPopView.h"
#import "SSActivityView.h"
#import "SSThemed.h"
#import "ExploreArticleCellCommentView.h"
#import "TTArticleCommentView.h"
#import "ExploreArticleCellEntityWords.h"
#import "TTArticlePicView.h"
#import "TTDiggButton.h"
#import "TTImageView.h"
#import "TTAlphaThemedButton.h"
#import "TTHighlightedLabel.h"
#import "ExploreActionButton.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "TTVideoEmbededAdButton.h"
#import "SSPGCActionManager.h"
#import "ExploreArticleMovieViewDelegate.h"
#import "TTLayOutCellDataHelper.h"
#import "TTRoute.h"
#import "TTUISettingHelper.h"
#import "TTImageView.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "TTActionPopView.h"
#import "ExploreEntry.h"
#import "ExploreEntryManager.h"
#import "ExploreEntryDefines.h"
#import "TTIndicatorView.h"
#import "ArticleShareManager.h"
#import "TTActivityShareManager.h"
#import "ArticleShareManager.h"
#import "ExploreMixListDefine.h"
#import "ExploreItemActionManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTLabelTextHelper.h"
#import "ExploreCellHelper.h"
#import "NSObject+FBKVOController.h"
#import "SSMotionRender.h"
#import "TTActionSheetController.h"
#import "TTReportManager.h"
#import "Comment.h"
#import "TTFollowThemeButton.h"
#import "TTUGCAttributedLabel.h"
#import "TTlayoutLoopInnerPicView.h"
#import "TTLayOutCellBaseModel.h"

@class ExploreItemActionManager;

@interface TTLayOutCellViewBase : ExploreCellViewBase<SSActivityViewDelegate,TTDislikePopViewDelegate>

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) ExploreOriginalData *originalData;

@property (nonatomic, strong) SSThemedLabel             *titleLabel;        //标题
@property (nonatomic, strong) TTArticlePicView          *picView;           //图片
@property (nonatomic, strong) TTAsyncCornerImageView    *sourceImageView;   //来源头像
@property (nonatomic, strong) SSThemedLabel             *sourceLabel;       //来源名称
@property (nonatomic, strong) SSThemedLabel             *infoLabel;         //信息
@property (nonatomic, strong) SSThemedLabel             *liveTextLabel;     //直播标签
@property (nonatomic, strong) SSThemedLabel             *typeLabel;         //类型标签
@property (nonatomic, strong) TTAlphaThemedButton       *digButton;         //点赞按钮
@property (nonatomic, strong) TTAlphaThemedButton       *commentButton;     //评论按钮
@property (nonatomic, strong) TTAlphaThemedButton       *forwardButton;     //转发按钮
@property (nonatomic, strong) SSThemedButton            *unInterestedButton; //不感兴趣
@property (nonatomic, strong) SSThemedLabel             *abstractLabel;     //摘要
@property (nonatomic, strong) TTHighlightedLabel        *commentLabel;      //评论
@property (nonatomic, strong) TTUGCAttributedLabel      *commentAttrLabel;  //带...全文的评论
@property (nonatomic, strong) SSThemedView              *backgroundView;    //背景
@property (nonatomic, strong) SSThemedView              *separatorView;     //竖向分割线
@property (nonatomic, strong) TTFollowThemeButton       *subscribeButton;   //关注按钮
@property (nonatomic, strong) SSThemedView              *topRect;           //顶部10pi分隔条
@property (nonatomic, strong) SSThemedView              *bottomRect;        //底部10pi分割条
@property (nonatomic, strong) SSThemedView              *bottomLineView;    //底部分割线
@property (nonatomic, strong) SSThemedLabel             *subTitleLabel;     //副标题
@property (nonatomic, strong) TTArticleCellEntityWordView *entityWordView;  //添加关注实体词
@property (nonatomic, strong) SSThemedButton            *wenDaButton;      //问答按钮 不可点击

@property (nonatomic, strong) SSThemedView              *adBackgroundView;  //广告view背景
@property (nonatomic, strong) TTVideoEmbededAdButton    *adButton;          //广告标识
@property (nonatomic, strong) ExploreActionButton       *actionButton;      //广告按钮
@property (nonatomic, strong) SSThemedLabel             *adSubtitleLabel;   //广告来源信息
@property (nonatomic, strong) SSThemedImageView         *adLocationIcon;    //广告位置icon
@property (nonatomic, strong) SSThemedLabel             *adLocationLabel;   //广告位置信息

@property (nonatomic, strong) TTlayoutLoopInnerPicView  *adInnerLoopPicView;


- (void)layoutDigButton;
- (void)layoutCommentButton;
- (void)layoutSubscribeButton;
- (void)layoutInfoLabel;

@property (nonatomic, strong) ExploreArticleMovieViewDelegate   *movieViewDelegate;
@property (nonatomic, strong) NSDictionary                      *extraDic;
@property (nonatomic, strong) NSDictionary                      *extraDicForUFCell;
@property (nonatomic, strong) TTActionSheetController           *actionSheetController;
@property (nonatomic, strong) SSActivityView                    *phoneShareView;    //分享弹窗
@property (nonatomic, strong) TTActivityShareManager            *activityActionManager;
@property (nonatomic, strong) ExploreItemActionManager          *itemActionManager;

- (void)bringAdButtonBackToCell;
//- (void)bringAdButtonToMovie;

- (void)layoutComponents;
- (void)layoutCommentLabel;
- (void)updateContentColor;

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords onlyOne:(BOOL)onlyOne;
- (void)sourceImageClick;
- (void)addKVOForArticleCell;
- (void)removeKVOForArticleCell;
- (void)calculateFrameAndRefreshUI;
- (void)trackForU11CellShowInList;
- (NSUInteger)refer;

// 广告需要获取当前 cell 的布局信息
- (nullable NSDictionary *)adCellLayoutInfo;
@end
