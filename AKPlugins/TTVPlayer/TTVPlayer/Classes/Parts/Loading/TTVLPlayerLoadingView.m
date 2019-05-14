//
//  TTVLPlayerLoadingView.m
//  Article
//
//  Created by panxiang on 2018/10/12.
//

#import "TTVLPlayerLoadingView.h"
#import "TTVActivityIndicator.h"

#define kTipLoadingViewH 32
#define kHorizontalGap [TTVPlayerUtility tt_padding:12]

@interface TTVLPlayerLoadingView ()

@property (nonatomic, strong) TTVActivityIndicator *loadingView;
@property (nonatomic, strong) UILabel *loadingTip;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, assign) BOOL showFreeFlowTip;

@end

@implementation TTVLPlayerLoadingView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidden = YES;
        [self _buildViewHierarchy];
        [self _buildConstraints];
        self.showFreeFlowTip = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.layer.cornerRadius = 4;
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, self.loadingView.width+60, self.loadingView.height+4+self.loadingTip.height+40);
    self.center = CGPointMake(self.superview.width/2.0, self.superview.height/2.0);
    self.loadingView.center = self.center;
}

#pragma mark -
#pragma mark public methods

- (void)startLoading {
    [self.loadingView startAnimating];
    self.hidden = NO;
    self.loadingTip.hidden = !self.showFreeFlowTip;
}

- (void)stopLoading {
    [self.loadingView stopAnimating];
    self.hidden = YES;
    self.loadingTip.hidden = YES;
}

- (BOOL)isLoading {
    return self.loadingView.isAnimating;
}

#pragma mark -
#pragma mark UI

- (void)_buildViewHierarchy {
    [self addSubview:self.loadingView];
    [self addSubview:self.loadingTip];
}

- (void)_buildConstraints {
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(kTipLoadingViewH);
        make.height.mas_equalTo(kTipLoadingViewH);
    }];
    
    [self.loadingTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loadingView.mas_bottom).offset(4);
        make.centerX.equalTo(self.loadingView);
    }];
}

#pragma mark -
#pragma mark getters

- (TTVActivityIndicator *)loadingView {
    if (!_loadingView) {
        _loadingView = [[TTVActivityIndicator alloc] initWithFrame:CGRectMake(0, 0, kTipLoadingViewH, kTipLoadingViewH)];
        _loadingView.lineWidth = 4;
        _loadingView.hidesWhenStopped = YES;
        _loadingView.tintColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f];
    }
    return _loadingView;
}

- (UILabel *)loadingTip
{
    if (!_loadingTip) {
        _loadingTip = [[UILabel alloc] init];
        
        _loadingTip.textColor = [TTVPlayerUtility colorWithHexString:@"cacaca"];
        _loadingTip.font = [UIFont systemFontOfSize:12.f];
//        _loadingTip.text = @"免流量加载中";
        [_loadingTip sizeToFit];
    }
    return _loadingTip;
}

- (void)showErrorWithText:(NSString *)text
{
    self.hidden = NO;
    [self.loadingView stopAnimating];
    self.userInteractionEnabled = NO;
}

- (void)showFreeFlowTip:(BOOL)show
{
    self.showFreeFlowTip = show;
}

- (void)setLoadingText:(NSString *)text {
    self.loadingTip.text = text;
}

@end


