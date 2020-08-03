//
//  FHBuildingDetailScrollView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/7/31.
//

#import "FHBuildingDetailScrollView.h"

@interface FHBuildingDetailScrollView() <UIGestureRecognizerDelegate>

@end

@implementation FHBuildingDetailScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self panBack:gestureRecognizer]) {
        return YES;
    }
    return NO;
}

- (BOOL)panBack:(UIGestureRecognizer *)gestureRecognizer {
    CGFloat location_X = 0.15 * [UIScreen mainScreen].bounds.size.width;                                     //屏幕设置的阈值
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:self];                                                        //获取到的是手指移动后，在相对坐标中的偏移量（也就是这个移动最终是向前还是向后）
       // NSLog(@"luowentao 获取到的是手指移动后，在相对坐标中的偏移量 point = %@",NSStringFromCGPoint(point));
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            CGPoint location = [gestureRecognizer locationInView:self];                                     //获取到的是手指点击屏幕实时的坐标点
          //  NSLog(@"luowentao 获取到的是手指点击屏幕实时的坐标点 location = %@",NSStringFromCGPoint(location));
            if (point.x >0 && location.x < location_X) {
                return YES;
            }
        }
        
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self panBack:gestureRecognizer]) {
        return NO;
    }
    return YES;
}
@end
