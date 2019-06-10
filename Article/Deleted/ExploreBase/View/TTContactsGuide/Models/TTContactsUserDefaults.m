
//
//  TTContactsUserDefaults.m
//  Article
//
//  Created by Zuopeng Liu on 7/24/16.
//
//

#import "TTContactsUserDefaults.h"
#import "TTContactsNetworkManager.h"
//#import <SDWebImage/SDWebImageManager.h>
#import <TTImage/TTWebImageManager.h>
#import "SSCommonLogic.h"



/**
 * [键名] >> 本地存储 settings 下发的上传通讯录配置，KeyValue 包含如下：
 * TTCollectContactsVersionKey : VersionNumber
 * TTContactsDialogStyleDataKey : DialogTexts
 */
NSString * const TTUploadContactsConfigPersistenceKey   = @"TTUploadContactsConfigPersistenceKey";

NSString * const TTCollectContactsVersionKey            = @"contacts_collect_version";
NSString * const TTContactsDialogStyleDataKey           = @"contacts_dialog_style";

// DialogTexts 里包含的 KeyValue
NSString * const TTContactsDialogStyleMajorTextKey      = @"major_text";
NSString * const TTContactsDialogStyleMinorTextKey      = @"minor_text";
NSString * const TTContactsDialogStyleButtonTextKey     = @"button_text";
NSString * const TTContactsDialogStylePrivacyTextKey    = @"privacy_notice";
NSString * const TTContactsDialogStyleImageURLKey       = @"diagram_url";
NSString * const TTContactsDialogStyleNightImageURLKey  = @"diagram_url_night";
NSString * const TTContactsDialogStyleImageNameKey      = @"diagram_name";

NSString * const TTHasUploadedContactsFlagKey           = @"TTHasUploadedContactsFlagKey"; // 是否成功上传过通讯录至服务端

NSString * const kTTContactsCheckTimestampKey           = @"kTTContactsCheckTimestampKey"; // 上次请求通讯录弹窗接口的时间戳
NSString * const TTContactsGuidePresentTimestampKey     = @"TTContactsGuideTimestampKey"; // 上次弹出通讯录弹窗的时间戳

/**
 * 'contents': {
        'open_contact': '你的通讯录好友给你发来红包',
        'open_redpack': '领取好友红包',
        'friend_name': '',  # 如果为空则展示『xx等x位』，不为空则显示该文案
        'get_redpack': '获得好友红包，金额随机',
        'redpack': '好友红包',
    },
    'pop_redpack_interval': 7*24*3600,  # 点X后7天弹出通讯录红包
    'check_expire_time': 24*3600,  # check是否可领红包数据缓存1天
 */
NSString * const TTContactsRedPacketDataKey             = @"tt_upload_contact_redpack"; // 通讯录红包 settings
NSString * const TTContactsRedPacketContentsKey         = @"contents"; // 红包文案可控内容
NSString * const TTContactsRedPacketPersistenceKey      = @"TTContactsRedPacketPersistenceKey";
NSString * const TTContactsRedPacketAuthTimestampKey    = @"TTContactsRedPacketAuthTimestampKey";

@implementation TTContactsUserDefaults

+ (BOOL)hasUploadedContacts {
    id flagObj = [[NSUserDefaults standardUserDefaults] objectForKey:TTHasUploadedContactsFlagKey];
    if (!flagObj) { // 本地判断不存在的情况下，请求网络判断，并保存到本地
        [TTContactsNetworkManager requestHasUploadedContactsWithCompletion:^(NSError *error, BOOL hasUploadedContacts) {
            // 如果服务端异常则终止流程
            if (error) {
                return;
            }

            [TTContactsUserDefaults setHasUploadedContacts:hasUploadedContacts];
        }];
        return YES;
    } else {
        return [[NSUserDefaults standardUserDefaults] boolForKey:TTHasUploadedContactsFlagKey];
    }
}

