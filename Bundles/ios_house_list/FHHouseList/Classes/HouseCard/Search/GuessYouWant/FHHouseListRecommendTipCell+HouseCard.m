//
//  FHHouseListRecommendTipCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseListRecommendTipCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseGuessYouWantViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "TTBaseMacro.h"

@implementation FHHouseListRecommendTipCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseGuessYouWantTipViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseGuessYouWantTipViewModel.class] ? (FHHouseGuessYouWantTipViewModel *)viewModel : nil;
    objc_setAssociatedObject(self, &view_model_key, cardViewModel, OBJC_ASSOCIATION_RETAIN);
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
        WeakSelf;
        self.channelSwitchBlock = ^{
            StrongSelf;
            [self handleChannelSwitch];
        };
    }
}

- (void)handleChannelSwitch {
    FHHouseGuessYouWantTipViewModel *cardViewModel = [self.viewModel isKindOfClass:FHHouseGuessYouWantTipViewModel.class] ? (FHHouseGuessYouWantTipViewModel *)self.viewModel : nil;
    [cardViewModel handleChannelSwitch];
}

- (id<FHHouseNewComponentViewModelObserver>)viewModel {
    return objc_getAssociatedObject(self, &view_model_key);
}


+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseGuessYouWantTipViewModel.class]) return 0.0f;
    FHHouseGuessYouWantTipViewModel *cardViewModel = (FHHouseGuessYouWantTipViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
