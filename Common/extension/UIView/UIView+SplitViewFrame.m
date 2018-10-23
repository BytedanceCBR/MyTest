//
//  UIView+SplitViewFrame.m
//  Article
//
//  Created by panxiang on 15/11/5.
//
//

#import "UIView+SplitViewFrame.h"
#import "RSSwizzle.h"
#import <objc/runtime.h>
#import "SSThemed.h"
@implementation UIView (SplitViewFrame)

- (CGRect)splitViewFrame
{
    if ([SSCommon isPadDevice]) {
        CGFloat padding = [SSCommon paddingForViewWidth:0];
        CGSize windowSize = [SSCommon windowSize];

        CGRect frame = CGRectMake(0, self.frame.origin.y, windowSize.width, self.frame.size.height);
        frame = CGRectInset(frame, padding, 0);
        
        return frame;
    }
    return self.frame;
}

- (CGFloat)splitViewLeft
{
    return CGRectGetMinX([self splitViewFrame]);
}

- (CGFloat)splitViewWidth
{
    return  CGRectGetWidth([self splitViewFrame]);
}

- (CGFloat)splitViewHeight
{
    return  CGRectGetHeight([self splitViewFrame]);
}

@end
