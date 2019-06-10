//
//  TTVPlayerStateFullScreen.h
//  Article
//
//  Created by panxiang on 2018/8/23.
//

#import <Foundation/Foundation.h>

#define TTVPlayerActionTypeRotatePlayer @"TTVPlayerActionTypeRotatePlayer"
#define TTVFullScreenManager_fullButton @"TTVFullScreenManager_fullButton"
#define TTVFullScreenManager_fullbackButton @"TTVFullScreenManager_fullbackButton"

@interface TTVPlayerStateFullScreen : NSObject
@property (nonatomic ,assign ,readonly) BOOL enableFullScreen;
@property (nonatomic ,assign ,readonly) BOOL supportsPortaitFullScreen;
@property (nonatomic ,assign ,readonly) BOOL isFullScreen;
@property (nonatomic ,assign ,readonly) BOOL isTransitioning;
@end

