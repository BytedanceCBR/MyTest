//
//  SSAnimationRender.m
//  Article
//
//  Created by Yu Tianhang on 13-3-7.
//
//

#import "SSMotionRender.h"
#import "UIImage+TTThemeExtension.h"
#import "TTUIResponderHelper.h"

@implementation SSMotionRender

+ (void)motionInView:(UIView *)targetView byType:(SSMotionType)type
{
    [self motionInView:targetView byType:type image:[UIImage themedImageNamed:@"add_all_dynamic.png"]];
}

+ (void)motionInView:(UIView *)targetView byType:(SSMotionType)type image:(UIImage *)img
{
    [self motionInView:targetView byType:type image:img offsetPoint:CGPointMake(-10.f, 0.f)];
}

+ (void)motionInView:(UIView *)targetView byType:(SSMotionType)type image:(UIImage *)img offsetPoint:(CGPoint)offset
{
    switch(type) {
        case SSMotionTypeZoomInAndDisappear:
        case SSMotionTypeZoonInAndReappear:
            {
                UIView *motionView = [[UIImageView alloc] initWithImage:img];
                motionView.center = CGPointMake(targetView.frame.size.width/2 + offset.x, targetView.frame.size.height/8 + offset.y);
                UIView *topmostView = [UIApplication sharedApplication].keyWindow;
                if (!topmostView) {
                    UIViewController * topmostController = [TTUIResponderHelper topmostViewController];
                    topmostView = topmostController.view;
                }
                motionView.center = [topmostView convertPoint:motionView.center fromView:targetView];
                [topmostView addSubview:motionView];

                float storedAlpha = motionView.alpha;
                motionView.alpha = 0.f;
                motionView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
                [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
                    motionView.alpha = 1.f;
                    motionView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                        if(type == SSMotionTypeZoomInAndDisappear) {
                            motionView.alpha = 0.f;
                        }
                        else if (type == SSMotionTypeZoonInAndReappear) {
                            motionView.alpha = storedAlpha;
                        }
                        motionView.transform = CGAffineTransformMakeScale(1.3, 1.3);
                    } completion:^(BOOL finished) {
                        [motionView removeFromSuperview];
                    }];
                }];
            }
            break;
        default:
            break;
    }
}

+ (void)motionView:(UIView *)motionView inView:(UIView *)targetView byType:(SSMotionType)type
{
}

+ (void)motionView:(UIView *)motionView inView:(UIView *)targetView byType:(SSMotionType)type duration:(CGFloat)duration
{
}

+ (void)motionView:(UIView *)motionView fromRect:(CGRect)aRect byType:(SSMotionType)type
{
}
@end
