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

@class HMSegmentedControl,FHHouseFindListViewController,FHErrorView;
@interface FHHouseFindListViewModel : NSObject

- (instancetype)initWithScrollView:(UIScrollView *)scrollView viewController:(FHHouseFindListViewController *)listVC;
- (void)jump2GuessVC;
- (void)setTracerModel:(FHTracerModel *)tracerModel;
- (void)setSegmentView:(HMSegmentedControl *)segmentView;
- (void)addConfigObserver;
- (void)viewDidLayoutSubviews;
- (void)setErrorMaskView:(FHErrorView *)errorMaskView;

@end

NS_ASSUME_NONNULL_END
