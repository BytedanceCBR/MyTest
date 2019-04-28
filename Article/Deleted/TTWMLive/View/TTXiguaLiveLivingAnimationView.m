//
//  TTXiguaLiveLivingAnimationView.m
//  Article
//
//  Created by lipeilun on 2017/12/6.
//

#import "TTXiguaLiveLivingAnimationView.h"
#import <Lottie/Lottie.h>

@interface TTXiguaLiveLivingAnimationView()
@property (nonatomic, strong) LOTAnimationView *backAnimationView;
@property (nonatomic, strong) SSThemedLabel *textLabel;
@property (nonatomic, strong) LOTAnimationView *lineAnimationView;
@property (nonatomic, assign) TTXiguaLiveLivingAnimationViewStyle style;
@end

@implementation TTXiguaLiveLivingAnimationView

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(TTXiguaLiveLivingAnimationViewStyle)style {
    if (self = [super init]) {
        self.style = style;
        [self setupSubViews];
        self.backgroundColor = [UIColor clearColor];
        [self addKVO];
    }
    return self;
}

- (void)setupSubViews {
    [self configSelfSize];
    
    switch (self.style) {
        case TTXiguaLiveLivingAnimationViewStyleSmallNoLine:
            self.backgroundColorThemeKey = kColorLine2;
//            [self addSubview:self.backAnimationView];
            [self addSubview:self.textLabel];
            break;
        case TTXiguaLiveLivingAnimationViewStyleMiddleAndLine:
        case TTXiguaLiveLivingAnimationViewStyleLargeAndLine:
        default:
//            [self addSubview:self.backAnimationView];
            self.backgroundColorThemeKey = kColorLine2;
            [self addSubview:self.textLabel];
            [self addSubview:self.lineAnimationView];
            break;
    }
}

- (void)configSelfSize {
    switch (self.style) {
        case TTXiguaLiveLivingAnimationViewStyleSmallNoLine:
            self.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:40], [TTDeviceUIUtils tt_newPadding:16]);
            break;
        case TTXiguaLiveLivingAnimationViewStyleMiddleAndLine:
            self.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:72], [TTDeviceUIUtils tt_newPadding:28]);
            self.alpha = 0.9;
            break;
        case TTXiguaLiveLivingAnimationViewStyleLargeAndLine:
        default:
            self.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:104], [TTDeviceUIUtils tt_newPadding:36]);
            self.alpha = 0.9;
            break;
    }
    self.layer.cornerRadius = self.height/2;
}

- (void)themeChanged:(NSNotification *)notification {
//    [self.backAnimationView removeFromSuperview];
//    self.backAnimationView = nil;
//    [self insertSubview:self.backAnimationView belowSubview:self.textLabel];
    if (self.style != TTXiguaLiveLivingAnimationViewStyleSmallNoLine) {
        [self.lineAnimationView removeFromSuperview];
        self.lineAnimationView = nil;
        [self addSubview:self.lineAnimationView];
    }
    self.textLabel.textColor = [UIColor tt_themedColorForKey:kColorText12];
    [self beginAnimation];
    [self updateSubViewsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateSubViewsLayout];
}

- (void)updateSubViewsLayout {
    switch (self.style) {
        case TTXiguaLiveLivingAnimationViewStyleSmallNoLine: {
//            self.backAnimationView.frame = self.bounds;
            self.textLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:9]];
            self.textLabel.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:6],
                                              [TTDeviceUIUtils tt_newPadding:2],
                                              [TTDeviceUIUtils tt_newPadding:29],
                                              [TTDeviceUIUtils tt_newPadding:12]);
            
        }
            break;
        case TTXiguaLiveLivingAnimationViewStyleMiddleAndLine: {
//            self.backAnimationView.frame = self.bounds;
            
            self.textLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:11]];
            self.textLabel.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:13],
                                              [TTDeviceUIUtils tt_newPadding:6],
                                              [TTDeviceUIUtils tt_newPadding:36],
                                              [TTDeviceUIUtils tt_newPadding:16]);
            
            self.lineAnimationView.frame = CGRectMake(self.textLabel.right + [TTDeviceUIUtils tt_newPadding:1],
                                                      [TTDeviceUIUtils tt_newPadding:9],
                                                      [TTDeviceUIUtils tt_newPadding:10],
                                                      [TTDeviceUIUtils tt_newPadding:10]);
        }
            break;
        case TTXiguaLiveLivingAnimationViewStyleLargeAndLine:
        default: {
//            self.backAnimationView.frame = self.bounds;
            
            self.textLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:15]];
            self.textLabel.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:22],
                                              [TTDeviceUIUtils tt_newPadding:8],
                                              [TTDeviceUIUtils tt_newPadding:50],
                                              [TTDeviceUIUtils tt_newPadding:21]);
            
            self.lineAnimationView.frame = CGRectMake(self.textLabel.right + [TTDeviceUIUtils tt_newPadding:2],
                                                      [TTDeviceUIUtils tt_newPadding:14],
                                                      [TTDeviceUIUtils tt_newPadding:10],
                                                      [TTDeviceUIUtils tt_newPadding:12]);
        }
            break;
    }
}

- (void)beginAnimation {
//    [self.backAnimationView play];
    [self.lineAnimationView play];
}

- (void)stopAnimation {
//    [self.backAnimationView stop];
    [self.lineAnimationView stop];
}

- (LOTAnimationView *)backAnimationView {
    if (!_backAnimationView) {
        NSString *animationFileStr;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            animationFileStr = [[NSBundle mainBundle] pathForResource:@"xg_back_gradient" ofType:@"json" inDirectory:@"XiguaLiveResource.bundle"];
        } else {
            animationFileStr = [[NSBundle mainBundle] pathForResource:@"xg_back_gradient_night" ofType:@"json" inDirectory:@"XiguaLiveResource.bundle"];
        }
        
        _backAnimationView = [LOTAnimationView animationWithFilePath:animationFileStr];
        _backAnimationView.layer.cornerRadius = self.height / 2;
        _backAnimationView.clipsToBounds = YES;
        _backAnimationView.loopAnimation = YES;
        _backAnimationView.backgroundColor = [UIColor clearColor];
        [_backAnimationView play];
    }
    return _backAnimationView;
}

- (LOTAnimationView *)lineAnimationView {
    if (!_lineAnimationView) {
        NSString *animationFileStr;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            animationFileStr = [[NSBundle mainBundle] pathForResource:@"xg_three_line" ofType:@"json" inDirectory:@"XiguaLiveResource.bundle"];
        } else {
            animationFileStr = [[NSBundle mainBundle] pathForResource:@"xg_three_line_night" ofType:@"json" inDirectory:@"XiguaLiveResource.bundle"];
        }
        
        _lineAnimationView = [LOTAnimationView animationWithFilePath:animationFileStr];
        _lineAnimationView.clipsToBounds = YES;
        _lineAnimationView.loopAnimation = YES;
        _lineAnimationView.backgroundColor = [UIColor clearColor];

    }
    return _lineAnimationView;
}

- (SSThemedLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _textLabel.textColor = [UIColor tt_themedColorForKey:kColorText12];
        _textLabel.text = @"直播中";
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}

- (void)willMoveToWindow:(UIWindow *)newWindow{
    if (newWindow) {
        [self beginAnimation];
    }else{
        [self stopAnimation];
    }
}

- (void)addKVO{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(beginAnimation)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

@end
