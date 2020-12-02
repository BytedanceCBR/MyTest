//
//  FHHouseSearchSecondHouseCell+HouseCard.m
//  FHHouseList
//
//  Created by bytedance on 2020/12/1.
//

#import "FHHouseSearchSecondHouseCell+HouseCard.h"
#import <objc/runtime.h>
#import "FHHouseSearchSecondHouseViewModel.h"

@implementation FHHouseSearchSecondHouseCell(HouseCard)

static const char view_model_key;
- (void)setViewModel:(id<FHHouseNewComponentViewModelProtocol>)viewModel {
    FHHouseSearchSecondHouseViewModel *cardViewModel = [viewModel isKindOfClass:FHHouseSearchSecondHouseViewModel.class] ? (FHHouseSearchSecondHouseViewModel *)viewModel : nil;
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
    if (![viewModel isKindOfClass:FHHouseSearchSecondHouseViewModel.class]) return 0.0f;
    FHHouseSearchSecondHouseViewModel *cardViewModel = (FHHouseSearchSecondHouseViewModel *)viewModel;
    return [self heightForData:cardViewModel.model];
}

@end
