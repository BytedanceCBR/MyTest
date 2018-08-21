//
//  SSAnimationRender.h
//  Article
//
//  Created by Yu Tianhang on 13-3-7.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SSMotionType) {
    SSMotionTypeZoomInAndDisappear, 
    SSMotionTypeZoonInAndReappear
};

@interface SSMotionRender : NSObject
+ (void)motionInView:(UIView *)targetView byType:(SSMotionType)type;
+ (void)motionInView:(UIView *)targetView byType:(SSMotionType)type image:(UIImage *)img;
+ (void)motionInView:(UIView *)targetView byType:(SSMotionType)type image:(UIImage *)img offsetPoint:(CGPoint)offset;
// unsupport now
+ (void)motionView:(UIView *)motionView inView:(UIView *)targetView byType:(SSMotionType)type;
+ (void)motionView:(UIView *)motionView inView:(UIView *)targetView byType:(SSMotionType)type duration:(CGFloat)duration;
+ (void)motionView:(UIView *)motionView fromRect:(CGRect)aRect byType:(SSMotionType)type;
@end
