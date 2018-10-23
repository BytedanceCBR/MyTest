//
//  TTAccountBindingViewController.m
//  Article
//
//  Created by Zuopeng Liu on 7/21/16.
//
//

#import "TTAccountBindingViewController.h"
#import <objc/runtime.h>
#import <SSThemed.h>

#import <TTUIResponderHelper.h>
#import <TTNetworkManager.h>
#import <TTAccountBusiness.h>
#import "UIActionSheet+TTBlocks.h"

#import "TTEditUserProfileItemCell.h"
#import "TTUserBindAccountCell.h"
#import "TTUserPrivatePhoneCell.h"

#import "TTEditUserProfileSectionView.h"

#import "ArticleMobileNumberViewController.h"
#import "ArticleMobileChangeViewController.h"
#import "ArticleMobilePasswordViewController.h"
#import "ArticleAddressBridger.h"

#import "TTArticleCategoryManager.h"
#import <TTCategoryDefine.h>



typedef NS_ENUM(NSUInteger, TTSectionType) {
    kTTSectionTypeNone,
    kTTSectionTypeBindingInfo,   // 绑定修改（手机号、密码等）
    kTTSectionTypePrivate,       // 个人隐私
    kTTSectionTypeThirdAccounts  // 关联帐号
    
};

typedef NS_ENUM(NSUInteger, TTCellType) {
    kTTCellTypeNone,
    kTTCellTypeBindingPhone,
    kTTCellTypeEmail,
    kTTCellTypeModifyPassword,
    kTTCellTypeAccountRelatingItem,
    kTTCellTypePrivatePhone,
};

@interface TTAccountBindingViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
TTAccountMulticastProtocol
>
@property (nonatomic, strong) NSArray        *thirdAccounts;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, assign) BOOL can_be_found_by_phone;
@end


/**
 * Categories
 */
@interface TTAccountBindingViewController (TTThirdPartyAccounts)

// 点击触发第三方用户账号绑定事件
@property (nonatomic, copy) TTTriggerBindingUserAccountBlock bindingAccountCallback;

@end

@interface TTAccountBindingViewController (TTUserMobilePhone)
- (void)bindMobile;
- (void)changePhoneNumber;
- (void)changePassword;
@end

@implementation TTAccountBindingViewController

- (instancetype)init
{
    return [self initWithRouteParamObj:nil];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    if ((self = [super initWithRouteParamObj:paramObj])) {
        self.thirdAccounts = [[TTPlatformAccountManager sharedManager] platformAccounts];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup navigationBar
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"账号和隐私设置",nil)];
    
    self.can_be_found_by_phone = [TTAccountManager currentUser].canBeFoundByPhone;
    [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self doPlatformShowTracker];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self updatePhonePrivateStatus];
}

- (void)registerNotifications
{
    [TTAccount addMulticastDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

#pragma mark - TTAccountMulticastProtocol and notifications

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self updatePhonePrivateStatus];
}

- (void)onAccountAuthPlatformStatusChanged:(TTAccountAuthPlatformStatusChangedReasonType)reasonType platform:(NSString *)platformName error:(NSError *)error
{
    [self reload];
}

- (void)updatePhonePrivateStatus
{
    BOOL can_be_found_by_phone = [TTAccountManager currentUser].canBeFoundByPhone;
    
    //未改变则不调用接口
    if (can_be_found_by_phone == self.can_be_found_by_phone) {
        return;
    }
    self.can_be_found_by_phone = can_be_found_by_phone;
    
    NSNumber *requestNum;
    if (can_be_found_by_phone) {
        requestNum = @1;
    } else {
        requestNum = @0;
    }
    
//    FRUserRelationSetCanBeFoundByPhoneRequestModel *requestModel = [[FRUserRelationSetCanBeFoundByPhoneRequestModel alloc] init];
//    requestModel.can_be_found_by_phone = requestNum;
//
//    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
//        //do no thing
//    }];
}

- (void)respondsToAccountLogoutPlatform:(NSError *)error
{
    if (!error) {
        WeakSelf;
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"解绑成功", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            StrongSelf;
            [self reload];
        });
    } else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"解绑失败", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
    }
}

