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
    return 0.0f;
}

@end
