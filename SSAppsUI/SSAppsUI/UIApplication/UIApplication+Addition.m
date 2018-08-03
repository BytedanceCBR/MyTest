//
//  UIApplication.m
//  Article
//
//  Created by Dianwei on 13-2-1.
//
//

#import "UIApplication+Addition.h"

@implementation UIApplication(Addition)

+ (UIInterfaceOrientation)currentUIOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

+ (BOOL)isPortraitOrientation
{
    if (UIInterfaceOrientationIsPortrait([self currentUIOrientation])) {
        return YES;
    }
    return NO;
}

+ (CGFloat)realStatusBarHeight
{
    CGRect statusBarSize = [[UIApplication sharedApplication] statusBarFrame];
    float  height = MIN(statusBarSize.size.width, statusBarSize.size.height);
    return height;
}
@end
