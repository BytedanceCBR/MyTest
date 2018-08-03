//
//  SettingVIew.m
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SettingView.h"
#import "SSSimpleCache.h"
#import "SSFeedbackViewController.h"
#import "NSStringAdditions.h"

#import "NewsLogicSetting.h"
#import "NewsUserSettingManager.h"
#import "ArticleTitleImageView.h"
#import "APNsManager.h"

#import "NewsDetailLogicManager.h"
#import "SSFeedbackManager.h"
#import "SSWebViewController.h"
#import "ArticleURLSetting.h"
#import "TTInstallIDManager.h"
#import "DebugUmengIndicator.h"
#import "SSNavigationBar.h"
#import "ExploreLogicSetting.h"
#import "TTTrackerWrapper.h"
#import "SSCommonLogic.h"
#import "SSTrashManager.h"
#import <TTImage/TTWebImageManager.h>
#import "TTIndicatorView.h"
#import "ExploreItemActionManager.h"
#import "TTThemedAlertController.h"

//#import "FRLogicManager.h"

#import "TTNavigationController.h"
#import "TTSettingADSplashVC.h"

#import "SettingPushCell.h"
#import "SettingNormalCell.h"
#import "SettingSwitch.h"

#import "TTABHelper.h"
#import "revision.h"

#import "TTAuthorizeHintView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"

#import "TTStringHelper.h"
#import "TTLabelTextHelper.h"
#import "TTUserSettingsManager.h"

#import "BlockUsersListViewController.h" // 黑名单

#import "TTEditUserProfileViewController.h"
#import "TTAccountBindingViewController.h"
#import "TTEditUserLogoutCell.h"

#import "TTSettingConstants.h"
#import "TTEditUserProfileItemCell.h"

#import "NewsBaseDelegate.h"
#import "TTAuthorizeManager.h"
#import "ExploreMovieView.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"
#import "TTModuleBridge.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import "TTUserSettings/TTUserSettingsManager+Notification.h"

#import "IESVideoPlayer.h"
#import <TTRexxar/TTRPackageManager.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import <BDTBasePlayer/TTVOwnPlayerCacheWrapper.h>

//#import "TTLivePlayerTrafficViewController.h"
#import "TTAdSplashMediator.h"
#import "TTAdSplashSettingVC.h"
#import "TTTabBarProvider.h"
#import "TTSettingMineTabManager.h"
#import "TTTabBarProvider.h"

//爱看
#import "AKTaskSettingHelper.h"

#define kCellHeight     43.f
#define UMENG_SETTINGVIEW_EVENT_ID_STR @"more_tab"

#define kActionSheetForClearCacheTag        1
#define kActionSheetForImageSetting         3
#define kActionSheetForFontSetting          4
#define kActionSheetCommentDisplaySetting   5
#define kActionSheetForVideoTrafficTip      6

#define kRedpointTag                    5001
#define kFeedbackRedpointTag            5003
#define kHasNewVersionTag               5004


#ifndef BuildRev
#define BuildRev ""
#endif

typedef NS_ENUM(NSUInteger, TTSettingSectionType) {
    kTTSettingSectionTypeNone = 0,
    kTTSettingSectionTypeAccount,      // 编辑资料、帐号与绑定设置、黑名单
    kTTSettingSectionTypeAbstractFont, // 列表显示摘要、字体大小
    //    kTTSettingSectionTypeFlowCache,    // 非wifi网络流量、清理缓存
    //    kTTSettingSectionTypeNotification, // 推送通知、收藏时转发、自动播放视频
    kTTSettingSectionTypeTTCover,      // 头条封面、当前版本、使用帮助
    kTTSettingSectionTypeLogout,       // 退出登录
    //    kTTSettingSectionTypeUmengDebug,   // 友盟Debug
};

typedef NS_ENUM(NSUInteger, TTSettingCellType) {
    SettingCellTypeNone = 0,                // 无
    SettingCellTypeFeedback,                // 反馈
    SettingCellTypeResourceMode,            // 夜间模式
    SettingCellTypeReadMode,                // 列表显示摘要
    SettingCellTypeFontMode,                // 字体大小
    SettingCellTypeLoadImageMode,           // 移动网络流量
    SettingCellTypeClearCache,              // 清除缓存
    SettingCellTypePushNotification,        // 推送通知
    SettingCellTypeCoinTaskSetting ,        // 金币任务设置
    SettingCellTypeVideoTrafficTip,         // 视频流量弹窗提示
    SettingCellTypeVideoAutoPlay,           // 视频自动播放
    SettingCellTypeCheckNewVersion,         // 检查新版本
    SettingCellTypeNatantSwitch,            // 浮层开关
    SettingCellTypeClientEscapeSwitch,      // 自动优化阅读
    SettingCellTypeShowBtn4Refresh,         // 显示列表悬浮刷新按钮
    
    SettingCellTypeADRegisterEntrance,      // 广告主注册入口
    SettingCellTypeShowADSplash,            // 展示开屏广告图
    SettingCellTypeAccountManagement,       // 账号管理/编辑资料
    
    SettingCellTypeAccountBindingSetting,   // 帐号和绑定设置
    SettingCellTypeBlockUsersList,          // 黑名单
    
    SettingCellTypeLogout,                  // 退出登录
};
typedef TTSettingCellType SettingCellType;


typedef NS_ENUM(NSUInteger, ArticleSettingViewCacheStatus) {
    ArticleSettingViewCacheStatusNormal,        // 默认情况
    ArticleSettingViewCacheStatusCalculating,   // 正在计算
    ArticleSettingViewCacheStatusCalcCompleted, // 正在计算
    ArticleSettingViewCacheStatusTrashing       // 正在清理
};

static NSString *const TTVideoTrafficTipSettingKey = @"TTVideoTrafficTipSettingKey";

#pragma mark - SettingView

@interface SettingView ()
<
UITableViewDelegate,
UITableViewDataSource,
UIActionSheetDelegate,
TTEditUserProfileViewControllerDelegate
> {
    CGFloat     _fileSize;
    ArticleSettingViewCacheStatus   _cacheStatus;
    BOOL                            _isEmptyingTrash;
    BOOL                            _isOpenSettingApp;
    BOOL                            _shouldShowBtn4RefreshSetting;
    BOOL                            _shouldShowADRegisterEntrance;
}

@property (nonatomic, strong) SSNavigationBar * navigationBar;
@property (nonatomic, strong) SSThemedTableView * tableView;
@property (nonatomic, strong) SSThemedLabel * aboutLabel;

@property (nonatomic, strong) SettingSwitch * resourceModeSwitch;
@property (nonatomic, strong) SettingSwitch * readModeSwitch;
@property (nonatomic, strong) SettingSwitch * pushNotificatoinSwitch;
//@property (nonatomic, strong) SettingSwitch * shareWhenFavoriteSwitch;
//@property (nonatomic, strong) SettingSwitch * umengDebugSwitch;
@property (nonatomic, strong) SettingSwitch * showBtn4RefreshSwitch;
@property (nonatomic, strong) SettingSwitch * showAwardCoinTipSwitch;

@property (nonatomic, strong) TTIndicatorView * indicatorView;

@property (nonatomic, strong) UIView *footerContainerView;
@property (nonatomic, strong) SSThemedButton *userProtocolButton;
@property (nonatomic, strong) SettingPushCell *pushCell;

@property (nonatomic, assign) NSUInteger tapCount;
@property (nonatomic, assign) BOOL cacheJustCleaned;
@property (nonatomic, strong) UITapGestureRecognizer *flexTapGesture;

/**
 * 退出登录时，是否显示过重置密码
 */
@property (nonatomic, assign) BOOL resetPasswordAlertShowed; // default is NO
@property (nonatomic, assign) BOOL airDownloading;

@end

