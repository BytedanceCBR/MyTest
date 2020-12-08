//
//  FHSuggestionSubscribCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHSuggestionSubscribCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseSubscribeViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"

@implementation FHSuggestionSubscribCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseSubscribeViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseSubscribeViewModel.class] ? (FHHouseSubscribeViewModel *)viewModel : nil;
    objc_setAssociatedObject(self, &view_model_key, cardViewModel, OBJC_ASSOCIATION_RETAIN);
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
        [self updateHeightByIsFirst:cardViewModel.cardIndex == 0];
        
        __weak typeof(self) wself = self;
        self.addSubscribeAction = ^(NSString * _Nonnull subscribeText) {
            [wself requestAddSubScribe:subscribeText];
        };
        
        self.deleteSubscribeAction = ^(NSString * _Nonnull subscribeId) {
            [wself requestDeleteSubScribe:subscribeId];
        };
    }
}

- (id<FHHouseNewComponentViewModelObserver>)viewModel {
    return objc_getAssociatedObject(self, &view_model_key);
}

- (void)requestAddSubScribe:(NSString *)text {
    FHHouseSubscribeViewModel *cardViewModel = [self.viewModel isKindOfClass:FHHouseSubscribeViewModel.class] ? (FHHouseSubscribeViewModel *)self.viewModel : nil;
    [cardViewModel requestAddSubScribe:text];
}

- (void)requestDeleteSubScribe:(NSString *)subscribeId {
    FHHouseSubscribeViewModel *cardViewModel = [self.viewModel isKindOfClass:FHHouseSubscribeViewModel.class] ? (FHHouseSubscribeViewModel *)self.viewModel : nil;
    [cardViewModel requestDeleteSubScribe:subscribeId];
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
    if (![viewModel isKindOfClass:FHHouseSubscribeViewModel.class]) return 0.0f;
    FHHouseSubscribeViewModel *cardViewModel = (FHHouseSubscribeViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
