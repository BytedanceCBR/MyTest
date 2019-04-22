//
//  TTStartupADGroup.h
//  Article
//
//  Created by fengyadong on 17/1/19.
//
//

#import "TTStartupGroup.h"

@interface TTStartupADGroup : TTStartupGroup

typedef NS_ENUM(NSUInteger, TTADStartupType) {
    TTADStartupTypeShowAD = 0, //广告展示
    TTADStartupTypeRequsetShareAD, //分享广告获取
    TTADStartupTypeRequestRefreshAD,//下拉刷新广告获取
    TTADStartupTypeFetchADResource, //获取广告资源
    TTADStartupTypeFetchADEngine,//广告引擎初始化
};

+ (TTStartupADGroup *)ADGroup;

@end
