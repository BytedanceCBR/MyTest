//
//  TTAdTrackManager.h
//  Article
//
//  Created by yin on 2017/7/10.
//
//

#import <Foundation/Foundation.h>

@interface TTAdTrackManager : NSObject

//+ (void)trackWithEvents:(NSDictionary *)dic;

+ (void)trackWithTag:(NSString *)tag
               label:(NSString *)label
               value:(NSString *)value
            extraDic:(NSDictionary *)dic;

@end
