//
//  FHHouseEvnContextBridgeImp.m
//  Article
//
//  Created by 谷春晖 on 2018/11/19.
//

#import "FHHouseEvnContextBridgeImp.h"
#import "Bubble-Swift.h"


@implementation FHHouseEvnContextBridgeImp

-(NSString *)currentMapSelect
{
    return [[EnvContext shared] currentMapSelect];
}

-(void)setTraceValue:(NSString *)value forKey:(NSString *)key
{
    [[EnvContext shared] setTraceValueWithValue:value key:key];
}

-(NSDictionary *)homePageParamsMap
{
    return [[EnvContext shared]homePageParamsMap];
}

-(void)recordEvent:(NSString *)key params:(NSDictionary *)params
{
    [[EnvContext shared]recordEventWithKey:key params:params];
}


-(NSString *)currentCityName
{
    return [[[EnvContext shared] client] currentCityName];
}

-(NSString *)currentProvince
{
    return [[[EnvContext shared] client] currentProvince];
}

-(BOOL)locationSameAsChooseCity
{
    return YES;
}

-(CLLocationCoordinate2D)currentLocation
{
    return [[[EnvContext shared] client] currentLocation];
}

-(NSDictionary *_Nullable)appConfig
{
    return nil;
}

-(NSDictionary *)appConfigRentOpData
{
    return nil;
}

-(void)showToast:(NSString *)toast duration:(CGFloat)duration inView:(UIView *)view
{
    return [[[EnvContext shared]toast] showToast:toast duration:duration isUserInteraction:NO];
}

@end
