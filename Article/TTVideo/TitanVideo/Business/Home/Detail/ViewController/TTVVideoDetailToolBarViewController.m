//
//  TTVVideoDetailToolBarViewController.m
//  Article
//
//  Created by pei yun on 2017/5/10.
//
//

#import "TTVVideoDetailToolBarViewController.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "TTVVideoArticle+Extension.h"
#import "ArticleInfoManager.h"
#import "ArticleShareManager.h"
#import "TTActivityShareManager.h"
#import "TTDetailModel.h"
#import "TTDetailModel+videoArticleProtocol.h"
#import "SSActivityView.h"
#import "TTAdManager.h"
#import "TTActionSheetController.h"
#import "TTReportManager.h"
#import "TTVideoCallbackTaskGlobalQueue.h"
#import "TTNetworkManager.h"
#import "ExploreDetailToolbarView.h"
#import "TTDetailModel+TTVTrackToolbarMode.h"
#import "NewsDetailLogicManager.h"
#import "SSCommentInputHeader.h"
#import "TTCommentWriteView.h"
#import "TTVVideoDetailCollectService.h"
#import "TTVVideoDetailVCDefine.h"
#import "TTVideoTip.h"
#import "ExploreItemActionManager.h"
#import "ArticleMobileLoginViewController.h"
#import "TTCommentViewController.h"
#import "TTVWhiteBoard.h"
#import "TTVideoDetailHeaderPosterView.h"
#import "TTVVideoDetailStayPageTracker.h"
#import "TTVContainerScrollView.h"
#import "TTVCommentViewController.h"
#import "KVOController.h"
#import "TTUIResponderHelper.h"
#import "ExploreMovieView.h"
#import "TTAccountManager.h"
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"
//#import <TTRepostServiceProtocol.h>
//#import "TTRepostService.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
#import "TTVShareDetailTracker.h"
//#import "TTShareToRepostManager.h"
#import "TTVDetailPlayControl.h"
#import "TTVPlayVideo.h"
#import <BDTArticle/Article.h>
//新分享库
#import <TTShareActivity.h>
#import <TTShareManager.h>
#import "TTPanelActivity.h"
#import "TTAdPromotionContentItem.h"
#import "NSDictionary+TTGeneratedContent.h"
#import "TTWebImageManager.h"
#import "TTDiggActivity.h"
#import "TTBuryActivity.h"
#import "TTCommodityActivity.h"
#import "TTActivityShareSequenceManager.h"
#import "TTShareMethodUtil.h"
//#import "TTThreadDeleteContentItem.h"
#import "ExploreOrderedData.h"
#import "TTKitchenHeader.h"
#import "BDPlayerObjManager.h"
#import "TTDirectForwardWeitoutiaoContentItem.h"
#import <TTDirectForwardWeitoutiaoActivity.h>
#import "TTVVideoDetailViewController.h"
//#import "TTRepostService.h"

//爱看
#import "AKAwardCoinManager.h"
#import "AKHelper.h"

extern BOOL ttvs_isShareIndividuatioEnable(void);
extern NSInteger ttvs_isShareTimelineOptimize(void);

typedef NS_ENUM(NSUInteger, TTVActivityClickSourceFrom) {
    TTVActivityClickSourceFromPlayerMore ,
    TTVActivityClickSourceFromPlayerShare,
    TTVActivityClickSourceFromPlayerDirect,
    TTVActivityClickSourceFromCentreButton,
    TTVActivityClickSourceFromCentreButtonDirect,
    TTVActivityClickSourceFromListMore,
    TTVActivityClickSourceFromListShare,
    TTVActivityClickSourceFromDetailVideoOver,
    TTVActivityClickSourceFromListVideoOver,
    TTVActivityClickSourceFromDetailBottomBar,
    TTVActivityClickSourceFromListVideoOverDirect,
    TTVActivityClickSourceFromDetailVideoOverDirect
};

extern NSString *const assertDesc_articleType;
NSString *const SECTIONTYPE = @"sectionType";
NSString *const ISFULLSCREEN = @"isFullScreen";
NSString *const OLDSHAREPANEL = @"oldSharePanel";
NSString *const NEWSHAREPANEL = @"newSharePanel";
NSString *const BOTTOMBAR = @"bottomBar";

extern BOOL ttvs_isShareIndividuatioEnable(void);
extern NSInteger ttvs_isShareTimelineOptimize(void);

//static NSString * _Nonnull const TTVideoDetailViewControllerDeleteVideoArticle = @"TTVideoDetailViewControllerDeleteVideoArticle";

@interface TTVVideoDetailToolBarViewController () <SSActivityViewDelegate, TTCommentWriteManagerDelegate, TTVVideoDetailCollectServiceDelegate, TTActivityShareManagerDelegate, TTVDetailContext, TTShareManagerDelegate>

@property (nonatomic, strong) ExploreDetailToolbarView            *toolbarView;
@property (nonatomic, strong) TTActivityShareManager              *activityActionManager;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@property (nonatomic, strong) TTCommentWriteView           *commentWriteView;

@property (nonatomic, assign) BOOL isCommentButtonClicked;
@property (nonatomic, assign) BOOL shouldSendCommentTrackEvent;

@property (nonatomic, strong) TTVVideoDetailCollectService *collectService;
@property (nonatomic, assign) BOOL registeredKVO;
@property (nonatomic, strong) NSMutableDictionary *shareSectionAndEventDic; //event3的额外字典
@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;
@property (nonatomic, strong) SSActivityView *phoneShareView;
@property (nonatomic, strong) TTShareManager * shareManager;

/**
 *  UGC滚到评论区, 从TTDetailModel中迁移过来的
 */
@property (nonatomic, assign) BOOL beginShowCommentUGC;
/**
 *  UGC拉出评论框, 同上
 */
@property (nonatomic, assign) BOOL beginWriteCommentUGC;

@property (nonatomic, assign) BOOL beginShowComment;

@end

@implementation TTVVideoDetailToolBarViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initShowStatus];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification) name:UIKeyboardWillHideNotification object:nil];

    }
    return self;
}

- (void)setDetailModel:(TTDetailModel *)detailModel
{
    _detailModel = detailModel;
    
    NSDictionary *params = detailModel.baseCondition;
    self.beginShowCommentUGC = [params tt_boolValueForKey:@"showCommentUGC"];
    self.beginWriteCommentUGC = [params tt_boolValueForKey:@"writeCommentUGC"];
    self.beginShowComment = [params tt_boolValueForKey:@"showcomment"];
    self.shouldSendCommentTrackEvent = !(self.beginShowComment || self.beginShowCommentUGC);
}

- (void)setReloadVideoInfoFinished:(BOOL)reloadVideoInfoFinished
{
    _reloadVideoInfoFinished = reloadVideoInfoFinished;
    
    if (reloadVideoInfoFinished) {
        [self updateToolbar];
        [self addKVO];
    }
}

- (void)setBanEmojiInput:(BOOL)banEmojiInput
{
    _banEmojiInput = banEmojiInput;
    if ([self isViewLoaded]) {

        BOOL isBanRepostOrEmoji = ![KitchenMgr getBOOL:KKCCommentRepostFirstDetailEnable] || (self.detailModel.adID > 0)  || ak_banEmojiInput();
        self.toolbarView.banEmojiInput = banEmojiInput || isBanRepostOrEmoji;
        if(self.commentWriteView) {
            self.commentWriteView.banEmojiInput = banEmojiInput;
        }
    }
}

- (void)setWriteButtonPlayHoldText:(NSString *)writeButtonPlayHoldText{
    _writeButtonPlayHoldText = writeButtonPlayHoldText;
    [self.toolbarView.writeButton setTitle:writeButtonPlayHoldText forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toolbarView.frame = self.view.bounds;
    if ([TTDeviceHelper isPadDevice]) {
        self.banEmojiInput = YES;
    }
    [self.view addSubview:self.toolbarView];
    [self.whiteboard setValue:@(self.isCommentButtonClicked) forKey:@"isCommentButtonClicked"];
}

- (void)_initShowStatus
{
    self.showStatus = TTVVideoDetailViewShowStatusVideo;
    self.enableScrollToChangeShowStatus = YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // add by zjing safeArea
    CGFloat safeInsetBottom = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        safeInsetBottom = 34;
    }
    self.view.height = ExploreDetailGetToolbarHeight() + safeInsetBottom;
    
    self.toolbarView.frame = self.view.bounds;
}

- (TTShareManager *)shareManager {
    if (nil == _shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

#pragma mark - TTVWhiteBoard methods

- (TTVideoDetailHeaderPosterView *)movieShotView
{
    id value = [self.whiteboard valueForKey:@"movieShotView"];
    if ([value isKindOfClass:[TTVideoDetailHeaderPosterView class]]) {
        return (TTVideoDetailHeaderPosterView *)value;
    } else {
        return nil;
    }
}

- (ExploreMovieView *)movieView
{
    id value = [self.whiteboard valueForKey:@"movieView"];
    if ([value isKindOfClass:[ExploreMovieView class]]) {
        return (ExploreMovieView *)value;
    } else {
        return nil;
    }
}

- (TTVVideoDetailStayPageTracker *)tracker
{
    id value = [self.whiteboard valueForKey:@"tracker"];
    if ([value isKindOfClass:[TTVVideoDetailStayPageTracker class]]) {
        return (TTVVideoDetailStayPageTracker *)value;
    } else {
        return nil;
    }
}


- (BOOL)isBackAction
{
    return self.detailStateStore.state.isBackAction;
}

- (TTVCommentViewController *)commentVC
{
    id value = [self.whiteboard valueForKey:@"commentVC"];
    if ([value isKindOfClass:[TTVCommentViewController class]]) {
        return (TTVCommentViewController *)value;
    } else {
        return nil;
    }
}

- (TTVDetailPlayControl *)playControl{
    id value = [self.whiteboard valueForKey:@"playControl"];
    if ([value isKindOfClass:[TTVDetailPlayControl class]] ) {
        return (TTVDetailPlayControl *)value;
    }else{
        return nil;
    }
}

- (BOOL)beginShowComment
{
    id value = [self.whiteboard valueForKey:@"beginShowComment"];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value boolValue];
    } else {
        return NO;
    }
}

