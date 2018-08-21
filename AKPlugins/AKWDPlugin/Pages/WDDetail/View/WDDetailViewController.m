//
//  WDDetailViewController.m
//  Article
//
//  Created by 延晋 张 on 16/4/11.
//
//  问答详情页VC。创建所需View并根据展示需求进行装配、调度

#import "WDDetailViewController.h"
#import "WDBottomToolView.h"
#import "WDNewDetailTitleView.h"
#import "WDDetailModel.h"
#import "WDServiceHelper.h"
#import "WDAnswerService.h"
#import "WDMonitorManager.h"
#import "WDSettingHelper.h"
#import "WDDetailHeaderView.h"
#import "WDNewDetailHeaderView.h"
#import "WDDetailView.h"
#import "WDDefines.h"
#import "WDDetailViewModel.h"
#import "WDDetailNatantViewModel.h"
#import "WDDetailNatantViewModel+ShareCategory.h"
#import "WDParseHelper.h"
#import "WDAnswerEntity.h"
#import "WDCommonLogic.h"
#import "WDNewsHelpView.h"
#import "WDShareUtilsHelper.h"
#import "WDDetailNatantViewBase.h"
#import "WDDetailNatantContainerView.h"
#import "WDTrackerHelper.h"
#import "HPGrowingTextView.h"
#import "WDUIHelper.h"
#import "TTDetailWebviewContainer.h"
#import "TTAdPromotionManager.h"
#import "WDAdapterSetting.h"

#import "TTDetailViewController.h"
#import "TTRoute.h"
#import "SSWebViewBackButtonView.h"
#import "TTAuthorizeManager.h"
#import "TTLabelTextHelper.h"
#import "TTIndicatorView.h"
#import "UIButton+TTAdditions.h"
#import "TTNavigationController.h"
#import "UIViewController+Track.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIViewController+NavigationBarStyle.h"
#import "NSObject+FBKVOController.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import "UIImage+TTThemeExtension.h"
#import <AKCommentPlugin/TTCommentViewControllerProtocol.h>
#import <AKCommentPlugin/TTCommentModelProtocol.h>
#import <AKCommentPlugin/TTCommentDataManager.h>
#import <AKCommentPlugin/TTCommentWriteView.h>
#import <TTShare/TTShareManager.h>
#import <TTThemed/TTThemeManager.h>
#import <TTUIWidget/TTViewWrapper.h>
#import <Crashlytics/Crashlytics.h>
#import <TTNewsAccountBusiness/TTAccountBusiness.h>
#import <TTImagePreviewAnimateManager/TTInteractExitHelper.h>
#import <TTBaseLib/UITextView+TTAdditions.h>
#import <TTFriendRelation/TTFollowThemeButton.h>
#import <TTFriendRelation/TTFollowManager.h>
#import <TTPlatformUIModel/TTBubbleView.h>
#import <TTImpression/TTRelevantDurationTracker.h>
#import <TTVideoService/TTFFantasyTracker.h>


extern NSInteger const kWDPostCommentBindingErrorCode;
static NSString * const kHasShownComentPolicyIndicatorViewKey = @"HasShownComentPolicyIndicatorViewKey";
static NSUInteger const kOldAnimationViewTag = 20161221;

@interface WDDetailViewController () <TTDetailViewController, WDDetailViewDelegate, TTCommentDataSource, TTCommentViewControllerDelegate, TTCommentWriteManagerDelegate, UIViewControllerErrorHandler, TTUIViewControllerTrackProtocol, UIActionSheetDelegate, WDBottomToolViewDelegate, TTShareManagerDelegate, TTInteractExitProtocol, WDDetailHeaderViewDelegate>
{
    BOOL _backButtonTouched;
    BOOL _closeButtonTouched;
    BOOL _hiddenByDisplayImage;
    BOOL _hasSendEnterCommentTrack;
    BOOL _hasSendFinishCommentTrack;
    BOOL _hasSendReadContentTrack;
    BOOL _hasSendFinishContentTrack;
    BOOL _webViewWillChangeFontSize;
    BOOL _isCommentViewWillShow;
    BOOL _headerViewAnswerButtonShowed;
    BOOL _headerViewGoodAnswerButtonShowed;
    BOOL _headerViewPulled;
}

@property (nonatomic, strong) TTViewWrapper *wrapperView;
@property (nonatomic, strong) UIViewController<TTCommentViewControllerProtocol> *commentViewController;

@property (nonatomic, strong) WDDetailNatantContainerView *natantContainerView;
@property (nonatomic, strong) TTAlphaThemedButton *rightBarButtonItemView;
@property (nonatomic, strong) TTFollowThemeButton *rightFollowButton;

@property (nonatomic, strong) SSThemedImageView *logoTitleView;
@property (nonatomic, strong) WDNewDetailTitleView *profileTitleView;
@property (nonatomic, strong) UIView<WDDetailHeaderView> *headerView;
@property (nonatomic, strong) WDDetailView *detailView;
@property (nonatomic, strong) SSThemedView *whiteGapView; // iPad适配专用顶部白底View，配合wrapperView

@property (nonatomic, strong) SSWebViewBackButtonView *backButtonView;

@property (nonatomic, strong) WDNewsHelpView *sliderHelpView;
@property (nonatomic, strong) WDBottomToolView *toolbarView;
@property (nonatomic, strong) TTBubbleView *bubbleView;

@property (nonatomic, strong) TTCommentWriteView *commentWriteView;

@property (nonatomic, strong) WDDetailModel *detailModel;
@property (nonatomic, strong) WDDetailNatantViewModel *natantViewModel;

@property (nonatomic, strong) DetailActionRequestManager *actionManager;

@property (nonatomic, strong) TTShareManager *shareManager;

@property (nonatomic, assign) CGFloat enterHalfFooterStatusContentOffset;

@property (nonatomic, assign) BOOL wasTitleViewShowed;

@property (nonatomic, assign) BOOL infoLoadFinished;
@property (nonatomic, assign) BOOL infoLoadFailed;

@property (nonatomic, strong) TTIndicatorView *indictorView;
@property (nonatomic, strong) TTIndicatorView *actionIndicator;

@property (nonatomic, assign) NSInteger showSlideType;
@property (nonatomic, assign) BOOL isNewVersion;
@property (nonatomic, assign) BOOL hasEndDisplay;
@property (nonatomic, assign) BOOL isViewDisplaying;
@property (nonatomic, assign) BOOL isNeedCommentTrack;
@property (nonatomic, assign) BOOL isInfoContentFetching;
@property (nonatomic, assign) BOOL hasDisappear;
@property (nonatomic, assign) BOOL hasAppear;

@property (nonatomic, assign) BOOL hasTrackRedPacketShowEvent;

@property (nonatomic,assign) double commentShowTimeTotal;
@property (nonatomic,strong) NSDate *commentShowDate;

@end

@implementation WDDetailViewController

@synthesize leftBarButton;
@synthesize rightBarButtons;
@synthesize dataSource;
@synthesize delegate;

- (instancetype)initWithDetailViewModel:(WDDetailModel *)model
{
    //create detailView
    self = [super initWithNibName:nil bundle:nil];
    if (self) {

        _detailModel = model;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusbarFrameDidChangeNotification)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidBecomeActiveNotification)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
                
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
        [dict setValue:@"enter" forKey:@"label"];
        [dict setValue:model.answerEntity.ansid forKey:@"value"];
        [self sendTrackWithDict:dict];
        
        //go detail

        NSMutableDictionary * goDetailDict = [NSMutableDictionary dictionaryWithDictionary:model.gdExtJsonDict];
        [goDetailDict setValue:@"go_detail" forKey:@"tag"];
        [goDetailDict setValue:[self enterFrom] forKey:@"label"];
        [goDetailDict setValue:model.answerEntity.ansid forKey:@"value"];
        [goDetailDict setValue:@"umeng" forKey:@"category"];
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker eventData:goDetailDict];
        }
        
        //Wenda_V3_DoubleSending
        NSMutableDictionary *v3Dic = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
        [v3Dic setValue:model.answerEntity.ansid forKey:@"group_id"];
        [v3Dic setValue:model.answerEntity.ansid forKey:@"ansid"];
        [v3Dic setValue:model.answerEntity.qid forKey:@"qid"];
        
//        [TTTrackerWrapper eventV3:@"go_detail" params:v3Dic isDoubleSending:YES];
        
        if (!isEmptyString(model.answerEntity.ansid)) {
            [TTFFantasyTracker sharedInstance].lastGid = model.answerEntity.ansid;
        }
    }
    return self;
}

- (instancetype)initWithDetailModel:(WDDetailModel *)detailModel {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        _detailModel = detailModel;
        
        _isNewVersion = YES;
        _showSlideType = [[WDSettingHelper sharedInstance_tt] wdAnswerDetailShowSlideType];
        
        [self p_setDetailViewBars];
        
    }
    return self;
    
}

- (void)detailContainerViewController:(SSViewControllerBase *)container reloadData:(WDDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    if (self.detailView) return;
    
    [self p_buildViews];
    [self.detailView tt_initializeServerRequestMonitorWithName:WDDetailInfoTimeService];
    [self p_startLoadArticleInfo];
    [self p_updateNavigationTitleView];
    
    WeakSelf;
    [self.KVOController observe:self.natantViewModel keyPath:@"isShowDeleteAnswer" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        if (self.natantViewModel.isShowDeleteAnswer) {
            self.natantViewModel.isShowDeleteAnswer = NO;
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确认删除此回答？删除后无法恢复" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除回答" otherButtonTitles:nil, nil];
            [sheet showInView:self.view];
        }
    }];
}

- (void)detailContainerViewController:(nullable SSViewControllerBase *)container loadContentFailed:(nullable NSError *)error
{
    [self tt_endUpdataData];
}

#pragma mark - life circle

