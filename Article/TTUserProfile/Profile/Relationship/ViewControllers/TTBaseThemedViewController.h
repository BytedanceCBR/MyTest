//
//  TTBaseThemedViewController.h
//  Article
//
//  Created by liuzuopeng on 8/22/16.
//
//

#import "SSViewControllerBase.h"



@interface TTBaseThemedViewController : SSViewControllerBase
@property (nonatomic, strong, readonly) UINavigationController *topNavigationController;

- (CGFloat)navigationBarHeight;
+ (CGFloat)statusBarHeight;
@end
