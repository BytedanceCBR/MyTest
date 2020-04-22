 //
//  FHDetailHalfPopLogoHeader.m
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import "FHDetailHalfPopLogoHeader.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import <Masonry/Masonry.h>

@interface FHDetailHalfPopLogoHeader ()

@property(nonatomic , strong)UIImageView *iconImgView;
@property(nonatomic , strong)UILabel *titleLabel;
@property(nonatomic , strong)UILabel *tipLabel;
@property(nonatomic , assign)FHDetailHalfPopType halfPopType;

@end

@implementation FHDetailHalfPopLogoHeader

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self initConstraints];
    }
    return self;
}

- (instancetype)initWithHalfPopType:(FHDetailHalfPopType)halfPopType
{
    _halfPopType = halfPopType;
    self = [super initWithFrame:CGRectZero];
    if(self) {
        [self setupUI];
        if (halfPopType == FHDetailHalfPopTypeLeft) {
            [self initLeftConstraints];
        }else {
            [self initConstraints];
        }
    }
    return self;
}

- (void)setupUI
{
    _iconImgView = [[UIImageView alloc] init];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontSemibold:20];
    _titleLabel.textColor = [UIColor themeOrange4];
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.textColor = [UIColor themeGray3];
    _tipLabel.font = [UIFont themeFontRegular:12];
    
    [self addSubview:_iconImgView];
    [self addSubview:_titleLabel];
    [self addSubview:_tipLabel];
}
- (void)initConstraints
{
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.mas_equalTo(self).offset(10);
        make.height.mas_equalTo(28);
    }];
    
    [_iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(24, 24));
        make.right.mas_equalTo(self.titleLabel.mas_left).offset(-2);
    }];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
        make.centerX.mas_equalTo(self);
    }];
}

- (void)initLeftConstraints
{
    _iconImgView.hidden = YES;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(20);
        make.height.mas_equalTo(28);
    }];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
        make.left.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(20);
    }];
}

-(void)updateWithTitle:(NSString *)title tip:(NSString *)tip imgUrl:(NSString *)imgUrl
{
    self.titleLabel.text = title;
    self.tipLabel.text = tip;
    
    [self.titleLabel sizeToFit];
    [self.tipLabel sizeToFit];
    
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(CGRectGetWidth(self.titleLabel.bounds));
    }];
    [_tipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(CGRectGetWidth(self.tipLabel.bounds));
    }];
    
    [self.iconImgView bd_setImageWithURL:[NSURL URLWithString:imgUrl]];
}

- (void)updateWithTitle:(NSString *)title tip:(NSString *)tip
{
    self.titleLabel.text = title;
    self.tipLabel.text = tip;
    self.iconImgView.hidden = YES;
    self.tipLabel.font = [UIFont themeFontRegular:14];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
