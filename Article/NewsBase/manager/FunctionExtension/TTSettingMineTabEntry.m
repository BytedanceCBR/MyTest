//
//  TTSettingMineTab_m
//  Article
//
//  Created by fengyadong on 16/11/2.
//
//

#import "TTSettingMineTabEntry.h"
#import "ArticleBadgeManager.h"
#import <TTAccountBusiness.h>
#import "SSCommonLogic.h"
#import "ArticleFetchSettingsManager.h"
#import "SSWebViewController.h"
#import "TTNetworkUtilities.h"
#import "TTThemeManager.h"
#import "PGCAccountManager.h"
#import "TTMessageNotificationTipsManager.h"
//#import "TTPLManager.h"
#import "TTBadgeTrackerHelper.h"
#import "TTRoute.h"

#import "TTMessageNotificationMacro.h"
#import <Crashlytics/Crashlytics.h>
//#import "TTCommonwealManager.h"
#import "TTURLUtils.h"
#import "NSDictionary+TTAdditions.h"
#import "TTRNBundleManager.h"
#import "NSString+URLEncoding.h"
#import "AKLoginTrafficViewController.h"
#define kTTSettingEntryCommonwealDidClicKey @"kTTSettingEntryCommonwealDidClicKey"
#define pgcEntryKey @"pgc"

@implementation TTSettingMineTabEntry

#pragma mark -- Initializer

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    if (self = [super init]) {
        self.key = [dictionary tt_stringValueForKey:@"key"];
        self.shouldBeDisplayed = YES;
        self.hintStyle = [dictionary tt_integerValueForKey:@"tip_new"];
        self.hintCount = 0;
        self.urlString = [dictionary tt_stringValueForKey:@"url"];
        self.text = [dictionary tt_stringValueForKey:@"name"];
        self.isTrackForShow = YES;
        self.isTrackForMineTabShow = YES;
        self.avatarUrlString = [dictionary tt_stringValueForKey:@"avatar_url"];
        self.userAuthInfo = [dictionary tt_stringValueForKey:@"user_auth_info"];
        self.lastImageUrl = [dictionary tt_stringValueForKey:@"last_image_url"];
        self.AKRequireLogin = [dictionary tt_boolValueForKey:@"require_login"];
        self.akTaskSwitch = [dictionary tt_boolValueForKey:@"score_task"];
        NSDictionary *accessoryData = [dictionary tt_dictionaryValueForKey:@"right_data"];
        self.accessoryText = [accessoryData tt_stringValueForKey:@"text"];
        self.accessoryTextColor = [accessoryData tt_stringValueForKey:@"color"];
        [[self class] setBlockForEntry:self];
    }
    
    if (isEmptyString(self.key) || isEmptyString(self.text) || isEmptyString(self.urlString)) {
        return nil;
    }
    
    return self;
}

+ (instancetype)initWithEntryType:(TTSettingMineTabEntyType)type {
    TTSettingMineTabEntry *entry = nil;
    switch (type) {
        case TTSettingMineTabEntyTypeiPhoneTopFunction:
            return [TTSettingMineTabEntry iPhoneTopFunctionEntry];
            break;
        case TTSettingMineTabEntyTypeiPadNightMode:
            return [TTSettingMineTabEntry iPadNightModeEntry];
            break;
        case TTSettingMineTabEntyTypeiPadFavor:
            return [TTSettingMineTabEntry iPadFavorEntry];
            break;
        case TTSettingMineTabEntyTypeiPadHistory:
            return [TTSettingMineTabEntry iPadHistoryEntry];
            break;
        case TTSettingMineTabEntyTypeMyFollow:
            return [TTSettingMineTabEntry followEntry];
            break;
        case TTSettingMineTabEntyTypeWorkLibrary:
            return [TTSettingMineTabEntry workLibraryEntry];
            break;
        case TTSettingMineTabEntyTypeMessage:
            return [TTSettingMineTabEntry messageEntry];
            break;
//        case TTSettingMineTabEntyTypePrivateLetter:
//            return [TTSettingMineTabEntry privateLetterEntry];
//            break;
        case TTSettingMineTabEntyTypeTTMall:
            return [TTSettingMineTabEntry ttMallEntry];
            break;
        case TTSettingMineTabEntyTypeGossip:
            return [TTSettingMineTabEntry gossipEntry];
            break;
        case TTSettingMineTabEntyTypeFeedBack:
            return [TTSettingMineTabEntry feedbackEntry];
            break;
        case TTSettingMineTabEntyTypeSettings:
            return [TTSettingMineTabEntry settingsEntry];
            break;
        default:
            break;
    }
    return entry;
}

