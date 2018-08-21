//
//  TTStartupInterfaceGroup.h
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupGroup.h"

@interface TTStartupInterfaceGroup : TTStartupGroup

typedef NS_ENUM(NSUInteger, TTInterfaceStartupType) {
    TTInterfaceStartupTypeUserInfo = 0, //获取用户信息
    TTInterfaceStartupTypeAppAlert,//应用内弹窗
    TTInterfaceStartupTypeAppSettings,//应用配置
    TTInterfaceStartupTypeGuideSettings,//引导弹窗配置
    TTInterfaceStartupTypeUGCPermission,//UGC发视频权限
    TTInterfaceStartupTypeUmengTrack,//友盟统计
    TTInterfaceStartupTypeUserConfig,//获取用户设置
    TTInterfaceStartupTypeAppStoreAD,//回传AppStore推广统计
    TTInterfaceStartupTypeRouteSelect,//选路
    TTInterfaceStartupTypeFetchBadge,//刷新飘红飘点
    TTInterfaceStartupTypeGetDomain,//获取域名
    TTInterfaceStartupTypeFeedbackCheck,//反馈
    TTInterfaceStartupTypeGetCategory,//获取频道列表
    TTInterfaceStartupTypeProfileEntry,//我的页面入口通知注册
    TTInterfaceStartupTypeUploadContacts,//间隔时间自动上传通讯录
//    TTInterfaceStartupTypeSFActivityData,//春节活动数据相关 
};

+ (TTStartupInterfaceGroup *)interfaceGroup;

@end
