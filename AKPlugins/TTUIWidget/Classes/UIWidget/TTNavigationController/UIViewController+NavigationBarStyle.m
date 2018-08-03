//
//  UIViewController+NavigationBarConfig.m
//  TestUniversaliOS6
//
//  Created by yuxin on 3/26/15.
//  Copyright (c) 2015 Nick Yu. All rights reserved.
//

#import "UIViewController+NavigationBarStyle.h"
#import "TTThemeManager.h"
#import "UINavigationController+NavigationBarConfig.h"
#import "SSThemed.h"
#import "NSObject+FBKVOController.h"
#import "TTThemeManager.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"

@import ObjectiveC;

@interface TTNavigationBar ()

@property (nonatomic, strong, readwrite) SSThemedView *bottomLine;

@end

@implementation TTNavigationBar

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadTheme)
                                                     name:TTThemeManagerThemeModeChangedNotification
                                                   object:nil];
        [self setValue:@(YES) forKey:@"hidesShadow"];
        [self addBottomLine];
    }
    return self;
}

- (void)setItem:(UINavigationItem *)item {
    _item = item;
}

- (void)addBottomLine {
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bounds) - [TTDeviceHelper ssOnePixel], CGRectGetWidth(self.bounds), [TTDeviceHelper ssOnePixel])];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        _bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bottomLine];
    }
}

- (void)reloadTheme {
    [self tt_configNavBarWithTheme:self.viewController.navigationController.ttNavBarStyle];
}

