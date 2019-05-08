//
//  FHURLSettings.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHURLSettings.h"

extern NSString * baseUrl(void);
extern NSString* SNSBaseURL(void);
extern NSString* securityURL(void);
extern NSArray *baseUrlMapping(void);
extern NSString * logBaseURL(void);


@implementation FHURLSettings


+ (NSString *)articleEntryListURLString
{
    return [NSString stringWithFormat:@"%@/entry/list/v1/", [self baseURL]];
}

+ (NSString*)articleItemActionURLString
{
    return [NSString stringWithFormat:@"%@/2/article/item_action/", [self baseURL]];
}

+ (NSString*)recentURLString
{
    /// API 16 增加了Feed流中淘宝SDK的广告。以前是 v15
    return [NSString stringWithFormat:@"%@/2/article/v%@/stream/", [self baseURL], [self streamAPIVersionString]];
}

+ (NSString *)encrpytionStreamUrlString{
    return [NSString stringWithFormat:@"%@/api/news/feed/v%@/", [self baseURL], [self streamAPIVersionString]];
}

+ (NSString *)movieCommentVideoTabURLString
{
    return[NSString stringWithFormat:@"%@/vertical/movie/1/video/get_mov_video",[self baseURL]];
}

+ (NSString *)movieCommentEntireTabURLString
{
    return[NSString stringWithFormat:@"%@/2/article/v%@/stream/", [self baseURL], [self streamAPIVersionString]];
}

+ (NSString *)verticalVideoURLString
{
    return[NSString stringWithFormat:@"%@/vertical/video/1/",[self baseURL]];
}

+ (NSString *)detailCDNAPIVersionString
{
    return @"19";
}

+ (NSString *)detailFullPathString {
    return @"/article/full/";
}

+ (NSString *)detailContentPathString
{
    return @"/article/content/";
}

+ (NSString *)detailPaidNovelFullURLString {
    return [NSString stringWithFormat:@"%@/article/p_full/", [self baseURL]];
}

+ (NSString *)detailPaidNovelContentURLString {
    return [NSString stringWithFormat:@"%@/article/p_content/", [self baseURL]];
}

+ (NSString *)refreshTipURLString
{
    return [NSString stringWithFormat:@"%@/2/article/v%@/refresh_tip/", [self baseURL], [self streamAPIVersionString]];
}

+ (NSString*)getFavoritesURLString
{
    return [NSString stringWithFormat:@"%@/2/data/v%@/favorites/", [self SNSBaseURL], [self streamAPIVersionString]];
}

+ (NSString*)getHistoryURLString {
    return [NSString stringWithFormat:@"%@/2/data/v%@/history/list", [self SNSBaseURL], [self streamAPIVersionString]];
}

+ (NSString*)deleteHistoryURLString {
    return [NSString stringWithFormat:@"%@/2/data/v%@/history/delete", [self SNSBaseURL], [self streamAPIVersionString]];
}

+ (NSString*)searchURLString
{
    return [NSString stringWithFormat:@"%@/2/article/v%@/search/", [self baseURL], [self streamAPIVersionString]];
}

+ (NSString*)findWebURLString {
    return [NSString stringWithFormat:@"%@/discover/wap/discover_page/", [self baseURL]];
}

+ (NSString*)searchWebURLString {
    return [NSString stringWithFormat:@"%@/2/wap/search/", [self baseURL]];
}

+ (NSString *)searchInitialPageURLString {
    return [NSString stringWithFormat:@"%@/search/suggest/wap/initial_page/", [self baseURL]];
}

+ (NSString *) searchSuggestionURLString {
    return [NSString stringWithFormat:@"%@/2/article/search_sug/", [self baseURL]];
}

+ (NSString*)hotCommentURLString
{
    return [NSString stringWithFormat:@"%@/2/article/v10/hot_comments/", [self baseURL]];
}

+ (NSString*)recommendForumURLString
{
    return [NSString stringWithFormat:@"%@/ttdiscuss/comment/recommendforum/", [self baseURL]];
}

//https://wiki.bytedance.net/pages/viewpage.action?title=information%20API&spaceKey=TTRD
+ (NSString *)newArticleInfoString
{
    return [NSString stringWithFormat:@"%@/2/article/information/v23/", [self baseURL]];
}


+ (NSString*)cityURLString
{
    return [NSString stringWithFormat:@"%@/2/article/city/", [self baseURL]];
}

+ (NSString*)essayDetailURLString
{
    return [NSString stringWithFormat:@"%@/2/essay/detail/v10/", [self baseURL]];
}

#pragma mark -- PGC

+ (NSString *)fetchEntryURLString
{
    return [NSString stringWithFormat:@"%@/entry/profile/v1/", [self baseURL]];
}

