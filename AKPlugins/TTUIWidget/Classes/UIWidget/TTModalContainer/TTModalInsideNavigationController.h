//
//  TTModalInsideNavigationController.h
//  Article
//
//  Created by muhuai on 2017/4/7.
//
//

#import <Foundation/Foundation.h>
#import <TTUIWidget/TTNavigationController.h>
//#import "TTArticleMomentAnimationDelegate.h"

@class TTModalInsideNavigationController;

@protocol TTModalInsideNavigationDelegate <NSObject>

@required
- (void)modalInsideNavigationController:(TTModalInsideNavigationController *)modalNavigationController closeButtonOnClick:(id)sender;

- (void)modalInsideNavigationController:(TTModalInsideNavigationController *)modalNavigationController panAtPercent:(CGFloat)percent;

@end

@interface TTModalInsideNavigationController : TTNavigationController

@property (nonatomic, weak) id<TTModalInsideNavigationDelegate> modalNavigationDelegate;

@end
