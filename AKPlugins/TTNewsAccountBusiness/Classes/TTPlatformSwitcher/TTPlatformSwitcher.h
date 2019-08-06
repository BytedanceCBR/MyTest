//
//  TTPlatformSwitcher.h
//  Article
//
//  Created by xuzichao on 2017/5/16.
//
//

#import <Foundation/Foundation.h>

@interface TTPlatformSwitcher : NSObject

/**
 *  单例用于设置数据
 */
+ (instancetype)sharedInstance;
- (void)setABConfigDic:(NSDictionary *)ABConfigDic;

/**
 *  AppSetting下发的接口字段，服务名和库名同级，后台配置服务名称
 *  http://web_admin.byted.org/static/main/index.html#/app_settings/item_detail?id=507
 *
 *  此方法作判断调用，class为新建的服务类
 *  举例: [[TTPlatformSwitcher sharedInstance] isEnableForClass:[TTDislikeView class]];
 *  缩写：TTPlatformEnable([TTDislikeView class])
 *
 *  当服务类名众多含在库中的时候，可以由库统一开关
 *  podName 为当前所在库的库名，比如TTImage库包含了TTSDWebImageDownloaderOperation等等
 *  举例：[[TTPlatformSwitcher sharedInstance] isEnableForClass:NSClassFromString(TTImage)];
 *  缩写：TTPlatformEnable(NSClassFromString(TTImage))
 */
- (BOOL)isEnableForClass:(Class)className;

@end

NS_INLINE BOOL TTPlatformEnable(Class className) {
    return [[TTPlatformSwitcher sharedInstance] isEnableForClass:className];
}
