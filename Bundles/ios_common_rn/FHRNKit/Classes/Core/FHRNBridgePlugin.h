//
//  FHRNBridgePlugin.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/27.
//

#import "TTBridgePlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHRNBridgePlugin : TTBridgePlugin

TT_BRIDGE_EXPORT_HANDLER(fetch)

TT_BRIDGE_EXPORT_HANDLER(alertTest)

TT_BRIDGE_EXPORT_HANDLER(open)



@end

NS_ASSUME_NONNULL_END