@implementation SettingView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self unregisterNotifications];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[SSTrashManager sharedManager] cancel];
        _cacheStatus = ArticleSettingViewCacheStatusNormal;
        
        _shouldShowBtn4RefreshSetting = [SSCommonLogic refreshButtonSettingEnabled];
        
        // 广告合作入口
        // _shouldShowADRegisterEntrance = ![TTSettingMineTabManager sharedInstance_tt].hadDisplayedADRegisterEntrance;
        // 产品要求暂时去除该入口
        _shouldShowADRegisterEntrance = NO;

        
        // table view
        self.tableView = [[SSThemedTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundView = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.enableTTStyledSeparator = YES;
        _tableView.separatorInsetLeft = [TTDeviceUIUtils tt_padding:15.f];
        _tableView.separatorColorThemeKey = kColorLine1;
        _tableView.separatorSecondColorThemeKey = kColorLine1;
        
        [self addSubview:_tableView];
        
        [self initializeTableFooterView];
        
        self.resourceModeSwitch = [[SettingSwitch alloc] initWithFrame:CGRectZero];
        [_resourceModeSwitch addTarget:self action:@selector(resourceModeChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.readModeSwitch = [[SettingSwitch alloc] initWithFrame:CGRectZero];
        [_readModeSwitch addTarget:self action:@selector(readModeChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.pushNotificatoinSwitch = [[SettingSwitch alloc] initWithFrame:CGRectZero];
        [_pushNotificatoinSwitch addTarget:self action:@selector(pushNotificationChanged:) forControlEvents:UIControlEventValueChanged];
        self.showAwardCoinTipSwitch = [[SettingSwitch alloc] initWithFrame:CGRectZero];
        [_showAwardCoinTipSwitch addTarget:self action:@selector(showAwardCoinTipSwitchAction:) forControlEvents:UIControlEventValueChanged];
        //        self.shareWhenFavoriteSwitch = [[SettingSwitch alloc] initWithFrame:CGRectZero];
        //        [_shareWhenFavoriteSwitch addTarget:self action:@selector(shareWhenFavoriteChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.showBtn4RefreshSwitch = [[SettingSwitch alloc] initWithFrame:CGRectZero];
        [self.showBtn4RefreshSwitch addTarget:self action:@selector(showBtn4RefreshSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self bringSubviewToFront:self.navigationBar];
        
        [self registerNotifications];
        
        //
        [self reloadThemeUI];
    }
    
    return  self;
}

- (void)initializeTableFooterView
{
    self.footerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, 0)];
    
    self.userProtocolButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [_userProtocolButton setTitle:NSLocalizedString(@"爱看用户协议", @"") forState:UIControlStateNormal];
    _userProtocolButton.titleColorThemeKey = kColorText6;
    _userProtocolButton.highlightedTitleColorThemeKey = kColorText6Highlighted;
    _userProtocolButton.titleLabel.font = [UIFont systemFontOfSize:[SettingView fontSizeOfUserProtocolButton]];
    [_userProtocolButton addTarget:self action:@selector(userProtocolButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_userProtocolButton sizeToFit];
    _userProtocolButton.centerX = _tableView.width / 2;
    _userProtocolButton.top = 15.f + 5.f;
    [_footerContainerView addSubview:_userProtocolButton];
    
    
    self.aboutLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, _footerContainerView.width, 0)];
    _aboutLabel.numberOfLines = 0;
    _aboutLabel.textColorThemeKey = kColorText3;
    _aboutLabel.backgroundColor = [UIColor clearColor];
    _aboutLabel.textAlignment = NSTextAlignmentCenter;
    _aboutLabel.font = [UIFont boldSystemFontOfSize:[SettingView fontSizeOfAboutLabel]];
    
    NSString * channel = nil;
    if ([[TTSandBoxHelper getCurrentChannel] isEqualToString:@"App Store"]) {
        channel = @"";
    }
    else {
        channel = [NSString stringWithFormat:@"  %@",[TTSandBoxHelper getCurrentChannel]];
    }
    _aboutLabel.text = [NSString stringWithFormat:NSLocalizedString(@"All Rights Reserved By Toutiao.com%@", nil), channel];
    
#ifdef DEBUG
    
    NSMutableString *string = [NSMutableString stringWithFormat:NSLocalizedString(@"All Rights Reserved By Toutiao.com %s %s %@ %s\n", nil), __DATE__ ,__TIME__, [TTSandBoxHelper getCurrentChannel], BuildRev];
    [string appendFormat:@"deviceID:%@, userID:%@", [[TTInstallIDManager sharedInstance] deviceID], [TTAccountManager userID]];
    
    _aboutLabel.text = string;
#endif
    if ([TTSandBoxHelper isInHouseApp]) {
        NSMutableString *string = [NSMutableString stringWithFormat:NSLocalizedString(@"All Rights Reserved By Toutiao.com inHouse %s %s %@ %s\n", nil), __DATE__ ,__TIME__, [TTSandBoxHelper getCurrentChannel], BuildRev];
        [string appendFormat:@"deviceID:%@, userID:%@", [[TTInstallIDManager sharedInstance] deviceID], [TTAccountManager userID]];
        _aboutLabel.text = string;
    }
    
    CGFloat aboutHeight = [TTLabelTextHelper heightOfText:_aboutLabel.text fontSize:[SettingView fontSizeOfAboutLabel] forWidth:_aboutLabel.width];
    CGSize aboutSize = CGSizeMake(_aboutLabel.width, aboutHeight);
    _aboutLabel.height = ceilf(aboutSize.height) + 10;
    _aboutLabel.top = _userProtocolButton.bottom;
    [_footerContainerView addSubview:_aboutLabel];
    
    _footerContainerView.height = _aboutLabel.bottom + 10;
    
    _tableView.tableFooterView = _footerContainerView;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(footerTapped)];
    [_footerContainerView addGestureRecognizer:tap];
}

- (void)registerNotifications {
    // add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView) name:kSSFeedbackManagerFetchedDataNotification object:nil];
    if ([TTDeviceHelper isPadDevice]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportSettingFontSizeChangedNotification:) name:kSettingFontSizeChangedNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registPushNotification:) name:kSettingViewRegistPushNotification object:nil];
    
    [TTAccount addMulticastDelegate:self];
}

- (void)unregisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountLogout
{
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"退出成功", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(goBack:) object:nil];
    [self performSelector:@selector(goBack:) withObject:nil afterDelay:0.25];
}

#pragma mark - notification events

- (void)reportSettingFontSizeChangedNotification:(NSNotification *)notification
{
    [_tableView reloadData];
}

#pragma mark - event of tap footer view

- (void)footerTapped {
    self.tapCount++;

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"did: %@\nuid: %@", [[TTInstallIDManager sharedInstance] deviceID], [TTAccountManager userID]];
    if ([TTSandBoxHelper isInHouseApp]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拷贝成功" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
    
    if (self.tapCount > 5) {
        
        NSMutableString *string = [NSMutableString stringWithFormat:NSLocalizedString(@"All Rights Reserved By Toutiao.com %s %s %@ %s\n", nil), __DATE__ ,__TIME__, [TTSandBoxHelper getCurrentChannel], BuildRev];
        [string appendFormat:@"deviceID:%@, userID:%@", [[TTInstallIDManager sharedInstance] deviceID], [TTAccountManager userID]];
        
        _aboutLabel.text = string;
        
        CGFloat aboutHeight = [TTLabelTextHelper heightOfText:_aboutLabel.text fontSize:[SettingView fontSizeOfAboutLabel] forWidth:_aboutLabel.width];
        CGSize aboutSize = CGSizeMake(_aboutLabel.width, aboutHeight);
        _aboutLabel.height = ceilf(aboutSize.height) + 10;
        _aboutLabel.top = _userProtocolButton.bottom;

        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"拷贝成功" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
}

- (void)flexDebugTapped
{
    if (self.tapCount > 5) {
        //[[FLEXManager sharedManager] showExplorer];
    }
}

- (void)userProtocolButtonClicked:(id)sender
{
    SSWebViewController * webViewController = [[SSWebViewController alloc] initWithSupportIPhoneRotate:NO];
    [webViewController setTitleText:NSLocalizedString(@"爱看用户协议", nil)];
    [webViewController requestWithURLString:[ArticleURLSetting userProtocolURLString]];
    
    
    UINavigationController *topVC = [TTUIResponderHelper topNavigationControllerFor: self];
    topVC.navigationBarHidden = NO;
    [topVC pushViewController:webViewController animated:YES];
}

- (void)goBack:(id)sender
{
    if (![TTAccountManager isLogin] && [TTTabBarProvider isMineTabOnTabBar]) {
        UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor:self];
        [navController popToRootViewControllerAnimated:YES];
    } else{
        UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor:self];
        [navController popViewControllerAnimated:YES];
    }
}

