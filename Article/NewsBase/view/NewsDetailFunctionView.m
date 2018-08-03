//
//  NewsDetailFunctionView.m
//  Article
//
//  Created by Dianwei on 14-3-19.
//
//

#import "NewsDetailFunctionView.h"
#import "NewsUserSettingManager.h"
#import "UIImageAdditions.h"
#import "TTThemeManager.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"

@interface NewsDetailFunctionView()<UIGestureRecognizerDelegate>

@property(nonatomic, retain)UIImageView *nightmodeImageView;
@property(nonatomic, retain)UILabel *nightmodeLabel;
@property(nonatomic, retain)UISwitch *nightModeSwitch;
@property(nonatomic, retain)UIView *nightModeLineView;

@property(nonatomic, retain)UIImageView *fontImageView;
@property(nonatomic, retain)UILabel *fontLabel;
@property(nonatomic, retain)UISegmentedControl *fontSegment;

@property(nonatomic, retain)UIButton *closeButton;
@property(nonatomic, retain)UIView *maskView;
@property(nonatomic, retain)UITapGestureRecognizer *tapRecognizer;
@property(nonatomic, retain)UISwipeGestureRecognizer *swipeRecognizer;
@end

@implementation NewsDetailFunctionView

- (void)dealloc
{
    self.umengEventName = nil;
    self.nightmodeImageView = nil;
    self.nightmodeLabel = nil;
    self.nightModeSwitch = nil;
    self.nightModeLineView = nil;

    self.fontImageView = nil;
    self.fontLabel = nil;
    self.fontSegment = nil;
    self.closeButton = nil;
    self.nightModeLineView = nil;
    self.maskView = nil;
    [_maskView removeGestureRecognizer:_tapRecognizer];
    self.tapRecognizer = nil;
    
    [_maskView removeGestureRecognizer:_swipeRecognizer];
    self.swipeRecognizer = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.umengEventName = @"detail";
        float onewidth = [[UIScreen mainScreen] scale] == 2.0f ? .5f : 1.f;
        float offsetX = 10;
        
        self.nightmodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 18, 29, 29)];
        [self addSubview:_nightmodeImageView];
        offsetX = (_nightmodeImageView.right) + 10;
        
        self.nightmodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nightmodeLabel.font = [UIFont boldSystemFontOfSize:16];
        _nightmodeLabel.backgroundColor = [UIColor clearColor];
        _nightmodeLabel.text = NSLocalizedString(@"夜间模式", nil);
        [_nightmodeLabel sizeToFit];
        
        _nightmodeLabel.left = offsetX;
        _nightmodeLabel.centerY = _nightmodeImageView.center.y;

        [self addSubview:_nightmodeLabel];
        
        self.nightModeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_nightModeSwitch setOn:[[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight];
        [_nightModeSwitch addTarget:self action:@selector(nightModeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [_nightModeSwitch sizeToFit];

        _nightModeSwitch.left = self.width - 10 - (_nightModeSwitch.width);
        _nightModeSwitch.centerY = _nightmodeLabel.centerY;
        [self addSubview:_nightModeSwitch];
        
        self.nightModeLineView = [[UIView alloc] initWithFrame:CGRectMake(0, (_nightmodeImageView.bottom) + 12, self.width, onewidth)];
        [self addSubview:_nightModeLineView];
        
        offsetX = 10;
        
        
        
        self.fontImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, (_nightModeLineView.bottom) + 12, 29, 29)];
        [self addSubview:_fontImageView];
        offsetX = (_fontImageView.right) + 10;
        
        self.fontLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _fontLabel.font = [UIFont boldSystemFontOfSize:16];
        _fontLabel.backgroundColor = [UIColor clearColor];
        _fontLabel.text = NSLocalizedString(@"字体大小", nil);
        
        [_fontLabel sizeToFit];
       
        _fontLabel.origin = CGPointMake(offsetX, (_nightModeLineView.bottom) + 16);
        [self addSubview:_fontLabel];
        
        self.fontSegment = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"小", nil), NSLocalizedString(@"中", nil), NSLocalizedString(@"大", nil), NSLocalizedString(@"特大", nil)]];
        
        float fontSegmentWidth = 160;
        _fontSegment.frame = CGRectMake(self.width - 10 - fontSegmentWidth, (_nightModeLineView.bottom) + 12, fontSegmentWidth, 30);
        _fontSegment.clipsToBounds = YES;
        [_fontSegment setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} forState:UIControlStateNormal];
        [_fontSegment addTarget:self action:@selector(fontSegmentValueChanged:) forControlEvents:UIControlEventValueChanged];
        _fontSegment.selectedSegmentIndex = [NewsUserSettingManager fontSettingIndex];
        [self addSubview:_fontSegment];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
        _closeButton.layer.borderWidth = onewidth;
        
        _closeButton.frame = CGRectMake(8, (_fontImageView.bottom) + 20, self.width - 16, 44);
        [_closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
        _closeButton.layer.borderWidth = onewidth;
        [self addSubview:_closeButton];
        
        
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        
        self.maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.alpha = .35f;
        [_maskView addGestureRecognizer:_tapRecognizer];
        
        self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp;
        _swipeRecognizer.delegate = self;
        [_maskView addGestureRecognizer:_swipeRecognizer];
        [self reloadThemeUI];
    }
    
    return self;
}

