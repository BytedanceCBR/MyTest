//
//  VideoRepinButton.m
//  Video
//
//  Created by 于 天航 on 12-8-3.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoRepinButton.h"
#import "UIColorAdditions.h"

#define DetailUnitActionButtonTitleColor SSUIStringNoDefault(@"vuDetailUnitActionButtonTitleColor")
#define DownloadButtonLargeFontSize SSUIFloatNoDefault(@"vuDownloadButtonLargeFontSize")
#define DownloadButtonMiddleFontSize SSUIFloatNoDefault(@"vuDownloadButtonMiddleFontSize")

@implementation VideoRepinButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:@"收藏" forState:UIControlStateNormal];
        [self setTitle:@"已收藏" forState:UIControlStateSelected];
        
        UIImage *normalBackgroundImage = [UIImage imageNamed:@"btn_blue_video.png"];
        normalBackgroundImage = [normalBackgroundImage stretchableImageWithLeftCapWidth:floorf(normalBackgroundImage.size.width/2)
                                                                           topCapHeight:floorf(normalBackgroundImage.size.height/2)];
        
        UIImage *highlightBackgroundImage = [UIImage imageNamed:@"btn_blue_press_video.png"];
        highlightBackgroundImage = [highlightBackgroundImage stretchableImageWithLeftCapWidth:floorf(highlightBackgroundImage.size.width/2)
                                                                                 topCapHeight:floorf(highlightBackgroundImage.size.height/2)];
        
//        UIImage *selectedBackgroundImage = [UIImage imageNamed:@"download_video.png"];
//        selectedBackgroundImage = [selectedBackgroundImage stretchableImageWithLeftCapWidth:floorf(selectedBackgroundImage.size.width/2)
//                                                                               topCapHeight:floorf(selectedBackgroundImage.size.height/2)];
        
        [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightBackgroundImage forState:UIControlStateHighlighted];
//        [self setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected];
        
        [self setTitleColor:[UIColor colorWithHexString:DetailUnitActionButtonTitleColor] forState:UIControlStateNormal];
    }
    return self;
}

- (void)refreshUI
{
    if (self.selected) {
        self.titleLabel.font = ChineseFontWithSize(DownloadButtonMiddleFontSize);
    }
    else {
        self.titleLabel.font = ChineseFontWithSize(DownloadButtonLargeFontSize);
    }
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
