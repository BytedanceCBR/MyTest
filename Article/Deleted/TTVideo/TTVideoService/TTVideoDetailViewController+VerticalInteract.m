//
//  TTVideoDetailViewController+VerticalInteract.m
//  Article
//
//  Created by xiangwu on 2016/12/2.
//
//

#import "TTVideoDetailViewController+VerticalInteract.h"
#import "ArticleVideoPosterView.h"
#import "TTCommentViewController.h"
#import "TTVideoAlbumView.h"
#import "ArticleInfoManager.h"
#import "Article+TTADComputedProperties.h"
#import <objc/runtime.h>
#import "TTVideoDetailFloatCommentViewController.h"
#import "TTVideoMovieBanner.h"
#import "TTDetailNatantVideoPGCView.h"
#import "TTDetailNatantVideoBanner.h"
#import "TTVideoDetailPlayControl.h"
#import "ExploreOrderedData+TTAd.h"

static const NSTimeInterval kAnimDuration = 0.2;
static const CGFloat kCommentVCTolerance = 10;

@implementation TTVideoDetailInteractModel

@end

@implementation TTVideoDetailViewController (VerticalInteract)

@dynamic movieContainerViewPanGes, commentTableViewPanGes;

#pragma mark - public method

- (void)vdvi_commentTableViewDidScroll:(UIScrollView *)scrollView {
    if ([self vdvi_shouldFiltered] || self.videoAlbum.superview || self.floatCommentVC.view.superview) {
        return;
    }
    if (self.interactModel.isDraggingCommentTableView) {
        if (self.moviewViewContainer.height != self.interactModel.minMovieH) {
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        } else {
            self.interactModel.isDraggingCommentTableView = NO;
            self.interactModel.shouldSendCommentTrackLater = YES;
        }
    }
}

- (void)vdvi_commentTableViewDidEndDragging:(UIScrollView *)scrollView {
    if (!self.interactModel.shouldSendCommentTrackLater) {
        return;
    }
    self.interactModel.shouldSendCommentTrackLater = NO;
    if (self.commentVC.commentTableView.contentOffset.y > 0) {
        self.interactModel.curMovieH = self.interactModel.minMovieH;
        NSString *label = @"reduction";
        NSString *source = @"player_outside";
        [self vdvi_trackWithLabel:label source:source groupId:self.article.groupModel.groupID];
    }
}

- (void)vdvi_changeMovieSizeWithStatus:(VideoDetailViewShowStatus)staus {
    if ([self vdvi_shouldFiltered]) {
        return;
    }
    NSString *label = @"";
    CGRect frame = self.moviewViewContainer.frame;
    if (staus == VideoDetailViewShowStatusComment) { //收起视频
        label = @"reduction";
        frame.size.height = self.interactModel.minMovieH;
    } else {
        label = @"enlargement";
        frame.size.height = self.interactModel.maxMovieH;
    }
    [self vdvi_trackWithLabel:label source:@"comment_button" groupId:self.article.groupModel.groupID];
    [self p_executeAnimationWithFrame:frame];
}

- (BOOL)vdvi_shouldFiltered {
    //广告视频和iPad不会添加交互手势
    if ([TTDeviceHelper isPadDevice] || [self.orderedData.adModel isCreativeAd] || !SSIsEmptyDictionary(self.infoManager.videoBanner) || [TTDeviceHelper OSVersionNumber] < 8.0) {
        return YES;
    }
    return NO;
}

- (void)vdvi_trackWithLabel:(NSString *)label source:(NSString *)source groupId:(NSString *)groupId {
    NSMutableDictionary *extraDict = [[NSMutableDictionary alloc] init];
    [extraDict setValue:source forKey:@"action_type"];
    wrapperTrackEventWithCustomKeys(@"video_player", label, groupId, nil, extraDict);
}

#pragma mark - private method

- (void)p_handlePanGesture:(UIPanGestureRecognizer *)ges inView:(UIView *)view {
    if ((self.commentVC.commentTableView.contentOffset.y > kCommentVCTolerance && ges != self.movieContainerViewPanGes) || self.videoAlbum.superview || self.floatCommentVC.view.superview) {
        self.playControl.isChangingMovieSize = NO;
        return;
    }
    CGPoint velocityPoint = [ges velocityInView:view];
    CGPoint locationPoint = [ges locationInView:view];
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (ges == self.movieContainerViewPanGes) {
                self.interactModel.isDraggingMovieContainerView = YES;
                self.interactModel.lastY = locationPoint.y;
            } else {
                self.interactModel.cLastY = locationPoint.y;
            }
            [self p_markIsDraggingWithGesture:ges velocityPoint:velocityPoint];
            self.playControl.isChangingMovieSize = YES;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self p_markIsDraggingWithGesture:ges velocityPoint:velocityPoint];
            CGFloat step = 0;
            if (ges == self.movieContainerViewPanGes) {
                step = locationPoint.y - self.interactModel.lastY;
                self.interactModel.lastY = locationPoint.y;
            } else {
                step = locationPoint.y - self.interactModel.cLastY;
                self.interactModel.cLastY = locationPoint.y;
            }
            CGRect frame = self.moviewViewContainer.frame;
            frame.size.height += step;
            if (frame.size.height > self.interactModel.maxMovieH) {
                frame.size.height = self.interactModel.maxMovieH;
            }
            if (frame.size.height < self.interactModel.minMovieH) {
                frame.size.height = self.interactModel.minMovieH;
            }
            if (self.moviewViewContainer.height != frame.size.height) {
                [self.playControl setToolBarHidden:YES];
            }
            self.moviewViewContainer.frame = frame;
            self.movieShotView.frame = self.moviewViewContainer.bounds;
            if (self.movieView.superview == self.movieShotView) {
                self.movieView.frame = self.movieShotView.bounds;
            }
            if (self.topPGCView) {
                self.topPGCView.top = self.moviewViewContainer.bottom;
                self.commentVC.view.top = self.topPGCView.bottom;
            } else {
                self.commentVC.view.top = self.moviewViewContainer.bottom;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGRect frame = self.moviewViewContainer.frame;
            frame.size.height = velocityPoint.y > 0 ? self.interactModel.maxMovieH : self.interactModel.minMovieH;
            BOOL shouldSendTrack = frame.size.height != self.interactModel.curMovieH;
            [self p_executeAnimationWithFrame:frame];
            if (ges == self.movieContainerViewPanGes) {
                self.interactModel.isDraggingMovieContainerView = NO;
            }
            if (ges == self.commentTableViewPanGes) {
                self.interactModel.isDraggingCommentTableView = NO;
            }
            if (shouldSendTrack) {
                NSString *label = velocityPoint.y > 0 ? @"enlargement" : @"reduction";
                NSString *source = ges == self.commentTableViewPanGes ? @"player_outside" : @"player_inside";
                [self vdvi_trackWithLabel:label source:source groupId:self.article.groupModel.groupID];
            }
            self.playControl.isChangingMovieSize = NO;
        }
            break;
        default:
            break;
    }
}

