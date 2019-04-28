//
//  TTVideoCommon.m
//  Article
//
//  Created by 刘廷勇 on 15/11/30.
//
//

#import "TTVideoCommon.h"

extern NSString * const TTActivityContentItemTypeWechat;
extern NSString * const TTActivityContentItemTypeWechatTimeLine;
extern NSString * const TTActivityContentItemTypeQQFriend;
extern NSString * const TTActivityContentItemTypeQQZone;
//extern NSString * const TTActivityContentItemTypeDingTalk;
extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;
extern NSString * const TTActivityContentItemTypeBury;
extern NSString * const TTActivityContentItemTypeDigg;
extern NSString * const TTActivityContentItemTypeFavourite;
extern NSString * const TTActivityContentItemTypeReport;
extern NSString * const TTActivityContentItemTypeMessage;
//extern NSString * const TTActivityContentItemTypeSystem;
//extern NSString * const TTActivityContentItemTypeCopy;
//extern NSString * const TTActivityContentItemTypeEmail;
extern NSString * const TTActivityContentItemTypeCommodity;
extern NSString * const TTActivityContentItemTypeDislike;




@implementation TTVideoCommon

static BOOL isFullScreen;
+ (void) setCurrentFullScreen:(BOOL)isFull{
    isFullScreen = isFull;
}
+ (BOOL) MovieWiewIsFullScreen{
    return isFullScreen;
}

+ (NSString *)PGCOpenURLWithMediaID:(NSString *)mediaID enterType:(NSString *)enterType
{
//    @"sslocal://pgcprofile?uid=%@&page_source=1&gd_ext_json=%@&page_type=0"
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://pgcprofile?media_id=%@&page_source=1&page_type=0&gd_ext_json=%@", mediaID, enterType];
    return urlStr;
}


+ (NSString *)videoListlabelNameForShareActivityType:(TTActivityType)activityType withCategoryId:(NSString *)categoryId
{
    if (activityType == TTActivityTypeEMail) {
        return [NSString stringWithFormat: @"%@_list_email_pop",categoryId];
    }
    else if (activityType == TTActivityTypeMessage) {
        return [NSString stringWithFormat: @"%@_list_sms_pop",categoryId];
    }
    else if (activityType == TTActivityTypeFacebook) {
        return [NSString stringWithFormat: @"%@_list_facebook_pop",categoryId];
    }
    else if (activityType == TTActivityTypeTwitter) {
        return [NSString stringWithFormat: @"%@_list_twitter_pop",categoryId];
    }
    else if (activityType == TTActivityTypeCopy) {
        return [NSString stringWithFormat: @"%@_list_copy_url_pop",categoryId];
    }
    else if (activityType == TTActivityTypeWeixinShare) {
        return [NSString stringWithFormat: @"%@_list_weixin_pop",categoryId];
    }
    else if (activityType == TTActivityTypeWeixinMoment) {
        return [NSString stringWithFormat: @"%@_list_weixin_moments_pop",categoryId];
    }
    else if (activityType == TTActivityTypeSinaWeibo) {
        return [NSString stringWithFormat: @"%@_list_weibo_pop",categoryId];
    }
    else if (activityType == TTActivityTypeQQWeibo) {
        return [NSString stringWithFormat: @"%@_list_tweibo_pop",categoryId];
    }
    else if (activityType == TTActivityTypeQQZone) {
        return [NSString stringWithFormat: @"%@_list_qzone_pop",categoryId];
    }
    else if (activityType == TTActivityTypeKaiXin) {
        return [NSString stringWithFormat: @"%@_list_kaixin_pop",categoryId];
    }
    else if (activityType == TTActivityTypeRenRen) {
        return [NSString stringWithFormat: @"%@_list_renren_pop",categoryId];
    }
    else if (activityType == TTActivityTypeQQShare) {
        return [NSString stringWithFormat: @"%@_list_mobile_qq_pop",categoryId];
    }
    else if (activityType == TTActivityTypeNone) {
        return [NSString stringWithFormat: @"%@_list_share_cancel_button",categoryId];
    }
    else if (activityType == TTActivityTypeShareButton) {
        return [NSString stringWithFormat: @"%@_list_share_button",categoryId];
    }
    else if (activityType == TTActivityTypeZhiFuBao) {
        return [NSString stringWithFormat: @"%@_list_zhifubao_pop",categoryId];
    }
    else if (activityType == TTActivityTypeZhiFuBaoMoment) {
        return [NSString stringWithFormat: @"%@_list_zhifubao_shenghuoquan_pop",categoryId];
    }
    else if (activityType == TTActivityTypeDingTalk) {
        return [NSString stringWithFormat:@"%@_list_dingding_pop", categoryId];
    }
    else if (activityType == TTActivityTypeSystem) {
        return [NSString stringWithFormat: @"%@_list_system_pop",categoryId];
    }
    else {
        return nil;
    }
}

