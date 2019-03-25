//
//  FHCityMarketTrendChatViewModel.h
//  FHHouseTrend
//
//  Created by leo on 2019/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class PNLineChartData;
@interface FHCityMarketTrendChatViewModel : NSObject
@property (nonatomic, strong) NSArray<PNLineChartData*>* chartData;
@property (nonatomic, strong) NSArray<NSString*>* xLabels;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat unitPerSquare;
@property (nonatomic, strong) NSArray* model;
@property (nonatomic, strong) NSArray* categorySelections;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* source;
@property (nonatomic, copy) NSString* unitLabel;
@end

NS_ASSUME_NONNULL_END
