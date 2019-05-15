//
//  TTLiveMainViewController.m
//  Article
//
//  Created by matrixzk on 1/15/16.
//
//

#import "TTLiveMainViewController.h"
#import "TTNavigationController.h"
#import "TTLiveCellHelper.h"
#import <Masonry.h>
#import "NSStringAdditions.h"
#import "TTIndicatorView.h"
#import "TTPopTipsView.h"
#import "SSCommonLogic.h"

#import "TTAdapterManager.h"
#import "TTLiveStreamDataModel.h"
#import "TTLiveMessage.h"
#import "TTLiveTopBannerInfoModel.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "NSTimer+Additions.h"
#import <TTAccountBusiness.h>
#import "NetworkUtilities.h"
#import "TTRoute.h"

#import "TTLiveTabCategoryItem.h"
#import "TTFoldableLayout.h"
#import "TTLiveWebViewVC.h"
#import "TTHorizontalCategoryBar.h"
#import "TTSwipePageViewController.h"
#import "TTLiveChatTableViewController.h"
#import "TTLiveHeaderView.h"

#import "TTLiveAudioManager.h"
#import "TTLiveMainViewController+MessageHandler.h"

#import "TTLiveHeaderView+Video.h"
#import "TTLiveRemindView.h"

#import "TTLivePariseView.h"
#import "TTLiveFoldableLayout.h"
#import "TTImageView.h"
#import "TTSurfaceManager.h"

#define kHeightOfTopFakeNavBar 64
#define kHeightOfTopFakeNavBarMatch 74

@interface TTLiveMainViewController () <TTSwipePageViewControllerDelegate, TTLiveMessageBoxDelegate, UIViewControllerErrorHandler, TTLiveFakeNavigationBarDelegate, TTFoldableLayoutDelegate>

@property (nonatomic, strong) TTLiveStreamDataModel *streamDataModel;
@property (nonatomic, strong) TTLiveOverallInfoModel *overallModel;
@property (nonatomic, strong) TTLiveTopBannerInfoModel *topInfoModel;
@property (nonatomic, strong) TTLiveFoldableLayout *foldableLayout;
@property (nonatomic, strong) TTSwipePageViewController *swipePageVC;

@property (nonatomic, strong) TTLiveHeaderView *headerView;
@property (nonatomic, strong) TTImageView      *headerBackgroundImageView;
@property (nonatomic, strong) TTLivePariseView *pariseView;
@property (nonatomic, assign) BOOL              headerViewFolded;
@property (nonatomic, assign) BOOL              preStatusBarHidden;
@property (nonatomic, assign) CGFloat bannerHeight;
@property (nonatomic, strong) TTHorizontalCategoryBar *topTabView;
@property (nonatomic, strong) TTLiveFakeNavigationBar *fakeNavigationBar;
@property (nonatomic, strong) TTLiveFakeNavigationBar *animationFakeNavigationBar;
@property (nonatomic, strong) TTLiveFakeNavigationBar *droppedNavigationBar;
@property (nonatomic, strong) TTPopTipsView *popTipView;
@property (nonatomic, strong) TTLiveMessageBox *messageBoxView;
@property (nonatomic, strong) SSThemedView     *messageBoxBottomView;
@property (nonatomic, strong) NSMutableDictionary *trackerDic;

@property (nonatomic, strong) TTLiveDataSourceManager *dataSourceManager;

@property (nonatomic, strong) NSMutableDictionary *leaderRoleInfoDict;

// 聊天室停留时长事件统计
@property (nonatomic, strong) NSDate *enterDate;
// tab停留时长
@property (nonatomic, strong) NSDate *tabEnterDate;

@property (nonatomic, copy) NSString *originLiveStatus;

@property (nonatomic, strong) SSThemedButton *headerFoldedButton;

@property (nonatomic, assign)BOOL needGotoGuess;//需要定位到竞猜
@end

@implementation TTLiveMainViewController
{
    UIStatusBarStyle _currentStatusBarStyle;
    NSString * _lastPariseCountString;
    NSMutableArray<TTImageView *> * _infiniteIconViewList;
}

