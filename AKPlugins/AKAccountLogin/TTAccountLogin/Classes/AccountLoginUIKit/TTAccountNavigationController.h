//
//  TTAccountNavigationController.h
//  TTAccountLogin
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTNavigationController.h"
#import "TTAccountLoginAnimation.h"



@interface TTAccountNavigationController : TTNavigationController

@property (nonatomic, strong) TTAccountLoginAnimationDelegate *animationDelegate;

- (void)dismissWithAnimation;

@end
