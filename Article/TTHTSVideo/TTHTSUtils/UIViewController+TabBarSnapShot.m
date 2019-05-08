//
//  UIViewController+TabBarSnapShot.m
//  Article
//
//  Created by 王双华 on 2017/6/27.
//
//

#import "UIViewController+TabBarSnapShot.h"
#import "TTArticleTabBarController.h"

@implementation UIViewController(TabBarSnapShot)

+ (UIView *)tabBarSnapShotView
{
    UIWindow *rootWin = [[[UIApplication sharedApplication] delegate]window];
    if ([rootWin.rootViewController isKindOfClass:[TTArticleTabBarController class]]) {
        TTArticleTabBarController * rootTabController = (TTArticleTabBarController*)rootWin.rootViewController;
        UITabBar *tabBar = rootTabController.tabBar;
        UIView *tabBarSnapShot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tabBar.frame), CGRectGetHeight(tabBar.superview.frame))];
        
        //iOS10 TabBar高斯模糊效果的子视图换成了UIVisualEffectview 直接截图是截不到的
        //https://developer.apple.com/reference/uikit/uivisualeffectview
//        if ([TTDeviceHelper OSVersionNumber] >= 10.f) {
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:[[TTThemeManager sharedInstance_tt].currentThemeName isEqualToString:@"night"] ? UIBlurEffectStyleDark : UIBlurEffectStyleExtraLight];
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            effectView.frame = tabBar.frame;
            [tabBarSnapShot addSubview:effectView];
//        }
        
        //tabBar截图
        tabBar.layer.hidden = NO;
        UIGraphicsBeginImageContextWithOptions(tabBarSnapShot.bounds.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, CGRectGetHeight(tabBarSnapShot.frame)-CGRectGetHeight(tabBar.frame));
        [tabBar.layer renderInContext:context];
        
        UIImage *image = [UIGraphicsGetImageFromCurrentImageContext() imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIGraphicsEndImageContext();
        UIImageView *snapShot = [[UIImageView alloc] initWithImage:image];
        snapShot.frame = tabBarSnapShot.bounds;
        [tabBarSnapShot addSubview:snapShot];
        tabBar.layer.hidden = YES;
        
        return tabBarSnapShot;
    }
    return nil;
}
@end
