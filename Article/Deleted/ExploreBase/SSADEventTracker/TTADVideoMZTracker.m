//
//  TTADVideoMZTracker.m
//  Article
//
//  Created by rongyingjie on 2017/12/6.
//

#import "TTADVideoMZTracker.h"
#import "MZMonitor.h"

@interface TTADVideoMZTracker ()

@end

@implementation TTADVideoMZTracker

+ (instancetype)sharedManager
{
    static TTADVideoMZTracker *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TTADVideoMZTracker alloc] init];
    });
    return sharedManager;
}

- (void)mzTrackVideoUrls:(NSArray*)trackUrls adView:(UIView*)adView
{
    if ([SSCommonLogic isMZSDKEnable]) {
        UIView* superView = adView.superview;
        while (superView) {
            if ([superView isKindOfClass:NSClassFromString(@"TTLayOutCellViewBase")]) {
                self.trackSDKView = superView;
                break;
            }
            superView = superView.superview;
        }
        if (self.trackSDKView) {
            if (!SSIsEmptyArray(trackUrls)) {
                self.timerId = [MZMonitor adTrackVideo:trackUrls.firstObject adView:self.trackSDKView];
                
            }
        }        
    }
}

- (void)mzStopTrack
{
    if ([SSCommonLogic isMZSDKEnable]) {
        if (self.trackSDKView) {
            [MZMonitor adTrackStop:self.timerId];
            [MZMonitor retryCachedRequests];
        }
        self.trackSDKView = nil;
    }
}


@end