- (void)dealloc
{
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self p_sendDetailDeallocTrack];
    [self p_sendDetailLoadTimeOffLeaveTrack];
    
    NSString *originEtag = _detailModel.answerEntity.detailWendaExtra[@"etag"];
    if (!originEtag || ![originEtag isEqualToString:_natantViewModel.etag]) {
        [_detailModel.answerEntity deleteObject];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isCommentViewWillShow = NO;
    self.infoLoadFinished = NO;
    self.infoLoadFailed = NO;
    
    if (!_isNewVersion && _detailModel.isArticleReliable) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
        [self detailContainerViewController:nil reloadData:self.detailModel];
#pragma clang diagnostic pop
    }
    
    self.ttTrackStayEnable = YES;
    [self p_setupMenuItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self p_showSlideHelperViewIfNeeded];
    
    if (_isNewVersion) return;
    
    [self.detailView willAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_isNewVersion) {
        if (self.showSlideType == AnswerDetailShowSlideTypeBlueHeaderWithHint) {
            if (![TTDeviceHelper isPadDevice]) {
                if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                    BOOL isDefault = [[WDSettingHelper sharedInstance_tt] wdDetailStatusBarStyleIsDefault];
                    if (isDefault) {
                        self.ttStatusBarStyle = UIStatusBarStyleDefault;
                        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                    }
                    else {
                        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
                        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                    }
                }
            }
        }
        return;
    }
    
    if (self.natantContainerView.contentOffsetWhenLeave!=NSNotFound) {
        [self.natantContainerView checkVisibleAtContentOffset:self.natantContainerView.contentOffsetWhenLeave
                                              referViewHeight:self.commentViewController.view.frame.size.height];
    }
    
    if (!self.hasAppear) {
        self.hasAppear = YES;
        [self p_hideHeaderIfNeeded];
    }
    [self p_showPolicyIndicatorViewIfNeeded];
    
    [self.detailView didAppear];
    
    _hasDisappear = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.toolbarView showSupportsEmojiInputBubbleViewIfNeeded];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isNewVersion) return;
    
    [self p_removeIndicatorPolicyView];
    
    [self.detailView willDisappear];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
    
    if (_isNewVersion) return;
    
    if (_hasDisappear) return;
    _hasDisappear = YES;
    
    [self trySendCurrentPageStayTime];

    [self.natantContainerView resetAllRelatedItemsWhenNatantDisappear];
    [self.detailView didDisappear];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat natantWidth = [TTUIResponderHelper splitViewFrameForView:self.view].size.width;
        self.natantContainerView.width = natantWidth;
        [self.natantContainerView.items enumerateObjectsUsingBlock:^(WDDetailNatantViewBase * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WDDetailNatantViewBase * natantViewItem = (WDDetailNatantViewBase *)obj;
            natantViewItem.width = natantWidth-30;
        }];
        // 文章页有
        self.commentViewController.commentTableView.tableHeaderView = self.natantContainerView;
        if (!_isNewVersion) {
            self.toolbarView.frame = [self p_frameForToolBarView];
            [self.toolbarView layoutIfNeeded];
        }
    }
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    self.detailView.frame = [self p_frameForDetailView];
    if (!_isNewVersion) {
        self.toolbarView.frame = [self p_frameForToolBarView];
        [self.toolbarView layoutIfNeeded];
    }
}

- (TTShareManager *)shareManager {
    if (nil == _shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return  _shareManager;
}

#pragma mark - public

- (void)viewStartDisplay {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_detailModel.gdExtJsonDict];
    [dict setValue:@"enter" forKey:@"label"];
    [dict setValue:_detailModel.answerEntity.ansid forKey:@"value"];
    [self sendTrackWithDict:dict];
    
    //go detail
    NSMutableDictionary *goDetailDict = [NSMutableDictionary dictionaryWithDictionary:_detailModel.gdExtJsonDict];
    [goDetailDict setValue:@"go_detail" forKey:@"tag"];
    [goDetailDict setValue:[self enterFrom] forKey:@"label"];
    [goDetailDict setValue:_detailModel.answerEntity.ansid forKey:@"value"];
    [goDetailDict setValue:@"umeng" forKey:@"category"];
    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        [TTTracker eventData:goDetailDict];
    }
    
    
    //Wenda_V3_DoubleSending
    NSMutableDictionary *v3Dic = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    [v3Dic setValue:_detailModel.answerEntity.ansid forKey:@"group_id"];
    [v3Dic setValue:_detailModel.answerEntity.ansid forKey:@"ansid"];
    [v3Dic setValue:_detailModel.answerEntity.qid forKey:@"qid"];
//    [TTTrackerWrapper eventV3:@"go_detail" params:v3Dic isDoubleSending:YES];
    
    self.isViewDisplaying = YES;
    
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
    
    [self.detailView willAppear];
    
    if (self.natantContainerView.contentOffsetWhenLeave!=NSNotFound) {
        [self.natantContainerView checkVisibleAtContentOffset:self.natantContainerView.contentOffsetWhenLeave
                                              referViewHeight:self.commentViewController.view.frame.size.height];
    }
    
    [self p_showPolicyIndicatorViewIfNeeded];
    
    [self.detailView didAppear];
    
    if (self.isNeedCommentTrack) {
        [self tt_WDDetailViewWillShowFirstCommentCell];
    }
    
    _hasEndDisplay = NO;
}

- (void)viewEndDisplay {
    
    if (_hasEndDisplay) return;
    _hasEndDisplay = YES;
    
    self.isViewDisplaying = NO;
    
    self.ttTrackStayTime = [[NSDate date] timeIntervalSince1970] - self.ttTrackStartTime;
    
    [self p_removeIndicatorPolicyView];
    [self trySendCurrentPageStayTime];
    
    [self.detailView willDisappear];
    
    [self.natantContainerView resetAllRelatedItemsWhenNatantDisappear];
    [self.detailView didDisappear];
}

- (void)viewWillDisappear {
    
    self.ttTrackStayTime = [[NSDate date] timeIntervalSince1970] - self.ttTrackStartTime;
    
    [self p_removeIndicatorPolicyView];
    [self trySendCurrentPageStayTime];
    
    [self.detailView willDisappear];
}

- (void)viewDidDisappear {

    [self.natantContainerView resetAllRelatedItemsWhenNatantDisappear];
    [self.detailView didDisappear];
}

- (void)viewWillReappear {
    [self.detailView willAppear];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidReappear {
    if (self.natantContainerView.contentOffsetWhenLeave!=NSNotFound) {
        [self.natantContainerView checkVisibleAtContentOffset:self.natantContainerView.contentOffsetWhenLeave
                                              referViewHeight:self.commentViewController.view.frame.size.height];
    }
    
    [self.detailView didAppear];
}

- (void)reloadData {
    [self p_buildViews];
    [self.detailView tt_initializeServerRequestMonitorWithName:WDDetailInfoTimeService];

    WeakSelf;
    [self.KVOController observe:self.natantViewModel keyPath:@"isShowDeleteAnswer" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        if (self.natantViewModel.isShowDeleteAnswer) {
            self.natantViewModel.isShowDeleteAnswer = NO;
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"确认删除此回答？删除后无法恢复" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除回答" otherButtonTitles:nil, nil];
            [sheet showInView:self.view];
        }
    }];
}

- (void)viewEnterBackground {
    [self trySendCurrentPageStayTime];
}

- (void)viewEnterForeground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)loadInfomationIfNeeded {
    if (!self.natantContainerView) {
        [self p_buildDetailNatant];
    }
    if (!self.infoLoadFinished) {
        [self p_startLoadArticleInfo];
    }
}

- (void)commentCountButtonTapped {
    [self p_willShowComment];
}

- (void)sendCommentWithContent:(NSString *)content replyCommentID:(NSString *)replyCommentID replyUserID:(NSString *)replyUserID finishBlock:(void (^)(NSError *))finishBlock {
    [self.commentViewController tt_sendCommentWithContent:content replyCommentID:replyCommentID replyUserID:replyUserID finishBlock:^(NSError *error) {
        self.commentViewController.hasSelfShown = YES;
        if(!error)  {
            if ([self.detailView.detailWebView isNewWebviewContainer]) {
                [self.detailView.detailWebView openFirstCommentIfNeed];
            } else {
                [self.commentViewController tt_commentTableViewScrollToTop];
                if (![self.detailView.detailWebView isNatantViewOnOpenStatus]) {
                    [self.detailView.detailWebView openFooterView:NO];
                }
            }
        }
        if (finishBlock) {
            finishBlock(error);
        }
    }];
}

#pragma mark - private

- (void)p_hideHeaderIfNeeded
{
    if (self.headerView) {
        self.headerView.hidden = NO;
        if (self.detailModel.shouldHideHeader) {
            CGFloat minTop = kNavigationBarHeight - self.headerView.height;
            self.headerView.top = minTop;
            self.detailView.top = self.headerView.bottom;
        }
    }
}

- (void)p_buildViews
{
    [self p_buildMainView];
    if (!_isNewVersion) {
        [self p_buildDetailNatant];
        [self p_buildToolbarViewIfNeeded];
        [self p_setDetailViewBars];
        [self p_buildNaviBar];
    }
}

- (void)p_buildMainView
{
    if (!_isNewVersion && [TTDeviceHelper isPadDevice]) {
        self.wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [self p_buildHeaderViewIfNeed];
        [self p_buildDetailView];
        self.wrapperView.targetView = self.detailView;
        [self.view addSubview:self.wrapperView];
        [self.view addSubview:self.whiteGapView];
        [self.view addSubview:self.detailView];
        [self.view addSubview:self.headerView];
    } else {
        [self p_buildHeaderViewIfNeed];
        [self p_buildDetailView];
        [self.view addSubview:self.detailView];
        [self.view addSubview:self.headerView];
    }
    
    self.headerView.frame = [self p_frameForHeaderView];
    [self.detailView willAppear];
    self.detailView.frame = [self p_frameForDetailView];
    [self p_addDetailViewKVO];
    
    [self.detailView.detailWebView.webView becomeFirstResponder];
}

- (void)p_buildHeaderViewIfNeed {
    if (self.isNewVersion) {
        return;
    }
    if (self.headerView) {
        return;
    }
    if (self.detailModel.answerEntity.answerDeleted) {
        // 问题或者回答被删除，只显示错误页面
        return;
    }
    Class headerViewClass = [WDDetailHeaderView class];
//    if ([WDSettingHelper sharedInstance_tt].wendaDetailHeaderViewStyle == WDDetailHeaderViewStyleNew) {
//        headerViewClass = [WDNewDetailHeaderView class];
//    } else {
//        headerViewClass = [WDDetailHeaderView class];
//    }
    self.headerView = [[headerViewClass alloc] initWithFrame:[self p_frameForHeaderView] detailModel:self.detailModel];
    self.headerView.hidden = YES;
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerView.delegate = self;
}

