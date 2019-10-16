//GENERATED CODE , DON'T EDIT
#import "FHUserInfoModel.h"
@implementation FHUserInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHUserInfoDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"verifiedAgency": @"verified_agency",
    @"countryCode": @"country_code",
    @"recommendHintMessage": @"recommend_hint_message",
    @"isToutiao": @"is_toutiao",
    @"sessionKey": @"session_key",
    @"userVerified": @"user_verified",
    @"isBlocking": @"is_blocking",
    @"userId": @"user_id",
    @"userDecoration": @"user_decoration",
    @"userIdStr": @"user_id_str",
    @"userPrivacyExtend": @"user_privacy_extend",
    @"mediaId": @"media_id",
    @"bgImgUrl": @"bg_img_url",
    @"verifiedContent": @"verified_content",
    @"isBlocked": @"is_blocked",
    @"userAuthInfo": @"user_auth_info",
    @"isRecommendAllowed": @"is_recommend_allowed",
    @"screenName": @"screen_name",
    @"shareToRepost": @"share_to_repost",
    @"avatarUrl": @"avatar_url",
    @"canBeFoundByPhone": @"can_be_found_by_phone",
    @"fHomepageAuth": @"f_homepage_auth",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

