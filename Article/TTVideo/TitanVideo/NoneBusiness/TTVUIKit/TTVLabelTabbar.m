//
//  TTVLabelTabbar.m
//  Article
//
//  Created by pei yun on 2017/3/23.
//
//

#import "TTVLabelTabbar.h"
#import "UIColor+TTThemeExtension.h"

@interface TTVLabelTabbar ()
{
    UIEdgeInsets _padding;
    NSArray *_tabs;
    UIView *_indicator;
    UIView *_bottomLine;
}

@property (nonatomic, strong) NSArray *tabs;

@end

@implementation TTVLabelTabbar

- (instancetype)initWithTabs:(NSArray *)tabs
{
    self = [super init];
    if (self) {
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        self.scrollsToTop = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        _tabs = tabs;
        _selectedIndex = 0;
        _unhighlightColor = [UIColor colorWithHexString:@"0xaaaaaa"];
        _highlightColor = [UIColor colorWithHexString:@"0xec463b"];
        
        _padding = UIEdgeInsetsMake(5, 10, 5, 10);
        _indicator = [[UIView alloc] init];
        _indicator.height = 2;
        _indicator.backgroundColor = _highlightColor;
        _animateDuration = .5;
        _indicatorMovingWhenPageDragged = YES;
        
        if (tabs.count < 2) {
            _indicator.hidden = YES;
        }
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.height = 0.5;
        _bottomLine.backgroundColor = [UIColor colorWithHexString:@"0xE0E0E0"];
        [self addSubview:_bottomLine];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)setTabs:(NSArray *)tabs
{
    [_tabs enumerateObjectsUsingBlock:^(UIView *tab, NSUInteger idx, BOOL * _Nonnull stop) {
        [tab removeFromSuperview];
    }];
    _tabs = tabs;
    [self layoutTabs];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex >=0 && selectedIndex < _tabs.count && selectedIndex != _selectedIndex) {
        NSInteger prevIndex = _selectedIndex;
        _selectedIndex = selectedIndex;
        if (self.indicatorMovingWhenPageDragged) {
            [self unhighlightItemAtIndex:prevIndex];
            [self layoutIndicator];
            [self highlightItemAtIndex:self.selectedIndex];
        } else {
            WeakSelf;
            [UIView animateWithDuration:self.animateDuration animations:^{
                StrongSelf;
                [self unhighlightItemAtIndex:prevIndex];
                [self layoutIndicator];
                [self highlightItemAtIndex:self.selectedIndex];
            }];
        }
        [self locateSelectedTabAtIndex:selectedIndex];
    }
}

- (void)highlightItemAtIndex:(NSInteger)index
{
    UILabel * label = _tabs[index];
    label.textColor = self.highlightColor;
    if (self.forceLeftAlignment) {
        label.font = [UIFont boldSystemFontOfSize:13];
    } else {
        label.font = [UIFont systemFontOfSize:13];
    }
}

- (void)unhighlightItemAtIndex:(NSInteger)index
{
    UILabel * label = _tabs[index];
    if (self.forceLeftAlignment) {
        label.font = [UIFont systemFontOfSize:13];
    }
    label.textColor = self.unhighlightColor;
}

- (void)setIndicator:(UIView *)indicator
{
    _indicator = indicator;
}

