//
//  TabSelectSegControl.h
//  BaseGallery
//
//  Created by Tianhang Yu on 12-1-5.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSViewBase.h"
#import "SSThemed.h"

typedef enum {
    SSSegmentControlTypeSlide,
    SSSegmentControlTypeFlick
} SSSegmentControlType;


@class SSSegmentControl;

@protocol SSSegmentControlDelegate <NSObject>
- (void)ssSegmentControl:(SSSegmentControl *)ssSegmentControl didSelectAtIndex:(NSInteger)index;

@optional
- (void)ssSegmentControlDidSelectAtCurrentIndex:(SSSegmentControl *)ssSegmentControl;
@end


@interface SSSegmentControl : SSViewBase

@property (nonatomic, weak) id<SSSegmentControlDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray *segments;
@property (nonatomic, strong, readonly) NSArray *widths;
@property (nonatomic, strong, readonly) NSArray *gapWidths;
@property (nonatomic, strong) UIImage *slideImage;
@property (nonatomic, readonly) NSUInteger numberOfSegments;
@property (nonatomic, readonly) NSUInteger selectedIndex;       // default 0
@property (nonatomic, strong) UIImageView *slideImageView;
@property (nonatomic, strong) UIImageView *bottomShadow;
@property (nonatomic, strong)SSThemedView * bottomIndicator;
@property (nonatomic, strong)SSThemedView * bottomLineView;
@property (nonatomic, assign) BOOL hasAnimation;

- (id)initWithFrame:(CGRect)frame type:(SSSegmentControlType)type;
- (void)selectAtIndex:(NSUInteger)index;
- (void)selectAtIndex:(NSUInteger)index withAction:(BOOL)action;
- (void)defaultTwoSegments:(NSArray *)segments;
- (void)defatultThreeSegments:(NSArray *)segments withWidth:(CGFloat)width;
- (void)setSegments:(NSArray *)segments widths:(NSArray *)widths;
- (void)setSegments:(NSArray *)segments widths:(NSArray *)widths andGapWidths:(NSArray *)gapWidths;

@end


