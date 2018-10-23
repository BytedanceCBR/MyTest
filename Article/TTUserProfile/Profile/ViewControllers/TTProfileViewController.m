//
//  TTProfileViewController.m
//  Article
//
//  Created by yuxin on 7/17/15.
//
//

#import "TTProfileViewController.h"
#import "TTProfileViewController+Notification.h"
#import "UIColor+TTThemeExtension.h"

#import "AKProfileHeaderView.h"
#import "AKTaskSettingHelper.h"
#import "AKProfileBenefitManager.h"
#import "AKMinePhotoCarouselEntry.h"
#import "AKWebContainerViewController.h"
#import "AKLoginTrafficViewController.h"
#import "AKProfilePhotoCarouselViewCell.h"
#import "TTProfileFunctionCell.h"
#import "TTProfileTopFunctionCell.h"
#import "TTProfileMessageFunctionCell.h"
#import <TTAccountBusiness.h>
#import "ArticleBadgeManager.h"
#import "TTSettingMineTabGroup.h"
#import "TTSettingMineTabManager.h"
#import "TTSettingMineTabEntry.h"
#import "ArticleFetchSettingsManager.h"
#import "SSWebViewController.h"

//push to next VC
#import "TTFavoriteViewController.h"
#import "SSFeedbackViewController.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "TTProjectLogicManager.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIViewController+Track.h"

#import "TTProfileThemeConstants.h"
#import "TTNetworkManager.h"
#import "ArticleURLSetting.h"

#import "TTInterestViewController.h"
#import "TTFavoriteViewController.h"
#import "TTFavoriteHistoryViewController.h"
#import "TTFollowingViewController.h"
#import "TTFollowedViewController.h"
#import "TTVisitorViewController.h"
#import "TTRelationshipViewController.h"
#import "TTEditUserProfileViewController.h"
#import "TTCountInfoResponseModel.h"
#import "TTProfileNameContainerView.h"
#import "NSObject+FBKVOController.h"
#import "TTBadgeTrackerHelper.h"
#import "TTRoute.h"
#import "TTMessageNotificationTipsManager.h"
#import "TTMessageNotificationMacro.h"
//#import "TTPLManager.h"
#import <TTTracker.h>
//#import "TTCommonwealManager.h"
#import "BDTAccountClientManager.h"
#import "TTAccountBindingMobileViewController.h"
#import "TTTabBarProvider.h"
#import "AKLoginTrafficViewController.h"
#define PaddingTopBackButton 6
#define kTTProfileTopCellHeight    (142.f/2)

static NSString *const kTopFunctionKey = @"iPhone_top_function";
static NSString *const kPadNightModeKey = @"iPad_night_mode";
static NSString *const kMessageNotificationFuctionKey = @"mine_notification";
static NSString *const kPrivateLetterFunctionKey = @"private_letter";

static NSString *const kTTProfileMessageFunctionCellIdentifier = @"kTTProfileMessageFunctionCellIdentifier";

@interface TTProfileViewController ()<UIScrollViewDelegate,AKPhotoCarouselViewDelegate,TTEditUserProfileViewControllerDelegate>

@property (nonatomic, weak) IBOutlet AKProfileHeaderView *tableHeaderView;
@property (nonatomic, strong) TTAlphaThemedButton *backButton;
@property (nonatomic) BOOL backButtonClicked;
@property (nonatomic, assign)BOOL resurfaceIconAnimated;
@property (nonatomic, strong)NSNumber * originTaskEntryDisplay;
@property (nonatomic, strong)UIView *statusBarBackView;
@end

@implementation TTProfileViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self registerNotifications];
        self.ttTrackStayEnable = YES;
        if (![TTTabBarProvider isMineTabOnTabBar]){
            self.hidesBottomBarWhenPushed = YES;
        }
        else{
            self.hidesBottomBarWhenPushed = NO;
        }
    }
    return self;
}

- (instancetype)init
{
    if ([SSCommonLogic shouldUseOptimisedLaunch]) {
        self = [self initWithNibName:nil bundle:nil];
        self.ttHideNavigationBar = YES;
        self.ttStatusBarStyle = UIStatusBarStyleDefault;
        self.ttTrackStayEnable = YES;
    } else {
        self = [super init];
    }
    
    [self registerNotifications];
    self.ttTrackStayEnable = YES;
    if (![TTTabBarProvider isMineTabOnTabBar]){
        self.hidesBottomBarWhenPushed = YES;
    }
    else{
        self.hidesBottomBarWhenPushed = NO;
    }
    
    return self;
}

