//
//  FHNeighborhoodDetailRecommendTitleView.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/10/15.
//

#import "FHNeighborhoodDetailRecommendTitleView.h"
#import "Masonry.h"

@implementation FHNeighborhoodDetailRecommendTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
        }];
    }
    return self;
}

@end
