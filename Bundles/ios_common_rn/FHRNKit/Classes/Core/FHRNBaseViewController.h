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
#import "FHRNBridgePlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHRNBaseViewController : FHBaseViewController <TTRNKitObserverProtocol,TTBridgeEngine,FHRNBridgePluginExtension>

@property(nonatomic,assign)BOOL isLoadFinish;

- (instancetype)initWithParams:(NSDictionary *)params viewWrapper:(TTRNKitViewWrapper *)viewWrapper;

- (void)addViewWrapper:(TTRNKitViewWrapper *)viewWrapper;

- (void)sendEventName:(NSString *)stringName andParams:(NSDictionary *)params;

- (void)destroyRNView;

@end

NS_ASSUME_NONNULL_END