- (void)dealloc
{
    LOGD(@">>>>>> TTLiveMainVC Dealloc !!!!!");
    
    // stay event track
    [self eventTrack4StayLiveTabWithChannelIndex:_topTabView.selectedIndex]; // tab
    [self eventTrack4LiveRoomStayTime]; // live room
    
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 关掉音视频播放
//    [TTLiveManager stopCurrentPlayingAudioIfNeeded];
    [TTLiveAudioManager stopCurrentPlayingAudioIfNeeded];
//    [self stopLiveVideoIfNeeded];
    [self.headerView stopVideo];
    
    // 释放单例
//    [TTLiveManager freeSharedManager];
    
//    [self.timer invalidate];
//    self.timer = nil;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        NSDictionary *params = paramObj.allParams;
        self.overallModel = [[TTLiveOverallInfoModel alloc] init];
        self.overallModel.liveId = [params tt_stringValueForKey:@"liveid"];
        self.overallModel.referFrom = [params tt_stringValueForKey:@"from"];
        self.overallModel.adId = [params tt_stringValueForKey:@"ad_id"];
        self.overallModel.logExtra = [params tt_stringValueForKey:@"log_extra"];
        self.overallModel.enterFrom = [params tt_stringValueForKey:@"enter_from"];
        self.overallModel.categoryName = [params tt_stringValueForKey:@"category_name"];
        self.overallModel.logPb = [params tt_dictionaryValueForKey:@"log_pb"];
        self.overallModel.groupSource = [params tt_objectForKey:@"group_source"];
        self.overallModel.categoryID = [params tt_stringValueForKey:@"category_id"];
        if (!isEmptyString(self.overallModel.referFrom) && [self.overallModel.referFrom isEqualToString:@"guess"]){
            _needGotoGuess = YES;
        }
//        self.overallModel.liveId = @"6307430357977268481";//@"6307438716352725249";
//        if ([self.overallModel.liveId isEqualToString:@"6259251226370638084"]) {
//            self.overallModel.liveId = @"6307430357977268482";
//        }
//        self.overallModel.liveId = @"6317131497748824322";
        
        self.trackerDic = [[NSMutableDictionary alloc] initWithCapacity:4];
        [self.trackerDic setValue:self.overallModel.liveId forKey:@"value"];
        [self.trackerDic setValue:self.overallModel.referFrom forKey:@"refer"];
        self.lastInfiniteLike = 0;
        self.userDigCount = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveStatusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.ttHideNavigationBar = YES;
    _currentStatusBarStyle = UIStatusBarStyleDefault;
    
    self.fakeNavigationBar = [[TTLiveFakeNavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), [self fakeNavigationBarHeight])
                                                                   chatroom:self];
    [self.view addSubview:self.fakeNavigationBar];
    self.animationFakeNavigationBar = [[TTLiveFakeNavigationBar alloc] initWithFrame:self.fakeNavigationBar.frame
                                                                            chatroom:self];
    self.animationFakeNavigationBar.hidden = YES;
    
    //    [self setUpViewWithRequest];
    
    self.dataSourceManager = [[TTLiveDataSourceManager alloc] initWithChatroom:self];
    
    [self fetchHeaderInformation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.ttStatusBarStyle = _currentStatusBarStyle;
    // 暂时不支持其他界面返回自动播，考虑到免流入口退出返回的情况。
    // [_headerView viewWillAppear];
    if ([self.topInfoModel.background_type unsignedLongValue] == TTLiveTypeVideo) {
        [[UIApplication sharedApplication] setStatusBarHidden:!self.headerViewIsFolded && ![TTDeviceHelper isIPhoneXDevice] withAnimation:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    _currentStatusBarStyle = self.headerViewIsFolded ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
    [self.headerView pauseVideo];
    //core data
    if (self.streamDataModel || self.topInfoModel) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        if ( nil != self.streamDataModel.score1 ) {
            [param setValue:self.streamDataModel.score1 forKey:@"score1"];
        } else if (nil != self.topInfoModel.background.match.team1_score) {
            [param setValue:self.topInfoModel.background.match.team1_score forKey:@"score1"];
        }
        if ( nil != self.streamDataModel.score2 ) {
            [param setValue:self.streamDataModel.score2 forKey:@"score2"];
        } else if (nil != self.topInfoModel.background.match.team2_score) {
            [param setValue:self.topInfoModel.background.match.team2_score forKey:@"score2"];
        }
        if(nil != self.streamDataModel.participated){
            [param setValue:self.streamDataModel.participated forKey:@"participated"];
        } else if (nil != self.topInfoModel.participated) {
            [param setValue:self.topInfoModel.participated forKey:@"participated"];
        }
        if (!isEmptyString(self.streamDataModel.status_display)) {
            [param setValue:self.streamDataModel.status_display forKey:@"status_display"];
        } else if (!isEmptyString(self.topInfoModel.status_display)) {
            [param setValue:self.topInfoModel.status_display forKey:@"status_display"];
        }
        if ( nil != self.streamDataModel.status ) {
            [param setValue:self.streamDataModel.status forKey:@"status"];
        } else if (nil != self.topInfoModel.status) {
            [param setValue:self.topInfoModel.status forKey:@"status"];
        }
        if (!isEmptyString(self.overallModel.liveId)) {
            NSNumber *liveId = [NSNumber numberWithLongLong:[self.overallModel.liveId longLongValue]];
            [param setValue:liveId forKey:@"liveId"];
        }
        if ( nil != self.topInfoModel.title) {
            [param setValue:self.topInfoModel.title forKey:@"title"];
        }
        [param setValue:self.topInfoModel.followed forKey:@"followed"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TTLiveMainVCDeallocNotice
                                                            object:nil
                                                          userInfo:param];
    }
//    [_headerView viewWillDisappear];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGFloat topInset = self.view.tt_safeAreaInsets.top;
    switch ([self.topInfoModel.background_type unsignedIntegerValue]) {
        case TTLiveTypeVideo:
            topInset = self.fakeNavigationBar.height - 44;
            if (![TTDeviceHelper isIPhoneXDevice]){
                topInset = -topInset;
            }
            _fakeNavigationBar.top = topInset;
            _animationFakeNavigationBar.top = topInset;
            break;
        default:
            _fakeNavigationBar.top = topInset;
            _animationFakeNavigationBar.top = topInset;
            break;
    }
}

- (void)stopMovieViewPlay:(NSNotification *)notification {
    [self.headerView stopVideo];
}

- (TTLiveRemindView *)remindView {
    if (_remindView == nil) {
        _remindView = [[TTLiveRemindView alloc] init];
        _remindView.layer.cornerRadius = 13;
        _remindView.backgroundColorThemeKey = kColorBackground8;
        _remindView.userInteractionEnabled = YES;
        [_remindView addTarget:self action:@selector(scollToMessage) forControlEvents:UIControlEventTouchUpInside];
        _remindView.hidden = YES;
        [self.view insertSubview:_remindView belowSubview:_messageBoxView];
    }
    return _remindView;
}

- (void)scollToMessage {
    TTLiveChatTableViewController *chatVC = (TTLiveChatTableViewController *)[self currentChannelVC];
    [chatVC scrollToBottomWithAnimation:YES];
    
    [self eventTrackWithEvent:@"livetab"
                        label:@"news_click"
                    channelId:[(TTLiveTabCategoryItem *)self.overallModel.channelItems[_topTabView.selectedIndex] categoryId]];
}

- (UIViewController *)currentChannelVC
{
    return [_swipePageVC currentPageViewController];
}

- (UIViewController *)channelVCWithIndex:(NSInteger)index
{
    return [self.swipePageVC pageViewControllerWithIndex:index];
}

- (TTLiveTabCategoryItem *)channelItemWithChannelId:(NSInteger)channelId
{
    __block TTLiveTabCategoryItem *resultChannelItem;
    [self.overallModel.channelItems enumerateObjectsUsingBlock:^(TTLiveTabCategoryItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (channelId == item.categoryId.integerValue) {
            resultChannelItem = item;
            *stop = YES;
        }
    }];
    return resultChannelItem;
}

- (NSUInteger)tabIndexOfLiveChannelWithType:(TTLiveChannelType)channelType
{
    __block NSUInteger tabIndex = NSNotFound;
    [self.overallModel.channelItems enumerateObjectsUsingBlock:^(TTLiveTabCategoryItem * _Nonnull categoryItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (categoryItem.categoryId.integerValue == channelType) {
            tabIndex = idx;
            *stop = YES;
        }
    }];
    return tabIndex;
}

- (NSString *)leaderRoleNameWithUserID:(NSString *)userID
{
    return [_leaderRoleInfoDict valueForKey:userID];
}

- (BOOL)roleOfCurrentUserIsLeader
{
    return [self leaderRoleNameWithUserID:[TTAccountManager userID]] != nil;
}

- (void)showMessageOnSuitableChannel:(NSArray<TTLiveMessage *> *)messageArray
{
    NSInteger targetIndex = [self tabIndexOfLiveChannelWithType:[self roleOfCurrentUserIsLeader] ? TTLiveChannelTypeLive : TTLiveChannelTypeChat];
    UIViewController *targetPageVC = [self.swipePageVC pageViewControllerWithIndex:targetIndex];
    if ([targetPageVC isKindOfClass:[TTLiveChatTableViewController class]]) {
        if (targetIndex != self.topTabView.selectedIndex) {
            [self.swipePageVC setSelectedIndex:targetIndex];
            [self.topTabView setSelectedIndex:targetIndex];
        }
        [(TTLiveChatTableViewController *)targetPageVC addChatMessageItems:messageArray];
    }
}

- (UIEdgeInsets)edgeInsetsOfContentScrollView
{
    CGFloat bottomInset = [self roleOfCurrentUserIsLeader] ? kVisualHeightOfMsgBoxWithTypeSupportAll() : kVisualHeightOfMsgBoxWithTypeTextOnly();
    return UIEdgeInsetsMake(0, 0, bottomInset + 10, 0);
}

- (UIEdgeInsets)edgeInsetsOfContentWebScrollView
{
    CGFloat bottomInset = [self roleOfCurrentUserIsLeader] ? kVisualHeightOfMsgBoxWithTypeSupportAll() : kVisualHeightOfMsgBoxWithTypeTextOnly();
    return UIEdgeInsetsMake(0, 0, bottomInset, 0);
}

// 嘉宾身份登陆后，切换tab下的scrollView的contentInset
/*
- (void)resetEdgeInsetsOfContentScrollView
{
    [_swipePageVC.pages enumerateObjectsUsingBlock:^(__kindof UIResponder<TTFoldableLayoutItemDelegate> * _Nonnull currentPage, NSUInteger idx, BOOL * _Nonnull stop) {
        UIScrollView *scrollView = [currentPage tt_foldableDirvenScrollView];
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            scrollView.contentInset = [self edgeInsetsOfContentScrollView];
        }
        // LOGD(@"--");
    }];
}
 */


//旋转处理
- (void)receiveStatusBarOrientationChange:(NSNotification *)notice
{
    if ([TTDeviceHelper isPadDevice]) {
        
        [self tt_resetLayoutSubItems];
        
        CGRect frame = self.messageBoxView.frame;
        frame.origin.y = self.view.frame.size.height - CGRectGetHeight(frame);
        self.messageBoxView.frame = frame;
        
        self.popTipView.frame = CGRectMake(CGRectGetWidth(_headerView.frame) - adapterSpace(235),
                                           self.fakeNavigationBar.bottom - 3, adapterSpace(190),
                                           self.popTipView.frame.size.height);
//        self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)*(9.0/16));
    }
    self.remindView.centerX = self.view.centerX;
    self.remindView.bottom = self.view.height - _messageBoxView.height + 31 - self.view.tt_safeAreaInsets.bottom;
    if (@available(iOS 11.0, *)) {
        if ([self respondsToSelector:@selector(setNeedsUpdateOfHomeIndicatorAutoHidden)]) {
            [self setNeedsUpdateOfHomeIndicatorAutoHidden];
        }
    }
}

- (BOOL)prefersStatusBarHidden{
    if (self.overallModel.liveType.integerValue == TTLiveTypeVideo){
        return YES;
    }
    return NO;
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    BOOL landscape = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation);
    if (self.overallModel.liveType.integerValue == TTLiveTypeVideo && landscape){
        return YES;
    }
    return NO;
}