- (void)dealloc
{
    if (!_backButtonClicked) {
        [TTTrackerWrapper eventV3:@"tab_back" params:@{@"back_type":@"gesture",@"tab_name":@"mine"}];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[TTThemeManager sharedInstance_tt] removeObserver:self forKeyPath:@"currentMode"];
    [TTAccount removeMulticastDelegate:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![TTTabBarProvider isMineTabOnTabBar]) {
        _backButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(8, 20 + PaddingTopBackButton, 32, 32)];
        _backButton.imageName = @"white_lefterbackicon_titlebar";
        _backButton.layer.cornerRadius = 16;
        _backButton.clipsToBounds = YES;
        [_backButton addTarget:self action:@selector(iPhoneBackButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
    }
    
    // load and update views
    self.tableView.sectionHeaderHeight = 0.f;
    self.tableView.sectionFooterHeight = 0.f;
    self.tableView.tableFooterView = [SSThemedView new];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, [TTDeviceUIUtils tt_padding:30.f/2], 0, 0);
    self.tableView.separatorColor = [UIColor tt_themedColorForKey:kColorLine1];
    self.tableView.disableTTStyledSeparatorEdge = YES;
    [self.tableView registerClass:[AKProfilePhotoCarouselViewCell class] forCellReuseIdentifier:kAKIdenfitierPhotoCarouselKey];
    [self updateHeaderControls];
    [[TTSettingMineTabManager sharedInstance_tt] reloadSectionsIfNeeded];
    [self reloadTableView];
    
    if([TTDeviceHelper isPadDevice]) {
        self.padBackButton.hidden = NO;
    } else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44 + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom, 0);
    }
    
    self.tableView.backgroundColorThemeKey = kColorBackground3;
    [self.tableView registerClass:[TTProfileBaseFunctionCell class] forCellReuseIdentifier:@"BaseFunctionCell"];
    [self.tableView registerClass:[TTProfileMessageFunctionCell class] forCellReuseIdentifier:kTTProfileMessageFunctionCellIdentifier];
    [self.view insertSubview:self.statusBarBackView aboveSubview:self.tableView];
    //reset 收藏列表底tip的显示
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHasBottomTipFavlistClosedUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTaskEntryDisplayIfNeed) name:kAKBenefitSettingValueUpdateNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshCommonwealView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //tricky code：修复夜间模式下iPad iOS7/8系统上日夜间模式切换cell露出白块的问题
    if ([TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 9.f) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUserInfoView];
        });
    } else {
        [self refreshUserInfoView];
    }
    
    TTMessageNotificationTipsManager *manager = [TTMessageNotificationTipsManager sharedManager];
    [manager saveLastImportantMessageID];
    //切换到我的tab时
    if([[TTSettingMineTabManager sharedInstance_tt] getEntryForType:TTSettingMineTabEntyTypeMessage]){
        if(manager.isImportantMessage){
            wrapperTrackEventWithCustomKeys(@"message_list", @"vip_show", manager.msgID, nil, kTTMessageNotificationTrackExtra(manager.actionType));
        }
        else if(manager.unreadNumber > 0){
            wrapperTrackEventWithCustomKeys(@"message_list", @"show", nil, nil, kTTMessageNotificationTrackExtra(manager.actionType));
        }
    }
    
    [self updateTaskEntryDisplayIfNeed];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [BDTAccountClientManager presentBindingMobileVCFrom:BDTABindingMobileFromMine bindingCompletion:nil];
    
//    if (![TTAccountManager isLogin]) {
//        // 我的TAB 平台登录显示 埋点
//        if ([TTAccountAuthHuoShan isAppAvailable] && [TTProfileHeaderView isConfSupportedOfPlatform:PLATFORM_HUOSHAN]) {
//            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
//            [extraDict setValue:@"mine_tab" forKey:@"source"];
//            [extraDict setValue:@"1" forKey:@"hotsoon_login_show"];
//            [TTTrackerWrapper eventV3:@"login_mine_tab_show" params:extraDict];
//        }
//        if ([TTAccountAuthDouYin isAppAvailable] && [TTProfileHeaderView isConfSupportedOfPlatform:PLATFORM_DOUYIN]) {
//            NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
//            [extraDict setValue:@"mine_tab" forKey:@"source"];
//            [extraDict setValue:@"1" forKey:@"douyin_login_show"];
//            [TTTrackerWrapper eventV3:@"login_mine_tab_show" params:extraDict];
//        }
//    }
    
    if ([TTSettingMineTabManager sharedInstance_tt].hadDisplayedADRegisterEntrance) {
        wrapperTrackEvent(@"ad_register", @"mine_ad_register_show");
    }
}