#pragma mark -- Entries

+ (instancetype)iPhoneTopFunctionEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"iPhone_top_function";
    entry.shouldBeDisplayed = ![TTDeviceHelper isPadDevice];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = nil;
    entry.text = nil;
    entry.accessoryText = nil;
    entry.iconName = nil;
    
    return entry;
}

+ (instancetype)iPadNightModeEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"iPad_night_mode";
    entry.shouldBeDisplayed = [TTDeviceHelper isPadDevice];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = nil;
    entry.accessoryText = nil;
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        entry.text = NSLocalizedString(@"夜间", nil);
        entry.iconName = @"nighticon_profile";
    } else {
        entry.text = NSLocalizedString(@"日间", nil);
        entry.iconName = @"dayicon_profile";
    }
    
    return entry;
}

+ (instancetype)iPadFavorEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"iPad_favor";
    entry.shouldBeDisplayed = [TTDeviceHelper isPadDevice];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = @"sslocal://favorite?stay_id=favorite";
    entry.text = NSLocalizedString(@"收藏", nil);
    entry.accessoryText = nil;
    entry.iconName = @"favoriteicon_profile";
    
    return entry;
}

+ (instancetype)iPadHistoryEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"iPad_history";
    entry.shouldBeDisplayed = [TTDeviceHelper isPadDevice];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = @"sslocal://history?stay_id=read_history";
    entry.text = NSLocalizedString(@"历史", nil);
    entry.accessoryText = nil;
    entry.iconName = @"history_profile";
    
    return entry;
}

+ (instancetype)iPadMomentEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"iPad_moment";
    entry.shouldBeDisplayed = [TTDeviceHelper isPadDevice];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = @"sslocal://moment_list";
    entry.text = NSLocalizedString(@"好友动态", nil);
    entry.accessoryText = nil;
    entry.iconName = @"dynamicicon_profile";
    
    return entry;
}

+ (instancetype)followEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"mine_attention";
    entry.shouldBeDisplayed = ![TTDeviceHelper isPadDevice] && ![TTAccountManager isLogin];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = @"sslocal://relation/subscribe?titles=[\"subscribe\"]";
    entry.text = NSLocalizedString(@"我的关注", nil);
    entry.accessoryText = nil;
    entry.iconName = nil;
    
    return entry;
}

/**
 * 作品管理入口 url
 */
+ (NSString *)getWorkLibraryEntryUrlString:(NSString *)webviewString {
    NSString *pgcRNParams = [[NSUserDefaults standardUserDefaults] stringForKey:kPGCWorkLibraryRNParams];
    if (pgcRNParams) {
        return [NSString stringWithFormat:@"sslocal://react?%@&fallbackUrl=%@",
                pgcRNParams,
                [webviewString URLEncodedString]
                ];
    }
    return webviewString;
}

+ (instancetype)workLibraryEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    PGCAccount *pgcAccount = [[PGCAccountManager shareManager] currentLoginPGCAccount];
    NSString *webviewUrlString = [NSString stringWithFormat:@"sslocal://webview?url=https://mp.toutiao.com&title=%@", pgcAccount.screenName];
    NSString *urlString = [self getWorkLibraryEntryUrlString:webviewUrlString];
    
    entry.key = pgcEntryKey;
    entry.shouldBeDisplayed = [[PGCAccountManager shareManager] hasPGCAccount];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = urlString;
    entry.text = NSLocalizedString(@"作品管理", nil);
    entry.accessoryText = nil;
    entry.iconName = @"pgcicon_profile";
    
    return entry;
}

