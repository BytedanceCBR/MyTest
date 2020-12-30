//
//  FHDetailPlaceHolderView.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/12/20.
//

#import "FHDetailPlaceHolderView.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
@interface FHDetailPlaceHolderView()
@property (copy, nonatomic) UIView *bacView;
@property (copy, nonatomic) UIImageView *iconView;
@property (copy, nonatomic) UIImageView *placeCard1;
@property (copy, nonatomic) UIImageView *placeCard2;
@property (copy, nonatomic) UIImageView *placeCard3;
@property (copy, nonatomic) UIImageView *placeBottom;
@end
@implementation FHDetailPlaceHolderView

- (instancetype)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [self.bacView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.bacView);
        make.height.mas_offset(width * 52/75);
    }];
    [self.placeCard1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).offset(12);
        make.left.equalTo(self.bacView).offset(9);
        make.right.equalTo(self.bacView.mas_right).offset(-9);
        make.height.mas_offset((width-18) * 198/357);
    }];
    [self.placeCard2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.placeCard1.mas_bottom).offset(12);
        make.left.equalTo(self.bacView).offset(9);
        make.right.equalTo(self.bacView.mas_right).offset(-9);
        make.height.mas_offset((width-18) * 198/357);
    }];
    [self.placeCard3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.placeCard2.mas_bottom).offset(12);
        make.left.equalTo(self.bacView).offset(9);
        make.right.equalTo(self.bacView.mas_right).offset(-9);
        make.height.mas_offset((width-18) * 174/357);
    }];
    [self.placeBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.equalTo(self.bacView);
        make.height.mas_offset(width* 16/75);
    }];
}

- (UIView *)bacView {
    if (!_bacView) {
        UIView *bacView = [[UIView alloc]init];
        bacView.clipsToBounds = YES;
        bacView.backgroundColor = [UIColor themeGray7];
        [self addSubview:bacView];
        _bacView = bacView;
    }
    return _bacView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        UIImageView *iconImage = [[UIImageView alloc]init];
        iconImage.image  = [UIImage imageNamed:@"detai_loading_icon"];
        [self.bacView addSubview:iconImage];
        _iconView = iconImage;
    }
    return _iconView;
}
- (UIImageView *)placeCard1 {
    if (!_placeCard1) {
        UIImageView *placeCard1 = [[UIImageView alloc]init];
        placeCard1.image  = [UIImage imageNamed:@"detai_loading_view_1"];
        [self.bacView addSubview:placeCard1];
        _placeCard1 = placeCard1;
    }
    return _placeCard1;
}
- (UIImageView *)placeCard2 {
    if (!_placeCard2) {
        UIImageView *placeCard2 = [[UIImageView alloc]init];
        placeCard2.image  = [UIImage imageNamed:@"detai_loading_view_2"];
        [self.bacView addSubview:placeCard2];
        _placeCard2 = placeCard2;
    }
    return _placeCard2;
}
- (UIImageView *)placeCard3 {
    if (!_placeCard3) {
        UIImageView *placeCard3 = [[UIImageView alloc]init];
        placeCard3.image  = [UIImage imageNamed:@"detai_loading_view_3"];
        [self.bacView addSubview:placeCard3];
        _placeCard3 = placeCard3;
    }
    return _placeCard3;
}
- (UIImageView *)placeBottom {
    if (!_placeBottom) {
        UIImageView *placeBottom = [[UIImageView alloc]init];
        placeBottom.image  = [UIImage imageNamed:@"detai_loading_view_4"];
        [self.bacView addSubview:placeBottom];
        _placeBottom = placeBottom;
    }
    return _placeBottom;
}

@end
