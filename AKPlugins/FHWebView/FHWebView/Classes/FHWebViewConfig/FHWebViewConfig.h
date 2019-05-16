//
//  FHWebViewConfig.h
//  FHWebView
//
//  Created by 谢思铭 on 2019/5/15.
//

#import <Foundation/Foundation.h>
#import "FHWebViewConfigProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHAppVersion)
{
    FHAppVersionC = 0,
    FHAppVersionB,
};

@interface FHWebViewConfig : NSObject<FHWebViewConfigProtocol>

// 单例
+ (instancetype)sharedInstance;

+ (FHAppVersion)appVersion;

@end

NS_ASSUME_NONNULL_END
