//
//  FHCityMarketTrendHeaderViewModel.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCityMarketTrendHeaderViewModel : NSObject
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* price;
@property (nonatomic, copy) NSString* unit;
@property (nonatomic, copy) NSString* source;
@property (nonatomic, strong) NSArray* properties;
@end

NS_ASSUME_NONNULL_END
