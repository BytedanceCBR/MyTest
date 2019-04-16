//
//  FHRNBaseViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/25.
//

#import "FHBaseViewController.h"
#import "TTRNKit.h"
#import "TTRNKitViewWrapper.h"
#import "TTRNKit.h"
#import <TTBridgeEngine.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHRNBaseViewController : FHBaseViewController <TTRNKitObserverProtocol,TTBridgeEngine>

- (instancetype)initWithParams:(NSDictionary *)params viewWrapper:(TTRNKitViewWrapper *)viewWrapper;

- (void)addViewWrapper:(TTRNKitViewWrapper *)viewWrapper;

@end

NS_ASSUME_NONNULL_END