- (void)respondsToAccountConnectedPlatformChanged:(NSError *)error
{
    [self reload];
}

// 绑定、更换手机号，修改密码等用户Profile
- (void)onAccountUserProfileChanged:(NSDictionary *)changedFields error:(NSError *)error
{
    [self reload];
}

#pragma mark - private methods

- (void)reload
{
    if (!_sections) _sections = [NSMutableArray array];
    [self.sections removeAllObjects];
    
    if (isEmptyString([TTAccountManager currentUser].mobile)) {
        [self.sections addObjectsFromArray:@[@(kTTSectionTypeBindingInfo)]];
    } else {
        [self.sections addObjectsFromArray:@[@(kTTSectionTypeBindingInfo), @(kTTSectionTypePrivate)]];
    }
    
    self.thirdAccounts = [[TTPlatformAccountManager sharedManager] platformAccounts];
    
    if ([self.thirdAccounts count] > 0) {
        [self.sections addObject:@(kTTSectionTypeThirdAccounts)];
    }
    
    [super reload];
}

- (BOOL)containPasswordCell
{
    if ([self.mobilePhoneNumber length] > 0)
        return YES;
    return NO;
}

- (BOOL)containEmailCell
{
    if ([[self email] length] > 0){
        return YES;
    }
    return NO;
}

- (TTSectionType)sectionTypeOfIndex:(NSUInteger)section
{
    if (section >= [self.sections count]) return kTTSectionTypeNone;
    return [[self.sections objectAtIndex:section] unsignedIntegerValue];
}

- (TTCellType)cellTypeOfIndexPath:(NSIndexPath *)indexPath
{
    TTCellType cellType = kTTCellTypeNone;
    switch ([self sectionTypeOfIndex:indexPath.section]) {
        case kTTSectionTypeBindingInfo: {
            if (indexPath.row == 0) {
                cellType = kTTCellTypeBindingPhone;
            } else if (indexPath.row == 1 && [self containEmailCell]) {
                cellType = kTTCellTypeEmail;
            } else if ([self containPasswordCell]){
                cellType = kTTCellTypeModifyPassword;
            }
        }
            break;
        case kTTSectionTypePrivate: {
            cellType = kTTCellTypePrivatePhone;
            break;
        }
        case kTTSectionTypeThirdAccounts: {
            cellType = kTTCellTypeAccountRelatingItem;
        }
            break;
        default:
            break;
    }
    return cellType;
}

- (TTCellPositionType)cellPositionInIndexPath:(NSIndexPath *)indexPath
{
    TTCellPositionType type = kTTCellPositionTypeFirstAndLast;
    NSUInteger numberOfRows = [self numberOfRowsInSection:indexPath.section];
    
    if (indexPath.row == 0 && indexPath.row == numberOfRows - 1) {
        type = kTTCellPositionTypeFirstAndLast;
    } else if (indexPath.row == 0) {
        type = kTTCellPositionTypeFirst;
    } else if (indexPath.row == numberOfRows - 1) {
        type = kTTCellPositionTypeLast;
    } else {
        type = kTTCellPositionTypeMiddle;
    }
    return type;
}

- (TTUserProfileItem *)userItemOfIndexPath:(NSIndexPath *)indexPath
{
    TTUserProfileItem *item = [TTUserProfileItem new];
    item.titleThemeKey = [TTBaseUserProfileCell titleColorKey];
    item.contentThemeKey = [TTBaseUserProfileCell contentColorKey];
    
    switch ([self cellTypeOfIndexPath:indexPath]) {
        case kTTCellTypeBindingPhone: { // MobilePhoneNumber
            item.title = @"手机号";
            
            NSString *mobileNumber = [self mobilePhoneNumber];
            if (mobileNumber.length == 0) {
                // 暂时未绑定手机号
                item.content = @"绑定手机号";
            } else {
                NSMutableString *mobileString = [NSMutableString stringWithString:mobileNumber];
                if (mobileString.length > 7) {
                    [mobileString replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                }
                item.content = mobileString;
            }
        }
            break;
        case kTTCellTypeModifyPassword: { // Password
            item.title = @"修改密码";
            item.hiddenContent = YES;
        }
            break;
        case kTTCellTypeEmail: {
            item.title = @"邮箱";
            item.content = [self email];
        }
            break;
        default:
            break;
    }
    return item;
}

- (NSString *)cellIdentifierOfIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"kTTAccountBindingDefaultCellIdentifier";
    switch ([self cellTypeOfIndexPath:indexPath]) {
        case kTTCellTypeBindingPhone:
        case kTTCellTypeModifyPassword:
            cellIdentifier = @"kTTAccountBindingUserPhoneInfo";
            break;
        case kTTCellTypeEmail:
            cellIdentifier = @"kTTAccountBindingEmail";
            break;
        case kTTCellTypeAccountRelatingItem:
            cellIdentifier = @"kTTAccountBindingThirdRelatingItem";
            break;
        case kTTCellTypePrivatePhone:
            cellIdentifier = @"kTTAccountBindingPrivatePhone";
            break;
        default:
            break;
    }
    return cellIdentifier;
}

