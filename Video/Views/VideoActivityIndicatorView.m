//
//  VideoActivityIndicatorView.m
//  Video
//
//  Created by 于 天航 on 12-8-16.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoActivityIndicatorView.h"

@implementation VideoActivityIndicatorView

static VideoActivityIndicatorView *_sharedView = nil;

+ (VideoActivityIndicatorView *)sharedView
{
    @synchronized(self) {
        if (_sharedView == nil) {
            _sharedView = [[VideoActivityIndicatorView alloc] init];
        }
    }
    return _sharedView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat indicatorWidth = 93.f;
        CGFloat indicatorHeight = 80.f;
        CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
        
        self.messageLabel.font = ChineseFontWithSize(14.f);
        self.messageEdgeInsets = SSEdgeInsetsMake(-5, 0);
        self.visibleFrame = CGRectMake((applicationFrame.size.width - indicatorWidth)/2,
                                       (applicationFrame.size.height - indicatorHeight)/2,
                                       indicatorWidth,
                                       indicatorHeight);
        self.hideType = SSActivityIndicatorViewHideTypeAutoHideClickDisabled;
        self.displayDuration = 4.f;
    }
    return self;
}

- (void)showWithMessage:(NSString *)message duration:(CGFloat)displayDuration
{
    [self showInRect:self.visibleFrame message:message image:nil duration:displayDuration hideType:self.hideType];
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
