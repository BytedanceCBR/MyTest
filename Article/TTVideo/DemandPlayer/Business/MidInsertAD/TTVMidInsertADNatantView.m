//
//  TTVMidInsertADNatantView.m
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import "TTVMidInsertADNatantView.h"
#import <Masonry/Masonry.h>
#import "UIColor+TTThemeExtension.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+TTAdditions.h"
#import "NSTimer+Additions.h"
#import "TTLabelTextHelper.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTVPlayerView.h"
#import "NSTimer+NoRetain.h"
#import <libextobjc/extobjc.h>
#import "TTVMidInsertADModel.h"

@interface TTVMidInsertADNatantView ()

@property (nonatomic, strong) TTVMidInsertADModel *adModel;

@property (nonatomic, strong) SSThemedLabel *skipLabel;
@property (nonatomic, strong) SSThemedLabel *durationLabel;
@property (nonatomic, strong) TTAlphaThemedButton *skipButton;
@property (nonatomic, strong) TTAlphaThemedButton *showDetailButton;
@property (nonatomic, strong) TTAlphaThemedButton *fullScreenButton;
@property (nonatomic, strong) TTAlphaThemedButton *backButton;
@property (nonatomic, strong) UIView *separateLineView;
@property (nonatomic, strong) SSThemedView *skipBackgroundView;
@property (nonatomic, strong) SSThemedView *skipTouchView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) UIImageView *titleShadowView;

@property (nonatomic, assign) NSInteger titleTime;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger skipTime;
@property (nonatomic, assign) BOOL isFullScreen;
@end

static NSString *kDurationTimeFontName = @"DS-Digital-Italic";

@implementation TTVMidInsertADNatantView

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (instancetype)initWithFrame:(CGRect)frame pasterADModel:(TTVMidInsertADModel *)adModel
{
    if (self = [super initWithFrame:frame]) {
        _adModel = adModel;
        _skipTime = adModel.midInsertADInfoModel.skipTime.integerValue / 1000;
        _durationTime = MIN(adModel.midInsertADInfoModel.displayTime.integerValue / 1000, 99);
        if (_skipTime > _durationTime) {
            _skipTime = _durationTime;
        }
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [self addGestureRecognizer:tap];
        
        [self setupSubViews];
        
        @weakify(self);
        _timer = [NSTimer tt_timerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
            @strongify(self);
            [self timerAction:timer];
        }];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)setIsFullScreen:(BOOL)fullScreen
{
    _isFullScreen = fullScreen;
    
    if (_isFullScreen) {
        NSString *imageName = [TTDeviceHelper isPadDevice] ? @"shrink_video_iPad" : @"shrink_video";
        self.fullScreenButton.imageName = imageName;
    }
    else {
        NSString *imageName = [TTDeviceHelper isPadDevice] ? @"enlarge_video_iPad" : @"enlarge_video";
        self.fullScreenButton.imageName = imageName;
    }
    
    [self.fullScreenButton setNeedsDisplay];
    self.backButton.hidden = !fullScreen;
}

- (void)pauseTimer
{
    [self.timer tt_pause];
    
    if ([_delegate respondsToSelector:@selector(pauseTimer)]) {
        
        [_delegate pauseTimer];
    }
}

- (void)resumeTimer
{
    [self.timer tt_resume];
    
    if ([_delegate respondsToSelector:@selector(pauseTimer)]) {
        
        [_delegate resumeTimer];
    }
}

#pragma mark -

- (void)timerAction:(NSTimer *)timer
{
    if (--self.durationTime > 0) {
        
        if (--self.skipTime > 0) {
            self.skipLabel.text = [NSString stringWithFormat:@"可在%@s后关闭广告", @(self.skipTime)];
            self.skipLabel.hidden = NO;
        } else {
            [self showSkipButton];
        }
        
        self.durationLabel.text = (self.durationTime > 9) ? [@(self.durationTime) stringValue]: [NSString stringWithFormat:@"0%@", @(self.durationTime)];
        [self titleShowToHidden];
    } else {
        [self.timer invalidate];
        self.timer = nil;
        
        if ([self.delegate respondsToSelector:@selector(timerOver)]) {
            
            [self.delegate timerOver];
        }
    }
}

- (void)titleShowToHidden
{
    if (!_titleLabel.hidden) {
        --_titleTime;
        if (_titleTime < 1) {
            [self titleHidden];
        }
    }
}
- (void)titleHidden
{
    [UIView animateWithDuration:.15f animations:^{
        self.titleLabel.alpha = 0;
        self.titleShadowView.alpha = 0;
    } completion:^(BOOL finished) {
        self.titleLabel.hidden = YES;
        self.titleLabel.alpha = 1;
        self.titleShadowView.hidden = YES;
        self.titleShadowView.alpha = 1;
    }];
}

- (void)skipButtonClicked:(UIButton *)button
{
    [self.timer invalidate];
    self.timer = nil;
    if ([self.delegate respondsToSelector:@selector(skipButtonClicked:)]) {
        [self.delegate skipButtonClicked:button];
    }
}

