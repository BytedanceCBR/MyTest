//
//  FHNeighborhoodDetailFloorpanTitleView.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/16.
//

#import "FHNeighborhoodDetailFloorpanTitleView.h"
#import <Masonry/Masonry.h>

@implementation FHNeighborhoodDetailFloorpanTitleView

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.height.mas_equalTo(25);
            make.bottom.equalTo(self.mas_bottom).offset(-12);
        }];
    }
    return self;
}

@end
