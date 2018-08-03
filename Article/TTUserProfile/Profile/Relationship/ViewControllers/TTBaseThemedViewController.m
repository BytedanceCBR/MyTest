//
//  TTBaseViewController.m
//  Article
//
//  Created by liuzuopeng on 8/22/16.
//
//

#import "TTBaseThemedViewController.h"
#import "SSThemed.h"



@interface TTBaseThemedViewController ()
//@property (nonatomic, strong) SSThemedView *themedBackgroundView;
@end;

@implementation TTBaseThemedViewController
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
    }
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if ((self = [super initWithRouteParamObj:paramObj])) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.f) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
    
//    _themedBackgroundView = [SSThemedView new];
//    _themedBackgroundView.backgroundColorThemeKey = kColorBackground3;
//    [self.view addSubview:_themedBackgroundView];
//    [self.view sendSubviewToBack:_themedBackgroundView];
}

//- (void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//    [self.view sendSubviewToBack:_themedBackgroundView];
//    _themedBackgroundView.frame = CGRectInset(self.view.frame, 0, -64);
//}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
}

#pragma mark - properties

- (UINavigationController *)topNavigationController {
    return [TTUIResponderHelper topNavigationControllerFor:self];
}

- (CGFloat)navigationBarHeight {
    return TTNavigationBarHeight + [TTBaseThemedViewController statusBarHeight];
}

+ (CGFloat)statusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}
@end
