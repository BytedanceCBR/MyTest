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

@implementation FHHouseListRedirectTipCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseRedirectTipViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseRedirectTipViewModel.class] ? (FHHouseRedirectTipViewModel *)viewModel : nil;
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
    if (![viewModel isKindOfClass:FHHouseRedirectTipViewModel.class]) return 0.0f;
    FHHouseRedirectTipViewModel *cardViewModel = (FHHouseRedirectTipViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
