//
//  TTContactsGuideManager.m
//  Article
//
//  Created by Jiyee Sheng on 6/30/17.
//
//

#import "TTContactsGuideManager.h"
#import <TTAddressBookSDK.h>
#import "TTContactsNetworkManager.h"
#import "TTContactsUserDefaults.h"
#import "TTNavigationController.h"
#import "TTTabBarController.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "NewsBaseDelegate.h"
#import "TTIndicatorView.h"
#import "NetworkUtilities.h"
#import "FRRequestManager.h"
#import "TTGuideDispatchManager.h"
#import "TTContactsGuideViewHelper.h"
#import "TTContactsRedPacketGuideViewHelper.h"
#import <TTDialogDirector/TTDialogDirector.h>


NSString * const kTTContactsCheckResultKey               = @"kTTContactsCheckResultKey"; // 上次请求通讯录弹窗接口的结果缓存
NSString * const kTTContactsGuidePresentTimesKey         = @"kTTContactsGuidePresentTimesKey"; // (保留)再弹一次标识，用于累加次数统计
NSString * const kTTContactsGuideOnceMoreKey             = @"TTContactsGuideOnceMoreKey"; // (保留)再弹一次标识，用于累加次数统计

NSUInteger const kTTMinimumCheckTimeInterval             = 24 * 3600; // 兜底策略，最短检查时间间隔，检查是否允许弹窗的接口，默认每天至多请求一次
NSUInteger const kTTMinimumPresentTimeInterval           = 7 * 24 * 3600; // 兜底策略，最短弹窗时间间隔，默认保证七天内最多只允许弹一次
NSUInteger const kTTMaximumContactsAuthorizationTimeInterval = 15 * 60; // 跳转到设置页面之后 15 min 有效期

static TTIndicatorView *kIndicatorView = nil;

@implementation TTContactsGuideManager

+ (instancetype)sharedManager {
    static TTContactsGuideManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTContactsGuideManager alloc] init];
    });

    return manager;
}

#pragma mark - AutoUpload

+ (void)autoUploadContactsIfNeeded {
    // 如果用户未授权，或者拒绝授权，则直接返回
    if (![TTAddressBook isAddressBookAllowed]) {
        return;
    }

    NSNumber *timeInterval = [SSCommonLogic autoUploadContactsInterval];

    // 未下发 interval 字段
    if (!timeInterval) {
        return;
    }

    NSTimeInterval delta = timeInterval.doubleValue;

    // 保护策略，如果下发 interval 字段小于 1 天，则忽略
    if (delta < 24 * 60 * 60) {
        return;
    }

    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];

    NSNumber *lastTimestamp = [[NSUserDefaults standardUserDefaults] objectForKey:kTTUploadContactsTimestampKey];
    NSTimeInterval last = lastTimestamp.doubleValue;

    // 如果之前未上传过通讯录
    if (!lastTimestamp) { // 如果已经授权过，则自动上传，并记录时间
        [TTContactsGuideManager uploadContactsInBackground];
    } else if (now - last > delta) { // 或者符合超过 interval 时间间隔
        [TTContactsGuideManager uploadContactsInBackground];
    }
}

+ (void)uploadContactsInBackground {
    if ([TTAddressBook isAddressBookAllowed]) {
        // 提前记录上传时间，避免重复上传
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:kTTUploadContactsTimestampKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[TTAddressBookService sharedService] loadContactsForProperties:kTTContactsOfPropertiesV2
                                                             startBlock:nil
                                                            finishBlock:^(NSArray<TTABContact *> *records, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // upload addressbook
                    [TTContactsNetworkManager postContacts:records userActive:NO completion:^(NSError *error2, id jsonObj) {
                        if (!error2) {
                            [TTContactsUserDefaults setHasUploadedContacts:YES];

                            [TTTrackerWrapper eventV3:@"upload_concat_list_auto" params:@{
                                @"type": @"success"
                            }];
                        } else {
                            [TTTrackerWrapper eventV3:@"upload_concat_list_auto" params:@{
                                @"type" : @"failure",
                                @"reason" : @(error2.code)
                            }];
                        }
                    }];
                });
            } else {
                [TTTrackerWrapper eventV3:@"upload_concat_list_auto" params:@{
                    @"type" : @"failure",
                    @"reason" : @(error.code)
                }];
            }
        }];
    }
}

#pragma mark - Check Contacts Validation

