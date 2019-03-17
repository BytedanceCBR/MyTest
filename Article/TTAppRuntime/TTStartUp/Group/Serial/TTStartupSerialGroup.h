//
//  TTStartupSerialGroup.h
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTStartupGroup.h"

typedef NS_ENUM(NSUInteger, TTSerialStartupType) {
    TTSerialStartupTypeCrashAttemptFix = 0,//nano free尝试修复
    TTServiceStartupTypeCrashReport,//crash上报
    TTSerialStartupTypeFabric,//Fabric
    TTSerialStartupTypeClientABHelper, // 客户端实验初始化
    TTSerialStartupTypeAccountSDK,//TTAccountSDk
    TTSerialStartupTypeNetworkSerializer,//网络库序列化
    TTInterfaceStartupTypeGetInstallID,//获取installID
    TTSerialStartupTypeAppLog,//统计
    TTSerialStartupTypeRegisterSettings,//注册设置
    TTSerialStartupTypeCleanDatabase,//清理数据库
    TTSerialStartupTypeClearCache,//清除缓存
    TTSerialStartupTypeURLCacheSetting,//URLCache设置
    TTSerialStartupTypeSDWebImageCacheSetting,//SDWebImage缓存和过期时间设置
    TTSerialStartupTypeWeiboExpirationDetect,//微博过期检查
    TTServiceStartupTypeAppPageManager,//跳转管理器
    TTSerialStartupTypeHandleShortcutItem,//3d-touch快捷方式调起
    TTSerialStartupTypeHandleFirstLaunch,//新安装或者升级之后第一次打开
    TTSerialStartupTypeNetworkNotify,//网络变化通知
    TTSerialStartupTypeHanleAPNS,//push调起
    TTSerialStartupTypeWatchConnetion,//watch建连
    TTServiceStartupTypeOrientation,//转屏设置
    TTSerialStartupTypeSetHook,//设置pod库中的钩子方法
    TTSerialStartupTypePermissionSettingsReport,//上报推送权限设置
    TTServiceStartupTypeUseBDWebImage,//BDWebImage
    TTServiceStartupTypeFHIMStartupTask,//BDWebImage
    TTServiceStartupTypeOpenURL,//open url 调起
};

@interface TTStartupSerialGroup : TTStartupGroup

+ (TTStartupSerialGroup *)serialGroup;

@end