+ (NSString *)videoListlabelNameForShareActivityType:(TTActivityType)activityType
{
    if (activityType == TTActivityTypeEMail) {
        return @"share_email";
    }
    else if (activityType == TTActivityTypeMessage) {
        return @"share_sms";
    }
    else if (activityType == TTActivityTypeFacebook) {
        return @"share_facebook";
    }
    else if (activityType == TTActivityTypeTwitter) {
        return @"share_twitter";
    }
    else if (activityType == TTActivityTypeCopy) {
        return @"share_copy_link";
    }
    else if (activityType == TTActivityTypeWeixinShare) {
        return @"share_weixin";
    }
    else if (activityType == TTActivityTypeWeixinMoment) {
        return @"share_weixin_moments";
    }
    else if (activityType == TTActivityTypeSinaWeibo) {
        return @"share_weibo";
    }
    else if (activityType == TTActivityTypeQQWeibo) {
        return @"share_tweibo";
    }
    else if (activityType == TTActivityTypeQQZone) {
        return @"share_qzone";
    }
    else if (activityType == TTActivityTypeKaiXin) {
        return @"share_kaixin";
    }
    else if (activityType == TTActivityTypeRenRen) {
        return @"share_renren";
    }
    else if (activityType == TTActivityTypeQQShare) {
        return @"share_qq";
    }
    else if (activityType == TTActivityTypeNone) {
        return @"share_cancel_button";
    }
    else if (activityType == TTActivityTypeShareButton) {
        return @"share_button";
    }
    else if (activityType == TTActivityTypeZhiFuBao) {
        return @"share_zhifubao";
    }
    else if (activityType == TTActivityTypeZhiFuBaoMoment) {
        return @"share_zhifubao_shenghuoquan";
    }
    else if (activityType == TTActivityTypeDingTalk) {
        return @"share_dingding";
    }
    else if (activityType == TTActivityTypeSystem) {
        return @"share_system";
    }
    else if (activityType == TTActivityTypeWeitoutiao){
        return @"share_weitoutiao";
    }else{
        return  nil;
    }
}

+ (NSString *)videoSectionNameForShareActivityType:(TTActivitySectionType)activityType{
    
    if (activityType == TTActivitySectionTypeListMore) {
        return @"list_more";
    }
    else  if (activityType == TTActivitySectionTypeListShare) {
        return @"list_share";
    }
    else  if (activityType == TTActivitySectionTypeListVideoOver) {
        return @"list_video_over";
    }
    else  if (activityType == TTActivitySectionTypeDetailBottomBar) {
        return @"detail_bottom_bar";
    }
    else  if (activityType == TTActivitySectionTypeDetailVideoOver) {
        return @"detail_video_over";
    }
    else  if (activityType == TTActivitySectionTypeCentreButton) {
        return @"centre_button";
    }
    else  if (activityType == TTActivitySectionTypePlayerMore) {
        return @"player_more";
    }
    else  if (activityType == TTActivitySectionTypePlayerShare) {
        return @"player_share";
    }else if (activityType == TTActivitySectionTypeListDirect) {
            return @"list_share";
    }else if (activityType == TTActivitySectionTypePlayerDirect) {
        return @"player_click_share";
    }else{
        return nil;
    }
}