- (void)p_buildDetailView {
    self.detailView = [[WDDetailView alloc] initWithFrame:[self p_frameForDetailView] detailModel:self.detailModel];
    self.detailView.isNewVersion = self.isNewVersion;
    self.detailView.tag = kOldAnimationViewTag;
    self.detailView.delegate = self;
    self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)p_buildDetailNatant
{
    if (self.detailModel.answerEntity.answerDeleted) {
        return;
    }
    
    [self p_buildNatantView];
    [self p_buildCommentViewController];
}

- (void)p_buildTitleView
{
    self.profileTitleView = [[WDNewDetailTitleView alloc] initWithFrame:CGRectZero];
    [self.navigationItem setTitleView:self.profileTitleView];
    WeakSelf;
    [self.profileTitleView setTapHandler:^{
        StrongSelf;
        [WDServiceHelper openProfileForUserID:[self.detailModel.answerEntity.user.userID longLongValue]];
    }];
    
    [self.KVOController observe:self.detailModel.answerEntity.user keyPath:NSStringFromSelector(@selector(followerCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self.profileTitleView updateNavigationTitle:self.detailModel.answerEntity.user.name imageURL:self.detailModel.answerEntity.user.avatarURLString verifyInfo:self.detailModel.answerEntity.user.userAuthInfo decoration:self.detailModel.answerEntity.user.userDecoration fansNum:self.detailModel.answerEntity.user.followerCount];
    }];
    
//    SSThemedImageView *imageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
//    imageView.imageName = @"wukonglogo_ask_bar";
//    [imageView sizeToFit];
//    imageView.userInteractionEnabled = YES;
//    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewTaped:)]];
//    self.logoTitleView = imageView;
//    self.navigationItem.titleView = imageView;
}

- (void)p_buildNaviBar
{
    if (!self.backButtonView) {
        self.backButtonView = [[SSWebViewBackButtonView alloc] init];
    }
    [self.backButtonView.backButton addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButtonView.closeButton addTarget:self action:@selector(leftBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButtonView showCloseButton:NO];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButtonView];
    
    if ([self.detailModel.answerEntity answerDeleted]) {
        // 回答删除，只隐藏右侧的更多按钮，返回按钮保留
        self.navigationItem.rightBarButtonItems = nil;
        return;
    }
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    _rightBarButtonItemView = [self p_generateBarButtonWithImageName:@"new_more_titlebar"];
    [_rightBarButtonItemView addTarget:self action:@selector(p_showSharePanel) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat padding = 16.0f;
    if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) {
        padding = 0.0;
    }
    SSThemedView *view = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.rightFollowButton.width + [TTDeviceUIUtils tt_newPadding:padding], self.rightFollowButton.height)];
    self.rightFollowButton.centerX = view.width / 2;
    [view addSubview:self.rightFollowButton];

    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:_rightBarButtonItemView]];
    if (![[TTAccountManager userID] isEqualToString:[self.detailModel.answerEntity.user userID]]) {
        [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:view]];
    }
    
    self.navigationItem.rightBarButtonItems = buttons;
}

- (void)titleViewTaped:(UITapGestureRecognizer *)gesture
{
    NSString *urlString = [WDCommonLogic wukongURL];
    if (!isEmptyString(urlString) && [NSURL URLWithString:urlString]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:urlString] userInfo:nil];
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    if (parent) {
        [self p_buildTitleView];
    }
}

- (void)p_showChangePageAlert
{
    if (_isNewVersion) return;
    if (self.detailModel.showToast) {
        self.indictorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"进入折叠回答区" indicatorImage:nil dismissHandler:nil];
        [self.indictorView showFromParentView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.indictorView dismissFromParentView];
        });
    }
}

- (void)p_updateNavigationTitleView
{
    [self.profileTitleView updateNavigationTitle:self.detailModel.answerEntity.user.name imageURL:self.detailModel.answerEntity.user.avatarURLString verifyInfo:self.detailModel.answerEntity.user.userAuthInfo decoration:self.detailModel.answerEntity.user.userDecoration fansNum:self.detailModel.answerEntity.user.followerCount];

    self.rightFollowButton.hidden = self.profileTitleView.isShow ? NO : YES;

    if (self.detailModel.redPack) {
        self.rightFollowButton.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.detailModel.redPack.button_style.integerValue defaultType:TTUnfollowedType201];
    } else {
        self.rightFollowButton.unfollowedType = TTUnfollowedType101;
    }
    
    CGPoint followButtonCenter = self.rightFollowButton.center;

    CGFloat width = self.rightFollowButton.width;
    [self.rightFollowButton refreshUI];
    if (width > self.rightFollowButton.width) {
        self.rightFollowButton.constWidth = kRedPacketFollowButtonWidth();
        [self.rightFollowButton refreshUI];
    }
    self.rightFollowButton.center = followButtonCenter;
}

- (void)p_preloadNextPage
{
    if (self.isNewVersion) {
        return;
    }
    // 稍后可以加下面一个判断代码
    if (!self.detailModel.hasNext) {
        return;
    }
    if (isEmptyString(self.detailModel.nextAnsid)) {
        return;
    }
    [self.natantViewModel tt_preloadNextWithAnswerID:self.detailModel.nextAnsid];
}

- (void)p_updateNavigationTitleViewWithScrollViewContentOffset:(CGFloat)offset
{
    BOOL show = offset > self.detailView.titleViewAnimationTriggerPosY;
    [self p_showTitle:show];
    self.wasTitleViewShowed = show;
}

- (void)p_showTitle:(BOOL)show
{
//    BOOL isShow = self.profileTitleView.isShow;
//    if (!self.hasTrackRedPacketShowEvent && show && self.detailModel.redPack) {
//        self.hasTrackRedPacketShowEvent = YES;
//        NSMutableDictionary *showEventExtraDic = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
//        [showEventExtraDic setValue:self.detailModel.answerEntity.user.userID forKey:@"user_id"];
//        [showEventExtraDic setValue:@"show" forKey:@"action_type"];
//        [showEventExtraDic setValue:@"answer_detail_top_banner" forKey:@"source"];
//        [showEventExtraDic setValue:@"detail" forKey:@"position"];
//        [TTTrackerWrapper eventV3:@"red_button" params:showEventExtraDic];
//    }
//    [self.profileTitleView show:show animated:YES];
//    self.rightFollowButton.hidden = !show;
//    if (show) {
//        self.navigationItem.titleView = self.profileTitleView;
//    }
//
//    if (show && !isShow) {
//        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
//        [extra setValue:self.detailModel.answerEntity.ansid forKey:@"item_id"];
//        [extra setValue:self.detailView.detailViewModel.person.userID forKey:@"user_id"];
//        [TTTracker event:kWDDetailViewControllerUMEventName label:@"show_titlebar_pgc" value:@(self.detailModel.answerEntity.ansid.longLongValue) extValue:nil extValue2:nil dict:extra];
//    }
}

- (void)p_buildToolbarViewIfNeeded
{
    if (self.toolbarView) {
        return;
    }
    
    self.toolbarView = [[WDBottomToolView alloc] initWithFrame:[self p_frameForToolBarView]];
    self.toolbarView.detailModel = self.detailModel;
    self.toolbarView.delegate = self;
    [self.view addSubview:self.toolbarView];
    self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.toolbarView.banEmojiInput = YES;
}

- (void)p_buildCommentViewController
{
    self.commentViewController = [[NSClassFromString(@"TTCommentViewController") alloc] initWithViewFrame:[self p_contentVisableRect] dataSource:self delegate:self];
    self.commentViewController.enableImpressionRecording = YES;
    [self.commentViewController willMoveToParentViewController:self];
    [self addChildViewController:self.commentViewController];
    [self.commentViewController didMoveToParentViewController:self];
    [self.detailView tt_initializeServerRequestMonitorWithName:WDDetailCommentTimeService];
}

- (void)p_buildNatantView
{
    self.natantContainerView = [[WDDetailNatantContainerView alloc] initWithFrame:CGRectMake(0, 0, [TTUIResponderHelper splitViewFrameForView:self.view].size.width, 0)];
}

- (void)p_startLoadArticleInfo
{
    if (self.isInfoContentFetching == YES) {
        return;
    }
    self.isInfoContentFetching = YES;
    [self tt_startUpdate];
    WeakSelf;
    [self.natantViewModel tt_startFetchInformationWithFinishBlock:^(WDDetailModel *detailModel, NSError *error) {
        StrongSelf;
        if (!error) {
            [self.detailView tt_serverRequestTimeMonitorWithName:WDDetailInfoTimeService error:error];
            
            self.infoLoadFinished = YES;
            [self.detailView tt_deleteArticleByInfoFetchedIfNeeded];
            [self p_showDeleteStyleIfNeeded];
            
            [self.detailView tt_loadInformationContent];
            
            [self p_updateNavigationTitleView];

            self.natantContainerView.items = [self.natantViewModel p_newItemsBuildInNatantWithDetailModel:self.detailModel relatedView:self.view];
            [self.natantContainerView reloadData:self.detailModel];
            
            //添加浮层到转码页组件TTDetailWebContainerView
            [self.detailView tt_setNatantWithFooterView:self.commentViewController.view
                              includingFooterScrollView:[self.commentViewController commentTableView]];
            // 获取到mediaInfo后更新titleView
            [self p_showChangePageAlert];
            if ([[WDSettingHelper sharedInstance_tt] isWenSwithOpen]) {
                [self p_preloadNextPage];
            }
            
            if (self.detailModel.showComment) {
                [self p_willShowComment];
            }
        } else {
            self.infoLoadFinished = NO;
            self.infoLoadFailed = YES;
        }
        self.isInfoContentFetching = NO;
        [self tt_endUpdataData:NO error:error];
    }];
}