+ (void)setHasUploadedContacts:(BOOL)flag {
    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:TTHasUploadedContactsFlagKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:kTTFollowCategoryUploadedContactsCardStatusChangeNotification object:nil];
}

/**
 * 1. 如果服务端下发版本比客户端版本高且非0，则更新 TTUploadContactsConfigPersistenceKey
 * 2. 如果contacts_dialog_style存在且需要下载的图片不存在缓存，则预下载
 */
+ (void)parseContactConfigsFromSettings:(NSDictionary *)settings {
    long newVersionNumber       = [settings tt_longValueForKey:TTCollectContactsVersionKey];
    NSDictionary *dialogTexts   = [settings tt_dictionaryValueForKey:TTContactsDialogStyleDataKey];

    NSMutableDictionary *contactDict = [[[NSUserDefaults standardUserDefaults] objectForKey:TTUploadContactsConfigPersistenceKey] mutableCopy];
    if (!contactDict) contactDict = [NSMutableDictionary dictionary];
    long oldVersionNumber = [contactDict tt_longValueForKey:TTCollectContactsVersionKey];

    if (newVersionNumber > 0 && newVersionNumber > oldVersionNumber) {
        [contactDict setValue:@(newVersionNumber) forKey:TTCollectContactsVersionKey];
        if ([self isValidDialogTexts:dialogTexts]) {
            [contactDict setValue:dialogTexts forKey:TTContactsDialogStyleDataKey];
        } else {
            [contactDict setValue:nil forKey:TTContactsDialogStyleDataKey];
        }

        [[NSUserDefaults standardUserDefaults] setValue:contactDict forKey:TTUploadContactsConfigPersistenceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // 如果弹窗需要的图片本地不存在缓存，则预先下载图片
    [self downloadImagesInDialogTextsIfNeeded];
}

/**
 * 如果弹窗需要的图片本地不存在缓存，则预先下载图片
 */
+ (void)downloadImagesInDialogTextsIfNeeded {
    NSMutableDictionary *contactDict = [[[NSUserDefaults standardUserDefaults] objectForKey:TTUploadContactsConfigPersistenceKey] mutableCopy];
    if (!contactDict) contactDict = [NSMutableDictionary dictionary];

    NSDictionary *dialogTexts = [contactDict tt_dictionaryValueForKey:TTContactsDialogStyleDataKey];

    // 日间模式图
    NSString *URLString = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleImageURLKey];
    if (!isEmptyString(URLString) && ![TTWebImageManager cachedImageExistsForKey:URLString]) {
        [[TTWebImageManager shareManger] downloadImageWithURL:URLString options:0 progress:nil completed:nil];
    }

    // 夜间模式图
    NSString *nightURLString = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleNightImageURLKey];
    if (!isEmptyString(nightURLString) && ![TTWebImageManager cachedImageExistsForKey:nightURLString]) {
        [[TTWebImageManager shareManger] downloadImageWithURL:nightURLString options:0 progress:nil completed:nil];
    }
}

/**
 * 获取通讯录弹窗文案，settings 获取，根据 style_version 更新
 * 如果图片未加载成功，则直接使用本地预制数据 (PS, 此策略有点粗暴，或许有问题)
 * @return 返回通讯录弹窗文案
 */