- (void)requestUserAuditInfo
{
    [TTAccount getUserAuditInfoIgnoreDispatchWithCompletion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
        
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self trySendCurrentPageStayTime];
}

#pragma mark - theme

- (void)themeChanged:(NSNotification *)notification
{
    self.tableView.separatorColor = [UIColor tt_themedColorForKey:kColorLine1];
}

#pragma mark - update header controls

- (void)updateHeaderBenefitInfo
{
    [[AKProfileBenefitManager shareInstance] requestBenefitInfoWithCompletion:^(NSArray<AKProfileBenefitModel *> * models) {
        [self.tableHeaderView refreshBenefitInfoWithModels:models];
    }];
}

- (void)updateHeaderControls
{
    [self.tableHeaderView refreshLoginViewAndUnLoginViewStatus];
}

- (void)refreshUserInfoView
{
    [self.tableHeaderView refreshUserinfo];
    [self updateHeaderBenefitInfo];
}

- (void)refreshCommonwealView
{
    if(![SSCommonLogic commonwealEntranceEnable]) return;
//    [[TTCommonwealManager sharedInstance] uploadTodayUsingTimeWithCompletion:^(BOOL canGetMoney, double money, NSTimeInterval todayUsingTime) {
//        
//        if([TTAccountManager isLogin]) {
//            NSString *title = nil;
//            NSString *subTitle = nil;
//            if(canGetMoney) {
//                title = [NSString stringWithFormat:@"%.0lf公益金",money];
//                subTitle = @"待领取";
//            } else {
//                title = @"今日阅读";
//                double time = todayUsingTime / 60 < 1 ? 1 : todayUsingTime / 60;
//                subTitle = [NSString stringWithFormat:@"%.0lf分钟",time];
//            }
//            [self.tableHeaderView refreshCommonwealInfoWithTitle:title subTitle:subTitle isEnableGetMoney:canGetMoney];
//        } else {
//            NSString *title = nil;
//            if(canGetMoney) {
//                title = [NSString stringWithFormat:@"%.0lf公益金待领取",money];
//            } else {
//                double time = todayUsingTime / 60 < 1 ? 1 : todayUsingTime / 60;
//                title = [NSString stringWithFormat:@"今日阅读%.0lf分钟",time];
//            }
//            [self.tableHeaderView refreshCommonwealInfoWithTitle:title subTitle:nil isEnableGetMoney:canGetMoney];
//        }
//    }];
}

- (void)refreshUserHistoryInfo
{
//    if ([TTAccountManager isLogin]) {
//        //        [[ArticleBadgeManager shareManger] fetchUpdateCount];
//
//        [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting contInfoV2URLString] params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
//
//            TTCountInfoResponseModel *responseModel = nil;
//            NSError *parseError = nil;
//
//            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
//                responseModel = [[TTCountInfoResponseModel alloc] initWithDictionary:jsonObj error:&parseError];
//            }
//
//            // 当有数据时才刷新，否则显示老的数据
//            if (responseModel && [responseModel.message isEqualToString:@"success"]) {
//
//                [TTAccountManager setShowInfo:responseModel.data.showInfo];
//
//                [TTAccountManager setFollowingString:responseModel.data.followingsItem.name];
//                //[TTAccountManager setFollowerString:responseModel.data.followerItem.name];
//                [TTAccountManager setVisitorString:responseModel.data.visitorItem.name];
//                [TTAccountManager setMomentString:responseModel.data.momentItem.name];
//
//                [TTAccountManager currentUser].followingsCount = [responseModel.data.followingsItem.value longLongValue];
//                //[TTAccountManager currentUser].followersCount = [responseModel.data.followerItem.value longLongValue];
//                [TTAccountManager currentUser].visitCountRecent = [responseModel.data.visitorItem.value longLongValue];
//
//                long dongtaiCount = [responseModel.data.momentItem.value longLongValue];
//                if (dongtaiCount == 0) {
//                    dongtaiCount = [TTAccountManager currentUser].momentsCount;
//                }
//                [TTAccountManager currentUser].momentsCount = dongtaiCount;
//
//                if ([responseModel.data.multiplatformFollowerItem.value longLongValue] > 0) {
//                    [TTAccountManager setFollowerString:responseModel.data.multiplatformFollowerItem.name];
//                    [TTAccountManager currentUser].followersCount = [responseModel.data.multiplatformFollowerItem.value longLongValue];
//                } else {
//                    [TTAccountManager setFollowerString:responseModel.data.followerItem.name];
//                    [TTAccountManager currentUser].followersCount = [responseModel.data.followerItem.value longLongValue];
//                }
//
//                self.tableHeaderView.fansInfoArray = responseModel.data.followerDetail;
//                self.tableHeaderView.appFansView.appInfos = responseModel.data.followerDetail;
//
//                [self.tableHeaderView refreshUserHistoryInfo];
//            }
//
//            [self.tableHeaderView.nameContainerView refreshContainerView];
//
//            [self.tableHeaderView layoutIfNeeded];
//            [self.tableHeaderView setNeedsLayout];
//        }];
//        [self tt_performSelector:@selector(requestUserAuditInfo) onlyOnceInSelector:_cmd];
//    }
}