- (void)updateRemindView:(TTLiveMessage *)message {
    self.remindView.height = 28;
    self.remindView.centerX = self.view.centerX;
    self.remindView.bottom = self.view.height - _messageBoxView.height + 31 - self.view.tt_safeAreaInsets.bottom;;
    self.remindView.maxWidth = MAX(self.view.width - 60 * 2, 156);
    [self.remindView updateWithMessage:message];
}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    if ([TTDeviceHelper isPadDevice]) {
//        self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame)*(9.0/16));
//    }
//}
- (void)setPariseCount:(NSUInteger)pariseCount {
    NSString *newString = [self pariseCountStringValue:pariseCount];
    if (![_lastPariseCountString isEqualToString:newString]) {
        _lastPariseCountString = newString;
        [self.messageBoxView setPariseCount:newString];
    }
    _pariseCount = pariseCount;
}

- (NSString *)pariseCountStringValue:(NSUInteger)count {
    if (count < 10000) { //小于一万
        return [NSString stringWithFormat:@"%lu", (unsigned long)count];
    } else if (count < 999500) { //小于一百万
        return [NSString stringWithFormat:@"%.1lf万", (CGFloat)count / 10000];
    } else if (count < 100000000) { //小于一亿
        return [NSString stringWithFormat:@"%lu万", (unsigned long)count / 10000];
    } else if (count < 9995000000) { //小于一百亿
        return [NSString stringWithFormat:@"%.1lf亿", (CGFloat)count / 100000000];
    } else if (count < 1000000000000){ //一百亿以上
        return [NSString stringWithFormat:@"%lu亿", (unsigned long)count / 100000000];
    } else { //超过一万亿
        return @"9999亿";
    }
}

- (void)othersPariseDig:(NSUInteger)count inTime:(CGFloat)time {
    for (NSUInteger i = 0; i < count; i++) {
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * i / count * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray<NSString *>* urlList = wself.infiniteIconUrlList;
            if (urlList.count > 0) {
                NSUInteger index = arc4random() % urlList.count;
                [wself.pariseView otherPariseWithCommonImage:[urlList objectAtIndex:index]];
            }
        });
    }
}

#pragma mark -- 辅助函数

- (void)fetchHeaderInformation
{
    [self tt_startUpdate];
    
    WeakSelf;
    [self.dataSourceManager fetchHeaderInfoWithLiveId:self.overallModel.liveId finishBlock:^(NSError *error, TTLiveTopBannerInfoModel *headerInfo, NSString *tips) {
        StrongSelf;
        if (error) {
            
            if (!TTNetworkConnected()) {
                self.ttViewType = TTFullScreenErrorViewTypeNetWorkError;
            }
            else {
                self.ttViewType = TTFullScreenErrorViewTypeLocationServiceError;
            }
            
            [self tt_endUpdataData:NO error:error];
            
            if (tips){
                self.ttErrorView.errorMsg.text = tips;
            }
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            return ;
        }
        
        [self tt_endUpdataData];
        _currentStatusBarStyle = UIStatusBarStyleLightContent;
        self.ttStatusBarStyle = _currentStatusBarStyle;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        //全局model数据 overallModel.liveType
        self.topInfoModel = headerInfo;
        self.overallModel.liveType = headerInfo.background_type;
        self.overallModel.liveLeaders = headerInfo.leaders;
        self.overallModel.liveRoles = headerInfo.roles;
        self.overallModel.liveShareURL = headerInfo.share.url;
        self.overallModel.liveShareImage = [UIImage imageNamed:@"share_icon.png"];
        self.overallModel.liveShareImageURL = @"";
        self.overallModel.liveStateNum = headerInfo.status;
        self.overallModel.liveContent = headerInfo.share.summary;
        self.overallModel.liveShareGroupId = headerInfo.share.share_group_id;
        self.overallModel.liveTitle = headerInfo.share.title;
        self.overallModel.liveDescription = headerInfo.share.summary;
        self.overallModel.liveAbstract = headerInfo.share.summary;
        self.overallModel.userId = [TTAccountManager userID];
        self.overallModel.userName = [TTAccountManager userName];
        self.overallModel.userAvatarUrl = [TTAccountManager avatarURLString];
        self.overallModel.cameraBeautyEnable = headerInfo.cameraBeautyEnable;
        self.overallModel.initializeWithSelfieMode = headerInfo.initializeWithSelfieMode;
        self.overallModel.topMessageID = headerInfo.topMessageID;
        
//#if DEBUG
//        self.overallModel.cameraBeautyEnable = YES;
//        self.overallModel.initializeWithSelfieMode = YES;
//#endif
        
        
        self.leaderRoleInfoDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        [headerInfo.leaders enumerateObjectsUsingBlock:^(TTLiveLeaderModel * _Nonnull leaderModel, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *userId = leaderModel.uid.stringValue;
            NSInteger roleId = leaderModel.role.integerValue;
            [headerInfo.roles enumerateObjectsUsingBlock:^(TTLiveRoleModel * _Nonnull roleModel, NSUInteger idx, BOOL * _Nonnull stop) {
                if (roleModel.role.integerValue == roleId) {
                    [self.leaderRoleInfoDict setValue:roleModel.name forKey:userId];
                    *stop = YES;
                }
            }];
        }];
        
//        [TTLiveManager sharedManager].overalModel = self.overallModel;
        [self.trackerDic setValue:self.overallModel.liveStateNum forKey:@"stat"];
        
        self.originLiveStatus = self.topInfoModel.status.stringValue;
        
        [self setupSubviewsWithInfo:headerInfo];
    }];
}

