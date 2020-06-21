//
//  FHLoginConflictBridgePlugin.h
//  Pods
//
//  Created by bytedance on 2020/5/7.
//

#import "TTBridgePlugin.h"
#import <TTRexxar/TTRDynamicPlugin.h>

FOUNDATION_EXPORT NSString * const kFHLoginConflictResolvedSuccess;

FOUNDATION_EXPORT NSString * const kFHLoginConflictResolvedFail;

FOUNDATION_EXPORT NSString * const kFHLoginConflictResolvedBindMobile;

NS_ASSUME_NONNULL_BEGIN

@interface FHLoginConflictBridgePlugin : TTRDynamicPlugin

//TT_BRIDGE_EXPORT_HANDLER(postMessageToNative)

TTR_EXPORT_HANDLER(postMessageToNative)

@end

NS_ASSUME_NONNULL_END
