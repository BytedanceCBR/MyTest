

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSUInteger, TTGestureDirection) {
    TTGestureDirection_Unknown,
    TTGestureDirection_Down,
    TTGestureDirection_Up,
    TTGestureDirection_Left,
    TTGestureDirection_Right,
};

@protocol TTSharedViewTransitionFrom <NSObject>

@optional
- (UIView *)animationFromView;
- (UIImage *)animationFromImage;
- (void)animationFromClose;
- (void)animationFromCancel;
@end

@protocol TTSharedViewTransitionTo <NSObject>
@required

@optional
- (UIView *)animationToView;
- (UIImage *)animationToImage;
- (CGRect)animationToFrame;
- (void)animationToFinished:(UIView *)fromAnimatedView;
- (void)animationToBegin:(UIView *)fromAnimatedView;
@end


@protocol SharedViewTransitionWillDismissViewControllerProtocol <NSObject>

- (void)willDismiss;

@end

static int kMaxDistance = 120;
static int kMaxSpeed = 200;

@interface TTSharedViewTransition : NSObject<UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) BOOL disableAnimation;
@property (nonatomic, assign) BOOL pop;
@property (nonatomic, assign) TTGestureDirection gestureDirection;
@property (nonatomic, assign) BOOL isVerticalGestureOnBegin;
@property (nonatomic, assign) BOOL isTheSameDirection;


+ (instancetype)sharedInstance;

- (void)handlePanGestureRecognizer:(UIGestureRecognizer *)recognizer;

+ (BOOL)canFinishInteractiveTransitionWithPanAmount:(CGPoint)amount velocity:(CGPoint)velocity firstVelocity:(CGPoint)firstVelocity isVerticalGestureOnBegin:(BOOL)isVerticalGestureOnBegin;
@end

