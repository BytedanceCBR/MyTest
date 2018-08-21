//
//  TTInterfaceTipNightShiftView.m
//  Article
//
//  Created by chenjiesheng on 2017/6/24.
//

#import "TTInterfaceTipNightShiftView.h"
#import "TTInterfaceTipBaseModel.h"
#import "TTTopBar.h"
#import "TTNightShiftService.h"
#import <UIView+CustomTimingFunction.h>
#import <TTAlphaThemedButton.h>
#import <TTUIResponderHelper.h>
#import <TTDeviceHelper.h>
#import <TTDeviceUIUtils.h>
#import "TTNightShiftService.h"
#import <Crashlytics/Crashlytics.h>
#import "ArticleTabbarStyleNewsListViewController.h"

@interface TTInterfaceTipNightShiftView() <CAAnimationDelegate>
@property (nonatomic, strong)SSThemedLabel *titleLabel;
@property (nonatomic, strong)SSThemedLabel *subTitleLabel;
@property (nonatomic, strong)SSThemedLabel *singleLineLabel;
@property (nonatomic, strong)UISwitch      *swichButton;
@property (nonatomic, strong)TTAlphaThemedButton *closeButton;
@property (nonatomic, assign)CGFloat viewHeight;
@property (nonatomic, assign)BOOL animateDismiss;
@property (nonatomic, weak)UIView *myIconSnapshot;
@property (nonatomic, weak)UIView *origionMyIcon;
@property (nonatomic, strong)NSDate *showTime;
@property (nonatomic, assign)BOOL userTouch;
@end

@implementation TTInterfaceTipNightShiftView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.singleLineLabel];
        [self addSubview:self.swichButton];
        [self addSubview:self.closeButton];
        self.viewHeight = 80;
        [self setupSubViewContent];
        [self layoutSubViewUI];
        self.viewHeight = _subTitleLabel.bottom + 20;
    }
    return self;
}

#pragma private

- (void)setupSubViewContent
{
    self.titleLabel.text = [SSCommonLogic nightShiftModeTipViewTitle];
    self.subTitleLabel.text = [SSCommonLogic nightShiftModeTipViewContent];
    self.singleLineLabel.text = [SSCommonLogic openNightShiftModeTipViewContent];
}

- (void)layoutSubViewUI
{
    CGFloat textOrigionX = 22;
    CGFloat titleTopPadding = 20;
    CGFloat textBetweenPadding = 8;
    CGFloat switchRightPadding = 42;
    CGFloat closeButtonRightPadding = 10;
    CGFloat closeButtonTopPadding = 10;
    CGFloat closeButtonWidth = 14;
    [_titleLabel sizeToFit];
    [_subTitleLabel sizeToFit];
    [_swichButton sizeToFit];
    [_singleLineLabel sizeToFit];
    _swichButton.centerY = self.height / 2;
    _swichButton.right = self.width - switchRightPadding;
    
    CGFloat maxLabelWith = _swichButton.left - 10 - textOrigionX;
    CGFloat labelWidth = maxLabelWith;
    labelWidth = MIN(maxLabelWith,_titleLabel.width);
    _titleLabel.frame = CGRectMake(textOrigionX, titleTopPadding, labelWidth, _titleLabel.height);
    labelWidth = MIN(maxLabelWith,_subTitleLabel.width);
    _subTitleLabel.frame = CGRectMake(textOrigionX, _titleLabel.bottom + textBetweenPadding, labelWidth, _subTitleLabel.height);
    labelWidth = MIN(maxLabelWith,_singleLineLabel.width);
    _singleLineLabel.frame = CGRectMake(textOrigionX, titleTopPadding, labelWidth, _singleLineLabel.height);
    _singleLineLabel.centerY = _swichButton.centerY;
    _closeButton.frame = CGRectMake(self.width - closeButtonWidth - closeButtonRightPadding, closeButtonTopPadding, closeButtonWidth, closeButtonWidth);
    
    if ([TTNightShiftService isNightShiftWoking]){
        _singleLineLabel.hidden = NO;
        _titleLabel.hidden = YES;
        _subTitleLabel.hidden = YES;
    }else{
        _singleLineLabel.hidden = YES;
        _titleLabel.hidden = NO;
        _subTitleLabel.hidden = NO;
    }
}