- (void)_scrollToCommentListHeadAnimated:(BOOL)animated
{
    if (_homeActionDelegate && [_homeActionDelegate respondsToSelector:@selector(_scrollToCommentListHeadAnimated:)]) {
        [_homeActionDelegate _scrollToCommentListHeadAnimated:animated];
    }
}

#pragma mark -

- (ExploreDetailToolbarView *)toolbarView
{
    if (!_toolbarView) {
        _toolbarView = [[ExploreDetailToolbarView alloc] init];
        _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        _toolbarView.toolbarType = ExploreDetailToolbarTypeNormal;
        _toolbarView.fromView = ExploreDetailToolbarFromViewVideoDetail;
        _toolbarView.viewStyle = TTDetailViewStyleDarkContent;
        [_toolbarView.writeButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.emojiButton addTarget:self action:@selector(_writeCommentActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.commentButton addTarget:self action:@selector(_showCommentActionFired) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.topButton addTarget:self action:@selector(_showCommentActionFired) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.collectButton addTarget:self action:@selector(_collectActionFired) forControlEvents:UIControlEventTouchUpInside];
        [_toolbarView.shareButton addTarget:self action:@selector(_bottomShareActionFired) forControlEvents:UIControlEventTouchUpInside];
        _toolbarView.topButton.alpha = 0.f;
        _toolbarView.topButton.hidden = NO;
        
        [self.detailModel trackToolbarMode];
    }
    return _toolbarView;
}

- (TTActivityShareManager *)activityActionManager
{
    if (!_activityActionManager) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
        _activityActionManager.delegate = self;
        _activityActionManager.isVideoSubject = YES;
    }
    return _activityActionManager;
}

- (void)updateToolbar
{
    self.toolbarView.collectButton.selected = self.detailModel.protocoledArticle.userRepined;
    self.toolbarView.commentBadgeValue = [NSString stringWithFormat:@"%d",self.detailModel.protocoledArticle.commentCount];
}

- (NSDictionary *)userInfo
{
    if (self.detailModel.protocoledArticle.detailUserInfo) {
        return self.detailModel.protocoledArticle.detailUserInfo;
    } else {
        return self.detailModel.protocoledArticle.userInfo;
    }
}

- (void)keyboardWillHideNotification
{
    if (self.commentWriteView && self.commentWriteView.emojiInputViewVisible){
        return ;
    }

    if (self.commentWriteView) {
        [self.commentWriteView dismissAnimated:NO];
    }
}

#pragma mark - KVO

- (void)addKVO
{
    if (!self.registeredKVO) {
        @weakify(self);
        [self.KVOController observe:self.detailModel.protocoledArticle keyPaths:@[NSStringFromSelector(@selector(userRepined))] options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            @strongify(self);
            [self updateToolbar];
        }];
        [self.KVOController observe:self.detailModel.protocoledArticle keyPaths:@[NSStringFromSelector(@selector(commentCount))] options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            @strongify(self);
            [self updateToolbar];
            if ([change[NSKeyValueChangeOldKey] isKindOfClass:[NSNumber class]] && [change[NSKeyValueChangeNewKey] isKindOfClass:[NSNumber class]] && [change[NSKeyValueChangeOldKey] intValue] != [change[NSKeyValueChangeNewKey] intValue]) {
                NSString *uniqueIDStr = [NSString stringWithFormat:@"%lld", self.detailModel.protocoledArticle.uniqueID];
                SAFECALL_MESSAGE(TTVFeedUserOpDataSyncMessage, @selector(ttv_message_feedCommentCountChanged:uniqueIDStr:), ttv_message_feedCommentCountChanged:self.detailModel.protocoledArticle.commentCount uniqueIDStr:uniqueIDStr);
            }
        }];
        
        //        [self.KVOController observe:self.relatedVideoGroup keyPath:NSStringFromSelector(@selector(frame)) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        //            __strong typeof(wself) self = wself;
        //            self.wrapperScroller.contentSize = CGSizeMake(self.wrapperScroller.width, self.relatedVideoGroup.height + self.distinctNatantTitle.bottom);
        //        }];
        
        self.registeredKVO = YES;
    }
    
}

#pragma mark - Actions

- (void)_writeCommentActionFired:(id)sender
{
    BOOL switchToEmojiInput = (sender == self.toolbarView.emojiButton);
    if (switchToEmojiInput) {
        [TTTrackerWrapper eventV3:@"emoticon_click" params:@{
            @"status" : @"no_keyboard",
            @"source" : @"comment"
        }];
    }
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] initWithCapacity:5];
    [paramsDict setValue:self.videoInfo.itemID forKey:@"item_id"];
    [paramsDict setValue:self.videoInfo.groupModel.groupID forKey:@"group_id"];
    [paramsDict setValue:self.videoInfo.aggrType forKey:@"aggr_type"];
    [TTTrackerWrapper eventV3:@"comment_write_button" params:paramsDict];
    BOOL isFinish = NO;
    if (self.WriteButtonActionFired) {
       isFinish = self.WriteButtonActionFired();
    }
    if (!isFinish) {
        [self _openCommentWithText:nil switchToEmojiInput:switchToEmojiInput];
    }
}

- (void)_writeCommentActionFired
{
    BOOL isFinish = NO;
    if (self.WriteButtonActionFired) {
        isFinish = self.WriteButtonActionFired();
    }
    if (!isFinish) {
        [self _openCommentWithText:nil switchToEmojiInput:NO];
    }
}

- (void)_showCommentActionFired
{
    self.isCommentButtonClicked = YES;
    self.enableScrollToChangeShowStatus = NO;
    [self _switchShowStatusAnimated:YES isButtonClicked:YES];
    
    if (self.showStatus == TTVVideoDetailViewShowStatusVideo) {
        self.showStatus = TTVVideoDetailViewShowStatusComment;
    } else {
        self.showStatus = TTVVideoDetailViewShowStatusVideo;
    }
    if (self.homeActionDelegate && [self.homeActionDelegate respondsToSelector:@selector(vdvi_changeMovieSizeWithStatus:)]) {
        [self.homeActionDelegate vdvi_changeMovieSizeWithStatus:self.showStatus];
    }
}

- (void)_collectActionFired
{
    if (!TTNetworkConnected()){
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                 indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }
    
    self.toolbarView.collectButton.imageView.contentMode = UIViewContentModeCenter;
    self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    self.toolbarView.collectButton.alpha = 1.f;
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        self.toolbarView.collectButton.alpha = 0.f;
    } completion:^(BOOL finished){
        [self _triggerFavoriteActionWithButtonSeat:BOTTOMBAR];
        [self favoriteLog3];
        [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self.toolbarView.collectButton.alpha = 1.f;
        } completion:nil];
    }];
}

- (void)_openCommentWithText:(NSString *)text switchToEmojiInput:(BOOL)switchToEmojiInput {
    id<TTVArticleProtocol> article = self.detailModel.protocoledArticle;

    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:article.groupModel forKey:kQuickInputViewConditionGroupModel];
    [condition setValue:[NSNumber numberWithBool:article.hasImage] forKey:kQuickInputViewConditionHasImageKey];
    //    [condition setValue:[manager currentADID] forKey:kQuickInputViewConditionADIDKey];
    [condition setValue:self.detailModel.adID forKey:kQuickInputViewConditionADIDKey];

    NSString *mediaID = [article.mediaInfo[@"media_id"] stringValue];
    if ([article hasVideoSubjectID]) {
        mediaID = [article.detailMediaInfo[@"media_id"] stringValue];
    }
    [condition setValue:mediaID forKey:kQuickInputViewConditionMediaID];

    NSString *fwID = self.detailModel.article.groupModel.groupID;

    TTArticleReadQualityModel *qualityModel = [[TTArticleReadQualityModel alloc] init];
    float readPct = self.movieView.duration > 0 ? self.movieView.currentPlayingTime/self.movieView.duration : 0;
    NSInteger percent = MAX(0, MIN((NSInteger)(readPct * 100), 100));
    qualityModel.readPct = @(percent);
    qualityModel.stayTimeMs = @([self.tracker currentStayDuration]);

    TTCommentWriteManager *commentManager = [[TTCommentWriteManager alloc] initWithCommentCondition:condition commentViewDelegate:self commentRepostBlock:^(NSString *__autoreleasing *willRepostFwID) {
        *willRepostFwID = fwID;
    } extraTrackDict:nil bindVCTrackDict:nil commentRepostWithPreRichSpanText:nil readQuality:qualityModel];

    self.commentWriteView = [[TTCommentWriteView alloc] initWithCommentManager:commentManager];
    
    self.commentWriteView.emojiInputViewVisible = switchToEmojiInput;

    // writeCommentView 禁表情
    self.commentWriteView.banEmojiInput = self.banEmojiInput;
    [self.commentWriteView showInView:nil animated:YES];
}

- (void)_switchShowStatusAnimated:(BOOL)animated isButtonClicked:(BOOL)clicked
{
    dispatch_block_t block = ^ {
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            if (!self.isBackAction) {
                [self _openCommentWithText:nil switchToEmojiInput:NO];
            }
        });
    };
    if (self.showStatus == TTVVideoDetailViewShowStatusVideo) {
        if (self.commentWriteView && !self.commentWriteView.isDismiss) {
            //修复连续两次_openCommentWithText 导致弹出两个输入框
            return;
        }
        BOOL beginWriteComment = self.beginWriteCommentUGC;
        if (beginWriteComment && !clicked) {
            if (beginWriteComment) {
                block();
            }
        } else {
            [self _scrollToCommentListHeadAnimated:animated];
            /**
             *  评论数为0时引导评论
             */
            if (self.detailModel.protocoledArticle.commentCount == 0) {
                block();
            }
        }
    } else {
        [self _scrollToTopAnimated:animated];
    }
}