- (void)tapped:(UIGestureRecognizer*)recognizer
{
    [self dismiss];
}

- (void)swiped:(UIGestureRecognizer*)recognizer
{
    [self dismiss];
}

- (void)themeChanged:(NSNotification *)notification
{
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [_nightmodeImageView setImage:[UIImage themedImageNamed:@"night_more_details.png"]];
    _nightmodeLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"363636" nightColorName:@"707070"]];
    
    if([_nightModeSwitch respondsToSelector:@selector(setOnTintColor:)])
    {
        [_nightModeSwitch setOnTintColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"2a90d7" nightColorName:@"4371a0"]]];
    }
    
    _nightModeLineView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"dddddd" nightColorName:@"363636"]];
    
    [_fontImageView setImage:[UIImage themedImageNamed:@"font_more_details.png"]];
    _fontLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"363636" nightColorName:@"707070"]];
    
    

    if([_fontSegment respondsToSelector:@selector(setTintColor:)])
    {
        [_fontSegment setTintColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"2a90d7" nightColorName:@"4371a0"]]];
    }
        
    [_closeButton setTitleColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"505050" nightColorName:@"505050"]] forState:UIControlStateNormal];
    _closeButton.layer.borderColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"dddddd" nightColorName:@"363636"]].CGColor;
    [_closeButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"f5f5f5" nightColorName:@"f5f5f5"]] size:CGSizeMake(1, 1)] forState:UIControlStateHighlighted];
    _maskView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"000000" nightColorName:@"000000"]];
}


//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    return NO;
//}

- (void)close:(id)sender
{
    [self dismiss];
}

- (void)nightModeSwitchChanged:(id)sender
{
    UISwitch *nightModeSwitch = (UISwitch*)sender;
    ////// 统计是否是夜间模式
    NSString * eventID = (nightModeSwitch.on) ? @"click_to_night":@"click_to_day";
    wrapperTrackEvent(_umengEventName, eventID);
    [[TTThemeManager sharedInstance_tt] switchThemeModeto:(nightModeSwitch.isOn ? TTThemeModeNight : TTThemeModeDay)];
    if (_dismissAfterChangeSetting) {
        [self dismiss];
    }

}


- (void)brightnessSliderValueChanged:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    [[UIScreen mainScreen] setBrightness:slider.value];
}

- (void)fontSegmentValueChanged:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    ////// 统计字体型号
    const NSArray * fontArray = @[@"font_small", @"font_middle", @"font_big", @"font_ultra_big"];
    NSUInteger selectedIndex = segment.selectedSegmentIndex;
    NSString * eventID = nil;
    if (selectedIndex < fontArray.count) {
        eventID = fontArray[selectedIndex];
    } else {
        eventID = fontArray[0];
    }
    wrapperTrackEvent(_umengEventName, eventID);
    [TTUserSettingsManager setSettingFontSize:(int)segment.selectedSegmentIndex];
    
    if (_dismissAfterChangeSetting) {
        [self dismiss];
    }
}


- (void)showInView:(UIView*)view atPoint:(CGPoint)point
{
    self.origin = CGPointMake(0, (view.height));
    _maskView.frame = view.bounds;
    [view addSubview:_maskView];
    [view addSubview:self];
    [UIView animateWithDuration:.25 animations:^{
        self.origin = CGPointMake(point.x, point.y);
    } completion:^(BOOL finished) {
        _isDisplay = YES;
    }];
}

- (void)dismiss
{
    UIView *superview = [self superview];
    [_maskView removeFromSuperview];
    if(superview)
    {
        [UIView animateWithDuration:.25 animations:^{
            
            self.origin = CGPointMake(0, (superview.height));
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            _isDisplay = NO;
        }];
    }
}

@end
