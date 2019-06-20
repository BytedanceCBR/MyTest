//
//  TTMessageNotificationTipsModel.h
//  Article
//
//  Created by lizhuoli on 17/3/23.
//
//

#import "JSONModel.h"

@class TTMessageNotificationTipsImportantModel;
@interface TTMessageNotificationTipsModel : JSONModel

@property (nonatomic, strong) NSNumber *total; //未读数目
@property (nonatomic, copy) NSString *tips; //未读消息提示文案
@property (nonatomic, copy) NSString<Optional> *followChannelTips;//关注频道新消息提示文案，该字段非空则使用这个服务端下发的文案，否则客户端拼接
@property (nonatomic, strong) TTMessageNotificationTipsImportantModel<Optional> *important; //重要消息相关，无重要消息时没有该字段
@property (nonatomic, copy) NSString *actionType; //消息的类型，用于埋点统计
@property (nonatomic, strong) NSNumber *interval; //本接口轮询间隔
@property (nonatomic, copy) NSString<Optional> * lastImageUrl; //最新消息相关用户头像
@end

@interface TTMessageNotificationTipsImportantModel: JSONModel

@property (nonatomic, copy) NSString *action; //动作文案
@property (nonatomic, copy) NSString *userName; //用户名
@property (nonatomic, copy) NSString *thumbUrl; //缩略图
@property (nonatomic, copy) NSString *userAuthInfo; //相关用户的认证信息
@property (nonatomic, copy) NSString *userDecoration; //相关用户的认证信息
@property (nonatomic, strong) NSNumber<Optional> *displayTime; //气泡展示时长，单位是秒
@property (nonatomic, copy) NSString<Optional> *openUrl; //气泡点击跳转
@property (nonatomic, copy) NSString<Optional> *content; //评论消息的评论内容
@property (nonatomic, copy) NSString *msgID; //重要消息的id，用于埋点
@property (nonatomic, strong) NSNumber *cursor;//用于重要的人的消息的排序
@property (nonatomic, strong) NSNumber<Optional> *onlyBubble; //是否不进消息列表的气泡. 0-进消息列表，1-不进消息列表

@property (nonatomic, strong) NSNumber<Ignore> *hasShown;//标明当前重要的消息是否有被显示过

@end
