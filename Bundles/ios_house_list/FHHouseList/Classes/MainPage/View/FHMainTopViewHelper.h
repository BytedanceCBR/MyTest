//
//  FHMainTopViewHelper.h
//  FHHouseList
//
//  Created by 张静 on 2019/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHListEntrancesView,FHConfigDataOpDataModel;

@interface FHMainTopViewHelper : NSObject

+ (void)fillFHListEntrancesView:(FHListEntrancesView *)entranceView withModel:(FHConfigDataOpDataModel *)model withTraceParams:(NSDictionary *)traceParams;

@end

NS_ASSUME_NONNULL_END
