//
//  FHExtendHotAreaButton.m
//  FHCommonUI
//
//  Created by 张元科 on 2019/1/8.
//

#import "FHExtendHotAreaButton.h"

// FHExtendHotAreaButton

@implementation FHExtendHotAreaButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isExtend = YES;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    CGFloat widthDelta = bounds.size.width;
    CGFloat heightDelta = bounds.size.height;
    CGFloat dx = 0;
    CGFloat dy = 0;
    if (_isExtend) {
        dx = widthDelta / 2;
        dy = heightDelta / 2;
        // 小屏幕手机
        if ([UIScreen mainScreen].bounds.size.width < 330) {
            dx = widthDelta / 4;
            dy = heightDelta / 4;
        }
    } else {
        dx = 0;
        dy = 0;
    }
    bounds = CGRectMake(bounds.origin.x - dx, bounds.origin.y - dy, widthDelta + 2 * dx, heightDelta + 2 * dy);
    return CGRectContainsPoint(bounds, point);
}

@end