- (TTBaseUserProfileCell *)reuseCellInTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierOfIndexPath:indexPath];
    TTBaseUserProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        switch ([self cellTypeOfIndexPath:indexPath]) {
            case kTTCellTypeBindingPhone:
            case kTTCellTypeModifyPassword:
                cell = [[TTEditUserProfileItemCell alloc] initWithReuseIdentifier:cellIdentifier];
                break;
            case kTTCellTypeEmail:
                cell = [[TTEditUserProfileItemCell alloc] initWithReuseIdentifier:cellIdentifier];
                break;
            case kTTCellTypeAccountRelatingItem:
                cell = [[TTUserBindAccountCell alloc] initWithReuseIdentifier:cellIdentifier];
                break;
            case kTTCellTypePrivatePhone:
                cell = [[TTUserPrivatePhoneCell alloc] initWithReuseIdentifier:cellIdentifier];
                break;
            default:
                cell = [[TTBaseUserProfileCell alloc] initWithReuseIdentifier:cellIdentifier];
                break;
        }
    }
    
    return cell;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (section >= [self.sections count]) return 0;
    
    NSUInteger numberOfRows = 0;
    switch ([self sectionTypeOfIndex:section]) {
        case kTTSectionTypeBindingInfo: {
            numberOfRows = 1;
            
            if ([self containEmailCell]){
                numberOfRows++;
            }
            
            if ([self containPasswordCell]) {
                numberOfRows++;
            }
        }
            break;
        case kTTSectionTypeThirdAccounts: {
            numberOfRows = [self.thirdAccounts count];
        }
            break;
        case kTTSectionTypePrivate: {
            numberOfRows = 1;
        }
            break;
        default:
            break;
    }
    return numberOfRows;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightOfCell = 0;
    switch ([self cellTypeOfIndexPath:indexPath]) {
        case kTTCellTypeBindingPhone:
        case kTTCellTypeModifyPassword:
        case kTTCellTypeEmail:
            heightOfCell = [TTEditUserProfileItemCell cellHeight];
            break;
        case kTTCellTypeAccountRelatingItem:
            heightOfCell = [TTUserBindAccountCell cellHeight];
            break;
        case kTTCellTypePrivatePhone:
            heightOfCell = [TTUserBindAccountCell cellHeight];
            break;
        default:
            break;
    }
    return heightOfCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTBaseUserProfileCell *cell = [self reuseCellInTableView:tableView forIndexPath:indexPath];
    
    // reload cell data
    cell.cellSpearatorStyle = [TTBaseUserProfileCell separatorStyleForPosition:[self cellPositionInIndexPath:indexPath]];
    switch ([self cellTypeOfIndexPath:indexPath]) {
        case kTTCellTypeBindingPhone:
        case kTTCellTypeModifyPassword: {
            TTEditUserProfileItemCell *userItemCell = (TTEditUserProfileItemCell *)cell;
            TTUserProfileItem *userItem = [self userItemOfIndexPath:indexPath];
            [userItemCell reloadWithProfileItem:userItem];
        }
            break;
        case kTTCellTypeEmail:{
            TTEditUserProfileItemCell *userItemCell = (TTEditUserProfileItemCell *)cell;
            TTUserProfileItem *userItem = [self userItemOfIndexPath:indexPath];
            [userItemCell reloadWithProfileItem:userItem];
            userItemCell.topLineEnabled = NO;
            userItemCell.cellSpearatorStyle = kTTCellSeparatorStyleBottomPart;
            [userItemCell hiddenArrowImage];
            userItemCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case kTTCellTypeAccountRelatingItem: {
            if (indexPath.row < [self.thirdAccounts count]) {
                TTUserBindAccountCell *userAccountCell = (TTUserBindAccountCell *)cell;
                TTThirdPartyAccountInfoBase *userAccountItem = [self.thirdAccounts objectAtIndex:indexPath.row];
                userAccountCell.callbackDidTapBindingAccount = self.bindingAccountCallback;
                [userAccountCell reloadWithAccountInfo:userAccountItem];
            }
        }
            break;
        default:
            break;
    }
    
    return cell ? : [[SSThemedTableViewCell alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *aView = nil;
    switch ([self sectionTypeOfIndex:section]) {
        case kTTSectionTypePrivate:
        case kTTSectionTypeThirdAccounts: {
            TTEditUserProfileSectionView *sectionHeaderView = [[TTEditUserProfileSectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), [TTEditUserProfileSectionView defaultSectionHeight])];
            sectionHeaderView.titleLabel.text = @"社交平台帐号绑定";
            if ([self sectionTypeOfIndex:section] == kTTSectionTypePrivate) {
                sectionHeaderView.titleLabel.text = @"开启后，别人可以通过手机号加我好友";
            }
            sectionHeaderView.titleLabel.textColorThemeKey = kColorText3;
            [sectionHeaderView.titleLabel sizeToFit];
            aView = sectionHeaderView;
        }
            break;
        default: {
            aView = [[SSViewBase alloc] initWithFrame:CGRectMake(0, 0, SSWidth(tableView), 0)];
        }
            break;
    }
    aView.backgroundColor = [UIColor clearColor];
    
    return aView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = ([self sectionTypeOfIndex:section] != kTTSectionTypeBindingInfo) ? [TTEditUserProfileSectionView defaultSectionHeight] : 0.f;
    return height;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([self cellTypeOfIndexPath:indexPath]) {
        case kTTCellTypeBindingPhone: {
            if ([[self mobilePhoneNumber] length] == 0) {
                [self bindMobile];          // 绑定手机号
            } else {
                [self changePhoneNumber];   // 更换手机号码
            }
        }
            break;
        case kTTCellTypeModifyPassword: {
            [self changePassword];
        }
            break;
        default: {
            
        }
            break;
    }
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStyleGrouped;
}

- (UIEdgeInsets)tableViewOriginalContentInset
{
    return UIEdgeInsetsMake([self navigationBarHeight] + 10.f, 0, 0, 0);
}

#pragma mark - setter/getter

- (void)setThirdAccounts:(NSArray *)accounts
{
    const NSArray *orderedNames = @[
                                    TT_LOGIN_PLATFORM_WECHAT,
//                                    TT_LOGIN_PLATFORM_HUOSHAN,
//                                    TT_LOGIN_PLATFORM_DOUYIN,
                                    TT_LOGIN_PLATFORM_SINAWEIBO,
                                    TT_LOGIN_PLATFORM_QZONE,
                                    TT_LOGIN_PLATFORM_QQWEIBO
//                                    TT_LOGIN_PLATFORM_TIANYI,
                                    ];
    NSArray<NSString *> *controlledPlatformList = [TTAccountLoginConfLogic loginPlatformEntryList];
    NSMutableArray *mutAccounts = [accounts mutableCopy];
    for (TTThirdPartyAccountInfoBase *account in accounts) {
        if ([account isKindOfClass:[WeixinUserAccount class]]) {
            if (![TTAccountAuthWeChat isAppAvailable]) { // 如果没有安装微信，则删除微信账号登录
                [mutAccounts removeObject:account];
            }
        }
//        } else if ([account isKindOfClass:[HuoShanUserAccount class]]) {
//            if (![TTAccountAuthHuoShan isAppAvailable]) { // 如果没有火山小视频，则删除火山小视频账号登录
//                [mutAccounts removeObject:account];
//            }
//        } else if ([account isKindOfClass:[DouYinUserAccount class]]) {
//            if (![TTAccountAuthDouYin isAppAvailable]) { // 如果没有安装抖音，则删除抖音账号登录
//                [mutAccounts removeObject:account];
//            }
//        } else if ([account isKindOfClass:[RenrenUserAccount class]]) {
//            [mutAccounts removeObject:account];
//        } else if ([account isKindOfClass:[KaixinUserAccount class]]) {
//            [mutAccounts removeObject:account];
//        }
        
        // 根据服务端下发，移除下线平台
        if ([controlledPlatformList count] > 0 && ![controlledPlatformList containsObject:account.keyName]) {
            [mutAccounts removeObject:account];
        }
    }
    
    NSArray *sortedAccounts = [mutAccounts sortedArrayUsingComparator:^NSComparisonResult(TTThirdPartyAccountInfoBase *obj1, TTThirdPartyAccountInfoBase *obj2) {
        if ([obj1 isKindOfClass:[TTThirdPartyAccountInfoBase class]] && [obj2 isKindOfClass:[TTThirdPartyAccountInfoBase class]]) {
            NSUInteger index1 = [orderedNames indexOfObject:[[obj1 class] platformName]];
            NSUInteger index2 = [orderedNames indexOfObject:[[obj2 class] platformName]];
            return (index1 > index2) ? NSOrderedDescending:NSOrderedAscending;
        }
        return NSOrderedAscending;
    }];
    
    _thirdAccounts = sortedAccounts;
}

- (NSString *)email
{
    return [TTAccountManager currentUser].email;
}

- (NSString *)mobilePhoneNumber
{
    return [TTAccountManager currentUser].mobile;
}

- (NSInteger)numberOfLoginedAccounts
{
    return [[TTAccountManager currentUser].connects count];
}

- (UIViewController *)viewController
{
    return [TTUIResponderHelper topViewControllerFor:self.view];
}

#pragma mark - logger

- (void)doPlatformShowTracker
{
    // LogV3
    [_thirdAccounts enumerateObjectsUsingBlock:^(TTThirdPartyAccountInfoBase * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [extraDict setValue:@"mine" forKey:@"source"];
//        if ([obj isKindOfClass:[HuoShanUserAccount class]]) {
//            [extraDict setValue:@"1" forKey:@"hotsoon_login_show"];
//            [TTTrackerWrapper eventV3:@"bind_show" params:extraDict];
//        } else if ([obj isKindOfClass:[DouYinUserAccount class]]) {
//            [extraDict setValue:@"1" forKey:@"douyin_login_show"];
//            [TTTrackerWrapper eventV3:@"bind_show" params:extraDict];
        if ([obj isKindOfClass:[WeixinUserAccount class]]) {
            [extraDict setValue:@"1" forKey:@"weixin_login_show"];
            [TTTrackerWrapper eventV3:@"bind_show" params:extraDict];
        }
//        else if ([obj isKindOfClass:[QZoneUserAccount class]]) {
//            [extraDict setValue:@"1" forKey:@"qq_login_show"];
//            [TTTrackerWrapper eventV3:@"bind_show" params:extraDict];
//        } else if ([obj isKindOfClass:[TianYiUserAccount class]]) {
//            [extraDict setValue:@"1" forKey:@"telecom_login_show"];
//            [TTTrackerWrapper eventV3:@"bind_show" params:extraDict];
//        }
    }];
}

- (void)doClickTrackerForPlatform:(TTThirdPartyAccountInfoBase *)platformInfo
{
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:@"mine" forKey:@"source"];
//    if ([platformInfo isKindOfClass:[HuoShanUserAccount class]]) {
//        [extraDict setValue:@"hotsoon" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_click" params:extraDict];
//    } else if ([platformInfo isKindOfClass:[DouYinUserAccount class]]) {
//        [extraDict setValue:@"douyin" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_click" params:extraDict];
//    }
    if ([platformInfo isKindOfClass:[WeixinUserAccount class]]) {
        [extraDict setValue:@"weixin" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"bind_click" params:extraDict];
    }
//    else if ([platformInfo isKindOfClass:[QZoneUserAccount class]]) {
//        [extraDict setValue:@"qq" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_click" params:extraDict];
//    } else if ([platformInfo isKindOfClass:[TianYiUserAccount class]]) {
//        [extraDict setValue:@"telecom" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_click" params:extraDict];
//    }
}