- (void)fullScreenButtonClicked:(UIButton *)button
{
    _isFullScreen = !_isFullScreen;
    [self setIsFullScreen:_isFullScreen];
    if ([self.delegate respondsToSelector:@selector(fullScreenbuttonClicked:toggledTo:)]) {
        [self.delegate fullScreenbuttonClicked:button toggledTo:_isFullScreen];
    }
}

- (void)showDetailButtonClicked:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(showDetailButtonClicked:)]) {
        [self.delegate showDetailButtonClicked:button];
    }
}

- (void)backButtonClicked:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(backButtonClicked:)]) {
        [self.delegate backButtonClicked:button];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(pasterADClicked)]) {
        [self.delegate pasterADClicked];
    }
}


#pragma mark - Layout

- (void)setupSubViews
{
    self.clipsToBounds = YES;
    
    CGFloat skipFontSize = [TTDeviceUIUtils tt_fontSize:12];
    CGFloat durationFontSize = [TTDeviceUIUtils tt_fontSize:16];
    
//    CGFloat lineHeight = [TTDeviceUIUtils tt_lineHeight:8];
    CGFloat bgViewHeight = [TTDeviceUIUtils tt_lineHeight:25];
    CGFloat bgViewWidth = [TTDeviceUIUtils tt_lineHeight:144.f];
    
//    CGFloat lineWidth = [TTDeviceHelper ssOnePixel];
//    CGFloat viewSpace3 = [TTDeviceUIUtils tt_padding:3];
    CGFloat viewSpace5 = [TTDeviceUIUtils tt_padding:5];
//    CGFloat viewSpace7 = [TTDeviceUIUtils tt_padding:7];
    CGFloat viewSpace10 = [TTDeviceUIUtils tt_padding:10];
    CGFloat viewSpace12 = [TTDeviceUIUtils tt_padding:12];
    CGFloat viewSpace15 = [TTDeviceUIUtils tt_padding:15];
    
    UIFont *skipLabelFont = [UIFont systemFontOfSize:skipFontSize];
    UIFont *durationFont = [UIFont fontWithName:kDurationTimeFontName size:durationFontSize];
    
    UIColor *bgColor = [UIColor clearColor];
    
    self.skipBackgroundView = [[SSThemedView alloc] initWithFrame:CGRectZero];
    self.skipBackgroundView.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground5] colorWithAlphaComponent:.5f];
    self.skipBackgroundView.layer.cornerRadius = bgViewHeight / 2;
    [self addSubview:self.skipBackgroundView];
    [self.skipBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(bgViewHeight));
        make.width.equalTo(@(bgViewWidth));
        make.top.equalTo(self.mas_top).offset(viewSpace10);
        make.right.equalTo(self.mas_right).offset(-viewSpace12);
    }];
    
    // duration
    SSThemedLabel *duration = [[SSThemedLabel alloc] init];
    duration.text = (self.durationTime > 9) ? [@(self.durationTime) stringValue]: [NSString stringWithFormat:@"0%@", @(self.durationTime)];
    duration.font = durationFont;
    
    duration.textColor = [UIColor whiteColor];
    duration.textAlignment = NSTextAlignmentCenter;
    duration.backgroundColor = bgColor;
    [self.skipBackgroundView addSubview:duration];
    self.durationLabel = duration;
    
    [duration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.skipBackgroundView.mas_centerY);
        make.left.equalTo(@(viewSpace12));
    }];
    
    TTAlphaThemedButton *skipButton = [[TTAlphaThemedButton alloc] init];
    [skipButton setTitleColorThemeKey:kColorText8];
    skipButton.titleLabel.font = skipLabelFont;
    [skipButton addTarget:self action:@selector(skipButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [skipButton setTitle:NSLocalizedString(@"关闭广告", nil) forState:UIControlStateNormal];
    skipButton.imageName = @"closeicon_ad_video";
    skipButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    skipButton.hidden = YES;
    
    [self.skipBackgroundView addSubview:skipButton];
    self.skipButton = skipButton;
    
    [skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.skipBackgroundView.mas_centerY);
        make.right.equalTo(self.skipBackgroundView.mas_right).offset(-viewSpace12);
//        make.left.mas_equalTo(self.durationLabel.mas_right).offset(viewSpace12);
    }];
    [skipButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageRight imageTitlespace:viewSpace5];
    
    SSThemedLabel *skipLabel = [[SSThemedLabel alloc] init];
    skipLabel.font = skipLabelFont;
    skipLabel.textColor = [UIColor whiteColor];
    skipLabel.backgroundColor = [UIColor clearColor];
    self.skipLabel = skipLabel;
    self.skipLabel.hidden = YES;
    [self.skipBackgroundView addSubview:self.skipLabel];
    [self.skipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.skipBackgroundView);
        make.right.equalTo(self.skipBackgroundView.mas_right).offset(-viewSpace12);