- (void)tt_configNavBarWithTheme:(NSString *)style
{
    if (self.viewController.ttNaviTranslucent) {
        self.translucent = YES;
    } else {
        self.translucent = NO;
    }
    
    if (!style) {
        if (self.viewController.navigationController.ttNavBarStyle) {
            style = self.viewController.navigationController.ttNavBarStyle;
        } else if (self.viewController.navigationController.ttDefaultNavBarStyle) {
            style = self.viewController.navigationController.ttDefaultNavBarStyle;
        } else {
            style = @"White";
        }
    }
    
    //title的文字颜色
    UIColor *titleTextColor = [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationTextColor%@", style]];
    NSMutableDictionary *titleTextAttrDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [titleTextAttrDict setValue:[UIFont systemFontOfSize:16]
                         forKey:NSFontAttributeName];
    [titleTextAttrDict setValue:titleTextColor
                         forKey:NSForegroundColorAttributeName];
    self.titleTextAttributes = titleTextAttrDict;
    
    //如果是背景图 就用图 否则用颜色
    if (![style isEqualToString:@"Image"] && [UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationBarBackground%@", style]]) {
        
        [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        if (!self.viewController.navigationController.isPop) {
            [self setBarTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationBarBackground%@", style]]];
            
            //这个是左右控件 如果是plain text的，把文本颜色改成我们需要的
            [self setTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationTextColor%@", style]]];
        } else {
            [[self.viewController.navigationController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                [self setBarTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationBarBackground%@", style]]];
                
                //这个是左右控件 如果是plain text的，把文本颜色改成我们需要的
                [self setTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationTextColor%@", style]]];
            } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                
                if (![context isCancelled]) {
                    [self setBarTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationBarBackground%@", style]]];
                    
                    //这个是左右控件 如果是plain text的，把文本颜色改成我们需要的
                    [self setTintColor:[UIColor tt_themedColorForKey:[NSString stringWithFormat:@"navigationTextColor%@", style]]];
                }
            }];
        }
    } else {
        [self setBarTintColor:nil];
        [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        if ([style isEqualToString:@"Image"]) {
            if ([UIImage tt_themedImageForKey:[NSString stringWithFormat:@"navigationBarBackground%@",style]]) {
                [self setBackgroundImage:[UIImage tt_themedImageForKey:[NSString stringWithFormat:@"navigationBarBackground%@",style]]
                           forBarMetrics:UIBarMetricsDefault];
            }
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11.0, *)){
        //消除右移16的问题
        for(UIView *view in self.subviews){
            NSString *contentViewClass = [@[@"_UIN", @"avigat", @"ionBarC", @"onten", @"tView"] componentsJoinedByString:@""];
            if ([view isKindOfClass:NSClassFromString(contentViewClass)]){
                NSDirectionalEdgeInsets insets = view.directionalLayoutMargins;
                UIBarButtonItem *leftBarButtonItem = self.viewController.navigationItem.leftBarButtonItem;
                UIBarButtonItem *rightBarButtonItem = self.viewController.navigationItem.rightBarButtonItem;
                CGFloat leftViewInset = insets.leading;
                CGFloat rightViewInset = insets.trailing;
                if (leftBarButtonItem.customView){
                    leftViewInset -= leftBarButtonItem.customView.alignmentRectInsets.left;
                }
                if (rightBarButtonItem.customView){
                    rightViewInset -= rightBarButtonItem.customView.alignmentRectInsets.right;
                }
                view.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(insets.top, leftViewInset, insets.bottom, rightViewInset);
            }
        }
    }
    
    if (self.bottomLine) {
        [self bringSubviewToFront:self.bottomLine];
    }
    
    if (self.viewController.ttNeedTopExpand) {
        [self setValue:@(UIBarPositionTopAttached) forKey:@"barPosition"];
    } else {
        [self setValue:@(UIBarPositionAny) forKey:@"barPosition"];
        self.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    
    
    self.bottomLine.hidden = self.viewController.ttNeedHideBottomLine;
}

@end

@implementation UIViewController (NavigationBarStyle)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(tt_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
        SEL originalSelector2 = @selector(viewDidAppear:);
        SEL swizzledSelector2 = @selector(tt_viewDidAppear:);
        
        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
        
        BOOL success2 = class_addMethod(class, originalSelector2, method_getImplementation(swizzledMethod2), method_getTypeEncoding(swizzledMethod2));
        if (success2) {
            class_replaceMethod(class, swizzledSelector2, method_getImplementation(originalMethod2), method_getTypeEncoding(originalMethod2));
        } else {
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
        
    });
}

- (void)tt_viewWillAppear:(BOOL)animated
{
    [self tt_viewWillAppear:animated];
    
    if (self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    if (!self.ttHideNavigationBar) {
        if (self.ttNavigationBar) {
            [self.ttNavigationBar tt_configNavBarWithTheme:self.ttNavBarStyle];
        } else {
            [self.navigationController tt_configNavBarWithTheme:self.ttNavBarStyle];
        }
    }
    
    if (self.ttNeedChangeNavBar) {
        if (self.navigationController.navigationBarHidden != self.ttHideNavigationBar) {
            [self.navigationController setNavigationBarHidden:self.ttHideNavigationBar animated:YES];
        }
    }
}

- (void)tt_viewDidAppear:(BOOL)animated
{
    [self tt_viewDidAppear:animated];
    
    if (![self.parentViewController isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    if ([[TTThemeManager sharedInstance_tt] viewControllerBasedStatusBarStyle]) {
        
        if ([UIApplication sharedApplication].statusBarStyle != self.ttStatusBarStyle) {
            
            [UIApplication sharedApplication].statusBarStyle = self.ttStatusBarStyle;
            
        }
    }
    else {
        [UIApplication sharedApplication].statusBarStyle = [[TTThemeManager sharedInstance_tt] statusBarStyle];
        
    }
    
}


- (NSString*)ttNavBarStyle {
    
    return (NSString*)objc_getAssociatedObject(self, @selector(ttNavBarStyle));
}

- (void)setTtNavBarStyle:(NSString *)ttNavBarStyle {
    
    objc_setAssociatedObject(self, @selector(ttNavBarStyle),ttNavBarStyle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)ttStatusBarStyle {
    
    return (NSUInteger)[objc_getAssociatedObject(self, @selector(ttStatusBarStyle)) integerValue];
}

- (void)setTtStatusBarStyle:(NSUInteger)ttStatusBarStyle {
    
    objc_setAssociatedObject(self, @selector(ttStatusBarStyle),@(ttStatusBarStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)ttHideNavigationBar {
    
    return (BOOL)[objc_getAssociatedObject(self, @selector(ttHideNavigationBar)) boolValue];
}

- (void)setTtHideNavigationBar:(BOOL)ttHideNavigationBar{
    
    [self setTtNeedChangeNavBar:YES];
    objc_setAssociatedObject(self, @selector(ttHideNavigationBar),@(ttHideNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.ttNavigationBar) {
        self.ttNavigationBar.hidden = ttHideNavigationBar;
    }
}

- (BOOL)ttDisableDragBack {
    
    return (BOOL)[objc_getAssociatedObject(self, @selector(ttDisableDragBack)) boolValue];
}

- (void)setTtDisableDragBack:(BOOL)ttDisableDragBack {
    
    objc_setAssociatedObject(self, @selector(ttDisableDragBack),@(ttDisableDragBack), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ttDragToRoot {
    
    return (BOOL)[objc_getAssociatedObject(self, @selector(ttDragToRoot)) boolValue];
}

- (void)setTtDragToRoot:(BOOL)ttDragToRoot {
    
    objc_setAssociatedObject(self, @selector(ttDragToRoot),@(ttDragToRoot), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)ttNeedChangeNavBar {
    
    return (BOOL)[objc_getAssociatedObject(self, @selector(ttNeedChangeNavBar)) boolValue];
}

- (void)setTtNeedChangeNavBar:(BOOL)ttNeedChangeNavBar {
    
    objc_setAssociatedObject(self, @selector(ttNeedChangeNavBar),@(ttNeedChangeNavBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTNavigationBar *)ttNavigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTtNavigationBar:(TTNavigationBar *)ttNavigationBar {
    [ttNavigationBar pushNavigationItem:self.navigationItem animated:NO];
    ttNavigationBar.viewController = self;
    ttNavigationBar.item = self.navigationItem;
    objc_setAssociatedObject(self, @selector(ttNavigationBar),ttNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ttNeedHideBottomLine {
    if (objc_getAssociatedObject(self,_cmd)) {
        return (BOOL)[objc_getAssociatedObject(self,_cmd) boolValue];
    } else {
        return NO;
    }
}

- (void)setTtNeedHideBottomLine:(BOOL)ttNeedHideBottomLine {
    BOOL originValue = self.ttNeedHideBottomLine;
    objc_setAssociatedObject(self, @selector(ttNeedHideBottomLine),@(ttNeedHideBottomLine), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (originValue != ttNeedHideBottomLine) {
        [self.ttNavigationBar layoutSubviews];
    }
}

- (BOOL)ttNeedTopExpand {
    if (objc_getAssociatedObject(self,_cmd)) {
        return (BOOL)[objc_getAssociatedObject(self,_cmd) boolValue];
    } else {
        return YES;
    }
}

- (void)setTtNeedTopExpand:(BOOL)ttNeedTopExpand {
    objc_setAssociatedObject(self, @selector(ttNeedTopExpand),@(ttNeedTopExpand), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ttNaviTranslucent {
    if (objc_getAssociatedObject(self,_cmd)) {
        return (BOOL)[objc_getAssociatedObject(self,_cmd) boolValue];
    } else {
        return NO;
    }
}

- (void)setTtNaviTranslucent:(BOOL)ttNaviTranslucent {
    objc_setAssociatedObject(self, @selector(ttNaviTranslucent),@(ttNaviTranslucent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ttNeedIgnoreZoomAnimation {
    if (objc_getAssociatedObject(self,_cmd)) {
        return (BOOL)[objc_getAssociatedObject(self,_cmd) boolValue];
    } else {
        return NO;
    }
}

- (void)setTtNeedIgnoreZoomAnimation:(BOOL)ttNeedIgnoreZoomAnimation {
    objc_setAssociatedObject(self, @selector(ttNeedIgnoreZoomAnimation),@(ttNeedIgnoreZoomAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
