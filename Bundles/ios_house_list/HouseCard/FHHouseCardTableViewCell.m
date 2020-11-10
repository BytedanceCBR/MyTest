//
//  FHHouseCardTableViewCell.m
//  ABRInterface
//
//  Created by bytedance on 2020/11/10.
//

#import "FHHouseCardTableViewCell.h"
#import "FHHouseNewComponentViewModel.h"

@interface FHHouseCardTableViewCell()<FHHouseNewComponentViewModelObserver>

@end

@implementation FHHouseCardTableViewCell
@synthesize viewModel = _viewModel;

- (void)dealloc {
    [self.viewModel removeObserver:self];
}

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [_viewModel removeObserver:self];
    _viewModel = viewModel;
    [_viewModel addObserver:self];
}

- (void)cellWillShowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)cellDidClickAtIndexPath:(NSIndexPath *)indexPath {
    
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    return 0.0f;
}

@end
