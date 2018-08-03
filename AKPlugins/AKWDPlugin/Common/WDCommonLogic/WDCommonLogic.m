//
//  WDCommonLogic.m
//  Article
//
//  Created by xuzichao on 16/9/8.
//
//

#import "WDCommonLogic.h"
#import "WDCommonURLSetting.h"
#import "WDDefines.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>

@implementation WDCommonLogic

@end

@implementation WDCommonLogic (WDCategoryCathedData)

+ (NSURL *)fileWDCategoryCathedDataUrl
{
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsPath = [dirs objectAtIndex:0];
    NSString *fileDocumentPath = [NSString stringWithFormat:@"%@%@",documentsPath,@"/WDCathedData"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDocumentPath]) {
        
        [fileManager createDirectoryAtPath:fileDocumentPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    
    NSURL *fileUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@",documentsPath,@"/WDCathedData/jsonString"]];
    
    return fileUrl;
}

+ (void)setWDCategoryCathedDataJsonString:(NSString *)jsonString
{
    NSURL *fileUrl = [WDCommonLogic fileWDCategoryCathedDataUrl];
    [jsonString writeToURL:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSString *)getWDCategoryCathedDataJsonString
{
    NSURL *fileUrl = [WDCommonLogic fileWDCategoryCathedDataUrl];
    
    NSString *script = [NSString stringWithContentsOfFile:fileUrl.path encoding:NSUTF8StringEncoding error:nil];
    
    return script;
}


+ (void)clearWDCategoryCathedDataJsonString
{
    NSURL *fileUrl = [WDCommonLogic fileWDCategoryCathedDataUrl];
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:fileUrl.path error:nil];
}

@end


@implementation WDCommonLogic (WDDetailSwitch)

static NSString *const kWDCommonWDDetailStyleKey = @"kWDCommonWDDetailStyleKey";
+ (void)setWDNewDetailStyleEnabled:(BOOL)enabled{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kWDCommonWDDetailStyleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isWDNewDetailStyleEnabled{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kWDCommonWDDetailStyleKey];
}

static NSString *const kWDCommonWDDetailNewPushKey = @"kWDCommonWDDetailNewPushKey";
+ (void)setWDNewDetailNewPushDisabled:(BOOL)enabled{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kWDCommonWDDetailNewPushKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isWDNewDetailNewPushDisabled{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kWDCommonWDDetailNewPushKey];
}
@end

@implementation WDCommonLogic (WDNatantNewStyleEnable)

NSString * const WDCommonLogicNatantNewStyleEnable = @"kWDCommonLogicNatantNewStyleEnable";

+ (void)setWDDetailNatantNewStyleEnable:(BOOL)enabled
{
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:WDCommonLogicNatantNewStyleEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isWDDetailNatantNewStyleEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:WDCommonLogicNatantNewStyleEnable];
}

@end


@implementation WDCommonLogic (channelShowAddFristPage)

static NSString *const kSSChannelShowAddFristPageKey = @"kSSChannelShowAddFristPageKey";
+ (void)setChannelAddFristPageEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kSSChannelShowAddFristPageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (BOOL)isChannelAddFristPageEnabled {
    BOOL isEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kSSChannelShowAddFristPageKey];
    return isEnabled;
}
@end



@implementation WDCommonLogic (hasCloseAddToFirstPageCell)

#define AddToFirstPageCellCloseDays    7 * 24 * 3600   //7天
NSString *const hasCloseAddToFirstPageCell = @"hasCloseAddToFirstPageCell";

+ (BOOL)shouldShowAddToFirstPageCell {
    
    if ([[NSUserDefaults standardUserDefaults] floatForKey:hasCloseAddToFirstPageCell]) {
        
        //一周后又重新开启
        NSTimeInterval closeTime = [[NSUserDefaults standardUserDefaults] floatForKey:hasCloseAddToFirstPageCell];
        NSTimeInterval openTime = closeTime +  AddToFirstPageCellCloseDays;
        NSDate *openDate = [NSDate dateWithTimeIntervalSince1970:openTime];
        
        return ([[NSDate date] earlierDate:openDate] == openDate);
        
    }
    
    return YES;
}

+ (void)closeAddToFirstPageCell:(BOOL)close {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    if (!close) {
        currentTime -= AddToFirstPageCellCloseDays;
    }
    [[NSUserDefaults standardUserDefaults] setFloat:currentTime forKey:hasCloseAddToFirstPageCell];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
@implementation WDCommonLogic (WDBrandTransform)

static NSString * const WDCommonLogicWukongURL = @"kWDCommonLogicWukongURL";

+ (void)setWukongURL:(NSString *)urlString
{
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:WDCommonLogicWukongURL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)wukongURL
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:WDCommonLogicWukongURL];
}