+ (TTSettingMineTabEntry *)workLibraryEntryInterceptor:(TTSettingMineTabEntry *)entry {
    entry.urlString = [self getWorkLibraryEntryUrlString:entry.urlString];
    return entry;
}

+ (instancetype)messageEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    TTMessageNotificationTipsManager *manager = [TTMessageNotificationTipsManager sharedManager];
    NSUInteger number = manager.unreadNumber;
    
    entry.key = @"mine_notification";
    entry.shouldBeDisplayed = YES;
    entry.hintStyle = number > 0 ? TTSettingHintStyleNumber : TTSettingHintStyleNone;
    entry.hintCount = number;
    entry.urlString = @"sslocal://message";
    entry.text = NSLocalizedString(@"消息", nil);
    entry.accessoryText = nil;
    entry.avatarUrlString = manager.thumbUrl;
    entry.userAuthInfo = manager.userAuthInfo;
    entry.msgID = manager.msgID;
    entry.actionType = manager.actionType;
    entry.userName = manager.userName;
    entry.action = manager.action;
    entry.tips = manager.tips;
    entry.isImportantMessage = manager.isImportantMessage;
    entry.iconName = @"messageicon_profile";
    entry.lastImageUrl = manager.lastImageUrl;
    
    return entry;
}

//+ (instancetype)privateLetterEntry {
//    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
//
//    NSUInteger number = [TTPLManager sharedManager].unreadNumber;
//
//    entry.key = @"private_letter";
//    entry.shouldBeDisplayed = [SSCommonLogic isIMServerEnable];
//    entry.hintStyle = number > 0 ? TTSettingHintStyleNumber : TTSettingHintStyleNone;
//    entry.hintCount = number;
//    entry.urlString = @"sslocal://private_letter_list";
//    entry.text = NSLocalizedString(@"私信", nil);
//    entry.accessoryText = nil;
//    entry.iconName = @"private_lettericon_profile";
//
//    return entry;
//}

+ (instancetype)ttMallEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"mall";
    entry.shouldBeDisplayed = ![TTDeviceHelper isPadDevice];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = @"sslocal://webview?url=http://lf.quduzixun.com/2/wap/tt_mall/&bounce_disable=1&hide_bar=1&title=头条商城";
    entry.text = NSLocalizedString(@"头条商城", nil);
    entry.accessoryText = [ArticleFetchSettingsManager mineTabSellIntroduce];
    entry.iconName = nil;
    
    return entry;
}

+ (instancetype)gossipEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"gossip";
    entry.shouldBeDisplayed = ![TTDeviceHelper isPadDevice];
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = @"sslocal://gossip";
    entry.text = NSLocalizedString(@"我要爆料", nil);
    entry.accessoryText = nil;
    entry.iconName = nil;
    
    return entry;
}

+ (instancetype)feedbackEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"feedback";
    entry.shouldBeDisplayed = YES;
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = @"sslocal://feedback";
    entry.text = NSLocalizedString(@"用户反馈", nil);
    entry.accessoryText = nil;
    entry.iconName = @"feedbackicon_profile";
    
    return entry;
}

+ (instancetype)settingsEntry {
    TTSettingMineTabEntry *entry = [[TTSettingMineTabEntry alloc] init];
    
    entry.key = @"config";
    entry.shouldBeDisplayed = YES;
    entry.hintStyle = TTSettingHintStyleNone;
    entry.hintCount = 0;
    entry.urlString = @"sslocal://more";
    entry.text = NSLocalizedString(@"系统设置", nil);
    entry.accessoryText = nil;
    entry.iconName = @"setupicon_profile";
    
    return entry;
}

