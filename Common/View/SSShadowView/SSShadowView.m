//
//  SSShadowView.m
//  Gallery
//
//  Created by Zhang Leonardo on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SSShadowView.h"
#import <QuartzCore/QuartzCore.h>


@implementation SSShadowView

- (void)setVerticalGradualShadowTopColor:(UIColor *)topColor endColor:(UIColor *)endColor
{    
    CGColorRef topC = topColor.CGColor;
    CGColorRef endC = endColor.CGColor;
    CAGradientLayer * newShadow = [[CAGradientLayer alloc] init];
    newShadow.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    newShadow.colors = [NSArray arrayWithObjects:(id)topC, (id)endC, nil];
    [self.layer addSublayer:newShadow];
    [newShadow release];
}

@end