- (void)doLoginSuccessTrackerForPlatform:(TTThirdPartyAccountInfoBase *)platformInfo
{
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:@"mine" forKey:@"source"];
//    if ([platformInfo isKindOfClass:[HuoShanUserAccount class]]) {
//        [extraDict setValue:@"hotsoon" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_success" params:extraDict];
//    } else if ([platformInfo isKindOfClass:[DouYinUserAccount class]]) {
//        [extraDict setValue:@"douyin" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_success" params:extraDict];
//    }
    if ([platformInfo isKindOfClass:[WeixinUserAccount class]]) {
        [extraDict setValue:@"weixin" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"bind_success" params:extraDict];
    }
//    else if ([platformInfo isKindOfClass:[QZoneUserAccount class]]) {
//        [extraDict setValue:@"qq" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_success" params:extraDict];
//    } else if ([platformInfo isKindOfClass:[TianYiUserAccount class]]) {
//        [extraDict setValue:@"telecom" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_success" params:extraDict];
//    }
}

- (void)doLoginFailureTrackerForPlatform:(TTThirdPartyAccountInfoBase *)platformInfo
{
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [extraDict setValue:@"mine" forKey:@"source"];
//    if ([platformInfo isKindOfClass:[HuoShanUserAccount class]]) {
//        [extraDict setValue:@"hotsoon" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_fail" params:extraDict];
//    } else if ([platformInfo isKindOfClass:[DouYinUserAccount class]]) {
//        [extraDict setValue:@"douyin" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_fail" params:extraDict];
//    }
    if ([platformInfo isKindOfClass:[WeixinUserAccount class]]) {
        [extraDict setValue:@"weixin" forKey:@"action_type"];
        [TTTrackerWrapper eventV3:@"bind_fail" params:extraDict];
    }
//    else if ([platformInfo isKindOfClass:[QZoneUserAccount class]]) {
//        [extraDict setValue:@"qq" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_fail" params:extraDict];
//    } else if ([platformInfo isKindOfClass:[TianYiUserAccount class]]) {
//        [extraDict setValue:@"telecom" forKey:@"action_type"];
//        [TTTrackerWrapper eventV3:@"bind_fail" params:extraDict];
//    }
}