#pragma mark -- NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.iconName = [aDecoder decodeObjectForKey:@"icon_name"];
        self.userAuthInfo = [aDecoder decodeObjectForKey:@"user_auth_info"];
        self.avatarUrlString = [aDecoder decodeObjectForKey:@"avatar_url"];
        self.msgID = [aDecoder decodeObjectForKey:@"message_id"];
        self.actionType = [aDecoder decodeObjectForKey:@"action_type"];
        self.userName = [aDecoder decodeObjectForKey:@"user_name"];
        self.action = [aDecoder decodeObjectForKey:@"action"];
        self.tips = [aDecoder decodeObjectForKey:@"tips"];
        self.isImportantMessage = [[aDecoder decodeObjectForKey:@"is_important_message"] boolValue];
        self.lastClickedTimeInterval = [[aDecoder decodeObjectForKey:@"last_click_interval"] doubleValue];
        self.lastImageUrl = [aDecoder decodeObjectForKey:@"last_image_url"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.iconName forKey:@"icon_name"];
    [aCoder encodeObject:self.userAuthInfo forKey:@"user_auth_info"];
    [aCoder encodeObject:self.avatarUrlString forKey:@"avatar_url"];
    [aCoder encodeObject:self.msgID forKey:@"message_id"];
    [aCoder encodeObject:self.actionType forKey:@"action_type"];
    [aCoder encodeObject:self.userName forKey:@"user_name"];
    [aCoder encodeObject:self.action forKey:@"action"];
    [aCoder encodeObject:self.tips forKey:@"tips"];
    [aCoder encodeObject:@(self.isImportantMessage) forKey:@"is_important_message"];
    [aCoder encodeObject:@(_lastClickedTimeInterval) forKey:@"last_click_interval"];
    [aCoder encodeObject:self.lastImageUrl forKey:@"last_image_url"];
}

#pragma mark -- Helper

/** 通过entry的URL打开Schema，如果clearHint为YES，会自动清除角标，如果不通过服务端下发的红点应设为NO，在update block中管理红点 */
+ (void)openURLForEntry:(TTSettingMineTabEntry *)entry clearHint:(BOOL)clearHint {

    TTSettingMineTabEntry *interceptedEntry;
    if ([entry.key isEqualToString:pgcEntryKey]) {
        interceptedEntry = [self workLibraryEntryInterceptor:entry];
    } else {
        interceptedEntry = entry;
    }

    NSURL *url = [TTStringHelper URLWithURLString:interceptedEntry.urlString];
    if ([url.scheme isEqualToString:@"sslocal"] || [url.scheme hasPrefix:@"snssdk35"]) {
        if ([url.absoluteString rangeOfString:@"jdkepler"].location != NSNotFound) {
            TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:interceptedEntry.urlString]];

            if (paramObj.queryParams) {
                [self openKepler:paramObj.queryParams];
            }
        }else{
            TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:@{@"enter_type":@"mine"}];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:info];
        }
    } else {
        UINavigationController *topController = [TTUIResponderHelper topNavigationControllerFor:nil];
        ssOpenWebView([TTStringHelper URLWithURLString:interceptedEntry.urlString], interceptedEntry.text, topController, NO, nil);
    }
    interceptedEntry.lastClickedTimeInterval = [[NSDate date] timeIntervalSince1970];
    if (clearHint) {
        [interceptedEntry clearHint];
    }
    if (!isEmptyString(interceptedEntry.key)) {
        wrapperTrackEvent(@"mine_tab", interceptedEntry.key);
    }
    if ([interceptedEntry.key isEqualToString:@"mine_notification"]) {
        wrapperTrackEvent(@"mine_tab", @"mine_msg");
    }
}

+ (void)setBlockForEntry:(TTSettingMineTabEntry *)entry {
    [self setEnterBlockForEntry:entry];
    [self setUpdateBlockForEntry:entry];
    [self setSwitchChangedBlockForEntry:entry];
}

