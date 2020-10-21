//
//  FHNeighborhoodDetailHouseSaleTitleView.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/16.
//

#import "FHNeighborhoodDetailHouseSaleTitleView.h"
#import <Masonry/Masonry.h>


@implementation FHNeighborhoodDetailHouseSaleTitleView

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.height.mas_equalTo(25);
            make.bottom.equalTo(self.mas_bottom).offset(-16);
        }];
    }
    return self;
}

@end