@end


@implementation TTAccountBindingViewController (TTThirdPartyAccounts)

- (TTTriggerBindingUserAccountBlock)bindingAccountCallback
{
    TTTriggerBindingUserAccountBlock _bindingAccountCallback = objc_getAssociatedObject(self, @selector(bindingAccountCallback));
    if (!_bindingAccountCallback) {
        WeakSelf;
        _bindingAccountCallback = ^(id sender, TTThirdPartyAccountInfoBase *info) {
            if (!sender || ![sender isKindOfClass:[UISwitch class]]) {
                return;
            }
            
            StrongSelf;
            [self doClickTrackerForPlatform:info];
            
            UISwitch *switchButton = (UISwitch *)sender;
            if(!TTNetworkConnected()) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络不给力，请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                [switchButton setOn:!switchButton.isOn];
                return;
            }
            
            if (info) {
                if (![info logined]) { // 第三方账号绑定
                    
                    [TTAccountLoginManager requestLoginPlatformByName:info.keyName completion:^(BOOL success, NSError *error) {
                        [self respondsToAccountConnectedPlatformChanged:error];
                        if (success) {
                            [self doLoginSuccessTrackerForPlatform:info];
                        } else {
                            [self doLoginFailureTrackerForPlatform:info];
                        }
                    }];
                    
                    if ([info isKindOfClass:[WeixinUserAccount class]]) {
                        wrapperTrackEvent(@"login", @"auth_weixin");
                    }
                } else {
                    if ([self numberOfLoginedAccounts] < 2 && [self mobilePhoneNumber].length == 0) {
                        // 没有绑定过手机号，提示解绑将无法登录，请先绑定手机号
                        [self showBindingPhoneAlertViewBeforeUnbinding];
                    } else {
                        // 绑定过手机号，确认是否解绑
                        [self showIfUnbindingAlertViewWithUserInfo:info];
                    }
                }
                if (![info isKindOfClass:[WeixinUserAccount class]]) {
                    wrapperTrackEvent(@"login", [NSString stringWithFormat:@"account_setting_%@", info.keyName]);
                }
            }
        };
        self.bindingAccountCallback = _bindingAccountCallback;
    }
    return _bindingAccountCallback;
}

