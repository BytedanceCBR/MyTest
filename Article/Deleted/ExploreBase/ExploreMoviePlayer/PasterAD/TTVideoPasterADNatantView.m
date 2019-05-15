//
//  TTVideoPasterADNatantView.m
//  Article
//
//  Created by Dai Dongpeng on 5/26/16.
//
//

#import "TTVideoPasterADNatantView.h"
#import "TTVideoPasterADModel.h"
#import <Masonry/Masonry.h>
#import "UIColor+TTThemeExtension.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+TTAdditions.h"
#import "NSTimer+Additions.h"
#import "NSTimer+NoRetain.h"
#import "TTLabelTextHelper.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import <libextobjc/extobjc.h>

@interface TTVideoPasterADNatantView ()

@property (nonatomic, strong) TTVideoPasterADModel *adModel;

@property (nonatomic, strong) SSThemedLabel *skipLabel;
@property (nonatomic, strong) SSThemedLabel *durationLabel;
@property (nonatomic, strong) TTAlphaThemedButton *skipButton;
@property (nonatomic, strong) TTAlphaThemedButton *showDetailButton;
@property (nonatomic, strong) TTAlphaThemedButton *fullScreenButton;
@property (nonatomic, strong) TTAlphaThemedButton *backButton;
@property (nonatomic, strong) UIView *separateLineView;
@property (nonatomic, strong) SSThemedView *skipBackgroundView;
@property (nonatomic, strong) SSThemedView *skipTouchView;
@property (nonatomic, strong) UIImageView *titleShadowView;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger skipTime;
@property (nonatomic, assign) BOOL isFullScreen;

//@property (nonatomic, strong) TTAlphaThemedButton *controlButton;

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, assign) NSInteger titleTime;

@end

static NSString *kDurationTimeFontName = @"DS-Digital-Italic";

