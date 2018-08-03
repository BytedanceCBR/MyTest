//
//  TTSettingMineTabEntry.h
//  Article
//
//  Created by fengyadong on 16/11/2.
//
//

#import "TTSettingGeneralEntry.h"

typedef NS_ENUM(NSUInteger, TTSettingMineTabEntyType){
    TTSettingMineTabEntyTypeiPhoneTopFunction = 0,//iPhone顶部夜间收藏历史
    
    TTSettingMineTabEntyTypeiPadNightMode,//iPad夜间
    TTSettingMineTabEntyTypeiPadFavor,//iPad收藏
    TTSettingMineTabEntyTypeiPadHistory,//iPad历史
    
    TTSettingMineTabEntyTypeMyFollow,//我的关注 iPhone only
    
    TTSettingMineTabEntyTypeWorkLibrary,//作品管理
    TTSettingMineTabEntyTypePrivateLetter,//私信
    
    TTSettingMineTabEntyTypeTTMall,//头条商城 iPhone only
    
    TTSettingMineTabEntyTypeGossip,//我要爆料 iPhone only
    TTSettingMineTabEntyTypeFeedBack,//用户反馈
    TTSettingMineTabEntyTypeSettings,//设置
    TTSettingMineTabEntyTypePhotoCarousel,//轮播
};

@interface TTSettingMineTabEntry : TTSettingGeneralEntry

@property (nonatomic, copy)   NSString *iconName;//本地icon图标名称，包括iPhone的顶部图标和iPad的cell左侧图标
@property (nonatomic, copy)   NSString *avatarUrlString;//entry显示需要的右侧头像URL
@property (nonatomic, copy)   NSString *userAuthInfo;//entry显示需要的认证信息
@property (nonatomic, copy)   NSString *msgID;//entry显示需要的消息ID
@property (nonatomic, copy)   NSString *actionType;//entry显示需要的消息类型
@property (nonatomic, copy)   NSString *lastImageUrl;//最新消息相关用户头像
@property (nonatomic, copy)   NSString *tips;//消息通知提示
@property (nonatomic, copy)   NSString *userName;//消息通知需要拼接字符串
@property (nonatomic, assign) BOOL isImportantMessage;//消息通知判断是否是重要的用户
@property (nonatomic, copy)   NSString *action;//消息通知对应用户名
@property (nonatomic, assign) NSTimeInterval lastClickedTimeInterval;
@property (nonatomic, copy) void (^switchChangedBlock)(UISwitch *changedSwitch);

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;//服务端数据
+ (instancetype)initWithEntryType:(TTSettingMineTabEntyType)type;

//block无法归档/解档，这里需要重新初始化
+ (void)setBlockForEntry:(TTSettingMineTabEntry *)entry;

@end
