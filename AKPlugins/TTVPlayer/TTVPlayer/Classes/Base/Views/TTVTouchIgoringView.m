//
//  TTVTouchIgoringView.m
//  test
//
//  Created by lisa on 2019/3/18.
//  Copyright © 2019 lina. All rights reserved.
//

#import "TTVTouchIgoringView.h"

@implementation TTVTouchIgoringView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView == self) {
        return nil;
    }
    return hitTestView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *view in self.subviews) {
        [view setNeedsLayout];
    }
}

@end
