//
//  FHVideoNetFlowTipView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/29.
//

#import "FHVideoNetFlowTipView.h"
#import "UIViewAdditions.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"

static const CGFloat kTipAndBtnPadding = 24.f;
static CGFloat kcontinuePlayBtnPadding = 42.f;

@interface FHVideoNetFlowTipView()

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *continuePlayBtn;

@property (nonatomic, strong) UIButton *subscribeBtn;
@property (nonatomic, copy) NSString *tipText;


@end

@implementation FHVideoNetFlowTipView


- (instancetype)initWithFrame:(CGRect)frame tipText:(NSString *)text isSubscribe:(BOOL)isSubscribe {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        
        _tipText = text;
        _isSubscribe = isSubscribe;
        
        [self addSubview:self.tipLabel];
        self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.continuePlayBtn];
        self.continuePlayBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.subscribeBtn];
        self.subscribeBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.tipLabel.centerX = self.width / 2;;
    self.tipLabel.top = (self.height - (self.tipLabel.height + kTipAndBtnPadding + self.continuePlayBtn.height)) / 2;
    
    self.continuePlayBtn.top = self.tipLabel.bottom + kTipAndBtnPadding;
    
    if (self.subscribeBtn.hidden) {
        
        self.continuePlayBtn.centerX = self.centerX;
    } else {
        
        self.subscribeBtn.centerY = self.continuePlayBtn.centerY;
        self.continuePlayBtn.left = (self.width - kcontinuePlayBtnPadding - self.continuePlayBtn.width - self.subscribeBtn.width) / 2;
        self.subscribeBtn.right = self.width - self.continuePlayBtn.left;
    }
}

- (void)refreshTipLabel:(CGFloat)mergin {
    kcontinuePlayBtnPadding = 24;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.f;
    [style setAlignment:NSTextAlignmentCenter];
    NSString *text = [_tipText stringByReplacingOccurrencesOfString:@"，" withString:@"\n"];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0xcacaca"], NSParagraphStyleAttributeName : style}];
    
    _tipLabel.attributedText = attributedText;
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(self.width - mergin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    _tipLabel.size = size;
    
    [self setNeedsLayout];
}

- (void)refreshTipLabelText:(NSString *)tipLabelText {
    self.tipText = tipLabelText;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.f;
    style.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_tipText attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0xcacaca"], NSParagraphStyleAttributeName : style}];
    _tipLabel.attributedText = attributedText;
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(self.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    _tipLabel.size = size;
    
    [self setNeedsLayout];
}

- (void)setTipLabelText:(NSString *)tipLabelText {
    [self refreshTipLabelText:tipLabelText];
}
#pragma mark - Geter & Setter

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.numberOfLines = 0;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5.f;
        style.alignment = NSTextAlignmentCenter;
        NSMutableDictionary *attrsDict = [[NSMutableDictionary alloc] init];
        attrsDict[NSFontAttributeName] = [UIFont systemFontOfSize:14.f];
        attrsDict[NSForegroundColorAttributeName] = [UIColor colorWithHexString:@"0xcacaca"];
        attrsDict[NSParagraphStyleAttributeName] = style;
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_tipText ?: @"" attributes:attrsDict];
        _tipLabel.attributedText = attributedText;
        [_tipLabel sizeToFit];
    }
    
    return _tipLabel;
}

- (UIButton *)continuePlayBtn {
    if (!_continuePlayBtn) {
        _continuePlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _continuePlayBtn.size = CGSizeMake(68.f, 26.f);
        _continuePlayBtn.layer.cornerRadius = 13.f;
        _continuePlayBtn.layer.masksToBounds = YES;
        _continuePlayBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
        [_continuePlayBtn setTitle:NSLocalizedString(@"继续播放", nil) forState:UIControlStateNormal];
        [_continuePlayBtn setTitleColor:[UIColor colorWithHexString:@"0xffffff"] forState:UIControlStateNormal];
        _continuePlayBtn.titleLabel.font = [UIFont themeFontRegular:12];
        [_continuePlayBtn addTarget:self action:@selector(clickContinueButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _continuePlayBtn;
}
- (void)clickContinueButton {
    // 不这样判断一下会崩溃哈
    if ([self respondsToSelector:@selector(continuePlayBlock)]) {
        (!self.continuePlayBlock) ?: self.continuePlayBlock();
    }
    if ([self respondsToSelector:@selector(continuePlayBlockAddtion)]) {
        (!self.continuePlayBlockAddtion) ?: self.continuePlayBlockAddtion();
    }
}

- (UIButton *)subscribeBtn {
    if (!_subscribeBtn) {
        _subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _subscribeBtn.size = CGSizeMake(88.f, 32.f);
        _subscribeBtn.hidden = !_isSubscribe;
        _subscribeBtn.layer.cornerRadius = 4.f;
        _subscribeBtn.layer.masksToBounds = YES;
        [_subscribeBtn setTitleColor:[UIColor colorWithHexString:@"0xffffff"] forState:UIControlStateNormal];
        _subscribeBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _subscribeBtn.backgroundColor = [UIColor colorWithHexString:@"0x2a90d7"];
        [_subscribeBtn addTarget:self action:@selector(clickSubscribeButton) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _subscribeBtn;
}

- (void)clickSubscribeButton {
    if ([self respondsToSelector:@selector(subscribeBlock)]) {
        (!self.subscribeBlock) ?: self.subscribeBlock();
    }
    
}

@end
