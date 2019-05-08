//
//  FHHouseBridgeManager.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHHouseBridgeManager.h"

@interface FHHouseBridgeManager ()

@property(nonatomic , strong) id envContextBridge;
@property(nonatomic , strong) id cellsBridge;
@property(nonatomic , strong) id cityListBridge;

@end

@implementation FHHouseBridgeManager

+(instancetype)sharedInstance
{
    static FHHouseBridgeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHouseBridgeManager alloc]init];
    });
    return manager;
}

-(id<FHHouseFilterBridge> )filterBridge
{
    Class clazz = NSClassFromString(@"FHHouseFilterBridgeImp");
    return (id<FHHouseFilterBridge> )[[clazz alloc] init];
}

-(id<FHHouseEnvContextBridge>)envContextBridge
{
    if (!_envContextBridge) {
        Class clazz = NSClassFromString(@"FHHouseEvnContextBridgeImp");
        _envContextBridge = [[clazz alloc]init];
    }
    return _envContextBridge;
}

-(id<FHHouseCellsBridge>)cellsBridge
{
    if (!_cellsBridge) {
        Class clazz = NSClassFromString(@"FHHouseCellsBridgeImp");
        _cellsBridge = [[clazz alloc]init];
    }
    return _cellsBridge;
}

-(id<FHHouseSwitchCityDelegate>)cityListModelBridge {
    if (!_cityListBridge) {
        Class clazz = NSClassFromString(@"FHCityListViewModel");
        _cityListBridge = [[clazz alloc] init];
    }
    return _cityListBridge;
}

@end
