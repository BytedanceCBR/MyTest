//
//  TTAdSingletonManager.h
//  Article
//
//  Created by yin on 2017/4/28.
//
//

#import <Foundation/Foundation.h>
#import "TTAdConstant.h"

@protocol TTAdSingletonProtocol <NSObject>


@optional

- (void)applicationDidFinishLaunchingNotification:(NSNotification*)notification;

- (void)applicationWillEnterForegroundNotification:(NSNotification*)notification;

 - (void)applicationDidBecomeActiveNotification:(NSNotification*)notification;

- (void)applicationDidEnterBackgroundNotification:(NSNotification*)notification;

@end

@interface TTAdSingletonManager : NSObject

Singleton_Interface(TTAdSingletonManager)

- (BOOL)registerSingleton:(id<TTAdSingletonProtocol>)singleton forKey:(NSString *)key;

- (BOOL)unRegisterSingleton:(id<TTAdSingletonProtocol>)singleton forKey:(NSString *)key;

- (NSArray*)singletonsArray;

- (void)applicationDidLaunch;

@end