- (void)reloadTableViewLater
{
    //iOS8下 cancel后如何self已经 没有别人引用了 就会dealloc，导致后面调用self的时候crash
    __strong TTProfileViewController *strongSelf = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:strongSelf];
    
    [strongSelf performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.25];
}

- (void)reloadTableView
{
    // Fix，由于断网进入不会刷新上方视图，但仍未已登陆状态，需要UI状态同步
    [self.tableView reloadData];
}

#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= 20) {
        [UIView animateWithDuration:.15 animations:^{
            self.statusBarBackView.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:.15 animations:^{
            self.statusBarBackView.alpha = 0;
        }];
    }
    if (_backButton) {
        if (scrollView.contentOffset.y <= 0) {
            _backButton.backgroundColor = [UIColor clearColor];
        }
        else{
            _backButton.backgroundColor = [UIColor colorWithHexString:@"0000007f"];
        }
    }
}

#pragma mark tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [TTSettingMineTabManager sharedInstance_tt].visibleSections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTSettingMineTabEntry *entry = [[self class] entryForIndexPath:indexPath];
    
    if (!entry.shouldBeDisplayed) {
        return 0;
    }
    
    if ([entry.key isEqualToString:kTopFunctionKey]) {
        return [TTDeviceUIUtils tt_padding:kTTProfileTopCellHeight];
    }
    
    if ([entry.key isEqualToString:kAKIdenfitierPhotoCarouselKey]) {
        return self.view.width * 6 / 25.0;
    }
    
    return [TTDeviceUIUtils tt_padding:kTTProfileCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    TTSettingMineTabGroup *group = nil;
    if (section < [TTSettingMineTabManager sharedInstance_tt].visibleSections.count) {
        group = [[TTSettingMineTabManager sharedInstance_tt].visibleSections objectAtIndex:section];
    }
    return group.items.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTSettingMineTabEntry *entry = [[self class] entryForIndexPath:indexPath];
    
    NSString *identifier = @"FunctionCell";
    
    if([entry.key isEqualToString:kTopFunctionKey]) {
        identifier = @"TopFunctionCell";
    }
    if ([entry.key isEqualToString:kMessageNotificationFuctionKey] || [entry.key isEqualToString:kPrivateLetterFunctionKey]) {
        identifier = kTTProfileMessageFunctionCellIdentifier;
    }
    if ([entry.key isEqualToString:kAKIdenfitierPhotoCarouselKey]) {
        identifier = kAKIdenfitierPhotoCarouselKey;
    }
    
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if ([entry.key isEqualToString:kMessageNotificationFuctionKey] || [entry.key isEqualToString:kPrivateLetterFunctionKey]) {
        // 由于有图片和认证图标，使用代码重构的cell而不是stroyboard的
        TTProfileMessageFunctionCell *cell = (TTProfileMessageFunctionCell *)tableViewCell;
        cell.tableView = (SSThemedTableView*)tableView;
        cell.cellIndex = indexPath;
        [cell configWithEntry:entry];
    } else if ([entry.key isEqualToString:kAKIdenfitierPhotoCarouselKey]){
        AKProfilePhotoCarouselViewCell *cell = (AKProfilePhotoCarouselViewCell *)tableViewCell;
        AKMinePhotoCarouselEntry       *carouselEntry = (AKMinePhotoCarouselEntry *)entry;
        cell.carouselView.delegate = self;
        [cell refreshPhotoCarouselViewWithCellModels:carouselEntry.cellModels];
    } else {
        TTProfileFunctionCell *cell = (TTProfileFunctionCell *)tableViewCell;
        cell.tableView = (SSThemedTableView*)tableView;
        cell.cellIndex = indexPath;
        //去掉夜间switch
        cell.accessoryView = nil;
        if ([cell respondsToSelector:@selector(rightImageView)]) {
            cell.rightImageView.hidden = NO;
        }
        
        if ([entry.key isEqualToString:kTopFunctionKey]) {
            __weak typeof(self) wself = self;
            [(TTProfileTopFunctionCell*)cell setEnterTouchHandler:^{
                entry.switchChangedBlock(nil);
                [wself reloadTableViewLater];
            }];
        } else {
            //有此block表示右侧accessoryView是开关而不是箭头
            if (entry.switchChangedBlock) {
                cell.accessoryView = cell.rightSwitch;
                cell.rightImageView.hidden = YES;
                __weak typeof (cell) weakCell = cell;
                cell.switchChanged = ^(){
                    entry.switchChangedBlock(weakCell.rightSwitch);
                };
            }
            
            cell.titleLb.text = entry.text;
            if (!isEmptyString(entry.accessoryTextColor)) {
                cell.accessoryLb.textColor = [UIColor colorWithHexString:entry.accessoryTextColor];
            }
            cell.accessoryLb.text = entry.accessoryText;
            [cell refreshHintWithEntry:entry];
            
            if ([TTDeviceHelper isPadDevice]) {
                [cell setCellImageName:entry.iconName];
            }
        }
    }
    tableViewCell.hidden = !entry.shouldBeDisplayed;
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TTSettingMineTabEntry *entry = [[self class] entryForIndexPath:indexPath];
    if ([entry.key isEqualToString:@"mine_wallet"]) {
        [TTTracker eventV3:@"my_wallet_click" params:nil isDoubleSending:NO];
    }
    void(^operation)(void) = ^ {
        if (entry && entry.enter) {
            entry.enter();
            
            if ([entry.key isEqualToString:@"influence"]) {
                [TTTrackerWrapper eventV3:@"influence_click" params:@{@"position":@"mine"}];
            }
            if ([entry.key isEqualToString:@"mine_task"]) {
                [TTTracker eventV3:@"task_page_show" params:nil isDoubleSending:NO];
            }
        }
        
        if ([[TTSettingMineTabManager sharedInstance_tt] reloadSectionsIfNeeded]) {
            [self reloadTableView];
        }
    };
    if ([TTAccountManager isLogin]) {
        operation();
    } else {
        TTSettingMineTabEntry *entry = [[self class] entryForIndexPath:indexPath];
        if (entry.AKRequireLogin) {
            [AKLoginTrafficViewController presentLoginTrafficViewControllerWithCompleteBlock:^(BOOL result) {
                if (result) {
                    operation();
                }
            }];
        } else {
            operation();
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTSettingMineTabEntry *entry = [[self class] entryForIndexPath:indexPath];
    if (entry && entry.key) {
        // 实名认证 第一级入口展示
        if ([entry.key isEqualToString:@"shiming"]) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                wrapperTrackEvent(@"mine_tab", @"shiming_show");
            });
        }
        
        if ([entry.key isEqualToString:@"influence"]) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [TTTrackerWrapper eventV3:@"influence_show" params:@{@"position":@"mine"}];
            });
        }
    }
}