- (void)refreshTableView
{
    [_tableView reloadData];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView reloadData];
}

- (void)willAppear
{
    [super willAppear];
    
    wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"enter");
    
    [_tableView reloadData];
    
    [SettingView setSettingViewAppeared];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingViewWillAppearNotification object:nil];
    
    if (_shouldShowADRegisterEntrance) {
        wrapperTrackEvent(@"ad_register", @"setting_ad_register_show");
    }
}

- (void)willDisappear
{
    [super willDisappear];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingViewWillDisappearNotification object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _footerContainerView.width = _tableView.width;
    _userProtocolButton.centerX = _tableView.width / 2;
    _userProtocolButton.top = 15.f + 5.f;
    
    CGFloat aboutHeight = [TTLabelTextHelper heightOfText:_aboutLabel.text fontSize:[SettingView fontSizeOfAboutLabel] forWidth:_aboutLabel.width];
    CGSize aboutSize = CGSizeMake(_aboutLabel.width, aboutHeight);
    _aboutLabel.width = _tableView.width;
    _aboutLabel.height = ceilf(aboutSize.height) + 10;
    _aboutLabel.top = _userProtocolButton.bottom + 40;
    _footerContainerView.height = _aboutLabel.bottom + 10;
    
    _tableView.tableFooterView = _footerContainerView;
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self supportSettingSectionTypeArray].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TTSettingSectionType sectionType = [self sectionTypeAtSection:section];
    NSArray *cellTypeList = [self supportSettingCellTypeArrayWithSectionType:sectionType];
    return cellTypeList.count;
}

- (void)refreshContent
{
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCellType cellType = [self cellTypeAtIndexPath:indexPath];
//    if (cellType == SettingCellTypePushNotification
//        && ((![self isAPNSEnabled] || [TTUserSettingsManager apnsNewAlertClosed]))
//        ) {
//        if ([TTDeviceHelper isPadDevice]) {
//            return 90.0f;
//        }
//        return [TTDeviceUIUtils tt_padding:kTTSettingNotificationCellHeight];
//    }
    
    if (cellType == SettingCellTypeLogout) {
        return [TTEditUserLogoutCell cellHeight];
    }
    
    return [SettingView heightOfCell];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = [TTDeviceUIUtils tt_padding:kTTSettingSpacingOfSection];
    
    if ([self isTableViewSectionOfLogoutModule] &&
        [self sectionTypeAtSection:section] == kTTSettingSectionTypeLogout) {
        height = [TTDeviceUIUtils tt_padding:kTTSettingLogoutSectionHeaderHeight];
    }
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, height)];
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = [TTDeviceUIUtils tt_padding:kTTSettingSpacingOfSection];
    if ([self sectionTypeAtSection:section] == kTTSettingSectionTypeLogout &&
        [self isTableViewSectionOfLogoutModule]) {
        height = [TTDeviceUIUtils tt_padding:kTTSettingLogoutSectionHeaderHeight];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCellType cellType = [self cellTypeAtIndexPath:indexPath];
    
    NSString *cellIndenitfier = @"";
    UITableViewCell *cell;
    if (cellType == SettingCellTypePushNotification) {
        cell = [[SettingPushCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndenitfier];
        self.pushCell = (SettingPushCell *)cell;
        self.pushCell.pushTitleLabel.font = [UIFont systemFontOfSize:[SettingView fontSizeOfCellLeftLabel]];
    } else if (cellType == SettingCellTypeLogout) {
        if ([self isTableViewSectionOfLogoutModule]) {
            cell = [[TTEditUserLogoutCell alloc] initWithReuseIdentifier:cellIndenitfier];
        }
    } else if (cellType == SettingCellTypeAccountManagement) {
        cell = [[TTEditUserProfileItemCell alloc] initWithReuseIdentifier:cellIndenitfier];
    } else {
        cell = [[SettingNormalCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndenitfier];
    }
    cell.backgroundColor = nil;
    SSThemedView * bgView = [[SSThemedView alloc] init];
    bgView.backgroundColorThemeKey = kColorBackground4;
    cell.backgroundView = bgView;
    
    cell.textLabel.font = [UIFont systemFontOfSize:[SettingView fontSizeOfCellLeftLabel]];
    cell.textLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:[SettingView fontSizeOfCellRightLabel]];
    
    
    if (cellType == SettingCellTypeFeedback) {
        cell.textLabel.text = NSLocalizedString(@"意见反馈", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        UIImageView * accessoryImageView =
        [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"arrow_drawer.png"]
                          highlightedImage:[UIImage themedImageNamed:@"arrow_drawer_press.png"]];
        cell.accessoryView = accessoryImageView;
        
        UIView * redpointView = [cell.contentView viewWithTag:kFeedbackRedpointTag];
        if([SSFeedbackManager hasNewFeedback]) {
            if(!redpointView) {
                redpointView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"redpoint.png"]];
                redpointView.center = CGPointMake(cell.contentView.frame.size.width - 50, cell.contentView.frame.size.height/2);
                CGRect redRect = redpointView.frame;
                redRect.origin.x = 84;
                redpointView.frame = redRect;
                redpointView.tag = kFeedbackRedpointTag;
                [cell.contentView addSubview:redpointView];
            }
        }
        else {
            [redpointView removeFromSuperview];
        }
    }
    else if (cellType == SettingCellTypeResourceMode) {
        cell.textLabel.text = NSLocalizedString(@"夜间模式", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self refreshswitch:_resourceModeSwitch];
        _resourceModeSwitch.frame = CGRectMake(0, 0, 100, 40);
        cell.accessoryView = _resourceModeSwitch;
        [_resourceModeSwitch setOn:([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight)];
    }
    else if (cellType == SettingCellTypeReadMode) {
        cell.textLabel.text = NSLocalizedString(@"列表显示摘要", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self refreshswitch:_readModeSwitch];
        _readModeSwitch.frame = CGRectMake(0, 0, 100, 40);
        cell.accessoryView = _readModeSwitch;
        [_readModeSwitch setOn:[NewsLogicSetting userSetReadMode] == ReadModeAbstract];
    }
    else if (cellType == SettingCellTypeFontMode) {
        cell.textLabel.text = NSLocalizedString(@"字体大小", nil);
        TTUserSettingsFontSize fontIndex = [TTUserSettingsManager settingFontSize];
        cell.detailTextLabel.text = [[NewsUserSettingManager fontSettings] objectAtIndex:(NSUInteger)fontIndex];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (cellType == SettingCellTypeLoadImageMode) {
        cell.textLabel.text = [self settingCellLoadImageString];
        cell.detailTextLabel.text = [self networkTrafficSettingText];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (cellType == SettingCellTypeCoinTaskSetting) {
        cell.textLabel.text = NSLocalizedString(@"金币任务提醒", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self refreshswitch:_showAwardCoinTipSwitch];
        _showAwardCoinTipSwitch.frame = CGRectMake(0, 0, 100, 40);
        cell.accessoryView = _showAwardCoinTipSwitch;
//        cell.detailTextLabel.text =
        [_showAwardCoinTipSwitch setOn:[AKTaskSettingHelper shareInstance].isEnableShowCoinTip];
    }
    else if (cellType == SettingCellTypeVideoTrafficTip) {
        cell.textLabel.text = [self settingCellVideoTrafficTip];
        cell.detailTextLabel.text = [self videoTrafficTipText];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (cellType == SettingCellTypeClearCache) {
        
        //此处进行ABManager 的测试实验
        
        TTClearCacheLiteraryType type = [TTABHelper clearCacheLiteraryType];
        if (type == TTClearCacheLiteraryTypeClear) {
            cell.textLabel.text = NSLocalizedString(@"清除缓存", nil);
        }
        else {
            cell.textLabel.text = NSLocalizedString(@"清理缓存", nil);
        }
        
        //如果刚刚清理过 就直接显示0.0M 不要计算了-- nick 4.9.x
        if (self.cacheJustCleaned) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB", 0.001f];
            
        }
        else {
            if (_cacheStatus == ArticleSettingViewCacheStatusNormal) {
                _cacheStatus = ArticleSettingViewCacheStatusCalculating;
                cell.detailTextLabel.text = NSLocalizedString(@"正在计算...", nil);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    _fileSize = [ExploreLogicSetting cacheSizeWithTempVideoAudioFile];
                    [ExploreLogicSetting addUpCacheSizeWithImage:YES http:YES coreData:NO wendaDraft:YES shortVideo:YES completion:^(NSInteger totalSize) {
                        _fileSize += totalSize;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (_fileSize < 0.1f) _fileSize = 0.001f;
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB", _fileSize];
                            _cacheStatus = ArticleSettingViewCacheStatusCalcCompleted;
                        });
                    }];
                });
            } else if (_cacheStatus == ArticleSettingViewCacheStatusCalcCompleted){
                if (_fileSize < 0.1f) {
                    _fileSize = 0.001f;
                }
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB", _fileSize];
            } else if (_cacheStatus == ArticleSettingViewCacheStatusTrashing) {
                cell.detailTextLabel.text = NSLocalizedString(@"正在清理...", nil);;
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (cellType == SettingCellTypePushNotification) {
        cell.textLabel.text = nil;//NSLocalizedString(@"推送通知", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self refreshswitch:_pushNotificatoinSwitch];
        _pushNotificatoinSwitch.frame = CGRectMake(0, 0, 100, 40);
        cell.accessoryView = _pushNotificatoinSwitch;
        
        NSString *detailText;
        // 系统推送设置
        BOOL apnsClosed = ![self isAPNSEnabled];
        if (apnsClosed) {
            if (&UIApplicationOpenSettingsURLString != NULL) {
                detailText = NSLocalizedString(@"你可能错过重要资讯通知，点击去设置允许通知", nil);
            } else {
                detailText = NSLocalizedString(@"你可能错过重要资讯通知，请在“设置” - “通知” - “爱看”内允许通知", nil);
            }
            [_pushNotificatoinSwitch setOn:NO];
        } else {
            BOOL isOn = ![TTUserSettingsManager apnsNewAlertClosed];
            [_pushNotificatoinSwitch setOn:isOn];
            if (!isOn) {
                detailText = NSLocalizedString(@"你可能错过重要资讯通知，点击开启", nil);
            } else {
                detailText = nil;
            }
        }
        
        self.pushCell.pushTitleLabel.text = NSLocalizedString(@"推送通知", nil);
//        self.pushCell.pushDetailLabel.text = detailText;
    }
    else if (cellType == SettingCellTypeShowBtn4Refresh) {
        cell.textLabel.text = NSLocalizedString(@"列表页显示刷新按钮", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self refreshswitch:_showBtn4RefreshSwitch];
        _showBtn4RefreshSwitch.frame = CGRectMake(0, 0, 100, 40);
        cell.accessoryView = _showBtn4RefreshSwitch;
        [_showBtn4RefreshSwitch setOn:[SSCommonLogic showRefreshButton]];
    }
    else if (cellType == SettingCellTypeCheckNewVersion) {
        cell.textLabel.text = NSLocalizedString(@"当前版本", nil);
        NSString *curVersion = [TTSandBoxHelper versionName];
        cell.detailTextLabel.text = curVersion;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        tap.numberOfTapsRequired = 7;
        [tap addTarget:self action:@selector(flexDebugTapped)];
        [cell addGestureRecognizer:tap];
        self.flexTapGesture = tap;
    }
    else if (cellType == SettingCellTypeShowADSplash) {
        cell.textLabel.text = NSLocalizedString(@"爱看封面", nil);
        UIImageView *accessoryImage = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"setting_rightarrow"]];
        cell.accessoryView = accessoryImage;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (cellType == SettingCellTypeAccountManagement) {
        TTUserProfileItem *item = [TTUserProfileItem new];
        item.title = NSLocalizedString(@"编辑资料", nil);
        item.titleThemeKey = kColorText1;
        
        item.isAuditing = [[TTAccountManager currentUser].auditInfoSet isAuditing];
        
        TTEditUserProfileItemCell *itemCell = (TTEditUserProfileItemCell *)cell;
        itemCell.selectionStyle = UITableViewCellSelectionStyleNone;
        itemCell.cellSpearatorStyle = kTTCellSeparatorStyleTopPart;
        
        [itemCell reloadWithProfileItem:item];
    }
    else if (cellType == SettingCellTypeAccountBindingSetting) {
        cell.textLabel.text = NSLocalizedString(@"账号和隐私设置", nil);
        UIImageView *accessoryImage = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"setting_rightarrow"]];
        cell.accessoryView = accessoryImage;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (cellType == SettingCellTypeBlockUsersList) {
        cell.textLabel.text = NSLocalizedString(@"黑名单", nil);
        UIImageView *accessoryImage = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"setting_rightarrow"]];
        cell.accessoryView = accessoryImage;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if (cellType == SettingCellTypeLogout) {
        [((TTEditUserLogoutCell *)cell) reloadWithTitle:@"退出登录" themeKey:kColorText4];
    } else if (cellType == SettingCellTypeADRegisterEntrance) {
        cell.textLabel.text = NSLocalizedString(@"广告合作", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"3步注册开户", nil);
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"setting_rightarrow"]];;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // luohuaqing: bug fix. 在IOS8上，textLabel和detailTextLabel的默认font size会随系统设置的改变而改变
    if ([TTDeviceHelper OSVersionNumber] >= 8)
    {
        cell.textLabel.font = [UIFont systemFontOfSize:[SettingView fontSizeOfCellLeftLabel]];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:[SettingView fontSizeOfCellRightLabel]];
    }
    
    ((SSThemedTableViewCell *)cell).tableView = self.tableView;
    ((SSThemedTableViewCell *)cell).cellIndex = indexPath;
    
    return cell;
}


