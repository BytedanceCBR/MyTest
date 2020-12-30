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
#import "FHListBaseCell+HouseCard.h"

@implementation FHFindHouseHelperCell(HouseCard)

- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseFindHouseHelperViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseFindHouseHelperViewModel.class] ? (FHHouseFindHouseHelperViewModel *)viewModel : nil;
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        [self refreshWithData:cardViewModel.model];
        __weak typeof(self) wself = self;
        self.cellTapAction = ^(NSString * _Nonnull url) {
            [wself cellDidClickAtIndexPath:nil];
        };
    }
}


+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseFindHouseHelperViewModel.class]) return 0.0f;
    FHHouseFindHouseHelperViewModel *cardViewModel = (FHHouseFindHouseHelperViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
