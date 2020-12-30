//
//  FHListBaseCell+HouseCard.m
//  ABRInterface
//
//  Created by bytedance on 2020/12/14.
//

#import "FHListBaseCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseCardCellViewModelProtocol.h"

@implementation FHListBaseCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    objc_setAssociatedObject(self, &view_model_key, viewModel, OBJC_ASSOCIATION_RETAIN);
}

- (id<FHHouseNewComponentViewModelProtocol>)viewModel {
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

- (void)cellDidEndShowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(hideCardAtIndexPath:)]) {
            [cardViewModel hideCardAtIndexPath:indexPath];
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

- (void)cellWillEnterForground {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(cardWillEnterForground)]) {
            [cardViewModel cardWillEnterForground];
        }
    }
}

- (void)cellDidEnterBackground {
    if ([self.viewModel conformsToProtocol:@protocol(FHHouseCardCellViewModelProtocol)]) {
        id<FHHouseCardCellViewModelProtocol> cardViewModel = (id<FHHouseCardCellViewModelProtocol>)self.viewModel;
        if ([cardViewModel respondsToSelector:@selector(cardDidEnterBackground)]) {
            [cardViewModel cardDidEnterBackground];
        }
    }
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    return 0.0f;
}

@end