#pragma mark - TableView helper

- (BOOL)isTableViewSectionOfLogoutModule {
    return YES;
}


- (NSArray *)supportSettingSectionTypeArray
{
    if ([TTAccountManager isLogin]) {
        return @[@(kTTSettingSectionTypeAccount),
                 @(kTTSettingSectionTypeAbstractFont),
                 @(kTTSettingSectionTypeTTCover),
                 @(kTTSettingSectionTypeLogout),];
    } else {
        return @[@(kTTSettingSectionTypeAbstractFont),@(kTTSettingSectionTypeTTCover)];
    }
}

- (NSArray *)supportSettingCellTypeArrayWithSectionType:(TTSettingSectionType)type
{
    switch (type) {
        case kTTSettingSectionTypeAccount:
            return @[@(SettingCellTypeAccountManagement)];
            break;
        case kTTSettingSectionTypeAbstractFont:
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:@[
                                                                     @(SettingCellTypeClearCache),
                                                                     @(SettingCellTypeFontMode),
                                                                     @(SettingCellTypeLoadImageMode),
                                                                     @(SettingCellTypeVideoTrafficTip),
                                                                     @(SettingCellTypePushNotification),]];
            if ([AKTaskSettingHelper shareInstance].akBenefitEnable) {
                [array addObject:@(SettingCellTypeCoinTaskSetting)];
            }
            if (_shouldShowBtn4RefreshSetting) {
                [array insertObject:@(SettingCellTypeShowBtn4Refresh) atIndex:3];
            }
            return array;
        }
        case kTTSettingSectionTypeTTCover:
            return @[@(SettingCellTypeCheckNewVersion)];
        case kTTSettingSectionTypeLogout:
            return @[@(SettingCellTypeLogout)];
        default:
            return @[];
    }
}

- (TTSettingSectionType)sectionTypeAtSection:(NSInteger)section
{
    NSArray *sectionTypeList = [self supportSettingSectionTypeArray];
    if (section > sectionTypeList.count) {
        return kTTSettingSectionTypeNone;
    }
    NSNumber *sectionTypeObject = sectionTypeList[section];
    return sectionTypeObject.integerValue;
}

- (TTSettingCellType)cellTypeAtIndexPath:(NSIndexPath *)indexpath
{
    TTSettingSectionType sectionType = [self sectionTypeAtSection:indexpath.section];
    NSArray *cellTypeList = [self supportSettingCellTypeArrayWithSectionType:sectionType];
    if (cellTypeList.count < indexpath.row) {
        return SettingCellTypeNone;
    }
    NSNumber *cellType = cellTypeList[indexpath.row];
    return cellType.integerValue;
}