@implementation TTVideoPasterADNatantView

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (instancetype)initWithFrame:(CGRect)frame pasterADModel:(TTVideoPasterADModel *)adModel
{
    if (self = [super initWithFrame:frame]) {
        _adModel = adModel;
        _skipTime = 0;//adModel.skipTime.integerValue;
        _durationTime = adModel.videoPasterADInfoModel.duration.integerValue;
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
}

- (void)resumeTimer
{
    [self.timer tt_resume];
}

- (void)hidePlayButtonAnimated:(BOOL)animated
{
//    [UIView animateWithDuration:animated ? .35 : 0 animations:^{
//        self.controlButton.alpha = 0;
//    }];
}

- (void)hidePauseButtonAnimated:(BOOL)animated
{
//    [self hidePlayButtonAnimated:animated];
}

- (void)showPlayButtonAnimated:(BOOL)animated
{
//    CGFloat duration = animated ? .35 : 0;
//
//    self.controlButton.selected = NO;
//    self.controlButton.hidden = NO;
//
//    [UIView animateWithDuration:duration animations:^{
//           self.controlButton.alpha = 1.f;
//    }];
}

- (void)showPauseButtonAnimated:(BOOL)animated
{
//    CGFloat duration = animated ? .35 : 0;
//
//    self.controlButton.selected = YES;
//    self.controlButton.hidden = NO;
//
//    [UIView animateWithDuration:duration animations:^{
//        self.controlButton.alpha = 1.f;
//    }];
}

- (void)controlButtonAction:(UIButton *)button
{
//    if (!button.selected && [self.delegate respondsToSelector:@selector(playButtonClicked:)]) {
//        [self.delegate playButtonClicked:button];
//    } else if (button.selected && [self.delegate respondsToSelector:@selector(pauseButtonClicked:)]) {
//        [self.delegate pauseButtonClicked:button];
//    }
}

- (BOOL)isPlayButtonShowed
{
    return NO;//!self.controlButton.hidden && self.controlButton.alpha >= 1 && !self.controlButton.selected;
}
- (BOOL)isPauseButtonShowed
{
    return NO;//!self.controlButton.hidden && self.controlButton.alpha >= 1 && self.controlButton.selected;
}

#pragma mark -
- (void)timerAction:(NSTimer *)timer
{
    if (--self.durationTime > 0) {
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
    self.titleLabel.hidden = YES;
    self.titleShadowView.hidden = YES;
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
    if ([self.adModel.videoPasterADInfoModel.enableClick boolValue] && [self.delegate respondsToSelector:@selector(pasterADClicked)]) {
        [self.delegate pasterADClicked];
    }
}

#pragma mark - Layout

- (void)setupSubViews
{
    
    CGFloat skipFontSize = [TTDeviceUIUtils tt_fontSize:12];
    CGFloat durationFontSize = [TTDeviceUIUtils tt_fontSize:16];
    
    CGFloat lineHeight = [TTDeviceUIUtils tt_lineHeight:8];
    CGFloat bgViewHeight = [TTDeviceUIUtils tt_lineHeight:24];
    CGFloat bgViewWidth = [TTDeviceUIUtils tt_lineHeight:118];

    CGFloat lineWidth = [TTDeviceHelper ssOnePixel];
    CGFloat viewSpace5 = [TTDeviceUIUtils tt_padding:5];
    CGFloat viewSpace7 = [TTDeviceUIUtils tt_padding:7];
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
    
    UIView *line = [[UIView alloc] init];
    {
        TTAlphaThemedButton *skipButton = [[TTAlphaThemedButton alloc] init];
        [skipButton setTitleColorThemeKey:kColorText8];
        skipButton.titleLabel.font = skipLabelFont;
        [skipButton addTarget:self action:@selector(skipButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [skipButton setTitle:NSLocalizedString(@"关闭广告", nil) forState:UIControlStateNormal];
        skipButton.imageName = @"closeicon_ad_video";
        //skipButton.imageName = @"skipicon_ad_video";
        skipButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        skipButton.hidden = YES;
        
        [self.skipBackgroundView addSubview:skipButton];
        self.skipButton = skipButton;
        
        [skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self.skipBackgroundView.mas_centerY);
            make.right.equalTo(self.skipBackgroundView.mas_right).offset(-viewSpace12);
        }];
        [skipButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageRight imageTitlespace:viewSpace5];
        
        // line
        line.backgroundColor = [UIColor tt_defaultColorForKey:kColorText11];
        
        [self.skipBackgroundView addSubview:line];
        self.separateLineView = line;
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(skipButton.mas_centerY);
//            make.right.equalTo(skipLabel.mas_left).offset(-viewSpace10).priority(200);
            make.right.equalTo(skipButton.mas_left).offset(-viewSpace7);
            make.width.equalTo(@(lineWidth));
            make.height.equalTo(@(lineHeight));
        }];
        
        if (self.skipTime == 0) { //特殊处理skipTime＝0，显示skip button
            [self showSkipButton];
        }
    }

    // duration
    SSThemedLabel *duration = [[SSThemedLabel alloc] init];
    duration.text = (self.durationTime > 9) ? [@(self.durationTime) stringValue]: [NSString stringWithFormat:@"0%@", @(self.durationTime)];
    duration.font = durationFont;
    
    duration.textColor = [UIColor tt_defaultColorForKey:kColorText8];
    duration.textAlignment = NSTextAlignmentCenter;
    duration.backgroundColor = bgColor;
    [self.skipBackgroundView addSubview:duration];
    self.durationLabel = duration;
    
    [duration mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.skipBackgroundView.mas_centerY);
//        make.right.equalTo(line.mas_left).offset(-viewSpace8);
        make.left.equalTo(@(viewSpace12));

    }];
    
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
            make.bottom.mas_offset(-viewSpace10);
            make.width.equalTo(@(fullScreenButtonDiameter));
            make.height.equalTo(@(fullScreenButtonDiameter));
        }];
        
        
        CGFloat showDetailFontSize = [TTDeviceUIUtils tt_fontSize:12];
