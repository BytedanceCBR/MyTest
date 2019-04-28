//
//  TTVContainerSortView.m
//  Article
//
//  Created by yangshaobo on 2018/11/7.
//

#import "TTVContainerSortView.h"
#import "UIViewAdditions.h"

@interface TTVContainerSortView ()

@property (nonatomic, assign) NSUInteger countOfSortedViews;

@property (nonatomic, strong) NSMutableArray<UIView *> *viewsArray;

@property (nonatomic, assign) TTVContainerSortViewLayoutDirection layoutDirection;

@end

@implementation TTVContainerSortView

- (instancetype)initWithLayoutDirection:(TTVContainerSortViewLayoutDirection)layoutDirection spacing:(CGFloat)spacing {
    if (self = [super init]) {
        self.layoutDirection = layoutDirection;
        self.viewsArray = [NSMutableArray array];
        self.spacing = spacing;
        self.countOfSortedViews = 0;
    }
    return self;
}

- (void)addView:(UIView *)view {
    if ([view isKindOfClass:[UIView class]]) {
        [self addSubview:view];
        [self _cleanViewsArray];
        [self _addView:view];
        [self sizeToFit];
    }
}

#pragma mark - Set & Get

- (void)setSpacing:(CGFloat)spacing {
    _spacing = spacing;
    [self sizeToFit];
}

#pragma mark - Override

- (CGSize)sizeThatFits:(CGSize)size {
    __block CGFloat start = 0;
    __block CGFloat maxControlSide = 0;
    [self.viewsArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hidden || obj.superview != self) {
            return;
        }
        [obj sizeToFit];
        if (self.layoutDirection == TTVContainerSortViewLayoutDirectionVertical) {
            maxControlSide = MAX(obj.frame.size.width, maxControlSide);
            start += obj.bounds.size.height + self.spacing;
        } else {
            maxControlSide = MAX(obj.frame.size.height, maxControlSide);
            start += obj.bounds.size.width + self.spacing;
        }
    }];
    start = MAX(0, start - self.spacing);
    if (self.layoutDirection == TTVContainerSortViewLayoutDirectionVertical) {
        return (CGSize){maxControlSide, start};
    }
    return (CGSize){start, maxControlSide};
}

- (void)layoutSubviews {
    [super layoutSubviews];
    __block CGFloat start = 0;
    __block CGFloat maxControlSide = 0;
    [self.viewsArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hidden || obj.superview != self) {
            return;
        }
        [obj sizeToFit];
        if (self.layoutDirection == TTVContainerSortViewLayoutDirectionVertical) {
            obj.frame = CGRectMake(0, start, obj.frame.size.width, obj.frame.size.height);
            maxControlSide = MAX(obj.frame.size.width, maxControlSide);
            start += obj.bounds.size.height + self.spacing;
        } else {
            obj.frame = CGRectMake(start, 0, obj.frame.size.width, obj.frame.size.height);
            maxControlSide = MAX(obj.frame.size.height, maxControlSide);
            start += obj.bounds.size.width + self.spacing;
        }
    }];
    [self.viewsArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.layoutDirection == TTVContainerSortViewLayoutDirectionVertical) {
            obj.centerX = maxControlSide / 2.f;
        } else {
            obj.centerY = maxControlSide / 2.f;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _cleanViewsArray];
    });
}

#pragma mark - Util

//SortPriority越低越靠前 ， 如果array中有不是UIView的类型 靠后
- (void)_addView:(UIView *)view {
    [self.viewsArray removeObject:view];
    if ([view isKindOfClass:[UIView class]]) {
        if ([self.viewsArray count] == 0) {
            [self.viewsArray addObject:view];
            return;
        }
        if (self.viewsArray.firstObject && ((UIView *)self.viewsArray.firstObject).ttvPlayerSortContainerPriority >= view.ttvPlayerSortContainerPriority) {
            [self.viewsArray insertObject:view atIndex:0];
            return;
        }
        if (self.viewsArray.lastObject && ((UIView *)self.viewsArray.lastObject).ttvPlayerSortContainerPriority <= view.ttvPlayerSortContainerPriority) {
            [self.viewsArray addObject:view];
            return;
        }
        NSArray *array = [self.viewsArray copy];
        for (NSInteger i = 0; i < [array count]; i ++) {
            UIView *in_view = self.viewsArray[i];
            if (in_view.ttvPlayerSortContainerPriority > view.ttvPlayerSortContainerPriority) {
                [self.viewsArray insertObject:view atIndex:i];
                break;
            }
        }
    }
}

- (void)_cleanViewsArray {
    NSArray *array = [self.viewsArray copy];
    for (NSInteger i = [array count] - 1; i >= 0; i--) {
        if (self.viewsArray[i].superview != self) {
            [self.viewsArray removeObjectAtIndex:i];
        }
    }
    self.countOfSortedViews = [self.viewsArray count];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
}
@end
