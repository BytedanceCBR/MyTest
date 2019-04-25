//
//  TTMoviePlayerControlFinishAction.m
//  Article
//
//  Created by songxiangwu on 16/9/6.
//
//

#import "TTMoviePlayerControlFinishAction.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "TTVideoEmbededAdButton.h"

static const CGFloat kBtnW = 44;
static const CGFloat kPrePlayBtnBottom = 10;
extern NSInteger ttvs_isVideoShowOptimizeShare(void);
extern BOOL ttvs_isVideoDetailPlayLastEnabled(void);

@interface TTMoviePlayerControlFinishAction ()

@property (nonatomic, weak) UIView *baseView;
@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) CGFloat bannerHeight; // 兼容banner出现的情况

@end

@implementation TTMoviePlayerControlFinishAction

- (instancetype)initWithBaseView:(UIView *)baseView {
    self = [super init];
    if (self) {
        _baseView = baseView;
        
        _bannerHeight = 0;
        
        //背景view
        _backView = [[UIView alloc] initWithFrame:_baseView.bounds];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [_baseView addSubview:_backView];
        
        _containerView = [[UIView alloc] initWithFrame:_backView.bounds];
        [_backView addSubview:_containerView];
        
        //分享按钮
        _shareButton = [[TTAlphaThemedButton alloc] init];
        [_containerView addSubview:_shareButton];
        
        _shareLabel = [[SSThemedLabel alloc] init];
        _shareLabel.text = NSLocalizedString(@"分享", nil);
        _shareLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _shareLabel.textColor = SSGetThemedColorWithKey(kColorText12);
        [_shareLabel sizeToFit];
        [_containerView addSubview:_shareLabel];
        
        //重播按钮
        _replayButton = [[TTAlphaThemedButton alloc] init];
        [_containerView addSubview:_replayButton];
        
        _replayLabel = [[SSThemedLabel alloc] init];
        _replayLabel.text = NSLocalizedString(@"重播", nil);
        _replayLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        _replayLabel.textColor = SSGetThemedColorWithKey(kColorText12);
        [_replayLabel sizeToFit];
        [_containerView addSubview:_replayLabel];
        
        [_containerView addSubview: self.prePlayBtn];
        [_containerView addSubview:self.moreButton];
    }
    return self;
}

- (void)refreshSubViews:(BOOL)hasFinished {
    self.backView.hidden = !hasFinished;
//    self.shareButton.hidden = !hasFinished;
//    self.replayButton.hidden = !hasFinished;
//    self.shareLabel.hidden = !hasFinished;
//    self.replayLabel.hidden = !hasFinished;
    
    if (hasFinished && self.prePlayBtn.isEnabled) {
        
        self.prePlayBtn.hidden = NO;
    } else {
        
        self.prePlayBtn.hidden = YES;
    }
}

- (void)layoutSubviews {
    
    _backView.frame = _baseView.bounds;
    _containerView.frame = _backView.frame;
    _containerView.height -= _bannerHeight;
    
    CGRect frame = _containerView.frame;
    CGFloat sepW = 22;
    _shareButton.center = CGPointMake(frame.size.width/2+sepW+CGRectGetWidth(_shareButton.frame)/2, CGRectGetHeight(frame)/2);
    _shareLabel.center = CGPointMake(_shareButton.center.x, CGRectGetMaxY(_shareButton.frame)+5+_shareLabel.frame.size.height);
    _replayButton.center = CGPointMake(frame.size.width/2-sepW-CGRectGetWidth(_replayButton.frame)/2, CGRectGetHeight(frame)/2);
    _replayLabel.center = CGPointMake(_replayButton.center.x, _shareLabel.center.y);
    
    _prePlayBtn.centerY = CGRectGetHeight(frame) - _prePlayBtn.height / 2 - kPrePlayBtnBottom;
    _moreButton.centerY = 22;

}

- (void)setIsFullMode:(BOOL)isFullMode {
    _isFullMode = isFullMode;
    _shareButton.frame = CGRectMake(0, 0, kBtnW, kBtnW);
    _shareButton.imageName = @"Share";
    _replayButton.frame = CGRectMake(0, 0, kBtnW, kBtnW);
    _replayButton.imageName = @"Replay";
    _prePlayBtn.hidden = (!_prePlayBtn.enabled || isFullMode);
    _moreButton.hidden = isFullMode;
    [self layoutSubviews];
}

- (void)updateFinishActionItemsFrameWithBannerHeight:(CGFloat)height {
    
    _bannerHeight = height;
    
    [self layoutSubviews];
}

- (TTAlphaThemedButton *)prePlayBtn {
    
    if (!ttvs_isVideoDetailPlayLastEnabled()) {
        
        return nil;
    }
    
    if (!_prePlayBtn) {
        
        UIImage *img = [UIImage imageNamed:@"pre_play"];
        _prePlayBtn = [[TTAlphaThemedButton alloc] init];
        _prePlayBtn.enabled = NO;
        _prePlayBtn.frame = CGRectMake(12, _containerView.height - kPrePlayBtnBottom - img.size.height, 60, img.size.height);
        _prePlayBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_prePlayBtn setImage:img forState:UIControlStateNormal];
        [_prePlayBtn setTitle:NSLocalizedString(@"上一个", nil) forState:UIControlStateNormal];
        [_prePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText12] forState:UIControlStateNormal];
        [_prePlayBtn setTitleColor:[UIColor tt_defaultColorForKey:kColorText12Highlighted] forState:UIControlStateHighlighted];
        _prePlayBtn.titleLabel.font = [UIFont systemFontOfSize:12.f];
        [_prePlayBtn layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:2.f];
        
        [_prePlayBtn sizeToFit];
    }
    
    return _prePlayBtn;
}

- (TTAlphaThemedButton *)moreButton {
    
    if (ttvs_isVideoShowOptimizeShare() == 0) {
        
        return nil;
    }
    
    if (!_moreButton) {
        
        _moreButton = [[TTAlphaThemedButton alloc] init];
        _moreButton.right = self.containerView.width - 36;
        _moreButton.width = 24.f;
        _moreButton.height = 24.f;
        _moreButton.imageView.center = CGPointMake(_moreButton.frame.size.width/2, _moreButton.frame.size.height/2);
        _moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_moreButton setImage:[UIImage themedImageNamed:@"new_morewhite_titlebar"] forState:UIControlStateNormal];
        [_moreButton sizeToFit];
    }
    
    return _moreButton;
}

@end
