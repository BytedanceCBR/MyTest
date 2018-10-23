//
//  WDCollectionView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/7/2.
//
//

#import "WDCollectionView.h"
#import "WDDefines.h"

@implementation WDCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self panBack:gestureRecognizer]) {
        return NO;
    }
    return YES;
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            CGPoint location = [gestureRecognizer locationInView:self];
            if (point.x >= 0 && location.x < self.width && self.contentOffset.x <= 0) {
                CGFloat offsetY = self.contentOffset.y;
                [self setContentOffset:CGPointMake(0, offsetY)];
                return YES;
            }
        }
    }
    return NO;
}

@end
