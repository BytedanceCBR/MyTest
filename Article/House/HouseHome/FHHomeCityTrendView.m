//
//  FHHomeCityTrendView.m
//  Article
//
//  Created by 谢飞 on 2018/11/20.
//

#import "FHHomeCityTrendView.h"
#import "UIColor+Theme.h"
#import "FHHomeTrendItemView.h"
#import "FHConfigModel.h"
#import "UIFont+House.h"

@interface FHHomeCityTrendView()

@property(nonatomic, strong) UIImageView *bgView;

@property(nonatomic, strong) FHHomeTrendItemView *leftView;

@property(nonatomic, strong) UIView *line;

@property(nonatomic, strong) UIControl *rightBtn;
@property(nonatomic, strong) FHHomeTrendItemView *centerView;
@property(nonatomic, strong) FHHomeTrendItemView *rightView;
@property(nonatomic, strong) UIImageView *rightArrow;


@end

@implementation FHHomeCityTrendView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self setupUI];
    
    }
    return self;
}

-(void)setupUI {
    
    [self addSubview:self.bgView];

    [self addSubview:self.leftView];
    WeakSelf;
    self.leftView.btn.hidden = NO;
    self.leftView.clickedCallback = ^(UIButton *btn) {
        
        [wself leftBtnDidClick:btn];

    };
    [self addSubview:self.line];
    
    [self addSubview:self.rightBtn];
    [self.rightBtn addTarget:self action:@selector(rightBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.centerView];
    [self addSubview:self.rightView];
    [self addSubview:self.rightArrow];

}

-(void)leftBtnDidClick:(UIButton *)btn {
    
    if (self.clickedLeftCallback) {
        self.clickedLeftCallback(btn);
    }

}


-(void)rightBtnDidClick:(UIControl *)btn {
    
    if (self.clickedRightCallback) {
        self.clickedRightCallback();
    }
}

-(void)updateWithModel:(FHConfigDataCityStatsModel *)model {
    
    self.leftView.titleLabel.text = [NSString stringWithFormat:@"%@%@",model.cityName,model.cityTitleDesc];
    self.leftView.subtitleLabel.text = [NSString stringWithFormat:@"%@",model.cityDetailDesc];
    self.leftView.icon.image = [UIImage imageNamed:@"home_setting-arrow"];
    self.leftView.leftPadding = 20;
    self.leftView.rightPadding = 10;
    
    NSString *priceStr = [NSString stringWithFormat:@"%@ %@",model.pricingPerSqm,model.pricingPerSqmUnit];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:priceStr];
    [attr addAttributes:@{NSFontAttributeName: [UIFont themeFontRegular:18]} range:[priceStr rangeOfString:model.pricingPerSqm]];
    [attr addAttributes:@{NSFontAttributeName: [UIFont themeFontRegular:10]} range:[priceStr rangeOfString:model.pricingPerSqmUnit]];
    self.centerView.titleLabel.attributedText = attr;
    
    if (model.monthUp.doubleValue > 0.0001f) {
        self.centerView.icon.image = [UIImage imageNamed:@"home_red_arrow"];
        self.centerView.icon.hidden = NO;
        self.centerView.subtitleLabel.hidden = NO;
        NSString *monthUpStr = [NSString stringWithFormat:@"%.2f",ABS(model.monthUp.floatValue * 100)];
        float monthUp = monthUpStr.floatValue;
        if (fmodf(monthUp * 10, 1) == 0) {
            
            self.centerView.subtitleLabel.text = [NSString stringWithFormat:@"%@ %.1f%%",model.pricingPerSqmDesc, monthUp];
        }else {
            
            self.centerView.subtitleLabel.text = [NSString stringWithFormat:@"%@ %.2f%%",model.pricingPerSqmDesc, monthUp];
        }

    }else if (model.monthUp.doubleValue < -0.0001f) {
        self.centerView.icon.image = [UIImage imageNamed:@"home_green_arrow"];
        self.centerView.icon.hidden = NO;
        self.centerView.subtitleLabel.hidden = NO;
        NSString *monthUpStr = [NSString stringWithFormat:@"%.2f",ABS(model.monthUp.floatValue * 100)];
        float monthUp = monthUpStr.floatValue;
        if (fmodf(monthUp * 10, 1) == 0) {
            
            self.centerView.subtitleLabel.text = [NSString stringWithFormat:@"%@ %.1f%%",model.pricingPerSqmDesc, ABS(model.monthUp.doubleValue * 100)];
        }else {
            
            self.centerView.subtitleLabel.text = [NSString stringWithFormat:@"%@ %.2f%%",model.pricingPerSqmDesc, ABS(model.monthUp.doubleValue * 100)];
        }

    }else {
        self.centerView.icon.hidden = YES;
        self.centerView.subtitleLabel.hidden = YES;

    }
    
    NSString *numStr = [NSString stringWithFormat:@"%@ %@",model.addedNumToday, model.addedNumTodayUnit];
    NSMutableAttributedString *numAttr = [[NSMutableAttributedString alloc]initWithString:numStr];
    [numAttr addAttributes:@{NSFontAttributeName: [UIFont themeFontRegular:18]} range:[numStr rangeOfString:model.addedNumToday]];
    [numAttr addAttributes:@{NSFontAttributeName: [UIFont themeFontRegular:10]} range:[numStr rangeOfString:model.addedNumTodayUnit]];
    
    self.rightView.titleLabel.attributedText = numAttr;
    self.rightView.subtitleLabel.text = [NSString stringWithFormat:@"%@",model.addedNumTodayDesc];
    
}
-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.bgView.frame = self.bounds;
    
    self.leftView.frame = CGRectMake(0, 0, 120, self.height);
    self.line.size = CGSizeMake(1, 38);
    self.line.left = self.leftView.right;
    self.line.centerY = self.leftView.centerY;
    
    self.rightArrow.size = CGSizeMake(18, 18);
    self.rightArrow.left = self.width - 15 - self.rightArrow.width;
    self.rightArrow.centerY = self.leftView.centerY;
    
    CGFloat itemWidth = (self.rightArrow.left - self.line.right - 20) / 2;
    self.centerView.frame = CGRectMake(self.line.right, 0, itemWidth, self.height);
    self.rightView.frame = CGRectMake(self.centerView.right, 0, itemWidth, self.height);

}

-(UIImageView *)bgView {
    
    if (!_bgView) {
        _bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"home_city_bg"]];
        _bgView.contentMode = UIViewContentModeScaleToFill;
        _bgView.clipsToBounds = true;
    }
    return _bgView;
}

-(FHHomeTrendItemView *)leftView {
    
    if (!_leftView) {
        
        _leftView = [[FHHomeTrendItemView alloc]init];
    }
    return _leftView;
}

-(UIView *)line {
    
    if (!_line) {
        
        _line = [[UIView alloc]init];
        _line.backgroundColor = [UIColor themeGrayPale];
    }
    return _line;
}

-(UIControl *)rightBtn {
    
    if (!_rightBtn) {
        _rightBtn = [[UIControl alloc]init];
    }
    return _rightBtn;
}

-(FHHomeTrendItemView *)centerView {
    
    if (!_centerView) {
        
        _centerView = [[FHHomeTrendItemView alloc]init];
    }
    return _centerView;
}


-(FHHomeTrendItemView *)rightView {
    
    if (!_rightView) {
        
        _rightView = [[FHHomeTrendItemView alloc]init];
    }
    return _rightView;
}

-(UIImageView *)rightArrow {
    
    if (!_rightArrow) {
        _rightArrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"home_arrowicon_feed"]];
    }
    return _rightArrow;
}

@end
