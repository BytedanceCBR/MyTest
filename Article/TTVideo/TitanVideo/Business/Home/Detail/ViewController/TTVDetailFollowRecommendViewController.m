//
//  TTVDetailFollowRecommendViewController.m
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import "TTVDetailFollowRecommendViewController.h"
#import "TTAlphaThemedButton.h"
#import "TTVVideoDetailNatantPGCViewModel.h"
#import "TTUIResponderHelper.h"
#import "TTNavigationController.h"
#import "UIView+CustomTimingFunction.h"
@interface TTVDetailFollowRecommendViewController()<UIGestureRecognizerDelegate>
@property (nonatomic, strong)UIPanGestureRecognizer *pan;
@property (nonatomic, assign) CGFloat lastY;
@property (nonatomic, assign) CGFloat originY;
@property (nonatomic, assign) BOOL isDraggingView;

@end

@implementation TTVDetailFollowRecommendViewController

- (instancetype)initWithPGCViewModel:(TTVVideoDetailNatantPGCViewModel *)pgcViewModel ViewWidth:(CGFloat)width
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.recommendView = [[TTVDetailFollowRecommendView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
        self.recommendView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.recommendView.position = @"video_detail";
        self.recommendView.ifNeedToSendShowAction = YES;
        self.recommendView.userID = [pgcViewModel.pgcModel.contentInfo ttgc_contentID];
        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_recommend" forKey:@"follow_type"];
        [rtFollowDict setValue:[pgcViewModel.pgcModel.contentInfo ttgc_contentID] forKey:@"profile_user_id"];
        [rtFollowDict setValue:pgcViewModel.pgcModel.categoryName forKey:@"category_name"];
        [rtFollowDict setValue:@"detail_follow_card" forKey:@"source"];
        [rtFollowDict setValue:@(TTFollowNewSourceVideoDetailRecommend) forKey:@"server_source"];
        [rtFollowDict setValue:pgcViewModel.pgcModel.enterFrom forKey:@"enter_from"];
        [rtFollowDict setValue:pgcViewModel.pgcModel.logPb forKey:@"log_pb"];
        self.recommendView.rtFollowExtraDict = [rtFollowDict copy];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = self;
        self.view.userInteractionEnabled = YES;
        pan.minimumNumberOfTouches = 1;
        pan.maximumNumberOfTouches = 1;
        [self.view addGestureRecognizer:pan];
        self.pan = pan;
    }
    return self ?: nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = CGRectMake(0, 0, self.recommendView.width, self.recommendView.height);
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.recommendView];
    self.backButton.top = 0.f;
    self.backButton.width = self.view.width;
    self.backButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.clipsToBounds = YES;
}

- (TTAlphaThemedButton *)backButton
{
    if (!_backButton) {
        _backButton = [[TTAlphaThemedButton alloc] init];
        _backButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
        _backButton.enableHighlightAnim = NO;
        _backButton.alpha = 0;
        WeakSelf;
        [_backButton addTarget:self withActionBlock:^{
            StrongSelf;
            if (self.backActionFired) {
                self.backActionFired();
            }
    } forControlEvent:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)pan:(UIPanGestureRecognizer *)ges {
    CGPoint locationPoint = [ges locationInView:self.view];
    CGPoint velocityPoint = [ges velocityInView:self.view];
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.originY = self.recommendView.frame.size.height;
            self.lastY = locationPoint.y;
            if (velocityPoint.y < 0 && !self.isDraggingView) {
                self.isDraggingView = YES;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (velocityPoint.y < 0 && !self.isDraggingView) {
                self.isDraggingView = YES;
            }
            if (self.isDraggingView) {
                CGFloat step = locationPoint.y - self.lastY;
                CGRect frame = self.recommendView.frame;
                frame.origin.y += step;
                if (frame.origin.y > 0) {
                    frame.origin.y = self.view.bounds.origin.y;
                }
                float stepPercent = (0 - frame.origin.y) / self.originY;
                self.backButton.alpha = 1 - stepPercent;
                self.recommendView.frame = frame;
            }
            self.lastY = locationPoint.y;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            if (self.isDraggingView) {
                CGRect frame = self.recommendView.frame;
                float stepPercent = (0 - frame.origin.y) / self.originY;
                frame.origin.y = (velocityPoint.y < 0 || stepPercent > 0.1)  ? -self.originY : 0;
                if (frame.origin.y < 0){
                    if (self.backActionFired) {
                        self.backActionFired();
                    }
                }else{
                    [UIView animateWithDuration: 0.25f customTimingFunction: CustomTimingFunctionSineOut animation:^{
                        self.recommendView.frame = frame;
                        self.backButton.alpha = frame.origin.y < 0 ? 0 : 1;
                    } completion:^(BOOL finished) {
                    }];
                }
            }
            self.isDraggingView = NO;
        }
            break;
        default:
            break;
    }

}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    if (self.pan == gestureRecognizer){
        TTNavigationController *navi = (TTNavigationController *)[TTUIResponderHelper topNavigationControllerFor:self];
        if (navi.panRecognizer == otherGestureRecognizer || navi.swipeRecognizer == otherGestureRecognizer) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer == self.pan) {
        CGPoint velocity = [self.pan velocityInView:self.view];
        if (fabs(velocity.x) > fabs(velocity.y)){
            return NO;
        }
        if (self.view.alpha == 0) {
            return NO;
        }
        if (CGRectGetWidth(self.view.frame) == 0 || CGRectGetHeight(self.view.frame) == 0) {
            return NO;
        }

        CGPoint translation = [((UIPanGestureRecognizer *)gestureRecognizer) translationInView:gestureRecognizer.view];
        if (fabs(translation.x) > fabs(translation.y)) {
            return NO;
        }
        return YES;
    }
    return YES;
}

@end
