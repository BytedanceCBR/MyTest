//
//  SSSegmentControl.m
//  BaseGallery
//
//  Created by Tianhang Yu on 12-1-5.
//  Copyright (c) 2012年 99fang. All rights reserved.
//

#import "SSSegmentControl.h"
#import "SSSegment.h"
#import "TTDeviceHelper.h"


 

#define kBottomIndicatorHeight 2

@interface SSSegmentControl ()

@property (nonatomic, readwrite) NSUInteger numberOfSegments;
@property (nonatomic, readwrite) NSUInteger selectedIndex;
@property (nonatomic, strong, readwrite) NSArray *segments;

@property (nonatomic) SSSegmentControlType type;
@end

@implementation SSSegmentControl

- (id)initWithFrame:(CGRect)frame type:(SSSegmentControlType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedIndex = 0;
        self.type = type;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame type:SSSegmentControlTypeFlick];
}



#pragma mark - public

- (void)setBottomShadow:(UIImageView *)bottomShadow
{
    if (_bottomShadow) {
        [_bottomShadow removeFromSuperview];
    }
    _bottomShadow = bottomShadow;
    
    if (_bottomShadow) {
        CGRect tmpFrame = _bottomShadow.frame;
        tmpFrame.origin.x = 0;
        tmpFrame.origin.y = self.bounds.size.height;
        tmpFrame.size.width = self.bounds.size.width;
        _bottomShadow.frame = tmpFrame;
        
        self.clipsToBounds = NO;
        _bottomShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:_bottomShadow];
    }
}

- (void)setSegments:(NSArray *)segments widths:(NSArray *)widths andGapWidths:(NSArray *)gapWidths{
   
    if (widths && ([widths count] != [segments count]) && gapWidths &&([gapWidths count] != [segments count] - 1)) {
        SSLog(@"%s: Segments count must equal to widths count , GapsWidths count must equal to widths count - 1", __PRETTY_FUNCTION__);
        return;
    }
    
    for (SSSegment *segment in _segments) {
        [segment removeFromSuperview];
    }
    
    _segments = segments;
    _widths = widths;
    _gapWidths = gapWidths;
    [self _layoutSegmentsWithGap];
}


- (void)_layoutSegmentsNOGap
{
    for (SSSegment *segment in _segments) {
        [segment removeFromSuperview];
    }
    
    CGRect vFrame = self.bounds;
    
    CGFloat subviewsOffsetX = 0.f;
    CGFloat subviewsOffsetY = 0.f;
    CGFloat subviewsWidth = _widths ? [[_widths objectAtIndex:0] floatValue] : vFrame.size.width / [_segments count];
    CGFloat subviewsHeight = vFrame.size.height;
    
    int index = 0;
    for (SSSegment *segment in _segments) {
        
        if (_widths) {
            subviewsWidth = [[_widths objectAtIndex:index] floatValue];
        }
        
        segment.frame = CGRectMake(subviewsOffsetX, subviewsOffsetY, subviewsWidth, subviewsHeight);
        segment.index = index;
        [segment addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:segment];
        
        [segment refreshUI];
        
        if (index == 0) {
            segment.checked = YES;
        }
        
        subviewsOffsetX += subviewsWidth;
        index ++;
    }
}

