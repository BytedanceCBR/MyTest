//
//  FHCommuteManager.m
//  FHHouseList
//
//  Created by 春晖 on 2019/4/1.
//

#import "FHCommuteManager.h"
#import <TTBaseLib/TTSandBoxHelper.h>

#define COMMUTE_CONFIG    @"_COMMUTE_CONFIG_"
#define COMMUTE_LOCATION  @"LOCATION"
#define COMMUTE_DUARTION  @"DURATION"
#define COMMUTE_TYPE      @"type"
#define COMMUTE_LATITUDE  @"LATITUDE"
#define COMMUTE_LONGITUDE @"LONGITUDE"
#define COMMUTE_CITY_ID   @"CITY_ID"


@interface FHCommuteManager ()

@property(nonatomic , strong) NSMutableDictionary *configDict;

@end

@implementation FHCommuteManager

+(instancetype)sharedInstance
{
    static FHCommuteManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHCommuteManager alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    self = [super init];
    if (self) {        
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:COMMUTE_CONFIG];
        _configDict = [[NSMutableDictionary alloc]init];
        if (dict) {
            [_configDict addEntriesFromDictionary:dict];
        }
    }
    return self;
}

-(NSString *)destLocation
{
    return _configDict[COMMUTE_LOCATION];
}

-(void)setDestLocation:(NSString *)destLocation
{
    _configDict[COMMUTE_LOCATION] = destLocation;
}

-(void)setLatitude:(CGFloat)latitude
{
    _configDict[COMMUTE_LATITUDE] = @(latitude);
}

-(CGFloat)latitude
{
    return [_configDict[COMMUTE_LATITUDE] floatValue];
}

-(void)setLongitude:(CGFloat)longitude
{
    _configDict[COMMUTE_LONGITUDE] = @(longitude);
}

-(CGFloat)longitude
{
    return [_configDict[COMMUTE_LONGITUDE] floatValue];
}

-(void)setDuration:(NSString *)duration
{
    _configDict[COMMUTE_DUARTION] = duration;
}

-(NSString *)duration
{
    return _configDict[COMMUTE_DUARTION];
}

-(FHCommuteType) commuteType
{
    NSNumber *type = _configDict[COMMUTE_TYPE];
    if (type) {
        return type.integerValue;
    }
    return -1;
}

-(void)setCommuteType:(FHCommuteType)commuteType
{
    _configDict[COMMUTE_TYPE] = @(commuteType);
}

-(NSString *)commuteTypeName
{
    switch (self.commuteType) {
        case FHCommuteTypeBus:
            return @"公交";
        case FHCommuteTypeDrive:
            return @"驾车";
        case FHCommuteTypeRide:
            return @"骑行";
        case FHCommuteTypeWalk:
            return @"步行";
        default:
            break;
    }
    return @"公交";    
}

-(NSString *)cityId
{
    return _configDict[COMMUTE_CITY_ID];
}

-(void)setCityId:(NSString *)cityId
{
    _configDict[COMMUTE_CITY_ID] = cityId;
}

-(void)clear
{
    [_configDict removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:COMMUTE_CONFIG];
}

-(void)sync
{
    [[NSUserDefaults standardUserDefaults] setObject:_configDict forKey:COMMUTE_CONFIG];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
