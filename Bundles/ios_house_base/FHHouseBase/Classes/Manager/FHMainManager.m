//
//  FHMainManager.m
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import "FHMainManager.h"
#import "FHHouseBridgeManager.h"

@implementation FHMainManager

+(instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

//-(instancetype)init
//{
//    self = [super init];
//    if(self){
//
//    }
//    return self;
//}


-(BOOL)locationSameAsChooseCity
{
    id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
    return [contextBridge locationSameAsChooseCity];
}

-(CLLocationCoordinate2D)currentLocation
{
    return [_locationManager currentLocation];
}

@end
