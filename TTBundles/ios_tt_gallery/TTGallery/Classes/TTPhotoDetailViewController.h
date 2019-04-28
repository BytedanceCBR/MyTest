//
//  TTPhotoDetailViewController.h
//  Article
//
//  Created by yuxin on 4/18/16.
//
//

#import "SSViewControllerBase.h"
#import "TTDetailViewController.h"
#import "TTPhotoNativeDetailView.h"
#import "TTDetailWebviewContainer.h"
#import "ExploreDetailToolbarView.h"
#import "ExploreDetailNavigationBar.h"
#import "TTPhotoCommentViewController.h"
#import "TTPhotoDetailTracker.h"
#import "ExploreDetailNavigationBar.h"
#import "TTActivity.h"
#import "SSActivityView.h"
#import "TTActivityShareManager.h"
#import "TTActionSheetController.h"
#import "TTPhotoDetailViewModel.h"
#import "TTPhotoNewCommentViewController.h"
#import "TTModalContainerController.h"

@protocol TTPhotoDetailViewContainerDelegate <NSObject>

- (void)ttPhotoDetailViewBackBtnClick;

@end


@interface TTPhotoDetailViewController : SSViewControllerBase <TTDetailViewController,SSActivityViewDelegate>

//评论VC
@property (nonatomic, strong) TTPhotoCommentViewController * commentViewController;
@property (nonatomic,strong) TTModalContainerController *modalContainerController;
//底部的toobar
@property (nonatomic, strong, readwrite) ExploreDetailToolbarView * toolbarView;

//顶部的topbar
@property (nonatomic, strong) ExploreDetailNavigationBar * topView;
@property (nonatomic, strong) CAGradientLayer *topViewGradLayer;//顶部导航的渐变图层

//传入的DetailModel
@property (nonatomic, strong, readonly) TTDetailModel *detailModel;

//本VC的VM，主要处理了info接口数据请求
@property (nonatomic, strong) TTPhotoDetailViewModel * viewModel;

//native和web图集的view
@property (nonatomic, strong) TTDetailWebviewContainer * webContainer;
@property (nonatomic, strong) TTPhotoNativeDetailView * nativeDetailView;
@property (nonatomic, assign, readonly) BOOL isShowingRelated;

//分享的panelview 和分享manager
@property (nonatomic, strong) TTActivityShareManager * activityActionManager;
@property (nonatomic, strong) SSActivityView * moreSettingActivityView;
@property (nonatomic, strong) SSActivityView * phoneShareView;

//统计tracker
@property(nonatomic, strong, readonly) TTPhotoDetailTracker *tracker;

//web图集的阅读位置，为统计提供
@property (nonatomic, assign, readonly) NSInteger showedCountOfImage;
@property (nonatomic, assign, readonly) NSInteger currentShowedImageIndex;

//新图集交互手势代理
@property (nonatomic,weak)  id<TTPhotoDetailViewContainerDelegate>  containerDelegate;

/**
 *  图集长按弹出后点击分享单张图片界面
 */
@property (nonatomic, strong) SSActivityView * currentGalleryShareView;
@property (nonatomic, assign) TTShareSourceObjectType shareSourceType;

// 图集当前展示的gallery url
@property (nonatomic, copy  ) NSString       *currentGalleryUrl;
// 图集当前的点击状态，只读
@property (nonatomic, assign, readonly) BOOL tapOn;

// 图集当前是否在上下滑退出过程中
@property (nonatomic, assign, readwrite) BOOL isInVertiMoveGesture;

// 统计点返回按钮返回or手势返回
@property (nonatomic, assign) BOOL backButtonTouched;

@property (nonatomic, strong) TTActionSheetController *actionSheetController;

@property (nonatomic, assign) BOOL hasCommentVCAppear;

//统计评论显示时长
@property (nonatomic,assign) double commentShowTimeTotal;
@property (nonatomic,strong) NSDate *commentShowDate;

//init方法 入参是 TTDetailModel
- (instancetype)initWithDetailViewModel:(TTDetailModel *)model;

- (BOOL)shouldShowAvatarView;

- (NSUInteger)maximumVisibleIndex;
- (NSUInteger)currentVisibleIndex;

//判断是否应该加载原生图集
- (BOOL)shouldLoadNativeGallery;

@end