#pragma private

- (NSInteger)currentTimeInterval
{
    NSDate *date = [[NSDate alloc] init];
    NSInteger time = [date timeIntervalSince1970];
    return time;
}

- (NSInteger)stayTimeInterval
{
    if (_showTime == nil){
        return 0;
    }
    NSDate *date = [[NSDate alloc] init];
    NSInteger time = [date timeIntervalSinceDate:_showTime];
    return time;
}

#pragma public

- (void)show
{
    [super show];
    [SSCommonLogic nightShiftModeTipViewShowCountPlus];
    [TTNightShiftService hasShowNightShiftModeTipView];
    _showTime = [[NSDate alloc] init];
    
    [TTTrackerWrapper eventV3:@"eye_care_pop_show" params:@{@"pop_states":@"show"}];
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"kTTNightShiftTipViewCountKey"];
    [Answers logCustomEventWithName:@"night_shift" customAttributes:@{@"tip_show":@(count)}];
}

- (CGFloat)heightForView
{
    return self.viewHeight;
}

- (CGFloat)widthForView
{
    return CGRectGetWidth([UIScreen mainScreen].bounds) - 16;
}

- (CGFloat)bottomPadding
{
    return 8;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutSubViewUI];
}

- (void)selectedTabChangeWithCurrentIndex:(NSUInteger)current lastIndex:(NSUInteger)last isUGCPostEntrance:(BOOL)isPostEntrance
{
    if (current != last || isPostEntrance){
        [self.manager dismissViewWithDefaultAnimation:@NO];
        
        [Answers logCustomEventWithName:@"night_shift" customAttributes:@{@"hidden":@"auto_tab"}];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
        [params setValue:@([self stayTimeInterval]) forKey:@"stay_time"];
        [TTTrackerWrapper eventV3:@"eye_care_pop_hide" params:params];
    }
}

- (void)topVCChange{
    [self.manager dismissViewWithDefaultAnimation:@NO];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setValue:@([self stayTimeInterval]) forKey:@"stay_time"];
    [Answers logCustomEventWithName:@"night_shift" customAttributes:@{@"hidden":@"auto_vc"}];
    [TTTrackerWrapper eventV3:@"eye_care_pop_hide" params:params];
}

- (void)enterBackground
{
    [self.manager dismissViewWithDefaultAnimation:@NO];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setValue:@([self stayTimeInterval]) forKey:@"stay_time"];
    [Answers logCustomEventWithName:@"night_shift" customAttributes:@{@"hidden":@"auto_background"}];
    [TTTrackerWrapper eventV3:@"eye_care_pop_hide" params:params];
}

- (CGFloat)timerDuration
{
    return _userTouch ? 6 : [SSCommonLogic nightShiftModeTipViewAutoDismissTime]/1000.0;
}

- (CGFloat)restartTimerDuration
{
    return 6;
}

- (BOOL)needTimer
{
    return [SSCommonLogic nightShiftModeTipViewAutoDismissTime] > 0;
}

#pragma ButtonAction

