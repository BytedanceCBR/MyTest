//
//  TTVScrollableSegmentControl.m
//  Article
//
//  Created by pei yun on 2017/3/22.
//
//

#import "TTVScrollableSegmentControl.h"
#import "NSObject+FBKVOController.h"
#import "UIColor+TTThemeExtension.h"
#import "NSArray+BlocksKit.h"

static const NSInteger kTagFloor = 1000;
static const CGFloat kDefaultVisibleItemCount = -1;
static const CGFloat kAutoWidth = 0;
static const CGFloat kAutoHeight = 0;
static const CGFloat kDefaultGradientOffset = 50;
static const CGFloat kDefaultGradientPercentage = 0.2;

@interface TTVScrollableSegmentControl ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIControl *currentSelectControl;

@property (nonatomic, assign) CGFloat gradientScrollOffset;
@property (nonatomic, assign) CGFloat gradientPercentage;
@property (nonatomic, strong) UIColor *gradientColor;
@property (nonatomic, strong) UIView *leftMask;
@property (nonatomic, strong) UIView *rightMask;

@end

@implementation TTVScrollableSegmentControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _animateDuration = 0.3f;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    WeakSelf;
    [self.KVOController observe:self.scrollView keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial block:^(id observer, id object, NSDictionary *change) {
        StrongSelf;
        if (self.adoptGradient) {
            [self updateGradientsForScrollView:self.scrollView];
        }
    }];
    [self addSubview:_scrollView];
    
    _visibleItemCount = kDefaultVisibleItemCount;
    _adoptGradient = YES;
    self.gradientScrollOffset = kDefaultGradientOffset;
    self.gradientPercentage = kDefaultGradientPercentage;
    self.gradientColor = [UIColor whiteColor];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    [self switchToIndex:selectedIndex animated:NO];
}

- (void)setControls:(NSArray<UIControl *> *)controls
{
    _controls = controls;
    if (self.segmentedControlDelegate && [self.segmentedControlDelegate respondsToSelector:@selector(scrollableSegmentControl:controlsWillBeAdded:)]) {
        [self.segmentedControlDelegate scrollableSegmentControl:self controlsWillBeAdded:self.controls];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    self.selectedIndex = self.selectedIndex;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self doLayout];
    [super layoutSubviews];
}

- (void)doLayout
{
    if (self.segmentedControlDelegate && [self.segmentedControlDelegate respondsToSelector:@selector(scrollableSegmentControl:controlsWillLayout:)]) {
        [self.segmentedControlDelegate scrollableSegmentControl:self controlsWillLayout:self.controls];
    }
    for (UIControl *control in self.controls) {
        [control removeFromSuperview];
    }
    CGFloat startX = self.contentInsets.left;
    for (NSInteger i = 0; i < self.controls.count; i ++) {
        UIControl *control = self.controls[i];
        control.tag = kTagFloor + i;
        control.left = startX;
        if (control.width == kAutoWidth) {
            CGFloat itemCount = self.visibleItemCount > 0 ? self.visibleItemCount : self.controls.count;
            control.width = (self.width - self.contentInsets.left - self.contentInsets.right + self.itemSpacing) / itemCount - self.itemSpacing;
        }
        if (control.height == kAutoHeight) {
            control.height = self.height - self.contentInsets.top - self.contentInsets.bottom;
        }
        control.top = (self.height - control.height) / 2;
        [control addTarget:self action:@selector(didTapControlInternal:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:control];
        startX += (i == self.controls.count - 1) ? control.width : (control.width + self.itemSpacing);
    }
    self.scrollView.contentSize = CGSizeMake(startX + self.contentInsets.right, self.scrollView.height);
    
    if (self.adoptGradient) {
        [self applyGradient];
    }
    
    if (self.segmentedControlDelegate && [self.segmentedControlDelegate respondsToSelector:@selector(scrollableSegmentControl:controlsDidLayout:)]) {
        [self.segmentedControlDelegate scrollableSegmentControl:self controlsDidLayout:self.controls];
    }
}

- (void)didTapControlInternal:(UIControl *)control
{
    if (self.currentSelectControl == control) {
        return;
    }
    NSInteger index = control.tag - kTagFloor;
    self.selectedIndex = index;
    [self switchToIndex:index animated:YES];
}

- (void)switchToIndex:(NSInteger)index animated:(BOOL)animated
{
    if (!animated) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self switchToIndexInternal_:index animated:animated];
        });
    } else {
        [self switchToIndexInternal_:index animated:animated];
    }
}

- (void)switchToIndexInternal_:(NSInteger)index animated:(BOOL)animated
{
    if (index >= 0 && index < self.controls.count) {
        UIControl *control = self.controls[index];
        if (self.currentSelectControl == control) {
            return;
        }
        if (self.segmentedControlDelegate && [self.segmentedControlDelegate respondsToSelector:@selector(segmentedControllDidBeginSnapingToIndex:withDuration:)]) {
            [self.segmentedControlDelegate segmentedControllDidBeginSnapingToIndex:index withDuration:self.animateDuration];
        }
        
        [UIView animateWithDuration:animated ? self.animateDuration : 0.0f animations:^{
            self.movableBackgroundView.width = control.width;
            self.movableBackgroundView.bottom = self.scrollView.bottom;
            self.movableBackgroundView.centerX = control.centerX;
        } completion:^(BOOL finished) {
            self.currentSelectControl.selected = NO;
            control.selected = YES;
            self.currentSelectControl = control;
            if (self.segmentedControlDelegate && [self.segmentedControlDelegate respondsToSelector:@selector(scrollableSegmentControl:didSelectItemAtIndex:)]) {
                [self.segmentedControlDelegate scrollableSegmentControl:self didSelectItemAtIndex:index];
            }
        }];
        [self scrollItemVisible:control];
    }
}

