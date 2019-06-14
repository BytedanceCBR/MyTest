//
//  TTVNetTrafficFreeFlowTipView.m
//  Article
//
//  Created by lijun.thinker on 2017/7/10.
//

#import "TTVNetTrafficFreeFlowTipView.h"
#import <TTThemed/SSThemed.h>
#import "TTAlphaThemedButton.h"
#import "UIViewAdditions.h"
//#import "TTFreeFlowTipManager.h"
#import <ReactiveObjC/ReactiveObjC.h>

static const CGFloat kTipAndBtnPadding = 24.f;
static CGFloat kcontinuePlayBtnPadding = 42.f;

@interface TTVNetTrafficFreeFlowTipView()

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *continuePlayBtn;

@property (nonatomic, strong) UIButton *subscribeBtn;

@end

@implementation TTVNetTrafficFreeFlowTipView

- (instancetype)initWithFrame:(CGRect)frame tipText:(NSString *)text isSubscribe:(BOOL)isSubscribe {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground5];
        
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
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName : [UIColor tt_defaultColorForKey:kColorText9], NSParagraphStyleAttributeName : style}];
    _tipLabel.attributedText = attributedText;
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(self.width - mergin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    _tipLabel.size = size;
    
    [self setNeedsLayout];
}

- (void)refreshTipLabelText:(NSString *)tipLabelText {
    _tipText = tipLabelText;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5.f;
    style.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:_tipText attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:14.f], NSForegroundColorAttributeName : [UIColor tt_defaultColorForKey:kColorText9], NSParagraphStyleAttributeName : style}];
    _tipLabel.attributedText = attributedText;
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(self.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    _tipLabel.size = size;
    
    [self setNeedsLayout];
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
        attrsDict[NSForegroundColorAttributeName] = [UIColor tt_defaultColorForKey:kColorText9];
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
        _continuePlayBtn.layer.borderColor = [UIColor tt_defaultColorForKey:kColorLine11].CGColor;
        _continuePlayBtn.layer.borderWidth = 1;
        [_continuePlayBtn setTitle:NSLocalizedString(@"继续播放", nil) forState:UIControlStateNormal];
        [_continuePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText10] forState:UIControlStateNormal];
        _continuePlayBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        WeakSelf;
        [[_continuePlayBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            StrongSelf;
            (!self.continuePlayBlock) ?: self.continuePlayBlock();
        }];
    }
    
    return _continuePlayBtn;
}

- (UIButton *)subscribeBtn {
    if (!_subscribeBtn) {
        _subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _subscribeBtn.size = CGSizeMake(88.f, 32.f);
        _subscribeBtn.hidden = !_isSubscribe;
        _subscribeBtn.layer.cornerRadius = 4.f;
        _subscribeBtn.layer.masksToBounds = YES;
//        [_subscribeBtn setTitle:NSLocalizedString([TTFreeFlowTipManager getSubcribeButtonText], nil) forState:UIControlStateNormal];
        [_subscribeBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText10] forState:UIControlStateNormal];
        _subscribeBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _subscribeBtn.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground8];
        WeakSelf;
        [[_subscribeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            StrongSelf;
            (!self.subscribeBlock) ?: self.subscribeBlock();
        }];
    }
    
    return _subscribeBtn;
}

@end