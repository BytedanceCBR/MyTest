//
//  VideoSocialActionButton.m
//  Video
//
//  Created by 于 天航 on 12-8-2.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoSocialActionButton.h"
#import "UIColorAdditions.h"

#define DetailUnitActionButtonTitleColor SSUIStringNoDefault(@"vuDetailUnitActionButtonTitleColor")
#define DetailUnitActionButtonTitleFontSize SSUIFloatNoDefault(@"vuDetailUnitActionButtonTitleFontSize")
#define DetailUnitActionButtonCountFontSize SSUIFloatNoDefault(@"vuDetailUnitActionButtonCountFontSize")
#define DownloadButtonLargeFontSize SSUIFloatNoDefault(@"vuDownloadButtonLargeFontSize")
#define DownloadButtonMiddleFontSize SSUIFloatNoDefault(@"vuDownloadButtonMiddleFontSize")

@interface VideoSocialActionButton ()

@property (nonatomic, retain) UILabel *subtitleLabel;

@end

@implementation VideoSocialActionButton

@synthesize subtitleLabel = _subtitleLabel;

- (void)dealloc
{
    self.subtitleLabel = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    	UIImage *normalBackgroundImage = [UIImage imageNamed:@"btn_blue_video.png"];
        normalBackgroundImage = [normalBackgroundImage stretchableImageWithLeftCapWidth:floorf(normalBackgroundImage.size.width/2)
                                                                           topCapHeight:floorf(normalBackgroundImage.size.height/2)];
        
        UIImage *highlightBackgroundImage = [UIImage imageNamed:@"btn_blue_press_video.png"];
        highlightBackgroundImage = [highlightBackgroundImage stretchableImageWithLeftCapWidth:floorf(highlightBackgroundImage.size.width/2) 
                                                                                 topCapHeight:floorf(highlightBackgroundImage.size.height/2)];
        
        UIImage *disabledBackgroundImage = [UIImage imageNamed:@"download_video.png"];
        disabledBackgroundImage = [disabledBackgroundImage stretchableImageWithLeftCapWidth:floorf(disabledBackgroundImage.size.width/2)
                                                                                 topCapHeight:floorf(disabledBackgroundImage.size.height/2)];

        [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightBackgroundImage forState:UIControlStateHighlighted];
        [self setBackgroundImage:disabledBackgroundImage forState:UIControlStateDisabled];
        [self setTitleColor:[UIColor colorWithHexString:DetailUnitActionButtonTitleColor] forState:UIControlStateNormal];
        
        self.subtitleLabel = [[[UILabel alloc] init] autorelease];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textColor = [UIColor colorWithHexString:DetailUnitActionButtonTitleColor];
        _subtitleLabel.font = ChineseFontWithSize(DetailUnitActionButtonCountFontSize);
        [self addSubview:_subtitleLabel];
    }
    return self;
}

#pragma mark - public

- (void)setSubtitle:(NSString *)subTitle
{
    _subtitleLabel.text = subTitle;
    [_subtitleLabel sizeToFit];
    
    CGPoint tmpCenter = _subtitleLabel.center;
    tmpCenter.x = self.bounds.size.width/2;
    tmpCenter.y = self.bounds.size.height - _subtitleLabel.bounds.size.height/2 - 2.f;
    _subtitleLabel.center = tmpCenter;
}

- (void)refreshUI
{
    if (_subtitleLabel.text) {
        
        self.titleLabel.font = ChineseFontWithSize(DetailUnitActionButtonTitleFontSize);
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 9, 0)];
        
        CGPoint tmpCenter = _subtitleLabel.center;
        tmpCenter.x = self.bounds.size.width/2;
        tmpCenter.y = self.bounds.size.height - _subtitleLabel.bounds.size.height/2 - 2.f;
        _subtitleLabel.center = tmpCenter;
    }
    else {
        if ([self.titleLabel.text length] > 2) {
            self.titleLabel.font = ChineseFontWithSize(DownloadButtonMiddleFontSize);
        }
        else {
            self.titleLabel.font = ChineseFontWithSize(DownloadButtonLargeFontSize);
        }
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

#pragma mark - private

- (void)statusClean
{
    self.highlighted = NO;
    self.selected = NO;
    self.enabled = YES;
}

- (void)statusUnHightlightDisable
{
    [self statusClean];
    self.enabled = NO;
}

- (void)statusHightlightDisable
{
    [self statusClean];
    self.enabled = NO;
    self.highlighted = YES;
}

#pragma mark - public

- (void)setSocialActionButtonStatus:(SocialActionButtonStatus)status
{
    switch (status) {
        case SocialActionButtonStatusClean:
            [self statusClean];
            break;
        case SocialActionButtonStatusHightlightedDisabled:
            [self statusHightlightDisable];
            break;
        case SocialActionButtonStatusUnHightlightedDisabled:
            [self statusUnHightlightDisable];
            break;
        case SocialActionButtonStatusSelectedDisable:
        case SocialActionButtonStatusUnSelectedDisable:
            break;
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