- (void)setupSubviewsWithInfo:(TTLiveTopBannerInfoModel *)topInfoModel
{
    //统计
//    [[TTLiveManager sharedManager] trackerEvent:@"go_live" label:@"click" tab:nil extValue:nil];
    // event track
    [self eventTrackWithEvent:@"go_live" label:@"click"];
    
    WeakSelf;
    
    self.bannerHeight = CGRectGetWidth(self.view.frame) * (9.0/16);
    
    if (topInfoModel.background_type.integerValue == TTLiveTypeMatch){
        self.bannerHeight = [TTDeviceUIUtils tt_newPaddingSpecialElement:157];
        
        TTLiveMatchInfoModel *match = topInfoModel.background.match;

        switch (self.overallModel.liveStateNum.integerValue) {
            case TTLiveStatusPre:
            case TTLiveStatusPlaying:
                // 显示直播外链
                if (match.matchVideoLiveSource.videoSourceArray.count != 0){
                    self.bannerHeight = [TTDeviceUIUtils tt_newPaddingSpecialElement:201];
                }
                break;
            case TTLiveStatusOver:
                // 若有集锦回放外链，则切换显示；若无，则不显示
                if (match.matchVideoPlaybackSource.videoSourceArray.count != 0 || match.matchVideoCollectionSource.videoSourceArray.count != 0) {
                    self.bannerHeight = [TTDeviceUIUtils tt_newPaddingSpecialElement:201];
                }
                break;
            default:
                break;
        }
    }
    
    CGFloat heightOffset = 0;
    if ([TTDeviceHelper isIPhoneXDevice]){
        heightOffset = self.view.tt_safeAreaInsets.top;
        self.bannerHeight += heightOffset;
    }
    
    _headerView = [[TTLiveHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.bannerHeight)
                                                dataModel:topInfoModel
                                                 chatroom:self
                                             heightOffset:heightOffset];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _headerBackgroundImageView = [[TTImageView alloc] initWithFrame:_headerView.frame];
    _headerBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_headerBackgroundImageView];
    [self setupHeaderBackgroundImageViewWithInfoModel:topInfoModel];
    
    CGFloat droppedNavBarHeight = [self dropNavigationBarHeight];
    _fakeNavigationBar.height = [self fakeNavigationBarHeight];
    _animationFakeNavigationBar.height = [self fakeNavigationBarHeight];
    self.fakeNavigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.fakeNavigationBar.delegate = self;
    [self.fakeNavigationBar setupBarWithModel:topInfoModel type:TTLiveFakeNavigationBarTypeNormal];
    
    self.animationFakeNavigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.animationFakeNavigationBar.delegate = self;
    [self.animationFakeNavigationBar setupBarWithModel:topInfoModel type:TTLiveFakeNavigationBarTypeNormal];
    [_headerView addSubview:_animationFakeNavigationBar];
    //提示界面popTipView
    [self showTipFolllowView:topInfoModel];
    
    // 收起状态的导航条
   
    _droppedNavigationBar = [[TTLiveFakeNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, droppedNavBarHeight)
                                                                  chatroom:self];
    _droppedNavigationBar.alpha = 0.f;
    [self.view addSubview:_droppedNavigationBar];
    [_droppedNavigationBar setupBarWithModel:topInfoModel type:TTLiveFakeNavigationBarTypeSlide];
    _droppedNavigationBar.delegate = self;
    _droppedNavigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    CGFloat topInset = self.view.tt_safeAreaInsets.top;
    switch ([self.topInfoModel.background_type unsignedIntegerValue]) {
        case TTLiveTypeVideo:
            topInset = self.fakeNavigationBar.height - 44;
            [[UIApplication sharedApplication] setStatusBarHidden:![TTDeviceHelper isIPhoneXDevice]];
            if (![TTDeviceHelper isIPhoneXDevice]){
                topInset = -topInset;
            }
            _fakeNavigationBar.top = topInset;
            _animationFakeNavigationBar.top = topInset;
            break;
        default:
            _fakeNavigationBar.top = topInset;
            _animationFakeNavigationBar.top = topInset;
            break;
    }
    
    if ([topInfoModel.background_type unsignedIntegerValue] == TTLiveTypeVideo) {
        
    }
    
    // 频道切换
    _topTabView = [[TTHorizontalCategoryBar alloc] initWithFrame:CGRectMake(0, self.bannerHeight, CGRectGetWidth(self.view.frame), kHeightOfTopTabView)];
    _topTabView.bottomIndicatorEnabled = YES;
    _topTabView.leftAlignmentEnabled = YES;
    _topTabView.bottomIndicatorFitTitle = YES;
    _topTabView.enableAnimatedHighlighted = NO;
    [_topTabView setTabBarAnimateToBigger:NO];
    [_topTabView showVerticalLine:NO];
    [_topTabView setTabBarTextFont:[UIFont systemFontOfSize:TTLiveFontSize(16)]];
    
    _topTabView.interitemSpacing = 10;
    _topTabView.backgroundColorThemeKey = kColorBackground4;
    
    //使用主题换肤
    if ([TTSurfaceManager resurfaceEnable]){
        [_topTabView setTabBarTextColor:[UIColor tt_defaultColorForKey:kColorText1] maskColor:[TTSurfaceManager categoryBarColor] lineColor:[UIColor tt_defaultColorForKey:kColorLine1]];
        _topTabView.bottomIndicatorColor = [TTSurfaceManager categoryBarColor];
    }else{
        [_topTabView setTabBarTextColor:[UIColor tt_themedColorForKey:kColorText1] maskColor:[UIColor tt_themedColorForKey:kColorText4] lineColor:[UIColor tt_themedColorForKey:kColorLine1]];
        _topTabView.bottomIndicatorColor = [UIColor tt_themedColorForKey:kColorText4];
    }
    
    _topTabView.didSelectCategory = ^(NSUInteger index) { // , BOOL animated
        StrongSelf;
        
        // 滑动 pageVC
        if (index < self.overallModel.channelItems.count) {
            [self.swipePageVC setSelectedIndex:index];
            self.remindView.hidden = YES;
        }
        
        [self hiddenMessageBoxIfNeedAtIndex:index];
        
        //修改消息盒子统计
//        NSString *tab = [[TTLiveManager sharedManager] getTabStringById:[NSNumber numberWithInteger:index + 1]];
        ///...
        NSString *tabName = [self channelItemWithChannelId:(index + 1)].title;
        [self.trackerDic setValue:tabName forKey:@"tab"];
    };
    
    _topTabView.didTapCategoryItem = ^(NSUInteger indexOfTappedItem, NSUInteger currentIndex) {
        
        StrongSelf;
        
        if (indexOfTappedItem == currentIndex &&
            [[self currentChannelVC] isKindOfClass:[TTLiveChatTableViewController class]]) { // 在当前tab点击当前barItem
            
//            TTLiveChatTableViewController *chatVC = (TTLiveChatTableViewController *)[self currentChannelVC];
//            [chatVC triggerPullDownAction];
//            
//            // event track
//            TTLiveTabCategoryItem *item = [chatVC channelItem];
//            [self eventTrackWithEvent:@"livetab"
//                                label:item.badgeNum > 0 ? @"refresh_click_tip" : @"refresh_click"
//                            channelId:item.categoryId];
//            [[TTLiveManager sharedManager] trackerliveTab:item.categoryId label:item.bandgeNum > 0 ? @"refresh_click_tip" : @"refresh_click"];
        } else { // 点击其他tab
            
            if ([[self channelVCWithIndex:indexOfTappedItem] isKindOfClass:[TTLiveChatTableViewController class]]) {
                self.remindView.hidden = YES;
                TTLiveChatTableViewController *chatVC = (TTLiveChatTableViewController *)[self channelVCWithIndex:indexOfTappedItem];
                if (chatVC.tableView.contentOffset.y > 0) {
                    [chatVC.tableView setContentOffset:CGPointZero animated:NO];
                }
                [chatVC fetchLiveStreamDataSourceWithRefreshType:TTLiveMessageListRefreshTypePolling];
                [chatVC scrollToBottomWithAnimation:NO];
            }
            
            // stay event track
            [self eventTrack4StayLiveTabWithChannelIndex:currentIndex];
        }
        
        // event track
        NSArray *categoryItems = self.overallModel.channelItems;
        if (indexOfTappedItem < categoryItems.count) {
            [self eventTrackWithEvent:@"livetab"
                                label:(indexOfTappedItem == currentIndex) ? @"enter_click" : @"enter_other_click"
                            channelId:[(TTLiveTabCategoryItem *)categoryItems[indexOfTappedItem] categoryId]];
//            [[TTLiveManager sharedManager] trackerliveTab:[(TTLiveTabCategoryItem *)categoryItems[indexOfTappedItem] categoryId]
//                                                    label:(indexOfTappedItem == currentIndex) ? @"enter_click" : @"enter_other_click"];
        }
        
    };
    
    //分类列表与内容
    NSMutableArray *channelItems = [[NSMutableArray alloc] init];
    NSMutableArray *swipePageArray = [NSMutableArray arrayWithCapacity:topInfoModel.channels.count];
    for (TTLiveChannelModel *channel in topInfoModel.channels) {
        if (self.topInfoModel.disableComment && channel.channelId.integerValue == 2){
            continue;
        }
        TTLiveTabCategoryItem *item = [TTLiveTabCategoryItem new];
        item.categoryId = [NSNumber numberWithInteger:channel.channelId.integerValue];
        item.title = channel.name;
        item.categoryUrl = channel.channelUrl;
        item.maxCursor = @0;
        item.history = @0;
        [channelItems addObject:item];
        
        switch ([channel.channelId integerValue]) {
            case TTLiveChannelTypeLive:
            case TTLiveChannelTypeChat:
                [swipePageArray addObject:[[TTLiveChatTableViewController alloc] initWithChannelItem:item inChatroom:self]];
                break;
                
            default:
                [swipePageArray addObject:[[TTLiveWebViewVC alloc] initWithDataSourceModel:item chatroom:self]];
                break;
        }
    }
    
    
    //关系配置
