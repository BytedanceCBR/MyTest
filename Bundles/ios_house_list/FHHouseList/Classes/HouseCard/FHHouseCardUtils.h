//
//  FHHouseCardUtils.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FHHousePlaceholderStyle) {
    FHHousePlaceholderStyleUnknown,
    FHHousePlaceholderStyle1,
    FHHousePlaceholderStyle2,
    FHHousePlaceholderStyle3,
};

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseCardUtils : NSObject

+ (NSDictionary *)supportCellStyleMap;

+ (NSArray *)getPlaceholderModelsWithStyle:(FHHousePlaceholderStyle)style count:(NSInteger)count;

+ (NSArray *)getHouseListPlaceholderModelsWithStyle:(FHHousePlaceholderStyle)style count:(NSInteger)count;

+ (NSObject *)getEntityFromModel:(id)model;

+ (id)getNoResultViewModelWithExistModel:(id)existModel containerHeight:(CGFloat)containerHeight;

+ (void)trackUseListComponentIfNeed;

@end

@interface FHHouseCardUtils(Detail)

+ (id)getDetailEntityFromModel:(id)model;

@end

NS_ASSUME_NONNULL_END