@end

@implementation WDCommonLogic (WDDetailReportStyle)

static NSString * const WDDetailRelatedReportStyle = @"kDetailRelatedReportStyle";

+ (void)setRelatedReportStyle:(NSNumber *)style
{
    [[NSUserDefaults standardUserDefaults] setObject:style forKey:WDDetailRelatedReportStyle];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (WDDetailReportStyle)relatedReportStyle
{
    return ((WDDetailReportStyle)[[NSUserDefaults standardUserDefaults] integerForKey:WDDetailRelatedReportStyle]);
}

@end

@implementation WDCommonLogic (WDDetailShowType)

static NSString * const WDDetailShowSlideTypeKey = @"WDDetailShowSlideTypeKey";

+ (void)setAnswerDetailShowSlideType:(NSInteger)showSlideType
{
    [[NSUserDefaults standardUserDefaults] setInteger:showSlideType forKey:WDDetailShowSlideTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSInteger)answerDetailShowSlideType
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:WDDetailShowSlideTypeKey];
}

@end

@implementation WDCommonLogic (WDDetailSlide)

static NSString * const kNoNeedDisplaySlideHelpKey =   @"kNoNeedDisplaySlideHelpKey";
static NSString * const kDisplaySlideHelpTimeKey =    @"kDisplaySlideHelpTimeKey";
static NSString * const kDisplayListSlideHelpTimeKey =   @"kDisplayListSlideHelpTimeKey";

+ (BOOL)noNeedDisplaySlideHelp
{
    BOOL noNeed =  [[[NSUserDefaults standardUserDefaults] objectForKey:kNoNeedDisplaySlideHelpKey] boolValue];
    int time = [[[NSUserDefaults standardUserDefaults] objectForKey:kDisplaySlideHelpTimeKey] intValue];
    return noNeed || time >= 1;
}

+ (void)increaseSlideDisplayHelp
{
    int time = [[[NSUserDefaults standardUserDefaults] objectForKey:kDisplaySlideHelpTimeKey] intValue];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:time + 1] forKey:kDisplaySlideHelpTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setNoNeedDisplaySlideHelp:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:kNoNeedDisplaySlideHelpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation WDCommonLogic (CommentDraft)

NSString * const WDCommonLogicCommentDraftCacheKey = @"WDCommonLogicCommentDraftCacheKey";
NSString * const WDCommonLogicSaveForwordStatusCacheKey = @"WDCommonLogicSaveForwordStatusCacheKey";

+ (void)setDraft:(NSDictionary *)draft forType:(WDCommentType)type {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSObject *cachedValue = [userDefaults valueForKey:WDCommonLogicCommentDraftCacheKey];
    NSMutableDictionary *drafts = nil;
    if ([cachedValue isKindOfClass:[NSDictionary class]]) {
        drafts = [cachedValue mutableCopy];
    } else {
        drafts = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    NSString *key = [NSString stringWithFormat:@"%ld", (long)type];
    [drafts setValue:draft forKey:key];
    [userDefaults setValue:drafts forKey:WDCommonLogicCommentDraftCacheKey];
    [userDefaults synchronize];
}

+ (NSDictionary *)draftForType:(WDCommentType)type {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)type];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *cachedValue = [userDefaults valueForKey:WDCommonLogicCommentDraftCacheKey];
    if ([cachedValue isKindOfClass:[NSDictionary class]]) {
        return [cachedValue valueForKey:key];
    }
    return nil;
}

+ (void)cleanDrafts {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:nil forKey:WDCommonLogicCommentDraftCacheKey];
    [userDefaults synchronize];
}

+ (void)setSaveForwordStatusEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:WDCommonLogicSaveForwordStatusCacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)saveForwordStatusEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:WDCommonLogicSaveForwordStatusCacheKey];
}

//评论/转发/回复时，如果输入框内容为空，出一条提示，此提示由服务端控制
+ (NSString *)commentInputViewPlaceHolder {
    NSString * placeHolder = [[NSUserDefaults standardUserDefaults] stringForKey:@"kCommentInputViewPlaceHolder"];
    if (![placeHolder isKindOfClass:[NSString class]] || placeHolder.length==0) {
        placeHolder = @"";
    }
    return placeHolder;
}

@end

@implementation WDCommonLogic (ShareTemplate)

