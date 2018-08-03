//
//  VideoTitleBarSegment.m
//  Video
//
//  Created by 于 天航 on 12-7-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "VideoTitleBarSegment.h"
#import "UIColorAdditions.h"

@implementation VideoTitleBarSegment

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"vuTitleBarSegmentNormalTitleColor")]
                   forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"vuStandardBlueColor")]
                   forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"vuStandardBlueColor")]
                   forState:UIControlStateDisabled];
        [self setTitleShadowColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"vuTitleBarSegmentTitleShadowColor")]
                         forState:UIControlStateNormal];
        self.titleLabel.shadowOffset = CGSizeMake(0.f, SSUIFloatNoDefault(@"vuTitleBarSegmentTitleShadowOffset"));
        self.titleLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuTilleBarSegmentFontSize"));
        self.titleEdgeInsets = UIEdgeInsetsMake(1.f, 0, 0, 0);
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
