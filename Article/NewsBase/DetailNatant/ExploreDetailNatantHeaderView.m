//
//  ExploreDetailNatantHeaderView.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-23.
//
//

#import "ExploreDetailNatantHeaderView.h"
#import "TTDetailNatantViewBase.h"

@interface ExploreDetailNatantHeaderView()
{
    float _itemOriginY;
    float _itemIndex;
}

@end

@implementation ExploreDetailNatantHeaderView

- (void)dealloc
{
    [self clear];
}

- (id)initWithWidth:(float)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        _itemOriginY = 0;
        _itemIndex = 100;
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor colorWithDayColorName:@"fafafa" nightColorName:@"252525"];
}

- (void)clear
{
    for (UIView * view in self.subviews) {
        if ([view isKindOfClass:[ExploreDetailNatantHeaderItemBase class]]) {
            [view removeFromSuperview];
        }
    }
    _itemOriginY = 0;
    _itemIndex = 100;
    [self setNatantHeight:0];
}

- (void)setNatantHeight:(float)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)appendView:(ExploreDetailNatantHeaderItemBase *)itemBase height:(float)height
{
    [self appendView:itemBase height:height left:0];
}

- (void)appendView:(ExploreDetailNatantHeaderItemBase *)itemBase height:(float)height left:(CGFloat)left
{
    if (![self.subviews containsObject:itemBase]) {
        [self addSubview:itemBase];
        itemBase.origin = CGPointMake(left, _itemOriginY);
        _itemOriginY += height;
        itemBase.tag = _itemIndex;
        [self setNatantHeight:_itemOriginY];
        _itemIndex ++;
    }
}

- (void)refreshWithWidth:(float)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;

    _itemOriginY = 0;
    for (int i = 100; i < _itemIndex; i++) {
        UIView * view = [self viewWithTag:i];
        if ([view isKindOfClass:[ExploreDetailNatantHeaderItemBase class]] || [view isKindOfClass:[TTDetailNatantViewBase class]]) {
            ExploreDetailNatantHeaderItemBase * itemBase = (ExploreDetailNatantHeaderItemBase *)view;
            [itemBase refreshWithWidth:width];
            itemBase.origin = CGPointMake(0, _itemOriginY);
            _itemOriginY += itemBase.height;
        }
    }
    [self setNatantHeight:_itemOriginY];
}

@end
