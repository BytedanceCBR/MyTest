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

@implementation FHNeighbourhoodAgencyCardCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseNeighborAgencyViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseNeighborAgencyViewModel.class] ? (FHHouseNeighborAgencyViewModel *)viewModel : nil;
    objc_setAssociatedObject(self, &view_model_key, cardViewModel, OBJC_ASSOCIATION_RETAIN);
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
        [self updateHeightByIsFirst:cardViewModel.cardIndex == 0];
    }
}

- (id<FHHouseNewComponentViewModelObserver>)viewModel {
    return objc_getAssociatedObject(self, &view_model_key);
}

- (void)cellWillShowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(showCardAtIndexPath:)]) {
            [cardViewModel showCardAtIndexPath:indexPath];
        }
    }
}


+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseNeighborAgencyViewModel.class]) return 0.0f;
    FHHouseNeighborAgencyViewModel *cardViewModel = (FHHouseNeighborAgencyViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
