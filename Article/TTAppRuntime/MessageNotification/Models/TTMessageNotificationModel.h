//
//  TTMessageNotificationModel.h
//  Article
//
//  Created by lizhuoli on 17/3/23.
//
//

#import "JSONModel.h"

typedef NS_ENUM(NSUInteger, TTMessageNotificationStyle) {
    TTMessageNotificationStyleRawText = 1, //文本通知
    TTMessageNotificationStyleJump = 2, //跳转通知
    TTMessageNotificationStyleInteractive = 3, //内容互动消息
    TTMessageNotificationStyleInteractiveMerge = 4, //聚合的内容互动消息
    TTMessageNotificationStyleDig = 5, //点赞消息
    TTMessageNotificationStyleDigMerge = 6, //聚合的点赞消息
    TTMessageNotificationStyleFollow = 7, //关注消息
    TTMessageNotificationStyleFollowMerge = 8, //聚合的关注消息
    TTMessageNotificationStyleWDInvite = 9, //问答邀请
};

@class TTMessageNotificationUserModel, TTMessageNotificationContentModel;

@protocol TTMessageNotificationModel @end
@interface TTMessageNotificationModel : JSONModel

@property (nonatomic, strong) NSNumber *cursor; //消息排序的cursor
@property (nonatomic, strong) NSNumber *style; //消息样式类型
@property (nonatomic, copy) NSString *createTime; //消息产生的时间
@property (nonatomic, copy) NSString *actionType;//消息具体类型，用于埋点
@property (nonatomic, copy) NSString *ID; //消息的存储id(仅用于调试，没有重排序情形下与cursor相等)
@property (nonatomic, strong) TTMessageNotificationUserModel *user; //消息的用户信息
@property (nonatomic, strong) TTMessageNotificationContentModel *content; //消息的内容信息
@property (nonatomic, strong) NSNumber<Ignore> *cachedHeight;
@property (nonatomic, strong) NSNumber<Ignore> *hasFollowed;   //代表我是否关注此用户
@property (nonatomic, strong) NSNumber<Ignore> *hasBeFollowed; //代表此用户是否关注我

@end

@protocol TTMessageNotificationIconModel @end
@interface TTMessageNotificationIconModel : JSONModel

@property (nonatomic, copy) NSString *url; //图标url
@property (nonatomic, strong) NSNumber *width; //图标宽度
@property (nonatomic, strong) NSNumber *height; //图标高度

@end

@interface TTMessageNotificationUserModel : JSONModel

@property (nonatomic, copy) NSString *userID; //用户id
@property (nonatomic, copy) NSString *screenName; //用户名
@property (nonatomic, copy) NSString *avatarUrl; //头像
@property (nonatomic, copy) NSString<Optional> *userAuthInfo; //认证信息
@property (nonatomic, copy) NSString<Optional> *userDecoration; //佩饰
@property (nonatomic, copy) NSString<Optional> *contactInfo; //通讯录关系
@property (nonatomic, copy) NSArray<TTMessageNotificationIconModel, Optional> *relationInfo; //关注状态

@end

@interface TTMessageNotificationWDProfitModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *iconDayUrl;
@property (nonatomic, copy) NSString<Optional> *iconNightUrl;
@property (nonatomic, copy) NSString<Optional> *text;
@property (nonatomic, copy) NSString<Optional> *amount;

@end

@interface TTMessageNotificationContentModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *bodyText; //消息主体
@property (nonatomic, copy) NSString<Optional> *bodyUrl; //消息主体点击后跳转的url
@property (nonatomic, copy) NSString<Optional> *refText; //被引用内容
@property (nonatomic, copy) NSString<Optional> *refThumbUrl; //被引用内容的缩略图url
@property (nonatomic, copy) NSString<Optional> *multiText; //聚合消息提示文案
@property (nonatomic, copy) NSString<Optional> *multiUrl;   //聚合消息跳转url
@property (nonatomic, copy) NSString<Optional> *actionText; //动作文案
@property (nonatomic, copy) NSString<Optional> *gotoText; //下方额外跳转文案
@property (nonatomic, copy) NSString<Optional> *gotoThumbUrl; //下方额外跳转的缩略图
@property (nonatomic, copy) NSString<Optional> *gotoUrl; //下方额外跳转链接
@property (nonatomic, copy) NSString<Optional> *extra; //其他信息，json
@property (nonatomic, copy) NSString<Optional> *refImageType; //被引用的缩略图的类型
@property (nonatomic, copy) NSArray<Optional> *filterWords; // 邀请回答不喜欢
@property (nonatomic, strong) TTMessageNotificationWDProfitModel <Optional>*profit; //仅供问答使用

@end

@interface TTMessageNotificationResponseModel : JSONModel

@property (nonatomic, copy) NSArray<TTMessageNotificationModel, Optional> *msgList;
@property (nonatomic, strong) NSNumber<Optional> *hasMore; //是否还有更前的消息
@property (nonatomic, strong) NSNumber<Optional> *readCursor; //本次进入tab将展示的消息中未读和已读的界限
@property (nonatomic, strong) NSNumber<Optional> *minCursor; //返回的消息列表里面cursor的最小值

@end