+ (NSString *)PGCProfileURLString
{
    return [NSString stringWithFormat:@"%@/2/pgc/profile/", [self SNSBaseURL]];
}

+ (NSString *)PGCArticleURLString
{
    return [NSString stringWithFormat:@"%@/2/pgc/articles/", [self SNSBaseURL]];
}

+ (NSString *)PGCStatisticsURLString
{
    return [NSString stringWithFormat:@"%@/2/auth/redirect/?next=https://mp.toutiao.com/", [self SNSBaseURL]];
}

+ (NSString *)PGCLikeUserURLString
{
    return [NSString stringWithFormat:@"%@/2/pgc/like_list/", [self SNSBaseURL]];
}

+ (NSString*)momentListURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/list/v8/", [self SNSBaseURL]];
}

+ (NSString*)momentUpdateNumberURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/update/v2/", [self baseURL]];
}


+ (NSString*)momentDetailListURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/detail_list/v6/", [self baseURL]];
}

+ (NSString*)momentDetailURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/detail/v7/", [self baseURL]];
}

+ (NSString*)momentDetailURLStringV8
{
    return [NSString stringWithFormat:@"%@/dongtai/detail/v8/", [self baseURL]];
}

+ (NSString*)commentDetailURLString
{
    return [NSString stringWithFormat:@"%@/2/comment/v1/detail/", [self baseURL]];
}

+ (NSString*)momentDiggedUsersURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/digg/list/", [self baseURL]];
}

+ (NSString*)postReplyedCommentURLString
{
    return [NSString stringWithFormat:@"%@/2/comment/v3/create_reply/", [self baseURL]];
}

+ (NSString*)commentDiggedUsersURLString
{
    return [NSString stringWithFormat:@"%@/2/comment/v1/digg_list/", [self baseURL]];
}

+ (NSString*)replyedCommentListURLString
{
    return [NSString stringWithFormat:@"%@/2/comment/v1/reply_list/", [self baseURL]];
}

+ (NSString*)replyedCommentDigURLString
{
    return [NSString stringWithFormat:@"%@/2/comment/v1/digg_reply/", [self baseURL]];
}

+ (NSString*)deleteReplyedCommentURLString
{
    return [NSString stringWithFormat:@"%@/2/comment/v1/delete_reply/", [self baseURL]];
}

+ (NSString*)momentCommentURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/comment/list/v3/", [self baseURL]];
}

+ (NSString*)momentCommentURLStringV4
{
    return [NSString stringWithFormat:@"%@/dongtai/comment/list/v4/", [self baseURL]];
}

+ (NSString*)momentPostCommentURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/comment/action/", [self baseURL]];
}

+ (NSString*)momentDiggURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/digg/action/", [self baseURL]];
}

+ (NSString*)momentCancelDiggURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/digg/cancel/", [self baseURL]];
}

+ (NSString*)momentCommentDiggURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/comment/digg/", [self baseURL]];
}

+ (NSString*)followGetUpdateNumberURLString
{
    return [NSString stringWithFormat:@"%@/follow/update/tips/", [self baseURL]];
}

+ (NSString *) HTTPSBaseURL {
    return [[self securityURL] stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
}

+ (NSString*)PRSendCodeURLString
{
    return [NSString stringWithFormat:@"%@/user/mobile/send_code/v2/", [self HTTPSBaseURL]];
}

+ (NSString*)PRRegisterURLString
{
    return [NSString stringWithFormat:@"%@/user/mobile/register/v2/", [self HTTPSBaseURL]];
}

+ (NSString*)PRRefreshCaptchaURLString
{
    return [NSString stringWithFormat:@"%@/user/refresh_captcha/", [self HTTPSBaseURL]];
}

+ (NSString*)PRLoginURLString
{
    return [NSString stringWithFormat:@"%@/user/mobile/login/v2/", [self HTTPSBaseURL]];
}

+ (NSString*)PRMailLoginURLString
{
    return [NSString stringWithFormat:@"%@/user/auth/email_login/",[self HTTPSBaseURL]];
}

+ (NSString*)PRQuickLoginURLString
{
    return [NSString stringWithFormat:@"%@/user/mobile/quick_login/", [self HTTPSBaseURL]];
}

+ (NSString*)PRResetPasswordURLString
{
    NSString *str = [NSString stringWithFormat:@"%@/user/mobile/reset_password/", [self HTTPSBaseURL]];
    //    NSString *result = [str stringByReplacingOccurrencesOfString:@"http" withString:@"https" options:NSCaseInsensitiveSearch range:NSMakeRange(0, str.length)];
    //    return result;
    return str;
}

+ (NSString*)PRChangePasswordURLString
{
    NSString *str =  [NSString stringWithFormat:@"%@/user/mobile/change_password/", [self HTTPSBaseURL]];
    return str;
    //    NSString *result = [str stringByReplacingOccurrencesOfString:@"http" withString:@"https" options:NSCaseInsensitiveSearch range:NSMakeRange(0, str.length)];
    //    return result;
}

+ (NSString*)PRBindPhoneURLString
{
    return [NSString stringWithFormat:@"%@/user/mobile/bind_mobile/v2/", [self HTTPSBaseURL]];
}

+ (NSString*)PRUnbindPhoneURLString
{
    return [NSString stringWithFormat:@"%@/user/mobile/unbind_mobile/", [self HTTPSBaseURL]];
}

+ (NSString*)PRChangePhoneNumberURLString
{
    return [NSString stringWithFormat:@"%@/user/mobile/change_mobile/", [self HTTPSBaseURL]];
}

+ (NSString*)uploadAddressBookURLString
{
    return [NSString stringWithFormat:@"%@/user/contacts/collect/", [self baseURL]];
}

+ (NSString*)uploadAddressBookV2URLString
{
    return [NSString stringWithFormat:@"%@/user/contacts/collect/v2/", [self baseURL]];
}

+ (NSString*)functionExtensionURLString
{
    return [NSString stringWithFormat:@"%@/score_task/v1/user/tabs/", [self baseURL]];
}

+ (NSString*)userProtocolURLString
{
    return [NSString stringWithFormat:@"%@/f100/download/user_agreement.html&title=幸福里用户协议",[self baseURL]];
}

#pragma mark -- 删除

+ (NSString *)deleteMomentURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/delete/", [self SNSBaseURL]];
}

