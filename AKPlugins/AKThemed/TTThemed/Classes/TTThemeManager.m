//
//  TTThemeManager.m
//  Zhidao
//
//  Created by Nick Yu on 3/3/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "TTThemeManager.h"
#import "TTUIResponderHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "UIColor+TTThemeExtension.h"

NSString *const TTThemeModeStorageKey = @"TTThemeModeStorageKey";
NSString *const TTThemeManagerThemeModeChangedNotification = @"TTThemeManagerThemeModeChangedNotification";

@interface TTThemeManager ()

@property (nonatomic, strong) NSDictionary *defaultTheme;
@property (nonatomic, strong) NSDictionary *currentTheme;
@property (nonatomic, strong) NSCache *colorCache;
@property (nonatomic, strong) UIWindow *nightModelWindow;
@property (nonatomic, assign, readwrite) TTThemeMode currentThemeMode;

@end

@implementation TTThemeManager

#pragma mark - initialization
+ (void)load {
    [TTThemeManager sharedInstance_tt];
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.currentThemeMode = (TTThemeMode)[[NSUserDefaults standardUserDefaults] integerForKey:TTThemeModeStorageKey];
        
        if (!self.currentThemeMode) {
            self.currentThemeMode = TTThemeModeDay;
        }
        
        self.colorCache = [[NSCache alloc] init];
        
        if (!self.defaultTheme) {
            self.defaultTheme = [self dictionaryForBundle:nil theme:@"default"];
        }
        
        if (_currentThemeMode == TTThemeModeDay) {
            [self switchThemeModeto:TTThemeModeDay needBroadcast:NO];
        }
        else {
            [self switchThemeModeto:TTThemeModeNight needBroadcast:NO];
        }
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            if (_currentThemeMode == TTThemeModeNight) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadNightWindow];
                    //                    [self toggleNightWindow:_currentThemeMode];
                });
            }
        }];
        
    }
    return self;
}


/**
 *  使用新的bundle配置
 */
+ (void)applyBundleName:(NSString *)bundleName {
    [[TTThemeManager sharedInstance_tt] applyBundleName:bundleName];
}

- (void)applyBundleName:(NSString *)bundleName {
    self.currentTheme = [self dictionaryForBundle:bundleName theme:@"default"];
}

#pragma mark - public method
- (UIColor *)themedColorForKey:(NSString *)key {
    if (self.currentTheme && [self.currentTheme[@"colors"] valueForKey:key]) {
        NSString *colorString = [self.currentTheme[@"colors"] valueForKey:key];
        
        UIColor *color = [self.colorCache objectForKey:colorString];
        
        if (!color) {
            color = [UIColor colorWithHexString:colorString];
            
            if (color) {
                [self.colorCache setObject:color forKey:colorString];
            }
        }
        
        return color;
    }
    if (key && [key isKindOfClass:[NSString class]] && (key.length == 6 || key.length == 8)) {
        return [UIColor colorWithHexString:key];
    }
    return nil;
}

- (UIImage *)themedImageForKey:(NSString *)key {
    NSDictionary *themeDict = self.currentTheme;
    if (themeDict && [themeDict[@"images"] valueForKey:key]) {
        NSString *imageName = [themeDict[@"images"] valueForKey:key];
        return [UIImage themedImageNamed:imageName];
    }
    return nil;
}

- (NSString *)rgbaValueForKey:(NSString *)key {
    NSDictionary *themeDict = self.currentTheme;
    return [themeDict[@"colors"] valueForKey:key];
}

- (NSString *)rgbaDefalutThemeValueForKey:(NSString *)key {
    
    NSDictionary *themeDict = self.defaultTheme;
    return [themeDict[@"colors"] valueForKey:key];
}

