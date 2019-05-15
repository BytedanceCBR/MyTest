//
//  UIViewController+TTVAdditions.m
//  Article
//
//  Created by pei yun on 2017/7/25.
//
//

#import "UIViewController+TTVAdditions.h"

void ttv_removeChildViewController(UIViewController *childViewController)
{
    [childViewController willMoveToParentViewController:nil];  // 1
    [childViewController.view removeFromSuperview];            // 2
    [childViewController removeFromParentViewController];      // 3
}

@implementation UIViewController (TTVAdditions)

@end
