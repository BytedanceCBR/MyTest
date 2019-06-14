//
//  TTVNetFlowTipView.m
//  Article
//
//  Created by lijun.thinker on 2017/7/10.
//

#import "TTVNetFlowTipView.h"
#import "UIViewAdditions.h"

static const CGFloat kTipAndBtnPadding = 24.f;
static CGFloat kcontinuePlayBtnPadding = 42.f;

@interface TTVNetFlowTipView()

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *continuePlayBtn;
@property (nonatomic, copy) NSString *tipText;


@end

@implementation TTVNetFlowTipView


- (instancetype)initWithFrame:(CGRect)frame tipText:(NSString *)text{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        _tipText = text;
        
        [self addSubview:self.tipLabel];
        self.tipLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:self.continuePlayBtn];
        self.continuePlayBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.tipLabel.centerX = self.width / 2;;
    self.tipLabel.top = (self.height - (self.tipLabel.height + kTipAndBtnPadding + self.continuePlayBtn.height)) / 2;
    
    self.continuePlayBtn.top = self.tipLabel.bottom + kTipAndBtnPadding;
    
    self.continuePlayBtn.centerX = self.centerX;
}

- (void)refreshTipLabel:(CGFloat)mergin {
    kcontinuePlayBtnPadding = 24;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.f;
    [style setAlignment:NSTextAlignmentCenter];
    NSString *text = [_tipText stringByReplacingOccurrencesOfString:@"，" withString:@"\n"];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName : [TTVPlayerUtility colorWithHexString:@"0xcacaca"], NSParagraphStyleAttributeName : style}];

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
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_tipText attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName : [TTVPlayerUtility colorWithHexString:@"0xcacaca"], NSParagraphStyleAttributeName : style}];
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
        attrsDict[NSForegroundColorAttributeName] = [TTVPlayerUtility colorWithHexString:@"0xcacaca"];
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
        _continuePlayBtn.size = CGSizeMake(88.f, 32.f);
        _continuePlayBtn.layer.cornerRadius = 4.f;
        _continuePlayBtn.layer.masksToBounds = YES;
        _continuePlayBtn.layer.borderColor = [TTVPlayerUtility colorWithHexString:@"0xffffff"].CGColor;
        _continuePlayBtn.layer.borderWidth = 1;
        [_continuePlayBtn setTitle:NSLocalizedString(@"继续播放", nil) forState:UIControlStateNormal];
        [_continuePlayBtn setTitleColor:[TTVPlayerUtility colorWithHexString:@"0xffffff"] forState:UIControlStateNormal];
        _continuePlayBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_continuePlayBtn addTarget:self action:@selector(clickContinueButton) forControlEvents:UIControlEventTouchUpInside];
//        WeakSelf;
//        [[_continuePlayBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//            StrongSelf;
//
//        }];
    }
    
    return _continuePlayBtn;
}
- (void)clickContinueButton {
    // 不这样判断一下会崩溃哈
    if ([self respondsToSelector:@selector(continuePlayBlock)]) {
        (!self.continuePlayBlock) ?: self.continuePlayBlock();
    }
}

@end