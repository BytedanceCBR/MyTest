//
//  RNData.h
//  
//
//  Created by Chen Hong on 16/7/25.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNData : ExploreOriginalData

@property (nullable, nonatomic, retain) NSDictionary *data;
@property (nullable, nonatomic, retain) NSArray *filterWords;
@property (nullable, nonatomic, retain) NSArray *actionList;

// 以下字段为增加ExploreOrderedDataCellTypeDynamicRN时添加，用于动态加载bundle，及动态获取数据
@property (nullable, nonatomic, copy) NSDictionary *rawData;
@property (nullable, nonatomic, copy) NSString *moduleName;
@property (nullable, nonatomic, copy) NSNumber *typeId;
@property (nullable, nonatomic, copy) NSString *typeName;
@property (nullable, nonatomic, copy) NSString *dataUrl;
@property (nullable, nonatomic, copy) NSNumber *refreshInterval;
@property (nullable, nonatomic, copy) NSDictionary *dataContent;
@property (nullable, nonatomic, copy) NSDate *lastUpdateTime; //上一次更新数据的时间

- (void)updateWithDataContentObj:(NSDictionary *)content;

@end

NS_ASSUME_NONNULL_END