//- (TTSettingSectionType)settingSectionTypeOfIndex:(NSUInteger)index {
//    TTSettingSectionType sectionType = kTTSettingSectionTypeNone;
//    NSUInteger section = index + ([TTAccountManager isLogin] ? 0 : 1);
//    if (section == 0) {
//        sectionType = kTTSettingSectionTypeAccount;
//    } else if (section == 1) {
//        sectionType = kTTSettingSectionTypeAbstractFont;
//        //    } else if (section == 2) {
//        //        sectionType = kTTSettingSectionTypeFlowCache;
//        //    } else if (section == 3) {
//        //        sectionType = kTTSettingSectionTypeNotification;
//    }
//    else if (section == 2) {
//        sectionType = kTTSettingSectionTypeTTCover;
//    } else if (section == 3) {
//        if ([self isTableViewSectionOfLogoutModule] && [TTAccountManager isLogin]) {
//            sectionType = kTTSettingSectionTypeLogout;
//        }
//    }
//    //    else if (section == 6) {
//    //        if ([self isTableViewSectionOfLogoutModule] && [TTAccountManager isLogin])
//    //            sectionType = kTTSettingSectionTypeLogout;
//    //    }
//    return sectionType;
//}

//- (TTSettingCellType)settingCellTypeOfIndexPath:(NSIndexPath *)indexPath {
//    NSInteger row = indexPath.row;
//    SettingCellType result = SettingCellTypeNone;
//
//    switch ([self settingSectionTypeOfIndex:indexPath.section]) {
//        case kTTSettingSectionTypeAccount: {
//            if (0 == row) result = SettingCellTypeAccountManagement;
//            else if (1 == row) result = SettingCellTypeAccountBindingSetting;
//            else if (2 == row) result = SettingCellTypeBlockUsersList;
//        }
//            break;
//
//        case kTTSettingSectionTypeAbstractFont: {
//
//            if (row >= 1){
//                row = row + (_shouldShowNightShiftSetting ? 0 : 1);
//            }
//
//            if (row >= 3) {
//                row = row + (_shouldShowBtn4RefreshSetting ? 0 : 1);
//            }
//            if (0 == row) result = SettingCellTypeClearCache;
//            else if (1 == row) result = SettingCellTypeNightShiftMode;
//            else if (2 == row) result = SettingCellTypeFontMode;
//            else if (3 == row) result = SettingCellTypeShowBtn4Refresh;
//            else if (4 == row) result = SettingCellTypeReadMode;
//            else if (5 == row) result = SettingCellTypeLoadImageMode;
//            else if (6 == row) result = SettingCellTypeVideoTrafficTip;
//            else if (7 == row) result = SettingCellTypePushNotification;
//        }
//            break;
//        case kTTSettingSectionTypeTTCover: {
//
//            row = row + (_shouldShowADRegisterEntrance ? 0 : 1);
//            if (0 == row) {
//                result = SettingCellTypeADRegisterEntrance;
//            } else if (1 == row) {
//                result = SettingCellTypeShowADSplash;
//            } else if (2 == row) {
//                result = SettingCellTypeCheckNewVersion;
//            }
//        }
//            break;
//
//        case kTTSettingSectionTypeLogout: {
//            result = SettingCellTypeLogout;
//        }
//            break;
//
//        default:
//            break;
//    }
//    return result;
//}

- (NSIndexPath *)settingCellIndexPathForType:(SettingCellType)type {
    __block NSInteger row = 0;
    __block NSInteger section = 0;
    __block BOOL finded = NO;
    NSArray<NSNumber *> *sectionList = [self supportSettingSectionTypeArray];
    [sectionList enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger sectionIdx, BOOL * _Nonnull stop) {
        NSArray<NSNumber *> *cellList = [self supportSettingCellTypeArrayWithSectionType:obj.integerValue];
        [cellList enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger rowIdx, BOOL * _Nonnull stop) {
            if (obj.integerValue == type) {
                section = sectionIdx;
                row = rowIdx;
                finded = YES;
                *stop = YES;
            }
        }];
        if (finded) {
            *stop = YES;
        }
    }];
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}


- (void)refreshswitch:(UISwitch*)switchControl
{
    if([switchControl respondsToSelector:@selector(setOnImage:)])
    {
        [switchControl setOnImage:[UIImage themedImageNamed:@"onbtn_setup.png"]];
        [switchControl setOffImage:[UIImage themedImageNamed:@"offbtn_setup.png"]];
    }
    else if([switchControl respondsToSelector:@selector(setOnTintColor:)])
    {
        [switchControl setOnTintColor:[UIColor colorWithHexString:@"60bbf4"]];
    }
}

- (NSString *)networkTrafficSettingText
{
    NSString *text = [[NewsUserSettingManager networkTrafficSettings] objectAtIndex:[TTUserSettingsManager networkTrafficSetting]];
    return text;
}

- (NSString *)videoTrafficTipText {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:TTVideoTrafficTipSettingKey]) { //默认显示提醒一次
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:TTVideoTrafficTipSettingKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSInteger idx = [[NSUserDefaults standardUserDefaults] integerForKey:TTVideoTrafficTipSettingKey];
    if (idx == 0) {
        return @"每次提醒";
    } else {
        return @"提醒一次";
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCellType type = [self cellTypeAtIndexPath:indexPath];
    switch (type) {
        case SettingCellTypeReadMode:
        case SettingCellTypePushNotification:
        case SettingCellTypeNatantSwitch:
        case SettingCellTypeClientEscapeSwitch:
        case SettingCellTypeCheckNewVersion:
            return NO;
            
        default:
            return YES;
    }
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateTableView:tableView atIndexPath:indexPath isHighlight:YES];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UITableViewCell *tCell in [tableView visibleCells]) {
        [self updateTableView:tableView atIndexPath:[tableView indexPathForCell:tCell] isHighlight:NO];
    }
}

- (void)updateTableView:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath isHighlight:(BOOL)highlight
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SSThemedView * bgView = (SSThemedView *)cell.backgroundView;
    if (bgView) {
        bgView.backgroundColorThemeKey = highlight ? kColorBackground4Highlighted : kColorBackground4;
    }
}

- (void)needReload:(NSNotification *)notification
{
    [_tableView reloadData];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [_tableView reloadData];
    
    if (_isOpenSettingApp) {
        [[APNsManager sharedManager] sendAppNoticeStatus];
        if ([self isAPNSEnabled]) {
            wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"notice_set_open");
            
            [self.pushNotificatoinSwitch setOn:YES];
            [TTUserSettingsManager closeAPNsNewAlert:NO];
            [[APNsManager sharedManager] sendAppNoticeStatus];
        }
        
        _isOpenSettingApp = NO;
    }
}
#pragma mark Select


- (void)_settingSourceViewOfController:(UIViewController *)controller tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if ([controller respondsToSelector:@selector(popoverPresentationController)]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        controller.popoverPresentationController.sourceView = cell.contentView;
        controller.popoverPresentationController.sourceRect = cell.contentView.bounds;
    }
}

- (void)_showIPhoneActionSheetForTextSetting
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"设置字体大小", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"小", nil), NSLocalizedString(@"中", nil), NSLocalizedString(@"大", nil), NSLocalizedString(@"特大", nil), nil];
    sheet.tag = kActionSheetForFontSetting;
    [sheet showInView:self];
}

- (void)_showIPadAlertForTextSetting:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"设置字体大小", @"")
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self];
    
    WeakSelf;
    UIAlertAction *smallAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"小", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            StrongSelf;
                                                            [self setFontWithIndex:0];
                                                            [topVC dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    
    [controller addAction:smallAction];
    
    UIAlertAction *middleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"中", @"")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             StrongSelf;
                                                             [self setFontWithIndex:1];
                                                             [topVC dismissViewControllerAnimated:YES completion:nil];
                                                         }];
    
    [controller addAction:middleAction];
    
    UIAlertAction *largeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"大", @"")
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            StrongSelf;
                                                            [self setFontWithIndex:2];
                                                            [topVC dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    
    [controller addAction:largeAction];
    
    UIAlertAction *hugeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"特大", @"")
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           StrongSelf;
                                                           [self setFontWithIndex:3];
                                                           [topVC dismissViewControllerAnimated:YES completion:nil];
                                                       }];
    
    [controller addAction:hugeAction];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [topVC dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:cancelAction];
    
    [self _settingSourceViewOfController:controller tableView:tableView indexPath:indexPath];
    [topVC.navigationController presentViewController:controller animated:YES completion:nil];
}

