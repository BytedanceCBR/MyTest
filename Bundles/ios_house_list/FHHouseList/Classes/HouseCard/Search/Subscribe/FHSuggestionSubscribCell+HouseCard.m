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
#import "FHListBaseCell+HouseCard.h"

@implementation FHSuggestionSubscribCell(HouseCard)

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseSubscribeViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseSubscribeViewModel.class] ? (FHHouseSubscribeViewModel *)viewModel : nil;
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

- (void)requestAddSubScribe:(NSString *)text {
    FHHouseSubscribeViewModel *cardViewModel = [self.viewModel isKindOfClass:FHHouseSubscribeViewModel.class] ? (FHHouseSubscribeViewModel *)self.viewModel : nil;
    [cardViewModel requestAddSubScribe:text];
}

- (void)requestDeleteSubScribe:(NSString *)subscribeId {
    FHHouseSubscribeViewModel *cardViewModel = [self.viewModel isKindOfClass:FHHouseSubscribeViewModel.class] ? (FHHouseSubscribeViewModel *)self.viewModel : nil;
    [cardViewModel requestDeleteSubScribe:subscribeId];
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseSubscribeViewModel.class]) return 0.0f;
    FHHouseSubscribeViewModel *cardViewModel = (FHHouseSubscribeViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