- (void)_layoutSegmentsWithGap
{
    CGRect vFrame = self.bounds;
    
    CGFloat subviewsCenterX = 0.f;
    CGFloat subviewsOffsetY = 0.f;
    CGFloat subviewsWidth   = 0.f;
    CGFloat subviewsHeight = vFrame.size.height;
    
    int index = 0;
    CGFloat gapWidth = 0;
    CGFloat gapwidthSum = 0;
    for (int i = 0; i < [_segments count] - 1 ; i++) {
        gapWidth = [[self.gapWidths objectAtIndex:i] floatValue];
        gapwidthSum += gapWidth;
    }
    
    subviewsCenterX = (vFrame.size.width - gapwidthSum) / 2;
    NSInteger textLength = 0;
    for (SSSegment *segment in _segments) {
        if ([[segment titleLabel].text length] > textLength) {
            textLength = [[segment titleLabel].text length];
        }
        subviewsWidth = 0;
        gapWidth = 0;
        if (self.widths) {
            subviewsWidth = [[self.widths objectAtIndex:index] floatValue];
        }
        if (self.gapWidths) {
            if (index < [_segments count] - 1) {
                gapWidth = [[self.gapWidths objectAtIndex:index] floatValue];
                
            }
        }
        
        segment.frame = CGRectMake(subviewsCenterX - subviewsWidth / 2, subviewsOffsetY, subviewsWidth, subviewsHeight);
        segment.index = index;
        [segment addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:segment];
        
        [segment refreshUI];
        
        if (index == 0) {
            segment.checked = YES;
        }
        
        subviewsCenterX += gapWidth;
        index ++;
    }
    subviewsCenterX = (vFrame.size.width - gapwidthSum) / 2;
    
    CGFloat bottomIndicatorWidth = 0;
    if (textLength == 2) {
        bottomIndicatorWidth = 30;
    }
    else if (textLength == 3){
        bottomIndicatorWidth = 49;
    }
    else{
        bottomIndicatorWidth = 64;
    }
    _hasAnimation = YES;
    if (!self.bottomIndicator) {
        self.bottomIndicator = [[SSThemedView alloc] initWithFrame:[self _bottomIndicatorFrameWithWidth:bottomIndicatorWidth subviewsCenterX:subviewsCenterX]];
        [self.bottomIndicator setBackgroundColor:SSGetThemedColorWithKey(kColorBackground7)];
    }
    else
    {
        self.bottomIndicator.frame = [self _bottomIndicatorFrameWithWidth:bottomIndicatorWidth subviewsCenterX:subviewsCenterX];
    }
    [self addSubview:_bottomIndicator];

    if (!_bottomLineView) {
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:[self _bottomLineViewFrame]];
        [self.bottomLineView setBackgroundColor:SSGetThemedColorWithKey(kColorLine7)];
    }
    else
    {
        self.bottomLineView.frame = [self _bottomLineViewFrame];
    }
    [self addSubview:_bottomLineView];


}

- (CGRect)_bottomIndicatorFrameWithWidth:(CGFloat)bottomIndicatorWidth subviewsCenterX:(CGFloat)subviewsCenterX
{
    return CGRectMake(subviewsCenterX - bottomIndicatorWidth / 2, self.height - kBottomIndicatorHeight - [TTDeviceHelper ssOnePixel], bottomIndicatorWidth, kBottomIndicatorHeight);
}

- (CGRect)_bottomLineViewFrame
{
    return CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel],self.width, [TTDeviceHelper ssOnePixel]);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        if (_gapWidths) {
            [self _layoutSegmentsWithGap];
        }
        else
        {
            [self _layoutSegmentsNOGap];
        }
        [self selectAtIndex:_selectedIndex];
    }
}

- (void)setSegments:(NSArray *)segments widths:(NSArray *)widths
{
    if (widths && ([widths count] != [segments count])) {
        SSLog(@"%s: Segments count must equal to widths count!", __PRETTY_FUNCTION__);
        return;
    }
    _segments = segments;
    _widths = widths;
    _gapWidths = nil;
    [self _layoutSegmentsNOGap];
}

- (void)defaultTwoSegments:(NSArray *)segments
{
    NSNumber * gapWidth = @(90);
    NSNumber * segmentWidth = @([self defaultWidthForSSSegment]);
    [self setSegments:segments widths:@[segmentWidth, segmentWidth] andGapWidths:@[gapWidth]];
}

- (void)defatultThreeSegments:(NSArray *)segments withWidth:(CGFloat)width
{
    NSArray *segmentWidths = nil;
    if ([segments count] == 3) {
        CGFloat leftSegmentWidth = (width - 2)/3;
        CGFloat middelSegmentWidth = leftSegmentWidth + 2;
        segmentWidths = @[[NSNumber numberWithFloat:leftSegmentWidth], [NSNumber numberWithFloat:middelSegmentWidth], [NSNumber numberWithFloat:leftSegmentWidth]];
    }
    [self setSegments:segments widths:segmentWidths];

}