- (void)presentContactsGuideView {
    if ([self presentingContactsGuideViewType] == TTContactsGuideViewNoRedPacket) {
        // 增加延时，保证能在推荐频道加载之后执行判断
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // if (![[TTGuideDispatchManager sharedInstance_tt] containItemForClass:[TTContactsGuideViewHelper class]]) {
            //     TTContactsGuideViewHelper <TTGuideProtocol> *guideViewItem = [TTContactsGuideViewHelper new];
            //     [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:guideViewItem withContext:nil];
            // }
            
            if (![TTDialogDirector containsDialogClass:[TTContactsGuideViewHelper class]]) {
                TTContactsGuideViewHelper <TTGuideProtocol> *guideViewItem = [TTContactsGuideViewHelper new];
                [guideViewItem showWithContext:nil];
            }
        });
    } else if ([self presentingContactsGuideViewType] == TTContactsGuideViewRedPacket) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // if (![[TTGuideDispatchManager sharedInstance_tt] containItemForClass:[TTContactsRedPacketGuideViewHelper class]]) {
            //     TTContactsRedPacketGuideViewHelper <TTGuideProtocol> *guideViewItem = [TTContactsRedPacketGuideViewHelper new];
            //     [[TTGuideDispatchManager sharedInstance_tt] addGuideViewItem:guideViewItem withContext:nil];
            // }
            
            if (![TTDialogDirector containsDialogClass:[TTContactsRedPacketGuideViewHelper class]]) {
                TTContactsRedPacketGuideViewHelper <TTGuideProtocol> *guideViewItem = [TTContactsRedPacketGuideViewHelper new];
                [guideViewItem showWithContext:nil];
            }
        });
    }
}

- (void)checkContactsValidation {
    FRUserRelationContactcheckRequestModel *requestModel = [[FRUserRelationContactcheckRequestModel alloc] init];

    [FRRequestManager requestModel:requestModel callBackWithMonitor:^(NSError *error, NSObject <TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        FRUserRelationContactcheckResponseModel *model = (FRUserRelationContactcheckResponseModel *) responseModel;

        if (model) {
            // 记录通讯录弹窗服务端检查时间
            [TTContactsUserDefaults setContactsGuideCheckTimestamp:[[NSDate date] timeIntervalSince1970]];

            [self setContactsCheckResultInUserDefaults:model];

            if ([self shouldPresentContactsGuideView]) {
                [self presentContactsGuideView];
            }
        }
    }];
}

- (BOOL)shouldCheckContactsValidation {
    FRUserRelationContactcheckResponseModel *model = [self contactsCheckResultInUserDefaults];

    if (!model) {
        return YES; 
    }

    if (model.data.has_collected.boolValue) { // 服务端确认已上传过通讯录的则永远不再检查
        [TTContactsUserDefaults setHasUploadedContacts:YES];
        return NO;
    }

    // 如果用户已经允许通讯录权限，则不需要检查
    if ([TTAddressBook isAddressBookAllowed]) {
        return NO;
    }

    NSTimeInterval dateNow = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval deltaNext = model.data.next_time.doubleValue; // 下一次请求服务端的时间间隔，如 7 * 24 * 3600
    NSTimeInterval dateLast = [TTContactsUserDefaults contactsGuideCheckTimestamp];

    if (dateLast > 0 && dateNow - dateLast < kTTMinimumCheckTimeInterval) { // 端上兜底策略
        return NO;
    }

    return dateNow - dateLast > deltaNext; // 如果此次未能弹出，优先重新请求服务端检查，之前存储的条件被重置
}

- (BOOL)shouldPresentContactsGuideView {
    FRUserRelationContactcheckResponseModel *model = [self contactsCheckResultInUserDefaults];

    if (!model) {
        return NO;
    }

    if (!TTNetworkConnected()) { // 网络连接正常
        return NO;
    }

    if ([TTDeviceHelper isPadDevice]) { // iPad 不弹
        return NO;
    }

    if (model.data.popup_type.integerValue == TTContactsGuideViewRedPacket &&
        (!model.data.redpack ||
            model.data.redpack.status.integerValue != TTContactsRedPacketAvailable ||
            isEmptyString(model.data.redpack.redpack_id) ||
            isEmptyString(model.data.redpack.token))) { // 检查红包数据合法性
        return NO;
    }

    // 如果用户已经允许通讯录权限，则不需要弹窗。这里，有一个特殊情况...
    if ([TTAddressBook isAddressBookAllowed]) {
        if (model.data.popup_type.integerValue == TTContactsGuideViewRedPacket &&
            [self isNotOverTimeIntervalAfterOpenSettingsUrl]) { // 拒绝权限用户在设置里打开了通讯录权限之后+判断授权跳转回来的策略
            return YES;
        }

        return NO;
    }

    // 如果用户拒绝了通讯录权限 (Denied)，则服务端返回弹出无红包弹窗时就忽略掉，直到弹出有红包弹窗为止。
    if ([TTAddressBook isAddressBookDenied] && model.data.popup_type.integerValue == TTContactsGuideViewNoRedPacket) {
        return NO;
    }

    // 暂时移除端上此策略
//    NSTimeInterval dateNow = [[NSDate date] timeIntervalSince1970];
//    NSTimeInterval dateLast = [TTContactsUserDefaults contactsGuidePresentTimestamp];
//
//    if (dateLast > 0 && dateNow - dateLast < kTTMinimumPresentTimeInterval) { // 端上兜底策略
//        return NO;
//    }

    // 如果用户已经上传过通讯录，则不需要弹窗。用户首次启动时，默认返回 YES。另外，这个策略要放在上一个策略之后，因为启动存在静默上传，也会设置此
    if ([TTContactsUserDefaults hasUploadedContacts]) {
        return NO;
    }

    return model.data.should_popup.integerValue > 0;
}