- (void)_scrollToTopAnimated:(BOOL)animated
{
    [self.ttvContainerScrollView setContentOffset:CGPointZero animated:animated];//不延迟有bug XWTT-9089
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.ttvContainerScrollView setContentOffset:CGPointZero animated:animated];
    });
}

#pragma mark - TTVVideoDetailCollectServiceDelegate

- (void)detailCollectService:(TTVVideoDetailCollectService *)collectService showTipMsg:(NSString *)tipMsg icon:(UIImage *)image buttonSeat:(NSString *)btnSeat
{
    if (!btnSeat || [btnSeat isEqualToString:BOTTOMBAR]){
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:tipMsg
                                 indicatorImage:image
                                    autoDismiss:YES
                                 dismissHandler:nil];
    }
    else if ([btnSeat isEqualToString:NEWSHAREPANEL]){
        [TTShareMethodUtil showIndicatorViewInActivityPanelWindowWithTip:tipMsg andImage:image dismissHandler:nil];
    }else if ([btnSeat isEqualToString:OLDSHAREPANEL]){
        [self showIndicatorViewWithTip:tipMsg andImage:image dismissHandler:nil];
    }
}

- (void)setShowStatus:(TTVVideoDetailViewShowStatus)showStatus
{
    BOOL isComment = showStatus == TTVVideoDetailViewShowStatusComment;
    
    if (isComment && self.shouldSendCommentTrackEvent) {
        NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithCapacity:10];
        [extra setValue:[self categoryName] forKey:@"category_name"];
        [extra setValue:[self enterFromString] forKey:@"enter_from"];
        [extra setValue:[self.detailModel uniqueID] forKey:@"group_id"];
        [extra setValue:self.detailModel.protocoledArticle.itemID forKey:@"item_id"];
        NSString *actionStr = @"pull";
        if (self.beginShowComment) {
            actionStr = @"click_list_button";
        } else if (self.isCommentButtonClicked) {
            actionStr = @"click_detail_button";
        }
        [extra setValue:actionStr forKey:@"action"];
        [extra setValue:@"video" forKey:@"source"];
        if (self.detailModel.logPb){
            [extra setValue:self.detailModel.logPb forKey:@"log_pb"];
        }else{
            [extra setValue:self.detailModel.gdExtJsonDict[@"log_pb"] forKey:@"log_pb"];
        }
        [TTTrackerWrapper eventV3:@"enter_comment" params:extra];
        self.shouldSendCommentTrackEvent = NO;
    }
    
    if (_showStatus == showStatus) {
        return;
    }
    _showStatus = showStatus;
}

#pragma mark - TTActivityShareManagerDelegate

- (void)activityShareManager:(TTActivityShareManager *)activityShareManager
    completeWithActivityType:(TTActivityType)activityType
                       error:(NSError *)error {
//    if (!error) {
//        [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                                   repostType:TTThreadRepostTypeArticle
//                                                            operationItemType:TTRepostOperationItemTypeArticle
//                                                              operationItemID:self.videoInfo.itemID
//                                                                originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.videoInfo.ttv_convertedArticle]
//                                                                 originThread:nil
//                                                               originShortVideoOriginalData:nil
//                                                            originWendaAnswer:nil
//                                                               repostSegments:nil];
//    }
}


#pragma mark -
#pragma mark TTCommentWriteManagerDelegate

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    if (self.detailModel.logPb){
        [paramsDict setValue:self.detailModel.logPb forKey:@"log_pb"];
    }else{
        [paramsDict setValue:self.detailModel.gdExtJsonDict[@"log_pb"] forKey:@"log_pb"];
    }
    [paramsDict setValue:[self enterFromString]  forKey:@"enter_from"];
    [paramsDict setValue:self.videoInfo.groupModel.groupID forKey:@"group_id"];
    [paramsDict setValue:self.videoInfo.groupModel.itemID forKey:@"item_id"];
    [paramsDict setValue:[self categoryName] forKey:@"category_name"];
    [paramsDict setValue:@"house_app2c_v2"  forKey:@"event_type"];

    [TTTracker eventV3:@"rt_post_comment" params:paramsDict];

    [commentView dismissAnimated:YES];
    commentWriteManager.delegate = nil;
    [self commentResponsedReceived:responseData];
}

- (void)commentResponsedReceived:(NSDictionary *)notifyDictioanry
{
    if(![notifyDictioanry objectForKey:@"error"])  {
        self.detailModel.protocoledArticle.commentCount = self.detailModel.protocoledArticle.commentCount + 1;
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[notifyDictioanry objectForKey:@"data"]];
        [self.commentVC insertCommentWithDict:data];
        [self.commentVC markTopCellNeedAnimation];
        [self.commentVC commentViewWillScrollToTopCommentCell];
        [self _scrollToCommentListHeadAnimated:YES];
    }
}
// 播放器结束页面分享动作
- (void)_videoOverShareActionFired
{
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_shareActionFired];
    }else{
        [self _shareActionFired:NO];
    }
    [self addClickSourceFromClickSource:TTVActivityClickSourceFromDetailVideoOver isFullScreen:NO];
    [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
}

- (void)adTopShareActionFired
{
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_shareActionFired];
    }else{
        [self _shareActionFired:NO];
    }
    [self addClickSourceFromClickSource:TTVActivityClickSourceFromDetailBottomBar isFullScreen:NO];
    [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
    
}
// 底部分享动作
- (void)_bottomShareActionFired
{
//    if ([[TTKitchenMgr sharedInstance] getBOOL:kKCShareBoardDisplayRepost]) {
//        [self showforwardSharePanel];
//    } else {
        if (ttvs_isShareIndividuatioEnable()) {
            [self new_shareActionFired];
        }else{
            [self _shareActionFired:NO];
        }
        
//    }
    [self addClickSourceFromClickSource:TTVActivityClickSourceFromDetailBottomBar isFullScreen:NO];
    [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
}

// 播放中右上角分享动作
- (void)_videoPlayShareActionFired
{
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_shareActionFired];
    }else{
        [self _shareActionFired:YES];
    }
    [self addClickSourceFromClickSource:TTVActivityClickSourceFromPlayerShare isFullScreen:YES];
    [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
}

// 中间分享动作
- (void)_detailCentrelShareActionFired
{
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_shareActionFired];
    }else{
        [self _shareActionFired:NO];
    }
    [self addClickSourceFromClickSource:TTVActivityClickSourceFromCentreButton isFullScreen:NO];
    [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
}

// 播放结束右上角更多按钮动作
- (void)_videoOverMoreActionFired
{
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_moreActionFired];
    }else{
        [self _moreActionFired:NO];
    }
    [self addClickSourceFromClickSource:TTVActivityClickSourceFromPlayerMore isFullScreen:NO];
    [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
}

// 播放中右上角按钮更多动作
- (void)_videoPlayMoreActionFired:(BOOL )isFullScrren
{
    if (ttvs_isShareIndividuatioEnable()) {
        [self new_moreActionFired];
    }else{
        [self _moreActionFired:isFullScrren];
    }
    [self addClickSourceFromClickSource:TTVActivityClickSourceFromPlayerMore isFullScreen:isFullScrren];
    [self shareTrackEventV3WithActivityType:TTActivityTypeShareButton];
}

- (void)_shareActionFired:(BOOL )isFullScreen
{
    Article *convertedArticle = [self.videoInfo ttv_convertedArticle];
    convertedArticle.mediaName = [self.videoInfo.userInfo ttgc_contentName];
    //非列表页进入视频详情页，增加分享图片获取容错
    [self convertedAddVideoDetailInfo:convertedArticle];
    
    NSString *adID = self.videoInfo.adIDStr ? self.videoInfo.adIDStr : self.videoInfo.adModel.ad_id;
    NSMutableArray * activityItems = @[].mutableCopy;
    if ([self.infoManager needShowAdShare]) {
        NSMutableDictionary *shareInfo = [self.infoManager makeADShareInfo];
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareInfo:shareInfo showReport:YES];
    } else {
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:convertedArticle adID: [NSNumber numberWithLongLong:[adID longLongValue]] showReport:YES];
    }
    
    //当视频是ugc视频时将举报按钮替换成删除按钮
    NSString *uid = [[self userInfo] stringValueForKey:@"user_id" defaultValue:nil];
    NSString *accountUserID = [TTAccountManager userID];
    if (isEmptyString(adID)){
        if (!isEmptyString(uid) && !isEmptyString(accountUserID) && [uid isEqualToString:accountUserID]) { //ugc视频
            [activityItems enumerateObjectsUsingBlock:^(TTActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.activityType == TTActivityTypeReport) {
                    [activityItems replaceObjectAtIndex:idx withObject:[TTActivity activityOfDelete]];
                    *stop = YES;
                }
            }];
        }
    }
    
    if (self.activityActionManager.useDefaultImage) {
        UIImage *image = [self.movieShotView logoImage];
        if (image) {
            self.activityActionManager.shareImage = image;
            // 原来搜索视频分享到朋友圈，没有设置image，导致分享视频icon是默认image。点击搜索视频，进入视频点击分享后，设置分享到朋友圈的image
            self.activityActionManager.shareToWeixinMomentOrQZoneImage = image;
            self.activityActionManager.systemShareImage = image;
        }
    }
    

        SSActivityView *phoneShareView = [[SSActivityView alloc] init];
        
        phoneShareView.delegate = self;
        phoneShareView.activityItems = activityItems;
        //分享板广告在视频广告详情页不出ad
        if (isFullScreen) {
            [TTAdManageInstance share_showInAdPage:@"1" groupId:self.detailModel.article.groupModel.groupID];
        }else{
            [TTAdManageInstance share_showInAdPage:self.detailModel.article.adIDStr groupId:convertedArticle.groupModel.groupID];
        }
        [phoneShareView showOnViewController:[TTUIResponderHelper topViewControllerFor: self] useShareGroupOnly:NO isFullScreen:isFullScreen];
        self.phoneShareView = phoneShareView;
