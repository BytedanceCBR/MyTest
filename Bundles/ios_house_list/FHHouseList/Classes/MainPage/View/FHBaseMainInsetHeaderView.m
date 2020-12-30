//
//  FHBaseMainInsetHeaderView.m
//  FHHouseList
//
//  Created by xubinbin on 2020/12/25.
//

#import "FHBaseMainInsetHeaderView.h"

@implementation FHBaseMainInsetHeaderViewModel


@end

@implementation FHBaseMainInsetHeaderView

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHBaseMainInsetHeaderViewModel.class]) return CGFLOAT_MIN;
    return 5.0f;
}

@end
