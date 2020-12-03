//
//  FHHouseListRedirectTipCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseListRedirectTipCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseRedirectTipViewModel.h"
#import "FHHouseNewComponentViewModel+HouseCard.h"

@implementation FHHouseListRedirectTipCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseRedirectTipViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseRedirectTipViewModel.class] ? (FHHouseRedirectTipViewModel *)viewModel : nil;
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
    if (![viewModel isKindOfClass:FHHouseRedirectTipViewModel.class]) return 0.0f;
    FHHouseRedirectTipViewModel *cardViewModel = (FHHouseRedirectTipViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
