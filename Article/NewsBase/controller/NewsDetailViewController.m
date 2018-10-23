//
//  NewsDetailViewController.m
//  Article
//
//  Created by Hu Dianwei on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ExploreDetailView.h"
#import "ExploreImageDetailView.h"

#import "NewsDetailViewController.h"
#import "NewsDetailFunctionView.h"
#import "SSWebViewController.h"
#import "NewsUserSettingManager.h"
#import "NewsHelpView.h"
#import "NewsDetailViewModel.h"
#import "TTThemedAlertController.h"
#import "SSWebViewBackButtonView.h"
#import "NewsDetailLogicManager.h"

#import "SSActivityView.h"

#import "UIView+Refresh_ErrorHandler.h"
#import "UIImageAdditions.h"

#import "UIViewController+NavigationBarStyle.h"

#import "PGCWAPViewController.h"
#import "ExploreEntry.h"
#import "PGCAccount.h"

#import "DetailActionRequestManager.h"

#import "ExploreItemActionManager.h"

#import "TTIndicatorView.h"

#import "ArticleReportViewController.h"
#import "TTNavigationController.h"


#import "TTAuthorizeManager.h"
#import "ArticleProfileFollowConst.h"

#import "ArticleMomentProfileViewController.h"
#import "SSUFPManager.h"
#import "TTIndicatorView.h"

#import <Crashlytics/Crashlytics.h>
#import "TTViewWrapper.h"
#import "TTThemedAlertController.h"
#import "TTSaveImageAlertView.h"
#import "ExploreDetailSaveImageManager.h"
#import "SSReportManager.h"
#import "UIImage+TTThemeExtension.h"
#import "TTThemeManager.h"
#import "TTStringHelper.h"

#define kPhoneSimpleTypeActionSheetTag  999

@interface NewsDetailViewController() <ExploreDetailViewDelegate, SSWebViewAddressBarDelegate, SSActivityViewDelegate, TTSaveImageAlertViewDelegate,UIActionSheetDelegate> {
    long long _flags;
    BOOL _hasDidAppeared;
    TTShareSourceObjectType shareSourceType;
}

@property(nonatomic, strong, readwrite)Article *article;

@property(nonatomic, strong)SSWebViewBackButtonView *backButtonView;
@property(nonatomic, strong)NewsHelpView *sliderHelpView;
@property(nonatomic, strong)UIBarButtonItem *leftBarButtonItem;

@property(nonatomic, assign)NewsGoDetailFromSource fromSource;
@property(nonatomic, copy)NSString *gdLabel;
/**
 * added 5.2.1 开屏广告透传open_url打开详情页广告落地页
 */
@property(nonatomic, copy)NSString *adOpenUrl;
@property(nonatomic, strong)NSDictionary *gdExtJsonDict;
@property(nonatomic, strong)NSString * categoryID;
@property(nonatomic, strong)NSNumber * adID;
@property(nonatomic, strong) NSString * adLogExtra;

@property(nonatomic, strong) NSString * originalSchema;

/**
 *  相关阅读的来源ID
 */
@property(nonatomic, strong)NSNumber * relateReadFromGID;
@property(nonatomic, strong)ExploreOrderedData * orderedData;

@property(nonatomic, strong) NewsDetailViewModel *newsDetailViewModel;
@property (nonatomic,assign) BOOL backBtnTouched;
@property (nonatomic, assign) BOOL closeBtnTouched;

/**
 *  头条号，夜间模式，字体设置，举报界面
 */
@property(nonatomic, strong)SSActivityView * moreSettingActivityView;
/**
 *  分享界面
 */
@property(nonatomic, strong)SSActivityView * phoneShareView;
@property(nonatomic, strong)ExploreDetailSaveImageManager *saveImageManager;
/**
 *  图集长按弹出后点击分享单张图片界面
 */
@property(nonatomic, strong)SSActivityView * currentGalleryShareView;

@property(nonatomic, strong)NSMutableArray * activityItems;

@property(nonatomic, strong) DetailActionRequestManager *detailActionRequestManager;

@property(nonatomic, strong)TTActivityShareManager *activityActionManager;

@end

@implementation NewsDetailViewController {
    BOOL _hiddenByDisplayImage;
}

@synthesize article, sliderHelpView;

