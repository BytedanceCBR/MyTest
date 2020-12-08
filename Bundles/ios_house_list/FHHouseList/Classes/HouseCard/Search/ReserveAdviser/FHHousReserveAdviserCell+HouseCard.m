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

@implementation FHHousReserveAdviserCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseReserveAdviserViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseReserveAdviserViewModel.class] ? (FHHouseReserveAdviserViewModel *)viewModel : nil;
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
    if (![viewModel isKindOfClass:FHHouseReserveAdviserViewModel.class]) return 0.0f;
    FHHouseReserveAdviserViewModel *cardViewModel = (FHHouseReserveAdviserViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
