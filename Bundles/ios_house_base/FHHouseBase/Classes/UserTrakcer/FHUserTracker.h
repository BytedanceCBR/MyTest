//
//  FHUserTracker.h
//  FHHouseBase
//
//  Created by 谷春晖 on 2018/11/18.
//

#import <Foundation/Foundation.h>
#import "FHTracerModel.h"

#define TRACK_EVENT(event ,  param) [FHUserTracker writeEvent:event params:param]
#define TRACK_MODEL(event ,  model) [FHUserTracker writeEvent:event withModel:model]

NS_ASSUME_NONNULL_BEGIN

@interface FHUserTracker : NSObject

+(void)writeEvent:(NSString *)event params:(NSDictionary *_Nullable)param;

+(void)writeEvent:(NSString *)event withModel:(FHTracerModel *_Nullable)model;

@end

NS_ASSUME_NONNULL_END
