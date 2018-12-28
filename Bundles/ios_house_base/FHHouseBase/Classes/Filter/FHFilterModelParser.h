//
//  FHFilterModelParser.h
//  FHHouseBase
//
//  Created by leo on 2018/12/28.
//

#import <Foundation/Foundation.h>
#import "FHSearchConfigModel.h"
#import "FHFilterNodeModel.h"
#import "FHHouseType.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHFilterModelParser : NSObject

+(NSArray<FHFilterNodeModel*>*)getConfigByHouseType:(FHHouseType)houseType;

+(NSArray<FHFilterNodeModel*>*)getSortConfigByHouseType:(FHHouseType)houseType;

@end

NS_ASSUME_NONNULL_END
