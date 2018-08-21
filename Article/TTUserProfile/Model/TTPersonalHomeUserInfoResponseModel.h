//
//  TTPersonalHomeUserInfoResponseModel.h
//  Article
//
//  Created by wangdi on 2017/3/20.
//
//

#import "TTResponseModel.h"
#import "TTRequestModel.h"
#import "FRApiModel.h"
/*
 {
 "message": "success",
 "data": {
 "is_followed": false,  // 是否被关注
 "current_user_id": 5526555143,  // 当前用户id
 "bottom_tab": [],  // 底tab
 "article_limit_enable": 1,  // 之前用的ab参数，已废弃
 "verified_agency": "头条认证",  // 认证机构
 "common_friends": [],  // 共同好友
 "is_following": true,  // 我是否关注此人
 "pgc_like_count": 0,
 "star_chart": {},  // 明星
 "user_verified": true, //是否展示申请认证
 "top_tab": [  // 顶部tab
 {
 "url": "http://issub.snssdk.com/dongtai/list/v8",
 "is_default": false,
 "show_name": "动态",
 "type": "dongtai"
 },
 {
 "url": "",
 "is_default": true,
 "show_name": "文章",
 "type": "all"
 },
 {
 "url": "",
 "is_default": false,
 "show_name": "视频",
 "type": "video"
 },
 {
 "url": "http://isub.snssdk.com/2/user/tab_wenda/",
 "is_default": false,
 "show_name": "问答",
 "type": "wenda"
 }
 ],
 "is_blocking": 0,  // 是否拉黑
 "user_id": 8,  // 被访问的用户uid
 "area": null,  // 用户地区
 "creator_id": 8,
 "share_url": "http://m.toutiao.com/profile/8/",  // 分享到第三方用的地址
 "show_private_letter": 0,  // 是否展示私信入口,只有用户没拉黑并且已经关注此用户并且登录状态并且mediaId不为空，才会展示发私信
 "followers_count": 12964,  // 粉丝数
 "status": 0,
 "media_id": 2762033087,  // 媒体号，如果不为0，显示『头条号』表示
 "description": "观察移动互联网带来的变革",  // 用户签名
 "bg_img_url": "http://p3.pstatp.com/origin/bc30011684fa86d4b71",  // 背景图片
 "verified_content": "今日头条创始人兼CEO",  // 认证内容
 "screen_name": "张一鸣",
 "visit_count_recent": 5721,  // 最近来访人数
 "is_blocked": 0,  // 是否被拉黑
 "user_auth_info": "{\"auth_type\": \"1\", \"auth_info\": \"今日头条创始人兼CEO\"}",  // 用户认证信息
 "name": "张一鸣",  // 用户名
 "big_avatar_url": "http://p9.pstatp.com/large/7697/5037049012",  // 大图地址，点头像是访问这个
 "gender": 1,  // 性别，1男2女
 "industry": null,  // 行业
 "ugc_publish_media_id": 51434019287,  // ugc 发文账号
 "avatar_url": "http://p9.pstatp.com/medium/7697/5037049012",  // 头像
 "followings_count": 1163  // 关注数
 }
 */

@interface TTPersonalHomeUserInfoRequestModel : TTRequestModel

@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *media_id;
@property (nonatomic, copy) NSString *refer;

@end

@protocol TTPersonalHomeUserInfoDataItemResponseModel <NSObject>
@end

@interface TTPersonalHomeUserInfoDataItemResponseModel: TTResponseModel

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *show_name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSNumber *is_default;
@property (nonatomic, copy) NSString *native_index_url;

@end

@protocol TTPersonalHomeUserInfoDataBottomItemResponseModel <NSObject>
@end

@interface TTPersonalHomeUserInfoDataBottomItemResponseModel : TTResponseModel

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, strong) NSArray<TTPersonalHomeUserInfoDataBottomItemResponseModel> *children;

@end

@interface TTPersonalHomeStarUserDataItemResponseModel : TTResponseModel
/*
 "RateChangeStatus": 2,
 "url": "sslocal://concern?enter_from=user_profile&gd_label=user_profile&cid=6213176432638560770",
 "Rate": 6,
 "Score": 14390383
 */
@property (nonatomic, strong) NSNumber *RateChangeStatus;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSNumber *Rate;
@property (nonatomic, strong) NSNumber *Score;

@end

