//
//  TTVideoTabLiveCellView.m
//  Article
//
//  Created by xuzichao on 16/5/25.
//
//

#import "TTVideoTabLiveCellView.h"

@interface TTVideoTabLiveCellView ()



@end

@implementation TTVideoTabLiveCellView

- (void)refreshUI
{
    [super refreshUI];

    self.videoRightBottomLabel.contentInset = UIEdgeInsetsMake(0,3, 0, 0);
    self.redDot.hidden = NO;
    self.redDot.frame = CGRectMake(6, self.videoRightBottomLabel.height/2 - 3, 6, 6);
}

- (void)refreshWithData:(id)data
{
    self.actionBar.schemeType = TTVideoCellActionBarLayoutSchemeLive;
    
    [super refreshWithData:data];
    
    self.playButton.imageName = @"live_video_icon";
    self.videoRightBottomLabel.text = @"直播";

}

@end
