//
//  FHHouseAreaHeaderView.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHHouseAreaHeaderView.h"
#import "UIColor+Theme.h"
#import <Masonry/Masonry.h>
@interface FHHouseAreaHeaderView ()

@property(nonatomic , strong) UIView *topTipView;
@property(nonatomic , strong) UILabel *nameLabel;
@property(nonatomic , strong) UILabel *locationLabel;
@property(nonatomic , strong) UILabel *priceLabel;
@property(nonatomic , strong) UIImageView *indicatorImgView;

@end

@implementation FHHouseAreaHeaderView

-(UILabel *)labelColor:(UIColor *)color fontSize:(CGFloat)fontSize
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:fontSize];
    return label;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _topTipView = [[UIView alloc] init];
        _topTipView.backgroundColor = [UIColor themeGrayPale];
        
        _nameLabel = [self labelColor:[UIColor themeBlack] fontSize:20];
        _locationLabel = [self labelColor:[UIColor themeGray] fontSize:12 ];
        _priceLabel = [self labelColor:[UIColor themeRed] fontSize:16];
        
        UIImage *img = [UIImage imageNamed:@"indicator"];
        _indicatorImgView = [[UIImageView alloc] initWithImage:img];
        
        [self addSubview:_topTipView];
        [self addSubview:_nameLabel];
        [self addSubview:_locationLabel];
        [self addSubview:_priceLabel];
        [self addSubview:_indicatorImgView];
        
        [self initConstraints];
        
    }
    return self;
}

-(void)initConstraints
{
    [_topTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(4);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(24, 3));
    }];
    
    [_indicatorImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.right.mas_equalTo(self).offset(-21);
    }];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(_indicatorImgView.mas_left).offset(-10);
        make.width.mas_lessThanOrEqualTo(100);
//        make.height.mas_equalTo(22);
    }];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
        make.right.mas_lessThanOrEqualTo(_priceLabel).offset(-10);
//        make.height.mas_equalTo(28);
    }];
    [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_nameLabel);
        make.top.mas_equalTo(_nameLabel.mas_bottom).offset(2);
        make.right.mas_lessThanOrEqualTo(_priceLabel).offset(-10);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