+ (NSDictionary *)contactDialogTexts {
    NSDictionary *contactDict = [[NSUserDefaults standardUserDefaults] objectForKey:TTUploadContactsConfigPersistenceKey];
    NSDictionary *dialogTexts = [contactDict tt_dictionaryValueForKey:TTContactsDialogStyleDataKey];

    NSString *urlString = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleImageURLKey];
    NSString *nightUrlString = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleNightImageURLKey];

    BOOL isValid  = [self isValidDialogTexts:dialogTexts];
    if (![TTWebImageManager cachedImageExistsForKey:urlString] && ![TTWebImageManager cachedImageExistsForKey:nightUrlString]) {
        isValid = NO;
    }

    if (!isValid) {
        NSDictionary *defaultTexts = @{
            TTContactsDialogStyleMajorTextKey: @"看看哪些好友在用爱看",
            TTContactsDialogStyleMinorTextKey: @"同步通讯录",
            TTContactsDialogStyleButtonTextKey: @"现在看看" ,
            TTContactsDialogStylePrivacyTextKey: @"在“我的”-“设置”-“账号和隐私设置”可关闭" ,
            TTContactsDialogStyleImageNameKey: @"read_friends_contacts"
        };

        NSMutableDictionary *mutableContactDict = [contactDict mutableCopy];
        if (!mutableContactDict) mutableContactDict = [NSMutableDictionary dictionary];
        [mutableContactDict setValue:defaultTexts forKey:TTContactsDialogStyleDataKey];
        [[NSUserDefaults standardUserDefaults] setValue:mutableContactDict forKey:TTUploadContactsConfigPersistenceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        return defaultTexts;
    }

    return dialogTexts;
}

/**
 * 判断 settings 弹窗文案是否合法
 * @param dialogTexts 弹窗文案字典
 * @return 返回弹窗文案是否合法
 */
+ (BOOL)isValidDialogTexts:(NSDictionary *)dialogTexts {
    if (!dialogTexts) return NO;

    NSString *majorText = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleMajorTextKey];
    NSString *minorText = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleMinorTextKey];
    NSString *buttonText = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleButtonTextKey];
    NSString *URLString = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleImageURLKey];
    NSString *nightURLString = [dialogTexts tt_stringValueForKey:TTContactsDialogStyleNightImageURLKey];

    return (!isEmptyString(majorText) && !isEmptyString(minorText) && !isEmptyString(buttonText) && !isEmptyString(URLString) && !isEmptyString(nightURLString));
}

+ (NSTimeInterval)contactsGuideCheckTimestamp {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kTTContactsCheckTimestampKey];
}

+ (void)setContactsGuideCheckTimestamp:(NSTimeInterval)timestamp {
    [[NSUserDefaults standardUserDefaults] setDouble:timestamp forKey:kTTContactsCheckTimestampKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSTimeInterval)contactsGuidePresentTimestamp {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:TTContactsGuidePresentTimestampKey];
}

