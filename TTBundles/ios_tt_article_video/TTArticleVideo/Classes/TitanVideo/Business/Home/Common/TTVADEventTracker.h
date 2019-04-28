//
//  TTVADEventTracker.h
//  Article
//
//  Created by pei yun on 2017/8/1.
//
//

#import <Foundation/Foundation.h>

@interface TTVADEventTracker : NSObject

+ (void)ttv_adEventTrackerWithTag:(NSString *)tag label:(NSString *)label adID:(NSString *)adID logExtra:(NSString *)logExtra extraParamsDict:(NSDictionary *)extraParamsDict;

@end
