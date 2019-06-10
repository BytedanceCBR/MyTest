//
//  TTVPlayerLayoutBottomView.m
//  Article
//
//  Created by yangshaobo on 2018/11/2.
//

#import "TTVPlayerLayoutBottomView.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVContainerSortView.h"
#import "UIView+TTVViewKey.h"
#import "UIViewAdditions.h"


//NoFullScreenRightContainerView
#define kNoFullScreenRightContainerViewRightPadding 12.f
#define kNoFullScreenRightContainerViewSpacing 12.f
#define kNoFullScreenRightContainerViewBottomCenterY 20.f

//FullScreenRightContainerView
#define kFullScreenRightContainerViewRightPadding 20.f
#define kFullScreenRightContainerViewHeight 24.f
#define kFullScreenRightContainerViewSpacing 28.f

//FullScreenLeftContainerView
#define kFullScreenLeftContainerViewLeftPadding 12.f
#define kFullScreenLeftContainerViewHeight 40.f
#define kFullScreenLeftContainerViewBottom 8.f
#define kFullScreenLeftContainerViewSpacing 6.f


@interface TTVPlayerLayoutBottomView ()

@property (nonatomic, strong) TTVContainerSortView *noFullScreenRightContainerView;

@property (nonatomic, strong) TTVContainerSortView *fullScreenRightContainerView;

@property (nonatomic, strong) TTVContainerSortView *fullScreenLeftContainerView;

@end

@implementation TTVPlayerLayoutBottomView

- (instancetype)init {
    if (self = [super init]) {
        [self _initContainerViews];
        [self _initObserver];
    }
    return self;
}


- (void)_initContainerViews {
    self.noFullScreenRightContainerView = [[TTVContainerSortView alloc] initWithLayoutDirection:TTVContainerSortViewLayoutDirectionHorizontal spacing:kNoFullScreenRightContainerViewSpacing];
    self.fullScreenRightContainerView = [[TTVContainerSortView alloc] initWithLayoutDirection:TTVContainerSortViewLayoutDirectionHorizontal spacing:kFullScreenRightContainerViewSpacing];
    self.fullScreenLeftContainerView = [[TTVContainerSortView alloc] initWithLayoutDirection:TTVContainerSortViewLayoutDirectionHorizontal spacing:kFullScreenLeftContainerViewSpacing];
    [self addSubview:self.noFullScreenRightContainerView];
    [self addSubview:self.fullScreenRightContainerView];
    [self addSubview:self.fullScreenLeftContainerView];
    self.fullScreenRightContainerView.backgroundColor = [UIColor yellowColor];
    self.fullScreenLeftContainerView.backgroundColor = [UIColor redColor];
    self.noFullScreenRightContainerView.backgroundColor = [UIColor whiteColor];
}

- (void)_initObserver {
    @weakify(self);
    [RACObserve(self, isFullScreen).distinctUntilChanged.deliverOnMainThread subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        self.noFullScreenRightContainerView.hidden = self.isFullScreen;
        self.fullScreenRightContainerView.hidden = !self.isFullScreen;
        self.fullScreenLeftContainerView.hidden = !self.isFullScreen;
        [self setNeedsLayout];
    }];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.fullScreenRightContainerView sizeToFit];
    [self.fullScreenLeftContainerView sizeToFit];
    [self.noFullScreenRightContainerView sizeToFit];
    
    // full screen
    if (self.isFullScreen) {
        self.fullScreenLeftContainerView.frame =
        CGRectMake(kFullScreenLeftContainerViewLeftPadding,
                   kFullScreenLeftContainerViewBottom + CGRectGetHeight(self.fullScreenLeftContainerView.frame),
                   CGRectGetWidth(self.fullScreenLeftContainerView.frame),
                   CGRectGetHeight(self.fullScreenLeftContainerView.frame));
        
        self.fullScreenRightContainerView.frame = \
        CGRectMake(CGRectGetWidth(self.frame) - kFullScreenRightContainerViewRightPadding - CGRectGetWidth(self.fullScreenRightContainerView.frame), \
                   CGRectGetMidY(self.fullScreenLeftContainerView.frame) - CGRectGetHeight(self.fullScreenRightContainerView.frame), \
                   CGRectGetWidth(self.fullScreenRightContainerView.frame), \
                   CGRectGetHeight(self.fullScreenRightContainerView.frame));
        
        UIView * higherFullscreenView = self.fullScreenLeftContainerView.height > self.fullScreenRightContainerView.height ? self.fullScreenRightContainerView:self.fullScreenLeftContainerView;
        self.fullScreenRightContainerView.centerY = higherFullscreenView.height/2.0;
        self.fullScreenLeftContainerView.centerY = higherFullscreenView.height/2.0;
    }
    
    
    
    // no full screen
    self.noFullScreenRightContainerView.frame = \
        CGRectMake(CGRectGetWidth(self.frame) - kNoFullScreenRightContainerViewRightPadding - CGRectGetWidth(self.noFullScreenRightContainerView.frame),\
                   0,\
                   CGRectGetWidth(self.noFullScreenRightContainerView.frame),\
                   CGRectGetHeight(self.noFullScreenRightContainerView.frame));
    self.noFullScreenRightContainerView.centerY = self.frame.size.height - kNoFullScreenRightContainerViewBottomCenterY;
}
@end
