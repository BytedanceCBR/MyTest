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
#import "FHListBaseCell+HouseCard.h"

@implementation FHRecommendSecondhandHouseTitleCell(HouseCard)

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseGuessYouWantContentViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseGuessYouWantContentViewModel.class] ? (FHHouseGuessYouWantContentViewModel *)viewModel : nil;
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
    }
}

+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseGuessYouWantContentViewModel.class]) return 0.0f;
    FHHouseGuessYouWantContentViewModel *cardViewModel = (FHHouseGuessYouWantContentViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}
@end