//    [[TTLiveManager sharedManager] setupConfigWithMainViewController:self
//                                                          messageBox:self.messageBoxView];
//    [TTLiveManager sharedManager].categoryItems = channelItems;
    
    self.overallModel.channelItems = channelItems;
    _topTabView.categories = channelItems;
    
    //消息盒子messageBox
    [self setUpMessageView:topInfoModel];

    
    // swipePageVC
    _swipePageVC = [[TTSwipePageViewController alloc] initWithDefaultSelectedIndex:[self indexOfDefaultSelectedTab]];
    NSArray *pageItems = [NSArray arrayWithArray:swipePageArray];
    _swipePageVC.pages = pageItems;
    _swipePageVC.delegate = self;
    TTLiveFoldableLayout *foldableLayout = [[TTLiveFoldableLayout alloc] initWithItems:pageItems delegate:self];
    foldableLayout.headerView = _headerView;
    foldableLayout.pageViewController = _swipePageVC;
    foldableLayout.tabView = _topTabView;
    foldableLayout.minHeaderHeight = droppedNavBarHeight;
    
    foldableLayout.maxHeaderHeight = self.bannerHeight;
    foldableLayout.tabViewOffset = UIEdgeInsetsZero;
    
    if (self.overallModel.channelItems.count <= 1) {
        foldableLayout.tabViewHeight = 0;
    }
    
    // 视频直播，header不随手指滑动
    TTLiveType type = topInfoModel.background_type.integerValue;
    BOOL lockHeaderAutoFolded = NO;
    
    if (type == TTLiveTypeVideo) {
        lockHeaderAutoFolded = YES;
    } else if (type == TTLiveTypeMatch) {
        TTLiveMatchInfoModel *match = topInfoModel.background.match;
        TTLiveStatus status = [topInfoModel.status integerValue];
        switch (status) {
            case TTLiveStatusPre:
            case TTLiveStatusPlaying:
                if (match.matchVideoLiveSource.videoSourceArray.count > 0) {
                    lockHeaderAutoFolded = YES;
                }
                break;
            case TTLiveStatusOver:
                if (match.matchVideoPlaybackSource.videoSourceArray.count > 0 || match.matchVideoCollectionSource.videoSourceArray.count > 0) {
                    lockHeaderAutoFolded = YES;
                }
                break;
            default:
                break;
        }
    }
    
    if (!lockHeaderAutoFolded) {
        // 此参数赋值要在 self.tt_layout 赋值之前做，因为在给 self.tt_layout 赋值时做布局。
//    foldableLayout.lockHeaderAutoFolded = YES;
        foldableLayout.unlockPushToFolded = YES;
        _animationFakeNavigationBar.hidden = NO;
        [_animationFakeNavigationBar refreshActionButtonHidden:YES];
        [_fakeNavigationBar refreshTitleViewHidden:YES];
    } else {
        foldableLayout.lockHeaderAutoFolded = YES;
    }
//    [self addHeaderFoldedHandleButton];
//    }
    // 开始布局
    self.tt_layout = foldableLayout;
    self.foldableLayout = foldableLayout;
    [self.pariseView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(self.view).multipliedBy(0.3);
        make.width.mas_equalTo(56 * 2);
        make.right.equalTo(self.view).offset(56 - 68);
        make.top.equalTo(self.view).offset(self.bannerHeight);
        make.bottom.equalTo(self.view).offset(-44);
    }];
    
    _pariseView.startOffsetX = 56;
    
    [self.view bringSubviewToFront:_topTabView];
    [self.view bringSubviewToFront:_fakeNavigationBar];
    [self.view bringSubviewToFront:_droppedNavigationBar];
//    [self.view bringSubviewToFront:self.shareFollowView];
    // 必须保证该view在最上层，否则无法响应在点击非输入框区域时收起键盘。
    [self.view bringSubviewToFront:self.messageBoxView];
    [self.view bringSubviewToFront:self.messageBoxBottomView];
    [self.view bringSubviewToFront:_pariseView];
    if ([self roleOfCurrentUserIsLeader]) {
        [self.view bringSubviewToFront:self.messageBoxView];
        [self.view bringSubviewToFront:self.messageBoxBottomView];
    }

    // 初始化定位到server指定tab
    _topTabView.selectedIndex = [self indexOfDefaultSelectedTab];
    // 初始化tab如果不是聊天列表，msgBox将失去delegate。
//    self.messageBoxView.delegate = [self suitableChatViewController];
//    self.messageBoxView.delegate = [TTLiveMessageSendProxy new];
    self.messageBoxView.delegate = self;
    
    // 初始化停留时长统计时间戳
    self.enterDate = [NSDate date];
    self.tabEnterDate = [NSDate date];
    
    // 消息接口轮询
//    [self adjustPollingTimerWithTimeInterval:topInfoModel.refresh_interval];
    [self.dataSourceManager adjustPollingTimerWithTimeInterval:topInfoModel.refresh_interval];
    if ((![TTDeviceHelper isPadDevice]) && ([self.topInfoModel.background_type unsignedIntegerValue] != TTLiveTypeMatch) && self.topInfoModel.infiniteLike) {
        [self.dataSourceManager uploadParise];
    }
    
    _preStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    
    
    
}

- (void)setupHeaderBackgroundImageViewWithInfoModel:(TTLiveTopBannerInfoModel *)dataModel{
        // 背景图
        switch (dataModel.background_type.integerValue) {
                
            case TTLiveTypeSimple:
                [_headerBackgroundImageView setImageWithModel:[[TTImageInfosModel alloc] initWithDictionary:dataModel.background.simple.covers]];
                break;
                
            case TTLiveTypeStar:
                [_headerBackgroundImageView setImageWithModel:[[TTImageInfosModel alloc] initWithDictionary:dataModel.background.star.covers]];
                break;
                
            case TTLiveTypeMatch:
                [_headerBackgroundImageView setImageWithModel:[[TTImageInfosModel alloc] initWithDictionary:dataModel.background.match.covers]];
                break;
                
            case TTLiveTypeVideo:
                [_headerBackgroundImageView setImageWithModel:[[TTImageInfosModel alloc] initWithDictionary:dataModel.background.video.videoCover]];
                break;
            default:
                break;
        }
}

