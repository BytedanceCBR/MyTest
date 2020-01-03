//
// Created by zhulijun on 2019-12-10.
// Copyright (c) 2019 HeshamMegid. All rights reserved.
//

#import "FHSegmentControl.h"


@interface FHSegmentControl ()
@property(nonatomic, readwrite) CGFloat segmentTotalWidth;
@property(nonatomic, readwrite) NSArray<NSNumber *> *segmentWidthsArray;
@property(nonatomic, strong) CALayer *selectionIndicatorStripLayer;
@end

@implementation FHSegmentControl

- (instancetype)initWithSectionTitles:(NSArray<NSString *> *)sectionTitles {
    self = [super init];
    if (self) {
        _sectionTitles = [sectionTitles copy];
        [self commitInit];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    _selectedSegmentIndex = 0;
    _shouldAnimateUserSelection = YES;
    _touchEnabled = YES;
    self.selectionIndicatorStripLayer = [CALayer layer];
}

- (void)setSectionTitles:(NSArray<NSString *> *)sectionTitles {
    _sectionTitles = sectionTitles;

    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated {
    [self setSelectedSegmentIndex:index animated:animated notify:NO];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated notify:(BOOL)notify {
    if (_selectedSegmentIndex < 0) {
        return;
    }
    _selectedSegmentIndex = index;
    [self setNeedsDisplay];

    if (animated) {
        if ([self.selectionIndicatorStripLayer superlayer] == nil) {
            [self.layer addSublayer:self.selectionIndicatorStripLayer];
            [self setSelectedSegmentIndex:index animated:NO notify:YES];
            return;
        }

        if (notify)
            [self notifyForSegmentChangeToIndex:index];

        // Restore CALayer animations
        self.selectionIndicatorStripLayer.actions = nil;

        // Animate to new position
        [CATransaction begin];
        [CATransaction setAnimationDuration:0.15f];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
        [CATransaction commit];
    } else {
        // Disable CALayer animations
        NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", [NSNull null], @"bounds", nil];
        self.selectionIndicatorStripLayer.actions = newActions;
        self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
        if (notify)
            [self notifyForSegmentChangeToIndex:index];
    }
}

- (void)notifyForSegmentChangeToIndex:(NSInteger)index {
    if (self.superview)
        [self sendActionsForControlEvents:UIControlEventValueChanged];

    if (self.indexChangeBlock) {
        self.indexChangeBlock(index);
    }
}

- (CGSize)measureTitleAtIndex:(NSUInteger)index {
    if (index >= self.sectionTitles.count) {
        return CGSizeZero;
    }

    id title = self.sectionTitles[index];
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
    NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
    CGSize size = [(NSString *) title sizeWithAttributes:titleAttrs];
    UIFont *font = titleAttrs[@"NSFont"];
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

- (NSDictionary *)resultingSelectedTitleTextAttributes {
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:[self resultingTitleTextAttributes]];

    if (self.selectedTitleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.selectedTitleTextAttributes];
    }

    return [resultingAttrs copy];
}

- (NSDictionary *)resultingTitleTextAttributes {
    NSDictionary *defaults = @{
            NSFontAttributeName: [UIFont systemFontOfSize:19.0f],
            NSForegroundColorAttributeName: [UIColor blackColor],
    };

    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:defaults];

    if (self.titleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.titleTextAttributes];
    }

    return [resultingAttrs copy];
}

- (NSAttributedString *)attributedTitleAtIndex:(NSUInteger)index {
    id title = self.sectionTitles[index];
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;

    NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
    UIColor *titleColor = titleAttrs[NSForegroundColorAttributeName];
    if (titleColor) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:titleAttrs];
        dict[NSForegroundColorAttributeName] = titleColor;
        titleAttrs = [NSDictionary dictionaryWithDictionary:dict];
    }
    return [[NSAttributedString alloc] initWithString:(NSString *) title attributes:titleAttrs];
}

- (void)updateSegmentRects {
    NSMutableArray *mutableSegmentWidths = [NSMutableArray array];
    self.segmentTotalWidth = 0.0f;
    [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
        CGFloat stringWidth = [self measureTitleAtIndex:idx].width;
        self.segmentTotalWidth += stringWidth;
        [mutableSegmentWidths addObject:[NSNumber numberWithFloat:stringWidth]];
    }];
    self.segmentWidthsArray = [mutableSegmentWidths copy];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSegmentRects];
}

