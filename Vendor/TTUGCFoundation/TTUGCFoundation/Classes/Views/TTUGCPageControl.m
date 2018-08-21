//
//  TTUGCPageControl.m
//  Article
//
//  Created by JvanChow on 19/12/2017.
//

#import "TTUGCPageControl.h"
#import "UIView+CustomTimingFunction.h"
#import "UIViewAdditions.h"

#define kItemSize 14 // 每个cell的宽高

typedef NS_ENUM(NSUInteger, TTUGCPageControlSubviewState) {
    TTUGCPageControlSubviewStateNone,
    TTUGCPageControlSubviewStateSmall,
    TTUGCPageControlSubviewStateMedium,
    TTUGCPageControlSubviewStateNormal,
};

@interface TTUGCPageControlSubview : SSThemedView

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, assign) TTUGCPageControlSubviewState state;
@property (nonatomic, strong) SSThemedView *dotView;

@end

@implementation TTUGCPageControlSubview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = 7;
        CGFloat x = (self.width - width) / 2.f;
        self.dotView = [[SSThemedView alloc] initWithFrame:CGRectMake(x, x, width, width)];
        self.dotView.layer.cornerRadius = width / 2.f;
        self.dotView.clipsToBounds = YES;
        [self addSubview:self.dotView];
    }
    return self;
}

- (void)setState:(TTUGCPageControlSubviewState)state {
    switch (state) {
        case TTUGCPageControlSubviewStateNone:
            self.dotView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
            break;
        case TTUGCPageControlSubviewStateSmall:
            self.dotView.transform = CGAffineTransformMakeScale(0.714f, 0.714f);
            break;
        case TTUGCPageControlSubviewStateMedium:
            self.dotView.transform = CGAffineTransformMakeScale(0.857f, 0.857f);
            break;
        case TTUGCPageControlSubviewStateNormal:
            self.dotView.transform = CGAffineTransformIdentity;
            break;
    }
}

- (void)setDotColor:(UIColor *)dotColor {
    self.dotView.layer.backgroundColor = dotColor.CGColor;
}

@end

@interface TTUGCPageControl () <UIScrollViewDelegate>

@property (nonatomic, strong) SSThemedScrollView *scrollView;
@property (nonatomic, assign) BOOL animationState; // 表示是否是动效状态
@property (nonatomic, strong) NSMutableArray *reuseSubviews;
@property (nonatomic, assign) NSUInteger numberOfPages;

@end

@implementation TTUGCPageControl

- (instancetype)initWithNumberOfPages:(NSUInteger)numberOfPages currentPage:(NSUInteger)currentPage {
    self = [super init];
    if (self) {
        _numberOfPages = numberOfPages;
        _currentPage = currentPage;
        NSUInteger displayMaxCount = 5;
        if (numberOfPages <= displayMaxCount) {
            self.frame = CGRectMake(0, 0, numberOfPages * kItemSize, kItemSize);
            self.animationState = NO;

            CGFloat x = 0;
            self.scrollView.contentSize = CGSizeMake(kItemSize * numberOfPages, kItemSize);
            NSMutableArray *array = [NSMutableArray array];
            for (NSInteger i = 0; i < numberOfPages; i++) {
                x = i * kItemSize;
                TTUGCPageControlSubview *subview = [[TTUGCPageControlSubview alloc] initWithFrame:CGRectMake(x, 0, kItemSize, kItemSize)];
                subview.index = i;
                [self.scrollView addSubview:subview];
                [array addObject:subview];
            }
            self.reuseSubviews = [NSMutableArray arrayWithArray:[array copy]];
            self.scrollView.contentOffset = CGPointMake(0, 0);
        } else {
            self.frame = CGRectMake(0, 0, displayMaxCount * kItemSize, kItemSize);
            self.animationState = YES;

            CGFloat x = 0;
            NSInteger index = currentPage - 3;
            NSMutableArray *array = [NSMutableArray array];
            self.scrollView.contentSize = CGSizeMake(kItemSize * (numberOfPages + 2 * 2), kItemSize); // 前后各加两个空白区域
            for (NSInteger i = 0; i < displayMaxCount + 2; i++) { // 可复用的子View是展示个数再+2，居中显示，左右两边各一个预留子View
                x = (index + 2) * kItemSize;
                TTUGCPageControlSubview *subview = [[TTUGCPageControlSubview alloc] initWithFrame:CGRectMake(x, 0, kItemSize, kItemSize)];
                subview.index = index;
                [self updateSubviewState:subview currentPage:currentPage];
                [self.scrollView addSubview:subview];
                [array addObject:subview];
                index++;
            }
            self.reuseSubviews = [NSMutableArray arrayWithArray:[array copy]];
            self.scrollView.contentOffset = CGPointMake(kItemSize * currentPage, 0);
        }
        [self addSubview:self.scrollView];
    }
    return self;
}