//        make.left.mas_equalTo(self.durationLabel.mas_right).offset(viewSpace12);
    }];
    
    if (self.skipTime == 0) { //特殊处理skipTime＝0，显示skip button
        [self showSkipButton];
    } else {
        self.skipLabel.text = [NSString stringWithFormat:@"可在%@s后关闭广告", @(self.skipTime)];
        self.skipLabel.hidden = NO;
    }
    
    {
        // 查看详情和全屏按钮
        
        TTAlphaThemedButton *fullScreenButton = [[TTAlphaThemedButton alloc] init];
        fullScreenButton.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        fullScreenButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -15, -20, -15);
        fullScreenButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        [fullScreenButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.fullScreenButton = fullScreenButton;
        [self addSubview:fullScreenButton];
        [self setIsFullScreen:NO];
        
        CGFloat fullScreenButtonDiameter = [TTDeviceUIUtils tt_padding:24];
        self.fullScreenButton.layer.cornerRadius = fullScreenButtonDiameter / 2;
        
        [fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-viewSpace15);
            make.width.equalTo(@(fullScreenButtonDiameter));
            make.bottom.mas_offset(-viewSpace10);
            make.height.equalTo(@(fullScreenButtonDiameter));
        }];
        
        
        CGFloat showDetailFontSize = [TTDeviceUIUtils tt_fontSize:12];
        CGFloat detailButtonHeight = [TTDeviceUIUtils tt_padding:24];
        
        TTAlphaThemedButton *showDetailButton = [[TTAlphaThemedButton alloc] init];
        [showDetailButton setTitleColorThemeKey:kColorText8];
        [showDetailButton.titleLabel setFont:[UIFont systemFontOfSize:showDetailFontSize]];
        showDetailButton.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground8] colorWithAlphaComponent:.7f];
        showDetailButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        NSString *detailText = !(isEmptyString(self.adModel.midInsertADInfoModel.buttonText))? self.adModel.midInsertADInfoModel.buttonText: @"查看详情";
        [showDetailButton setTitle:NSLocalizedString(detailText, nil) forState:UIControlStateNormal];
        showDetailButton.layer.cornerRadius = detailButtonHeight / 2;
        showDetailButton.layer.masksToBounds = YES;
        [showDetailButton addTarget:self action:@selector(showDetailButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        showDetailButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -15, -20, -10);
        [showDetailButton sizeToFit];
        CGRect showDetaiBtnFrame = showDetailButton.frame;
        self.showDetailButton = showDetailButton;
        [self addSubview:_showDetailButton];
        [self.showDetailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(fullScreenButton.mas_left).offset(-viewSpace15);
            make.centerY.equalTo(fullScreenButton.mas_centerY);
            make.width.equalTo(@(MIN(showDetaiBtnFrame.size.width, self.width - 60)));
            make.height.equalTo(@(detailButtonHeight));
        }];
        
        //back button
        TTAlphaThemedButton *backButton = [[TTAlphaThemedButton alloc] init]; //
        [backButton setImage:[UIImage imageNamed:@"leftbackbutton_titlebar_photo_preview"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        self.backButton = backButton;
        [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(viewSpace15);
            make.centerY.equalTo(duration.mas_centerY);
        }];
        backButton.hidden = !_isFullScreen;
    }
}

- (void)showSkipButton
{
    self.skipButton.hidden = NO;
    self.skipLabel.hidden = YES;
    [self.skipBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([TTDeviceUIUtils tt_lineHeight:112.5f]);
    }];
//    CGFloat viewSpace10 = [TTDeviceUIUtils tt_padding:10.f];
//    [self.separateLineView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.skipButton.mas_left).offset(-viewSpace10).priority(800);
//    }];
}

- (UIWindow *)mainWindow
{
    UIWindow *window = nil;
    if (!window) {
        window = [UIApplication sharedApplication].keyWindow;
    }
    if (!window && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    return window;
}

- (BOOL)isTopMostView {
    
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *w in windows) {
        // 分享
        Class cls = NSClassFromString(@"TTPanelControllerWindow");
        Class clsNew = NSClassFromString(@"TTNewPanelControllerWindow");
        if ((cls && [w isKindOfClass:cls] && (!w.hidden || [w isKeyWindow])) || (clsNew && [w isKindOfClass:clsNew] && (!w.hidden || [w isKeyWindow]))) {
            return NO;
        }
    }
    
    if ([[UIApplication sharedApplication].keyWindow isKindOfClass:NSClassFromString(@"TTVVideoRotateScreenWindow")]) {
        return YES;
    }
    UIWindow *keyWindow = [self mainWindow];
    
    CGPoint pt = [self.superview convertPoint:self.center toView:keyWindow];
    UIView *topView = [keyWindow hitTest:pt withEvent:nil];
    while (topView) {
        if ([topView isKindOfClass:[TTVPlayerView class]]) {
            return YES;
            break;
        }
        topView = topView.superview;
    }
    return NO;
}


@end
