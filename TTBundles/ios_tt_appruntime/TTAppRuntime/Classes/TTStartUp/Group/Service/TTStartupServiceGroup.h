//
//  TTStartupServiceGroup.h
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTStartupGroup.h"

@interface TTStartupServiceGroup : TTStartupGroup

typedef NS_ENUM(NSUInteger, TTServiceStartupType) {
    TTServiceStartupTypeMonitor = 0, //监控
    TTServiceStartupTypeCustomUISetting,//自定义UI配置
    TTServiceStartupTypeCellRegister,//cell注册
    TTServiceStartupTypeMapperRegister,//注册schema
    TTServiceStartupTypeAVPlayer,//自研播放器
    TTServiceStartupTypeTimeInterval,//时间间隔设置
    TTServiceStartupTypeLocation,//时间间隔设置
    TTServiceStartupTypeSpotlight,//spotlight调起
    TTServiceStartupTypeUniversalLinks,//universallinks调起
    TTServiceStartupTypeCollectDiskSpace,//磁盘空间搜集
    TTServiceStartupTypeCookie,//cookie
    TTServiceStartupTypeBackgroundMode,//后台任务
    TTServiceStartupTypeVideoSyncSwitch,//同步开关
    TTServiceStartupTypePrivateLetter,// 私信
    TTServiceStartupTypeiOS10NotificationCheck,// ios10推送到达时检查锁屏状态
    TTServiceStartupTypeNetworkStatusMonitor,//网络联通状态检查
    TTServiceStartupTypeReporter,//举报服务
    TTServiceStartupTypeLaunchTime,//记录启动时间
    TTServiceStartupTypeStatistics, //免流量统计
    TTServiceStartupTypeFeedPreload,//推荐feed getlocal预加载
    TTServiceStartupTypeTVCast,//电视投屏
    TTServiceStartupTypeIESPlayer,//IESPlayer
    TTServiceStartupTypeAkActivityTab,//爱看任务tab启动任务
    TTServiceStartupTypeAkLaunch,//爱看通用启动任务
};

+ (TTStartupServiceGroup *)serviceGroup;

@end