+ (NSString *)deleteArticleCommentURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/group_comment/delete/", [self SNSBaseURL]];
}

+ (NSString *)deleteArticleNewCommentURLString
{
    return [NSString stringWithFormat:@"%@/2/comment/v1/delete_comment/", [self SNSBaseURL]];
}

+ (NSString *)deleteMomentCommentURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/comment/delete/", [self baseURL]];
}

+ (NSString *)forumInfoURLString
{
    return [NSString stringWithFormat:@"%@/forum/info/v2/", [self baseURL]];
}

+ (NSString *)followForumURLString
{
    return [NSString stringWithFormat:@"%@/forum/follow/", [self baseURL]];
}

+ (NSString *)unfollowForumURLString
{
    return [NSString stringWithFormat:@"%@/forum/unfollow/", [self baseURL]];
}

+ (NSString*)myForumWebURLString
{
    return  @"http://i.snssdk.com/forum/user_forums/";
    
}

//start 4.6 加入
+ (NSString*)topicListURLString
{
    return [NSString stringWithFormat:@"%@/forum/feed/", [self baseURL]];
}

+ (NSString*)topicDiscoverString
{
    return [NSString stringWithFormat:@"%@/forum/more/v1/", [self baseURL]];
}

//end
+ (NSString*)discoverNumberURLString
{
    return [NSString stringWithFormat:@"%@/discover/api/icon_status/", [self baseURL]];
}

+ (NSString*)momentAdminURL
{
    return [NSString stringWithFormat:@"http://admin.bytedance.com/siteadmin/forum/talk/operate/?id="];
}

+ (NSString *)toutiaoVideoAPIVersion {
    return @"1";
}

