//
//  TTPlayerResolutionDegradeTipView.m
//  Article
//
//  Created by 赵晶鑫 on 29/08/2017.
//
//

#import "TTPlayerResolutionDegradeTipView.h"
#import <NSTimer+Additions.h>

@interface TTPlayerResolutionDegradeTipView ()

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *splitLineView;
@property (nonatomic, strong) UIButton *degradeResolutionButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) NSTimer *hideTimer;

@end

static NSString * const kTTPlayerResolutionDegradTipViewShownKey = @"kTTPlayerResolutionDegradTipViewShownKey";

@implementation TTPlayerResolutionDegradeTipView

#pragma mark -
#pragma mark - life cycle

+ (void)initialize {
    if (self == [TTPlayerResolutionDegradeTipView self]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTTPlayerResolutionDegradTipViewShownKey];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ttv_buildViewHierarchy];
        [self ttv_buildViewConstraints];
        [self ttv_addObserver];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.height / 2;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_closeButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -
#pragma mark public methods

- (BOOL)showIfNeeded {
    if (![self ttv_hasShownBefore]) {
        self.hidden = NO;
        [self ttv_markHasShown];
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(ttv_close) userInfo:nil repeats:NO];
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark private methods

- (void)ttv_addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttv_enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (BOOL)ttv_hasShownBefore {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kTTPlayerResolutionDegradTipViewShownKey];
}

- (void)ttv_markHasShown {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTPlayerResolutionDegradTipViewShownKey];
}

#pragma mark -
#pragma mark UI

- (void)ttv_buildViewHierarchy {
    self.hidden = YES;
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.54f];
    
    [self addSubview:self.contentLabel];
    [self addSubview:self.splitLineView];
    [self addSubview:self.degradeResolutionButton];
    [self addSubview:self.closeButton];
}

- (void)ttv_buildViewConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(15.0f);
        make.top.mas_offset(7.0f);
        make.bottom.mas_offset(-7.0f);
    }];
    
    [self.splitLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentLabel.mas_right).mas_offset(10.0f);
        make.top.mas_offset(12.0f);
        make.bottom.mas_offset(-12.0f);
        make.width.mas_equalTo(1.0f);
    }];
    
    [self.degradeResolutionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.splitLineView.mas_right).mas_offset(10.0f);
        make.centerY.equalTo(self);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.degradeResolutionButton.mas_right).mas_offset(12.0f);
        make.right.mas_offset(-16.0f);
        make.centerY.equalTo(self);
    }];
}

#pragma mark -
#pragma mark actions

- (void)ttv_close {
    self.hidden = YES;
    
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)ttv_resolutionDegrade {
    [self ttv_close];
    
    if (self.resolutionDegradeBlock) {
        self.resolutionDegradeBlock();
    }
}

- (void)ttv_enterBackground {
    [self.hideTimer tt_pause];
}

- (void)ttv_enterForeground {
    [self.hideTimer tt_resume];
}

#pragma mark -
#pragma mark getters

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:13.0f]];
        _contentLabel.textColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.text = @"网络卡，切换标清更流畅";
        [_contentLabel sizeToFit];
    }
    return _contentLabel;
}

- (UIView *)splitLineView {
    if (!_splitLineView) {
        _splitLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _splitLineView.backgroundColor = [UIColor colorWithWhite:250.0f / 255.0f alpha:0.3f];
    }
    return _splitLineView;
}

- (UIButton *)degradeResolutionButton {
    if (!_degradeResolutionButton) {
        _degradeResolutionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _degradeResolutionButton.titleLabel.font = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:13.0f]];
        [_degradeResolutionButton setTitle:@"立即切换" forState:UIControlStateNormal];
        [_degradeResolutionButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_degradeResolutionButton addTarget:self action:@selector(ttv_resolutionDegrade) forControlEvents:UIControlEventTouchUpInside];
        _degradeResolutionButton.hitTestEdgeInsets = UIEdgeInsetsMake(0.0f, -16.0f, 0.0f, 0.0f);
    }
    return _degradeResolutionButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.alpha = 0.7f;
        [_closeButton setImage:[UIImage imageNamed:@"resolution_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(ttv_close) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, -16.0f);
    }
    return _closeButton;
}

@end