- (void)drawRect:(CGRect)rect {
    [self.backgroundColor setFill];
    UIRectFill([self bounds]);

    self.selectionIndicatorStripLayer.backgroundColor = self.selectionIndicatorColor.CGColor;
    self.selectionIndicatorStripLayer.cornerRadius = self.selectionIndicatorCornerRadius;
    self.layer.sublayers = nil;

    CGFloat segmentMargin = self.segmentWidthsArray.count > 1 ? (CGRectGetWidth(self.frame) - self.segmentTotalWidth) / (self.segmentWidthsArray.count - 1) : 0;

    [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {

        CGFloat stringHeight = 0;
        CGSize size = [self measureTitleAtIndex:idx];
        stringHeight = size.height;

        // Text inside the CATextLayer will appear blurry unless the rect values are rounded
        CGFloat xOffset = 0;
        for (NSUInteger i = 0; i < self.segmentWidthsArray.count; i++) {
            if (idx == i)
                break;
            NSNumber *width = self.segmentWidthsArray[i];
            xOffset = xOffset + [width floatValue] + segmentMargin;
        }

        CGFloat widthForIndex = [[self.segmentWidthsArray objectAtIndex:idx] floatValue];
        CGRect titleLayerRect = CGRectMake(ceilf(xOffset), 0, ceilf(widthForIndex), ceilf(stringHeight));

        CATextLayer *titleLayer = [CATextLayer layer];
        titleLayer.frame = titleLayerRect;
        titleLayer.alignmentMode = kCAAlignmentCenter;
        if ([UIDevice currentDevice].systemVersion.floatValue < 10.0) {
            titleLayer.truncationMode = kCATruncationEnd;
        }
        titleLayer.string = [self attributedTitleAtIndex:idx];
        titleLayer.contentsScale = [[UIScreen mainScreen] scale];

        [self.layer addSublayer:titleLayer];
    }];

    if (!self.selectionIndicatorStripLayer.superlayer) {
        self.selectionIndicatorStripLayer.frame = [self frameForSelectionIndicator];
        [self.layer addSublayer:self.selectionIndicatorStripLayer];
    }
}

- (CGRect)frameForSelectionIndicator {
    CGFloat indicatorYOffset = self.bounds.size.height - self.selectionIndicatorSize.height;
    CGFloat segmentMargin = self.segmentWidthsArray.count > 1 ? (CGRectGetWidth(self.frame) - self.segmentTotalWidth) / (self.segmentWidthsArray.count - 1) : 0;

    CGFloat xOffset = 0;
    for (NSUInteger i = 0; i < self.segmentWidthsArray.count; i++) {
        if (self.selectedSegmentIndex == i)
            break;
        NSNumber *width = self.segmentWidthsArray[i];
        xOffset = xOffset + [width floatValue] + segmentMargin;
    }
    CGFloat widthForIndex = [self.segmentWidthsArray[self.selectedSegmentIndex] floatValue];
    return CGRectMake(xOffset + (widthForIndex - self.selectionIndicatorSize.width) * 0.5, indicatorYOffset, self.selectionIndicatorSize.width, self.selectionIndicatorSize.height);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchLocation)) {
        NSInteger segment = 0;

        CGFloat segmentMargin = self.segmentWidthsArray.count > 1 ? (CGRectGetWidth(self.frame) - self.segmentTotalWidth) / (self.segmentWidthsArray.count - 1) : 0;

        CGFloat xOffset = 0;
        for (NSUInteger i = 0; i < self.segmentWidthsArray.count; i++) {
            NSInteger width = [self.segmentWidthsArray[i] integerValue];
            CGRect fullRect = CGRectMake(ceilf(xOffset - segmentMargin * 0.5), 0, ceilf(width + segmentMargin), CGRectGetHeight(self.frame));
            if (CGRectContainsPoint(fullRect, touchLocation)) {
                segment = i;
                break;
            }
            xOffset = xOffset + width + segmentMargin;
        }
        if (segment != self.selectedSegmentIndex && segment < self.sectionTitles.count) {
            // Check if we have to do anything with the touch event
            if (self.isTouchEnabled)
                [self setSelectedSegmentIndex:segment animated:self.shouldAnimateUserSelection notify:YES];
        }
    }
}
@end
