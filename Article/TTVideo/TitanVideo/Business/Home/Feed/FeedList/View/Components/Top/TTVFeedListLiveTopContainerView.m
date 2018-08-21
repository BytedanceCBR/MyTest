//
//  TTVFeedListLiveTopContainerView.m
//  Article
//
//  Created by pei yun on 2017/4/20.
//
//

#import "TTVFeedListLiveTopContainerView.h"


@interface TTVFeedListLiveTopContainerView ()

@property(nonatomic, strong)SSThemedView *redDot; //红点

@end

@implementation TTVFeedListLiveTopContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageContainerView.videoRightBottomLabel.contentInset = UIEdgeInsetsMake(0,3, 0, 0);
        self.redDot = [[SSThemedView alloc] initWithFrame:CGRectMake(6, 0, 6, 6)];
        self.redDot.backgroundColorThemeKey = kColorText4;
        self.redDot.layer.cornerRadius = 3;
        [self.imageContainerView.videoRightBottomLabel addSubview:self.redDot];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.redDot.top = self.imageContainerView.videoRightBottomLabel.height / 2 - 3;
    self.imageContainerView.playButton.imageName = @"live_video_icon";
    self.imageContainerView.videoRightBottomLabel.text = @"直播";
}

@end
