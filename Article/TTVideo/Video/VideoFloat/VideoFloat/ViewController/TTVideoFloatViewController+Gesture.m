//
//  TTVideoFloatViewController+Gesture.m
//  Article
//
//  Created by panxiang on 16/8/16.
//
//

#import "TTVideoFloatViewController+Gesture.h"

@implementation TTVideoFloatViewController (Gesture)

- (void)addGesture
{
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandler:)];
    [self.panGestureRecognizer addTarget:[TTSharedViewTransition sharedInstance] action:@selector(handlePanGestureRecognizer:)];
    self.panGestureRecognizer.delegate = self;
    self.panGestureRecognizer.enabled = YES;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self.view gestureRecognizers]];
    [array addObjectsFromArray:[self.tableView gestureRecognizers]];
    for (UIGestureRecognizer *gesture in array) {
        [gesture requireGestureRecognizerToFail:self.panGestureRecognizer];
    }
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
}

- (void)panGestureRecognizerHandler:(UIPanGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint currentTouchPoint = [self.panGestureRecognizer locationInView:self.view];
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self.view];
        if (self.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            self.firstVelocity = CGPointZero;
            self.initialTouchPosition = currentTouchPoint;
            self.preTouchPosition = currentTouchPoint;
            [self panGestureDidBegin];
        } else if (self.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            if (CGPointEqualToPoint(self.firstVelocity, CGPointZero)) {
                self.firstVelocity = velocity;
            }
            CGPoint panAmount = CGPointMake(currentTouchPoint.x - self.preTouchPosition.x, currentTouchPoint.y - self.preTouchPosition.y);
            CGPoint totalPanAmount = CGPointMake(currentTouchPoint.x - self.initialTouchPosition.x, currentTouchPoint.y - self.initialTouchPosition.y);
            [self panGestureChangingWithOffset:panAmount totalOffset:totalPanAmount];
            self.preTouchPosition = currentTouchPoint;
            
        } else if (self.panGestureRecognizer.state == UIGestureRecognizerStateEnded || self.panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
            CGPoint totalPanAmount = CGPointMake(currentTouchPoint.x - self.initialTouchPosition.x, currentTouchPoint.y - self.initialTouchPosition.y);
            BOOL pop = [TTSharedViewTransition canFinishInteractiveTransitionWithPanAmount:totalPanAmount velocity:velocity firstVelocity:self.firstVelocity isVerticalGestureOnBegin:[TTSharedViewTransition sharedInstance].isVerticalGestureOnBegin];
            [TTSharedViewTransition sharedInstance].pop = pop;
            [self panGestureDidEndWithOffset:totalPanAmount pop:pop];
            self.firstVelocity = CGPointZero;
        }
    }
}

- (void)panGestureDidBegin
{
    self.selfViewOriginFrame = self.containerView.frame;
    [[UIApplication sharedApplication].keyWindow addSubview:self.containerView];
}

- (void)panGestureChangingWithOffset:(CGPoint)offset totalOffset:(CGPoint)totalPanAmount
{
    switch ([TTSharedViewTransition sharedInstance].gestureDirection) {
        case TTGestureDirection_Down:
            self.containerView.frame = CGRectMake(0, MAX(totalPanAmount.y, 0), self.view.width, self.view.height);
            break;
        case TTGestureDirection_Up:
            self.containerView.frame = CGRectMake(0, MIN(totalPanAmount.y, 0), self.view.width, self.view.height);
            break;
        case TTGestureDirection_Right:
            self.containerView.frame = CGRectMake(MAX(totalPanAmount.x, 0), 0, self.view.width, self.view.height);
            break;
        default:
            break;
    }
}

- (void)panGestureDidEndWithOffset:(CGPoint)totalPanAmount pop:(BOOL)pop
{
    if (!pop) {
        [UIView animateWithDuration:0.25 animations:^{
            self.containerView.frame = self.selfViewOriginFrame;
        } completion:^(BOOL finished) {
            [self.view addSubview:self.containerView];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            switch ([TTSharedViewTransition sharedInstance].gestureDirection) {
                case TTGestureDirection_Up:
                    self.containerView.frame = CGRectOffset(self.selfViewOriginFrame, 0, -self.view.height);
                    break;
                case TTGestureDirection_Down:
                    self.containerView.frame = CGRectOffset(self.selfViewOriginFrame, 0, self.view.height);
                    break;
                case TTGestureDirection_Right:
                    self.containerView.frame = CGRectOffset(self.selfViewOriginFrame, self.view.width, 0);
                    break;
                    
                default:
                    break;
            }
        } completion:^(BOOL finished) {
            [self.view addSubview:self.containerView];
        }];
    }
    [TTSharedViewTransition sharedInstance].gestureDirection = TTGestureDirection_Unknown;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if (self.panGestureRecognizer == gestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self.view];
        [TTSharedViewTransition sharedInstance].isVerticalGestureOnBegin = fabs(velocity.y) > fabs(velocity.x);
        BOOL isVerticalGesture = [TTSharedViewTransition sharedInstance].isVerticalGestureOnBegin;
        TTGestureDirection direction = TTGestureDirection_Unknown;
        if (isVerticalGesture) {
            if (velocity.y > 0) {
                direction = TTGestureDirection_Down;
            } else {
                direction = TTGestureDirection_Up;
            }
        }
        
        else {
            if (velocity.x > 0) {
                direction = TTGestureDirection_Right;
            } else {
                direction = TTGestureDirection_Left;
            }
        }
        [TTSharedViewTransition sharedInstance].gestureDirection = direction;
        switch (direction) {
            case TTGestureDirection_Left:
                return NO;
                break;
            case TTGestureDirection_Right:
                return YES;
                break;
            case TTGestureDirection_Down:
                return self.tableView.contentOffset.y <= -64;
                break;
            case TTGestureDirection_Up:
                return (self.tableView.contentOffset.y + self.tableView.height) >= self.tableView.contentSize.height;
                break;
            default:
                break;
        }
    }
    return NO;
}
@end