#pragma mark - set the section space (tricky)

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.f;
    }
    
    TTSettingMineTabGroup *group = [[TTSettingMineTabManager sharedInstance_tt].visibleSections objectAtIndex:section - 1];
    __block BOOL display = NO;
    [group.items enumerateObjectsUsingBlock:^(TTSettingGeneralEntry * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.shouldBeDisplayed) {
            display = YES;
            *stop = YES;
        }
    }];
    if (!display) {
        return 0;
    }
    
    return [TTDeviceUIUtils tt_padding:kTTProfileSpacingOfSection];
}


- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.f;
}

- (UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    SSThemedView *header = nil;
    
    if (section != 0) {
        header = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, SSWidth(tableView), 5.0)];
        header.backgroundColorThemeKey = kColorBackground3;
    }
    
    return header;
}

- (void)showViewController:(UIViewController*)controller
{
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark UI Actions
- (void)iPhoneBackButtonClick:(id)sender
{
    _backButtonClicked = YES;
    [TTTrackerWrapper eventV3:@"tab_back" params:@{@"back_type":@"back_button",@"tab_name":@"mine"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backBtnTouched
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)favBtnTouched:(id)sender
{
    wrapperTrackEvent(@"mine_tab", @"favorite");
    
    TTFavoriteHistoryViewController * controller = [[TTFavoriteHistoryViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(@{@"stay_id":@"favorite"})];
    [self showViewController:controller];
}

- (IBAction)historyBtnTouched:(id)sender
{
    wrapperTrackEvent(@"mine_tab", @"history");
    
    TTFavoriteHistoryViewController * controller = [[TTFavoriteHistoryViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(@{@"stay_id":@"read_history"})];
    [self showViewController:controller];
}

- (void)photoCarouselView:(AKPhotoCarouselView *)carouselView didSelectedAt:(NSInteger)index cellModel:(AKPhotoCarouselCellModel *)cellModel
{
    void (^operation)(void) = ^ {
        NSURL *url = [NSURL URLWithString:cellModel.openURL];
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
    };
    if ([TTAccount sharedAccount].isLogin) {
        operation();
    } else {
        [AKLoginTrafficViewController presentLoginTrafficViewControllerWithCompleteBlock:^(BOOL result) {
            if (result) {
                operation();
            }
        }];
    }
}

#pragma mark -- Helper

+ (TTSettingMineTabEntry *)entryForIndexPath:(NSIndexPath *)indexPath
{
    TTSettingMineTabGroup *group = nil;
    TTSettingMineTabEntry *entry = nil;
    
    if (indexPath.section < [TTSettingMineTabManager sharedInstance_tt].visibleSections.count) {
        group = [[TTSettingMineTabManager sharedInstance_tt].visibleSections objectAtIndex:indexPath.section];
    }
    
    if (indexPath.row < group.items.count) {
        entry = (TTSettingMineTabEntry *)[group.items objectAtIndex:indexPath.row];
    }
    
    return entry;
}

- (void)updateTaskEntryDisplayIfNeed
{
    BOOL display = [[AKTaskSettingHelper shareInstance] isEnableShowTaskEntrance];
    if ((!self.originTaskEntryDisplay && display == false) || (self.originTaskEntryDisplay && display != self.originTaskEntryDisplay.boolValue)) {
        self.originTaskEntryDisplay = @(display);
        [[TTSettingMineTabManager sharedInstance_tt] rebuildshVisibleSections];
        [self.tableView reloadData];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground
{
    [self trySendCurrentPageStayTime];
}

- (void)trackStartedByAppWillEnterForground
{
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)trySendCurrentPageStayTime
{
    if (self.ttTrackStartTime == 0) {//当前页面没有在展示过
        return;
    }
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    
    [self _sendCurrentPageStayTime:duration];
    
    self.ttTrackStartTime = 0;
    [self tt_resetStayTime];
}

- (void)_sendCurrentPageStayTime:(NSTimeInterval)duration
{
//    if (![TTTabBarProvider isMineTabOnTabBar]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@(((long long)(duration))) forKey:@"stay_time"];
        [params setValue:@"mine" forKey:@"tab_name"];
        if ([SSCommonLogic threeTopBarEnable]){
            [params setValue:_fromTab forKey:@"from_tab_name"];
        }
//        [TTTrackerWrapper eventV3:@"stay_tab" params:params];
//    }
}

#pragma Getter

- (UIView *)statusBarBackView
{
    if (_statusBarBackView == nil) {
        _statusBarBackView = [[UIView alloc] init];
        _statusBarBackView.backgroundColor = [UIColor whiteColor];
        _statusBarBackView.width = self.view.width;
        _statusBarBackView.height = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top;
        _statusBarBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _statusBarBackView.alpha = 0;
    }
    return _statusBarBackView;
}

#pragma safeInset

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    if (![TTTabBarProvider isMineTabOnTabBar]){
        _backButton.top = self.view.safeAreaInsets.top + PaddingTopBackButton;
    }
}

@end