- (void)scrollItemVisible:(UIControl *)item
{
    CGRect frame = item.frame;
    if (item != self.scrollView.subviews.firstObject && item != self.scrollView.subviews.lastObject) {
        CGFloat min = CGRectGetMinX(item.frame);
        CGFloat max = CGRectGetMaxX(item.frame);
        
        
        if (min < self.scrollView.contentOffset.x) {
            frame = (CGRect){{item.frame.origin.x - 25, item.frame.origin.y}, item.frame.size};
        } else if (max > self.scrollView.contentOffset.x + self.scrollView.frame.size.width) {
            frame = (CGRect){{item.frame.origin.x + 25, item.frame.origin.y}, item.frame.size};
        }
    }
    
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

#pragma mark - TTVSegmentedControl

- (void)moveToNormalizedOffset:(CGFloat)offset
{
    CGFloat innerWidth = self.scrollView.bounds.size.width - _contentInsets.left - _contentInsets.right;
    CGFloat left = offset * innerWidth + _contentInsets.left;
    left = MIN(self.scrollView.bounds.size.width - _movableBackgroundView.width - _contentInsets.right, MAX(_contentInsets.left, left));
    _movableBackgroundView.left = left;
//    CGFloat innerWidth = self.width - _padding.left - _padding.right;
//    CGFloat tabWidth = innerWidth / _tabs.count;
//    
//    CGFloat left = offset * innerWidth + _padding.left;
//    left = MIN(self.width - tabWidth - _padding.right, MAX(_padding.left, left));
//    
//    _indicator.frame = CGRectMake(left, self.height - _indicator.height,
//                                  tabWidth, _indicator.height);
}

- (void)moveToIndex:(NSUInteger)index
{
    self.selectedIndex = index;
}

#pragma mark - Gradient Layer

- (void)applyGradient
{
    if (self.leftMask) {
        [self.leftMask removeFromSuperview];
        self.leftMask = nil;
    }
    
    if (self.rightMask) {
        [self.rightMask removeFromSuperview];
        self.rightMask = nil;
    }
    
    self.leftMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)];
    self.leftMask.userInteractionEnabled = NO;
    self.leftMask.backgroundColor = self.gradientColor;
    self.leftMask.alpha = 0;
    [self insertSubview:self.leftMask aboveSubview:self.scrollView];
    
    self.leftMask.layer.mask = [self gradientLayerForBounds:self.leftMask.bounds inVector:CGVectorMake(0.0, self.gradientPercentage) withColors:@[self.gradientColor, [UIColor clearColor]]];
    
    self.rightMask = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];
    self.rightMask.userInteractionEnabled = NO;
    self.rightMask.backgroundColor = self.gradientColor;
    self.rightMask.alpha = 0.7;
    [self insertSubview:self.rightMask aboveSubview:self.scrollView];
    
    self.rightMask.layer.mask = [self gradientLayerForBounds:self.rightMask.bounds inVector:CGVectorMake(1 - self.gradientPercentage, 1.0) withColors:@[[UIColor clearColor], self.gradientColor]];
}

- (void)updateGradientsForScrollView:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < self.gradientScrollOffset) {
        CGFloat alpha = scrollView.contentOffset.x / self.gradientScrollOffset;
        self.leftMask.alpha = alpha;
    } else {
        self.leftMask.alpha = 1;
    }
    
    if (scrollView.contentOffset.x + scrollView.frame.size.width > scrollView.contentSize.width - self.gradientScrollOffset) {
        CGFloat alpha = (scrollView.contentSize.width - (scrollView.contentOffset.x + scrollView.frame.size.width)) / self.gradientScrollOffset;
        self.rightMask.alpha = alpha;
    } else {
        self.rightMask.alpha = 1;
    }
}

- (CAGradientLayer *)gradientLayerForBounds:(CGRect)bounds inVector:(CGVector)vector withColors:(NSArray *)colors
{
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.locations = [NSArray arrayWithObjects:
                      [NSNumber numberWithFloat:vector.dx],
                      [NSNumber numberWithFloat:vector.dy],
                      nil];
    
    mask.colors = [NSArray arrayWithObjects:
                   (__bridge id)((UIColor *)colors.firstObject).CGColor,
                   (__bridge id)((UIColor *)colors.lastObject).CGColor,
                   nil];
    
    mask.frame = bounds;
    mask.startPoint = CGPointMake(0, 0);
    mask.endPoint = CGPointMake(1, 0);
    
    return mask;
}

@end

@implementation TTVScrollableLabelSegmentControl

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        self.itemSpacing = 10;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        lineView.height = 2;
        lineView.backgroundColor = [UIColor colorWithHexString:@"0xec463b"];
        self.movableBackgroundView = lineView;
        [self.scrollView addSubview:lineView];
    }
    return self;
}

- (void)setTitles:(NSArray<NSString *> *)titles
{
    _titles = titles;
    
    CGFloat itemWidth = kAutoWidth;
    CGFloat itemHeight = kAutoHeight;
    self.controls = [self.titles bk_map:^id(NSString *title) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
        button.hitTestEdgeInsets = UIEdgeInsetsMake(-self.contentInsets.top, -self.itemSpacing / 2, -self.contentInsets.bottom, -self.itemSpacing / 2);
        
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"0xaaaaaa"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"0xec463b"] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor colorWithHexString:@"0xec463b"] forState:UIControlStateSelected];
        [button setTitleColor:[UIColor colorWithHexString:@"0xec463b"] forState:UIControlStateHighlighted | UIControlStateSelected];
        return button;
    }];
}

@end
