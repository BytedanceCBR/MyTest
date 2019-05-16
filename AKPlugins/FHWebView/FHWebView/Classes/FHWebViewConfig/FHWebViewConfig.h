//
//  FHWebViewConfig.h
//  FHWebView
//
//  Created by 谢思铭 on 2019/5/15.
//

#import <Foundation/Foundation.h>
#import "FHWebViewConfigProtocol.h"
#import "BDTDefaultHTTPRequestSerializer.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHWebViewConfig : NSObject<FHWebViewConfigProtocol>

// 单例
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
