//
//  FHHousReserveAdviserCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHousReserveAdviserCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseReserveAdviserViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"

@implementation FHHousReserveAdviserCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseReserveAdviserViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseReserveAdviserViewModel.class] ? (FHHouseReserveAdviserViewModel *)viewModel : nil;
    objc_setAssociatedObject(self, &view_model_key, cardViewModel, OBJC_ASSOCIATION_RETAIN);
    if (cardViewModel) {
        [self refreshWithData:cardViewModel.model];
    }
}

- (id<FHHouseNewComponentViewModelObserver>)viewModel {
    return objc_getAssociatedObject(self, &view_model_key);
}

//曝光
- (void)cellWillShowAtIndexPath:(NSIndexPath *)indexPath {
    
}

//结束曝光
- (void)cellDidEndShowAtIndexPath:(NSIndexPath *)indexPath {
    
}

//点击
- (void)cellDidClickAtIndexPath:(NSIndexPath *)indexPath {
    
}

//回到前台
- (void)cellWillEnterForground {
    
}

//进入后台
- (void)cellDidEnterBackground {
    
}


+ (CGFloat)viewHeightWithViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    if (![viewModel isKindOfClass:FHHouseReserveAdviserViewModel.class]) return 0.0f;
    FHHouseReserveAdviserViewModel *cardViewModel = (FHHouseReserveAdviserViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