//    }
    [self setIsCanFullScreenFromOrientationMonitor:NO];

}

- (void)_moreActionFired:(BOOL )isFullScreen
{
    Article *convertedArticle = [self.videoInfo ttv_convertedArticle];
    convertedArticle.mediaName = [self.videoInfo.userInfo ttgc_contentName];
    //非列表页进入视频详情页，增加分享图片获取容错
    [self convertedAddVideoDetailInfo:convertedArticle];
    
    [_activityActionManager clearCondition];
    NSString *adID = self.videoInfo.adIDStr ? self.videoInfo.adIDStr : self.videoInfo.adModel.ad_id;
    
    NSMutableArray * activityItems = @[].mutableCopy;
    if ([self.infoManager needShowAdShare]) {
        NSMutableDictionary *shareInfo = [self.infoManager makeADShareInfo];
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager shareInfo:shareInfo showReport:YES];
    } else {
        activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:convertedArticle adID:[NSNumber numberWithLongLong:[adID longLongValue]] showReport:YES];
    }
    
    NSMutableArray *group1 = [NSMutableArray array];
    NSMutableArray *group2 = [NSMutableArray array];
    
    //头条号icon,放最后
    NSString * avatarUrl = nil;
    NSString * name = nil;
    NSString *msgKey = @"关注";
    
    if ([convertedArticle.mediaInfo isKindOfClass:[NSDictionary class]] ) {
        avatarUrl = convertedArticle.mediaInfo[@"avatar_url"];
        
        if (convertedArticle.isSubscribe.boolValue) {
            name = [NSString stringWithFormat:@"取消%@",msgKey];
        }
        else {
            name = msgKey;
        }
    }
    
    BOOL hidePGCActivity = [convertedArticle hasVideoSubjectID] || !convertedArticle.mediaInfo || isEmptyString(avatarUrl) || isEmptyString(name);
    hidePGCActivity = YES;// 新样式不显示关注
    if (!hidePGCActivity) {
        TTActivity *pgcActivity = [TTActivity activityOfPGCWithAvatarUrl:avatarUrl showName:name];
        [group2 addObject:pgcActivity];
    }
    
    // 收藏
    TTActivity * favorite = [TTActivity activityOfVideoFavorite];
    favorite.selected = convertedArticle.userRepined;
    [group2 addObject:favorite];
    
    //顶踩
    NSString *diggCount = [NSString stringWithFormat:@"%@",@(convertedArticle.diggCount)];
    if ([convertedArticle.banDigg boolValue]) {
        if (convertedArticle.userDigg) {
            diggCount = @"1";
        }
        else{
            diggCount = @"0";
        }
    }
    TTActivity *digUpActivity = [TTActivity activityOfDigUpWithCount:diggCount];
    digUpActivity.selected = convertedArticle.userDigg;
    [group2 addObject:digUpActivity];
    
    NSString *buryCount = [NSString stringWithFormat:@"%@",@(convertedArticle.buryCount)];
    if ([convertedArticle.banBury boolValue]) {
        if (convertedArticle.userBury) {
            buryCount = @"1";
        }
        else{
            buryCount = @"0";
        }
    }
    TTActivity *digDownActivity = [TTActivity activityOfDigDownWithCount:buryCount];
    digDownActivity.selected = convertedArticle.userBury;
    [group2 addObject:digDownActivity];
    
    //当视频是ugc视频时将举报按钮替换成删除按钮
    NSString *uid = [[convertedArticle userInfo] stringValueForKey:@"user_id" defaultValue:nil];
    if (!isEmptyString(uid) && !isEmptyString([TTAccountManager userID]) && [uid isEqualToString:[TTAccountManager userID]]) { //ugc视频
        [activityItems enumerateObjectsUsingBlock:^(TTActivity *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.activityType == TTActivityTypeReport) {
                [activityItems replaceObjectAtIndex:idx withObject:[TTActivity activityOfDelete]];
                *stop = YES;
            }
        }];
    }
    
    //分开放，举报放最后边
    for (TTActivity *activity in activityItems) {
        if (activity.activityType == TTActivityTypeReport || activity.activityType == TTActivityTypeDetele) {
            [group2 addObject:activity];
        }
        else {
            [group1 addObject:activity];
        }
    }
    
    //视频特卖 放第一位置
    NSArray *commoditys = self.videoInfo.commoditys;
    if (commoditys.count > 0) {
        [self commodityLogV3WithEventName:@"commodity_recommend_show"];
        [group2 insertObject:[TTActivity activityOfVideoCommodity] atIndex:0];
    }
    
    SSActivityView *phoneShareView = [[SSActivityView alloc] init];
    phoneShareView.delegate = self;
    if (isFullScreen) {
        [TTAdManageInstance share_showInAdPage:@"1" groupId:self.detailModel.article.groupModel.groupID];
    }else{
        [TTAdManageInstance share_showInAdPage:self.detailModel.article.adIDStr groupId:convertedArticle.groupModel.groupID];
    }
    [phoneShareView showActivityItems:@[group1, group2] isFullSCreen:isFullScreen];
    self.phoneShareView = phoneShareView;
    [self setIsCanFullScreenFromOrientationMonitor:NO];
}

- (void)_videoOverDirectShareItemActionWithActivityType:(NSString *)activityType
{
    [self ttv_directShareItemActionFromCickeSource:TTVActivityClickSourceFromDetailVideoOverDirect itemType:activityType];
}

- (void)_videoPlayDirectShareItemActionWithActivityType:(NSString *)activityType
{
    TTActivityType itemType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:activityType];
    [self addClickSourceFromClickSource:TTVActivityClickSourceFromPlayerDirect isFullScreen:YES];
    [self directShareTrackEventV3WithActivityType:itemType isFullScreen:YES];
    [self ttv_directshareWithActivityType:activityType];
}

- (void)_detailCentrelDirectShareItemAction:(NSString *)activityType
{
    [self ttv_directShareItemActionFromCickeSource:TTVActivityClickSourceFromCentreButtonDirect itemType:activityType];
}

- (void)ttv_directShareItemActionFromCickeSource:(TTVActivityClickSourceFrom )clickSource itemType:(NSString *)activityType
{
    TTActivityType itemType = [TTActivityShareSequenceManager activityTypeFromStringActivityType:activityType];
    if ([AKAwardCoinManager isShareTypeWithActivityType:itemType]) {
        [AKAwardCoinManager requestShareBounsWithGroup:self.detailModel.article.groupModel.groupID fromPush:self.detailModel.fromSource == NewsGoDetailFromSourceAPNS || self.detailModel.fromSource == NewsGoDetailFromSourceAPNSInAppAlert completion:nil];
    }
    if (ttvs_isShareIndividuatioEnable()){
        [self ttv_directshareWithActivityType:activityType];
    }else{
        NSString *adId = nil;
        if ([self.detailModel.adID longLongValue] > 0) {
            adId = [NSString stringWithFormat:@"%@", self.detailModel.adID];
        }
        
        NSString *groupId = [NSString stringWithFormat:@"%lld", self.detailModel.protocoledArticle.uniqueID];
        
        if (self.activityActionManager.useDefaultImage) {
            UIImage *image = [self.movieShotView logoImage];
            if (image) {
                self.activityActionManager.shareImage = image;
                // 原来搜索视频分享到朋友圈，没有设置image，导致分享视频icon是默认image。点击搜索视频，进入视频点击分享后，设置分享到朋友圈的image
                self.activityActionManager.shareToWeixinMomentOrQZoneImage = image;
                self.activityActionManager.systemShareImage = image;
            }
        }
        Article *convertedArticle = [self.videoInfo ttv_convertedArticle];
        convertedArticle.mediaName = [self.videoInfo.userInfo ttgc_contentName];
        //非列表页进入视频详情页，增加分享图片获取容错
        [self convertedAddVideoDetailInfo:convertedArticle];
        
        [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:convertedArticle adID:self.detailModel.adID showReport:YES];
        [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:TTShareSourceObjectTypeVideoDetail uniqueId:groupId adID:adId platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.protocoledArticle.groupFlags];
    }
    [self addClickSourceFromClickSource:clickSource isFullScreen:NO];
    [self directShareTrackEventV3WithActivityType:itemType isFullScreen:NO];

}


#pragma mark SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view button:(UIButton *)button didCompleteByItemType:(TTActivityType)itemType{
    if (itemType == TTActivityTypeFavorite) {
        if (!TTNetworkConnected()){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            return;
        }
        button.selected = !button.selected;
        [self _triggerFavoriteActionWithButtonSeat:OLDSHAREPANEL];
        [self shareTrackEventV3WithActivityType:itemType favouriteButton:button];

    }
    
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if ([AKAwardCoinManager isShareTypeWithActivityType:itemType]) {
        [AKAwardCoinManager requestShareBounsWithGroup:self.detailModel.article.groupModel.groupID fromPush:self.detailModel.fromSource == NewsGoDetailFromSourceAPNS || self.detailModel.fromSource == NewsGoDetailFromSourceAPNSInAppAlert completion:nil];
    }
    if (itemType == TTActivityTypeWeitoutiao || itemType == TTActivityTypeDislike || itemType ==TTActivityTypeReport || itemType == TTActivityTypeEMail || itemType == TTActivityTypeSystem ||itemType == TTActivityTypeMessage) {
        if ([self playControl]) {
            TTVDetailPlayControl *detailPlayControl = [self playControl];
            if (detailPlayControl.movieView.player.context.isFullScreen) {
                if (itemType == TTActivityTypeReport) {
                    [detailPlayControl.movieView exitFullScreen:YES completion:^(BOOL finished) {
                        dispatch_after(0, dispatch_get_main_queue(), ^{
                            
                            [self reportAction];
                        });
                    }];
                    return;
                }else{
                    [detailPlayControl.movieView exitFullScreen:YES completion:^(BOOL finished) {}];
                }
            }
        }
    }
