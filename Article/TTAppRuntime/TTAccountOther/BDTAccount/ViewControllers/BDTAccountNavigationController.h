//
//  BDTAccountNavigationController.h
//  Article
//
//  Created by zuopengliu on 14/9/2017.
//
//

#import <TTNavigationController.h>
#import <TTAccountLoginAnimation.h>



@interface BDTAccountNavigationController : TTNavigationController

@property (nonatomic, strong) TTAccountLoginAnimationDelegate *animationDelegate;

/**
 *  导航栏距离屏幕上边缘的间距
 */
+ (CGFloat)topEdgeInsetScreenMargin;

@end