+ (NSString *)parseShareContentWithTemplate:(NSString *)templateString title:(NSString *)t shareURLString:(NSString *)urlString
{
    if (isEmptyString(templateString)) {
        return nil;
    }
    
    @try {
        NSString * dealString = templateString;
        
        NSMutableString * resultString = [NSMutableString stringWithCapacity:50];
        
        NSString * patternStr = @"\\{.*?\\}";
        NSError *tError = nil;
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:patternStr options:NSRegularExpressionCaseInsensitive error:&tError];
        
        int replacedCount = 0;
        while (replacedCount < 30) {
            replacedCount ++;
            NSRange matchRange = [regex rangeOfFirstMatchInString:dealString options:0 range:NSMakeRange(0, [dealString length])];
            if (matchRange.location == NSNotFound) {
                [resultString appendString:dealString];
                break;
            }
            [resultString appendString:[dealString substringToIndex:matchRange.location]];
            
            NSString * subStr = [dealString substringWithRange:matchRange];
            if (subStr != nil) {
                NSArray * ary = nil;
                if ([subStr length] >= 3) {
                    NSString * tempStr = [subStr substringWithRange:NSMakeRange(1, [subStr length] - 2)];
                    ary = [tempStr componentsSeparatedByString:@":"];
                }
                NSString * replaceString = nil;
                if ([ary count] == 1) {
                    if ([((NSString *)[ary objectAtIndex:0]) isEqualToString:@"share_url"]) {
                        replaceString = urlString;
                    }
                    else if ([((NSString *)[ary objectAtIndex:0]) isEqualToString:@"title"]) {
                        replaceString = t;
                    }
                    
                }
                else if ([ary count] == 2) {
                    
                    NSString * tmpStr = nil;
                    
                    if ([((NSString *)[ary objectAtIndex:0]) isEqualToString:@"title"]) {
                        tmpStr = t;
                    }
                    else if ([((NSString *)[ary objectAtIndex:0]) isEqualToString:@"share_url"]) {
                        tmpStr = urlString;
                    }
                    
                    int length = [[ary objectAtIndex:1] intValue];
                    
                    if ([tmpStr length] <= length) {
                        replaceString = tmpStr;
                    }
                    else {
                        replaceString = [tmpStr substringToIndex:length];
                    }
                }
                [resultString appendString:replaceString];
                if ((matchRange.location + matchRange.length) < [dealString length]) {
                    dealString = [dealString substringFromIndex:matchRange.location + matchRange.length];
                }
                else {
                    break;
                }
                
            }
        }
        
        return resultString;
        
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (void)saveShareTemplate:(NSDictionary *)dict
{
    if (dict == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kShareTemplatesKey"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"kShareTemplatesKey"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)getShareTemplate
{
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShareTemplatesKey"];
    return dict;
}

@end


@implementation WDCommonLogic (TipGesture)

// 5.4中 控制显示 详情页右滑返回的 tip
+ (BOOL)showGestureTip {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"SSCommonLogicSettingTipGestureShowKey"]) {
        return [[userDefaults objectForKey:@"SSCommonLogicSettingTipGestureShowKey"] boolValue];
    }
    // 默认关
    return NO;
}

+ (void)setShowGestureTip:(BOOL)showGestureTip {
    [[NSUserDefaults standardUserDefaults] setValue:@(showGestureTip) forKey:@"SSCommonLogicSettingTipGestureShowKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end


@implementation WDCommonLogic (Author)

+ (void)setH5SettingsForAuthor:(NSDictionary *)settings {
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:@"h5Settings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)fetchH5SettingsForAuthor {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"h5Settings"];
}

@end

static BOOL _transitonAnimationEnable = NO;
@implementation WDCommonLogic (TransitonAnimationEnable)
+ (void)setTransitionAnimationEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:@"KSSCommonLogicTransitionAnimationEnableKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)transitionAnimationEnable {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _transitonAnimationEnable = [[NSUserDefaults standardUserDefaults] boolForKey:@"KSSCommonLogicTransitionAnimationEnableKey"];
    });
    return _transitonAnimationEnable;
}
@end

