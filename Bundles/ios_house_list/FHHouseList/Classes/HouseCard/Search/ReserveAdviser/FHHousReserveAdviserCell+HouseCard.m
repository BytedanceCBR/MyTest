//
//  FHHousReserveAdviserCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHousReserveAdviserCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseReserveAdviserViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHListBaseCell+HouseCard.h"

@implementation FHHousReserveAdviserCell(HouseCard)

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseReserveAdviserViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseReserveAdviserViewModel.class] ? (FHHouseReserveAdviserViewModel *)viewModel : nil;
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
    }
}


+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseReserveAdviserViewModel.class]) return 0.0f;
    FHHouseReserveAdviserViewModel *cardViewModel = (FHHouseReserveAdviserViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