- (void)setBindingAccountCallback:(TTTriggerBindingUserAccountBlock)bindingAccountCallback
{
    objc_setAssociatedObject(bindingAccountCallback, @selector(bindingAccountCallback), bindingAccountCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)showBindingPhoneAlertViewBeforeUnbinding
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"解绑后将无法登录，请先绑定手机号", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:NSLocalizedString(@"立即绑定", nil) otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    WeakSelf;
    actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        StrongSelf;
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [self bindMobile];
            wrapperTrackEvent(@"login_register", @"unbind_last_confirm");
        } else {
            [self reload];
            wrapperTrackEvent(@"login_register", @"unbind_last_cancel");
        }
    };
}

/**
 *  显示是否确认解绑操作
 */
- (void)showIfUnbindingAlertViewWithUserInfo:(TTThirdPartyAccountInfoBase *)info
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"解除绑定?", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    WeakSelf;
    actionSheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        StrongSelf;
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            [TTAccountLoginManager requestLogoutPlatformByName:[info keyName] ? : [[info class] platformName] completion:^(BOOL success, NSError *error) {
                [self respondsToAccountLogoutPlatform:error];
            }];
        } else {
            [self reload];
        }
    };
    
    // log
    if ([info isKindOfClass:[WeixinUserAccount class]]) {
        wrapperTrackEvent(@"login", [NSString stringWithFormat:@"account_setting_%@", info.keyName]);
    }
}

