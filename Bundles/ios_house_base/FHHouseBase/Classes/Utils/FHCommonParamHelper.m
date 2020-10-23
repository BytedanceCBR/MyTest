//
//  FHCommonParamHelper.m
//  FHHouseBase
//
//  Created by bytedance on 2020/10/22.
//

#import "FHCommonParamHelper.h"
#import <TTNetBusiness/TTNetworkUtilities.h>
#import "FHEnvContext.h"
#import "FHLocManager.h"
#import "TTDeviceHelper+FHHouse.h"
#import <ByteDanceKit/NSString+BTDAdditions.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import "TTSettingsManager+FHSettings.h"

static const char xorStr[] = "x1yNd0a2Z";

@implementation FHCommonParamHelper

+ (NSDictionary *)generateRequestCommonParams:(NSDictionary *)cacheParams {
    NSDictionary *param = [TTNetworkUtilities commonURLParameters];
    
    //初始化公共请求参数
    NSMutableDictionary *requestParam = [[NSMutableDictionary alloc] initWithDictionary:cacheParams];
    if (param) {
        [requestParam addEntriesFromDictionary:param];
    }
    
    requestParam[@"app_id"] = @"1370";
    requestParam[@"aid"] = @"1370";
    
    requestParam[@"channel"] = [[NSBundle mainBundle] infoDictionary][@"CHANNEL_NAME"];
    requestParam[@"app_name"] = @"f100";
    requestParam[@"source"] = @"app";
    
    //获取city_id
    if ([[FHEnvContext getCurrentSelectCityIdFromLocal] respondsToSelector:@selector(integerValue)]) {
        NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
        if (cityId > 0) {
            [requestParam setValue:@(cityId) forKey:@"city_id"];
        }
    }
    
    
    NSString *gCityId = [FHLocManager sharedInstance].currentReGeocode.cityCode;
    NSString *gCityName = [FHLocManager sharedInstance].currentReGeocode.city;
    
    
    CGFloat f_density = [UIScreen mainScreen].scale;
    CGFloat f_memory = [TTDeviceHelper getTotalCacheSpace];
    
    if (f_density) {
        requestParam[@"f_density"] = @(f_density);
    }
    
    if (f_memory) {
        requestParam[@"f_memory"] = @(f_memory);
    }
    
    
    NSDictionary *locationParams = [self generateLocationParams];
    if (locationParams) {
        [requestParam addEntriesFromDictionary:locationParams];
    }

    
    if ([gCityId isKindOfClass:[NSString class]]) {
        requestParam[@"gaode_city_id"] = gCityId;
    }
    
    if ([gCityName isKindOfClass:[NSString class]]){
        requestParam[@"city_name"] = gCityName;
        requestParam[@"city"] = gCityName;
    }
    
    return requestParam;
}


+ (NSDictionary *)generateLocationParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    CLLocationCoordinate2D coordinate = [FHLocManager sharedInstance].currentLocaton.coordinate;
    double longitude = coordinate.longitude;
    double latitude = coordinate.latitude;
    
    //【经纬度加密需求】去掉通用参数里的gaode_lng和gaode_lat参数，和Android端确认的结果：目前只有/f100/v2/api/config接口使用这两个参数, 使用f_setting.f_enable_gaode_lng_in_common_params作为控制开关(0: off，1:on)，默认策略是0
    if ([[TTSettingsManager fSettings] btd_boolValueForKey:@"f_enable_gaode_lng_in_common_params" default:NO]) {
        if (longitude != 0 && longitude != 0) {
            [params btd_setObject:@(longitude) forKey:@"gaode_lng"];
            [params btd_setObject:@(latitude) forKey:@"gaode_lat"];
        }
    }
    
    //【经纬度加密需求】通用参数使用as_id代替longitude和latitude, 使用f_setting.f_enable_longitude_in_common_params作为控制开关(0: as_id only，1:longitude&longitude only, 2:both)，默认策略是0
    int asIdMode = [[TTSettingsManager fSettings] btd_intValueForKey:@"f_enable_longitude_in_common_params" default:0];
    if (asIdMode == 1 || asIdMode == 2) {
        if (longitude != 0 && longitude != 0) {
            [params btd_setObject:@(longitude) forKey:@"longitude"];
            [params btd_setObject:@(latitude) forKey:@"latitude"];
        }
    }
    
    if (asIdMode == 0 || asIdMode == 2) {
        NSString *as_id = [self generateAsID:coordinate];
        if (as_id && as_id.length) {
            [params btd_setObject:as_id forKey:@"as_id"];
            [self checkAsId:as_id coordinate:coordinate];
        }
    }
    
    return params;
}

//将经纬度拼接，对原始字节进行异或，然后进行base64，得到 as_id
+ (NSString *)generateAsID:(CLLocationCoordinate2D)coordinate {
    double longitude = coordinate.longitude;
    double latitude = coordinate.latitude;
    if (longitude == 0 || longitude == 0) return nil;
    
    NSString *lng_lat = [NSString stringWithFormat:@"%.6f_%.6f", longitude, latitude];
    NSData *lng_lat_data = [lng_lat dataUsingEncoding: NSUTF8StringEncoding];
    Byte *lng_lat_bytes = (Byte *)[lng_lat_data bytes];
    if (lng_lat_bytes == NULL) return nil;
    for (int i = 0; i < [lng_lat_data length]; i++) {
        lng_lat_bytes[i] = lng_lat_bytes[i] ^ xorStr[i % strlen(xorStr)];
    }
    
    NSData *encodeData = [NSData dataWithBytes:lng_lat_bytes length:[lng_lat_data length]];
    if (encodeData == nil) return nil;
    return [encodeData base64EncodedStringWithOptions:0];
}

+ (void)checkAsId:(NSString *)as_id coordinate:(CLLocationCoordinate2D)coordinate {
#if DEBUG
    NSLog(@"zwlog encode (%f , %f) => %@", coordinate.longitude, coordinate.latitude, as_id);
    NSString *decodeStr = [as_id btd_base64DecodedString];
    NSData *encodeData = [decodeStr dataUsingEncoding: NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[encodeData bytes];
    for (int i = 0; i < [encodeData length]; i++) {
        bytes[i] = bytes[i] ^ xorStr[i % strlen(xorStr)];
    }
    
    NSData *decodeData = [NSData dataWithBytes:bytes length:[encodeData length]];
    NSString *originStr = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    NSString *destOriginStr = [NSString stringWithFormat:@"%.6f_%.6f", coordinate.longitude, coordinate.latitude];
    if (originStr.length && destOriginStr.length && [destOriginStr isEqualToString:originStr]) {
        NSLog(@"zwlog check as_id is ok");
    } else {
        NSLog(@"zwlog check as_id is error");
    }
#endif
}

@end