@implementation WDCommonLogic (UserVerifyConfig)
+ (void)setUserVerifyConfigs:(NSDictionary *)configs
{
    if (SSIsEmptyDictionary(configs)) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:configs forKey:@"kSSCommonLogicUserVerifyConfigKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)userVerifyConfigs
{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kSSCommonLogicUserVerifyConfigKey"];
}

+ (NSDictionary *)userVerifyIconModelConfigs {
    static NSMutableDictionary *iconModelConfigs;
    NSDictionary *userVerifyConfigs = [[self class] userVerifyConfigs];
    if (!SSIsEmptyDictionary(userVerifyConfigs)) {
        NSArray<NSDictionary *> *configArray = [userVerifyConfigs tt_arrayValueForKey:@"type_config"];
        if (!SSIsEmptyArray(configArray)) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                iconModelConfigs = [NSMutableDictionary dictionaryWithCapacity:2];
                [configArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (!SSIsEmptyDictionary(obj)) {
                        NSString *type = [obj tt_stringValueForKey:@"type"];
                        NSString *url = [obj tt_stringValueForKey:@"url"];
                        NSDictionary *avatarIcon = [obj tt_dictionaryValueForKey:@"avatar_icon"];
                        NSDictionary *labelIcon = [obj tt_dictionaryValueForKey:@"label_icon"];
                        iconModelConfigs[type] = @{
                                                   @"avatar_icon" : avatarIcon,
                                                   @"label_icon" : labelIcon,
                                                   @"url" : url
                                                   };
                    }
                }];
            });
        }
    }
    
    return [iconModelConfigs copy];
}

+ (NSDictionary *)userVerifyLabelIconModelOfType:(NSString *)type {
    if (isEmptyString(type)) {
        return nil;
    }
    
    NSDictionary *configs = [[self class] userVerifyIconModelConfigs];
    NSDictionary *config = [configs tt_dictionaryValueForKey:type];
    if (SSIsEmptyDictionary(config)) {
        return nil;
    }
    NSDictionary *labelIconModel = [config tt_dictionaryValueForKey:@"label_icon"];
    if (SSIsEmptyDictionary(labelIconModel)) {
        return nil;
    }
    
    return labelIconModel;
}

+ (NSDictionary *)userVerifyAvatarIconModelOfType:(NSString *)type {
    if (isEmptyString(type)) {
        return nil;
    }
    
    NSDictionary *configs = [[self class] userVerifyIconModelConfigs];
    NSDictionary *config = [configs tt_dictionaryValueForKey:type];
    if (SSIsEmptyDictionary(config)) {
        return nil;
    }
    NSDictionary *avatarIconModel = [config tt_dictionaryValueForKey:@"avatar_icon"];
    if (SSIsEmptyDictionary(avatarIconModel)) {
        return nil;
    }
    
    return avatarIconModel;
}

+ (NSArray<NSString *> *)userVerifyFeedShowArray
{
    NSDictionary *userVerifyConfigs = [[self class] userVerifyConfigs];
    if (!SSIsEmptyDictionary(userVerifyConfigs)) {
        return [userVerifyConfigs tt_arrayValueForKey:@"feed_show_type"];
    }
    
    return nil;
}
@end


@implementation WDCommonLogic (UGCMedals)

+ (void)setUGCMedalsWithDictionay:(NSDictionary *)dictionary {
    [[NSUserDefaults standardUserDefaults] setObject:dictionary forKey:@"kSScommonLogicUGCMedalsNameKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)ugcMedals {
    static NSDictionary *medalWeitoutiao = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *weitoutiaoDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSScommonLogicUGCMedalsNameKey"];
        if ([weitoutiaoDict isKindOfClass:[NSDictionary class]]) {
            medalWeitoutiao = weitoutiaoDict;
        }
    });
    return medalWeitoutiao;
}

@end

@implementation WDCommonLogic (PullRefresh)

+ (void)setNewPullRefreshEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"pull_refresh_new_enabled"];
}

+ (BOOL)isNewPullRefreshEnabled {
    static BOOL bEnabled;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"pull_refresh_new_enabled"];
    });
    return bEnabled;
}

+ (CGFloat)articleNotifyBarHeight {
    if ([WDCommonLogic isNewPullRefreshEnabled]) {
        return 40.0;
    } else {
        return 32.0;
    }
}

@end

@implementation WDCommonLogic (ImageHost)

#pragma mark - 是否头条下发的图片

+ (NSString *)toutiaoImageHost
{
    return @"pstatp.com";
}

+ (void)setToutiaoImageHost:(NSString *)host
{
   
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

@implementation WDCommonLogic (Answer)

static NSString *const kWDCommonLogicAnswerReadPositionEnable = @"WDCommonLogicAnswerReadPositionEnable";

+ (void)setAnswerReadPositionEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kWDCommonLogicAnswerReadPositionEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)answerReadPositionEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kWDCommonLogicAnswerReadPositionEnable];
}

@end

@implementation WDCommonLogic (MessageNewStyle)

static NSString *const kWDCommonLogicMessageNewStyleKey = @"WDCommonLogicMessageNewStyleKey";

+ (void)setWDMessageDislikeNewStyle:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:kWDCommonLogicMessageNewStyleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isWDMessageDislikeNewStyle
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kWDCommonLogicMessageNewStyleKey];
}

@end

