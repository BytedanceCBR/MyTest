//
//  FHHousePlaceholderCell.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/1.
//

#import "FHHousePlaceholderCell.h"
#import "FHHousePlaceholderViewModel.h"

@implementation FHHousePlaceholderStyle1Cell

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHousePlaceholderStyle1ViewModel.class]) return 0.0f;
    return 88;
}

@end

@implementation FHHousePlaceholderStyle2Cell

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    _viewModel = viewModel;
    FHHousePlaceholderStyle2ViewModel *cardViewModel = [viewModel isKindOfClass:FHHousePlaceholderStyle2ViewModel.class] ? (FHHousePlaceholderStyle2ViewModel *)viewModel : nil;
    if (cardViewModel) {
        self.topOffset = cardViewModel.topOffset;
    }
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHousePlaceholderStyle2ViewModel.class]) return 0.0f;
    return 124;
}


@end

@implementation FHHousePlaceholderStyle3Cell

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHousePlaceholderStyle3ViewModel.class]) return 0.0f;
    return 105;
}

@end