- (void)_showIPadAlertForLoadImage:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath

{
    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[self settingCellLoadImageString]
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    WeakSelf;
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"最佳效果（下载大图）", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                StrongSelf;
                                                [self changeImageDIsplaySettingWithIndex:0];
                                                [topVC dismissViewControllerAnimated:YES completion:nil];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"较省流量（智能下图）", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                StrongSelf;
                                                [self changeImageDIsplaySettingWithIndex:1];
                                                [topVC dismissViewControllerAnimated:YES completion:nil];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"极省流量（不下载图）", @"")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *action) {
                                                StrongSelf;
                                                [self changeImageDIsplaySettingWithIndex:2];
                                                [topVC dismissViewControllerAnimated:YES completion:nil];
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", @"")
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action) {
                                                [topVC dismissViewControllerAnimated:YES completion:nil];
                                            }]];
    
    [self _settingSourceViewOfController:alert tableView:tableView indexPath:indexPath];
    
    [topVC.navigationController presentViewController:alert animated:YES completion:nil];
    
}

- (void)_showIPhoneActionSheetForLoadImage
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:[self settingCellLoadImageString]
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"取消", @"")
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"最佳效果（下载大图）", @""), NSLocalizedString(@"较省流量（智能下图）", @""), NSLocalizedString(@"极省流量（不下载图）", @""), nil];
    sheet.tag = kActionSheetForImageSetting;
    [sheet showInView:self];
}

- (void)_showIPadAlertForVideoTrafficTip:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[self settingCellVideoTrafficTip]
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    WeakSelf;
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"每次提醒", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        StrongSelf;
        [self setVideoTrafficTipWithIndex:0];
        [topVC dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"提醒一次", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        StrongSelf;
        [self setVideoTrafficTipWithIndex:1];
        [topVC dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        wrapperTrackEvent(@"net_alert_setting", @"cancel");
        [topVC dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self _settingSourceViewOfController:alert tableView:tableView indexPath:indexPath];
    [topVC.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)_showIPhoneActionSheetForVideoTrafficTip
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[self settingCellVideoTrafficTip] delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"每次提醒", nil), NSLocalizedString(@"提醒一次", nil), nil];
    sheet.tag = kActionSheetForVideoTrafficTip;
    [sheet showInView:self];
}

- (BOOL)_shouldShowIPadAlert
{
    return [TTDeviceHelper OSVersionNumber] >= 8.0 && [TTDeviceHelper isPadDevice];
}

- (void)_showIPadAlertForClearCache:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UIViewController *topVC = [TTUIResponderHelper topViewControllerFor: self];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定删除所有缓存？问答草稿、离线内容及图片均会被清除"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    WeakSelf;
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        StrongSelf;
        [self clearCache];
        // [topVC dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self _settingSourceViewOfController:alert tableView:tableView indexPath:indexPath];
    [topVC.navigationController presentViewController:alert animated:YES completion:nil];
}

- (void)_showIPhoneActionSheetForClearCache
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"确定删除所有缓存？离线内容及图片均会被清除", nil)
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    sheet.tag = kActionSheetForClearCacheTag;
    [sheet showInView:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingCellType cellType = [self cellTypeAtIndexPath:indexPath];
    if (cellType == SettingCellTypeFeedback) {
        [self feedbackButtonClicked:nil];
    } else if (cellType == SettingCellTypeResourceMode) {
        
    } else if (cellType == SettingCellTypeReadMode) {
        
    } else if (cellType == SettingCellTypeFontMode) {
        if([self _shouldShowIPadAlert]) {
            [self _showIPadAlertForTextSetting:tableView indexPath:indexPath];
        } else {
            [self _showIPhoneActionSheetForTextSetting];
        }
    } else if (cellType == SettingCellTypeLoadImageMode) {
        if([self _shouldShowIPadAlert]) {
            [self _showIPadAlertForLoadImage:tableView indexPath:indexPath];
        } else {
            [self _showIPhoneActionSheetForLoadImage];
        }
    } else if (cellType == SettingCellTypeVideoTrafficTip) {
        wrapperTrackEvent(@"net_alert_setting", @"click");
        if ([self _shouldShowIPadAlert]) {
            [self _showIPadAlertForVideoTrafficTip:tableView indexPath:indexPath];
        } else {
            [self _showIPhoneActionSheetForVideoTrafficTip];
        }
    } else if (cellType == SettingCellTypeClearCache) {
        wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"clear_cache");
        if (_cacheStatus != ArticleSettingViewCacheStatusCalcCompleted) {
            return;
        }
        
        if([TTDeviceHelper OSVersionNumber] >= 8.0 && [TTDeviceHelper isPadDevice]) {
            [self _showIPadAlertForClearCache:tableView indexPath:indexPath];
        } else {
            [self _showIPhoneActionSheetForClearCache];
        }
    } else if (cellType == SettingCellTypePushNotification) {
        
    } else if (cellType == SettingCellTypeClientEscapeSwitch) {
        
    } else if (cellType == SettingCellTypeNatantSwitch) {
        
    }else if (cellType == SettingCellTypeCheckNewVersion) {
        wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"check_version");
        // 苹果审核拒绝app自己检测版本更新
        //[[NewVersionAlertManager alertManager] startAlertAutoCheck:NO];
    }
    else if (cellType == SettingCellTypeShowADSplash) {
        if ([TTAdSplashMediator useSplashSDK]) {
            TTAdSplashSettingVC *vc = [[TTAdSplashSettingVC alloc] init];
            UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
            [topController.navigationController pushViewController:vc animated:YES];
        }
        else{
            TTSettingADSplashVC *vc = [[TTSettingADSplashVC alloc] init];
            UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
            [topController.navigationController pushViewController:vc animated:YES];
        }
    } else if (cellType == SettingCellTypeAccountManagement) {
        [self showEditUserView:nil]; //编辑资料
    } else if (cellType == SettingCellTypeAccountBindingSetting) {
        [self openAccountBindingSettingDidSelectCell:nil];
    } else if (cellType == SettingCellTypeBlockUsersList) {
        [ self openUserBlacklistsDidSelectCell:nil];
    } else if (cellType == SettingCellTypeLogout) {
        [self triggerLogoutDidSelectCell];
    } else if (cellType == SettingCellTypeADRegisterEntrance) { // 广告合作
        if ([TTAccountManager isLogin]) {
            NSURL *url = [TTStringHelper URLWithURLString:@"https://ad.toutiao.com/m/self_service/?source2=ttappsetting"];
            UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:nil];
            ssOpenWebView(url, @"广告合作", topController, NO, nil);
        } else {
            [TTAccountManager presentQuickLoginFromVC:self.viewController type:TTAccountLoginDialogTitleTypeDefault source:@"" isPasswordStyle:YES completion:nil];
        }
        wrapperTrackEvent(@"ad_register", @"setting_ad_register_clk");
    }
    
    if(_delegate) {
        [_delegate padSettingViewDidSelectedCell:self];
    }
}

#pragma mark - event of logout

- (void)triggerLogoutDidSelectCell
{
    if ([SSCommonLogic ttAlertControllerEnabled]) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"退出确认", nil) message:NSLocalizedString(@"退出当前账号，将不能继续赚钱，不能同步收藏等", nil) preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        WeakSelf;
        [alert addActionWithTitle:NSLocalizedString(@"确认退出", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            StrongSelf;
            [self logout];
        }];
        [alert showFrom:self.viewController animated:YES];
    } else {
        // luohuaqing: Workaround (dispatch_async) for (maybe) some iOS bug
        // See details here: http://stackoverflow.com/questions/30606512/uialertview-delay-or-not-showing & http://openradar.appspot.com/19285091
        // Note that UIAlertView is already deprecated and it should not be used anymore.
        dispatch_async(dispatch_get_main_queue(), ^{
            TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"退出确认", nil) message:NSLocalizedString(@"退出当前账号，将不能继续赚钱，不能同步收藏等", nil) preferredType:TTThemedAlertControllerTypeAlert];
            WeakSelf;
            [alertVC addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            }];
            [alertVC addActionWithTitle:NSLocalizedString(@"确认退出", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                StrongSelf;
                [self logout];
            }];
            [alertVC showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
        });
    }
}

