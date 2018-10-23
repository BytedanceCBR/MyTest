//
//  TSVEventPassthroughView.m
//  AFgzipRequestSerializer
//
//  Created by Zuyang Kou on 25/12/2017.
//

#import "TSVEventPassthroughView.h"

@implementation TSVEventPassthroughView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *subview in self.subviews) {
        CGPoint subviewPoint = [self convertPoint:point toView:subview];
        UIView *hittestView = [subview hitTest:subviewPoint withEvent:event];
        if (hittestView) {
            return hittestView;
        }
    }

    return nil;
}

@end