- (TTLiveChatTableViewController *)suitableChatViewController
{
    TTLiveChatTableViewController *chatVC = (TTLiveChatTableViewController *)[self channelVCWithIndex:[self tabIndexOfLiveChannelWithType:TTLiveChannelTypeChat]];
    if (![chatVC isKindOfClass:[TTLiveChatTableViewController class]]) {
        chatVC = (TTLiveChatTableViewController *)[self channelVCWithIndex:[self tabIndexOfLiveChannelWithType:TTLiveChannelTypeLive]];
        if (![chatVC isKindOfClass:[TTLiveChatTableViewController class]]) {
            chatVC = nil;
        }
    }
    return chatVC;
}

- (NSUInteger)indexOfDefaultSelectedTab
{
    __block NSUInteger index = [self tabIndexOfLiveChannelWithType:_topInfoModel.default_channel.integerValue];
    if (_needGotoGuess){
        //需要定位到名字为“竞猜”的tab
        [self.overallModel.channelItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTCategoryItem *item = (TTCategoryItem *)obj;
            if ([item.title isEqualToString:@"竞猜"]){
                index = idx;
                *stop = YES;
            }
        }];
    }
    return index == NSNotFound ? 0 : index;
}

- (void)addHeaderFoldedHandleButton
{
    SSThemedButton *headerFoldedButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    headerFoldedButton.tag = 160719;
    headerFoldedButton.imageName = @"chatroom_icon_up";
    headerFoldedButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
    [headerFoldedButton addTarget:self action:@selector(headerFoldedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_topTabView addSubview:headerFoldedButton];
    [headerFoldedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_topTabView.mas_right).offset(-18);
        make.centerY.equalTo(_topTabView.mas_centerY);
    }];
    _headerFoldedButton = headerFoldedButton;
}

- (void)headerFoldedButtonPressed:(UIButton *)button
{
    [self resetStateOfFoldedButton:button];
    [self foldedHeaderView:button.isSelected];
    
    // event track
    [self eventTrackWithEvent:@"live" label:button.isSelected ? @"video_retract" : @"video_launch"];
}

- (void)resetStateOfFoldedButton:(UIButton *)button
{
    [self resetStateOfFoldedButton:button withSelected:!button.isSelected];
}

- (void)resetStateOfFoldedButton:(UIButton *)button withSelected:(BOOL)selected {
    if (button.isSelected != selected) {
        [UIView animateWithDuration:0.25 animations:^{
            button.transform = CGAffineTransformRotate(button.transform, M_PI);
        } completion:nil];
        button.selected = selected;
    }
}

// 展开HeaderView
- (void)unfoldedHeaderView
{
    [self foldedHeaderView:NO];
    [self resetStateOfFoldedButton:[_topTabView viewWithTag:160719]];
}

- (void)foldedHeaderView:(BOOL)folded
{
    if (folded) {
        self.foldableLayout.unlockPushToFolded = NO;
        [self tt_resetLayoutToMinHeader:YES];
    } else {
        self.foldableLayout.unlockPushToFolded = YES;
        [self tt_resetLayoutToMaxHeader:YES];
    }
    if ([self.topInfoModel.background_type unsignedLongValue] == TTLiveTypeVideo) {
        folded = folded && ![TTDeviceHelper isIPhoneXDevice];
        [[UIApplication sharedApplication] setStatusBarHidden:!folded withAnimation:NO];
    }
}

// HeaderView 是否处于收起状态
- (BOOL)headerViewIsFolded
{
    return _headerViewFolded;
}

//- (void)stopLiveVideoIfNeeded
//{
//    [self.headerView stopVideo];
//}

- (void)pauseLiveVideoIfNeeded
{
    [self.headerView pauseVideo];
}

- (void)startLiveVideoIfNeeded
{
    if (![self headerViewIsFolded]) {
        [self.headerView playVideo];
    }
}

//发言框
- (void)setUpMessageView:(TTLiveTopBannerInfoModel *)model
{
    CGFloat height = [self roleOfCurrentUserIsLeader] ? kRealHeightOfMsgBoxWithTypeSupportAll() : kRealHeightOfMsgBoxWithTypeTextOnly();
    self.messageBoxView = [[TTLiveMessageBox alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - height,
                                                                             CGRectGetWidth(self.view.frame), height)];
    _messageBoxBottomView = [[SSThemedView alloc] init];
    _messageBoxBottomView.backgroundColorThemeKey = kColorBackground4;
    _messageBoxBottomView.frame = CGRectMake(0, self.view.height - self.view.tt_safeAreaInsets.bottom, self.view.width, self.view.tt_safeAreaInsets.bottom);
    self.messageBoxView.mainChatroom = self;
    self.messageBoxView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    BOOL isAudience = ![self roleOfCurrentUserIsLeader];
    self.messageBoxView.type = [model.background_type unsignedIntegerValue];
    self.messageBoxView.shouldShowPariseButton = model.infiniteLike;
    self.messageBoxView.disableSendMsg = model.disableComment;
    if (isAudience) {
        [self.messageBoxView setMessageViewType:TTLiveMessageBoxTypeSupportTextOnly];
    } else {
        [self.messageBoxView setMessageViewType:TTLiveMessageBoxTypeSupportAll];
    }
    _infiniteIconViewList = [[NSMutableArray<TTImageView *> alloc] init];
    _infiniteIconUrlList = [[NSMutableArray<NSString *> alloc] init];
    for (NSString *url in model.infiniteLikeIconList) {
        [_infiniteIconViewList addObject:[self loadImageViewWithURLString:url]];
        [_infiniteIconUrlList addObject:url];
    }
    [self.messageBoxView changePariseCommonImage:model.infiniteLikeIcon];
    
    if (isEmptyString(model.talk_tips)) {
        [self.messageBoxView setInputPlaceholder:@"我来说两句"
                                       TextColor:[UIColor colorWithHexString:@"999999"]];
    }
    else {
        [self.messageBoxView setInputPlaceholder:model.talk_tips
                                       TextColor:[UIColor colorWithHexString:@"999999"]];
    }
    
//    NSString *tab = [[TTLiveManager sharedManager] getTabStringById:@1];
    NSUInteger indexOfDefaultTab = [self indexOfDefaultSelectedTab];
    NSString *tabName;
    if (indexOfDefaultTab < self.overallModel.channelItems.count) {
        tabName = self.overallModel.channelItems[indexOfDefaultTab];
    }
    [self.trackerDic setValue:tabName forKey:@"tab"];
    [self.messageBoxView setSsTrackerDic:self.trackerDic];
    
    [self.view addSubview:self.messageBoxView];
    [self.view addSubview:self.messageBoxBottomView];
}

- (TTImageView *)loadImageViewWithURLString:(NSString *)url {
    TTImageView *image = [[TTImageView alloc] init];
    [image setImageWithURLString:url placeholderImage:nil];
    return image;
}