+ (NSString *)mappedUrl:(NSString *)finalUrl
{
    NSArray *mapping = [self urlMapping];
    bool isMapped = NO;
    NSString *mappedOrigin = nil;
    NSString *mappedTarget = nil;
    for (NSDictionary *dic in mapping) {
        NSString *origin = [dic valueForKey:@"origin"];//i.sub
        NSString *target = [dic valueForKey:@"target"];//i.365
        NSString *trimHTTP = [finalUrl lowercaseString];
        
        if ([trimHTTP rangeOfString:@"https://"].location != NSNotFound) {
            trimHTTP = [trimHTTP stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        }
        if ([trimHTTP rangeOfString:@"http://"].location != NSNotFound) {
            trimHTTP = [trimHTTP stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        }
        if ([trimHTTP rangeOfString:origin].location != NSNotFound) {
            isMapped = YES;
            mappedOrigin = origin;
            mappedTarget = target;
            break;
        }
    }
    if (isMapped) {
        return [finalUrl stringByReplacingOccurrencesOfString:mappedOrigin withString:mappedTarget];
    }
    return finalUrl;
}

+ (NSString *)toutiaoVideoAPIURL
{
    NSString *string = [NSString stringWithFormat:@"%@/video/play/%@", [self baseURL], [self toutiaoVideoAPIVersion]];
    string = [self mappedUrl:string];
    return string;
}

+ (NSString *)videoSettingURLString
{
    return [NSString stringWithFormat:@"%@/vapp/settings/v1", [self baseURL]];
}

+ (NSString *)leTVAPIURL
{
    return @"http://api.letvcloud.com/getplayurl.php";
}

// 4.7
+ (NSString *)relatedVideoURL
{
    return [NSString stringWithFormat:@"%@/video_api/related/v1/", [self baseURL]];
}

+ (NSString *)pushSettingURL {
    return [NSString stringWithFormat:@"%@/hint_info/open_push_settings/v1", [self baseURL]];
}

+ (NSString *)moreForumURL {
    return [NSString stringWithFormat:@"%@/ttdiscuss/v1/forum/more/", [self baseURL]];
}

+ (NSString *)concernGuideURL {
    return [NSString stringWithFormat:@"%@/concern/v1/guide/page/", [self baseURL]];
}

// 5.3 个人主页
+ (NSString *)wapProfileURL {
    return [NSString stringWithFormat:@"%@/2/user/wap_profile/", [self baseURL]];
}

//5.4 监控
+ (NSString *)monitorURL {
    return [NSString stringWithFormat:@"%@/monitor/appmonitor/v1/settings", [self logBaseURL]];
}

+ (NSString *)monitorURLForBaseURL:(NSString *)baseUrl{
    return [NSString stringWithFormat:@"%@/monitor/appmonitor/v1/settings", baseUrl];
}
//5.5 我的关注界面
+ (NSString *)myFollowURL{
    return [NSString stringWithFormat:@"%@/concern/v2/follow/list/",[self baseURL]];
}

+ (NSString *)contInfoV2URLString {
    return [NSString stringWithFormat:@"%@/user/profile/count_info/v3/",[self baseURL]];
}

//首页搜索框提示
+ (NSString *)searchPlaceholderTextURLString {
    return [NSString stringWithFormat:@"%@/search/suggest/homepage_suggest/",[self baseURL]];
}

//ugc video 点赞api
+ (NSString *)shortVideoDiggUpURL
{
    return [NSString stringWithFormat:@"%@/ugc/video/v1/digg/digg",[self baseURL]];
}

//shortVideoOriginalData取消点赞api
+ (NSString *)shortVideoCancelDiggURL
{
    return [NSString stringWithFormat:@"%@/ugc/video/v1/digg/cancel",[self baseURL]];
}

+ (NSString *)shortVideoInfoURL
{
    return [NSString stringWithFormat:@"%@/ugc/video/v1/aweme/detail/info/",[self baseURL]];
}

+ (NSString *)shortVideoLoadMoreURL
{
    return [NSString stringWithFormat:@"%@/ugc/video/v1/load_more/video/",[self baseURL]];
}

+ (NSString *)shortVideoActivityListLoadMoreURL
{
    return [NSString stringWithFormat:@"%@/ugc/video/activity/list/v1/",[self baseURL]];
}

//检测App更新
+ (NSString *)checkVersionURL
{
    return [NSString stringWithFormat:@"%@/check_version/v6/",[self baseURL]];
}

//获取推荐好友关注列表接口
+ (NSString *)relationFriendsActivityURLString
{
    return [NSString stringWithFormat:@"%@/user/relation/friends/activity/v1/", [self baseURL]];
}

//获取春节活动分享短链
+ (NSString *)SFShareShotLinkURLString
{
    return [NSString stringWithFormat:@"%@/shorten/", [self baseURL]];
}

//爱看获取收益信息的接口
+ (NSString *)AKProfileBenefitInfo
{
    return [NSString stringWithFormat:@"%@/score_task/v1/user/info/",[self baseURL]];
}

//爱看获取我的页面图片通知的接口
+ (NSString *)AKFetchAlertInfo
{
    return [NSString stringWithFormat:@"%@/score_task/v1/pop_up/get/",[self baseURL]];
}

//爱看获取阅读、观看视频金币
+ (NSString *)AKGetReadBonus
{
    return [NSString stringWithFormat:@"%@/score_task/v1/task/get_read_bonus/",[self baseURL]];
}

#pragma mark -  use toutiao

+(NSString *)baseURL
{
    if (&baseUrl) {
        return baseUrl();
    }
    return @"i.haoduofangs.com";
}

+ (NSString *)streamAPIVersionString
{
    return @"78";
}

+ (NSString*)SNSBaseURL
{
    if (&SNSBaseURL) {
        return SNSBaseURL();
    }
    return @"isub.haoduofangs.com";
}
+ (NSString*)securityURL
{
    if (&securityURL) {
        return securityURL();
    }
    return @"security.haoduofangs.com";
}

+ (NSArray *)urlMapping
{
    if (&baseUrlMapping) {
        return baseUrlMapping();
    }
    return [NSArray array];
}

+(NSString *) logBaseURL
{
    if(&logBaseURL){
        return logBaseURL();
    }
    return @"log.haoduofangs.com";
}

@end
