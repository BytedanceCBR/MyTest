//
//  FHHouseListRedirectTipCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseListRedirectTipCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseRedirectTipViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHListBaseCell+HouseCard.h"

@implementation FHHouseListRedirectTipCell(HouseCard)

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseRedirectTipViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseRedirectTipViewModel.class] ? (FHHouseRedirectTipViewModel *)viewModel : nil;
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
    }
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseRedirectTipViewModel.class]) return 0.0f;
    FHHouseRedirectTipViewModel *cardViewModel = (FHHouseRedirectTipViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
