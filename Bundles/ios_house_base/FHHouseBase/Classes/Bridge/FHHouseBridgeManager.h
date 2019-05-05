//
//  FHHouseBridgeManager.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import <Foundation/Foundation.h>
#import "FHHouseFilterBridge.h"
#import "FHHouseEnvContextBridge.h"
#import "FHHouseCellsBridge.h"
#import "FHUserTrackerDefine.h"
#import "FHHouseSwitchCityDelegate.h"
#import "FHHouseAccountBridge.h"

#define SETTRACERKV(key ,value) [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:value forKey:key]


NS_ASSUME_NONNULL_BEGIN

@interface FHHouseBridgeManager : NSObject

+(instancetype)sharedInstance;

-(id<FHHouseFilterBridge> )filterBridge;

-(id<FHHouseEnvContextBridge>)envContextBridge;

-(id<FHHouseCellsBridge>)cellsBridge;

-(id<FHHouseSwitchCityDelegate>)cityListModelBridge;

-(id<FHHouseAccountBridge>)accountBridge;

@end

NS_ASSUME_NONNULL_END
