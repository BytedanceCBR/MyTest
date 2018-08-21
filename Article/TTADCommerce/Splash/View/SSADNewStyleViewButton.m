//
//  SSADNewStyleViewButton.m
//  Article
//
//  Created by matrixzk on 10/30/15.
//
//

#import "SSADNewStyleViewButton.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "TTThemeConst.h"

inline static CGFloat contentPadding() {
    CGFloat padding  = 4.0f;
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        padding  = 5.0f;
    }
    if ([TTDeviceHelper isPadDevice]) {
        padding  = 8.0f;
    }
    return padding;
}

inline static CGFloat titleFontSize() {
    CGFloat fontSize = 14.0f;
    if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 16.0f;
    }
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 18.0f;
    }
    return fontSize;
}

@interface SSADNewStyleViewButton ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *imageView;
@end

@implementation SSADNewStyleViewButton
{
    UIView *_titleBgView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25/1.0];
        self.titleText = NSLocalizedString(@"点击查看", nil);
        CGFloat fontSize = titleFontSize();
       
        // title label
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.text = self.titleText;
        self.titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText7];
        self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
       
        // arrow imageView
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_ad_spalsh"]];
       
        _titleBgView = [[UIView alloc] initWithFrame:CGRectZero];
        [_titleBgView addSubview:self.titleLabel];
        [_titleBgView addSubview:self.imageView];
        
        [self addSubview:_titleBgView];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [self addGestureRecognizer:tapGR];
    }
    return self;
}

- (void)setTitleText:(NSString *)titleText {
    if (!isEmptyString(titleText)) {
        _titleText = titleText;
    } else {
        _titleText = NSLocalizedString(@"点击查看", @"点击查看");
    }
    self.titleLabel.text = _titleText;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGFloat margin = 15.0f;
    const CGFloat padding  = contentPadding();
    const CGFloat maxWidth = CGRectGetWidth(self.bounds) - margin * 2;
    const CGFloat contentMaxWidth = maxWidth - padding - 16;
    [self.titleLabel sizeToFit];
    self.titleLabel.origin = CGPointZero;
    self.titleLabel.width = MIN(contentMaxWidth, CGRectGetWidth(self.titleLabel.frame));
    self.imageView.center = CGPointMake(CGRectGetMaxX(self.titleLabel.frame)+ padding + CGRectGetWidth(self.imageView.frame)/2, self.titleLabel.center.y);
    
    // title background view
    _titleBgView.frame = CGRectMake(0, 0, CGRectGetWidth(self.titleLabel.frame) + padding + CGRectGetWidth(self.imageView.frame), CGRectGetHeight(self.titleLabel.frame));
    _titleBgView.center = CGPointMake(self.width/2, self.height/2);
}

- (void)handleTapAction:(UITapGestureRecognizer *)tapGR
{
    if (self.buttonTapActionBlock) {
        self.buttonTapActionBlock();
    }
}

@end