- (void)p_showSlideHelperViewIfNeeded
{

    if(!_hiddenByDisplayImage && ![WDCommonLogic noNeedDisplaySlideHelp] && [WDCommonLogic showGestureTip]) {
        
        if (_isNewVersion) {
            if (_wdDelegate && [_wdDelegate respondsToSelector:@selector(wd_detailViewControllerShowSlideHelperView)]) {
                [_wdDelegate wd_detailViewControllerShowSlideHelperView];
            }
        }
        else {
            self.sliderHelpView = [[WDNewsHelpView alloc] initWithFrame:self.view.bounds];
            self.sliderHelpView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [self.sliderHelpView setImage:[UIImage themedImageNamed:@"slide.png"]];
            [self.sliderHelpView setText:NSLocalizedString(@"右滑返回", nil)];
            [self.view addSubview:self.sliderHelpView];
        }
        
        [WDCommonLogic increaseSlideDisplayHelp];
    }
    _hiddenByDisplayImage = NO;
}

- (void)p_showPolicyIndicatorViewIfNeeded
{
    if (!self.detailModel.answerEntity.answerDeleted && [[TTAccountManager userID] isEqualToString:self.detailView.detailViewModel.person.userID] && !self.detailModel.answerTips) {
        // 1.被删除不出
        // 2.非当前userID不出
        // 3.有惩戒名单提示不出
        // 4.出过不出
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kHasShownComentPolicyIndicatorViewKey]) {
            [self p_showIndicatorPolicyView];
        }
    }
}

- (void)p_showIndicatorPolicyView
{
    if (_wdDelegate && [_wdDelegate respondsToSelector:@selector(wd_detailViewControllerShowIndicatorPolicyView)]) {
        [_wdDelegate wd_detailViewControllerShowIndicatorPolicyView];
        return;
    }
    
    CGFloat originY = [TTDeviceHelper isIPhoneXDevice] ? 78.0f : 58.0f;
    CGPoint anchorPoint = CGPointMake(self.view.width - 25.0f, originY);
    NSString *imageName = @"detail_close_icon";
    TTBubbleView *bubbleView = [[TTBubbleView alloc] initWithAnchorPoint:anchorPoint imageName:imageName tipText:@"点此设置评论权限" attributedText:nil
                                                          arrowDirection:TTBubbleViewArrowUp lineHeight:0 viewType:1];
    [self.navigationController.view addSubview:bubbleView];
    
    WeakSelf;
    [bubbleView showTipWithAnimation:YES automaticHide:NO animationCompleteHandle:nil autoHideHandle:nil tapHandle:^{
        StrongSelf;
        [self p_removeIndicatorPolicyView];
    } closeHandle:^{
        StrongSelf;
        [self p_removeIndicatorPolicyView];
    }];
    self.bubbleView = bubbleView;

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHasShownComentPolicyIndicatorViewKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self p_removeIndicatorPolicyView];
    });
}

- (void)p_removeIndicatorPolicyView
{
    [self.bubbleView removeFromSuperview];
    self.bubbleView = nil;
}

- (void)p_setDetailViewBars {
    
    if (_isNewVersion) {
        self.ttHideNavigationBar = YES;
        self.ttNeedHideBottomLine = YES;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        return;
    }
    
    self.ttHideNavigationBar = NO;
    self.ttNeedHideBottomLine = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if (![[TTThemeManager sharedInstance_tt] viewControllerBasedStatusBarStyle]) {
        [[UIApplication sharedApplication] setStatusBarStyle:[TTThemeManager sharedInstance_tt].statusBarStyle animated:YES];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarStyle:[TTThemeManager sharedInstance_tt].statusBarStyle animated:YES];
        self.ttStatusBarStyle = [TTThemeManager sharedInstance_tt].statusBarStyle;
    }
}

- (CGRect)p_frameForHeaderView
{
    CGFloat yOffset = kNavigationBarHeight;
    if (yOffset < 64) {
        yOffset = 64;
    }
    if (!_isNewVersion && [TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        return CGRectMake(edgePadding, yOffset, windowSize.width - edgePadding*2, SSHeight(self.headerView));
    } else {
        return CGRectMake(0, yOffset, self.view.width, SSHeight(self.headerView));
    }
}

- (CGRect)p_frameForDetailView
{
    CGRect rect;
    CGFloat bottomHeight = _isNewVersion ? 0 : [self DetailGetToolbarHeight];
    CGFloat headerBottom = _isNewVersion ? 0 : self.headerView.bottom;
    
    if (!_isNewVersion && [TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        rect = CGRectMake(edgePadding, headerBottom, windowSize.width - edgePadding*2, SSHeight(self.view) - bottomHeight);
    } else {
        rect = CGRectMake(0, headerBottom, SSWidth(self.view), SSHeight(self.view) - bottomHeight);
    }
    
    return rect;
}

- (CGFloat)DetailGetToolbarHeight
{
    return ([TTDeviceHelper isPadDevice] ? 50 : self.view.tt_safeAreaInsets.bottom ? self.view.tt_safeAreaInsets.bottom + 44 : 44) + [TTDeviceHelper ssOnePixel];
}

- (CGRect)p_frameForToolBarView
{
    CGRect rect;
    CGFloat barHeight = [self DetailGetToolbarHeight];
    
    if (!_isNewVersion && [TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        rect = CGRectMake(0, self.view.height - barHeight, windowSize.width, barHeight);
    }
    else {
        rect = CGRectMake(0, self.view.height - barHeight, SSWidth(self.view), barHeight);
    }
    
    return rect;
}


//当前详情页可视范围标准rect(去掉顶部导航和底部toolbar)
- (CGRect)p_contentVisableRect
{
    //parentVC has UIRectEdgeNone property
    CGFloat visableHeight = [self p_frameForDetailView].size.height;
    return CGRectMake(0, 0.0f, [TTUIResponderHelper splitViewFrameForView:self.view].size.width, visableHeight);
}

- (void)p_addDetailViewKVO
{
    __weak typeof(self) wself = self;
    [self.KVOController observe:self.detailView.detailWebView keyPath:@"footerStatus" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        __strong typeof(wself) self = wself;
        int oType = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        int nType = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        if (oType != nType) {
            if ([self.detailView.detailWebView isNatantViewVisible]) {
                if ([self.detailView.detailWebView isCommentVisible]) {
                    [self p_sendEnterCommentTrack];
                }
                [self.commentViewController tt_sendShowStatusTrackForCommentShown:YES];
                self.commentShowDate = [NSDate date];
            } else {
                [self.commentViewController tt_sendShowStatusTrackForCommentShown:NO];
                if (self.commentShowDate) {
                    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
                    self.commentShowTimeTotal += timeInterval*1000;
                    self.commentShowDate = nil;
                }
            }
        }
        //浮层出现时，尝试发送评论列表的统计
        if (nType == TTDetailWebViewFooterStatusDisplayNotManual ||
            nType == TTDetailWebViewFooterStatusDisplayTotal) {
            self.commentViewController.hasSelfShown = YES;
            [self.commentViewController tt_sendShowTrackForVisibleCells];
        }
        else if (nType == TTDetailWebViewFooterStatusNoDisplay) {
            [self p_showTitle:self.wasTitleViewShowed];
        }
        else {
            self.commentViewController.hasSelfShown = NO;
        }
    }];
    
}

- (void)p_showCommentViewWithCondtions:(NSDictionary *)conditions switchToEmojiInput:(BOOL)switchToEmojiInput
{
    if (self.detailModel.answerEntity.banComment) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"该回答禁止评论" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        return;
    }

    NSString *fwID = self.detailModel.answerEntity.ansid;

    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
    double readPct = [self.detailView.detailWebView readPCTValue];
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    qualityModel.readPct = @(percent);
    qualityModel.stayTimeMs = @([self.dataSource stayPageTimeInterValForDetailView:self]);

    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:conditions commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fwID;
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:qualityModel];

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];

    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;

    // writeCommentView 禁表情
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        self.commentWriteView.banEmojiInput = self.commentViewController.tt_banEmojiInput;
    }

    if ([self.commentViewController respondsToSelector:@selector(tt_writeCommentViewPlaceholder)]) {
        [self.commentWriteView setTextViewPlaceholder:self.commentViewController.tt_writeCommentViewPlaceholder];
    }

    [self.commentWriteView showInView:self.view animated:YES];
}

- (BOOL)banEmojiInput
{
    return YES;
    
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        return self.commentViewController.tt_banEmojiInput;
    }
    
    return NO;
}

- (NSString *)writeCommentViewPlaceholder
{
    if ([self.commentViewController respondsToSelector:@selector(tt_writeCommentViewPlaceholder)]) {
        return self.commentViewController.tt_writeCommentViewPlaceholder;
    }

    return kCommentInputPlaceHolder;
}

- (void)p_showDeleteStyleIfNeeded
{
    if (self.detailModel.answerEntity.answerDeleted) {
        [self.headerView removeFromSuperview];
        [self.detailView removeFromSuperview];
        [self.natantContainerView removeFromSuperview];
        [self.commentViewController removeFromParentViewController];
        [self.commentViewController.view removeFromSuperview];
        [self.toolbarView removeFromSuperview];
        self.parentViewController.navigationItem.titleView = nil;
        self.navigationItem.rightBarButtonItems = nil;
        self.profileTitleView = nil;
    }
}

- (void)p_tryNextAnswer
{
    if (self.detailModel.hasNext && [NSURL URLWithString:self.detailModel.nextAnswerSchema]) {
        WDAnswerEntity *entity = [WDAnswerEntity generateAnswerEntityFromAnsid:self.detailModel.nextAnsid];
        entity.ansCount = self.detailModel.answerEntity.ansCount;
        if (![WDSettingHelper sharedInstance_tt].wdDetailNewPushDisabled) {
            [self.view.layer removeAllAnimations];
            
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.detailModel.nextAnswerSchema] userInfo:nil pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
                if ([nav isKindOfClass:[TTNavigationController class]] &&
                    [nav respondsToSelector:@selector(pushViewController:animationTag:direction:animated:)] &&
                    [routeObj.instance isKindOfClass:[UIViewController class]]) {
                    [((TTNavigationController *)nav) pushViewController:((UIViewController *)routeObj.instance) animationTag:kOldAnimationViewTag direction:TT_PUSH_FADE animated:YES];
                }
            }];
        }
        else {
            [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.detailModel.nextAnswerSchema] userInfo:nil];
        }
    } else {
        if (!self.infoLoadFinished && self.infoLoadFailed) {
            [self tt_WDDetailWebViewNextPageFailed];
        }
        
        if (self.infoLoadFinished) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"这是最后一个回答", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
    }
}

#pragma mark - Actions

