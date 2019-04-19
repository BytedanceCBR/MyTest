//
//  FHRNBridgePlugin.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/27.
//

#import "TTBridgePlugin.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHRNBridgePluginExtension <NSObject>

- (void)callPhone:(void (^)(NSDictionary *params))excute;

@end

@interface FHRNBridgePlugin : TTBridgePlugin

TT_BRIDGE_EXPORT_HANDLER(fetch)

TT_BRIDGE_EXPORT_HANDLER(alertTest)

TT_BRIDGE_EXPORT_HANDLER(open)

TT_BRIDGE_EXPORT_HANDLER(log_v3)

TT_BRIDGE_EXPORT_HANDLER(close)

TT_BRIDGE_EXPORT_HANDLER(load_finish)

TT_BRIDGE_EXPORT_HANDLER(enable_swipe)

TT_BRIDGE_EXPORT_HANDLER(disable_swipe)

TT_BRIDGE_EXPORT_HANDLER(monitor_common_log)

TT_BRIDGE_EXPORT_HANDLER(monitor_duration)

TT_BRIDGE_EXPORT_HANDLER(call_phone)

TT_BRIDGE_EXPORT_HANDLER(toast)

@end

NS_ASSUME_NONNULL_END
