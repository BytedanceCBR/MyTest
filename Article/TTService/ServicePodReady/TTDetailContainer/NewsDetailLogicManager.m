//
//  NewsDetailLogicManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-10-28.
//
//

#import "NewsDetailLogicManager.h"
#import "TTArticleCategoryManager.h"
#import <TTUIWidget/TTThemedAlertController.h>

#import <TTUserSettings/TTUserSettingsManager+NetworkTraffic.h>
#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import <TTBaseLib/NetworkUtilities.h>

static NewsDetailLogicManager * shareManager;

@interface NewsDetailLogicManager()<UIAlertViewDelegate>

@end

@implementation NewsDetailLogicManager

+ (NewsDetailLogicManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[NewsDetailLogicManager alloc] init];
    });
    return shareManager;
}

+ (NSString *)mainCategoryIDStr
{
    return kTTMainCategoryID;
}

+ (NSString *)changegCooperationWapURL:(NSString *)originalURL
{
    if (isEmptyString(originalURL)) {
        return nil;
    }
    NSMutableString * tmpWebURLString = [NSMutableString stringWithString:originalURL];
        
    BOOL hasHash = YES;
    
    if ([tmpWebURLString rangeOfString:@"#"].location == NSNotFound) {
        hasHash = NO;
    }
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    if (hasHash) {
        [tmpWebURLString appendFormat:@"&tt_daymode=%d", isDayModel ? 1 : 0];
    }
    else {
        [tmpWebURLString appendFormat:@"#tt_daymode=%d", isDayModel ? 1 : 0];
    }
    
    NSString *fontSizeType = [TTUserSettingsManager settingFontSizeString];
    [tmpWebURLString appendFormat:@"&tt_font=%@", fontSizeType];
    
    TTNetworkTrafficSetting netSettingType = [TTUserSettingsManager networkTrafficSetting];
    BOOL noImgShow = (!TTNetworkWifiConnected() && netSettingType == TTNetworkTrafficSave);
    [tmpWebURLString appendFormat:@"&tt_image=%d", noImgShow ? 0 : 1];
    
    [tmpWebURLString appendString:@"&tt_from=app"];
        
    return tmpWebURLString;
}

//无法区分频道进入
+ (NewsGoDetailFromSource)fromSourceByString:(NSString *)string
{
    NewsGoDetailFromSource source = NewsGoDetailFromSourceUnknow;
    if ([string isEqualToString:@"click_headline"]) {
        source = NewsGoDetailFromSourceHeadline;
    }
    else if ([string isEqualToString:@"click_category"]) {
        source = NewsGoDetailFromSourceCategory;
    }
    else if ([string isEqualToString:@"click_apn"]) {
        source = NewsGoDetailFromSourceAPNS;
    }
    else if ([string isEqualToString:@"click_news_alert"]) {
        source = NewsGoDetailFromSourceAPNSInAppAlert;
    }
    else if ([string isEqualToString:@"click_update"]) {
        source = NewsGoDetailFromSourceUpate;
    }
    else if ([string isEqualToString:@"click_search"]) {
        source = NewsGoDetailFromSourceSearch;
    }
    else if ([string isEqualToString:@"click_related"]) {
        source = NewsGoDetailFromSourceRelateReading;
    }
    else if ([string isEqualToString:@"click_album"]) {
        source = NewsGoDetailFromSourceVideoAlbum;
    }
    else if ([string isEqualToString:@"click_hot_comment"]) {
        source = NewsGoDetailFromSourceHotComment;
    }
    else if ([string isEqualToString:@"click_favorite"]) {
        source = NewsGoDetailFromSourceFavorite;
    }
    else if ([string isEqualToString:@"click_pgc_list"]) {
        source = NewsGoDetailFromSourceClickPGCList;
    }
    else if ([string isEqualToString:@"click_update_pgc"]) {
        source = NewsGoDetailFromSourceClickUpdatePGC;
    }
    else if ([string isEqualToString:@"click_subject"]) {
        source = NewsGoDetailFromSourceSubject;
    }
    else if ([string isEqualToString:@"click_activity"]) {
        source = NewsGoDetailFromSourceActivity;
    }
    else if ([string isEqualToString:@"click_update_detail"]) {
        source = NewsGoDetailFromSourceUpdateDetail;
    }
    else if ([string isEqualToString:@"click_profile"]) {
        source = NewsGoDetailFromSourceProfile;
    }
    else if ([string isEqualToString:@"click_notification"]) {
        source = NewsGoDetailFromSourceNotification;
    }
    else if ([string isEqualToString:@"click_today_extenstion"]) {
        source = NewsGoDetailFromSourceClickTodayExtenstion;
    }
    else if ([string isEqualToString:@"other_app"]) {
        source = NewsGoDetailFromSourceOtherApp;
    }  else if ([string isEqualToString:@"click_search_wap"]) {
        source = NewsGoDetailFromSourceClickWapSearchResult;
    }
    else if ([string isEqualToString:@"click_spotlight"]) {
        source = NewsGoDetailFromSourceSpotlightSearchResult;
    }
    else {
        NSString *lowerCaseString = [string lowercaseString];
        if ([lowerCaseString rangeOfString:@"weixin"].location != NSNotFound || [lowerCaseString rangeOfString:@"qq"].location != NSNotFound || [lowerCaseString rangeOfString:@"tencent"].location != NSNotFound) {
            source = NewsGoDetailFromSourceOtherApp;
        }
    }
    return source;
}