//    if (itemType == TTActivityTypeWeitoutiao) {
//        [self p_forwardToWeitoutiao];
//    }
//    else if (itemType == TTActivityTypeReport) {
    if (itemType == TTActivityTypeReport) {
        [self reportAction];
    } else if (itemType == TTActivityTypeDetele) {
        [self deleteAction];
    } else  if (itemType == TTActivityTypeDigUp)
    {
        if (self.detailModel.protocoledArticle.userBury) {
            NSString *tip = NSLocalizedString(@"您已经踩过", nil);
            [self showIndicatorViewWithTip:tip andImage:nil dismissHandler:nil];
        } else if (self.detailModel.protocoledArticle.userDigg){
            if (_diggActionFired) {
                self.diggActionFired(NO);
            }
        } else{
            if (_diggActionFired) {
                self.diggActionFired(YES);
            }
        }
        
    } else if (itemType == TTActivityTypeDigDown)
    {
        if (self.detailModel.protocoledArticle.userDigg) {
            NSString *tip = NSLocalizedString(@"您已经赞过", nil);
            [self showIndicatorViewWithTip:tip andImage:nil dismissHandler:nil];
        } else if (self.detailModel.protocoledArticle.userBury){
            if (_buryActionFired){
                self.buryActionFired(NO);
            }
        } else{
            if (_buryActionFired) {
                self.buryActionFired(YES);
            }
        }

    } else if(itemType == TTActivityTypeCommodity){
        if (self.commodityActionFired) {
            self.commodityActionFired();
            [self commodityLogV3WithEventName:@"commodity_recommend_click"];
        }
    } else{
        NSString *adId = nil;
        if ([self.detailModel.adID longLongValue] > 0) {
            adId = [NSString stringWithFormat:@"%@", self.detailModel.adID];
        }
        NSString *groupId = [NSString stringWithFormat:@"%lld", self.detailModel.protocoledArticle.uniqueID];
        
        BOOL isFullScreen = NO;
        if ([[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] isKindOfClass:[NSNumber class]]) {
            isFullScreen = [(NSNumber *)[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] boolValue];
        }
        
        [self.activityActionManager performActivityActionByType:itemType inViewController:self sourceObjectType:TTShareSourceObjectTypeVideoDetail uniqueId:groupId adID:adId platform:TTSharePlatformTypeOfMain groupFlags:self.detailModel.protocoledArticle.groupFlags isFullScreenShow:isFullScreen];
    }
    [self shareTrackEventV3WithActivityType:itemType];
    [self setIsCanFullScreenFromOrientationMonitor:YES];
}

//both old/new share pod usage


- (void)reportAction
{
    self.actionSheetController = [[TTActionSheetController alloc] init]; 
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
    WeakSelf;
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        StrongSelf;
        if (parameters[@"report"]) {
            TTReportContentModel *model = [[TTReportContentModel alloc] init];
            model.groupID = [self.detailModel uniqueID];
            model.videoID = self.detailModel.protocoledArticle.videoID;
            NSString *contentType = kTTReportContentTypePGCVideo;
            if ([self.detailModel.article isVideoSourceUGCVideo]) {
                contentType = kTTReportContentTypeUGCVideo;
            } else if ([self.detailModel.article isVideoSourceHuoShan]) {
                contentType = kTTReportContentTypeHTSVideo;
            } else if (self.detailModel.adID.longLongValue) {
                contentType = kTTReportContentTypeAD;
            }
            
            [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:contentType reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID) contentModel:model extraDic:nil animated:YES];
            [self.shareSectionAndEventDic setValue:parameters[@"report"] forKey:@"reason"];
            [self shareTrackEventV3WithActivityType:TTActivityTypeReport];
        }
    }];
}

- (void)deleteAction
{
    NSString *itemID = !isEmptyString(self.detailModel.protocoledArticle.itemID) ? self.detailModel.protocoledArticle.itemID : self.detailModel.protocoledArticle.groupModel.groupID;
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:itemID forKey:@"item_id"];
    [extraDict setValue:@"click_video" forKey:@"source"];
    [extraDict setValue:@(1) forKey:@"aggr_type"];
    [extraDict setValue:@(1) forKey:@"type"];
    wrapperTrackEventWithCustomKeys(@"detail_share", @"delete_ugc", [self.detailModel uniqueID], nil, extraDict);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[[self userInfo] stringValueForKey:@"user_id" defaultValue:nil] forKey:@"user_id"];
    [params setValue:itemID forKey:@"item_id"];
    [self p_prepareDeleteLocalVideoTask];
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting deleteUGCMovieURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSInteger errorCode = 0;
        if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            errorCode = [(NSDictionary *)jsonObj tt_integerValueForKey:@"error_code"];
        }
        if (error || errorCode != 0) {
            NSString *tip = NSLocalizedString(@"操作失败", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
        } else {
            NSString *tip = NSLocalizedString(@"操作成功", nil);
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tip indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
            //                [self p_deleteLocalVideo];
            TTVideoCallbackTask *task = [[TTVideoCallbackTaskGlobalQueue sharedInstance] popQueueFromHead];
            
            if (task.callback) {
                task.callback();
            }
        }
    }];
}

#pragma mark - Private Methods

- (void)p_prepareDeleteLocalVideoTask {
    if (self.videoInfo.uniqueID > 0) {
        NSString *uniqueID = [NSString stringWithFormat:@"%lld", self.videoInfo.uniqueID];
        
        NSMutableDictionary *profileDict = [NSMutableDictionary dictionary];
        [profileDict setValue:self.detailModel.protocoledArticle.itemID forKey:@"item_id"];
        [profileDict setValue:[self.detailModel uniqueID] forKey:@"group_id"];
        [profileDict setValue:[[self userInfo] stringValueForKey:@"user_id" defaultValue:nil] forKey:@"user_id"];
        
        NSMutableDictionary *dongtaiDict = [NSMutableDictionary dictionary];
        [dongtaiDict setValue:self.detailModel.dongtaiID forKey:@"id"];
        
        TTVideoCallbackTask *task = [[TTVideoCallbackTask alloc] init];
        WeakSelf;
        task.callback = ^ {
            StrongSelf;
            [[NSNotificationCenter defaultCenter] postNotificationName:TTVideoDetailViewControllerDeleteVideoArticle object:nil userInfo:@{@"uniqueID":uniqueID}];
            NSArray *orderedDataArray = [ExploreOrderedData objectsWithQuery:@{@"uniqueID": uniqueID}];
            [ExploreOrderedData removeEntities:orderedDataArray];
            if (self.homeActionDelegate && [self.homeActionDelegate respondsToSelector:@selector(_topViewBackButtonPressed)]) {
                [self.homeActionDelegate _topViewBackButtonPressed];
            }
            if (!isEmptyString(self.detailModel.dongtaiID)) {
                NSMutableDictionary *dongtaiDict = [NSMutableDictionary dictionary];
                [dongtaiDict setValue:self.detailModel.dongtaiID forKey:@"id"];
            }
        };
        [[TTVideoCallbackTaskGlobalQueue sharedInstance] enQueueCallbackTask:task];
    }
}

- (void)_triggerFavoriteActionWithButtonSeat:(NSString *)btnSeat
{
    if (_collectService == nil) {
        _collectService = [[TTVVideoDetailCollectService alloc] init];
    }
    _collectService.originalArticle = self.detailModel.protocoledArticle;
    _collectService.gdExtJSONDict = self.detailModel.gdExtJsonDict;
    _collectService.delegate = self;
    [_collectService changeFavoriteButtonClicked:1 viewController:self withButtonSeat:btnSeat];
}

#pragma mark - Log

- (void)favoriteLog3{
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    if (self.videoInfo.userRepined) {
        [extra setValue:@"rt_favourite" forKey:@"favorite_name"];
    }else{
        [extra setValue:@"rt_unfavourite" forKey:@"favorite_name"];
    }
    [extra addEntriesFromDictionary:_shareSectionAndEventDic];
    Article *covertArticle = [self.videoInfo ttv_convertedArticle];
    [extra setValue:@(TTActivitySectionTypeDetailBottomBar)forKey:@"sectionType"];
    SAFECALL_MESSAGE(TTVShareDetailTrackerMessage,@selector(message_detailShareTrackWithGroupID:ActivityType:extraDic:fullScreen:),message_detailShareTrackWithGroupID:@(covertArticle.uniqueID).stringValue ActivityType:TTActivityTypeFavorite extraDic:extra fullScreen:NO);
    
}

