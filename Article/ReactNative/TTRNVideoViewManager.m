//
//  TTRNVideoViewManager.m
//  Article
//
//  Created by yin on 2016/12/29.
//
//

#import "TTRNVideoViewManager.h"
#import "TTRNVideoView.h"

@implementation TTRNVideoViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    TTRNVideoView *videoView = [[TTRNVideoView alloc] init];
    return videoView;
}

RCT_EXPORT_VIEW_PROPERTY(cover,NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(video_id, NSString)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(play, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(videoPosition, NSInteger)

@end
