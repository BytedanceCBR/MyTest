//
//  FHRecommendSecondhandHouseTitleCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHRecommendSecondhandHouseTitleCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseGuessYouWantViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"

@implementation FHRecommendSecondhandHouseTitleCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseGuessYouWantContentViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseGuessYouWantContentViewModel.class] ? (FHHouseGuessYouWantContentViewModel *)viewModel : nil;
    objc_setAssociatedObject(self, &view_model_key, cardViewModel, OBJC_ASSOCIATION_RETAIN);
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
    }
}

- (id<FHHouseNewComponentViewModelObserver>)viewModel {
    return objc_getAssociatedObject(self, &view_model_key);
}


+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseGuessYouWantContentViewModel.class]) return 0.0f;
    FHHouseGuessYouWantContentViewModel *cardViewModel = (FHHouseGuessYouWantContentViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}
@end