- (void)logout {
    NSString *userID = [TTAccountManager userID];
    
    WeakSelf;
    [TTAccountManager startLogoutUserWithCompletion:^(BOOL success, NSError *error) {
        StrongSelf;
        
        BOOL shouldIgnoreError = NO;
        //未设置密码也可以退出登录
        if (error.code == 1037) {
            shouldIgnoreError = YES;
        }
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:error.description forKey:@"error_description"];
        [extra setValue:@(error.code) forKey:@"error_code"];
        [extra setValue:userID forKey:@"user_id"];
        
        if (error && !shouldIgnoreError) {
            [[TTMonitor shareManager] trackService:@"account_logout" status:2 extra:extra];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"退出登录失败，请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        } else {
            [[TTMonitor shareManager] trackService:@"account_logout" status:1 extra:extra];
            
            // LogV1
            if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
                wrapperTrackerEvent([TTSandBoxHelper appName], @"xiangping", @"account_setting_signout");
            }
            // LogV3
            [TTTrackerWrapper eventV3:@"login_account_exit" params:nil isDoubleSending:YES];
            
            if (self.resetPasswordAlertShowed) {
                wrapperTrackEvent(@"login", @"exit_password_setting_success");
            }
            self.resetPasswordAlertShowed = NO;
        }
    }];
}

- (void)feedbackButtonClicked:(id)sender
{
    wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"feedback");
    SSFeedbackViewController * feedbackViewController = [[SSFeedbackViewController alloc] init];
    UIViewController *topController = [TTUIResponderHelper topViewControllerFor: self];
    [topController.navigationController pushViewController:feedbackViewController animated:YES];
}

- (void)pushNotificationChanged:(id)sender
{
    // 系统推送设置
    BOOL apnsClosed = ![self isAPNSEnabled];
    if (apnsClosed) {
        if (&UIApplicationOpenSettingsURLString != NULL) {
            wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"notice_set");
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([TTDeviceHelper OSVersionNumber] >= 10.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
#pragma clang diagnostic pop
            }
            else {
                [[UIApplication sharedApplication] openURL:url];
            }
            _isOpenSettingApp = YES;
        } else {
            wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"notice_alert");
            TTAuthorizeHintView *hintview = [[TTAuthorizeHintView alloc]initAuthorizeHintWithImageName:@"img_popup_notice" title:NSLocalizedString(@"推送设置", nil) message:NSLocalizedString(@"请在系统“设置” - “通知”内，允许“爱看”通知", nil)  confirmBtnTitle:@"我知道了" animated:YES completed:nil];
            [hintview show];
        }
        [_pushNotificatoinSwitch setOn:NO];
        return;
    }
    
    [TTUserSettingsManager closeAPNsNewAlert:![TTUserSettingsManager apnsNewAlertClosed]];
    [[APNsManager sharedManager] sendAppNoticeStatus];
    wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, ![TTUserSettingsManager apnsNewAlertClosed] ? @"apn_notice_on" : @"apn_notice_off");
    [self.tableView reloadData];
}

- (void)showAwardCoinTipSwitchAction:(SettingSwitch *)sw
{
    [[AKTaskSettingHelper shareInstance] setShowCoinTip:sw.isOn];
}

//针对的是用户自自有弹窗拒绝后，在设置页面去打开通知，手动调用完注册推送权限后发出的通知
- (void)registPushNotification:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)readModeChanged:(id)sender
{
    ReadMode oldMode = [NewsLogicSetting userSetReadMode];
    ReadMode mode = _readModeSwitch.isOn ? ReadModeAbstract : ReadModeTitle;
    [NewsLogicSetting setReadMode:mode];
    if(oldMode != mode)
    {
        //
        NSString *eventName = (mode == ReadModeTitle) ? @"title_mode" : @"digest_mode";
        wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR,eventName);
    }
}

- (void)resourceModeChanged:(id)sender
{
    TTThemeMode newMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? TTThemeModeNight : TTThemeModeDay;
    [[TTThemeManager sharedInstance_tt] switchThemeModeto:newMode];
    [NewsUserSettingManager setHasShownNightMode:YES];
    
    switch (newMode) {
        case TTThemeModeDay:
        {
            wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"click_to_day");
        }
            break;
        case TTThemeModeNight:
        {
            wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, @"click_to_night");
        }
            break;
        default:
            break;
    }
}

- (void)showBtn4RefreshSwitchChanged:(UISwitch *)settingSwitch
{
    [SSCommonLogic setShowRefreshButton:settingSwitch.isOn];
}

/**
 * 账号管理/编辑资料
 */
- (void)showEditUserView:(id)sender {
    wrapperTrackEvent(@"setting", @"enter_edit_profile");
    
    if([TTAccountManager isLogin]) {
        TTEditUserProfileViewController *profileVC = [TTEditUserProfileViewController new];
        profileVC.userType = [TTAccountManager accountUserType];
        profileVC.delegate = self;
        
        UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor:self];
        [navController pushViewController:profileVC animated:YES];
    }
}

- (void)openAccountBindingSettingDidSelectCell:(UITableViewCell *)cell {
    wrapperTrackEvent(@"setting", @"enter_edit_account");
    
    TTAccountBindingViewController *vc = [[TTAccountBindingViewController alloc] init];
    UINavigationController *topNav = [TTUIResponderHelper topNavigationControllerFor:self];
    [topNav pushViewController:vc animated:YES];
}

- (void)openUserBlacklistsDidSelectCell:(UITableViewCell *)cell {
    wrapperTrackEvent(@"setting", @"enter_blacklist");
    
    BlockUsersListViewController *vc = [[BlockUsersListViewController alloc] init];
    UINavigationController *topNav = [TTUIResponderHelper topNavigationControllerFor:self];
    [topNav pushViewController:vc animated:YES];
}

#pragma mark - TTEditUserProfileViewControllerDelegate

- (BOOL)hideDescriptionCellInEditUserProfileController:(TTEditUserProfileViewController *)aController {
    return NO;
}

- (void)editUserProfileController:(TTEditUserProfileViewController *)aController goBack:(id)sender {
    if (![TTAccountManager isLogin]) {
        UINavigationController *nav = nil;
        UIViewController *topController = [TTUIResponderHelper topNavigationControllerFor:self];
        if ([topController isKindOfClass:[UINavigationController class]]) {
            nav = (UINavigationController *)topController;
        } else {
            nav = topController.navigationController;
        }
        [nav popToRootViewControllerAnimated:YES];
    } else {
        UINavigationController *nav = [TTUIResponderHelper topViewControllerFor: aController].navigationController;
        [nav popViewControllerAnimated:YES];
    }
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex && actionSheet.tag == kActionSheetForVideoTrafficTip) {
        wrapperTrackEvent(@"net_alert_setting", @"cancel");
    }
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if(actionSheet.tag == kActionSheetForClearCacheTag)
        {
            [self clearCache];
        }
        else if(actionSheet.tag == kActionSheetForImageSetting)
        {
            
            TTNetworkTrafficSetting settingType = buttonIndex == 0 ? TTNetworkTrafficOptimum : (buttonIndex == 1 ? TTNetworkTrafficMedium : TTNetworkTrafficSave);
            
            
            [TTUserSettingsManager setNetworkTrafficSetting:settingType];
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[self settingCellIndexPathForType:SettingCellTypeLoadImageMode]];
            cell.detailTextLabel.text = [self networkTrafficSettingText];
            [[NSNotificationCenter defaultCenter] postNotificationName:kImageDisplayModeChangedNotification
                                                                object:self
                                                              userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:settingType] forKey:@"mode"]];
            
            
            NSString *eventName = settingType == TTNetworkTrafficOptimum ? @"bandwidth_big" : (settingType == TTNetworkTrafficMedium ? @"bandwidth_normal" : @"bandwidth_small");
            wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, eventName);
        } else if (actionSheet.tag == kActionSheetForVideoTrafficTip) {
            [self setVideoTrafficTipWithIndex:buttonIndex];
        }
        else if(actionSheet.tag == kActionSheetForFontSetting)
        {
            [TTUserSettingsManager setSettingFontSize:(int)buttonIndex];
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[self settingCellIndexPathForType:SettingCellTypeFontMode]];
            cell.detailTextLabel.text = [[NewsUserSettingManager fontSettings] objectAtIndex:buttonIndex];
            NSString *eventLabel = @"";
            switch (buttonIndex) {
                case 0: eventLabel = @"font_small";
                    break;
                case 1: eventLabel = @"font_middle";
                    break;
                case 2: eventLabel = @"font_big";
                    break;
                case 3: eventLabel = @"font_ultra_big";
                    break;
                default:
                    break;
            }
            
            wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, eventLabel);
            
        }
    }
}


