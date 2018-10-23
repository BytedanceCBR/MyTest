//
//  WDNetWorkPluginManager.h
//  Article
//
//  Created by 延晋 张 on 2016/10/8.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"
#import "TTNetworkManager.h"

/*
 1.区分详情页是否返回下一个回答的数据
 2.下一个回答常驻，无网络提示并重载
 3.详情页顶部Header干掉
 4.问答支持有视频的回答，在频道列表详情页展示,频道为右边的小图视频
 5.问答频道支持头像露出和三图模式以及添加到首屏公共化
 6.问答详情页举报和反对按钮拆开
 7.问答列表页新旧版本UI切换
 8.问答Widget变为Native化
 9.问答详情页支持广告
10.问题合并，增加主问题次问题的处理逻辑
11.问答频道出推人卡片安卓崩溃需要升级iOS同步
12.feed接口下发新版我的问答URL
   实名制认证
13.详情页做强举报功能
   详情页品牌露出
14.关注改收藏
15.详情页显示标签view
 */
#define WD_API_VERSION @"15"

extern NSString * const kWDApiVersion;

@interface WDNetWorkPluginManager : NSObject<Singleton>

- (TTHttpTask *)requestModel:(TTRequestModel *)model
                          callback:(TTNetworkResponseModelFinishBlock)callback;

@end
