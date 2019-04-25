//
//  TTADVideoMZTracker.h
//  Article
//
//  Created by rongyingjie on 2017/12/6.
//

#import <Foundation/Foundation.h>

@interface TTADVideoMZTracker : NSObject

@property (nonatomic, weak)   UIView* trackSDKView;
@property (nonatomic, assign) NSInteger timerId;

+ (instancetype)sharedManager;

- (void)mzTrackVideoUrls:(NSArray*)trackUrls adView:(UIView*)adView;

- (void)mzStopTrack;

@end
