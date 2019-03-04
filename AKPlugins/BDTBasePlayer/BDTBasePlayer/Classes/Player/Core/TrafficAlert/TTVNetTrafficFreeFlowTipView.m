//
//  TTVNetTrafficFreeFlowTipView.m
//  Article
//
//  Created by lijun.thinker on 2017/7/10.
//

#import "TTVNetTrafficFreeFlowTipView.h"
#import "TTVPalyerTrafficAlert.h"

static const CGFloat kTipAndBtnPadding = 28.f;
static const CGFloat kcontinuePlayBtnPadding = 40.f;

@interface TTVNetTrafficFreeFlowTipView()

@property (nonatomic, strong) SSThemedLabel *tipLabel;

@property (nonatomic, strong) UIButton *continuePlayBtn;

@property (nonatomic, strong) UIButton *subscribeBtn;

@property (nonatomic, assign) BOOL isSubscribe;

@property (nonatomic, copy) NSString *tipText;

@end

@implementation TTVNetTrafficFreeFlowTipView

- (instancetype)initWithFrame:(CGRect)frame tipText:(NSString *)text isSubscribe:(BOOL)isSubscribe {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground5];
        
        _tipText = text;
        _isSubscribe = isSubscribe;
        
        [self addSubview:self.tipLabel];
        [self addSubview:self.continuePlayBtn];
        [self addSubview:self.subscribeBtn];
    }
    
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.tipLabel.centerX = self.centerX;
    NSInteger height = (self.height - (self.tipLabel.height + kTipAndBtnPadding + self.continuePlayBtn.height)) / 2.0;
    self.tipLabel.top = height;
    
    self.continuePlayBtn.top = self.tipLabel.bottom + kTipAndBtnPadding;
    
    if (self.subscribeBtn.hidden) {
        
        self.continuePlayBtn.centerX = self.centerX;
    } else {
        
        self.subscribeBtn.centerY = self.continuePlayBtn.centerY;
        self.continuePlayBtn.left = (self.width - kcontinuePlayBtnPadding - self.continuePlayBtn.width - self.subscribeBtn.width) / 2;
        self.subscribeBtn.right = self.width - self.continuePlayBtn.left;
    }
}

#pragma mark - Geter & Setter

- (SSThemedLabel *)tipLabel {
    
    if (!_tipLabel) {
        
        _tipLabel = [[SSThemedLabel alloc] init];
        _tipLabel.text = _tipText;
        _tipLabel.textColor = [UIColor tt_defaultColorForKey:kColorText9];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:14.f];
        [_tipLabel sizeToFit];
    }
    
    return _tipLabel;
}

- (UIButton *)continuePlayBtn {
    
    if (!_continuePlayBtn) {
        
        _continuePlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _continuePlayBtn.size = CGSizeMake(94.f, 28.f);
        _continuePlayBtn.layer.cornerRadius = 4.f;
        _continuePlayBtn.layer.masksToBounds = YES;
        _continuePlayBtn.layer.borderColor = [UIColor tt_defaultColorForKey:kColorLine11].CGColor;
        _continuePlayBtn.layer.borderWidth = 1;
        [_continuePlayBtn setTitle:NSLocalizedString(@"继续播放", nil) forState:UIControlStateNormal];
        [_continuePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText10] forState:UIControlStateNormal];
        _continuePlayBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        WeakSelf;
        [_continuePlayBtn addTarget:self withActionBlock:^{
            StrongSelf;
            (!self.continuePlayBlock) ?: self.continuePlayBlock();
        } forControlEvent:UIControlEventTouchUpInside];
    }
    
    return _continuePlayBtn;
}

- (UIButton *)subscribeBtn {
    
    if (!_subscribeBtn) {
        
        _subscribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _subscribeBtn.size = CGSizeMake(94.f, 28.f);
        _subscribeBtn.hidden = !_isSubscribe;
        _subscribeBtn.layer.cornerRadius = 4.f;
        _subscribeBtn.layer.masksToBounds = YES;
        [_subscribeBtn setTitle:NSLocalizedString([TTVPlayerFreeFlowTipStatusManager getSubcribeButtonText], nil) forState:UIControlStateNormal];
        [_subscribeBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText10] forState:UIControlStateNormal];
        _subscribeBtn.titleLabel.font = [UIFont systemFontOfSize:14.f];
        _subscribeBtn.backgroundColor = [UIColor tt_defaultColorForKey:kColorBackground8];
        WeakSelf;
        [_subscribeBtn addTarget:self withActionBlock:^{
            StrongSelf;
            (!self.subscribeBlock) ?: self.subscribeBlock();
        } forControlEvent:UIControlEventTouchUpInside];
    }
    
    return _subscribeBtn;
}

@end
