//
//  TTCustomAnimationNavigationController.h
//  Article
//
//  Created by 王双华 on 17/3/6.
//
//

#import <TTUIWidget/TTNavigationController.h>
#import "TTCustomAnimationDelegate.h"

@interface TTCustomAnimationNavigationController : TTNavigationController

@property (nonatomic, strong) TTCustomAnimationDelegate *animationDelegate;

@property (nonatomic, assign) BOOL useWhiteStyle;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController animationStyle:(TTCustomAnimationStyle)style;

- (void)setAnimationStyle:(TTCustomAnimationStyle)style;

@end