+ (NSString *)enterFromValueForLogV3WithClickLabel:(NSString *)clickLabel categoryID:(NSString *)categoryID
{
    //ugly code: 兼容
    //推送进入时categoryID可能传预期以外的非空值，暂时针对这种case加兼容
    if ([clickLabel isEqualToString:@"click_news_alert"]) {
        return clickLabel;
    } else if ([clickLabel isEqualToString:@"click_apn"]) {
        return @"click_news_notify";
    }
    
    //小说详情页各入口，因为enter_from定义非常恶心，拎出来特殊处理
    if ([clickLabel isEqualToString:@"click_novel_channel"]) {
        //小说频道直接进入详情页
        return @"click_category";
    }
    else if ([clickLabel isEqualToString:@"click_bookshelf"] ||
             [clickLabel isEqualToString:@"click_category_novel"] ||
             [clickLabel isEqualToString:@"click_next_group"] ||
             [clickLabel isEqualToString:@"click_pre_group"]) {
        //我的书架，目录页，上一章下一章
        return clickLabel;
    }
    
    //categoryID非空表示从feed进入
    if (isEmptyString(categoryID) || [categoryID isEqualToString:@"xx"]) {
        if ([clickLabel isEqualToString:@"click_apn"]) {
            return @"click_news_notify";
        }
        else {
            return clickLabel;
        }
    }
    else {
        if ([categoryID isEqualToString:kTTMainCategoryID] ||
            [clickLabel isEqualToString:@"click_headline"]) {
            return clickLabel;
        }
        else {
            return @"click_category";
        }
    }
    return clickLabel;
}

+ (NSString *)articleDetailEventLabelForSource:(NewsGoDetailFromSource)source categoryID:(NSString *)categoryID;
{
    NSString * eventLabel = nil;
    switch (source) {
        case NewsGoDetailFromSourceUnknow:
        {
            //do nothing...
            eventLabel = @"";
        }
            break;
        case NewsGoDetailFromSourceHeadline:
        {
            eventLabel = @"click_headline";
        }
            break;
        case NewsGoDetailFromSourceCategory:
        case NewsGoDetailFromSourceVideoFloat:
        {
            if (!isEmptyString(categoryID)) {
                if ([categoryID isEqualToString:[self mainCategoryIDStr]]) {
                    eventLabel = @"click_headline";
                }
                else {
                    eventLabel = [NSString stringWithFormat:@"click_%@", categoryID];
                }
            }
            else {
                eventLabel = @"click_category";
                SSLog(@"articleDetailEventLabelForSource method error");
            }
            
        }
            break;
        case NewsGoDetailFromSourceAPNS:
        {
            eventLabel = @"click_apn";
        }
            break;
        case NewsGoDetailFromSourceAPNSInAppAlert:
        {
            eventLabel = @"click_news_alert";
        }
            break;
        case NewsGoDetailFromSourceUpate:
        {
            eventLabel = @"click_update";
        }
            break;
        case NewsGoDetailFromSourceSearch:
        {
            eventLabel = @"click_search";
        }
            break;
        case NewsGoDetailFromSourceRelateReading:
        {
            eventLabel = @"click_related";
        }
            break;
        case NewsGoDetailFromSourceVideoAlbum:
        {
            eventLabel = @"click_album";
        }
            break;
        case NewsGoDetailFromSourceHotComment:
        {
            eventLabel = @"click_hot_comment";
        }
            break;
        case NewsGoDetailFromSourceFavorite:
        {
            eventLabel = @"click_favorite";
        }
            break;
        case NewsGoDetailFromSourceClickPGCList:
        {
            eventLabel = @"click_pgc_list";
        }
            break;
        case NewsGoDetailFromSourceClickUpdatePGC:
        {
            eventLabel = @"click_update_pgc";
        }
            break;
        case NewsGoDetailFromSourceSubject:
        {
            eventLabel = @"click_subject";
        }
            break;
        case NewsGoDetailFromSourceActivity:
        {
            eventLabel = @"click_activity";
        }
            break;
        case NewsGoDetailFromSourceUpdateDetail:
        {
            eventLabel = @"click_update_detail";
        }
            break;
        case NewsGoDetailFromSourceProfile:
        {
            eventLabel = @"click_profile";
        }
            break;
        case NewsGoDetailFromSourceNotification:
        {
            eventLabel = @"click_notification";
        }
            break;
        case NewsGoDetailFromSourceClickTodayExtenstion:
        {
            eventLabel = @"click_today_extenstion";
        }
            break;
        case NewsGoDetailFromSourceOtherApp:
        {
            eventLabel = @"other_app";
        }
            break;
        case NewsGoDetailFromSourceClickWapSearchResult:
            eventLabel = @"click_search_wap";
            break;
        case NewsGoDetailFromSourceSpotlightSearchResult:
        {
            //do nothing...
            eventLabel = @"click_spotlight";
        }
            break;
        case NewsGoDetailFromSourceVideoFloatRelated:
        {
            eventLabel = @"click_related";
        }
            break;
        case NewsGoDetailFromSourceReadHistory:
        {
            eventLabel = @"click_read_history";
        }
            break;
        case NewsGoDetailFromSourcePushHistory:
        {
            eventLabel = @"click_push_history";
        }
            break;
        default:
            break;
    }
    return eventLabel;
}