+ (void)setContactsGuidePresentTimestamp:(NSTimeInterval)timestamp {
    [[NSUserDefaults standardUserDefaults] setDouble:timestamp forKey:TTContactsGuidePresentTimestampKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 通讯录红包相关策略

+ (void)parseContactRedPacketConfigurationsFromSettings:(NSDictionary *)settings {
    NSDictionary *contactRedPacketDict = [settings tt_dictionaryValueForKey:TTContactsRedPacketDataKey];
    NSDictionary *contents = [contactRedPacketDict tt_dictionaryValueForKey:TTContactsRedPacketContentsKey];

    if (contents) {
        [[NSUserDefaults standardUserDefaults] setValue:contactRedPacketDict forKey:TTContactsRedPacketPersistenceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSDictionary *)dictionaryOfContactsRedPacketContents {
    NSDictionary *contactRedPacketDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:TTContactsRedPacketPersistenceKey];

    return [contactRedPacketDict dictionaryValueForKey:TTContactsRedPacketContentsKey defalutValue:nil];
}

+ (NSTimeInterval)contactsAuthorizationTimestamp {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:TTContactsRedPacketAuthTimestampKey];
}

+ (void)setContactsAuthorizationTimestamp:(NSTimeInterval)timestamp {
    [[NSUserDefaults standardUserDefaults] setDouble:timestamp forKey:TTContactsRedPacketAuthTimestampKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 关注频道上传通讯录卡片

static BOOL kTTUserCloseUploadContactsCardInFollowCategory = NO;
static NSString * const kTTUserCompleteUploadContactsKey = @"kTTUserCompleteUploadContactsKey";
static NSString * const kTTUserCloseUploadContactsInFollowCategoryLastTimesKey = @"kTTUserCloseUploadContactsInFollowCategoryLastTimesKey";
static NSString * const kTTUserCloseUploadContactsInFollowCategoryLastLastTimesKey = @"kTTUserCloseUploadContactsInFollowCategoryLastLastTimesKey";
static NSString * const kTTUserCloseUploadContactsInFollowCategoryDateKey = @"kTTUserCloseUploadContactsInFollowCategoryDateKey";
NSString * const kTTFollowCategoryUploadedContactsCardStatusChangeNotification = @"kTTFollowCategoryUploadedContactsCardStatusChangeNotification";

+ (void)setUserCompleteUploadContacts {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTUserCompleteUploadContactsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTFollowCategoryUploadedContactsCardStatusChangeNotification object:nil];
}

+ (BOOL)needShowUploadContactsInFollowCategory {
    //Setting接口下发是否开启通讯录上传卡片
    BOOL followChannelUploadContactsEnable = [SSCommonLogic followChannelUploadContactsEnable];
    //用户是否成功上传过通讯录
    BOOL hasUploadedContacts = [self hasUploadedContacts];
    //用户是否完成通讯录上传
    BOOL userCompleteUploadContacts = [[NSUserDefaults standardUserDefaults] boolForKey:@"kTTUserCompleteUploadContactsKey"];

    //距离上次关闭通讯录上传卡片之后，是否到了再次展示的时候
    NSUInteger lastCloseTime = [[NSUserDefaults standardUserDefaults] integerForKey:kTTUserCloseUploadContactsInFollowCategoryLastTimesKey];
    NSUInteger lastLastCloseTime = [[NSUserDefaults standardUserDefaults] integerForKey:kTTUserCloseUploadContactsInFollowCategoryLastLastTimesKey];
    NSTimeInterval lastCloseDateTimeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kTTUserCloseUploadContactsInFollowCategoryDateKey];
    NSTimeInterval nowDateTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSUInteger days = (nowDateTimeInterval - lastCloseDateTimeInterval) / (24.f * 60.f * 60.f);
    BOOL needShowAfterLastClose = (days >= lastCloseTime + lastLastCloseTime);

    if (followChannelUploadContactsEnable
        && !hasUploadedContacts
        && !userCompleteUploadContacts
        && needShowAfterLastClose
        && !kTTUserCloseUploadContactsCardInFollowCategory) {
        //Setting接口下发开启通讯录上传卡片
        //用户没有上传过通讯录
        //用户没有完成通讯录上传
        //到了再次展示的时候
        //本次用户没有关闭过上传通讯录卡片
        return YES;
    } else {
        return NO;
    }
}

+ (void)userCloseUploadContactsInFollowCategory {
    NSUInteger lastCloseTime = [[NSUserDefaults standardUserDefaults] integerForKey:kTTUserCloseUploadContactsInFollowCategoryLastTimesKey];
    NSUInteger lastLastCloseTime = [[NSUserDefaults standardUserDefaults] integerForKey:kTTUserCloseUploadContactsInFollowCategoryLastLastTimesKey];
    if (0 == lastCloseTime && 0 == lastLastCloseTime) {
        lastCloseTime = 1;
        lastLastCloseTime = 2;
    } else {
        lastLastCloseTime = lastCloseTime + lastLastCloseTime;
        lastCloseTime = lastLastCloseTime - lastCloseTime;
    }

    [[NSUserDefaults standardUserDefaults] setInteger:lastCloseTime forKey:kTTUserCloseUploadContactsInFollowCategoryLastTimesKey];
    [[NSUserDefaults standardUserDefaults] setInteger:lastLastCloseTime forKey:kTTUserCloseUploadContactsInFollowCategoryLastLastTimesKey];

    NSTimeInterval closeTimeInterval = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setDouble:closeTimeInterval forKey:kTTUserCloseUploadContactsInFollowCategoryDateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    kTTUserCloseUploadContactsCardInFollowCategory = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTFollowCategoryUploadedContactsCardStatusChangeNotification object:nil];
}

@end
