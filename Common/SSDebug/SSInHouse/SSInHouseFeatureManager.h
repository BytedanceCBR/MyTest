//
//  SSInHouseFeatureManager.h
//  Article
//
//  Created by liufeng on 2017/8/14.
//
//

#import <Foundation/Foundation.h>
#import "SSInHouseFeature.h"

@interface SSInHouseFeatureManager : NSObject

// 当前生效的内测功能配置对象的副本（copy），修改返回的对象不会影响原值
@property (nonatomic, readonly, class) SSInHouseFeature *feature;

// 本地用户设置
@property (nonatomic, readonly, class) SSInHouseFeature *localFeature;
// 后端配置
@property (nonatomic, readonly, class) SSInHouseFeature *remoteFeature;

+ (instancetype)defaultManager;

- (void)resetServerDiskCacheWithSettings:(NSDictionary *)settings;

- (void)resetUserDiskCacheWithFeature:(SSInHouseFeature *)feature;

@end