//提示关注界面
- (void)showTipFolllowView:(TTLiveTopBannerInfoModel *)model
{
    if (model.status.integerValue != TTLiveStatusPre ||
        model.followed.boolValue ||
        ![SSCommonLogic showLiveChatTipViewForliveId:self.overallModel.liveId] ||
        [self roleOfCurrentUserIsLeader]) {
        return;
    }
    
    [SSCommonLogic setShowLiveChatTipView:NO liveId:self.overallModel.liveId];
    
    TTPopTipItem *tipItem = [[TTPopTipItem alloc] init];
    tipItem.type = TTPopTipsMessage;
    tipItem.tipBtnTitle = @"知道了";
    tipItem.tipDesc = model.follow_tips;
    WeakSelf;
    tipItem.block = ^(){
        StrongSelf;
        [SSCommonLogic setShowLiveChatTipView:NO liveId:self.overallModel.liveId];
        [self.popTipView dismissAnimate:YES];
        // event track
        [self eventTrackWithEvent:@"live" label:@"pop_know_click"];
    };
    CGFloat followButtonCenterToRight = [self.fakeNavigationBar followButtonCenterxToRight];
    CGFloat popTipViewTop = [self fakeNavigationBarHeight] - 3;
    if (_topInfoModel.background_type.integerValue == TTLiveTypeVideo){
        CGFloat statusBarHeight = self.fakeNavigationBar.height - 44;
        if ([TTDeviceHelper isIPhoneXDevice]){
            statusBarHeight = -statusBarHeight;
        }
        popTipViewTop -= statusBarHeight;
        //扣掉一个statusBar的高度
    }else if (_topInfoModel.background_type.integerValue == TTLiveTypeMatch){
        popTipViewTop += [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    self.popTipView = [[TTPopTipsView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_headerView.frame)-(TTLivePadding(190) -  adapterSpace(10) * 1.5 + followButtonCenterToRight), popTipViewTop, TTLivePadding(190), self.popTipView.frame.size.height)];
    [self.popTipView setPopViewWithItem:@[tipItem] type:TTPopTipsMessage];
    self.popTipView.hidden = YES;
    [_headerView addSubview:self.popTipView];
    
    [self.popTipView showAnimate:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.popTipView.dismiss) {
            [self.popTipView dismissAnimate:YES];
            // event track
            [self eventTrackWithEvent:@"live" label:@"pop_auto_disapper"];
        }
    });
    
    // event track
    [self eventTrackWithEvent:@"live" label:@"pop_show"];
}

- (void)refreshRedBadgeAndOnlineUserAndScore:(TTLiveStreamDataModel *)model
{
    if ([self.streamDataModel.participated unsignedLongLongValue] > [model.participated unsignedLongLongValue]) {
        model.participated = self.streamDataModel.participated;
    }
    
    self.streamDataModel = model;
    
    [self.fakeNavigationBar refreshBarWithModel:model];
    [self.animationFakeNavigationBar refreshBarWithModel:model];
    // 刷新收起状态的naviBar
    [self.droppedNavigationBar refreshBarWithModel:model];
    // 刷新header
    [self.headerView refreshHeaderViewWithModel:model];
    
    //红点
    _topTabView.categories = self.overallModel.channelItems;
}

- (TTLivePariseView *)pariseView {
    if (_pariseView == nil) {
        _pariseView = [[TTLivePariseView alloc] init];
        _pariseView.hidden = YES;
        [self.view addSubview:_pariseView];
    }
    return _pariseView;
}

- (void)makeShare
{
    [self.fakeNavigationBar makeShare:nil];
}

- (void)firstInDig {
    [self othersPariseDig:20 inTime:5];
}

#pragma mark - TTLiveFakeNavigationBarDelegate

//- (void)ttLiveFakeNavigationBarEllipsisBtnClicked
//{
//    [self setUpShareFollowViewWithModel:self.topInfoModel];
//    [self.shareFollowView showAnimate:YES];
//    [[TTLiveManager sharedManager] trackerMainLiveLabel:@"dot_click"];
//}

- (void)navigationBarTap{
    if (![self headerViewIsFolded]){
        return;
    }
    if ([self.currentChannelVC respondsToSelector:@selector(tableView)]){
        UITableView *tableView = [self.currentChannelVC performSelector:@selector(tableView)];
        if (tableView.isDecelerating){
            self.foldableLayout.lockFoldOneOpen = YES;
        }
    }
    [self foldedHeaderView:NO];
}

- (void)ttLiveFakeNavigationBarReserve:(BOOL)reserve success:(BOOL)success
{
    // event track
    if (self.popTipView && !self.popTipView.dismiss) {
        [self.popTipView dismissAnimate:YES];
        
//        [[TTLiveManager sharedManager] trackerMainLiveLabel:@"pop_reserve_disapper"];
        // event track
        [self eventTrackWithEvent:@"live" label:@"pop_reserve_disapper"];
    }
    
    NSString *text;
    
    //状态
    if (!success && !reserve) {
        text = @"取消关注失败!";
        self.topInfoModel.followed = @1;
    }
    else if (!success && reserve) {
        text = @"关注失败!";
        self.topInfoModel.followed = @0;
    }
    else if (success && reserve) {
        text = @"关注成功";
        self.topInfoModel.followed = @1;
    }
    else if (success && !reserve) {
        text = @"已取消关注";
        self.topInfoModel.followed = @0;
    }
    
    //提示
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                              indicatorText:text
                             indicatorImage:nil
                                autoDismiss:YES
                             dismissHandler:nil];
}


#pragma mark - TTFoldableLayoutDelegate Methods

//传入一个percent，代表进度。1表示展开，0表示收起
- (void)distanceDidChanged:(CGFloat)distance
{
    BOOL fold = distance < 0.05;
    CGFloat alpha = fold ? 1:0;
    
    if (_headerViewFolded != fold){
        _headerViewFolded = fold;
    }
    
    _droppedNavigationBar.alpha = alpha;
    
    if (fold) {
        UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight){
            statusBarStyle = UIStatusBarStyleLightContent;
        }
        [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle animated:NO];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    _fakeNavigationBar.hidden = fold;
}


#pragma mark - TTSwipePageViewControllerDelegate Methods

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
           pagingFromIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex
           completePercent:(CGFloat)percent
{
    [_topTabView updateInteractiveTransition:percent fromIndex:fromIndex toIndex:toIndex];
}

- (void)hiddenMessageBoxIfNeedAtIndex:(NSInteger)toIndex {
    if (self.topInfoModel.background_type.integerValue == TTLiveTypeMatch){
        TTLiveChannelModel *channelItem = self.topInfoModel.channels[toIndex];
        switch ([channelItem.channelId integerValue]) {
            case TTLiveChannelTypeLive:
            case TTLiveChannelTypeChat:
            {
                [UIView animateWithDuration:.25 animations:^{
                    _messageBoxView.alpha = 1;
                    _messageBoxBottomView.alpha = 1;
                }];
                break;
            }
            default:
            {
                [UIView animateWithDuration:.25 animations:^{
                    _messageBoxView.alpha = 0;
                    _messageBoxBottomView.alpha = 0;
                }];
            }
                break;
        }
    }
}

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
          didPagingToIndex:(NSInteger)toIndex
{
    NSUInteger lastIndex = _topTabView.selectedIndex;
    _topTabView.selectedIndex = toIndex;
    
    if ([[self channelVCWithIndex:toIndex] isKindOfClass:[TTLiveChatTableViewController class]]) {
        TTLiveChatTableViewController *chatVC = (TTLiveChatTableViewController *)[self channelVCWithIndex:toIndex];
        
//        self.messageBoxView.delegate = chatVC;
        
        // 若有新消息，则拉取显示。
        if (chatVC.channelItem.badgeNum > 0) {
            [chatVC.tableView setContentOffset:CGPointZero animated:YES];
            [chatVC scrollToBottomWithAnimation:NO];
            [chatVC fetchLiveStreamDataSourceWithRefreshType:TTLiveMessageListRefreshTypePolling];
        }
    }
    
    // stay event track
    [self eventTrack4StayLiveTabWithChannelIndex:lastIndex];
    
    // event track
    if (toIndex > 0 && toIndex < self.overallModel.channelItems.count) {
        [self eventTrackWithEvent:@"livetab"
                            label:@"enter_flip"
                        channelId:[(TTLiveTabCategoryItem *)self.overallModel.channelItems[toIndex] categoryId]];
    }
//    [[TTLiveManager sharedManager] trackerliveTab:[(TTLiveTabCategoryItem *)self.overallModel.channelItems[toIndex] categoryId]
//                                            label:@"enter_flip"];
    //在web tab下隐藏输入框，如果是体育直播的话
    [self hiddenMessageBoxIfNeedAtIndex:toIndex];
}

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
         willPagingToIndex:(NSInteger)toIndex
{
}

