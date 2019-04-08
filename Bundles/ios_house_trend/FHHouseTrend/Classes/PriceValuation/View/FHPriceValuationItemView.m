//
//  FHPriceValuationItemView.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHPriceValuationItemView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import "TTDeviceHelper.h"

@interface FHPriceValuationItemView()

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIImageView *rightImage;
@property(nonatomic, strong) UILabel *rightLabel;

@end

@implementation FHPriceValuationItemView

- (instancetype)initWithFrame:(CGRect)frame type:(FHPriceValuationItemViewType)type {
    self = [super initWithFrame:frame];
    
    if(self){
        self.type = type;
        self.backgroundColor = [UIColor whiteColor];
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentView];
    
    [self addSubview:self.rightImage];
    self.rightImage.image = [UIImage imageNamed:@"setting-arrow"];
    
    [self addSubview:self.rightLabel];
    self.rightLabel.hidden = YES;

    [self.contentView addSubview:self.bottomLine];
    
    if(self.type == FHPriceValuationItemViewTypeNormal){
        [self.contentView addSubview:self.contentLabel];
        UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAction:)];
        [self addGestureRecognizer:tapGesturRecognizer];
    }else{
        [self.contentView addSubview:self.textField];
    }
}

- (void)initConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(15);
        make.width.mas_equalTo(58);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-15);
        make.width.height.mas_equalTo(22);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-15);
        make.width.mas_lessThanOrEqualTo(58);
        make.centerY.mas_equalTo(self);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rightImage.mas_left).offset(-5);
        make.top.bottom.mas_equalTo(self);
        make.left.mas_equalTo(self.titleLabel.mas_right);
    }];
    
    if(self.type == FHPriceValuationItemViewTypeNormal){
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }else{
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(15);
        make.right.mas_equalTo(self).offset(-15);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(TTDeviceHelper.ssOnePixel);
    }];
}

- (UILabel *)titleLabel {
    if(!_titleLabel){
        _titleLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    }
    return _titleLabel;
}

- (UIView *)contentView {
    if(!_contentView){
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (UILabel *)contentLabel {
    if(!_contentLabel){
        _contentLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    }
    return _contentLabel;
}

- (UITextField *)textField {
    if(!_textField){
        _textField = [[UITextField alloc] init];
        _textField.font = [UIFont themeFontRegular:16];
        [_textField setValue:[UIColor themeGray3] forKeyPath:@"_placeholderLabel.textColor"];
        [_textField setTintColor:[UIColor themeRed3]];
    }
    return _textField;
}

- (UIImageView *)rightImage {
    if(!_rightImage){
        _rightImage = [[UIImageView alloc] init];
    }
    return _rightImage;
}

- (UILabel *)rightLabel {
    if(!_rightLabel){
        _rightLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        [_rightLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _rightLabel;
}

- (UIView *)bottomLine {
    if(!_bottomLine){
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor themeGray6];
    }
    return _bottomLine;
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)setRightText:(NSString *)rightText {
    if(rightText && ![rightText isEqualToString:@""]){
        self.rightLabel.hidden = NO;
        self.rightImage.hidden = YES;
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.rightLabel.mas_left).offset(-5);
            make.top.bottom.mas_equalTo(self);
            make.left.mas_equalTo(self.titleLabel.mas_right);
        }];
    }else{
        self.rightLabel.hidden = YES;
        self.rightImage.hidden = NO;
        [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.rightImage.mas_left).offset(-5);
            make.top.bottom.mas_equalTo(self);
            make.left.mas_equalTo(self.titleLabel.mas_right);
        }];
    }
    self.rightLabel.text = rightText;
}

- (void)setTitleWidth:(CGFloat)titleWidth {
    _titleWidth = titleWidth;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(titleWidth);
    }];
}

- (void)clickAction:(id)tap {
    if(self.tapBlock){
        self.tapBlock();
    }
}

@end