- (void)p_markIsDraggingWithGesture:(UIPanGestureRecognizer *)ges velocityPoint:(CGPoint)velocityPoint {
//    NSLog(@"commentTableView.contentOffset.y = %lf", self.commentVC.commentTableView.contentOffset.y);
    if (ges == self.commentTableViewPanGes && !self.interactModel.isDraggingCommentTableView) {
        //如果手势是向上滑动并且评论列表已经到顶部并且视频高度不是最小，则可以缩小视频
        if (velocityPoint.y < 0 && self.commentVC.commentTableView.contentOffset.y <= kCommentVCTolerance && self.moviewViewContainer.height != self.interactModel.minMovieH) {
            self.interactModel.isDraggingCommentTableView = YES;
        }
    }
}

- (void)p_changeMovieViewContainerFrame:(CGRect)frame {
    self.moviewViewContainer.frame = frame;
    self.movieShotView.frame = self.moviewViewContainer.bounds;
    if (self.movieView.superview == self.movieShotView) {
        self.movieView.frame = self.movieShotView.bounds; 
    }
    self.topPGCView.top = self.moviewViewContainer.bottom;
    if (self.topPGCView) {
        self.commentVC.view.top = self.topPGCView.bottom;
    } else {
        self.commentVC.view.top = self.moviewViewContainer.bottom;
    }
    [self.playControl updateFrame];
    if (self.movieBanner) {
        self.movieBanner.bottom = self.moviewViewContainer.bottom;
    }
}

- (void)p_executeAnimationWithFrame:(CGRect)frame {
    self.playControl.forbidLayout = YES;
    [UIView animateWithDuration:kAnimDuration animations:^{
        [self p_changeMovieViewContainerFrame:frame];
    } completion:^(BOOL finished) {
        self.interactModel.curMovieH = frame.size.height;
        self.playControl.forbidLayout = NO;
    }];
}

#pragma mark - action

- (void)p_handleMovieContainerViewPanned:(UIPanGestureRecognizer *)ges {
    [self p_handlePanGesture:ges inView:self.moviewViewContainer];
}

- (void)p_handleCommentTableViewPanned:(UIPanGestureRecognizer *)ges {
    [self p_handlePanGesture:ges inView:self.commentVC.view.superview];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.interactModel.isDraggingMovieContainerView && gestureRecognizer == self.commentTableViewPanGes) {
        return NO;
    }
    CGPoint velocityPoint = CGPointZero;
    if (gestureRecognizer == self.movieContainerViewPanGes) {
        velocityPoint = [self.movieContainerViewPanGes velocityInView:self.moviewViewContainer];
    } else if (gestureRecognizer == self.commentTableViewPanGes) {
        velocityPoint = [self.commentTableViewPanGes velocityInView:self.commentVC.view.superview];
    }
    BOOL isHorizontal = fabs(velocityPoint.x) > fabs(velocityPoint.y);
    if (isHorizontal) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.commentTableViewPanGes) {
        if (otherGestureRecognizer.view == self.commentVC.commentTableView) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

#pragma mark - getter & setter

- (UIPanGestureRecognizer *)movieContainerViewPanGes {
    UIPanGestureRecognizer *ges = objc_getAssociatedObject(self, @selector(movieContainerViewPanGes));
    if (!ges) {
        ges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleMovieContainerViewPanned:)];
        ges.delegate = self;
        objc_setAssociatedObject(self, @selector(movieContainerViewPanGes), ges, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ges;
}

- (UIPanGestureRecognizer *)commentTableViewPanGes {
    UIPanGestureRecognizer *ges = objc_getAssociatedObject(self, @selector(commentTableViewPanGes));
    if (!ges) {
        ges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_handleCommentTableViewPanned:)];
        ges.delegate = self;
        objc_setAssociatedObject(self, @selector(commentTableViewPanGes), ges, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ges;
}

@end