- (void)dealloc {
    NSString *tag = [[[_newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]?@"slide_detail":@"detail";
    NSString *leaveType;
    if (!self.closeBtnTouched) {
        if (self.backBtnTouched) {
            ssTrackEvent(tag, @"back_button");
            leaveType = @"page_back_button";
        }
        else {
            ssTrackEvent(tag, @"back_gesture");
            leaveType = @"back_gesture";
        }
    }
    else {
        leaveType = @"page_close_button";
    }
    NSMutableDictionary *eventContext = [NSMutableDictionary dictionary];
    [eventContext setValue:[self.detailView detailReadPCT] forKey:@"read_pct"];
    [eventContext setValue:@([self.detailView currentShowGalleryProgress]) forKey:@"page_count"];
    [eventContext setValue:leaveType forKey:@"type"];
    [self sendDetailTTLogV2WithEvent:kLeaveEvent eventContext:eventContext referContext:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    
    [self restorePortraitUIInterfaceIfNeeded];
}

- (id)initWithBaseCondition:(NSDictionary *)baseCondition {
    Article *tArticle = nil;
    NSDictionary *params = [baseCondition objectForKey:kSSAppPageBaseConditionParamsKey];
    
    self.originalSchema = [baseCondition objectForKey:@"kSSAppPageOriginalSchemaKey"];

    NewsGoDetailFromSource fSource = NewsGoDetailFromSourceUnknow;
    BOOL showComment = [[params objectForKey:@"showcomment"] boolValue];
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    id groupIdValue = params[@"groupid"]?:params[@"group_id"];
    if (groupIdValue) {
        NSNumber *groupID = @([[NSString stringWithFormat:@"%@", groupIdValue] longLongValue]);
        NSNumber *fixedgroupID = [SSCommonLogic fixNumberTypeGroupID:groupID];
        NSString *itemID = [params objectForKey:@"item_id"];
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:3];
        [query setValue:fixedgroupID forKey:@"uniqueID"];
        [query setValue:itemID forKey:@"itemID"];
        
        if ([params.allKeys containsObject:@"ordered_data"]) {
            self.orderedData = [params objectForKey:@"ordered_data"];
        }
        
        NSString * gdLabel = [params objectForKey:@"gd_label"];
        
        if ([params.allKeys containsObject:@"ordered_data"]) {
            self.orderedData = [params objectForKey:@"ordered_data"];
        }
        
        NSString *adOpenUrl = [params objectForKey:@"article_url"];
        if (!isEmptyString(adOpenUrl)) {
            _adOpenUrl = adOpenUrl;
        }
        
        if (!isEmptyString(gdLabel)) {
            self.gdLabel = gdLabel;
            fSource = [NewsDetailLogicManager fromSourceByString:gdLabel];
        }
        else if ([[params allKeys] containsObject:kNewsGoDetailFromSourceKey]) {
            fSource = [params[kNewsGoDetailFromSourceKey] intValue];
        }
        
        ///...
        if ([params valueForKey:@"from_gid"]) {
            _relateReadFromGID = [params valueForKey:@"from_gid"];
        }

        //视频详情页应该attach的movieView
        if ([[params allKeys] containsObject:@"movie_view"]) {
            _attachedMovieView = [params objectForKey:@"movie_view"];
        }
        
        tArticle = [Article insertInManager:[SSModelManager sharedManager] entityWithDictionary:query];
        if ([[params allKeys] containsObject:@"group_flags"]) {
            tArticle.groupFlags = @([[params objectForKey:@"group_flags"] intValue]);
        }
        if (params[@"aggr_type"]) {
            tArticle.aggrType = @([params[@"aggr_type"] integerValue]);
        }
        if (params[@"flags"]) {
            long long flags = [params[@"flags"] longLongValue];
            tArticle.articleType = @(flags & 0x1);
        } else {
            if ([params[@"article_type"] respondsToSelector:@selector(integerValue)]) {
                tArticle.articleType = @([params[@"article_type"] integerValue]);
            }
        }
        if ([[params allKeys] containsObject:@"natant_level"]) {
            tArticle.natantLevel = @([[params objectForKey:@"natant_level"] intValue]);
        }
        if ([[params allKeys] containsObject:@"stat_params"] && [[params objectForKey:@"stat_params"] isKindOfClass:[NSDictionary class]]) {
            self.statParams = [params objectForKey:@"stat_params"];
        }
        [[SSModelManager sharedManager] save:nil];
        NSNumber * adID = nil;
        if ([[params allKeys] containsObject:@"ad_id"]) {
            adID = @([[params objectForKey:@"ad_id"] longLongValue]);
            [condition setValue:adID forKey:kNewsDetailViewConditionADIDKey];
        }
        NSString * logExtra = [params objectForKey:@"log_extra"];
        if (isEmptyString(logExtra)) {
            logExtra = self.orderedData.logExtra;
        }
        [condition setValue:logExtra forKey:kNewsDetailViewConditionADLogExtraKey];
        
        NSString * categoryID = [params objectForKey:kNewsDetailViewConditionCategoryIDKey];
        if (!isEmptyString(categoryID)) {
            [condition setValue:categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
        }
        
        NSString *gdExtJson = [params objectForKey:@"gd_ext_json"];
        if (!isEmptyString(gdExtJson)) {
            gdExtJson = [gdExtJson stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dict = [NSString ss_objectWithJSONString:gdExtJson error:&error];;
            if (!error && [dict isKindOfClass:[NSDictionary class]]) {
                self.gdExtJsonDict = dict;
            }
        }
    }
    self = [self initWithArticle:tArticle source:fSource condition:condition];
    if (self) {
        self.beginShowComment = showComment;
        if (params[@"flags"]) {
            _flags = [params[@"flags"] longLongValue];
        }
    }
    return self;
}

- (id)initWithArticle:(Article *)tArticle
               source:(NewsGoDetailFromSource)source
            condition:(NSDictionary *)condition {
    self = [self init];
    if(self)
    {
        self.hidesBottomBarWhenPushed = YES;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        self.fromSource = source;
        self.article = tArticle;
        [[self.newsDetailViewModel sharedDetailManager] updateCurrentArticle:self.article];
        
        NSString * categoryID = [condition objectForKey:kNewsDetailViewConditionCategoryIDKey];
        self.categoryID = categoryID;
        
        if ([[condition allKeys] containsObject:kNewsDetailViewConditionADIDKey] &&
            [[condition objectForKey:kNewsDetailViewConditionADIDKey] longLongValue] > 0) {
            self.adID = @([[condition objectForKey:kNewsDetailViewConditionADIDKey] longLongValue]);
        }
        
        if ([[condition allKeys] containsObject:kNewsDetailViewConditionADLogExtraKey]) {
            self.adLogExtra = [condition objectForKey:kNewsDetailViewConditionADLogExtraKey];
        }
        
        if ([[condition objectForKey:kNewsDetailViewConditionRelateReadFromGID] longLongValue] > 0) {
            self.relateReadFromGID = @([[condition objectForKey:kNewsDetailViewConditionRelateReadFromGID] longLongValue]);
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(largeImageViewDisplayed:) name:kLargeImageViewDisplayedNotification object:nil];
        
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [_detailView didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.navigationItem.title = @"";
    
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground1);
    
    [self refreshDetailViewModel];
    
    [[_newsDetailViewModel sharedDetailManager] sendGoDetailFromID:_relateReadFromGID statParams:_statParams gdExtJsonDict:_gdExtJsonDict];
    
    Article *currentArticle = [[self.newsDetailViewModel sharedDetailManager] currentArticle];
    BOOL isImageSubject = [self isImageDetail];
    /// 如果可依赖，则回去读取Article_type字段
    BOOL isNativeImageSubject = [self isNativeImageDetail];
    //加保护，如果没有videoDetailInfo则不进视频详情页
    BOOL isVideoSubject = ([currentArticle isVideoSubject] && !SSIsEmptyDictionary(currentArticle.videoDetailInfo)) || !!(_flags & kArticleGroupFlagsDetailTypeVideoSubject);
    NSString *tag = isImageSubject ? @"slide_detail" : @"detail";
    ssTrackEvent(tag, @"enter");
    if (isImageSubject) {
        self.ttHideNavigationBar = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
    
    [self sendDetailTTLogV2WithEvent:kEnterEvent eventContext:nil referContext:nil];
    

    BOOL shouldDestoryAllActiveMovie = YES;
    if (isNativeImageSubject) {
        [self loadNativeImageDetailView];
    } else if (isVideoSubject) {
        shouldDestoryAllActiveMovie = NO;
        ExploreVideoDetailView *videoDetailView = [[ExploreVideoDetailView alloc] initWithFrame:self.view.bounds viewModel:self.newsDetailViewModel];
        if (nil != _attachedMovieView) {
            videoDetailView.movieView = _attachedMovieView;
            _attachedMovieView = nil;
        }
        if (nil != _statParams && [_statParams isKindOfClass:[NSDictionary class]]) {
            videoDetailView.gdExtDict = _statParams;
        }
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        videoDetailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:videoDetailView];
        self.detailView = videoDetailView;
        self.ttHideNavigationBar = YES;
        self.ttDragToRoot = YES;
    }
    
    if (shouldDestoryAllActiveMovie) {
        [ExploreMovieView removeAllExploreMovieView];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidChangeStatusBarOrientation:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [self refreshTaobaoDetailAdsIfNeeded];
    
    CLS_LOG(@"NewsDetailViewController viewDidLoad with groupID %lld",[currentArticle.uniqueID longLongValue]);
}

- (BOOL)shouldWrapDetailView {
    if ([TTDeviceHelper isPadDevice]) {
        return self.article && !(self.article.isImageSubject || !!(_flags & 0x10000) || self.article.isVideoSubject || !!(_flags & kArticleGroupFlagsDetailTypeVideoSubject));
    }
    return NO;
}

- (CGRect)frameForDetailView {
    //    if ([self shouldWrapDetailView]) {
    //        CGFloat edgePadding = [SSCommonAppExtension paddingForViewWidth:self.view.width];
    //        return CGRectMake(edgePadding, 0, self.view.width - edgePadding*2, self.view.height);
    //    }
    //    return self.view.bounds;
    CGSize windowSize = [SSCommonAppExtension windowSize];
    if ([self shouldWrapDetailView]) {
        CGFloat edgePadding = [SSCommonAppExtension paddingForViewWidth:windowSize.width];
        return CGRectMake(edgePadding, 0, windowSize.width - edgePadding*2, windowSize.height);
    }
    return CGRectMake(0, 0, windowSize.width, windowSize.height);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.detailView.frame = [self frameForDetailView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    //move from viewDidLoad
    if (nil == self.detailView) {
        [self loadArticleDetailViewWithForceNative:NO];
    } else {
        [_detailView willAppear];
    }
    
    //init leftBarButtonItem, move from viewDidLoad
    [self refreshLeftBarButtonItemsWithCloseButtonShown:NO];
    
    if(!_hiddenByDisplayImage && [self.newsDetailViewModel shouldShowNewsHelpView] &&
       ![[[self.newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]
       && [SSCommonLogic showGestureTip]) {
        self.sliderHelpView = [[NewsHelpView alloc] initWithFrame:self.view.bounds];
        sliderHelpView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        [sliderHelpView setImage:[UIImage themedImageNamed:@"slide.png"]];
        [sliderHelpView setText1:NSLocalizedString(@"右滑返回", nil)];
        [self.view addSubview:sliderHelpView];
        [self.newsDetailViewModel updateShouldShowNewsHelpView];
    }
    _hiddenByDisplayImage = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [_detailView didAppear];
    if (_hasDidAppeared) {
        [self startStayPageTrackerIfNeeded];
    }
    _hasDidAppeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [_detailView willDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self endStayPageTrackerIfNeed];
    [_detailView didDisappear];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if([TTDeviceHelper isPadDevice]) {
        return UIInterfaceOrientationMaskAll;
    } else {
        if ([[[_newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]) {
            return UIInterfaceOrientationMaskAllButUpsideDown;
            
        }
        return UIInterfaceOrientationMaskPortrait;
    }

}

#pragma mark - View

- (void)refreshLeftBarButtonItemsWithCloseButtonShown:(BOOL)closeButtonShown {
    if (nil == self.backButtonView) {
        self.backButtonView = [[SSWebViewBackButtonView alloc] init];
        [self.backButtonView.backButton addTarget:self action:@selector(backViewItemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButtonView.closeButton addTarget:self action:@selector(backViewItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButtonView];
    if (closeButtonShown) {
        [self.backButtonView showCloseButton:YES];
    }
}

- (void)refreshNavBarWithForcedShownEscapeButton:(BOOL)forcedEscapeButton {
    //barButtonItems
    if (self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    }
    
    if ([[[[_newsDetailViewModel sharedDetailManager] currentArticle] articleDeleted] boolValue]) {
        self.navigationItem.rightBarButtonItems = nil;
    }
    else {
        NSMutableArray *barButtons = [NSMutableArray array];
        NSDictionary *buttons = [self.newsDetailViewModel newsDetailRightButtons];
        if ([[buttons allKeys] containsObject:kMoreBarButtonKey]) {
            UIButton *moreButton = buttons[kMoreBarButtonKey];
            [moreButton addTarget:self action:@selector(moreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [barButtons addObject:[[UIBarButtonItem alloc] initWithCustomView:moreButton]];
        }
        self.navigationItem.rightBarButtonItems = barButtons;
    }
}

- (void)loadNativeImageDetailView
{
    ExploreImageDetailView *detailView = [[ExploreImageDetailView alloc] initWithFrame:self.view.bounds viewModel:self.newsDetailViewModel];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:detailView];
    self.detailView = detailView;
}

- (void)loadArticleDetailViewWithForceNative:(BOOL)forceLoadNative
{
    [self refreshDetailViewModel];
    if (forceLoadNative) {
        [[self.newsDetailViewModel sharedDetailManager] resetHasLoadedArticle];
        [[self.newsDetailViewModel sharedDetailManager] setForceLoadNativeContent:YES];
    }
    
    self.detailView = [[ExploreDetailView alloc] initWithFrame:[self frameForDetailView] viewModel:self.newsDetailViewModel];
    self.detailView.delegate = self;
    _detailView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if ([self shouldWrapDetailView]) {
        TTViewWrapper *wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [wrapperView addSubview:_detailView];
        wrapperView.targetView = _detailView;
        [self.view addSubview:wrapperView];
    }
    else {
        [self.view addSubview:_detailView];
    }
    
    [_detailView willAppear];
}

- (void)themeChanged:(NSNotification *)notification
{
    [self refreshNavBarWithForcedShownEscapeButton:NO];
}

#pragma mark - TTSaveImageAlertViewDelegate

- (void)alertDidShow
{
    [self trackGalleryWithTag:@"slide_detail"
                        label:@"long_press"
                 appendExtkey:nil
               appendExtValue:nil];
}

- (void)shareButtonFired:(id)sender
{
    [self currentGalleryShareUseActivityController];
    [self destructSaveImageAlert];
    [self trackGalleryWithTag:@"slide_detail"
                        label:@"long_press_share_button"
                 appendExtkey:@"position"
               appendExtValue:@([_detailView currentShowGalleryProgress])];
}

- (void)saveButtonFired:(id)sender{
    if ([self isNativeImageDetail]) {
        [((ExploreImageDetailView *)_detailView) saveCurrentNativeGalleryIfCould];
    }
    else {
        self.saveImageManager = [[ExploreDetailSaveImageManager alloc] init];
        self.saveImageManager.imageUrl = [((ExploreDetailView *)_detailView) currentShowGalleryURL];
        [self.saveImageManager saveImageData];
    }
    [self destructSaveImageAlert];
    [self trackGalleryWithTag:@"slide_detail"
                        label:@"save_pic"
                 appendExtkey:@"position"
               appendExtValue:@([_detailView currentShowGalleryProgress])];
}

- (void)cancelButtonFired:(id)sender{
    [self destructSaveImageAlert];
}

#pragma mark - SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType {
    Article *currentArticle = [self.newsDetailViewModel sharedDetailManager].currentArticle;
    if (view == _phoneShareView) {
        if (itemType == TTActivityTypeReport) {
            self.phoneShareView = nil;
            if ([SSCommonLogic reportInWapPageEnabled]) {
                tt_openReportWapPageWithAdID([[_newsDetailViewModel sharedDetailManager] currentArticle].groupModel, self.adID, ReportSourceOthers, nil);
            }
            else {
                [self triggerReportAction];
            }
            [self sendDetailTTLogV2WithEvent:@"click_report" eventContext:nil referContext:nil];
            //有统计需求时用
            //            NSString *tag = [[[_newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]?@"slide_detail":@"detail";
            //            ssTrackEvent(tag, @"report_button");
        }
        else {
            NSString *groupId = [NSString stringWithFormat:@"%lld", [currentArticle.uniqueID longLongValue]];
            BOOL hasVideo = [self.article.hasVideo boolValue] || [self.article isVideoSubject];
            [self sendDetailTTLogV2WithEvent:[TTActivityShareManager shareTargetStrForTTLogWithType:itemType] eventContext:@{@"position":@"share_button"} referContext:nil];
            [_activityActionManager performActivityActionByType:itemType inViewController:[SSCommonAppExtension topViewControllerFor: self] sourceObjectType:hasVideo ? TTShareSourceObjectTypeVideoList : shareSourceType uniqueId:groupId adID:nil platform:TTSharePlatformTypeOfMain groupFlags:currentArticle.groupFlags];
            NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:shareSourceType];
            if (itemType == TTActivityTypeNone) {
                tag = [currentArticle isImageSubject] ? @"slide_detail" : @"detail";
            }
            NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
            [_newsDetailViewModel sendDetailTrackEventWithTag:tag label:label];
            self.phoneShareView = nil;
        }
    } else if (view == _moreSettingActivityView) {
        if (itemType == TTActivityTypePGC) {
            [self.moreSettingActivityView cancelButtonClicked];
            ssTrackEvent(@"detail", @"pgc_button");
            [self sendDetailTTLogV2WithEvent:@"click_display_setting" eventContext:nil referContext:nil];
            
            NSString *mediaID = [currentArticle.mediaInfo[@"media_id"] stringValue];
            NSString *enterSource = [currentArticle isImageSubject] ? kPGCProfileEnterSourceGalleryArticleMore : nil;
            [PGCWAPViewController openWithMediaID:mediaID enterSource:enterSource itemID:nil];
        }
        else if (itemType == TTActivityTypeNightMode){
            NSString *tag = [currentArticle isImageSubject] ? @"slide_detail" : @"detail";
            BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
            NSString * eventID = nil;
            if (isDayMode){
                [TTThemeManager sharedInstance_tt].currentThemeMode = TTThemeModeNight;
                eventID = @"click_to_night";
            }
            else{
                [TTThemeManager sharedInstance_tt].currentThemeMode = TTThemeModeDay;
                eventID = @"click_to_day";
            }
            ssTrackEvent(tag, eventID);
            //做一个假的动画效果 让夜间渐变
            UIView * imageScreenshot = [self.view.window snapshotViewAfterScreenUpdates:NO];
            
            [self.view.window  addSubview:imageScreenshot];
            
            [UIView animateWithDuration:0.5f animations:^{
                imageScreenshot.alpha = 0;
            } completion:^(BOOL finished) {
                [imageScreenshot removeFromSuperview];
            }];
            [self sendDetailTTLogV2WithEvent:eventID eventContext:nil referContext:nil];
        }
        else if (itemType == TTActivityTypeFontSetting){
            [self.moreSettingActivityView fontSettingPressed];
            [self sendDetailTTLogV2WithEvent:@"click_display_setting" eventContext:nil referContext:nil];
        }
        else if (itemType == TTActivityTypeReport){
            [self.moreSettingActivityView cancelButtonClicked];
            if ([SSCommonLogic reportInWapPageEnabled]) {
                tt_openReportWapPageWithAdID([[_newsDetailViewModel sharedDetailManager] currentArticle].groupModel, self.adID, ReportSourceOthers, nil);
            }
            else {
                [self triggerReportAction];
            }
            NSString *tag = [currentArticle isImageSubject]?@"slide_detail":@"detail";
            ssTrackEvent(tag, @"report_button");
            [self sendDetailTTLogV2WithEvent:@"click_report" eventContext:nil referContext:nil];
        }
        else if (itemType == TTActivityTypeFavorite) {
            [self triggerFavoriteAction:1];
        }else { // Share
            NSString *groupId = [NSString stringWithFormat:@"%lld", [[self.newsDetailViewModel sharedDetailManager].currentArticle.uniqueID longLongValue]];
            [self sendDetailTTLogV2WithEvent:[TTActivityShareManager shareTargetStrForTTLogWithType:itemType] eventContext:@{@"position":@"preferences"} referContext:nil];
            [_activityActionManager performActivityActionByType:itemType inViewController:[SSCommonAppExtension topViewControllerFor: self] sourceObjectType:shareSourceType uniqueId:groupId adID:nil platform:TTSharePlatformTypeOfMain groupFlags:[[_newsDetailViewModel sharedDetailManager] currentArticle].groupFlags];
            NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:shareSourceType];
            if (itemType == TTActivityTypeNone) {
                tag = [[[_newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]?@"slide_detail":@"detail";
                NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
                [_newsDetailViewModel sendDetailTrackEventWithTag:tag label:label];
                self.moreSettingActivityView = nil;
            }
            
            NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
            [_newsDetailViewModel sendDetailTrackEventWithTag:tag label:label];
        }
    } else if (view == _currentGalleryShareView) {
        NSString *fromSource = [_newsDetailViewModel clickFromLabel];
        _activityActionManager.groupModel = [[_newsDetailViewModel sharedDetailManager] currentArticle].groupModel;
        _activityActionManager.clickSource = fromSource;
        [_activityActionManager performActivityActionByType:itemType
                                           inViewController:[SSCommonAppExtension topViewControllerFor: self]
                                           sourceObjectType:TTShareSourceObjectTypeSingleGallery
                                                   uniqueId:[[_newsDetailViewModel sharedDetailManager] currentArticle].groupModel.groupID
                                                       adID:nil
                                                   platform:TTSharePlatformTypeOfMain
                                                 groupFlags:nil];
        NSString *tag = [TTActivityShareManager tagNameForShareSourceObjectType:shareSourceType];
        NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
        [_newsDetailViewModel sendDetailTrackEventWithTag:tag label:label];
    }
}

- (void)showProfileWithArticleFriend:(ArticleFriend *)articleFriend {
    if (isEmptyString(articleFriend.userID)) {
        return;
    }
    
    ArticleMomentProfileViewController * controller = [[ArticleMomentProfileViewController alloc] initWithUserID:articleFriend.userID];
    controller.from = kFromNewsDetailComment;
    UIViewController *topController = [SSCommonAppExtension topViewControllerFor: self];
    [topController.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark - Actions

- (void)refreshTaobaoDetailAdsIfNeeded
{
    if (![[[self.newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]) {
        [[SSUFPManager sharedManager] startFetchDetailPromoterForced];
    }
}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backViewItemPressed:(id)sender {
    BOOL couldSendPageBack = YES;
    YSWebView *webView = nil;
    if ([self.detailView.contentView respondsToSelector:@selector(webView)]) {
        webView = (YSWebView *)[(id)self.detailView.contentView webView];
    }
    if ([self.backButtonView isCloseButtonShowing]) {
        if (sender == self.backButtonView.backButton) {
            if ([webView canGoBack]) {
                [webView goBack];
            }
            else {
                couldSendPageBack = NO;
                [self goBack:sender];
            }
            self.backBtnTouched = YES;
        }
        else {
            couldSendPageBack = NO;
            if (self.backButtonView.closeButton == sender) {
                [self goBack:nil];
            } else {
                [self goBack:sender];
            }
        }
    } else {
        if ([webView canGoBack]) {
            [webView goBack];
            [self refreshLeftBarButtonItemsWithCloseButtonShown:YES];
        } else {
            couldSendPageBack = NO;
            self.backBtnTouched = YES;
            [self goBack:sender];
        }
    }
    
    NSString *tag = [[[_newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]?@"slide_detail":@"detail";
    if (sender == self.backButtonView.closeButton) {
        ssTrackEvent(tag, @"close_button");
        self.closeBtnTouched = YES;
    }
    else if (sender == self.backButtonView.backButton && couldSendPageBack) {
        ssTrackEvent(tag, @"page_back");
    }
}

- (void)moreButtonPressed {
    if (![TTDeviceHelper isPadDevice] && [self isImageDetail] &&
        UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        //iPhone图集横屏时
        [self systemShareUseActivityControllerWithShareGroupOnly:YES];
    }
    else {
        if ([[_newsDetailViewModel sharedDetailManager] currentDetailType] != ExploreDetailTypeSimple) {
            [_activityActionManager clearCondition];
            if (!_activityActionManager) {
                self.activityActionManager = [[TTActivityShareManager alloc] init];
                self.activityActionManager.clickSource = [self.newsDetailViewModel clickFromLabel];
            }
            ExploreDetailManager *manager = [self.newsDetailViewModel sharedDetailManager];
            BOOL isVideo = [[manager currentArticle] isVideoSubject] || !!(_flags & kArticleGroupFlagsDetailTypeVideoSubject);
            NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:[manager currentArticle] adID:[manager currentADID] showReport:isVideo];
            
            Article * currentArticle = [[self.newsDetailViewModel sharedDetailManager] currentArticle];
            
            //头条号icon
            if ([currentArticle.mediaInfo count] != 0) {
                NSString * avatarUrl = nil;
                if ([currentArticle.mediaInfo objectForKey:@"avatar_url"]) {
                    avatarUrl = currentArticle.mediaInfo[@"avatar_url"];
                }
                
                TTActivity *pgcActivity = [TTActivity activityOfPGCWithAvatarUrl:avatarUrl showName:nil];
                [activityItems insertObject:pgcActivity atIndex:0];
            }
            
            if ([[_newsDetailViewModel sharedDetailManager] currentDetailType] == ExploreDetailTypeNoComment ||
                [[_newsDetailViewModel sharedDetailManager] currentDetailType] == ExploreDetailTypeNoToolBar) {
                TTActivity * favorite = [TTActivity activityOfFavorite];
                [activityItems addObject:favorite];
            }
            TTActivity * nightMode = [TTActivity activityOfNightMode];
            [activityItems addObject:nightMode];
            
            //图集没有字体设置
            if (![currentArticle isImageSubject]) {
                TTActivity * fontSetting = [TTActivity activityOfFontSetting];
                [activityItems addObject:fontSetting];
            }
            if (!isVideo) {
                //非视频文章，举报放在最后
                TTActivity * reportActivity = [TTActivity activityOfReport];
                [activityItems addObject:reportActivity];
            }
            
            if (_moreSettingActivityView) {
                self.moreSettingActivityView = nil;
            }
            self.moreSettingActivityView = [[SSActivityView alloc] init];
            [self.moreSettingActivityView refreshCancelButtonTitle:@"取消"];
            _moreSettingActivityView.delegate = self;
            [_moreSettingActivityView setActivityItemsWithFakeLayout:activityItems];
            [_moreSettingActivityView show];
            
            shareSourceType = TTShareSourceObjectTypeArticleTop;
        }
        else if ([[self.newsDetailViewModel sharedDetailManager] currentDetailType] == ExploreDetailTypeSimple) {
            UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"用Safari打开", nil), NSLocalizedString(@"复制链接", nil), nil];
            actionSheet.tag = kPhoneSimpleTypeActionSheetTag;
            [actionSheet showInView:self.view];
        }
    }
    ssTrackEvent(@"detail", @"preferences");
    [self sendDetailTTLogV2WithEvent:@"click_preferences" eventContext:nil referContext:nil];
}

- (void)closeNatantButtonPressed {
    if ([self.detailView respondsToSelector:@selector(closeNatantView)]) {
        [self.detailView closeNatantView];
    }
}

- (void)destructSaveImageAlert
{
    if ([self isNativeImageDetail]) {
        if ([_detailView respondsToSelector:@selector(destructSaveImageAlert)]) {
            [((ExploreImageDetailView *)_detailView) destructSaveImageAlert];
        }
    }
    else {
        [self.saveImageManager destructSaveAlert];
    }
}

- (void)restorePortraitUIInterfaceIfNeeded
{
    if (![TTDeviceHelper isPadDevice] && [self isImageDetail]) {
        BOOL shouldRestore = NO;
        NSArray *navViewControllers = [[SSCommonAppExtension topNavigationControllerFor: self] viewControllers];
        if (navViewControllers.count) {
            UIViewController *topViewController = [navViewControllers lastObject];
            if (![topViewController isKindOfClass:self.class]) {
                shouldRestore = YES;
            }
        }
        else {
            shouldRestore = YES;
        }
        
        if (shouldRestore) {
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        }
    }
}

#pragma mark - TTLog2.0 tracker

- (void)sendDetailTTLogV2WithEvent:(NSString *)event
                      eventContext:(NSDictionary *)eventContext
                      referContext:(NSDictionary *)referContext
{
    if (event && [event isEqualToString:@"share_unkown"]) {
        return;
    }
    NSMutableDictionary *screenContext = [[NSMutableDictionary alloc] init];
    [screenContext setValue:_adID forKey:@"ad_id"];
    [screenContext setValue:self.article.itemID forKey:@"item_id"];
    [screenContext setValue:[self.article.uniqueID stringValue] forKey:@"group_id"];
    [TTLogManager logEvent:event context:eventContext screenName:kDetailScreen screenContext:screenContext referContext:referContext];
}

#pragma mark - Gallery tracker
- (void)trackGalleryWithTag:(NSString *)tag
                      label:(NSString *)label
               appendExtkey:(NSString *)key
             appendExtValue:(NSNumber *)extValue
{
    Article *currentArticle = [[_newsDetailViewModel sharedDetailManager] currentArticle];
    if (![article isImageSubject]) {
        return;
    }
    
    NSMutableDictionary *extDict = [NSMutableDictionary dictionary];
    [extDict setValue:currentArticle.groupModel.itemID forKey:@"item_id"];
    if (!isEmptyString(key)) {
        [extDict setValue:extValue forKey:key];
    }
    ssTrackEventWithCustomKeys(tag, label, currentArticle.groupModel.groupID, nil, extDict);
}

#pragma mark - StayPage tracker
- (void)startStayPageTrackerIfNeeded
{
    //视频详情页在ExploreVideoDetailView里单独统计
    if ([_detailView isKindOfClass:[ExploreVideoDetailView class]]) {
        return;
    }
    [[self.newsDetailViewModel sharedDetailManager] startStayTracker];
}

- (void)endStayPageTrackerIfNeed
{
    if ([_detailView isKindOfClass:[ExploreVideoDetailView class]]) {
        return;
    }
    [[self.newsDetailViewModel sharedDetailManager] endStayTracker];
}

#pragma mark - ViewModel

- (void)refreshDetailViewModel
{
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:_adID forKey:kNewsDetailViewConditionADIDKey];
    [condition setValue:_categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
    [condition setValue:_relateReadFromGID forKey:kNewsDetailViewConditionRelateReadFromGID];
    [condition setValue:_statParams forKey:kNewsDetailViewCustomStatParamsKey];
    [condition setValue:_gdExtJsonDict forKey:kNewsDetailViewExtJSONKey];
    [condition setValue:_adLogExtra forKey:kNewsDetailViewConditionADLogExtraKey];
    
    //构建viewModel
    NSMutableDictionary *newsDetailInfo = [NSMutableDictionary dictionaryWithCapacity:4];
    [newsDetailInfo setValue:self.article forKey:kNewsArticleKey];
    [newsDetailInfo setValue:@(self.fromSource) forKey:kNewsFromSourceKey];
    [newsDetailInfo setValue:condition forKey:kNewsDetailConditionKey];
    [newsDetailInfo setValue:@(self.beginShowComment) forKey:kNewsShowCommentKey];
    [newsDetailInfo setValue:self.adOpenUrl forKey:kNewsAdOpenUrlKey];
    [newsDetailInfo setValue:self.adLogExtra forKey:kNewsDetailViewConditionADLogExtraKey];
    
    self.newsDetailViewModel = [[NewsDetailViewModel alloc] initWithNewsDetailInfo:newsDetailInfo
                                                                       orderedData:self.orderedData
                                                                           gdLabel:self.gdLabel
                                                                    originalSchema:self.originalSchema];
}

#pragma mark - Helper

- (void)largeImageViewDisplayed:(NSNotification*)notification {
    _hiddenByDisplayImage = YES;
}

- (BOOL)isImageDetail
{
    Article *currentArticle = [[self.newsDetailViewModel sharedDetailManager] currentArticle];
    return ([currentArticle isImageSubject] || _flags & 0x10000);
}

- (BOOL)isNativeImageDetail
{
    Article *currentArticle = [[self.newsDetailViewModel sharedDetailManager] currentArticle];
    /// 和秋良老师确认，如果Article能找到title，则认为是可依赖的
    BOOL isArticleReliable = !isEmptyString(currentArticle.title);
    return ([self isImageDetail] && (isArticleReliable && currentArticle.articleType.integerValue == ArticleTypeNativeContent)) || ((_flags & 0x10000) && currentArticle.articleType.integerValue == ArticleTypeNativeContent) || [_detailView isKindOfClass:[ExploreImageDetailView class]];
}

#pragma mark -- share

- (void)systemShareUseActivityController {
    return [self systemShareUseActivityControllerWithShareGroupOnly:NO];
}

- (void)systemShareUseActivityControllerWithShareGroupOnly:(BOOL)useShareGroupOnly
{
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.clickSource = [self.newsDetailViewModel clickFromLabel];
    }
    
    ExploreDetailManager *manager = [self.newsDetailViewModel sharedDetailManager];
    BOOL isVideo = [[manager currentArticle] isVideoSubject] || !!(_flags & kArticleGroupFlagsDetailTypeVideoSubject);
    NSMutableArray * activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setArticleCondition:[manager currentArticle] adID:[manager currentADID] showReport:isVideo];
    if (_activityActionManager.useDefaultImage && [self.detailView isKindOfClass:[ExploreVideoDetailView class]]) {
        UIImage *image = [((ExploreVideoDetailView *)self.detailView).movieShotView logoImage];
        if (image) {
            _activityActionManager.shareImage = image;
            _activityActionManager.systemShareImage = image;
        }
    }
    
    self.phoneShareView = [[SSActivityView alloc] init];
    _phoneShareView.delegate = self;
    _phoneShareView.activityItems = activityItems;
    [_phoneShareView showOnViewController:[SSCommonAppExtension topViewControllerFor: self] useShareGroupOnly:useShareGroupOnly];
    
    //点击分享按钮统计
    if (![[[_newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]) {
        NSString *tag =  @"detail";
        [_newsDetailViewModel sendDetailTrackEventWithTag:tag label:@"share_button"];
        
    }
    
    shareSourceType = TTShareSourceObjectTypeArticle;
}

- (void)currentGalleryShareUseActivityController {
    //图集分享单张图片，带水印
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
        self.activityActionManager.clickSource = [self.newsDetailViewModel clickFromLabel];
    }
    
    NSMutableArray * activityItems;
    if ([self isNativeImageDetail]) {
        UIImage *galleryImage = [((ExploreImageDetailView *)_detailView) currentNativeGalleryImage];
        UIImage *maskImage = [UIImage themedImageNamed:@"photo_watermark.png"];
        UIEdgeInsets edge = UIEdgeInsetsMake(0, 0, 12.f, 9.f);
        CGFloat left = galleryImage.size.width - maskImage.size.width - edge.right;
        CGFloat top = galleryImage.size.height - maskImage.size.height - edge.bottom;
        CGFloat width = maskImage.size.width;
        CGFloat height = maskImage.size.height;
        //对长条图做简单适配
        if (left < 0) {
            width = galleryImage.size.width/2 - edge.right/2;
            height = width * maskImage.size.height / maskImage.size.width;
            left = galleryImage.size.width/2;
            top = galleryImage.size.height - height - edge.bottom/2;
        }
        CGRect maskRect = CGRectMake(left, top, width, height);
        UIImage *galleryImageWithMask = [galleryImage tt_imageWithMaskImage:maskImage inRect:maskRect];
        
        activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setNativeGalleryImage:galleryImageWithMask webGalleryURL:nil];
    }
    else {
        //实际上5.4版本没打开URL分享方式入口，因为获取不到缩略图、水印等问题
        NSString *webGalleryURL = [((ExploreDetailView *)_detailView) currentShowGalleryURL];
        activityItems = [ArticleShareManager shareActivityManager:_activityActionManager setNativeGalleryImage:nil webGalleryURL:webGalleryURL];
    }
    
    self.currentGalleryShareView = [[SSActivityView alloc] init];
    self.currentGalleryShareView.delegate = self;
    self.currentGalleryShareView.activityItems = activityItems;
    [self.currentGalleryShareView showOnViewController:[SSCommonAppExtension topViewControllerFor: self]
                                     useShareGroupOnly:YES];
    
    shareSourceType = TTShareSourceObjectTypeSingleGallery;
}

#pragma mark - ExploreDetailMoreSettingDelegate

- (void)exploreDetailMoreSettingManagerDidTrigReportAction {
    [self triggerReportAction];
}

#pragma mark - ExploreDetailViewDelegate

- (void)exploreDetailViewDidPopFromRightSwip {
    [self goBack:nil];
}

- (void)exploreDetailView:(NewsDetailViewModel *)detailViewModel notifyWebViewConentLoadedWithError:(NSError *)error {
    if (error == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //初始化navigationBar
            [self refreshNavBarWithForcedShownEscapeButton:NO];
        });
    }
}

- (void)exploreDetailView:(NewsDetailViewModel *)detailViewModel refreshTitleViewWithTitle:(NSString *)title url:(NSString *)url {
    
}

- (void)exploreDetailView:(NewsDetailViewModel *)detailViewModel shouldShowCloseNatantButton:(BOOL)shouldShow {

}

- (void)exploreDetailViewShouldLoadNativeView
{
    if ([[[_newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]) {
        NSLog(@"webGallery timeout, try to load nativeGallery");
        [self loadNativeImageDetailView];
    }
    else {
        NSLog(@"webContent timeout, try to load nativeContent");
        [self loadArticleDetailViewWithForceNative:YES];
    }
}

#pragma mark - SSWebViewAddressBarDelegate
- (void)addressBar:(SSWebViewAddressBar *)bar prepareLoadURLString:(NSString *)urlStr {
    NSURL * url = [TTStringHelper URLWithURLString:urlStr];
    
    if (!url) {
        url = [TTStringHelper URLWithURLString:[urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if (url.scheme == nil) {
        NSString * tempURLString = [NSString stringWithFormat:@"http://%@", urlStr];
        url = [TTStringHelper URLWithURLString:tempURLString];
    }
    
    SSWebViewController * controller = [[SSWebViewController alloc] init];
    [controller setTitleText:NSLocalizedString(@"网页浏览", nil)];
    [controller showAddressBar:YES];
    [controller requestWithURL:url];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UIApplicationNotification
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // 如果加载期间切换到后台，则放弃这一次统计
    [self endStayPageTrackerIfNeed];
    if ([self.detailView respondsToSelector:@selector(applicationDidEnterBackground:)]) {
        [self.detailView applicationDidEnterBackground:notification];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self startStayPageTrackerIfNeeded];
    if ([self.detailView respondsToSelector:@selector(applicationWillEnterForeground:)]) {
        [self.detailView applicationWillEnterForeground:notification];
    }
}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)notification {
    if ([self.detailView respondsToSelector:@selector(applicationDidChangeStatusBarOrientation:)]) {
        [self.detailView applicationDidChangeStatusBarOrientation:notification];
    }
    
    [self.phoneShareView dismissWithAnimation:NO];
    [self.moreSettingActivityView cancelButtonClickedWithAnimation:NO];
    [self.currentGalleryShareView dismissWithAnimation:NO];
    [self destructSaveImageAlert];
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [self trackGalleryWithTag:@"slide_detail"
                            label:@"rotate_screen"
                     appendExtkey:nil
                   appendExtValue:nil];
    }
}

@end

@implementation NewsDetailViewController (NewsDetailActions)

- (void)triggerLikeAction {
    BOOL liked = ![[[self.newsDetailViewModel sharedDetailManager] currentArticle].userLike boolValue];
    [[self.newsDetailViewModel sharedDetailManager] saveLikeOriginalDataState:liked];
    self.detailActionRequestManager = [[DetailActionRequestManager alloc] init];
    NSMutableDictionary *condition = [NSMutableDictionary dictionary];
    if ([[_newsDetailViewModel sharedDetailManager] currentArticle].groupModel) {
        condition[kDetailActionGroupModelKey] = [[_newsDetailViewModel sharedDetailManager] currentArticle].groupModel;
    }
    //TODO:换成“喜欢”标志位
    if ([[_newsDetailViewModel sharedDetailManager] currentADID]) {
        condition[kDetailActionADIDKey] = [[_newsDetailViewModel sharedDetailManager] currentADID];
    }
    [self.detailActionRequestManager setCondition:condition];
    self.detailActionRequestManager.delegate = (id<DetailActionRequestManagerDelegate>)self;
    DetailActionRequestType requestType = liked ? DetailActionTypeLike : DetailActionTypeUnlike;
    [self.detailActionRequestManager startItemActionByType:requestType];
    
    NSString *label = liked ? @"like" : @"like_cancel";
    NSString *tag = [[[_newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject]?@"slide_detail":@"detail";
    [NewsDetailLogicManager trackEventTag:tag
                                    label:label
                                    value:[[_newsDetailViewModel sharedDetailManager] currentArticle].uniqueID
                                 extValue:nil
                                     adID:[[_newsDetailViewModel sharedDetailManager] currentADID]
                               groupModel:[[_newsDetailViewModel sharedDetailManager] currentArticle].groupModel];
    if (liked) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"将增加推荐此类内容" indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
}

- (void)triggerReportAction {
    if ([self.detailView respondsToSelector:@selector(HTMLForArticleReportWithCompletionHandler:)]) {
        __weak typeof(self) wself = self;
        [self.detailView HTMLForArticleReportWithCompletionHandler:^(NSString * _Nullable result) {
            __strong typeof(wself) self = wself;
            NSString *html = result;
            [self reportAction:html];
        }];
    } else {
        [self reportAction:nil];
    }
}

- (void)reportAction:(NSString *)html
{
    ExploreDetailManager *manager = [self.newsDetailViewModel sharedDetailManager];
    
    ArticleReportViewController * reportViewController;
    
    if ([[manager currentArticle].hasVideo boolValue]) {
        reportViewController = [[ArticleReportViewController alloc] initWithGroupModel:[manager currentArticle].groupModel videoID:[manager currentArticle].videoID viewStyle:ArticleReportViewNormalStyle reportType:ArticleReportVideo source:@"detail"];
    } else {
        reportViewController = [[ArticleReportViewController alloc] initWithGroupModel:[manager currentArticle].groupModel html:html viewStyle:ArticleReportViewNormalStyle reportType:ArticleReportArticle source:@"detail"];
        reportViewController.adId = [manager currentADID].stringValue;
    }
    
    TTNavigationController * nav = [[TTNavigationController alloc] initWithRootViewController:reportViewController];
    
    nav.ttDefaultNavBarStyle = @"White";
    
    if ([TTDeviceHelper isPadDevice]) {
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [[SSCommonAppExtension topViewControllerFor: self] presentViewController:nav animated:YES completion:NULL];
}

- (void)triggerFavoriteAction:(double)readPct {
    [[_newsDetailViewModel sharedDetailManager] changeFavoriteButtonClicked:readPct];
    
    ExploreDetailManager *manager = [self.newsDetailViewModel sharedDetailManager];
    
    if ([[manager currentArticle].userRepined boolValue]) {
        // 收藏生效
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (![[AccountManager sharedManager] isLogin] && ![self hasTipFavLoginUserDefaultKey]) {
                
                ssTrackEvent(@"pop", @"login_detail_favor_show");
                
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"登录后云端同步保存收藏，建议先登录", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                    
                    ssTrackEvent(@"pop", @"login_detail_favor_cancel");
                    
                    [self setHasTipFavLoginUserDefaultKey:YES];
                }];
                [alert addActionWithTitle:NSLocalizedString(@"去登录", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                    
                    ssTrackEvent(@"pop", @"login_detail_favor_open");
                    if ([SSCommonLogic accountABVersionEnabled]) {
                        [AccountManager showLoginAlertWithType:TTAccountAlertTitleTypeFavor source:@"detail_first_favor" completed:^(TTAlertComplete type, NSString *phoneNum) {
                            if (type == TTAlertCompleteTip) {
                                [AccountManager presentQuickLoginFromVC:[SSCommonAppExtension topNavigationControllerFor:self] type:TTLoginDialogTitleTypeDefault source:@"detail_first_favor" completionnHandler:^(TTQuickLoginState state) {
                                }];
                            }
                        }];
                    }
                    else {
                        ArticleLoginViewController * controller = [[ArticleLoginViewController alloc] init];
                        [[SSCommonAppExtension topNavigationControllerFor: nil] pushViewController:controller animated:YES];
                    }
                    [self setHasTipFavLoginUserDefaultKey:YES];
                }];
                [alert showFrom:[SSCommonAppExtension topmostViewController] animated:YES];
            }
        });
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kPhoneSimpleTypeActionSheetTag) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if (buttonIndex == 0) {
                [[self.newsDetailViewModel sharedDetailManager] openUseSafari];
            }
            else if (buttonIndex == 1) {
                [[self.newsDetailViewModel sharedDetailManager] copyText];
            }
        }
    }
}

#define kHasTipFavLoginUserDefaultKey @"kHasTipFavLoginUserDefaultKey"

- (void) setHasTipFavLoginUserDefaultKey:(BOOL) hasTip {
    [[NSUserDefaults standardUserDefaults] setBool:hasTip forKey:kHasTipFavLoginUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) hasTipFavLoginUserDefaultKey {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasTipFavLoginUserDefaultKey];
}

- (void)triggerBackAction {
    self.backBtnTouched = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation NewsDetailViewController (ImageSubject)

- (BOOL)isNewsDetailForImageSubject
{
    return [[[self.newsDetailViewModel sharedDetailManager] currentArticle] isImageSubject];
}

//有小窗视频播放时，禁止旋转
- (BOOL)canRotateNewsDetailForImageSubject
{
    UIViewController *vc = [SSCommonAppExtension topmostViewController].presentedViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        if (nav.viewControllers.count > 0) {
            NewsDetailViewController *detailVC = nav.viewControllers[0];
            if ([detailVC isKindOfClass:[NewsDetailViewController class]]) {
                if ([detailVC.detailView isKindOfClass:[ExploreVideoDetailView class]]) {
                    return NO;
                }
            }
        }
    }
    return YES;
}
@end
