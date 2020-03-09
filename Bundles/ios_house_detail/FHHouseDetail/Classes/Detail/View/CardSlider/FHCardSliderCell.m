//
//  FHCardSliderCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/6.
//

#import "FHCardSliderCell.h"
#import <Masonry/Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTBaseMacro.h"

@interface FHCardSliderCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *blackCoverView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic ,strong) UILabel *position;
@property (nonatomic ,strong) UIView *positionView;
@property (nonatomic ,strong) CAGradientLayer *gradientLayer;

@end

@implementation FHCardSliderCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        [self setupUI];
        [self layout];
    }
    return self;
}

- (void)setCellData:(id)data {
    self.imageView.image = [UIImage imageNamed:data];;//用SDWebImage
    self.titleLabel.text = @"市政旁置业好去处，高铁很便利";
    self.subTitleLabel.text = @"233人阅读";
    
    NSString *tagText = @"幸福里评测";
    if(isEmptyString(tagText)){
        self.positionView.hidden = YES;
        self.position.text = @"";
    }else{
        self.positionView.hidden = NO;
        self.position.text = @"幸福里评测";
    }
    [self updateTagView];
}

- (void)setupUI {
    [self.contentView addSubview:self.imageView];
    
    self.blackCoverView = [[UIView alloc] init];
    [self.imageView addSubview:_blackCoverView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:18] textColor:[UIColor whiteColor]];
    [self.imageView addSubview:_titleLabel];
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor whiteColor]];
    [self.imageView addSubview:_subTitleLabel];
    
    self.positionView = [[UIView alloc] init];
    _positionView.backgroundColor = [UIColor themeGray1];
    _positionView.hidden = YES;
    [self.imageView addSubview:_positionView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor whiteColor]];
    [_position sizeToFit];
    [_position setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_position setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.positionView addSubview:_position];
    
}

- (void)layout {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.blackCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.imageView);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.imageView).offset(-10);
        make.left.mas_equalTo(self.imageView).offset(10);
        make.right.mas_equalTo(self.imageView).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.subTitleLabel.mas_top).offset(-2);
        make.left.mas_equalTo(self.imageView).offset(10);
        make.right.mas_equalTo(self.imageView).offset(-10);
        make.height.mas_equalTo(25);
    }];
    
    [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView).offset(10);
        make.bottom.mas_equalTo(self.titleLabel.mas_top).offset(-6);
        make.height.mas_equalTo(24);
    }];
    
    [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionView).offset(4);
        make.right.mas_equalTo(self.positionView).offset(-4);
        make.centerY.mas_equalTo(self.positionView);
        make.height.mas_equalTo(17);
    }];
    
    [self.contentView layoutIfNeeded];
    //背景渐变
    self.gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.blackCoverView.bounds;
    _gradientLayer.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor,
                             (id)[[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor];
    [self.blackCoverView.layer addSublayer:_gradientLayer];
}

- (void)updateTagView {
    [self.contentView layoutIfNeeded];
    //标签指定圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.positionView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(6, 6)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.positionView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.positionView.layer.mask = maskLayer;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 10;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
