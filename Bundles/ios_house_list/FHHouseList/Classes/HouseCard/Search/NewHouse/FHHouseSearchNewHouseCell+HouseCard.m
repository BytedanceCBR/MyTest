//
//  FHHouseSearchNewHouseCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseSearchNewHouseCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseSearchNewHouseViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"

@implementation FHHouseSearchNewHouseCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseSearchNewHouseViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseSearchNewHouseViewModel.class] ? (FHHouseSearchNewHouseViewModel *)viewModel : nil;
    objc_setAssociatedObject(self, &view_model_key, cardViewModel, OBJC_ASSOCIATION_RETAIN);
    if (cardViewModel) {
//        self.backgroundColor = [UIColor themeGray7];
        [self updateHeightByIsFirst:cardViewModel.cardIndex == 0];
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
    if (![viewModel isKindOfClass:FHHouseSearchNewHouseViewModel.class]) return 0.0f;
    FHHouseSearchNewHouseViewModel *cardViewModel = (FHHouseSearchNewHouseViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