- (void)commodityLogV3WithEventName:(NSString *)eventName
{
    Article *covertArticle = [self.videoInfo ttv_convertedArticle];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:@"point_panel" forKey:@"section"];
    [dic setValue:[NSString stringWithFormat:@"%lld", covertArticle.uniqueID] forKey:@"group_id"];
    [dic setValue:covertArticle.itemID forKey:@"item_id"];
    [dic setValue:@"TEMAI" forKey:@"EVENT_ORIGIN_FEATURE"];
    BOOL isfullscreen = [TTVPlayVideo currentPlayingPlayVideo].player.context.isFullScreen;
    [dic setValue:isfullscreen ? @"fullscreen" : @"nofullscreen"  forKey:@"fullscreen"];
    [dic setValue:@"detail" forKey:@"position"];
    NSMutableDictionary *commodity_attr = [NSMutableDictionary dictionary];
    [commodity_attr setValue:@(self.videoInfo.commoditys.count) forKey:@"commodity_num"];
    [dic setValue:commodity_attr forKey:@"commodity_attr"];
    [TTTrackerWrapper eventV3:eventName params:dic];
}


#pragma mark - shareLog

- (void)addClickSourceFromClickSource:(TTVActivityClickSourceFrom )clickSource isFullScreen:(BOOL)isFullScreen{
    
    NSNumber *isfullScreen = isFullScreen ? @(1) : @(0);
    TTActivitySectionType sectionType;
    NSString *fromSource;
    if (clickSource == TTVActivityClickSourceFromPlayerMore) {
        if (isFullScreen) {
            fromSource = @"player_more";
        }else{
            fromSource = @"no_full_more";
        }
        sectionType = TTActivitySectionTypePlayerMore;
    }else  if (clickSource == TTVActivityClickSourceFromPlayerShare) {
        fromSource = @"player_share";
        sectionType = TTActivitySectionTypePlayerShare;
    }else  if (clickSource == TTVActivityClickSourceFromDetailBottomBar) {
        fromSource = @"detail_bottom_bar";
        sectionType = TTActivitySectionTypeDetailBottomBar;
    }else  if (clickSource == TTVActivityClickSourceFromDetailVideoOver) {
        fromSource = @"detail_video_over";
        sectionType = TTActivitySectionTypeDetailVideoOver;
    }else if (clickSource == TTVActivityClickSourceFromDetailVideoOverDirect) {
        fromSource = @"detail_video_over_direct";
        sectionType = TTActivitySectionTypeDetailVideoOver;
    }else if (clickSource == TTVActivityClickSourceFromCentreButton){
        fromSource = @"centre_button";
        sectionType = TTActivitySectionTypeCentreButton;
    } else if (clickSource == TTVActivityClickSourceFromCentreButtonDirect){
        fromSource = @"centre_button_direct";
        sectionType = TTActivitySectionTypeCentreButton;
    }else if (clickSource == TTVActivityClickSourceFromPlayerDirect){
        fromSource = @"player_click_share";
        sectionType = TTActivitySectionTypePlayerDirect;
    }else{
        fromSource = nil;
        sectionType = 1000;
    }
    self.activityActionManager.clickSource = fromSource;
    [self.shareSectionAndEventDic setValue:@(sectionType) forKey:SECTIONTYPE ];
    [self.shareSectionAndEventDic setValue:isfullScreen forKey:ISFULLSCREEN];
    [_shareSectionAndEventDic setValue:fromSource forKey:@"fromSource"];

}

- (NSMutableDictionary *)shareSectionAndEventDic{
    if (!_shareSectionAndEventDic) {
        _shareSectionAndEventDic = [NSMutableDictionary dictionary];
    }
    return _shareSectionAndEventDic;
}

- (void)shareTrackEventV3WithActivityType:(TTActivityType )itemType {
    [self shareTrackEventV3WithActivityType:itemType favouriteButton:nil ];
}

- (void)shareTrackEventV3WithActivityType:(TTActivityType )itemType favouriteButton:(UIButton *)button
{
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    if (itemType == TTActivityTypeFavorite)
    {
        BOOL userRepine = self.detailModel.protocoledArticle.userRepined;
        [extra setValue: userRepine ? @"rt_favourite" : @"rt_unfavourite" forKey:@"favorite_name"];
    }
    
    NSString *fromSource = _activityActionManager.clickSource;
    [extra setValue:fromSource forKey:@"fromSource"];
    [extra setValue:@(!self.detailModel.protocoledArticle.userDigg) forKey:@"userDigg"];
    [extra setValue:@(!self.detailModel.protocoledArticle.userBury) forKey:@"userBury"];
    [extra addEntriesFromDictionary:_shareSectionAndEventDic];
    Article *covertArticle = [self.videoInfo ttv_convertedArticle];
    BOOL isFullScreen = NO;
    if ([[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] isKindOfClass:[NSNumber class]]) {
        isFullScreen = [(NSNumber *)[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] boolValue];
    }
    SAFECALL_MESSAGE(TTVShareDetailTrackerMessage,@selector(message_detailShareTrackWithGroupID:ActivityType:extraDic:fullScreen:),message_detailShareTrackWithGroupID:@(covertArticle.uniqueID).stringValue ActivityType:itemType extraDic:extra fullScreen:isFullScreen);
    [_shareSectionAndEventDic removeAllObjects];
    [_shareSectionAndEventDic setValue:[extra valueForKey:SECTIONTYPE] forKey:SECTIONTYPE];
    [_shareSectionAndEventDic setValue:[extra valueForKey:ISFULLSCREEN] forKey:ISFULLSCREEN];
    [_shareSectionAndEventDic setValue:[extra valueForKey:@"fromSource"] forKey:@"fromSource"];

}

- (void)directShareTrackEventV3WithActivityType:(TTActivityType )itemType isFullScreen:(BOOL)isfullScreen
{
    NSString *fromSource = _activityActionManager.clickSource;
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:fromSource forKey:@"fromSource"];
    [extra addEntriesFromDictionary:_shareSectionAndEventDic];
    Article *covertArticle = [self.videoInfo ttv_convertedArticle];
    BOOL isFullScreen = NO;
    if ([[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] isKindOfClass:[NSNumber class]]) {
        isFullScreen = [(NSNumber *)[_shareSectionAndEventDic valueForKey:ISFULLSCREEN] boolValue];
    }
    SAFECALL_MESSAGE(TTVShareDetailTrackerMessage,@selector(message_detailExposedShareTrackWithGroupID:ActivityType:extraDic:fullScreen:),message_detailExposedShareTrackWithGroupID:@(covertArticle.uniqueID).stringValue ActivityType:itemType extraDic:extra fullScreen:isfullScreen);
    [_shareSectionAndEventDic removeAllObjects];
    [_shareSectionAndEventDic setValue:[extra valueForKey:SECTIONTYPE] forKey:SECTIONTYPE];
    [_shareSectionAndEventDic setValue:[extra valueForKey:ISFULLSCREEN] forKey:ISFULLSCREEN];
    [_shareSectionAndEventDic setValue:[extra valueForKey:@"fromSource"] forKey:@"fromSource"];
}

- (void)showIndicatorViewWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler{
    TTIndicatorView *indicateView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:indicatorImage dismissHandler:handler];
    indicateView.autoDismiss = YES;
    [indicateView showFromParentView:self.phoneShareView.panelController.backWindow.rootViewController.view];
}

- (NSString *)enterFromString{
    NSString * enterFrom = self.detailModel.clickLabel;
    if (self.detailModel.fromSource == NewsGoDetailFromSourceCategory | self.detailModel.fromSource == NewsGoDetailFromSourceVideoFloat) {
        enterFrom = @"click_category";
    }else if(self.detailModel.fromSource == NewsGoDetailFromSourceClickTodayExtenstion) {
        enterFrom = @"click_widget";
    }
    if (isEmptyString(enterFrom) && !isEmptyString(self.detailModel.gdLabel)) {
        enterFrom = self.detailModel.gdLabel;
    }
    return enterFrom;
}

- (NSString *)categoryName
{
    NSString *categoryName = self.detailModel.categoryID;
    if (!categoryName || [categoryName isEqualToString:@"xx"] ) {
        categoryName = [[self enterFromString] stringByReplacingOccurrencesOfString:@"click_" withString:@""];
    }else{
        if (![[self enterFromString] isEqualToString:@"click_headline"]) {
            if ([categoryName hasPrefix:@"_"]) {
                categoryName = [categoryName substringFromIndex:1];
            }
        }
    }
    return categoryName;
}

#pragma mark
#pragma mark - new share pod
- (void)showforwardSharePanel
{
    NSArray *contentItems = [self forwardSharePanelContentItems];
    [self.shareManager displayForwardSharePanelWithContent:contentItems];
}

- (void)new_shareActionFired
{
    if (self.detailModel.adID.longLongValue > 0){
        [[TTAdShareManager sharedManager] showInAdPage:self.detailModel.adID.stringValue groupId:self.detailModel.uniqueID];
    }
    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:[self shareActionUpItems]];
    [contentItems addObject:[self shareActionDownItems]];
    [self.shareManager displayActivitySheetWithContent:[contentItems copy]];
    [self setIsCanFullScreenFromOrientationMonitor:NO];
}

- (void)new_moreActionFired
{
    if (self.detailModel.adID.longLongValue > 0){
        [[TTAdShareManager sharedManager] showInAdPage:self.detailModel.adID.stringValue groupId:self.detailModel.uniqueID];
    }
    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:[self moreActionUpItems]];
    [contentItems addObject:[self moreActionDownItems]];
    [self.shareManager displayActivitySheetWithContent:[contentItems copy]];
    [self setIsCanFullScreenFromOrientationMonitor:NO];
}

#pragma  mark - direct share actions

- (void)ttv_directshareWithActivityType:(NSString *)activityTypeString
{
    id<TTActivityContentItemProtocol> activityItem;
    if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
        TTWechatTimelineContentItem *wcTlItem = [self wechatTimelineCotentItem];
        activityItem = wcTlItem;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeWechat]){
        TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
        activityItem = wcItem;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQFriend]){
        TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
        activityItem = qqItem;
    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeQQZone]){
        TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
        activityItem = qqZoneItem;
    }
