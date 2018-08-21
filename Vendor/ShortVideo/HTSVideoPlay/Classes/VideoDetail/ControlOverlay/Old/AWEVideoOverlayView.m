//
//  AWEVideoOverlayView.m
//  Pods
//
//  Created by Zuyang Kou on 22/06/2017.
//
//

#import "AWEVideoOverlayView.h"

@implementation AWEVideoOverlayView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *receivingView = [super hitTest:point withEvent:event];


    // The view itself does not handle any event, it merely acts as a view container
    if (receivingView == self) {
        receivingView = nil;
    }

    return receivingView;
}

@end
