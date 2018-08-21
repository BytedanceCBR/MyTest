//
//  TTRNLiveViewManager.m
//  Article
//
//  Created by yin on 2017/2/15.
//
//

#import "TTRNLiveViewManager.h"
#import "TTRNLiveView.h"

@implementation TTRNLiveViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    TTRNLiveView *liveView = [[TTRNLiveView alloc] init];
    return liveView;
}

RCT_EXPORT_VIEW_PROPERTY(cover, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(live_id, NSString)
RCT_EXPORT_VIEW_PROPERTY(muted, BOOL)
RCT_EXPORT_VIEW_PROPERTY(play, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(videoPosition, NSInteger)

@end