//        CGFloat detailButtonWidth = [TTDeviceUIUtils tt_padding:72];
        CGFloat detailButtonHeight = [TTDeviceUIUtils tt_padding:24];
        
        TTAlphaThemedButton *showDetailButton = [[TTAlphaThemedButton alloc] init];
        [showDetailButton setTitleColorThemeKey:kColorText8];
        [showDetailButton.titleLabel setFont:[UIFont systemFontOfSize:showDetailFontSize]];
        //    showDetailButton.backgroundColor = [UIColor colorWithHexString:@"2a90d7b2"];
        showDetailButton.backgroundColor = [[UIColor tt_defaultColorForKey:kColorBackground8] colorWithAlphaComponent:.7f];
//        showDetailButton.backgroundColor = [UIColor tt_defaultColorForKey];
        showDetailButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        NSString *detailText = !(isEmptyString(self.adModel.videoPasterADInfoModel.buttonText))? self.adModel.videoPasterADInfoModel.buttonText: @"查看详情";
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
            make.width.equalTo(@(showDetaiBtnFrame.size.width));
            make.height.equalTo(@(detailButtonHeight));
            
        }];
        
        //back button
        TTAlphaThemedButton *backButton = [[TTAlphaThemedButton alloc] init]; //
        backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -12, -15, -36);
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
    
    if (!isEmptyString(_adModel.videoPasterADInfoModel.title) && _adModel.videoPasterADInfoModel.titleTime)
    {
        UIImageView *shadowView = [[UIImageView alloc] init];
        UIImage *shadowImage = [UIImage imageNamed:@"video_paster_shadow"];
        [shadowView setImage:shadowImage];
        [self insertSubview:shadowView atIndex:0];
        self.titleShadowView = shadowView;
        
        SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
        titleLabel.font = durationFont;
        titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText8];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 2;
        
        NSString *text = _adModel.videoPasterADInfoModel.title;
        NSInteger length = [text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        length -= (length - text.length) / 2;
        length = (length +1) / 2;
        if (length >25) {
            text = [text substringToIndex:25];
        }
        
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:3];//行间距
        [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
        [titleLabel setAttributedText:attributedString];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_showDetailButton.mas_left).offset(-viewSpace7);
            make.left.mas_offset(@(viewSpace15));
            make.bottom.mas_offset(-viewSpace10);
        }];
        
         _titleTime = [_adModel.videoPasterADInfoModel.titleTime integerValue];
        if (_titleTime == 0) {
            titleLabel.hidden = YES;
            self.titleShadowView.hidden = YES;
        }
    }
    
    //play pause button
//    self.controlButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
//    self.controlButton.imageName = @"playicon_video";
//    self.controlButton.selectedImageName = @"pauseicon_video";
//    self.controlButton.hidden = YES;
//    [self.controlButton addTarget:self action:@selector(controlButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.controlButton];
//    [self.controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.mas_centerY);
//        make.centerX.equalTo(self.mas_centerX);
//    }];
}

- (void)showSkipButton
{
    self.skipButton.hidden = NO;
    self.skipLabel.hidden = YES;
    CGFloat viewSpace10 = [TTDeviceUIUtils tt_padding:10.f];
    [self.separateLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.skipButton.mas_left).offset(-viewSpace10).priority(800);
    }];
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
        if ((cls && [w isKindOfClass:cls] && ([w isKeyWindow] || !w.isHidden)) || (clsNew && [w isKindOfClass:clsNew] && ([w isKeyWindow] || !w.isHidden))) {
            return NO;
        }
    }
    
    UIWindow *keyWindow = [self mainWindow];
    
    CGPoint pt = [self.superview convertPoint:self.center toView:keyWindow];
    UIView *topView = [keyWindow hitTest:pt withEvent:nil];
    
    while (topView) {
        if (topView == self) {
            return YES;
        }
        topView = topView.superview;
    }
    
    return NO;
}


@end
