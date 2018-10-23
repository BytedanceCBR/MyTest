//
//  VideoRateView.m
//  Video
//
//  Created by Kimi on 12-10-12.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoRateView.h"

typedef enum {
    StarViewTypeEmpty,
    StarViewTypeHalf,
    StarViewTypeFull
} StarViewType;
@interface StarView : UIImageView
@property (nonatomic) StarViewType type;
@end

@implementation StarView

- (void)setType:(StarViewType)type
{
    _type = type;
    switch (_type) {
        case StarViewTypeEmpty:
            [self setImage:[UIImage imageNamed:@"star_gray.png"]];
            break;
        case StarViewTypeHalf:
            [self setImage:[UIImage imageNamed:@"star_half.png"]];
            break;
        case StarViewTypeFull:
            [self setImage:[UIImage imageNamed:@"star.png"]];
            break;
    }
}

@end


@interface VideoRateView ()
@property (nonatomic, retain) NSArray *stars;
@property (nonatomic, retain) UIView *noRateView;
@end

@implementation VideoRateView

- (void)dealloc
{
    self.rate = nil;
    self.stars = nil;
    self.noRateView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // do nothing
    }
    return self;
}

- (void)buildStars
{
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:5];
    CGFloat subviewX = 0.f;
    CGFloat subviewY = 0.f;
    CGFloat subviewWidth = 10.f;
    CGFloat subviewHeight = 10.f;
    for (int i=0; i < 5; i++) {
        StarView *star = [[[StarView alloc] init] autorelease];
        star.type = StarViewTypeEmpty;
        star.frame = CGRectMake(subviewX, subviewY, subviewWidth, subviewHeight);
        [self addSubview:star];
        
        [tmpArray addObject:star];
        
        subviewX += subviewWidth;
    }
    
    self.stars = [[tmpArray copy] autorelease];
}

- (void)displayNoRateView:(BOOL)display
{
    if (!_noRateView) {
        self.noRateView = [[[UIView alloc] init] autorelease];
        _noRateView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _noRateView.frame = self.bounds;
        [self addSubview:_noRateView];
        
        UILabel *noRateLabel = [[[UILabel alloc] init] autorelease];
        noRateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        noRateLabel.text = @"无评级";
        noRateLabel.textColor = [UIColor grayColor];
        noRateLabel.font = ChineseFontWithSize(9.f);
        noRateLabel.backgroundColor = [UIColor clearColor];
        [noRateLabel sizeToFit];
        noRateLabel.center = CGPointMake(noRateLabel.frame.size.width/2, _noRateView.frame.size.height/2);
        [_noRateView addSubview:noRateLabel];
    }
    
    _noRateView.hidden = !display;
    for (StarView *star in _stars) {
        star.hidden = display;
    }
}

- (void)setRate:(NSNumber *)rate
{
    if ([_rate floatValue] != [rate floatValue]) {
        [_rate release];
        _rate = [rate retain];
        
        if (_rate) {
            if (_stars == nil) {
                [self buildStars];
            }
            
            if ([_rate intValue] == -1) {
                [self displayNoRateView:YES];
            }
            else {
                [self displayNoRateView:NO];
                [_stars enumerateObjectsUsingBlock:^(StarView *star, NSUInteger idx, BOOL *stop) {
                    if (idx < floorf([_rate floatValue])) {
                        star.type = StarViewTypeFull;
                    }
                    else if (idx < ceilf([_rate floatValue])) {
                        star.type = StarViewTypeHalf;
                    }
                    else {
                        star.type = StarViewTypeEmpty;
                    }
                }];
            }
        }
    }
}

@end