+ (void)setEnterBlockForEntry:(TTSettingMineTabEntry *)entry {
    __weak typeof(entry) weakEntry = entry;
    if ([entry.key isEqualToString:@"iPhone_top_function"]
        || [entry.key isEqualToString:@"iPad_night_mode"] || [entry.key isEqualToString:@"night_shift"]) {
        entry.enter = nil;
    } else if ([entry.key isEqualToString:@"private_letter"]) {
        entry.enter = ^(){
            
            if (![TTAccountManager isLogin]) {
                wrapperTrackEvent(@"private_letter", @"click_logoff");
                
                if (weakEntry.hintCount > 0 && weakEntry.hintStyle == TTSettingHintStyleNumber) {
                    [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"click" position:@"private_letter" style:@"num_tips"];
                }
                else if (weakEntry.hintStyle == TTSettingHintStyleRedPoint || weakEntry.hintStyle == TTSettingHintStyleNewFlag){
                    [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"click" position:@"private_letter" style:@"red_tips"];
                }

                [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"private_letter" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                    if (type == TTAccountAlertCompletionEventTypeTip) {
                        UIViewController *viewController = [TTUIResponderHelper topNavigationControllerFor:nil].topViewController;
                        [TTAccountManager presentQuickLoginFromVC:viewController type:TTAccountLoginDialogTitleTypeDefault source:@"private_letter" completion:^(TTAccountLoginState state) {
                        
                        }];
                    }
                }];
            } else {
//                if([TTPLManager sharedManager].unreadNumber != 0){
//                    wrapperTrackEventWithCustomKeys(@"private_letter", @"click_with_badge", nil, nil, nil);
//                }
//                else{
//                    wrapperTrackEventWithCustomKeys(@"private_letter", @"click_without_badge", nil, nil, nil);
//                }
                [self openURLForEntry:weakEntry clearHint:NO];
                [self extraStatisticsForEntry:weakEntry];
            }
        };
    } else if ([entry.key isEqualToString:@"mine_notification"]) {
        entry.enter = ^(){
            
            if(![TTAccountManager isLogin]){
                wrapperTrackEvent(@"message_list", @"click_logoff");
                [AKLoginTrafficViewController presentLoginTrafficViewControllerWithCompleteBlock:nil];
            }
            else{
                if (weakEntry.isImportantMessage){
                    wrapperTrackEventWithCustomKeys(@"message_list", @"click_with_vip",weakEntry.msgID, nil,kTTMessageNotificationTrackExtra(weakEntry.actionType));
                }
                else if (weakEntry.hintCount > 0) {
                    wrapperTrackEventWithCustomKeys(@"message_list", @"click_with_badge",nil, nil, kTTMessageNotificationTrackExtra(weakEntry.actionType));
                }else {
                    wrapperTrackEventWithCustomKeys(@"message_list", @"click_without_badge", nil, nil, kTTMessageNotificationTrackExtra(weakEntry.actionType));
                }
                [[TTMessageNotificationTipsManager sharedManager] clearTipsModel];
            
                [self openURLForEntry:weakEntry clearHint:NO];
                [self extraStatisticsForEntry:weakEntry];
            }
        };
    } else if ([entry.key isEqualToString:@"bd"]) { // 广告合作
        entry.enter = ^(){
            if ([TTAccountManager isLogin]) {
                [self openURLForEntry:weakEntry clearHint:YES];
                [self extraStatisticsForEntry:weakEntry];
            } else {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:nil] type:TTAccountLoginDialogTitleTypeDefault source:@"" isPasswordStyle:YES completion:nil];
            }
            wrapperTrackEvent(@"ad_register", @"mine_ad_register_clk");
        };
    }
    else {
        entry.enter = ^(){
            [self openURLForEntry:weakEntry clearHint:YES];
            [self extraStatisticsForEntry:weakEntry];
        };
    }
}