//    }else if ([activityTypeString isEqualToString:TTActivityContentItemTypeDingTalk]){
//        TTDingTalkContentItem *ddItem = [[TTDingTalkContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
//        activityItem = ddItem;
//    }
    if (activityItem) {
        [self.shareManager shareToActivity:activityItem presentingViewController:nil];
    }
}


#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
//    if ([[activity contentItemType] isEqualToString:TTActivityContentItemTypeSystem] ||
//        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeSMS] ||
//        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeEmail] ||
    if ([[activity contentItemType] isEqualToString:TTActivityContentItemTypeForwardWeitoutiao] ||
        [[activity contentItemType] isEqualToString:TTActivityContentItemTypeReport])
    {
        if ([TTVPlayVideo currentPlayingPlayVideo].player.context.isFullScreen)
        {
            TTVPlayVideo *playVideo = [TTVPlayVideo currentPlayingPlayVideo];
            [playVideo exitFullScreen:YES completion:^(BOOL finished) {
                [UIViewController attemptRotationToDeviceOrientation];
            }];
        }
    }
    if (activity && ![activity.activityType isEqualToString:TTActivityTypeDirectForwardWeitoutiao]) {//直接转发时不记录cancel事件
        TTActivityType itemType = [TTVideoCommon activityTypeFromNewshareItemContentTypeFrom:[activity contentItemType]];
        if (itemType != TTActivityTypeFavorite){
            [self shareTrackEventV3WithActivityType:itemType];
        }
    }else{
        [self shareTrackEventV3WithActivityType:TTActivityTypeNone];
        [self setIsCanFullScreenFromOrientationMonitor:YES];
    }

}

#pragma safeInset

//- (void)viewSafeAreaInsetsDidChange
//{
//    [super viewSafeAreaInsetsDidChange];
//    if (self.view.superview){
//        CGRect frameInWindow = [self.view convertRect:self.view.bounds toView:nil];
//        UIEdgeInsets safeInset = self.view.safeAreaInsets;
//        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
//        if (ceil(ExploreDetailGetToolbarHeight() + safeInset.bottom) >= CGRectGetHeight(frameInWindow) &&
//            screenHeight == ceil(CGRectGetMaxY(frameInWindow))){
//            frameInWindow = CGRectMake(frameInWindow.origin.x, frameInWindow.origin.y - safeInset.bottom, self.view.width, (ExploreDetailGetToolbarHeight() + safeInset.bottom));
//            self.view.frame = [self.view.superview convertRect:frameInWindow fromView:nil];
//        }
//        self.toolbarView.frame = self.view.bounds;
//    }
//}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    [self setIsCanFullScreenFromOrientationMonitor:YES];
    TTActivityType activityType = [TTVideoCommon activityTypeFromNewshareItemContentTypeFrom:[activity contentItemType]];
    NSString *eventName = nil;
    if(error) {
        TTVActivityShareErrorCode errorCode = [TTActivityShareSequenceManager shareErrorCodeFromItemErrorCode:error WithActivity:activity];
        switch (errorCode) {
            case TTVActivityShareErrorFailed:
                [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
                break;
            case TTVActivityShareErrorUnavaliable:
            case TTVActivityShareErrorNotInstalled:
            default:
                break;
        }
        eventName = @"share_fail";
    }else{
        [[TTActivityShareSequenceManager sharedInstance_tt] instalAllShareServiceSequenceFirstActivity:activity.contentItemType];
        eventName = @"share_done";
    }
    
    if (activityType == TTActivityTypeReport) {
        return;
    }
    
    if (activityType == TTActivityTypeFavorite) {
        [self shareTrackEventV3WithActivityType:activityType];
    }else if (activityType != TTActivityTypeDigUp && activityType != TTActivityTypeDigDown){
        SAFECALL_MESSAGE(TTVShareDetailTrackerMessage, @selector(message_detailshareTrackActivityWithGroupID:ActivityType:FromSource:eventName:), message_detailshareTrackActivityWithGroupID:@(self.videoInfo.uniqueID).stringValue ActivityType:activityType FromSource:self.shareSectionAndEventDic[@"fromSource"] eventName:eventName);
    }
}

#pragma mark - share/more contentItems
- (NSArray<id<TTActivityContentItemProtocol>> *)shareActionUpItems{
    NSMutableArray<id<TTActivityContentItemProtocol>> *shareUpItems = @[].mutableCopy;
    [shareUpItems addObjectsFromArray:[self outShareItems]];

    return [shareUpItems copy];
}

- (NSArray<id<TTActivityContentItemProtocol>> *)shareActionDownItems{
    NSMutableArray<id<TTActivityContentItemProtocol>> *shareDownItems = @[].mutableCopy;
//    [shareDownItems addObjectsFromArray:[self shareItems]];
    [self addReportItemOrDeleteItem:shareDownItems];
    return [shareDownItems copy];
}

- (NSArray<id<TTActivityContentItemProtocol>> *)moreActionUpItems{
    NSMutableArray<id<TTActivityContentItemProtocol>> *moreUpItems = @[].mutableCopy;
    [moreUpItems addObjectsFromArray:[self outShareItems]];
//    if (!(self.detailModel.adID.longLongValue > 0)) {
//        [moreUpItems addObjectsFromArray:[self shareItems]];
//    }

    return [moreUpItems copy];
}

- (NSArray<id<TTActivityContentItemProtocol>> *)moreActionDownItems{
    NSMutableArray<id<TTActivityContentItemProtocol>> *moreDownItems = @[].mutableCopy;
//    if (self.detailModel.adID.longLongValue > 0) {
//        TTCopyContentItem *copyItem = [[TTCopyContentItem alloc] initWithDesc:[self shareUrl]];
//        TTSystemContentItem *sysItem = [[TTSystemContentItem alloc] initWithDesc:[self shareDesc] webPageUrl:[self shareUrl] image:[self shareImage]];
//        [moreDownItems addObject:sysItem];
//        [moreDownItems addObject:copyItem];
//    }else{
        if (self.videoInfo.commoditys.count > 0){
            [moreDownItems addObject:[self commodityContentItem]];
            [self commodityLogV3WithEventName:@"commodity_recommend_show"];
        }
        [moreDownItems addObject:[self favourateContentItem]];
        [moreDownItems addObject:[self diggContentItem]];
        [moreDownItems addObject:[self buryContentItem]];
//    }
    [self addReportItemOrDeleteItem:moreDownItems];
    return [moreDownItems copy];
}

#pragma mark - share contentItems

- (NSArray<id<TTActivityContentItemProtocol>> *)outShareItems
{
    TTWechatTimelineContentItem *wcTlItem = [self wechatTimelineCotentItem];
    TTWechatContentItem *wcItem = [[TTWechatContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
    TTQQFriendContentItem *qqItem = [[TTQQFriendContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
    TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] imageUrl:nil shareTye:TTShareWebPage];
//    TTDingTalkContentItem *ddItem = [[TTDingTalkContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc] webPageUrl:[self shareUrl] thumbImage:[self shareImage] shareType:TTShareWebPage];
//
    NSArray *typeArray = [[TTActivityShareSequenceManager sharedInstance_tt] getAllShareServiceSequence];
    NSMutableArray *SeqArray = @[].mutableCopy;
    [typeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *objType = (NSString *)obj;
            if ([objType isEqualToString:TTActivityContentItemTypeWechatTimeLine]){
                [SeqArray addObject:wcTlItem];
            }else if ([objType isEqualToString:TTActivityContentItemTypeWechat]){
                [SeqArray addObject:wcItem];
            }else if ([objType isEqualToString:TTActivityContentItemTypeQQFriend]){
                [SeqArray addObject:qqItem];
            }else if ([objType isEqualToString:TTActivityContentItemTypeQQZone]){
                [SeqArray addObject:qqZoneItem];
            }
//            else if ([objType isEqualToString:TTActivityContentItemTypeDingTalk]){
////                [SeqArray addObject:ddItem];
//            }
            else if ([objType isEqualToString: TTActivityContentItemTypeForwardWeitoutiao]){
//                if (!(self.detailModel.adID > 0)){
//                    [SeqArray addObject:[self forwardWeitoutiaoContentItem]];
//                }
            }

        }
    }];
    return SeqArray;

}

//- (NSArray<id<TTActivityContentItemProtocol>> *)shareItems
//{
//    TTSystemContentItem *sysItem = [[TTSystemContentItem alloc] initWithDesc:[self shareDesc] webPageUrl:[self shareUrl] image:[self shareImage]];
//    TTCopyContentItem *copyItem = [[TTCopyContentItem alloc] initWithDesc:[self shareUrl]];
//    TTEmailContentItem *emailItem = [[TTEmailContentItem alloc] initWithTitle:[self shareTitle] desc:[self shareDesc]];
//    return @[sysItem, emailItem, copyItem];
//}

- (void)addReportItemOrDeleteItem:(NSMutableArray<id<TTActivityContentItemProtocol>> *) itemArray{
    NSString *adID = self.videoInfo.adIDStr ? self.videoInfo.adIDStr : self.videoInfo.adModel.ad_id;
    NSString *uid = [[self userInfo] stringValueForKey:@"user_id" defaultValue:nil];
    NSString *accountUserID = [TTAccountManager userID];
    if (isEmptyString(adID)){
//        if (!isEmptyString(uid) && !isEmptyString(accountUserID) && [uid isEqualToString:accountUserID]) { //ugc视频
//            [itemArray addObject:[self deleteContentItem]];
//        }else{
            [itemArray addObject:[self reportItem]];
//        }
    }else{
        [itemArray addObject:[self reportItem]];
    }
}