- (void)layoutTabs
{
    CGFloat centerY = (self.height - _padding.bottom - _padding.top) / 2. + _padding.top;
    CGFloat innerWidth = self.width - _padding.left - _padding.right;
    CGFloat tabWidth = innerWidth / _tabs.count;
    if (!self.forceLeftAlignment) {
        __block CGFloat result = _padding.left + tabWidth/2;
        [_tabs enumerateObjectsUsingBlock:^(UILabel *tab, NSUInteger idx, BOOL * _Nonnull stop) {
            [tab setHitTestEdgeInsets:UIEdgeInsetsMake(0, (tab.width - tabWidth)/2, 0, (tab.width - tabWidth)/2)];
            tab.centerY = centerY;
            tab.textColor = self.unhighlightColor;
            tab.centerX = result;
            tab.userInteractionEnabled = YES;
            [self addSubview:tab];
            result += tabWidth;
        }];
        _bottomLine.width = self.width + [UIScreen mainScreen].bounds.size.width;
    } else {
        NSMutableArray *widthArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (UILabel *tab in _tabs) {
            [widthArray addObject:@(tab.bounds.size.width)];
        }
        CGFloat result = 28 + [widthArray[0] floatValue]/2.;
        for (int i = 0; i < _tabs.count; i++) {
            UILabel *tab = _tabs[i];
            [tab setHitTestEdgeInsets:UIEdgeInsetsMake(0, -14, 0, -14)];
            tab.centerY = centerY;
            tab.textColor = self.unhighlightColor;
            tab.font = [UIFont systemFontOfSize:13];
            tab.centerX = result;
            tab.userInteractionEnabled = YES;
            [self addSubview:tab];
            result += [widthArray[i] floatValue]/2. + ((i < _tabs.count - 1)?(47 + [widthArray[i + 1] floatValue]/2.) : 28);
        }
        if (result < [UIScreen mainScreen].bounds.size.width) {
            _bottomLine.width = self.width + [UIScreen mainScreen].bounds.size.width;
        } else {
            _bottomLine.width = result + [UIScreen mainScreen].bounds.size.width;
        }
        [self setContentSize:CGSizeMake(result, self.bounds.size.height)];
    }
    
    [self addSubview:_indicator];
    _indicator.backgroundColor = self.highlightColor;
    _bottomLine.bottom = self.height;
    _bottomLine.left = self.left - [UIScreen mainScreen].bounds.size.width/2;
    [self highlightItemAtIndex:self.selectedIndex];
    [self layoutIndicator];
    
}

- (void)layoutIndicator
{
    if (!self.forceLeftAlignment) {
        CGFloat innerWidth = self.width - _padding.left - _padding.right;
        CGFloat tabWidth = innerWidth / _tabs.count;
        
        CGFloat left = _selectedIndex * tabWidth + _padding.left;
        
        _indicator.frame = CGRectMake(left, self.height - _indicator.height,
                                      tabWidth, _indicator.height);
    } else {
        UILabel *tab = self.tabs[_selectedIndex];
        _indicator.frame = CGRectMake(0, self.height - _indicator.height, tab.bounds.size.width + 28, _indicator.height);
        _indicator.centerX = tab.centerX;
    }
}

- (void)onTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint pt = [tapGesture locationInView:self];
    pt.y = (self.height - _padding.bottom - _padding.top) / 2. + _padding.top;
    UIView *topView = [self hitTest:pt withEvent:nil];
    
    NSInteger index = [_tabs indexOfObject:topView];
    if (index != NSNotFound && index != _selectedIndex) {
        NSInteger prevIndex = _selectedIndex;
        _selectedIndex = index;
        if ([_delegateCustom respondsToSelector:@selector(tabbar:didSelectedIndex:)]) {
            [_delegateCustom tabbar:self didSelectedIndex:_selectedIndex];
            [self locateSelectedTabAtIndex:_selectedIndex];
        }
        WeakSelf;
        [UIView animateWithDuration:self.animateDuration animations:^{
            StrongSelf;
            [self unhighlightItemAtIndex:prevIndex];
            [self layoutIndicator];
            [self highlightItemAtIndex:self.selectedIndex];
        }];
    }
}

- (void)locateSelectedTabAtIndex:(NSInteger)index
{
    UILabel *nextTab = [self.tabs objectAtIndex:index];
    if (self.contentSize.width > self.bounds.size.width) {
        if (nextTab.centerX + self.bounds.size.width / 2 > self.contentSize.width) {
            [self setContentOffset:CGPointMake(self.contentSize.width - self.bounds.size.width, self.contentOffset.y) animated:YES];
        } else if (nextTab.centerX - self.bounds.size.width / 2 < 0) {
            [self setContentOffset:CGPointMake(0 , self.contentOffset.y) animated:YES];
        } else {
            [self setContentOffset:CGPointMake(nextTab.center.x - self.bounds.size.width / 2, self.contentOffset.y) animated:YES];
        }
    }
}

- (void)setTabNormalizedOffset:(CGFloat)offset
{
    if (self.indicatorMovingWhenPageDragged) {
        CGFloat innerWidth = self.width - _padding.left - _padding.right;
        CGFloat tabWidth = innerWidth / _tabs.count;
        
        CGFloat left = offset * innerWidth + _padding.left;
        left = MIN(self.width - tabWidth - _padding.right, MAX(_padding.left, left));
        
        _indicator.frame = CGRectMake(left, self.height - _indicator.height,
                                      tabWidth, _indicator.height);
    }
}

@end
