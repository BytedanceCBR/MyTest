

#import "PopoverViewCell.h"
#import "UIColor+TTThemeExtension.h"
#import "Masonry.h"

// extern
float const PopoverViewCellHorizontalMargin = 20.f; ///< 水平边距
float const PopoverViewCellVerticalMargin = 0.f; ///< 垂直边距
float const PopoverViewCellTitleLeftEdge = 12.f; ///< 标题左边边距

@interface PopoverViewCell ()

@property (nonatomic, strong) SSThemedImageView *iconView;
@property (nonatomic, strong) SSThemedView *redDotView;
@property (nonatomic, strong) SSThemedImageView *titleBgView;
@property (nonatomic, strong) SSThemedLabel *label;
@property (nonatomic, weak) UIView *bottomLine;

@end

@implementation PopoverViewCell

#pragma mark - Life Cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = self.backgroundColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // initialize
    [self initialize];
    
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}

#pragma mark - Setter
- (void)setStyle:(PopoverViewStyle)style {
    _style = style;
    _bottomLine.backgroundColor = [self.class bottomLineColorForStyle:style];
    if (_style == PopoverViewStyleDefault) {
        _label.textColorThemeKey = kColorText2;
    } else {
        _label.textColor = UIColor.whiteColor;
    }
}

#pragma mark - Private
// 初始化
- (void)initialize {
    
    _iconView = [[SSThemedImageView alloc] init];
    [self.contentView addSubview:_iconView];
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(28.f);
        make.height.mas_equalTo(28.f);
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView.mas_left).offset(20.f);
    }];
    
    // UI
    _label = [[SSThemedLabel alloc] init];
    _label.textColorThemeKey = kColorText2;
    _label.font = [[self class] titleFont];
    [self.contentView addSubview:_label];
    // Constraint
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.mas_equalTo(self.iconView.mas_right).offset(12.f);
    }];
    
    _titleBgView = [[SSThemedImageView alloc] init];
    [self.contentView addSubview:_titleBgView];
    [self.contentView sendSubviewToBack:_titleBgView];
    [_titleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_label.mas_centerX);
        make.centerY.equalTo(_label.mas_centerY);
    }];
    
    // 底部线条
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.00];
    bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:bottomLine];
    _bottomLine = bottomLine;
    // Constraint
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomLine]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(bottomLine)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLine(lineHeight)]|" options:kNilOptions metrics:@{@"lineHeight" : @(1/[UIScreen mainScreen].scale)} views:NSDictionaryOfVariableBindings(bottomLine)]];
    
    [self themeChanged:nil];
}

#pragma mark - Public
/*! @brief 标题字体 */
+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:14.f];
}

/*! @brief 底部线条颜色 */
+ (UIColor *)bottomLineColorForStyle:(PopoverViewStyle)style {
    return style == PopoverViewStyleDefault ? [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.00] : [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.00];
}

- (void)setAction:(PopoverAction *)action {
    [_iconView setImage:action.image];
    [_titleBgView setImage:action.titleImage];
    [_label setText:action.title];
    [_label sizeToFit];
    if (!SSIsEmptyArray(action.colors)) {
        _label.textColors = action.colors;
    }
    if (action.showRedDot) {
        if (!self.redDotView) {
            self.redDotView = [[SSThemedView alloc] init];
            self.redDotView.backgroundColor = [UIColor colorWithHexString:@"#ff6b6a"];
            self.redDotView.layer.cornerRadius = 3.0f;
            self.redDotView.layer.masksToBounds = YES;
        }
        [self.iconView addSubview:self.redDotView];
        [self.redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(6.f);
            make.height.mas_equalTo(6.f);
            make.top.equalTo(self.iconView.mas_top).offset(-[TTDeviceHelper ssOnePixel]);
            make.right.equalTo(self.iconView.mas_right).offset([TTDeviceHelper ssOnePixel]);
        }];
    } else {
        [self.redDotView removeFromSuperview];
    }
    if (action.titleFont) {
        _label.font = action.titleFont;
    } else {
        _label.font = [[self class] titleFont];
    }
}

- (void)showBottomLine:(BOOL)show {
    _bottomLine.hidden = !show;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.iconView.alpha = 1.f;
    }else {
        self.iconView.alpha = 0.5f;
    }
}

@end
