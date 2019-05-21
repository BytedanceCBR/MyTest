//
//  TTADVideoMZTracker.m
//  Article
//
//  Created by rongyingjie on 2017/12/6.
//

#import "TTADVideoMZTracker.h"
#import "MZMonitor.h"
#import "SSCommonLogic.h"
#import <TTBaseLib/TTBaseMacro.h>

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
}

- (void)mzStopTrack
{
}


@end
