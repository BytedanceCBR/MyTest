//
//  FHMyJoinNeighbourhoodView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHMyJoinNeighbourhoodView.h"

@implementation FHMyJoinNeighbourhoodView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
    self.backgroundColor = [UIColor greenColor];
//    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray4]];
//    [self addSubview:_descLabel];
//
//    self.moreBtn = [[UIButton alloc] init];
//    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
//    [self addSubview:_moreBtn];
}

- (void)initConstraints {
//    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self).offset(20);
//        make.top.bottom.mas_equalTo(self);
//        make.right.mas_equalTo(self.moreBtn.mas_left).offset(-20);
//
//    }];
//
//    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo(20);
//        make.right.mas_equalTo(self).offset(-18);
//    }];
}

@end