+ (void)setUpdateBlockForEntry:(TTSettingMineTabEntry *)entry {
    __weak typeof(entry) weakEntry = entry;
    if ([entry.key isEqualToString:@"mine_notification"]) {
        entry.update = ^BOOL{
            [weakEntry setModified:NO];
            TTMessageNotificationTipsManager *manager = [TTMessageNotificationTipsManager sharedManager];
            NSUInteger unreadNumber = manager.unreadNumber;
            weakEntry.hintStyle = unreadNumber > 0 ? TTSettingHintStyleNumber : TTSettingHintStyleNone;
            weakEntry.hintCount = unreadNumber;
            weakEntry.accessoryText = nil;
            weakEntry.userName = manager.userName;
            weakEntry.action = manager.action;
            weakEntry.tips = manager.tips;
            weakEntry.avatarUrlString = manager.thumbUrl;
            weakEntry.userAuthInfo = manager.userAuthInfo;
            weakEntry.msgID = manager.msgID;
            weakEntry.actionType = manager.actionType;
            weakEntry.isImportantMessage = manager.isImportantMessage;
            weakEntry.lastImageUrl = manager.lastImageUrl;
            
            return weakEntry.isModified;
        };
    } else if ([entry.key isEqualToString:@"pgc"]) {
        entry.update = ^BOOL{
            [weakEntry setModified:NO];
            weakEntry.shouldBeDisplayed = [[PGCAccountManager shareManager] hasPGCAccount];
            return weakEntry.isModified;
        };
    } else if ([entry.key isEqualToString:@"mine_attention"]) {
        entry.update = ^BOOL{
            [weakEntry setModified:NO];
            return weakEntry.isModified;
        };
    } else if ([entry.key isEqualToString:@"commonweal"]) {
        entry.update = ^BOOL{
#warning 公益项目暂时代码
            [weakEntry setModified:NO];
            BOOL hasClick = [[NSUserDefaults standardUserDefaults] boolForKey:kTTSettingEntryCommonwealDidClicKey];
            weakEntry.hintCount = hasClick ? 0 : weakEntry.hintCount;
            weakEntry.hintStyle = hasClick ? TTSettingHintStyleNone : TTSettingHintStyleRedPoint;
            
            return weakEntry.isModified;
        };
    }
    else {
        entry.update = nil;
    }
    
    if (entry.update) {
        entry.update();
    }
}

+ (void)extraStatisticsForEntry:(TTSettingMineTabEntry *)entry {
    NSString *position = nil;
    if ([entry.key isEqualToString:@"mine_notification"]) {
        position = @"mine_tab_notify";
    }
    else if ([entry.key isEqualToString:@"mall"]) {
        position = @"mine_tab_mall";
    }
    else if ([entry.key isEqualToString:@"jd"]) {
        position = @"mine_tab_jd";
    }
    else if ([entry.key isEqualToString:@"gossip"]) {
        position = @"mine_tab_gossip";
    }
    else if ([entry.key isEqualToString:@"feedback"]) {
        position = @"mine_tab_feed_back";
    }
    else if ([entry.key isEqualToString:@"config"]) {
        position = @"mine_tab_settings";
    } else if ([entry.key isEqualToString:@"commonweal"]) {
#warning 公益项目暂时代码
        position = @"mine_tab_commonweal";
    }
    
    if (!isEmptyString(position)) {
        if (entry.hintCount > 0 && entry.hintStyle == TTSettingHintStyleNumber) {
            [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"click" position:position style:@"num_tips"];
        }
        else if (entry.hintStyle == TTSettingHintStyleRedPoint || entry.hintStyle == TTSettingHintStyleNewFlag){
            [[TTBadgeTrackerHelper class] trackTipsWithLabel:@"click" position:position style:@"red_tips"];
        }
    }
}

