//
//  FHHouseNewComponentView.m
//  FHHouseList
//
//  Created by bytedance on 2020/10/28.
//

#import "FHHouseNewComponentView.h"
#import "FHHouseNewComponentViewModel.h"

@interface FHHouseNewComponentView()<FHHouseNewComponentViewModelObserver>

@end


@implementation FHHouseNewComponentView
@synthesize viewModel = _viewModel;

- (void)dealloc {
    [self.viewModel removeObserver:self];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [_viewModel removeObserver:self];
    _viewModel = viewModel;
    [_viewModel addObserver:self];
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if ([self respondsToSelector:@selector(calculateViewHeight:)]) {
        if (viewModel.needCalculateHeight) {
            viewModel.cachedHeight = [self calculateViewHeight:viewModel];
            viewModel.needCalculateHeight = NO;
        }
        return viewModel.cachedHeight;
    }
    
    return 0.0f;
}

@end