- (void)p_willShowComment
{
    [self p_sendNatantViewVisableTrack];
    if ([self.detailView.detailWebView isNatantViewOnOpenStatus]) {
        [self p_closeNatantView];
    }
    else {
        [self p_openNatantView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([self.detailView.detailWebView isNewWebviewContainer]? 0.6: 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[TTAuthorizeManager sharedManager].loginObj showAlertAtActionDetailComment:^{
                
                [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost source:@"post_comment" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                    if (type == TTAccountAlertCompletionEventTypeDone) {
                        if ([TTAccountManager isLogin]) {
                            [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
                        }
                    } else if (type == TTAccountAlertCompletionEventTypeTip) {
                        [TTAccountManager presentQuickLoginFromVC:self.navigationController type:TTAccountLoginDialogTitleTypeDefault source:@"post_comment" completion:^(TTAccountLoginState state) {
                         
                        }];
                    }
                }];
            }];
        });
        
        //added 5.3 无评论时引导用户发评论
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([self.detailView.detailWebView isNewWebviewContainer]? 0.6: 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.detailModel.answerEntity.commentCount.integerValue) {
                if (_isNewVersion) {
                    if (_wdDelegate && [_wdDelegate respondsToSelector:@selector(wd_detailViewControllerWriteCommentWithReservedText:)]) {
                        [_wdDelegate wd_detailViewControllerWriteCommentWithReservedText:nil];
                    }
                }
                else {
                    if(!_isCommentViewWillShow){
                        _isCommentViewWillShow = YES;
                        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
                    }
                }
            }
        });
        
        [self.natantContainerView sendNatantItemsShowEventWithContentOffset:0 isScrollUp:YES shouldSendShowTrack:YES];
    }
}

- (void)p_willOpenWriteCommentViewWithReservedText:(NSString *)reservedText switchToEmojiInput:(BOOL)switchToEmojiInput
{
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.detailModel.answerEntity.ansid];
    [condition setValue:groupModel forKey:@"kQuickInputViewConditionGroupModel"];
    [condition setValue:reservedText forKey:@"kQuickInputViewConditionInputViewText"];
    [self p_showCommentViewWithCondtions:condition switchToEmojiInput:switchToEmojiInput];
}

#pragma mark - Natant control

- (void)p_openNatantView
{
    if (![self.detailView.detailWebView isNewWebviewContainer]) { //新版浮层不再需要这个方法,DetailWebContainer里会实现类似效果 @zengruihuan
        [self.commentViewController tt_commentTableViewScrollToTop];
    }
    [self.detailView.detailWebView openFooterView:NO];
    self.wasTitleViewShowed = self.profileTitleView.isShow;
    [self p_showTitle:YES];
}

- (void)p_closeNatantView
{
    [self.detailView.detailWebView closeFooterView];
    [self.natantContainerView resetAllRelatedItemsWhenNatantDisappear];
    [self p_showTitle:self.wasTitleViewShowed];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData
{
    if (self.detailModel.answerEntity.answerDeleted) {
        self.ttViewType = TTFullScreenErrorViewTypeDeleted;
        return NO;
    }
    return YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"删除回答"]) {
        [self.natantViewModel tt_removeAnswerForAnswerIDFinishBlock:^(NSString *tips, NSError *error) {
            if (tips) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tips indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            } else {
                if (_isNewVersion) {
                    if (_wdDelegate && [_wdDelegate respondsToSelector:@selector(wd_detailViewControllerAfterDeleteAnswer)]) {
                        [_wdDelegate wd_detailViewControllerAfterDeleteAnswer];
                    }
                    return;
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground
{
    if (_isNewVersion) return;
    [self trySendCurrentPageStayTime];
}

- (void)trackStartedByAppWillEnterForground
{
    if (_isNewVersion) return;
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)trySendCurrentPageStayTime
{
    if (self.ttTrackStartTime == 0) {//当前页面没有在展示过
        
        [[TTMonitor shareManager] trackService:WDDetailErrorPageStayService
                                        status:0
                                         extra:nil];
        
        return;
    }
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration <= 200) {//低于200毫秒，忽略
        self.ttTrackStartTime = 0;
        [self tt_resetStayTime];
        return;
    }
    
    [self _sendCurrentPageStayTime:duration];
    
    self.ttTrackStartTime = 0;
    [self tt_resetStayTime];
}

- (void)_sendCurrentPageStayTime:(NSTimeInterval)duration
{
    NSTimeInterval errorStayTime = [[WDSettingHelper sharedInstance_tt] pageStayErrorTime];
    
    if (duration > 200 && duration < errorStayTime * 1000.0) {
        
        NSMutableDictionary *stayPageDict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
        NSDictionary *commentDic = @{@"stay_comment_time":[[NSNumber numberWithDouble:round(self.commentShowTimeTotal)] stringValue]};
        [stayPageDict setValuesForKeysWithDictionary:commentDic];
        stayPageDict[@"category"] = @"umeng";
        stayPageDict[@"tag"] = @"stay_page";
        stayPageDict[@"label"] = [self enterFrom];
        stayPageDict[@"value"] = self.detailModel.answerEntity.ansid;
        stayPageDict[@"ext_value"] = @(duration);
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTracker eventData:stayPageDict];
        }
        
        //Wenda_V3_DoubleSending
        NSMutableDictionary *v3Dic = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
        [v3Dic setValue:self.detailModel.answerEntity.ansid forKey:@"group_id"];
        [v3Dic setValue:self.detailModel.answerEntity.ansid forKey:@"ansid"];
        [v3Dic setValue:self.detailModel.answerEntity.qid forKey:@"qid"];
        [v3Dic setValue:@(duration) forKey:@"stay_time"];
        [v3Dic setValuesForKeysWithDictionary:commentDic];
//        [TTTrackerWrapper eventV3:@"stay_page" params:v3Dic isDoubleSending:YES];
        
        [[TTRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:self.detailModel.answerEntity.ansid itemID:self.detailModel.answerEntity.ansid enterFrom:[self enterFrom] categoryName:[self.detailModel.gdExtJsonDict objectForKey:@"category_name"] stayTime:duration logPb:[self.detailModel.gdExtJsonDict objectForKey:@"log_pb"] answerID:self.detailModel.answerEntity.ansid questionID:self.detailModel.answerEntity.qid enterFromAnswerID:[self.detailModel.gdExtJsonDict objectForKey:@"enterfrom_answerid"] parentEnterFrom:[self.detailModel.gdExtJsonDict objectForKey:@"parent_enterfrom"]];
    }
}

- (NSString *)enterFrom
{
    NSString * enterFrom = [self.detailModel enterFrom];
    if (isEmptyString(enterFrom)) {
        enterFrom = @"unknown";
    }
    return enterFrom;
}

- (void)sendTrackWithDict:(NSDictionary *)dictInfo
{
    if (![dictInfo isKindOfClass:[NSDictionary class]] ||
        [dictInfo count] == 0) {
        return;
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dictInfo];
    [dict setValue:@"answer" forKey:@"tag"];
    [dict setValue:@"umeng" forKey:@"category"];
    [TTTracker eventData:dict];
}

#pragma mark - Notifications

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    if (!_isNewVersion) {
        [self.toolbarView layoutIfNeeded];
    }

}

- (void)statusbarFrameDidChangeNotification {
    
}

- (void)appDidBecomeActiveNotification {
    
}

#pragma mark - TTDetailViewController protocol (NavBarItems)

- (TTFollowThemeButton *)rightFollowButton {
    if (!_rightFollowButton) {
        _rightFollowButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101 followedType:TTFollowedType101];
        _rightFollowButton.followed = self.detailModel.answerEntity.user.isFollowing;
        
        WeakSelf;
        [_rightFollowButton.KVOController observe:self.detailModel.answerEntity.user keyPath:NSStringFromSelector(@selector(isFollowing)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            BOOL isFollowing = [change tt_boolValueForKey:NSKeyValueChangeNewKey];
            self.rightFollowButton.followed = isFollowing;
            if (self.detailModel.redPack && isFollowing) {
                self.rightFollowButton.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:self.detailModel.redPack.button_style.integerValue defaultType:TTUnfollowedType201];
            } else {
                self.rightFollowButton.unfollowedType = TTUnfollowedType101;
            }
            [self.rightFollowButton refreshUI];
        }];
        [_rightFollowButton addTarget:self withActionBlock:^{
            StrongSelf;
            if (!TTNetworkConnected()) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:@"网络不给力，请稍后重试"
                                         indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"]
                                            autoDismiss:YES
                                         dismissHandler:nil];
                return;
            }
            
            BOOL isFollowed = self.detailModel.answerEntity.user.isFollowing;
            self.rightFollowButton.followed = isFollowed;
            [self.rightFollowButton startLoading];
            
            BOOL isFollowing = self.detailModel.answerEntity.user.isFollowing;
            NSString *event = isFollowing ? @"rt_unfollow" : @"rt_follow";
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
            [dict setValue:@"answer_detail_top_banner" forKey:@"source"];
            [dict setValue:@"detail" forKey:@"position"];
            [dict setValue:self.detailModel.answerEntity.ansid forKey:@"group_id"];
            [dict setValue:self.detailModel.answerEntity.user.userID forKey:@"to_user_id"];
            [dict setValue:@"from_group" forKey:@"follow_type"];
            if (self.detailModel.needSendRedPackFlag) {
                if (isFollowing) {
                    self.detailModel.needSendRedPackFlag = NO;
                }
                [dict setValue:@1 forKey:@"is_redpacket"];
            }
            [TTTracker eventV3:event params:[dict copy]];
            
            NSMutableDictionary *followDic = [NSMutableDictionary dictionary];
            [followDic setValue:self.detailModel.answerEntity.user.userID forKey:@"id"];
            [followDic setValue:@(101) forKey:@"new_source"];
            [followDic setValue:@(32) forKey:@"new_reason"];//FriendFollowNewReasonUnknown
            [followDic setValue:kWDDetailViewControllerUMEventName forKey:@"from"];
            
            FriendActionType actionType = self.detailModel.answerEntity.user.isFollowing ? FriendActionTypeUnfollow: FriendActionTypeFollow;
            if (actionType == FriendActionTypeFollow) {
                [[TTFollowManager  sharedManager] follow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
                    [self finishActionType:actionType error:error result:result];
                }];
            } else {
                [[TTFollowManager  sharedManager] unfollow:followDic completion:^(NSError * _Nullable error, NSDictionary * _Nullable result) {
                    [self finishActionType:actionType error:error result:result];
                }];
            }
            
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _rightFollowButton;
}

