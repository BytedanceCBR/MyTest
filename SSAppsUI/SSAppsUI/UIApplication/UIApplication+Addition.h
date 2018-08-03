//
//  UIApplication.h
//  Article
//
//  Created by Dianwei on 13-2-1.
//
//

#import <UIKit/UIKit.h>

@interface UIApplication(Addition)
+ (UIInterfaceOrientation)currentUIOrientation;
+ (BOOL)isPortraitOrientation;
+ (CGFloat)realStatusBarHeight;
@end