- (UIColor *)defaultThemeColorForKey:(NSString *)key {
    
    if (self.defaultTheme && [self.defaultTheme[@"colors"] valueForKey:key]) {
        NSString *colorString = [self.defaultTheme[@"colors"] valueForKey:key];
        
        UIColor *originalColor = [self.colorCache objectForKey:colorString];
        
        if (!originalColor) {
            originalColor = [UIColor colorWithHexString:colorString];
            
            if (originalColor) {
                [self.colorCache setObject:originalColor forKey:colorString];
            }
        }
        
        return originalColor;
    }
    
    if (key && [key isKindOfClass:[NSString class]] && (key.length == 6 || key.length == 8)) {
        return [UIColor colorWithHexString:key];
    }
    return nil;
}

- (UIStatusBarStyle)statusBarStyle {
    NSDictionary *themeDict = self.currentTheme;
    NSUInteger style = [[themeDict[@"colors"] valueForKey:@"StatusBarStyle"] integerValue];
    return style;
}

- (BOOL)viewControllerBasedStatusBarStyle {
    NSDictionary *themeDict = self.currentTheme;
    return [themeDict[@"statusBarViewContrllerBased"] boolValue];
}

- (BOOL)switchThemeModeto:(TTThemeMode)themeMode needBroadcast:(BOOL)needBroadcast {
    self.currentThemeMode = themeMode;
    [[NSUserDefaults standardUserDefaults] setInteger:self.currentThemeMode forKey:TTThemeModeStorageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (themeMode == TTThemeModeDay) {
        self.currentTheme = [self dictionaryForBundle:nil theme:@"default"];
    }
    else {
        self.currentTheme = [self dictionaryForBundle:nil theme:@"night"];
    }
    
    if (needBroadcast) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TTThemeManagerThemeModeChangedNotification object:self];
        });
    }
    
    //    [self toggleNightWindow:_currentThemeMode];
    
    return YES;
}

- (BOOL)switchThemeModeto:(TTThemeMode)themeMode {
    return [self switchThemeModeto:themeMode needBroadcast:YES];
}

- (NSString *)currentThemeName {
    if (_currentThemeMode == TTThemeModeDay) {
        return @"default";
    }
    else {
        return @"night";
    }
}

- (NSString *)selectFromDayColorName:(NSString *)dayName nightColorName:(NSString *)nightName {
    if (_currentThemeMode == TTThemeModeDay) {
        return dayName;
    }
    else {
        if (!nightName) {
            return dayName;
        }
        return nightName;
    }
}

#pragma mark - private method
- (void)loadNightWindow {
    if (!self.nightModelWindow) {
        self.nightModelWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0,
                                                                           MAX([TTUIResponderHelper screenSize].width,
                                                                               [TTUIResponderHelper screenSize].height),
                                                                           MAX([TTUIResponderHelper screenSize].width,
                                                                               [TTUIResponderHelper screenSize].height))];
        self.nightModelWindow.userInteractionEnabled = NO;
        self.nightModelWindow.backgroundColor = [UIColor blackColor];
        self.nightModelWindow.alpha = 0.5f;
        self.nightModelWindow.windowLevel = UIWindowLevelStatusBar + 1;
    }
}

- (void)toggleNightWindow:(TTThemeMode)themeMode {
    if (themeMode == TTThemeModeNight) {
        if (self.nightModelWindow.hidden == YES) {
            self.nightModelWindow.hidden = NO;
            self.nightModelWindow.alpha = 0.0f;
            [UIView animateWithDuration:0.3 animations:^{
                self.nightModelWindow.alpha = 0.5f;
            }];
        }
    }
    else {
        if (self.nightModelWindow.hidden == NO) {
            self.nightModelWindow.hidden = YES;
            self.nightModelWindow.alpha = 0.5f;
            [UIView animateWithDuration:0.3 animations:^{
                self.nightModelWindow.alpha = 0.0f;
            }];
        }
    }
}

- (NSDictionary *)dictionaryForBundle:(NSString *)bundleName theme:(NSString*)themeName {
    if (!bundleName) bundleName = @"TTThemed";
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_theme", themeName];
    NSString *path = [bundle pathForResource:fileName ofType:@"plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        path = [[NSBundle mainBundle] pathForResource:@"default_theme" ofType:@"plist"];
    }
    return [NSDictionary dictionaryWithContentsOfFile:path];
}
@end
