//
//  FHHouseFindListViewModel.h
//  FHHouseFind
//
//  Created by 张静 on 2019/1/2.
//

#import <Foundation/Foundation.h>
#import "FHHouseType.h"
#import "FHTracerModel.h"

NS_ASSUME_NONNULL_BEGIN

@class HMSegmentedControl;
@interface FHHouseFindListViewModel : NSObject

- (instancetype)initWithScrollView:(UIScrollView *)scrollView;
- (void)jump2GuessVC;
- (void)setTracerModel:(FHTracerModel *)tracerModel;
- (void)setSegmentView:(HMSegmentedControl *)segmentView;
- (void)addConfigObserver;
- (void)viewDidLayoutSubviews;

@end

NS_ASSUME_NONNULL_END
