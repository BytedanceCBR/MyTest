//
//  TTVPlayerLayoutTopView.m
//  Article
//
//  Created by yangshaobo on 2018/11/2.
//

#import "TTVPlayerLayoutTopView.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTVContainerSortView.h"
#import "UIView+TTVViewKey.h"

//FullBackButton
#define kFullBackButtonLeftPadding(fullScreen) (!fullScreen ? 8.f : 12.f)
#define kFullBackButtonTopPadding(fullScreen) (!fullScreen ? 4.f : 12.f)

//TitleView
#define kTitleViewLeftPadding 2.f

//RightContainerView
#define kRightContainerViewRightPadding(fullScreen) (!fullScreen ? 12.f : 12.f)
#define kRightContainerViewSpacing(fullScreen) (!fullScreen ? 22.f : 30.f)

//MoreButton
#define kMoreButtonRightPadding(fullScreen) (!fullScreen ? 16.f : 16.f)

@interface TTVPlayerLayoutTopView ()

@property (nonatomic, strong) TTVContainerSortView *rightRectangleViewsContainerView;

@property (nonatomic, strong) TTVContainerSortView *rightViewsContainerView;

@property (nonatomic, strong) TTVContainerSortView *leftViewsContainerView;

@end

@implementation TTVPlayerLayoutTopView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initContainerViews];
        [self _initObserver];
    }
    return self;
}

- (void)_initContainerViews {
    self.rightRectangleViewsContainerView = [[TTVContainerSortView alloc] initWithLayoutDirection:TTVContainerSortViewLayoutDirectionHorizontal spacing:kRightContainerViewSpacing(self.isFullScreen)];
    self.rightRectangleViewsContainerView.ttvPlayerSortContainerPriority = 0;
    self.rightViewsContainerView = [[TTVContainerSortView alloc] initWithLayoutDirection:TTVContainerSortViewLayoutDirectionHorizontal spacing:kRightContainerViewRightPadding(self.isFullScreen)];
    self.leftViewsContainerView = [[TTVContainerSortView alloc] initWithLayoutDirection:TTVContainerSortViewLayoutDirectionHorizontal spacing:2.f];
    [self.rightViewsContainerView addView:self.rightRectangleViewsContainerView];
    [self addSubview:self.rightViewsContainerView];
    [self addSubview:self.leftViewsContainerView];
}

- (void)_initObserver {
    @weakify(self);
    [RACObserve(self, isFullScreen).distinctUntilChanged.deliverOnMainThread subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.rightRectangleViewsContainerView setSpacing:kRightContainerViewSpacing(self.isFullScreen)];
        [self.rightViewsContainerView setSpacing:kRightContainerViewRightPadding(self.isFullScreen)];
        [self setNeedsLayout];
    }];
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.rightViewsContainerView sizeToFit];
    [self.leftViewsContainerView sizeToFit];
    
    self.leftViewsContainerView.frame = \
        CGRectMake(kFullBackButtonLeftPadding(self.isFullScreen),\
                   kFullBackButtonTopPadding(self.isFullScreen),\
                   CGRectGetWidth(self.leftViewsContainerView.frame),\
                   CGRectGetHeight(self.leftViewsContainerView.frame));
    
    self.rightViewsContainerView.frame = \
        CGRectMake(CGRectGetWidth(self.frame) - kMoreButtonRightPadding(self.isFullScreen) - CGRectGetWidth(self.rightViewsContainerView.frame), \
                   CGRectGetMidY(self.leftViewsContainerView.frame) - CGRectGetHeight(self.rightViewsContainerView.frame) / 2.f, \
                   CGRectGetWidth(self.rightViewsContainerView.frame), \
                   CGRectGetHeight(self.rightViewsContainerView.frame));
}


@end
