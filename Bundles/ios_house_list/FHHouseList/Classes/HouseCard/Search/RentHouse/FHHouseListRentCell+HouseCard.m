//
//  FHHouseListRentCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseListRentCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseSearchRentHouseViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"

@implementation FHHouseListRentCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseSearchRentHouseViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseSearchRentHouseViewModel.class] ? (FHHouseSearchRentHouseViewModel *)viewModel : nil;
    objc_setAssociatedObject(self, &view_model_key, cardViewModel, OBJC_ASSOCIATION_RETAIN);
    if (cardViewModel) {
        [self refreshWithData:cardViewModel.model];
        __weak typeof(self) wSelf = self;
        cardViewModel.opacityDidChange = ^{
            [wSelf refreshOpacityWithData:wSelf.model];
        };
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

- (void)cellDidClickAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(clickCardAtIndexPath:)]) {
            [cardViewModel clickCardAtIndexPath:indexPath];
        }
    }
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseSearchRentHouseViewModel.class]) return 0.0f;
    FHHouseSearchRentHouseViewModel *cardViewModel = (FHHouseSearchRentHouseViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
