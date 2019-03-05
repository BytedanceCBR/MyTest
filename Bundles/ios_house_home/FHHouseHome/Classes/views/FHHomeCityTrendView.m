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
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "TTBaseMacro.h"

@interface FHHomeCityTrendView()

@property(nonatomic, strong) UIImageView *bgView;

@property(nonatomic, strong) FHHomeTrendItemView *leftView;

@property(nonatomic, strong) UIView *line;

@property(nonatomic, strong) UIControl *rightBtn;
@property(nonatomic, strong) FHHomeTrendItemView *centerView;
@property(nonatomic, strong) FHHomeTrendItemView *rightView;
@property(nonatomic, strong) UIImageView *rightArrow;

@property(nonatomic, assign) CGFloat largeFontSize;
@property(nonatomic, assign) CGFloat smallFontSize;
@property(nonatomic, assign) CGFloat subtitleFontSize;

@end

@implementation FHHomeCityTrendView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.largeFontSize = 18.0;
        self.smallFontSize = 10.0;
        self.subtitleFontSize = 10.0;

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
    
    [self addSubview:self.centerView];
    [self addSubview:self.rightView];
    [self addSubview:self.rightArrow];

    [self addSubview:self.rightBtn];
    [self.rightBtn addTarget:self action:@selector(rightBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];

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
    
    self.leftView.titleLabel.font = [UIFont themeFontRegular:self.largeFontSize];
    self.leftView.subtitleLabel.font = [UIFont themeFontRegular:self.subtitleFontSize];
    self.centerView.subtitleLabel.font = [UIFont themeFontRegular:self.subtitleFontSize];
    self.rightView.subtitleLabel.font = [UIFont themeFontRegular:self.subtitleFontSize];

    self.leftView.titleLabel.text = [NSString stringWithFormat:@"%@%@",model.cityName,model.cityTitleDesc];
    self.leftView.subtitleLabel.text = [NSString stringWithFormat:@"%@",model.cityDetailDesc];
    self.leftView.icon.image = [UIImage imageNamed:@"home_setting_arrow"];
    self.leftView.leftPadding = 20 * WIDTHSCALE;
    self.leftView.rightPadding = 10 * WIDTHSCALE;
    
    CGFloat largeFontSize = self.largeFontSize;
    CGFloat smallFontSize = self.smallFontSize;
    if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
        
        largeFontSize = 16.f;
        smallFontSize = 9.f;

    }

    UIFont *largeFont = [UIFont themeFontRegular:largeFontSize];
    UIFont *smallFont = [UIFont themeFontRegular:smallFontSize];

    self.leftView.titleLabel.font = largeFont;
    self.leftView.subtitleLabel.font = smallFont;
    [self.leftView.titleLabel sizeToFit];
    [self.leftView.subtitleLabel sizeToFit];

    NSString *priceStr = [NSString stringWithFormat:@"%@ %@",model.pricingPerSqm,model.pricingPerSqmUnit];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:priceStr];
    [attr addAttributes:@{NSFontAttributeName: largeFont} range:[priceStr rangeOfString:model.pricingPerSqm]];
    [attr addAttributes:@{NSFontAttributeName: smallFont} range:[priceStr rangeOfString:model.pricingPerSqmUnit]];
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
        [self.centerView.subtitleLabel sizeToFit];
        [self.centerView.icon sizeToFit];
    }else {
        self.centerView.icon.hidden = YES;
        self.centerView.subtitleLabel.hidden = YES;
    }
    
    [self.centerView.titleLabel sizeToFit];
    [self.centerView.subtitleLabel sizeToFit];
    [self.centerView.icon sizeToFit];

    NSString *numStr = [NSString stringWithFormat:@"%@ %@",model.addedNumToday, model.addedNumTodayUnit];
    NSMutableAttributedString *numAttr = [[NSMutableAttributedString alloc]initWithString:numStr];
    [numAttr addAttributes:@{NSFontAttributeName: largeFont} range:[numStr rangeOfString:model.addedNumToday]];
    [numAttr addAttributes:@{NSFontAttributeName: smallFont} range:[numStr rangeOfString:model.addedNumTodayUnit]];
    
    self.rightView.titleLabel.attributedText = numAttr;
    self.rightView.subtitleLabel.text = [NSString stringWithFormat:@"%@",model.addedNumTodayDesc];
    [self.rightView.titleLabel sizeToFit];
    [self.rightView.subtitleLabel sizeToFit];

}

-(void)updateTrendFont:(BOOL)isSmallSize {
    
    if (isSmallSize) {
        
        self.largeFontSize = 16;
        self.smallFontSize = 12;
        self.subtitleFontSize = 12;

    }else {
        self.largeFontSize = 18;
        self.smallFontSize = 10;
        self.subtitleFontSize = 10;

    }
}


-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.bgView.frame = self.bounds;
    
    if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
        self.leftView.frame = CGRectMake(0, 0, 100, self.height);
    }else {
        self.leftView.frame = CGRectMake(0, 0, 120, self.height);
    }
    self.line.size = CGSizeMake(1, 38);
    self.line.left = self.leftView.right;
    self.line.centerY = self.leftView.centerY;
    
    self.rightArrow.size = CGSizeMake(16 * WIDTHSCALE, 16 * WIDTHSCALE);
    self.rightArrow.left = self.width - 15 - self.rightArrow.width;
    self.rightArrow.centerY = self.leftView.centerY;
    
    CGFloat itemWidth = (self.rightArrow.left - self.line.right - 15) / 2;
    self.centerView.frame = CGRectMake(self.line.right + 15, 0, itemWidth + 20, self.height);
    self.rightView.frame = CGRectMake(self.centerView.right, 0, itemWidth - 20, self.height);

    self.rightBtn.left = self.line.right;
    self.rightBtn.top = self.centerView.top;
    self.rightBtn.width = self.width - self.line.right;
    self.rightBtn.height = self.height - self.centerView.top;
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
        _line.backgroundColor = [UIColor themeGray6];
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