- (void)pageViewControllerWillBeginDragging:(UIScrollView *)scrollView
{
}


#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return NO;
}

- (void)refreshData{
    
    //首次获取数据失败，点击刷新
//    [self setUpViewWithRequest];
    [self fetchHeaderInformation];
}


#pragma mark - Notification

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    [self eventTrack4LiveRoomStayTime];
    [self eventTrack4StayLiveTabWithChannelIndex:_topTabView.selectedIndex];
    //NSLog(@">>>>>>>>>> stayTime , EnterBackground ");
    
//    if (TTLiveTypeVideo == self.topInfoModel.background_type.integerValue) {
//        [self.headerView pauseVideo];
//    }
    [self.dataSourceManager pauseTimer];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    self.enterDate = [NSDate date];
    self.tabEnterDate = [NSDate date];
    
//    if (TTLiveTypeVideo == self.topInfoModel.background_type.integerValue) {
//        [self.headerView playVideo];
//    }
    [self.dataSourceManager resumeTimer];
}


#pragma mark - Stay Event Track

// 直播室停留时长统计
- (void)eventTrack4LiveRoomStayTime
{
    if (!self.enterDate) {
        return;
    }
    
    NSString *intervalStr = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSinceDate:self.enterDate] * 1000)];
    [self eventTrackWithEvent:@"stay_live" label:@"click" channelId:nil extraValue:intervalStr];
//    [[TTLiveManager sharedManager] trackerEvent:@"stay_live"
//                                          label:@"click"
//                                            tab:nil
//                                       extValue:intervalStr];
//NSLog(@">>>>>>>>>> Send Event stayTime : %@", intervalStr);
}

// tab停留时长统计
- (void)eventTrack4StayLiveTabWithChannelIndex:(NSUInteger)channelIndex
{
    if (!self.tabEnterDate || channelIndex >= self.overallModel.channelItems.count) {
        return;
    }
    
//    NSString *tabName = [(TTLiveTabCategoryItem *)self.overallModel.channelItems[channelIndex] title];
    NSString *intervalStr = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSinceDate:self.tabEnterDate] * 1000)];
    [self eventTrackWithEvent:@"stay_livetab"
                        label:nil
                    channelId:[(TTLiveTabCategoryItem *)self.overallModel.channelItems[channelIndex] categoryId]
                   extraValue:intervalStr];
//    [[TTLiveManager sharedManager] trackerEvent:@"stay_livetab"
//                                          label:nil
//                                            tab:tabName
//                                       extValue:intervalStr];
    // 重置时间戳
    self.tabEnterDate = [NSDate date];
//NSLog(@">>>>>>>>>> Send Event stay_livetab : %@, tab : %@", intervalStr, tabName);
}

/** 顶部导航栏高度 */
- (CGFloat)fakeNavigationBarHeight {
    return ([self.topInfoModel.background_type unsignedIntegerValue] == TTLiveTypeVideo ? kHeightOfTopFakeNavBar : kHeightOfTopFakeNavBar - 20);
}

- (CGFloat)dropNavigationBarHeight {
    if (self.view.tt_safeAreaInsets.top > 0){
        return self.view.tt_safeAreaInsets.top + 44;
    }
    return kHeightOfTopFakeNavBar;
}

#pragma mark -- ThemedChange

- (void)themeChanged:(NSNotification *)notification
{
    if ([TTSurfaceManager resurfaceEnable]){
        [_topTabView setTabBarTextColor:[UIColor tt_defaultColorForKey:kColorText1] maskColor:[TTSurfaceManager categoryBarColor] lineColor:[UIColor tt_defaultColorForKey:kColorLine1]];
        _topTabView.bottomIndicatorColor = [TTSurfaceManager categoryBarColor];
    }else{
        [_topTabView setTabBarTextColor:[UIColor tt_themedColorForKey:kColorText1] maskColor:[UIColor tt_themedColorForKey:kColorText4] lineColor:[UIColor tt_themedColorForKey:kColorLine1]];
        _topTabView.bottomIndicatorColor = [UIColor tt_themedColorForKey:kColorText4];
    }
    [_topTabView updateAppearanceColor];
}

@end


@implementation TTLiveMainViewController (EventTracker)

- (void)eventTrackWithEvent:(NSString *)event label:(NSString *)label
{
    [self eventTrackWithEvent:event label:label channelId:nil];
}

- (void)eventTrackWithEvent:(NSString *)event label:(NSString *)label channelId:(NSNumber *)channelId
{
    [self eventTrackWithEvent:event label:label channelId:channelId extraValue:nil];
}

- (void)eventTrackWithEvent:(NSString *)event label:(NSString *)label channelId:(NSNumber *)channelId extraValue:(NSString *)extValue
{
    if (isEmptyString(event)) {
        return;
    }
    
    NSMutableDictionary *extraDic = [NSMutableDictionary new];
    // [extraDic setValue:self.overallModel.liveStateNum forKey:@"stat"];
    [extraDic setValue:self.streamDataModel ? self.streamDataModel.status : self.overallModel.liveStateNum
                forKey:@"stat"];
    [extraDic setValue:self.overallModel.referFrom forKey:@"refer"];
    if (!isEmptyString(extValue)) {
        [extraDic setValue:extValue forKey:@"ext_value"];
    }
    if (channelId) {
        NSString *tabName = [self channelItemWithChannelId:channelId.integerValue].title;
        [extraDic setValue:tabName forKey:@"tab"];
    }
    if ([event isEqualToString:@"stay_live"] && !isEmptyString(self.originLiveStatus)) {
        [extraDic setValue:self.originLiveStatus forKey:@"stat0"];
    }
    
    if ([TTTrackerWrapper isOnlyV3SendingEnable] && ([event isEqualToString:@"stay_live"] || [event isEqualToString:@"go_live"])) {
    } else {
        wrapperTrackEventWithCustomKeys(event, label, self.overallModel.liveId, nil, extraDic);
    }
    
    // AppLog 3.0
    if ([event isEqualToString:@"stay_live"] || [event isEqualToString:@"go_live"]) {
        
        NSMutableDictionary *log3Dict = [extraDic mutableCopy];
        [log3Dict removeObjectForKey:@"refer"];
        [log3Dict setValue:self.overallModel.liveId forKey:@"group_id"];
        [log3Dict setValue:self.overallModel.enterFrom forKey:@"enter_from"];
        [log3Dict setValue:self.overallModel.categoryName forKey:@"category_name"];
        [log3Dict setValue:self.overallModel.logPb forKey:@"log_pb"];
        [log3Dict setValue:self.overallModel.groupSource forKey:@"group_source"];
        
        NSString *eventV3;
        if ([event isEqualToString:@"go_live"]) {
            eventV3 = @"go_detail";
        } else if ([event isEqualToString:@"stay_live"]) {
            eventV3 = @"stay_page";
            if (!isEmptyString(extValue)) {
                [log3Dict setValue:extValue forKey:@"stay_time"];
            }
        }
        
        if (!eventV3) return;
        
        [TTTrackerWrapper eventV3:eventV3 params:log3Dict isDoubleSending:YES];
    }
}

@end
