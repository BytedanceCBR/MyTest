//
//  FHHouseListErrorView.m
//  FHHouseList
//
//  Created by bytedance on 2020/11/26.
//

#import "FHHouseListErrorView.h"

@implementation FHHouseListErrorView

- (void)showEmptyWithType:(FHEmptyMaskViewType)maskViewType {
    if (maskViewType == FHEmptyMaskViewTypeNoData) {
        [self showEmptyWithTip:@"数据走丢了" errorImageName:kFHErrorMaskNoDataImageName showRetry:YES];
        return;
    }
    
    [super showEmptyWithType:maskViewType];
}

@end
