//
//  VideoTitleLabel.m
//  Video
//
//  Created by 于 天航 on 12-8-2.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoTitleLabel.h"
#import "UIColorAdditions.h"

@implementation VideoTitleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.textColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuTitleBarTitleColor")];
        self.shadowColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuTitleBarTitleShadowColor")];
        self.shadowOffset = CGSizeMake(SSUIFloatNoDefault(@"vuTitleBarTitleShadowOffsetX"),
                                       SSUIFloatNoDefault(@"vuTitleBarTitleShadowOffsetY"));
        self.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuTitleBarTitleFontSize"));
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