@interface TTPersonalHomeLiveInfoItemStreamUrlResponseModel : TTResponseModel
@property (nonatomic, copy) NSString *stream_id;
@property (nonatomic, strong) NSNumber *create_time;
@property (nonatomic, copy) NSString *flv_pull_url;
@property (nonatomic, copy) NSString *alternate_pull_url;
@end

@interface TTPersonalHomeLiveDataLiveInfoItemResponseModel : TTResponseModel
@property (nonatomic, strong) TTPersonalHomeLiveInfoItemStreamUrlResponseModel *stream_url;
@property (nonatomic, assign) NSInteger watching_count;
@property (nonatomic, strong) NSNumber *create_time;
@property (nonatomic, copy) NSString *room_id;
@property (nonatomic, copy) NSString *schema;


@end

@interface TTPersonalHomeUserDataLiveDataItemResponseModel : TTResponseModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *share_url;
@property (nonatomic, copy) NSString *impression_extra;
@property (nonatomic, copy) NSString *group_id;
@property (nonatomic, strong) NSDictionary *large_image;
@property (nonatomic, strong) TTPersonalHomeLiveDataLiveInfoItemResponseModel *live_info;
@property (nonatomic, copy) NSString *group_source;

@end

@protocol TTPersonalHomeSinglePlatformFollowersInfoModel;

@interface TTPersonalHomeUserInfoDataResponseModel  : TTResponseModel

@property (nonatomic, strong) NSNumber *is_followed;
@property (nonatomic, copy)  NSString *current_user_id;
@property (nonatomic, copy) NSString *verified_agency;
@property (nonatomic, strong) NSNumber *is_following;
@property (nonatomic, strong) NSArray<TTPersonalHomeUserInfoDataItemResponseModel> *top_tab;
@property (nonatomic, strong) NSArray<TTPersonalHomeUserInfoDataBottomItemResponseModel> *bottom_tab;
@property (nonatomic, strong) TTPersonalHomeStarUserDataItemResponseModel *star_chart;
@property (nonatomic, strong) NSNumber *is_blocking;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *user_decoration;
@property (nonatomic, strong) NSNumber *user_verified;
@property (nonatomic, copy) NSString *share_url;
@property (nonatomic, strong) NSNumber *show_private_letter;
@property (nonatomic, strong) NSNumber *no_display_pgc_icon;
@property (nonatomic, strong) NSNumber *followers_count;
@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, copy) NSString *media_id;
@property (nonatomic, strong) NSNumber *media_type;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *bg_img_url;
@property (nonatomic, copy) NSString *verified_content;
@property (nonatomic, copy) NSString *screen_name;
@property (nonatomic, copy) NSString *apply_auth_entry_title;
@property (nonatomic, strong) NSNumber *visit_count_recent;
@property (nonatomic, strong) NSNumber *is_blocked;
@property (nonatomic, copy) NSString *big_avatar_url;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *gender;
@property (nonatomic, copy) NSString *industry;
@property (nonatomic, copy) NSString *ugc_publish_media_id;
@property (nonatomic, copy) NSString *avatar_url;
@property (nonatomic, strong) NSNumber *followings_count;
@property (nonatomic, copy) NSString *user_auth_info;
@property (nonatomic, strong) NSNumber *article_limit_enable;
@property (nonatomic, copy) NSString *apply_auth_url;
@property (nonatomic, copy) NSString *remark_name;//用户真实姓名
@property (nonatomic, copy) NSString *remark_desc;//推荐理由
@property (nonatomic, copy) NSString *followed_desc;//关注我显示文本
@property (nonatomic, copy) NSString *verified_content_v6;//页面认证信息
@property (nonatomic, strong) NSArray<NSString*> *medals;
@property (nonatomic, strong) FRActivityStructModel *activity;
@property (nonatomic, strong)TTPersonalHomeUserDataLiveDataItemResponseModel *live_data;
@property (nonatomic, copy) NSArray<TTPersonalHomeSinglePlatformFollowersInfoModel> *platformFollowersInfoArr;
@property (nonatomic, strong) NSNumber *multiplePlatformFollowersCount;
@end

@interface TTPersonalHomeUserInfoExtraDataResponseModel : TTResponseModel

@property (nonatomic, strong) NSNumber *is_following;
@property (nonatomic, copy) NSString *user_id;

@end

@interface TTPersonalHomeUserInfoResponseModel : TTResponseModel

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) TTPersonalHomeUserInfoDataResponseModel *data;
@property (nonatomic, strong) TTPersonalHomeUserInfoExtraDataResponseModel *extra_data;

@end