+ (void)setSwitchChangedBlockForEntry:(TTSettingMineTabEntry *)entry {
    __weak typeof(entry) weakEntry = entry;
    if([entry.key isEqualToString:@"iPhone_top_function"]) {
        entry.switchChangedBlock = ^(UISwitch *changedSwitch){
            [[self class] nightModeSwitchValueChanged:changedSwitch];
        };
    } else if ([entry.key isEqualToString:@"iPad_night_mode"]) {
        entry.switchChangedBlock = ^(UISwitch *changedSwitch){
            if([weakEntry.iconName isEqualToString:@"dayicon_profile"]) {
                weakEntry.iconName = @"nighticon_profile";
                weakEntry.text = NSLocalizedString(@"夜间", nil);
            } else if([weakEntry.iconName isEqualToString:@"nighticon_profile"]) {
                weakEntry.iconName = @"dayicon_profile";
                weakEntry.text = NSLocalizedString(@"日间", nil);
            }
            [[self class] nightModeSwitchValueChanged:changedSwitch];
        };
    }else {
        entry.switchChangedBlock = nil;
    }
}

+ (void)openKepler:(NSDictionary *)dict{
    if (SSIsEmptyDictionary(dict)) {
        return;
    }
}

+ (void)nightModeSwitchValueChanged:(UISwitch *)changedSwitch {
    TTThemeMode newMode = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? TTThemeModeNight : TTThemeModeDay;
    [[TTThemeManager sharedInstance_tt] switchThemeModeto:newMode];
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        if (changedSwitch) {
            [changedSwitch setOn:NO];
        }
        wrapperTrackEvent(@"mine_tab", @"night_view_on");
    }
    else {
        if (changedSwitch) {
            [changedSwitch setOn:YES];
        }
        wrapperTrackEvent(@"mine_tab", @"night_view_off");
    }
    
    if (![TTDeviceHelper isPadDevice]) {
        //做一个假的动画效果 让夜间渐变
        UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        
        UIView * imageScreenshot = [tabBarController.view snapshotViewAfterScreenUpdates:NO];
        
        [tabBarController.view  addSubview:imageScreenshot];
        
        [UIView animateWithDuration:0.5f animations:^{
            imageScreenshot.alpha = 0;
        } completion:^(BOOL finished) {
            [imageScreenshot removeFromSuperview];
        }];
    }
}

#define isStringEqual(str1,str2) ((str1 == nil && str2 == nil) || [str1 isEqualToString:str2])

- (void)setAvatarUrlString:(NSString *)avatarUrlString{
    if (!isStringEqual(_avatarUrlString, avatarUrlString)) {
        self.modified = YES;
    }
    _avatarUrlString = avatarUrlString;
}

- (void)setUserAuthInfo:(NSString *)userAuthInfo{
    if(!isStringEqual(_userAuthInfo, userAuthInfo)){
        self.modified = YES;
    }
    _userAuthInfo = userAuthInfo;
}

- (void)setMsgID:(NSString *)msgID{
    if (!isStringEqual(_msgID, msgID)) {
        self.modified = YES;
    }
    _msgID = msgID;
}

- (void)setActionType:(NSString *)actionType{
    if(!isStringEqual(_actionType, actionType)){
        self.modified = YES;
    }
    _actionType = actionType;
}

- (void)setUserName:(NSString *)userName{
    if(!isStringEqual(_userName, userName)){
        self.modified = YES;
    }
    _userName = userName;
}

- (void)setAction:(NSString *)action{
    if(!isStringEqual(_action, action)){
        self.modified = YES;
    }
    _action = action;
}

- (void)setTips:(NSString *)tips{
    if(!isStringEqual(_tips, tips)){
        self.modified = YES;
    }
    _tips = tips;
}

- (void)setIsImportantMessage:(BOOL)isImportantMessage{
    if (_isImportantMessage != isImportantMessage) {
        self.modified = YES;
    }
    _isImportantMessage = isImportantMessage;
}

- (void)setLastImageUrl:(NSString *)lastImageUrl {
    if (!isStringEqual(_lastImageUrl, lastImageUrl)) {
        self.modified = YES;
    }
    _lastImageUrl = lastImageUrl;
}

@end