- (void)setSlideImage:(UIImage *)slideImage
{
    if (_type == SSSegmentControlTypeSlide ) {
        _slideImage = slideImage;
        
        if (!_slideImageView) {
            self.slideImageView = [[UIImageView alloc] initWithImage:_slideImage];
            
            CGRect tmpFrame = _slideImageView.frame;
            
            if ([_segments count] > 0) {
                SSSegment *segment = [_segments objectAtIndex:_selectedIndex];
                tmpFrame.origin.x = CGRectGetMinX(segment.frame) + (segment.frame.size.width - _slideImageView.frame.size.width)/2;
                tmpFrame.origin.y = 0.f;
            }
            
            _slideImageView.frame = tmpFrame;
            
            [self addSubview:_slideImageView];
        }
        else {
            _slideImageView.image = _slideImage;
        }
    }
}

- (void)selectAtIndex:(NSUInteger)index withAction:(BOOL)action
{
    if (index < [_segments count]) {
        
        if (index == _selectedIndex) {
            if (action) {
                if (_delegate && [_delegate respondsToSelector:@selector(ssSegmentControlDidSelectAtCurrentIndex:)]) {
                    [_delegate ssSegmentControlDidSelectAtCurrentIndex:self];
                }
            }
        }
        else {
            self.selectedIndex = index;
            
            if (action) {
                if (_delegate != nil) {
                    [_delegate ssSegmentControl:self didSelectAtIndex:_selectedIndex];
                }
            }
        }
        NSInteger originIndex = 0;
        for (SSSegment *segment in _segments) {
            if (segment.checked == YES) {
                segment.checked = NO;
                break;
            }
            else{
                originIndex++;
            }
        }
        [self slideAnimationWithOriginIndex:originIndex andSelectedIndex:index];
        
        SSSegment *segment = [_segments objectAtIndex:_selectedIndex];
        segment.checked = YES;
    
        if (_type == SSSegmentControlTypeSlide) {
            [self slideSelectedImage];
        }
    }
}

- (void)slideAnimationWithOriginIndex:(NSInteger)originIndex andSelectedIndex:(NSInteger)selectedIndex{
    if (!_hasAnimation || originIndex == selectedIndex) {
        return;
    }
    else{
        if (_bottomIndicator) {
            NSUInteger segmentCount = [_segments count];
            CGFloat gapWidth = 90;//默认有两个segment
            if (segmentCount == 2) {
                gapWidth = 90;
            }
            else if(segmentCount == 3){
                gapWidth = 80;
            }
            else if (segmentCount == 4){
                if ([TTDeviceHelper is667Screen] ||[TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
                    gapWidth = 80;
                }
                else{
                    gapWidth = 76;
                }
            }
            else if(segmentCount == 5){
                if ([TTDeviceHelper is667Screen] ||[TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice]) {
                    gapWidth = 70;
                }
                else{
                    gapWidth = 60;
                }
            }
            CGFloat centerX  = _bottomIndicator.center.x;
            centerX += (selectedIndex - originIndex) * gapWidth;
            [UIView animateWithDuration:0.25f animations:^{
                _bottomIndicator.centerX = centerX;
            } completion:^(BOOL finished) {
                _bottomIndicator.centerX = centerX;
            }];
        }
    }
    
}

- (void)selectAtIndex:(NSUInteger)index
{
    [self selectAtIndex:index withAction:YES];
}

#pragma mark - private

- (void)slideSelectedImage
{
    [UIView animateWithDuration:0.25f
                     animations:^{
                         CGRect tmpFrame = _slideImageView.frame;
                         
                         if ([_segments count] > 0) {
                             SSSegment *segment = [_segments objectAtIndex:_selectedIndex];
                             tmpFrame.origin.x = CGRectGetMinX(segment.frame) + (segment.frame.size.width - _slideImageView.frame.size.width)/2;
                             tmpFrame.origin.y = 0.f;
                         }
                         
                         _slideImageView.frame = tmpFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
}


- (void)segmentClicked:(id)sender
{
    SSSegment *segment = sender;
    [self selectAtIndex:segment.index withAction:YES];
}

/*iOS10 上适配宽度*/
- (CGFloat)defaultWidthForSSSegment{
    if([TTDeviceHelper OSVersionNumber] >= 10.f){
        return 66.f;
    }
    else{
        return 64.f;
    }
}
@end






