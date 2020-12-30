//
//  FHNeighbourhoodAgencyCardCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHNeighbourhoodAgencyCardCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseNeighborAgencyViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHListBaseCell+HouseCard.h"

@implementation FHNeighbourhoodAgencyCardCell(HouseCard)

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseNeighborAgencyViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseNeighborAgencyViewModel.class] ? (FHHouseNeighborAgencyViewModel *)viewModel : nil;
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
    }
}


+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseNeighborAgencyViewModel.class]) return 0.0f;
    FHHouseNeighborAgencyViewModel *cardViewModel = (FHHouseNeighborAgencyViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