-(void)dealloc {
    _scrollView.delegate = nil;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor {
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    [self.reuseSubviews enumerateObjectsUsingBlock:^(TTUGCPageControlSubview *subview, NSUInteger idx, BOOL * _Nonnull stop) {
        subview.dotColor = subview.index == _currentPage ? _currentPageIndicatorTintColor : _pageIndicatorTintColor;
    }];
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    _pageIndicatorTintColor = pageIndicatorTintColor;
    [self.reuseSubviews enumerateObjectsUsingBlock:^(TTUGCPageControlSubview *subview, NSUInteger idx, BOOL * _Nonnull stop) {
        subview.dotColor = subview.index == _currentPage ? _currentPageIndicatorTintColor : _pageIndicatorTintColor;
    }];
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    if (_numberOfPages <= 1) {
        return;
    }
    if (_currentPage == currentPage) {
        return;
    }

    BOOL leftMove = currentPage > _currentPage;
    _currentPage = currentPage;
    [self.reuseSubviews enumerateObjectsUsingBlock:^(TTUGCPageControlSubview *subview, NSUInteger idx, BOOL * _Nonnull stop) {
        subview.dotColor = subview.index == currentPage ? _currentPageIndicatorTintColor : _pageIndicatorTintColor;
    }];

    if (!self.animationState) { // 个数少于5个时，只需要更新颜色
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2f
               customTimingFunction:CustomTimingFunctionEaseOut
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                          animation:^{
            if (leftMove) { // 左移
                TTUGCPageControlSubview *first = self.reuseSubviews.firstObject;
                TTUGCPageControlSubview *last = self.reuseSubviews.lastObject;
                first.index = last.index + 1;
                first.left = last.left + kItemSize;
                [self.reuseSubviews removeObject:first];
                [self.reuseSubviews addObject:first];
                self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + kItemSize, self.scrollView.contentOffset.y);
            } else { // 右移
                TTUGCPageControlSubview *first = self.reuseSubviews.firstObject;
                TTUGCPageControlSubview *last = self.reuseSubviews.lastObject;
                last.index = first.index - 1;
                last.left = first.left - kItemSize;
                [self.reuseSubviews removeObject:last];
                [self.reuseSubviews insertObject:last atIndex:0];
                self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x - kItemSize, self.scrollView.contentOffset.y);
            }
            [self.reuseSubviews enumerateObjectsUsingBlock:^(TTUGCPageControlSubview *subview, NSUInteger idx, BOOL * _Nonnull stop) {
                [self updateSubviewState:subview currentPage:currentPage];
            }];
        } completion:nil];
    });
}

- (void)updateSubviewState:(TTUGCPageControlSubview *)subview currentPage:(NSInteger)currentPage {
    if (subview.index < 0 || subview.index > _numberOfPages - 1) {
        subview.state = TTUGCPageControlSubviewStateNone;
    } else if (subview.index == currentPage) {
        subview.state = TTUGCPageControlSubviewStateNormal;
    } else if (abs((int)(subview.index - currentPage)) == 1) {
        subview.state = TTUGCPageControlSubviewStateMedium;
    } else if (abs((int)(subview.index - currentPage)) == 2) {
        subview.state = TTUGCPageControlSubviewStateSmall;
    } else {
        subview.state = TTUGCPageControlSubviewStateNone;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 该组件的父视图，在push进其他页面时，在TTNavigationController里调用[fromViewController.view removeFromSuperview]时，不知为何会改变当前scrollView的contentOffset
    if ([scrollView isEqual:self.scrollView] && scrollView.contentOffset.x != kItemSize * _currentPage) {
        self.scrollView.contentOffset = CGPointMake(kItemSize * _currentPage, 0);
    }
}

- (SSThemedScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[SSThemedScrollView alloc] initWithFrame:self.bounds];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.userInteractionEnabled = NO;
        _scrollView.delegate = self;
    }

    return _scrollView;
}

@end
