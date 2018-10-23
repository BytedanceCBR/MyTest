//
//  SSMojiWeatherView.m
//  Article
//
//  Created by Kimimaro on 13-5-20.
//
//

#import "SSMojiWeatherView.h"
#import "SSMojiHeader.h"
#import "SSLocationManager.h"

@interface SSMojiWeatherView ()
@property (nonatomic, retain) UIView *mojiView;
@end

@implementation SSMojiWeatherView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MOJI_SDK_AUTH_SUCCESS" object:nil];
    self.mojiView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportMojiInitializeSuccess:) name:SSMojiInitializeSuccessNotification object:nil];
        
        self.mojiView = [[MoJiSdk sdkInstance] getConciseView:[[SSLocationManager sharedManager] city]];
        if (_mojiView) {
            _mojiView.frame = self.bounds;
            [self addSubview:_mojiView];
        }
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    if (_mojiView && [SSCommon isPadDevice]) {
        [[MoJiSdk sdkInstance] setNightMode:[SSResourceManager shareBundle].currentMode == SSThemeModeNight];
    }
}

- (void)updateWeather
{
    [[MoJiSdk sdkInstance] updateWeather:[[SSLocationManager sharedManager] city]];
}

#pragma mark - notifications

- (void)reportMojiInitializeSuccess:(NSNotification *)notification
{
    if (!_mojiView) {
        self.mojiView = [[MoJiSdk sdkInstance] getConciseView:[[SSLocationManager sharedManager] city]];
        _mojiView.frame = self.bounds;
        [self addSubview:_mojiView];
        
        [self reloadThemeUI];
    }
}

@end