- (void)switchButtonClickAction:(UISwitch *)switchButton
{
    _userTouch = YES;
    [self restartTimer];
    [SSCommonLogic setNightShiftModeTipViewDisable];
    BOOL nightShiftWorking = switchButton.on;
    [TTNightShiftService nightShiftModeSetOn:nightShiftWorking];
    if (nightShiftWorking){
        _singleLineLabel.hidden = NO;
        _titleLabel.hidden = YES;
        _subTitleLabel.hidden = YES;
    }else{
        _singleLineLabel.hidden = YES;
        _titleLabel.hidden = NO;
        _subTitleLabel.hidden = NO;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    NSInteger time = [self currentTimeInterval];
    NSInteger stay_time = [self stayTimeInterval];
    [params setValue:nightShiftWorking ? @"on" : @"off" forKey:@"switch_states"];
    [params setValue:@(time) forKey:@"datetime"];
    [TTTrackerWrapper eventV3:@"eye_care_pop_switch" params:params];
    [Answers logCustomEventWithName:@"night_shift" customAttributes:@{@"status":nightShiftWorking ? @"tip_on" : @"tip_off",@"time" : stay_time < 3 ? @"less_3" : @"than_3"}];
}

- (void)closeButtonClickAction{
    [SSCommonLogic setNightShiftModeTipViewDisable];
    
    NSInteger stay_time = [self stayTimeInterval];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:@(stay_time) forKey:@"stay_time"];
    [params setValue:@"close" forKey:@"close_method"];
    [TTTrackerWrapper eventV3:@"eye_care_pop_close" params:params];
    [Answers logCustomEventWithName:@"night_shift" customAttributes:@{@"hidden":@"close", @"time" : stay_time < 3 ? @"less_3" : @"than_3"}];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TTNightShiftService showBubbleTip];
    });
    
    [self.manager dismissViewWithDefaultAnimation:@NO];
}

- (void)removeFromSuperviewByGesture
{
    [super removeFromSuperviewByGesture];
    [SSCommonLogic setNightShiftModeTipViewDisable];

    NSInteger stay_time = [self stayTimeInterval];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setValue:@(stay_time) forKey:@"stay_time"];
    [params setValue:@"gesture" forKey:@"close_method"];
    [TTTrackerWrapper eventV3:@"eye_care_pop_close" params:params];
    [Answers logCustomEventWithName:@"night_shift" customAttributes:@{@"hidden":@"pan_gesture", @"time" : stay_time < 3 ? @"less_3" : @"than_3"}];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TTNightShiftService showBubbleTip];
    });
}

- (void)removeFromSuperViewByTimer
{
    [super removeFromSuperViewByTimer];
    [SSCommonLogic setNightShiftModeTipViewDisable];
    if (_userTouch){
        
        NSInteger stay_time = [self stayTimeInterval];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
        [params setValue:@(stay_time) forKey:@"stay_time"];
        [params setValue:@"auto" forKey:@"close_method"];
        [TTTrackerWrapper eventV3:@"eye_care_pop_close" params:params];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TTNightShiftService showBubbleTip];
        });
    }
}

+ (BOOL)shouldDisplayWithContext:(NSDictionary *)context
{
    UINavigationController *navController = [TTUIResponderHelper topNavigationControllerFor:nil];
    UIViewController *topVC = navController.topViewController;
    if (![topVC isKindOfClass:[ArticleTabBarStyleNewsListViewController class]] || [TTInterfaceTipManager sharedInstance_tt].currentTabBarIndex != 0){
        return NO;
    }
    
    if ([TTNightShiftService isNightShiftWoking]){
        [TTNightShiftService setNeedShowTipView:NO];
        return NO;
    }
    return [TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay;
}

#pragma mark -- Getter && Setter
- (SSThemedLabel *)titleLabel{
    if (_titleLabel == nil){
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    }
    return _titleLabel;
}

- (SSThemedLabel *)singleLineLabel
{
    if (_singleLineLabel == nil){
        _singleLineLabel = [[SSThemedLabel alloc] init];
        _singleLineLabel.textColorThemeKey = kColorText1;
        _singleLineLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    }
    return _singleLineLabel;
}

- (SSThemedLabel *)subTitleLabel{
    if (_subTitleLabel == nil){
        _subTitleLabel = [[SSThemedLabel alloc] init];
        _subTitleLabel.textColorThemeKey = kColorText1;
        _subTitleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
    }
    return _subTitleLabel;
}

- (TTAlphaThemedButton *)closeButton{
    if (_closeButton == nil){
        _closeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _closeButton.imageName = @"detail_close_icon";
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_closeButton addTarget:self action:@selector(closeButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UISwitch *)swichButton{
    if (_swichButton == nil){
        _swichButton = [[UISwitch alloc] init];
        [_swichButton addTarget:self action:@selector(switchButtonClickAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _swichButton;
}
@end
