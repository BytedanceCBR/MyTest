//
//  WDParseHelper.h
//  Article
//
//  Created by xuzichao on 2016/11/15.
//
//

#import <Foundation/Foundation.h>

extern NSString * const kWDLogPbFromKey;
extern NSString * const kWDOriginFromKey;
extern NSString * const kWDEnterFromKey;
extern NSString * const kWDParentEnterFromKey;
extern NSString * const kWDSourceKey;

@interface WDParseHelper : NSObject

//parse
+ (NSDictionary *)apiParamFromBaseCondition:(NSDictionary *)condition;
+ (NSDictionary *)gdExtJsonFromBaseCondition:(NSDictionary *)condition;
+ (NSDictionary *)logPbFromBaseCondition:(NSDictionary *)condition;

+ (NSDictionary *)trakExtraFromBaseCondition:(NSDictionary *)condition forKey:(NSString *)key;
+ (NSDictionary *)protectMethodGetDicFromString:(NSString *)jsonStr;

//route
+ (NSDictionary *)routeJsonWithOriginJson:(NSDictionary *)originDict source:(NSString *)source;

+ (NSDictionary *)apiParamWithSourceApiParam:(NSDictionary *)originApiParam source:(NSString *)source;

//URL


@end