- (TTWechatTimelineContentItem *)wechatTimelineCotentItem{
    
    UIImage *shareImg = [self shareImage];
    NSString *timeLineText = [self shareTitle];
    TTShareType shareType;
    NSString *adID = self.videoInfo.adIDStr ? self.videoInfo.adIDStr : self.videoInfo.adModel.ad_id;


    TTWechatTimelineContentItem *wcTlItem;
    if (!isEmptyString(adID)) {
        shareType = TTShareVideo;
    }else{
        UIImageView *originalImageView = [[UIImageView alloc] initWithImage:[self shareImage]];
        if (ttvs_isShareTimelineOptimize() == 2) {
            shareImg = [self imageWithView:originalImageView];
        }
        if (ttvs_isShareTimelineOptimize() > 0 )
        {
            shareType = TTShareWebPage;
        }
        else{
            shareType = TTShareVideo;
        }
        
        if (ttvs_isShareTimelineOptimize() > 2) {
            timeLineText = [self timeLineTitle];
        }
    }
    wcTlItem = [[TTWechatTimelineContentItem alloc] initWithTitle:timeLineText desc:timeLineText webPageUrl:[self shareUrl] thumbImage:shareImg shareType:shareType];
    return wcTlItem;
}


- (TTReportContentItem *)reportItem
{
    TTReportContentItem *reportItem = [TTReportContentItem new];
    WeakSelf;
    reportItem.customAction = ^(void) {
        StrongSelf;
        [self reportAction];
    };
    return reportItem;
}

//- (TTForwardWeitoutiaoContentItem *)forwardWeitoutiaoContentItem {
//    TTForwardWeitoutiaoContentItem * contentItem = [[TTForwardWeitoutiaoContentItem alloc] init];
//    WeakSelf;
//    contentItem.repostParams = [self repostParams];
//    contentItem.customAction = ^{
//        StrongSelf;
//        [self p_forwardToWeitoutiao];
//    };
//    return contentItem;
//}

- (TTFavouriteContentItem *)favourateContentItem{
    TTFavouriteContentItem *contentItem = [[TTFavouriteContentItem alloc] init];
    contentItem.selected = self.videoInfo.userRepined;
    WeakSelf;
    @weakify(contentItem);
    contentItem.customAction = ^{
        StrongSelf;
        if (!TTNetworkConnected()){
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:NSLocalizedString(@"没有网络连接", nil)
                                     indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"]
                                        autoDismiss:YES
                                     dismissHandler:nil];
            return;
        }
        [self _triggerFavoriteActionWithButtonSeat:NEWSHAREPANEL];
        @strongify(contentItem);
        contentItem.selected = self.videoInfo.userRepined;
    };
    return contentItem;
}

- (TTCommodityContentItem *)commodityContentItem{
    TTCommodityContentItem *contentItem = [[TTCommodityContentItem alloc] initWithDesc:@"推荐商品"];
    @weakify(self);
    contentItem.customAction = ^{
        @strongify(self);
        if (self.commodityActionFired) {
            self.commodityActionFired();
            [self commodityLogV3WithEventName:@"commodity_recommend_click"];
        }
    };
    return contentItem;

}

- (TTDiggContentItem *)diggContentItem{
    TTDiggContentItem *contentItem = [[TTDiggContentItem alloc] init];
    contentItem.count = self.videoInfo.diggCount;
    contentItem.selected = self.videoInfo.userDigg;
    WeakSelf;
    @weakify(contentItem);
    contentItem.customAction = ^{
        StrongSelf;
        @strongify(contentItem);
        contentItem.banDig = NO;
        if (self.detailModel.protocoledArticle.userBury) {
            NSString *tip = NSLocalizedString(@"您已经踩过", nil);
            contentItem.banDig = YES;
            [TTShareMethodUtil showIndicatorViewInActivityPanelWindowWithTip:tip andImage:nil dismissHandler:nil];
        } else{
            if (_diggActionFired) {
                self.diggActionFired(!self.detailModel.protocoledArticle.userDigg);
            }
        }
    };
    return contentItem;
}

- (TTBuryContentItem *)buryContentItem{
    TTBuryContentItem *contentItem = [[TTBuryContentItem alloc] init];
    contentItem.count = self.videoInfo.buryCount;
    contentItem.selected = self.videoInfo.userBury;
    WeakSelf;
    @weakify(contentItem);
    contentItem.customAction = ^{
        StrongSelf;
        @strongify(contentItem);
        contentItem.banDig = NO;
        if (self.detailModel.protocoledArticle.userDigg) {
            NSString *tip = NSLocalizedString(@"您已经赞过", nil);
            contentItem.banDig = YES;
            [TTShareMethodUtil showIndicatorViewInActivityPanelWindowWithTip:tip andImage:nil dismissHandler:nil];
        } else {
            if (_buryActionFired){
                self.buryActionFired(!self.detailModel.protocoledArticle.userBury);
            }
        }
    };
    return contentItem;
}

//- (TTThreadDeleteContentItem *)deleteContentItem {
//    TTThreadDeleteContentItem * deleteContentItem = [[TTThreadDeleteContentItem alloc] initWithTitle:NSLocalizedString(@"删除", nil)
//                                                                                           imageName:@"delete_allshare"];
//    WeakSelf;
//    deleteContentItem.customAction = ^{
//        StrongSelf;
//        [self deleteAction];
//    };
//    return deleteContentItem;
//}

#pragma mark - share util

- (NSString *)shareTitle
{
    NSString *shareTitle;
    NSString *mediaName = [self.videoInfo.userInfo ttgc_contentName];
    if (!isEmptyString(mediaName)) {
        shareTitle = [NSString stringWithFormat:@"【%@】%@", mediaName, self.videoInfo.title];
    }
    else {
        shareTitle = self.videoInfo.title;
    }
    
    return shareTitle;
}

- (NSString *)timeLineTitle
{
    NSString *timeLineTitle;
    if (!isEmptyString(self.videoInfo.title)){
        timeLineTitle = [NSString stringWithFormat:@"%@-%@", self.videoInfo.title, @""];
    }else{
        timeLineTitle = NSLocalizedString(@"好房就在幸福里", nil);
    }
    return timeLineTitle;
}


- (NSString *)shareDesc
{
    Article *convertedArticle = [self.videoInfo ttv_convertedArticle];
    NSString *detail = isEmptyString(convertedArticle.abstract) ? NSLocalizedString(@"好房就在幸福里", nil) : convertedArticle.abstract;
    return detail;
}

- (NSString *)shareUrl
{
    NSString *shareUrl = [self.videoInfo shareURL];
    return shareUrl;
}

- (UIImage *)shareImage
{
    Article *convertedArticle = [self.videoInfo ttv_convertedArticle];
    //非列表页进入视频详情页，增加分享图片获取容错
    [self convertedAddVideoDetailInfo:convertedArticle];
    convertedArticle.mediaName = [self.videoInfo.userInfo ttgc_contentName];
    return [TTShareMethodUtil weixinSharedImageForArticle: convertedArticle];
}

- (UIImage *)imageWithView:(UIView *)view
{
    UIImage *iconImg = [UIImage imageNamed:@"video_play_share_icon.png"];
    UIImageView *iconImgView = [[UIImageView alloc] initWithImage:iconImg];
    iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    //iconImgView 方形 和view高度形同大小
    view.frame = CGRectMake(0, 0, view.size.width, view.size.height);
    iconImgView.size = CGSizeMake(view.size.height, view.size.height);
    [view addSubview:iconImgView];
    iconImgView.center = view.center;
    CGSize pageSize = view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - helper
- (void)convertedAddVideoDetailInfo:(Article *)convertedArticle
{
    if (!convertedArticle.largeImageDict && ![convertedArticle.videoDetailInfo valueForKey:VideoInfoImageDictKey]) {
        NSDictionary *videoDetailInfoLargeImageDic = [self.videoInfo.videoDetailInfo objectForKey:VideoInfoImageDictKey];
        NSMutableDictionary *videoDetailInfoMutableDic = [NSMutableDictionary dictionaryWithDictionary: convertedArticle.videoDetailInfo];
        [videoDetailInfoMutableDic setValue:videoDetailInfoLargeImageDic forKey:VideoInfoImageDictKey];
        convertedArticle.videoDetailInfo = [videoDetailInfoMutableDic copy];
    }
}

// 有分享面板时，控制视频是否能够根据设备方向转屏
- (void)setIsCanFullScreenFromOrientationMonitor:(BOOL)isCanFullScreen{
    if ([TTDeviceHelper OSVersionNumber] < 9.f) {
        [BDPlayerObjManager setIsCanFullScreenFromOrientationMonitorChanged:isCanFullScreen];
    }
}

#pragma mark - 分享转发面板
- (nullable NSArray<id<TTActivityContentItemProtocol>> *)forwardSharePanelContentItems {
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:[self outShareItems]];
//    [mutableArray addObjectsFromArray:[self shareItems]];
//    TTDirectForwardWeitoutiaoContentItem *directForwardContentItem = [[TTDirectForwardWeitoutiaoContentItem alloc] init];
//    directForwardContentItem.repostParams = [self repostParams];
//    directForwardContentItem.customAction = nil;
//    [mutableArray addObject:directForwardContentItem];
    
    return mutableArray.copy;
}

//- (NSDictionary *)repostParams
//{
//    NSDictionary *repostParams = [TTRepostService repostParamsWithRepostType:TTThreadRepostTypeArticle
//                                                               originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.videoInfo.ttv_convertedArticle]
//                                                                originThread:nil
//                                                originShortVideoOriginalData:nil
//                                                           originWendaAnswer:nil
//                                                           operationItemType:TTRepostOperationItemTypeArticle
//                                                             operationItemID:self.videoInfo.itemID
//                                                              repostSegments:nil];
//
//    return repostParams;
//}

//- (void)p_forwardToWeitoutiao {
//    // 文章详情页的转发，实际转发对象为文章，操作对象为文章
//    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict([self repostParams])];
//}

@end