@end


@implementation TTAccountBindingViewController (TTUserMobilePhone)

- (void)bindMobile
{
    wrapperTrackEvent(@"login", @"auth_mobile");
    
    ArticleMobileNumberViewController *viewController = [[ArticleMobileNumberViewController alloc] initWithMobileNumberUsingType:ArticleMobileNumberUsingTypeBind];
    viewController.completion = ^(ArticleLoginState state){
        [[ArticleAddressBridger sharedBridger] setPresentingController:self.navigationController];
        [[ArticleAddressBridger sharedBridger] tryShowGetAddressBookAlertWithMobileLoginState:state];
    };
    
    if ([self.navigationController isKindOfClass:[UINavigationController class]]) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)changePhoneNumber
{
    ArticleMobileChangeViewController *vc = [[ArticleMobileChangeViewController alloc] init];
    if ([self.navigationController isKindOfClass:[UINavigationController class]]) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)changePassword
{
    // 友盟统计
    wrapperTrackEvent(@"login", @"change_password");
    
    NSString *mobileNumber = [self mobilePhoneNumber];
    if ([SSCommonLogic ttAlertControllerEnabled]) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"修改登录密码", nil) message:[NSString stringWithFormat:NSLocalizedString(@"将给手机%@发送验证码", nil), mobileNumber] preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            wrapperTrackEvent(@"login", @"confirm_change");
            
            ArticleMobilePasswordViewController *viewController = [[ArticleMobilePasswordViewController alloc] initWithNibName:nil bundle:nil];
            viewController.mobileNumber = mobileNumber;
            if ([self.navigationController isKindOfClass:[UINavigationController class]])
                [self.navigationController pushViewController:viewController animated:YES];
        }];
        [alert showFrom:self animated:YES];
    } else {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"修改登录密码", nil) message:[NSString stringWithFormat:NSLocalizedString(@"将给手机%@发送验证码", nil), mobileNumber] preferredType:TTThemedAlertControllerTypeAlert];
        WeakSelf;
        [alert addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        }];
        [alert addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            StrongSelf;
            // 友盟统计
            wrapperTrackEvent(@"login", @"confirm_change");
            
            ArticleMobilePasswordViewController *viewController = [[ArticleMobilePasswordViewController alloc] initWithNibName:nil bundle:nil];
            viewController.mobileNumber = mobileNumber;
            
            if ([self.navigationController isKindOfClass:[UINavigationController class]]) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }];
        [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
    }
}

@end
