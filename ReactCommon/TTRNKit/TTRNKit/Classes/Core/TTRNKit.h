//
//  TTRNKit.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/11.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>
#import "TTRNKitStartUpSetting.h"
#import "TTRNKitGeckoWrapper.h"
#import "TTRNKitProtocol.h"
#import "TTRNKitMacro.h"
@class TTRNKitViewWrapper;
@class TTRNKitBridgeModule;
@class TTRNKit;

@protocol TTRNKitObserverProtocol <NSObject>

@property (nonatomic, weak) TTRNKit *manager;

@end

@interface TTRNKit : NSObject
- (instancetype)initWithGeckoParams:(NSDictionary *)geckoParams animationParams:(NSDictionary *)animationParams;

@property (nonatomic, weak) id<TTRNKitProtocol> delegate;

@property (nonatomic, weak, readonly) TTRNKitViewWrapper *currentViewWrapper;

@property (nonatomic, copy, readonly) NSDictionary *geckoParams;

@property (nonatomic, copy, readonly) NSDictionary *animationParams;

- (BOOL)fallBackForChannel:(NSString *)channel;

- (NSURL *)bundleUrlForChannel:(NSString *)channel;

- (TTRNKitBridgeModule *)rnKitBridgeModuleForChannel:(NSString *)channel;

- (RCTBridge *)rctBridgeForChannel:(NSString *)channel;

/**
 获取TTRNKit的状态
 */
- (void)registerObserver:(id<TTRNKitObserverProtocol>)observer;

/**
 业务方在native页面直接调用，通过sdk去解析url
 */
- (void)handleUrl:(NSString *)urlString;

/**
清空RN资源
 */
- (void)clearRNResourceForChannel:(NSString *)channel;

/**
 尝试加载RN资源
 */
- (BOOL)tryStartRNResourceWithChannel:(NSString *)channel;
/**
 调整图层，将最上层的view pop
 */
- (void)popViewHierarchy;
/**
 进入调试模式
 @param presentor 由它present出后续vc
 @param contentViewController 用于持有TTRNKitViewWrapper，contentViewController需要实现TTRNKitProtocol
 */
- (void)enterDebug:(UIViewController *)presentor contentViewController:(UIViewController *)contentViewController;
@end
