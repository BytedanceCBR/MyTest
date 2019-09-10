//
//  FHHouseOpenURLUtil.m
//  FHHouseList
//
//  Created by 春晖 on 2019/8/23.
//

#import "FHHouseOpenURLUtil.h"

@implementation FHHouseOpenURLUtil

+(BOOL)isSameURL:(NSString *)url1 and:(NSString *)url2
{
    if (url1 == url2) {
        return YES;
    }
    
    if ([url1 isEqualToString:url2]) {
        return YES;
    }
    
    NSDictionary *dict1 = [self queryDict:url1];
    NSDictionary *dict2 = [self queryDict:url2];
    
    if ([dict1 isEqualToDictionary:dict2]) {
        return YES;
    }
    
    
    return NO;
}

+(NSDictionary *)queryDict:(NSString *)url
{
    NSURLComponents *componets = [NSURLComponents componentsWithString:url];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for (NSURLQueryItem *item in componets.queryItems) {
        dict[item.name] = item.value;
    }
    
    return dict;
    
}

@end
