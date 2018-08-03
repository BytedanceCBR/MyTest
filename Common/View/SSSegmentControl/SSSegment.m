//
//  SSSegment.m
//  Video
//
//  Created by Tianhang Yu on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSSegment.h"
 

#define BadgeViewTopPadding 3.f
#define BadgeViewRightPadding 0.f

@interface SSSegment ()
@end

@implementation SSSegment
@synthesize index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setBadgeView:(UIView *)badgeView
{
    if (_badgeView) {
        [_badgeView removeFromSuperview];
    }
    
    _badgeView = badgeView;
    if (_badgeView) {
        _badgeView.origin = CGPointMake(self.width - (_badgeView.width) - BadgeViewRightPadding, BadgeViewTopPadding);
        [self addSubview:_badgeView];
    }
}

- (void)refreshUI
{
    // could be extended
    if (_badgeView) {
        _badgeView.origin = CGPointMake(self.width - (_badgeView.width) - BadgeViewRightPadding, BadgeViewTopPadding);
    }
}

@end