- (void)finishActionType:(FriendActionType)type error:(nullable NSError*)error result:(nullable NSDictionary*)result
{
    [self.rightFollowButton stopLoading:nil];
    
    if (!error) {
        NSDictionary *response = [result tt_dictionaryValueForKey:@"result"];
        NSDictionary *data = [response tt_dictionaryValueForKey:@"data"];
        NSDictionary *user = [data tt_dictionaryValueForKey:@"user"];
        BOOL isFollowing = [user tt_boolValueForKey:@"is_following"];
        self.detailModel.answerEntity.user.isFollowing = isFollowing;
        [self.detailModel.answerEntity save];
        
        if (self.detailModel.redPack && isFollowing) {
            NSMutableDictionary *extraDict = @{}.mutableCopy;
            [extraDict setValue:self.detailModel.answerEntity.user.userID forKey:@"user_id"];
            [extraDict setValue:[self.detailModel.gdExtJsonDict tt_stringValueForKey:@"category_name"] forKey:@"category"];
            [extraDict setValue:@"answer_detail_top_banner" forKey:@"source"];
            [extraDict setValue:@"detail" forKey:@"position"];
            [extraDict setValue:self.detailModel.gdExtJsonDict forKey:@"gd_ext_json"];

            [[WDAdapterSetting sharedInstance] showRedPackViewWithRedPackModel:self.detailModel.redPack extraDict:[extraDict copy] viewController:self];
            self.detailModel.redPack = nil;
        }
    } else {
        NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
        if (!TTNetworkConnected()) {
            hint = @"网络不给力，请稍后重试";
        }
        if (isEmptyString(hint)) {
            hint = NSLocalizedString(type == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
}

- (void)leftBarButtonClicked:(id)sender
{
    BOOL couldSendPageBack = YES;
    SSJSBridgeWebView *webView = self.detailView.detailWebView.webView;
    if ([self.backButtonView isCloseButtonShowing]) {
        if (sender == self.backButtonView.backButton) {
            if ([webView canGoBack]) {
                [webView goBack];
            }
            else {
                couldSendPageBack = NO;
                [self.navigationController popViewControllerAnimated:YES];
            }
            _backButtonTouched = YES;
        }
        else {
            couldSendPageBack = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if ([webView canGoBack]) {
            [webView goBack];
            [self.backButtonView showCloseButton:YES];
        } else {
            couldSendPageBack = NO;
            _backButtonTouched = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    if (sender == self.backButtonView.closeButton) {
        _closeButtonTouched = YES;
    }
}

- (void)detailContainerViewController:(SSViewControllerBase *)container leftBarButtonClicked:(id)sender
{
    BOOL couldSendPageBack = YES;
    SSJSBridgeWebView *webView = self.detailView.detailWebView.webView;
    if ([self.backButtonView isCloseButtonShowing]) {
        if (sender == self.backButtonView.backButton) {
            if ([webView canGoBack]) {
                [webView goBack];
            }
            else {
                couldSendPageBack = NO;
                [self.navigationController popViewControllerAnimated:YES];
            }
            _backButtonTouched = YES;
        }
        else {
            couldSendPageBack = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        if ([webView canGoBack]) {
            [webView goBack];
            [self.backButtonView showCloseButton:YES];
        } else {
            couldSendPageBack = NO;
            _backButtonTouched = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    if (sender == self.backButtonView.closeButton) {
        _closeButtonTouched = YES;
    }
}

- (void)detailContainerViewController:(SSViewControllerBase *)container rightBarButtonClicked:(id)sender
{
    [self p_showSharePanel];
}

- (void)p_showSharePanel
{
    if (self.detailModel.answerEntity.answerDeleted) {
        return;
    }
    [self p_removeIndicatorPolicyView];
    
    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:[self.natantViewModel wd_shareItems]];
    [contentItems addObject:[self.natantViewModel wd_customItems]];
    [self.shareManager displayActivitySheetWithContent:[contentItems copy]];
    
    [TTTracker category:@"umeng" event:kWDDetailViewControllerUMEventName label:@"more_clicked" dict:self.detailModel.gdExtJsonDict];
}

#pragma mark - Tracker

- (void)p_sendNatantViewVisableTrack
{
    if ([self.detailView.detailWebView isNatantViewOnOpenStatus]) {
        ttTrackEvent(kWDDetailViewControllerUMEventName, @"handle_close_drawer");
    }
    else {
        ttTrackEvent(kWDDetailViewControllerUMEventName, @"handle_open_drawer");
    }
}

- (void)p_sendDetailDeallocTrack
{
    if (!isEmptyString(self.detailModel.rid)) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (!SSIsEmptyDictionary(self.detailModel.gdExtJsonDict)) {
            [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
        }
        [dict setValue:self.detailModel.rid forKey:@"rule_id"];
        [dict setValue:self.detailModel.answerEntity.ansid forKey:@"group_id"];
        [dict setValue:@"wenda_answer" forKey:@"message_type"];
        [TTTracker eventV3:@"push_page_back_to_feed" params:[dict copy]];
    }
}

- (void)p_sendDetailLoadTimeOffLeaveTrack
{
    BOOL stayTooLong = [self.dataSource stayPageTimeInterValForDetailView:self] > 3000.f;
    if (stayTooLong && !self.detailView.domReady) {
        __weak typeof(self) weakSelf = self;
        [self.detailView.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML;" completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
            if (error || isEmptyString(result)) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:weakSelf.detailModel.answerEntity.ansid forKey:@"value"];
                [TTTracker category:@"article" event:@"detail_load" label:@"loading" dict:dict];
            }
        }];
    }
}

- (void)p_sendEnterCommentTrack
{
    if (_hasSendEnterCommentTrack) {
        return;
    }
    [self p_sendDetailLogicTrackForEvent:@"enter_comment"];
    _hasSendEnterCommentTrack = YES;
}

- (void)p_sendFinishCommentTrack
{
    if (_hasSendFinishCommentTrack) {
        return;
    }
    [self p_sendDetailLogicTrackForEvent:@"finish_comment"];
    _hasSendFinishCommentTrack = YES;
}

- (void)p_sendReadContentTrack
{
    if (_hasSendReadContentTrack) {
        return;
    }
    [self p_sendDetailLogicTrackForEvent:@"read_content"];
    _hasSendReadContentTrack = YES;
}

- (void)p_sendFinishContentTrack
{
    if (_hasSendFinishContentTrack) {
        return;
    }
    [self p_sendDetailLogicTrackForEvent:@"finish_content"];
    _hasSendFinishContentTrack = YES;
}

- (void)p_sendDetailLogicTrackWithLabel:(NSString *)label
{
    [self.natantViewModel tt_sendDetailLogicTrackWithLabel:label];
}

- (void)p_sendDetailLogicTrackForEvent:(NSString *)event
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if (self.detailModel.gdExtJsonDict) {
        [dict setValuesForKeysWithDictionary:self.detailModel.gdExtJsonDict];
    }
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:self.detailModel.enterFrom forKey:@"label"];
    [dict setValue:self.detailModel.answerEntity.ansid forKey:@"value"];
    
    if (!isEmptyString(self.detailModel.answerEntity.ansid)) {
        [dict setValue:self.detailModel.answerEntity.ansid forKey:@"item_id"];
    }
    [TTTracker eventData:dict];
}

#pragma mark UIMenuController Delegate

- (void)p_setupMenuItems
{
    UIMenuItem *customMenuItem1 = [[UIMenuItem alloc] initWithTitle:@"搜索" action:@selector(searchSelectionText:)];
    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:customMenuItem1, nil]];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (self.detailView.detailWebView.webView != nil) {
        if (action == @selector(searchSelectionText:)) {
            return YES;
        }
    }
    return [super canPerformAction:action withSender:sender];
}

- (NSString *)selectedText {
    return [self.detailView.detailWebView.webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()" completionHandler:nil];
}

- (void)searchSelectionText:(id)sender
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:[self selectedText] forKey:@"keyword"];
    [extra setValue:@(1) forKey:@"nav"];
    [extra setValue:@(1) forKey:@"backBtn"];
    [extra setValue:@(11) forKey:@"tabType"];//ListDataSearchFromTypeWebViewMenuItem
    [extra setValue:@(self.detailModel.answerEntity.ansid.longLongValue) forKey:@"groupID"];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:extra];
    NSString *schema = [NSString stringWithFormat:@"sslocal://search"];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:schema] userInfo:userInfo];
}

#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
    NSString *label = [WDShareUtilsHelper labelNameForShareActivity:activity];
    if (!isEmptyString(label)) {
        [self.detailModel sendDetailTrackEventWithTag:kWDDetailViewControllerUMEventName label:label];
    }
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.detailModel.answerEntity.ansid];
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    context.mediaID = self.detailModel.answerEntity.ansid;
    [self.actionManager setContext:context];
    DetailActionRequestType requestType = [WDShareUtilsHelper requestTypeForShareActivityType:activity];
    [self.actionManager startItemActionByType:requestType];
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    NSString *label = [WDShareUtilsHelper labelNameForShareActivity:activity shareState:(error ? NO : YES)];
    if (!isEmptyString(label)) {
        ttTrackEventWithCustomKeys(kWDDetailViewControllerUMEventName, label, self.detailModel.answerEntity.ansid, nil, self.detailModel.gdExtJsonDict);
    }
}

#pragma mark - WDDetailViewDelegate

- (void)tt_articleDetailViewWillChangeFontSize
{
    _webViewWillChangeFontSize = YES;
}

- (void)tt_articleDetailViewDidChangeFontSize
{
    _webViewWillChangeFontSize = NO;
}

