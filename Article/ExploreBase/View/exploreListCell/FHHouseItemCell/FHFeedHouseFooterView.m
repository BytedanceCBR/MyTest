//
//  FHFeedHouseFooterView.m
//  Article
//
//  Created by 张静 on 2018/11/21.
//

#import "FHFeedHouseFooterView.h"
#import "UIColor+Theme.h"

@interface FHFeedHouseHeaderView ()

@property(nonatomic, strong)UILabel *tipLabel;

@end

@implementation FHFeedHouseHeaderView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

-(void)setupUI {
    
    [self addSubview:self.tipLabel];
    self.tipLabel.frame = CGRectMake(20, 18, self.width - 20, self.height - 18);

}

-(void)updateTitle:(NSString *)title {
    
    self.tipLabel.text = title;
}


-(UILabel *)tipLabel {
    
    if (!_tipLabel) {
        
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 18] ? : [UIFont systemFontOfSize:18];
        _tipLabel.textColor = [UIColor themeBlue1];
    }
    
    return _tipLabel;
}

@end


@interface FHFeedHouseFooterView ()

@property(nonatomic, strong)UILabel *tipLabel;
@property(nonatomic, strong)UIImageView *rightArrow;
@property(nonatomic, strong)UIView *line;
//@property(nonatomic, strong)UIView *bottomLine;

@end

@implementation FHFeedHouseFooterView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    
    return self;
}

-(void)setupUI {
    
    [self addSubview:self.line];
    [self addSubview:self.tipLabel];
    [self addSubview:self.rightArrow];
//    [self addSubview:self.bottomLine];

    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(@20);
        make.height.mas_equalTo(@0.5);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@20);
        make.top.mas_equalTo(self.line.mas_bottom);
        make.height.mas_equalTo(47.5);
    }];
    
    [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(@(-15));
        make.centerY.mas_equalTo(self.tipLabel);
    }];
//
//    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.left.right.mas_equalTo(0);
//        make.height.mas_equalTo(@6);
//    }];
}

-(void)updateTitle:(NSString *)title {
    
    self.tipLabel.text = title;
}

-(UIView *)line {
    
    if (!_line) {
        
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor themeGray6];
    }
    return _line;
}

-(UILabel *)tipLabel {
    
    if (!_tipLabel) {
        
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 16] ? : [UIFont systemFontOfSize:16];
        _tipLabel.textColor = [UIColor themeBlue1];
    }
    
    return _tipLabel;
}


-(UIImageView *)rightArrow {
    
    if (!_rightArrow) {
        
        _rightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"feed_arrowicon-detail"]];
    }
    return _rightArrow;
}

//-(UIView *)bottomLine {
//
//    if (!_bottomLine) {
//
//        _bottomLine = [[UIView alloc]init];
//        _bottomLine.backgroundColor = [UIColor themeGray7];
//    }
//    return _bottomLine;
//}

@end