#pragma mark -- track
+ (void)trackEventTag:(NSString *)t label:(NSString *)l value:(NSNumber *)v extValue:(NSNumber *)eValue fromID:(NSNumber *)fromID params:(NSDictionary *)params groupModel:(TTGroupModel *)groupModel {
    [self trackEventTag:t label:l value:v extValue:eValue fromID:fromID adID:nil params:params groupModel:groupModel];
}

+ (void)trackEventTag:(NSString *)t label:(NSString *)l value:(NSNumber *)v extValue:(NSNumber *)eValue fromID:(NSNumber *)fromID adID:(NSNumber *)adID params:(NSDictionary *)params groupModel:(TTGroupModel *)groupModel{
    NSString * value = nil;
    if ([v longLongValue] != 0) {
        value = [NSString stringWithFormat:@"%@", v];
    }
    
    NSString * extValue = nil;
    if ([eValue longLongValue] != 0) {
        extValue = [NSString stringWithFormat:@"%@", eValue];
    }
    
    [self trackEventCategory:@"umeng" tag:t label:l value:value extValue:extValue fromGID:fromID adID:adID params:params groupModel:groupModel];
}

//category 为umeng
+ (void)trackEventTag:(NSString *)t label:(NSString *)l value:(NSNumber *)v extValue:(NSNumber *)eValue  groupModel:(TTGroupModel *)groupModel {
    [self trackEventTag:t label:l value:v extValue:eValue adID:nil groupModel:groupModel];
}

+ (void)trackEventTag:(NSString *)t label:(NSString *)l value:(NSNumber *)v extValue:(NSNumber *)eValue adID:(NSNumber *)adID groupModel:(TTGroupModel *)groupModel{
    [self trackEventTag:t label:l value:v extValue:eValue fromID:nil adID:adID params:nil groupModel:groupModel];
}

+ (void)trackEventCategory:(NSString *)c tag:(NSString *)t label:(NSString *)l value:(NSString *)v extValue:(NSString *)eValue groupModel:(TTGroupModel *)groupModel {
    [self trackEventCategory:c tag:t label:l value:v extValue:eValue fromGID:nil adID:nil groupModel:groupModel];
}

+ (void)trackEventCategory:(NSString *)c tag:(NSString *)t label:(NSString *)l value:(NSString *)v extValue:(NSString *)eValue fromGID:(NSNumber *)fromGID adID:(NSNumber *)adID groupModel:(TTGroupModel *)groupModel{
    [self trackEventCategory:c tag:t label:l value:v extValue:eValue fromGID:fromGID adID:adID params:nil groupModel:groupModel];
}

+ (void)trackEventCategory:(NSString *)c tag:(NSString *)t label:(NSString *)l value:(NSString *)v extValue:(NSString *)eValue fromGID:(NSNumber *)fromGID adID:(NSNumber *)adID params:(NSDictionary *)params groupModel:(TTGroupModel *)groupModel {
    NSMutableDictionary * dict;
    if ([params isKindOfClass:[NSDictionary class]]) {
        dict = [NSMutableDictionary dictionaryWithDictionary:params];
    } else {
       dict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    [dict setValue:c forKey:@"category"];
    [dict setValue:t forKey:@"tag"];
    [dict setValue:l forKey:@"label"];
    if (!isEmptyString(groupModel.itemID)) {
        if ([dict objectForKey:@"item_id"] == nil) {
            [dict setValue:groupModel.itemID forKey:@"item_id"];
        }
        [dict setValue:@(groupModel.aggrType) forKey:@"aggr_type"];
    }
    [dict setValue:v forKey:@"value"];
    [dict setValue:eValue forKey:@"ext_value"];
    [dict setValue:fromGID forKey:@"from_gid"];
    if (adID.longLongValue > 0) {
        [dict setValue:adID forKey:@"ad_id"];
    }
    [TTTrackerWrapper eventData:dict];
}

@end