- (void)webView:(nullable TTDetailWebviewContainer *)webViewContainer scrollViewDidScroll:(nullable UIScrollView *)scrollView
{
    UIScrollView *targetScrollView = [self.detailView.detailWebView isNewWebviewContainer] ? webViewContainer.containerScrollView: webViewContainer.webView.scrollView;
    
    if (scrollView == targetScrollView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > webViewContainer.webView.frame.size.height) {
            [self p_sendReadContentTrack];
            if (offsetY > webViewContainer.webView.frame.size.height * 2) {
                [self p_sendFinishContentTrack];
            }
        }
        
        if (webViewContainer.footerStatus == TTDetailWebViewFooterStatusDisplayHalf) {
            if (!_enterHalfFooterStatusContentOffset) {
                _enterHalfFooterStatusContentOffset = offsetY;
            }
            CGFloat natantScrollOffset = offsetY - _enterHalfFooterStatusContentOffset;
            [self.natantContainerView sendNatantItemsShowEventWithContentOffset:natantScrollOffset isScrollUp:NO];
            [self.natantContainerView checkVisibleAtContentOffset:natantScrollOffset - self.commentViewController.view.frame.size.height referViewHeight:self.commentViewController.view.frame.size.height];
        }
        
        if (_isNewVersion) {
            if (_wdDelegate && [_wdDelegate respondsToSelector:@selector(wd_detailViewControllerDidScroll:index:)]) {
                [_wdDelegate wd_detailViewControllerDidScroll:scrollView index:self.index];
            }
        }
        else {
            [self p_updateNavigationTitleViewWithScrollViewContentOffset:scrollView.contentOffset.y];
        }
        if (self.headerView) {
            [self updateHeaderViewWithOffset:offsetY scrollView:scrollView];
        }
    }
}

- (void)updateHeaderViewWithOffset:(CGFloat)offsetY scrollView:(UIScrollView *)scrollView
{
    if (offsetY >= 0) {
        CGFloat minTop = kNavigationBarHeight - self.headerView.height;
        if ((self.headerView.top - offsetY) < minTop) {
            self.headerView.top = minTop;
            self.detailView.top = self.headerView.bottom;
        } else {
            self.headerView.top = self.headerView.top - offsetY;
            self.detailView.top = self.headerView.bottom;
            [scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
        }
    } else {
        CGFloat maxTop = kNavigationBarHeight;
        if ((self.headerView.top - offsetY) >= maxTop) {
            self.headerView.top = maxTop - offsetY;
            self.detailView.top = maxTop + self.headerView.height;
        } else {
            self.headerView.top = self.headerView.top - offsetY;
            self.detailView.top = self.headerView.bottom;
            [scrollView setContentOffset:CGPointMake(0.0f, 0.0f)];
        }
        [self headerViewDidPull:self.headerView];
    }
    
    if (!_isNewVersion && [TTDeviceHelper isPadDevice]) {
        if (self.headerView.top > kNavigationBarHeight) {
            self.whiteGapView.height = self.headerView.top - kNavigationBarHeight;
            [self.view bringSubviewToFront:self.whiteGapView];
        } else {
            self.whiteGapView.height = 0.0f;
            [self.view sendSubviewToBack:self.whiteGapView];
        }
    }
}

- (void)tt_WDDetailViewWillShowLargeImage
{
    _hiddenByDisplayImage = YES;
}

- (void)tt_WDDetailWebViewNextPageFailed
{
    if ([WDSettingHelper sharedInstance_tt].isWenSwithOpen) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络异常，请重试", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        
        [self p_startLoadArticleInfo];
    } else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
    
}

- (void)tt_WDDetailViewWillShowFirstCommentCell
{
    if (self.isNewVersion && !self.isViewDisplaying) {
        self.isNeedCommentTrack = YES;
        return;
    }
    self.isNeedCommentTrack = NO;
    [self p_sendEnterCommentTrack];
    self.commentViewController.hasSelfShown = YES;
    [self.commentViewController tt_sendShowTrackForVisibleCells];
}

- (void)tt_WDDetailViewFooterHalfStatusOffset:(CGFloat)rOffset
{
    [self.commentViewController tt_sendHalfStatusFooterImpressionsForViableCellsWithOffset:rOffset];
}

- (void)tt_wdDetailViewWillShowOppose:(nonnull NSDictionary *)result {
    
    if ([self.detailModel.answerEntity isDigg]) {
        self.actionIndicator = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经赞过" indicatorImage:nil dismissHandler:nil];
        [self.actionIndicator showFromParentView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.actionIndicator dismissFromParentView];
        });
    }
    else {
        if (!self.detailModel.answerEntity.isBuryed) {
            self.detailModel.answerEntity.buryCount = @([self.detailModel.answerEntity.buryCount longLongValue] + 1);
            self.detailModel.answerEntity.isBuryed = YES;
            [WDAnswerService buryWithAnswerID:self.detailModel.answerEntity.ansid buryType:WDBuryTypeBury enterFrom:kWDDetailViewControllerUMEventName apiParam:self.detailModel.apiParam finishBlock:nil];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
            [dict setValue:@"umeng" forKey:@"category"];
            [dict setValue:@"answer_detail" forKey:@"tag"];
            [dict setValue:@"click_dislike" forKey:@"label"];
            [TTTracker eventData:dict];
        } else {
            self.detailModel.answerEntity.buryCount = [self.detailModel.answerEntity.buryCount longLongValue] >= 1 ? @([self.detailModel.answerEntity.buryCount longLongValue] - 1): @0;
            self.detailModel.answerEntity.isBuryed = NO;
            [WDAnswerService buryWithAnswerID:self.detailModel.answerEntity.ansid buryType:WDBuryTypeUnBury enterFrom:kWDDetailViewControllerUMEventName apiParam:self.detailModel.apiParam finishBlock:nil];
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
            WDAnswerEntity *answerEntity = self.detailModel.answerEntity;
            [dict setValue:answerEntity.ansid forKey:@"group_id"];
            [dict setValue:answerEntity.user.userID forKey:@"user_id"];
            [dict setValue:@(10) forKey:@"group_source"];
            [dict setValue:@"detail" forKey:@"position"];
            [TTTracker eventV3:@"rt_unbury" params:[dict copy]];
        }
    }
}

- (void)tt_wdDetailViewWillShowReport:(nonnull NSDictionary *)result {
    [self.natantViewModel tt_willShowReport];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:@"answer_detail" forKey:@"tag"];
    [dict setValue:@"click_report" forKey:@"label"];
    [TTTracker eventData:dict];
}

#pragma mark - WDBottomToolViewDelegate

- (void)bottomView:(WDBottomToolView *)bottomView writeButtonClicked:(SSThemedButton *)wirteButton
{
    if (!self.detailModel.answerEntity.banComment) {
        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    } else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"该回答禁止评论" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
    [self p_sendDetailLogicTrackWithLabel:@"write_button"];
}

- (void)bottomView:(WDBottomToolView *)bottomView emojiButtonClicked:(SSThemedButton *)wirteButton
{
    if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
        [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
            NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
            TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.detailModel.answerEntity.ansid];
            [baseCondition setValue:groupModel forKey:@"groupModel"];
            [baseCondition setValue:@(1) forKey:@"from"];
            [baseCondition setValue:@(YES) forKey:@"writeComment"];
            [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
            baseCondition;
        })];
        if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
            [self.commentViewController tt_clearDefaultReplyCommentModel];
        }
        [self.toolbarView.writeButton setTitle:@"写评论" forState:UIControlStateNormal];
        return;
    }
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:YES];
}

- (void)bottomView:(WDBottomToolView *)bottomView commentButtonClicked:(SSThemedButton *)commentButton
{
    [self p_willShowComment];
}

- (void)bottomView:(WDBottomToolView *)bottomView diggButtonClicked:(SSThemedButton *)diggButton
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    WDAnswerEntity *answerEntity = self.detailModel.answerEntity;
    [dict setValue:answerEntity.ansid forKey:@"group_id"];
    [dict setValue:answerEntity.user.userID forKey:@"user_id"];
    [dict setValue:@(10) forKey:@"group_source"];
    [dict setValue:@"detail_bottom" forKey:@"position"];

    if (self.detailModel.answerEntity.isDigg) {
        [TTTracker eventV3:@"rt_like" params:[dict copy]];
    } else {
        [TTTracker eventV3:@"rt_unlike" params:[dict copy]];
    }
}

- (void)bottomView:(WDBottomToolView *)bottomView nextButtonClicked:(SSThemedButton *)nextButton
{
    [self p_tryNextAnswer];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:kWDDetailViewControllerUMEventName forKey:@"tag"];
    [dict setValue:@"click_next_answer" forKey:@"label"];
    [dict setValue:self.detailModel.answerEntity.ansid forKey:@"value"];
    [TTTracker eventData:[dict copy]];
}

#pragma mark - TTCommentDataSource

- (void)tt_loadCommentsForMode:(TTCommentLoadMode)loadMode
        possibleLoadMoreOffset:(nullable NSNumber *)offset
                       options:(TTCommentLoadOptions)options
                   finishBlock:(nullable TTCommentLoadFinishBlock)finishBlock
{
    TTCommentDataManager *commentDataManager = [[TTCommentDataManager alloc] init];
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.detailModel.answerEntity.ansid];
    [commentDataManager startFetchCommentsWithGroupModel:groupModel forLoadMode:loadMode  loadMoreOffset:offset loadMoreCount:@(TTCommentDefaultLoadMoreFetchCount) msgID:self.detailModel.msgId options:options finishBlock:finishBlock];
}

- (SSThemedView *)tt_commentHeaderView
{
    return self.natantContainerView;
}

- (TTGroupModel *)tt_groupModel
{
    return [[TTGroupModel alloc] initWithGroupID:self.detailModel.answerEntity.ansid];
}

#pragma mark - TTCommentDelegate

