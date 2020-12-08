//
//  FHFindHouseHelperCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHFindHouseHelperCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseFindHouseHelperViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "UIColor+Theme.h"

@implementation FHFindHouseHelperCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseFindHouseHelperViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseFindHouseHelperViewModel.class] ? (FHHouseFindHouseHelperViewModel *)viewModel : nil;
    objc_setAssociatedObject(self, &view_model_key, cardViewModel, OBJC_ASSOCIATION_RETAIN);
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
        __weak typeof(self) wself = self;
        self.cellTapAction = ^(NSString * _Nonnull url) {
            [wself cellDidClickAtIndexPath:nil];
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
    if (![viewModel isKindOfClass:FHHouseFindHouseHelperViewModel.class]) return 0.0f;
    FHHouseFindHouseHelperViewModel *cardViewModel = (FHHouseFindHouseHelperViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