+ (NSString *)newshareItemContentTypeFromActivityType:(TTActivityType )activityType{
    NSString *contentType = nil;
//    if (activityType == TTActivityTypeEMail) {
//        contentType = TTActivityContentItemTypeEmail;
//    }
    if (activityType == TTActivityTypeMessage) {
        contentType = TTActivityContentItemTypeMessage;
    }
//    else if (activityType == TTActivityTypeCopy) {
//        contentType = TTActivityContentItemTypeCopy;
//    }
    else if (activityType == TTActivityTypeWeixinShare) {
        contentType = TTActivityContentItemTypeWechat;
    }
    else if (activityType == TTActivityTypeWeixinMoment) {
        contentType = TTActivityContentItemTypeWechatTimeLine;
    }
    else if (activityType == TTActivityTypeQQZone) {
        contentType = TTActivityContentItemTypeQQZone;
    }
    else if (activityType == TTActivityTypeQQShare) {
        contentType = TTActivityContentItemTypeQQFriend;
    }
//    else if (activityType == TTActivityTypeDingTalk) {
//        contentType = TTActivityContentItemTypeDingTalk;
//    }
    else if (activityType == TTActivityTypeWeitoutiao){
        contentType = TTActivityContentItemTypeForwardWeitoutiao;
    }
    else if (activityType == TTActivityTypeDigUp) {
        contentType = TTActivityContentItemTypeDigg;
    }
    else if (activityType == TTActivityTypeDigDown) {
        contentType = TTActivityContentItemTypeBury;
    }
    else if (activityType == TTActivityTypeReport){
        contentType = TTActivityContentItemTypeReport;
    }
//    else if (activityType == TTActivityTypeSystem) {
//        contentType = TTActivityContentItemTypeSystem;
//    }
    else if (activityType == TTActivityTypeFavorite) {
        contentType = TTActivityContentItemTypeFavourite;
    }
    else if (activityType == TTActivityTypeCommodity) {
        contentType = TTActivityContentItemTypeCommodity;
    }else if(activityType == TTActivityTypeDislike){
        contentType = TTActivityContentItemTypeDislike;
    }
      return contentType;
}

+ (TTActivityType)activityTypeFromNewshareItemContentTypeFrom:(NSString *)contentType{
    TTActivityType activityType = TTActivityTypeNone;
//    if ([contentType isEqualToString:TTActivityContentItemTypeEmail]) {
//        activityType = TTActivityTypeEMail;
//    }
    if([contentType isEqualToString:TTActivityContentItemTypeMessage]) {
        activityType = TTActivityTypeMessage;
    }
//    else if ([contentType isEqualToString:TTActivityContentItemTypeCopy]) {
//        activityType = TTActivityTypeCopy;
//    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeWechat]) {
        activityType = TTActivityTypeWeixinShare;
    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeWechatTimeLine]) {
        activityType = TTActivityTypeWeixinMoment;
    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeQQZone]) {
        activityType = TTActivityTypeQQZone;
    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeQQFriend]){
        activityType = TTActivityTypeQQShare;
    }
//    else if ([contentType isEqualToString:TTActivityContentItemTypeDingTalk]) {
//        activityType = TTActivityTypeDingTalk;
//    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]){
        activityType = TTActivityTypeWeitoutiao;
    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeDigg]) {
        activityType = TTActivityTypeDigUp;
    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeBury]) {
        activityType = TTActivityTypeDigDown;
    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeReport]){
        activityType = TTActivityTypeReport;
    }
//    else if ([contentType isEqualToString:TTActivityContentItemTypeSystem]) {
//        activityType = TTActivityTypeSystem;
//    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeFavourite]) {
        activityType = TTActivityTypeFavorite;
    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeCommodity]){
        activityType = TTActivityTypeCommodity;
    }
    else if ([contentType isEqualToString:TTActivityContentItemTypeDislike]){
        activityType = TTActivityTypeDislike;
    }
    return activityType;
}
@end