- (void)changeImageDIsplaySettingWithIndex:(int)index
{
    TTNetworkTrafficSetting settingType = index == 0 ? TTNetworkTrafficOptimum : (index == 1 ? TTNetworkTrafficMedium : TTNetworkTrafficSave);
    
    
    [TTUserSettingsManager setNetworkTrafficSetting:settingType];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[self settingCellIndexPathForType:SettingCellTypeLoadImageMode]];
    cell.detailTextLabel.text = [self networkTrafficSettingText];
    [[NSNotificationCenter defaultCenter] postNotificationName:kImageDisplayModeChangedNotification
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:settingType] forKey:@"mode"]];
    
    
    NSString *eventName = settingType == TTNetworkTrafficOptimum ? @"bandwidth_big" : (settingType == TTNetworkTrafficMedium ? @"bandwidth_normal" : @"bandwidth_small");
    wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, eventName);
}

- (void)setVideoTrafficTipWithIndex:(NSInteger)index
{
    NSInteger curIndex = [[NSUserDefaults standardUserDefaults] integerForKey:TTVideoTrafficTipSettingKey];
    if (curIndex == index) {
        return;
    }
    wrapperTrackEvent(@"net_alert_setting", index?@"once":@"every");
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[self settingCellIndexPathForType:SettingCellTypeVideoTrafficTip]];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:TTVideoTrafficTipSettingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    cell.detailTextLabel.text = [self videoTrafficTipText];
    [ExploreMovieView changeAlwaysCloseAlert];
//    [TTLivePlayerTrafficViewController changeFrequencyOfTrafficViewDisplayed];
}

- (void)setFontWithIndex:(int)index
{
    [TTUserSettingsManager setSettingFontSize:index];
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[self settingCellIndexPathForType:SettingCellTypeFontMode]];
    cell.detailTextLabel.text = [[NewsUserSettingManager fontSettings] objectAtIndex:index];
    NSString *eventLabel = @"";
    switch (index) {
        case 0: eventLabel = @"font_small";
            break;
        case 1: eventLabel = @"font_middle";
            break;
        case 2: eventLabel = @"font_big";
            break;
        case 3: eventLabel = @"font_ultra_big";
            break;
        default:
            break;
    }
    
    wrapperTrackEvent(UMENG_SETTINGVIEW_EVENT_ID_STR, eventLabel);
}

- (void)clearCache {
    
    [TTDebugRealMonitorManager cacheDevLogWithEventName:@"UserClearCache" params:nil];
    
    //当设置里面清楚缓存的时候发个通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingViewClearCachdNotification" object:nil];
    
    //删除临时视频和音频文件
    [ExploreLogicSetting clearTempVideoAudioFileCache];
    
    //清理webview离线包
    [[TTRPackageManager sharedManager] clearAllPackages];
    
    //清除加入缓存大小统计的存储
    _cacheStatus = ArticleSettingViewCacheStatusTrashing;
    [self.tableView reloadData];
    // 标记需要删除CoreData数据，下次启动就会删除.
    [SSCommonLogic setNeedCleanCoreData:YES];
    // 将URLCache删除
    NSString *bundleID = [TTSandBoxHelper bundleIdentifier];
    NSString *webCache = [bundleID stringCachePath];
    NSString *cachePath = [webCache stringByAppendingPathComponent:@"TTURLCache"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        NSString *resultPath = nil;
        [[SSTrashManager sharedManager] trashItemAtPath:webCache resultingItemPath:&resultPath error:nil];
    }
    
    //火山短视频缓存
    id<IESVideoCacheProtocol> shortVideoSysPlayerCache = [IESVideoCache cacheWithType:IESVideoPlayerTypeSystem];
    [shortVideoSysPlayerCache clearAllCache];//系统播放器
    
    id<IESVideoCacheProtocol> shortVideoOwnPlayerCache = [IESVideoCache cacheWithType:IESVideoPlayerTypeTTOwn];
    [shortVideoOwnPlayerCache clearAllCache];//自研播放器
    
    [[TTVOwnPlayerCacheWrapper sharedCache] clearAllCache];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [[SSSimpleCache sharedCache] clearCache];
    [TTWebImageManager clearDisk];
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [[adManagerInstance class] clearAllCache];
    
    [TTEntityBase vacuumAllDBs];
    
    WeakSelf;
    TTIndicatorView *indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:NSLocalizedString(@"正在清空", nil) indicatorImage:nil dismissHandler:^(BOOL isUserDismiss) {
        StrongSelf;
        if (isUserDismiss) {
            SSLog(@"用户取消清除");
            [[SSTrashManager sharedManager] cancel];
            _cacheStatus = ArticleSettingViewCacheStatusNormal;
            [self.tableView reloadData];
        }
    }];
    indicatorView.showDismissButton = YES;
    indicatorView.autoDismiss = NO;
    [indicatorView showFromParentView:self];
    [[SSTrashManager sharedManager] emptyTrashWithCompletionHandler:^(BOOL finished) {
        SSLog(@"清空完成");
        StrongSelf;
        self->_cacheStatus = ArticleSettingViewCacheStatusNormal;
        
        if (finished) {
            [indicatorView updateIndicatorWithText:NSLocalizedString(@"清除成功", nil) shouldRemoveWaitingView:YES];
            [indicatorView updateIndicatorWithImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"]];
            indicatorView.showDismissButton = NO;
            [indicatorView dismissFromParentView];
            self.cacheJustCleaned = YES;
        }
        [self.tableView reloadData];
    }];
//    [FRLogicManager cleanCache];
}

- (void)displayMessage:(NSString*)msg withImage:(UIImage*)image duration:(float)duration
{
    _indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:msg indicatorImage:image dismissHandler:nil];
    _indicatorView.autoDismiss = NO;
    [_indicatorView showFromParentView:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_indicatorView dismissFromParentView];
    });
}

+ (CGFloat)heightOfCell
{
    return [TTDeviceUIUtils tt_padding:kTTSettingCellHeight];
}

+ (CGFloat)fontSizeOfCellLeftLabel
{
    return [TTDeviceUIUtils tt_fontSize:kTTSettingTitleFontSize];
}

+ (CGFloat)fontSizeOfCellRightLabel
{
    return [TTDeviceUIUtils tt_fontSize:kTTSettingContentFontSize];
}

+ (CGFloat)fontSizeOfUserProtocolButton
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 14.f;
    } else {
        return 12.f;
    }
}

+ (CGFloat)fontSizeOfAboutLabel
{
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        return 16.f;
    } else {
        return 12.f;
    }
}

#pragma mark - Badge

+ (NSString *)settingViewAppearedUserDefaultKey
{
    return [NSString stringWithFormat:@"setSettingViewAppeared%@", [TTSandBoxHelper versionName]];
}

+ (BOOL)isSettingViewAppeared
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:[self settingViewAppearedUserDefaultKey]] boolValue];
}

+ (void)setSettingViewAppeared
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[self settingViewAppearedUserDefaultKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSUInteger)settingNewPointBadgeNumber
{
    int defaultPointNumber = 0;
    int total = 0;
    
    if (![self isSettingViewAppeared]) {
        total += defaultPointNumber;
    }
    
    return total;
}


- (BOOL)isAPNSEnabled {
    BOOL bEnabled = NO;
    
    if([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        bEnabled = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    else {
        bEnabled = ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone);
    }
    return bEnabled;
}

- (NSString *)settingCellLoadImageString
{
    return NSLocalizedString(@"非WiFi网络流量", nil);
}

- (NSString *)settingCellVideoTrafficTip
{
    return NSLocalizedString(@"非WiFi网络播放提醒", nil);
}

@end
