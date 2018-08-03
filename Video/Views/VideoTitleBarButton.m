//
//  VideoTitleBarButton.m
//  Video
//
//  Created by 于 天航 on 12-7-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoTitleBarButton.h"
#import "UIColorAdditions.h"

@implementation VideoTitleBarButton {
    VideoTitleBarButtonType _type;
}

+ (VideoTitleBarButton *)buttonWithType:(VideoTitleBarButtonType)type
{
    VideoTitleBarButton *button = [[[VideoTitleBarButton alloc] init] autorelease];
    
    [button setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"vuTitleBarButtonNormalTitleColor")]
                 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:SSUIStringNoDefault(@"vuStandardBlueColor")]
                 forState:UIControlStateHighlighted];
 
    NSString *normalBackgroundImageName = nil;
    NSString *highlightBackgroundImageName = nil;
    NSString *normalImageName = nil;
    NSString *highlightImageName = nil;
    
    CGFloat width = 56.f;
    
    switch (type) {
        case VideoTitleBarButtonTypeLeftNormalBoard:
        {
            normalBackgroundImageName = @"btn.png";
            highlightBackgroundImageName = @"btn_press.png";
            button.titleLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuTitleBarButtonBoardFontSize"));
            width = 66.f;
        }
            break;
        case VideoTitleBarButtonTypeLeftNormalNarrow:
        {
            normalBackgroundImageName = @"btn.png";
            highlightBackgroundImageName = @"btn_press.png";
            button.titleLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuTitleBarButtonNarrowFontSize"));
        }
            break;
        case VideoTitleBarButtonTypeRightNormalNarrow:
        {
            normalBackgroundImageName = @"btn_right";
            highlightBackgroundImageName = @"btn_right_press";
            button.titleLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuTitleBarButtonNarrowFontSize"));
        }
            break;
        case VideoTitleBarButtonTypeLeftBack:
        {
            normalBackgroundImageName = @"leftBackButtonBGNormal";
            highlightBackgroundImageName = @"leftBackButtonBG_press";
            normalImageName = @"leftBackButtonFGNormal";
            highlightImageName = @"leftBackButtonFG_press";
            button.titleLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuTitleBarButtonNarrowFontSize"));
        }
            break;
        case VideoTitleBarButtonTypeRefresh:
        {
            normalBackgroundImageName = @"rightRefreshButtonBGNormal";
            highlightBackgroundImageName = @"rightRefreshButtonBG_press";
            normalImageName = @"refreshicon";
            highlightImageName = @"refreshicon_press";
            button.titleLabel.font = ChineseFontWithSize(SSUIFloatNoDefault(@"vuTitleBarButtonNarrowFontSize"));
        }
            break;
        default:
            break;
    }
    
    UIImage *normalBackgroundImage = [UIImage imageNamed:normalBackgroundImageName];
    normalBackgroundImage = [normalBackgroundImage stretchableImageWithLeftCapWidth:normalBackgroundImage.size.width/2 topCapHeight:normalBackgroundImage.size.height/2];
    UIImage *highlightBackgroundImage = [UIImage imageNamed:highlightBackgroundImageName];
    highlightBackgroundImage = [highlightBackgroundImage stretchableImageWithLeftCapWidth:highlightBackgroundImage.size.width/2 topCapHeight:highlightBackgroundImage.size.height/2];
    
    [button setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightBackgroundImage forState:UIControlStateHighlighted];
    
    if ([normalImageName length] > 0) {
        UIImage *normalImage = [UIImage imageNamed:normalImageName];
        normalImage = [normalImage stretchableImageWithLeftCapWidth:normalImage.size.width/2 topCapHeight:normalImage.size.height/2];
        [button setImage:normalImage forState:UIControlStateNormal];
    }
    
    if ([highlightImageName length] > 0) {
        UIImage *highlightImage = [UIImage imageNamed:highlightImageName];
        highlightImage = [highlightImage stretchableImageWithLeftCapWidth:highlightImage.size.width/2 topCapHeight:highlightImage.size.height/2];
        [button setImage:highlightImage forState:UIControlStateHighlighted];
    }
    
    [button sizeToFit];
    CGRect tmpFrame = button.frame;
    tmpFrame.size.width = width;
    button.frame = tmpFrame;
    
    return button;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
