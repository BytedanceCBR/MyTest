//
//  FHDynamicLynxCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHDynamicLynxCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseLynxViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHListBaseCell+HouseCard.h"

@implementation FHDynamicLynxCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    [super setViewModel:viewModel];
    FHHouseLynxViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseLynxViewModel.class] ? (FHHouseLynxViewModel *)viewModel : nil;
    if (cardViewModel) {
        self.backgroundColor = [UIColor clearColor];
        FHDynamicLynxCellModel *cellModel = cardViewModel.model;
        if (cellModel && [cellModel isKindOfClass:[FHDynamicLynxCellModel class]]) {
            cellModel.cell = self;
            [self updateWithCellModel:cellModel];
        }
        [self refreshWithData:cardViewModel.model];
    }
}


+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseLynxViewModel.class]) return 0.0f;
    FHHouseLynxViewModel *cardViewModel = (FHHouseLynxViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