- (void)tt_commentViewControllerDidFetchCommentsWithError:(NSError *)error 
{
    if (self.detailModel.isJumpComment) {
        self.detailModel.isJumpComment = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self p_willShowComment];
        });
    } else if (!isEmptyString(self.detailModel.msgId)) {
        self.detailModel.msgId = @"";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self p_willShowComment];
        });
    }
   
    if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
        NSString *userName = self.commentViewController.tt_defaultReplyCommentModel.userName;
        [self.toolbarView.writeButton setTitle:isEmptyString(userName)? @"写评论": [NSString stringWithFormat:@"回复 %@：", userName] forState:UIControlStateNormal];
    }
    
    // toolbar 禁表情
    if ([self.commentViewController respondsToSelector:@selector(tt_banEmojiInput)]) {
        BOOL isBanRepostOrEmoji = ![[WDAdapterSetting sharedInstance] commentToolBarEnable];
        self.toolbarView.banEmojiInput = self.commentViewController.tt_banEmojiInput || isBanRepostOrEmoji;
    }
    self.toolbarView.banEmojiInput = YES;
    
    [self.detailView tt_serverRequestTimeMonitorWithName:WDDetailCommentTimeService error:error];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickCommentCellWithCommentModel:(nonnull id<TTCommentModelProtocol>)model
{
    [self.toolbarView hideSupportsEmojiInputBubbleViewIfNeeded];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didClickReplyButtonWithCommentModel:(id<TTCommentModelProtocol>)model
{
    [self.toolbarView hideSupportsEmojiInputBubbleViewIfNeeded];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController avatarTappedWithCommentModel:(id<TTCommentModelProtocol>)model
{
    if ([model.userID longLongValue] == 0) {
        return;
    }
    
    NSString *userID = [NSString stringWithFormat:@"%@", model.userID];
    NSString *schema = [NSString stringWithFormat:@"sslocal://profile?uid=%@&enter_from=%@",userID,@"answer_detail_comment"];
    NSString *categoryName = [self.detailModel.gdExtJsonDict objectForKey:@"category_name"];
    
    NSString *result = [WDTrackerHelper schemaTrackForPersonalHomeSchema:schema categoryName:categoryName fromPage:@"detail_wenda_comment" groupId:self.detailModel.answerEntity.ansid profileUserId:userID];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:result]];
    
    [self.toolbarView hideSupportsEmojiInputBubbleViewIfNeeded];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController tappedWithUserID:(NSString *)userID
{
    if ([userID longLongValue] == 0) {
        return;
    }
    NSString *userIDstr = [NSString stringWithFormat:@"%@", userID];
    NSMutableString *linkURLString = [NSMutableString stringWithFormat:@"sslocal://profile?uid=%@", userIDstr];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:linkURLString]];

    [self.toolbarView hideSupportsEmojiInputBubbleViewIfNeeded];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController startWriteComment:(id<TTCommentModelProtocol>)model
{
    if (_isNewVersion) {
        if (_wdDelegate && [_wdDelegate respondsToSelector:@selector(wd_detailViewControllerWriteCommentWithReservedText:)]) {
            [_wdDelegate wd_detailViewControllerWriteCommentWithReservedText:nil];
        }
        return;
    }
    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
}

- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController
             scrollViewDidScroll:(nonnull UIScrollView *)scrollView{
    CGFloat offsetPadding = 0;
    [self.natantContainerView sendNatantItemsShowEventWithContentOffset:scrollView.contentOffset.y isScrollUp:YES];
    [self.natantContainerView checkVisibleAtContentOffset:scrollView.contentOffset.y+offsetPadding referViewHeight:scrollView.height];
}


- (void)tt_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info {
    NSMutableDictionary *mdict = info.mutableCopy;
    //todo
    [mdict setValue:@"detail_wenda_comment_dig" forKey:@"fromPage"];
    [mdict setValue:[self.detailModel.gdExtJsonDict tt_stringValueForKey:@"category"]  forKey:@"categoryName"];
    [mdict setValue:self.detailModel.answerEntity.ansid forKey:@"groupId"];
    
    if (self.isNewVersion) {
        if ([self.wdDelegate respondsToSelector:@selector(wd_commentViewController:didSelectWithInfo:)]) {
            [self.wdDelegate wd_commentViewController:ttController didSelectWithInfo:mdict];
        }
    } else {
        [[WDAdapterSetting sharedInstance] commentViewControllerDidSelectedWithInfo:mdict viewController:self dismissBlock:^{
            [[UIApplication sharedApplication] setStatusBarStyle:[[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay? UIStatusBarStyleDefault: UIStatusBarStyleLightContent];
            if ([self.commentViewController respondsToSelector:@selector(tt_reloadData)]) {
                [self.commentViewController tt_reloadData];
            }
            
            self.commentShowDate = [NSDate date];
        }];
    }
    
    [self.toolbarView hideSupportsEmojiInputBubbleViewIfNeeded];
    
    //停止评论时间
    if (self.commentShowDate) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.commentShowDate];
        self.commentShowTimeTotal += timeInterval*1000;
        self.commentShowDate = nil;
    }
}

- (BOOL)tt_shouldShowDeleteComments
{
    return [self.natantViewModel canDeleteComment];
}

- (void)tt_commentViewController:(nonnull id<TTCommentViewControllerProtocol>)ttController
             refreshCommentCount:(int)count
{
    self.detailModel.answerEntity.commentCount = @(count);
    [self.detailModel.answerEntity save];
}

- (void)tt_commentViewControllerFooterCellClicked:(nonnull id<TTCommentViewControllerProtocol>)ttController
{
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    wrapperTrackEventWithCustomKeys(@"fold_comment", @"click", self.detailModel.answerEntity.ansid, nil, extra);
    NSMutableDictionary *condition = [[NSMutableDictionary alloc] init];
    [condition setValue:self.detailModel.answerEntity.ansid forKey:@"groupID"];
    
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://fold_comment"] userInfo:TTRouteUserInfoWithDict(condition)];
}

#pragma mark - TTWriteCommentViewDelegate

- (void)commentView:(TTCommentWriteView *) commentView cancelledWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager
{
    _isCommentViewWillShow = NO;
}

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    commentWriteManager.delegate = nil;
    self.commentViewController.hasSelfShown = YES;
    if(![responseData objectForKey:@"error"])  {
        [commentView dismissAnimated:YES];
        WDAnswerEntity *answer = self.detailModel.answerEntity;
        answer.commentCount = @([answer.commentCount longLongValue] + 1);
        NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:[responseData objectForKey:@"data"]];
        [self.commentViewController tt_insertCommentWithDict:data];
        if ([self.commentViewController respondsToSelector:@selector(tt_markStickyCellNeedsAnimation)]) {
            [self.commentViewController tt_markStickyCellNeedsAnimation];
        }
        if ([self.detailView.detailWebView isNewWebviewContainer]) {
            if (![self.detailView.detailWebView isNatantViewOnOpenStatus]) {
                [self p_sendNatantViewVisableTrack];
            }
            [self.detailView.detailWebView openFirstCommentIfNeed];
        } else {
            [self.commentViewController tt_commentTableViewScrollToTop];
            if (![self.detailView.detailWebView isNatantViewOnOpenStatus]) {
                [self.detailView.detailWebView openFooterView:NO];
                [self p_sendNatantViewVisableTrack];
            }
        }
    }
}

#pragma mark - WDDetailHeaderViewDelegate
- (void)headerView:(UIView<WDDetailHeaderView> *)headerView bgButtonDidTap:(UIButton *)button {
    // 头部的背景点击后执行的跳转逻辑，从SlideVC抄过来的
    if ([self.detailModel needReturn]) {
        [self dismissSelf];
    } else {
        [self.detailModel openListPage];
    }
}

- (void)headerView:(UIView<WDDetailHeaderView> *)headerView answerButtonDidTap:(UIButton *)button {
    NSString *schema = [self.detailModel.answerEntity postAnswerSchema];
    if (!isEmptyString(schema) && [NSURL URLWithString:schema]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:schema] userInfo:nil];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    dict[@"group_id"] = self.detailModel.answerEntity.ansid;
    [TTTracker eventV3:@"answer_detail_write_answer" params:dict];
}

- (void)headerView:(UIView<WDDetailHeaderView> *)headerView goodAnswerButtonDidTap:(UIButton *)button {
    NSString *schema = [self.detailModel.answerEntity postAnswerSchema];
    if (!isEmptyString(schema) && [NSURL URLWithString:schema]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:schema] userInfo:nil];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    dict[@"group_id"] = self.detailModel.answerEntity.ansid;
    [TTTracker eventV3:@"answer_detail_top_write_answer" params:dict];
}

- (void)headerView:(UIView<WDDetailHeaderView> *)headerView answerButtonDidShow:(UIButton *)button
{
    if (_headerViewAnswerButtonShowed) {
        return;
    }
    _headerViewAnswerButtonShowed = YES;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    dict[@"group_id"] = self.detailModel.answerEntity.ansid;
    [TTTracker eventV3:@"answer_detail_write_answer_show" params:dict];
}

- (void)headerView:(UIView<WDDetailHeaderView> *)headerView goodAnswerButtonDidShow:(UIButton *)button
{
    if (_headerViewGoodAnswerButtonShowed) {
        return;
    }
    _headerViewGoodAnswerButtonShowed = YES;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    dict[@"group_id"] = self.detailModel.answerEntity.ansid;
    [TTTracker eventV3:@"answer_detail_top_write_answer_show" params:dict];
}

- (void)headerViewDidPull:(UIView<WDDetailHeaderView> *)headerView
{
    if (_headerViewPulled) {
        return;
    }
    _headerViewPulled = YES;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.detailModel.gdExtJsonDict];
    dict[@"group_id"] = self.detailModel.answerEntity.ansid;
    [TTTracker eventV3:@"question_show_pull" params:dict];
}

#pragma mark - Getter & Setter

- (TTAlphaThemedButton *)p_generateBarButtonWithImageName:(NSString *)imageName {
    TTAlphaThemedButton *barButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    barButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    barButton.imageName = imageName;
    [barButton sizeToFit];
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        [barButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
    }
    else {
        [barButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
    }
    return barButton;
}

- (SSThemedView *)whiteGapView
{
    if (!_whiteGapView) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        SSThemedView *whiteView = [[SSThemedView alloc] initWithFrame:CGRectMake(edgePadding, kNavigationBarHeight, windowSize.width - edgePadding*2, 0.0f)];
        whiteView.backgroundColorThemeKey = kColorBackground4;
        _whiteGapView = whiteView;
    }
    return _whiteGapView;
}

- (WDDetailNatantViewModel *)natantViewModel
{
    if (!_natantViewModel) {
        _natantViewModel = [[WDDetailNatantViewModel alloc] initWithDetailModel:self.detailModel];
    }
    return _natantViewModel;
}

- (DetailActionRequestManager *)actionManager
{
    if (!_actionManager) {
        _actionManager = [[DetailActionRequestManager alloc] init];
    }
    return _actionManager;
}

#pragma mark - TTInteractExitProtocol

- (UIView *)suitableFinishBackView
{
    return self.detailView;
}

@end