/**
 * 待弹出通讯录弹窗类型
 * @return 弹窗枚举类型
 */
- (TTContactsGuideViewType)presentingContactsGuideViewType {
    FRUserRelationContactcheckResponseModel *model = [self contactsCheckResultInUserDefaults];

    return (TTContactsGuideViewType) model.data.popup_type.integerValue;
}

- (FRUserRelationContactcheckResponseModel *)contactsCheckResultInUserDefaults {
    NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kTTContactsCheckResultKey];

    if (!dictionary) {
        return nil;
    }

    NSError *error = nil;
    FRUserRelationContactcheckResponseModel *model =
        [[FRUserRelationContactcheckResponseModel alloc] initWithDictionary:dictionary error:&error];

    if (!model || error) { // model 无法解析
        return nil;
    }

    return model;
}

- (void)setContactsCheckResultInUserDefaults:(FRUserRelationContactcheckResponseModel *)model {
    NSDictionary *dictionary = model.toDictionary;

    [[NSUserDefaults standardUserDefaults] setValue:dictionary forKey:kTTContactsCheckResultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setContactsGuideHasPresented {
    FRUserRelationContactcheckResponseModel *model = [self contactsCheckResultInUserDefaults];

    if (model) {
        model.data.should_popup = @(-1); // 特殊标识，标记此次通讯录弹窗已弹出过

        [self setContactsCheckResultInUserDefaults:model];
    }

    // 累加弹出次数
    NSInteger presentTimes = [[NSUserDefaults standardUserDefaults] integerForKey:kTTContactsGuidePresentTimesKey];
    [[NSUserDefaults standardUserDefaults] setInteger:(++presentTimes) forKey:kTTContactsGuidePresentTimesKey];
}

- (NSInteger)contactsGuidePresentingTimes {
    NSInteger presentTimes = [[NSUserDefaults standardUserDefaults] integerForKey:kTTContactsGuidePresentTimesKey];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kTTContactsGuideOnceMoreKey]) {
        return presentTimes + 1;
    }

    return presentTimes;
}

/**
 * 判断跳转到设置页面时间是否 15 min 之内
 * @return
 */
- (BOOL)isNotOverTimeIntervalAfterOpenSettingsUrl {
    return [[NSDate date] timeIntervalSince1970] - [TTContactsUserDefaults contactsAuthorizationTimestamp] <= kTTMaximumContactsAuthorizationTimeInterval;
}


#pragma mark - UI related methods

- (void)showIndicatorView:(NSString *)text {
    if (kIndicatorView && kIndicatorView.superview) {
        [kIndicatorView dismissFromParentView];
        kIndicatorView = nil;
    }
    kIndicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView
                                                       indicatorText:text
                                                      indicatorImage:nil
                                                      dismissHandler:nil];

    [kIndicatorView showFromParentView:[TTUIResponderHelper mainWindowRootViewController].view];
    kIndicatorView.userInteractionEnabled = YES; // 模态弹框效果
    kIndicatorView.autoDismiss = NO;
}

- (void)hideIndicatorView {
    if (kIndicatorView && kIndicatorView.superview) {
        [kIndicatorView dismissFromParentView];
    }
}

/**
 * 用户是否停留在首页 Tab
 * @return
 */
- (BOOL)isUserStayInExploreMainViewController {
    UIViewController *rootViewController = [TTUIResponderHelper mainWindowRootViewController];
    if ([rootViewController isKindOfClass:[TTTabBarController class]]) {
        TTTabBarController *tabBarController = (TTTabBarController *)rootViewController;
        if (tabBarController.selectedIndex == 0 && [tabBarController.selectedViewController isKindOfClass:[TTNavigationController class]]) {
            TTNavigationController *navigationController = tabBarController.selectedViewController;
            if ([navigationController.topViewController isKindOfClass:[ArticleTabBarStyleNewsListViewController class]] &&
                !navigationController.presentedViewController) {
                return YES;
            }
        }
    }

    return NO;
}

/**
 * Feed 流是否处于推荐频道
 * @return
 */
- (BOOL)isCurrentExploreCategoryIdEqualsToMainCategoryId {
    TTExploreMainViewController *mainVC = [(NewsBaseDelegate *)[[UIApplication sharedApplication] delegate] exploreMainViewController];
    return (mainVC && mainVC.categorySelectorView && [mainVC.categorySelectorView.categoryId isEqualToString:kTTMainCategoryID]);
}

@end
