//
//  SSViewBase.m
//  Gallery
//
//  Created by 苏瑞强 on 17/3/10.
//  Copyright © 2017年 苏瑞强. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SSViewBase.h"
#import "UIColor+TTThemeExtension.h"
#import "TTUIResponderHelper.h"
#import "TTThemeManager.h"

@interface SSViewBase ()
@property(nonatomic, assign)BOOL couldLayoutSubviews;
@property(nonatomic, strong)UIView *nightModeMaskView;
@end

@implementation SSViewBase
@synthesize modeChangeActionType, nightModeMaskView;

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTThemeManagerThemeModeChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

    self.nightModeMaskView = nil;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _couldLayoutSubviews = YES;
        self.modeChangeActionType = ModeChangeActionTypeCustom;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationStautsBarDidRotate:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _couldLayoutSubviews = YES; // if need?
        
        self.modeChangeActionType = ModeChangeActionTypeCustom;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_themeChanged:)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationStautsBarDidRotate:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    return self;
}

- (void)setBackgroundColorThemeName:(NSString *)backgroundColorThemeName {
    NSString * backgroundColor = [backgroundColorThemeName copy];
    _backgroundColorThemeName = backgroundColor;
    self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] rgbaValueForKey:backgroundColorThemeName]];
}

- (void)applicationStautsBarDidRotate:(NSNotification *)notification{
    [self setNeedsLayout];
    _couldLayoutSubviews = YES;
    [self applicationStatusBarOrientationDidChanged];
}

- (void)applicationStatusBarOrientationDidChanged{
    //do nothing...
}

- (void)_themeChanged:(NSNotification*)notification{
    if((modeChangeActionType & ModeChangeActionTypeMask) != 0){
        if([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight){
            if(!nightModeMaskView){
                [self buildMaskView];
            }
            
            [self addSubview:nightModeMaskView];
        }
        else{
            [nightModeMaskView removeFromSuperview];
        }
    }
    
    if((modeChangeActionType & ModeChangeActionTypeCustom) != 0){
        [nightModeMaskView removeFromSuperview];
        [self themeChanged:notification];
    }
}

- (void)buildMaskView{
    self.nightModeMaskView = [[UIView alloc] initWithFrame:self.bounds];
    nightModeMaskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    nightModeMaskView.alpha = 0.5f;
    nightModeMaskView.backgroundColor = [UIColor blackColor];
    nightModeMaskView.layer.zPosition = 10;
    nightModeMaskView.userInteractionEnabled = NO;
}

- (void)reloadThemeUI{
    [self _themeChanged:nil];
}

- (void)themeChanged:(NSNotification*)notification{
    if (self.backgroundColorThemeName) {
        self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] rgbaValueForKey:self.backgroundColorThemeName]];
    }
}

- (void)willAppear {}
- (void)didAppear {}
- (void)willDisappear {}
- (void)didDisappear {}
- (void)didReceiveMemoryWarning {}

- (void)trySSLayoutSubviews{
    if(_couldLayoutSubviews){
        [self ssLayoutSubviews];
        _couldLayoutSubviews = NO;
    }
}

- (void)ssLayoutSubviews{
}

@end

@implementation UIView (SSViewControllerAccessor)

- (UIViewController *) viewController {
    return [TTUIResponderHelper topViewControllerFor:self];
}

- (UINavigationController *) navigationController {
    return [TTUIResponderHelper topNavigationControllerFor:self];
}

@end
