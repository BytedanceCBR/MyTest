//
//  TTVPlayerStateResolution.h
//  Article
//
//  Created by panxiang on 2018/8/23.
//

#import <Foundation/Foundation.h>
#import "TTVideoEngineModelDef.h"


#define TTVPlayerActionTypeClickResolutionButton @"TTVPlayerActionTypeClickResolutionButton"
#define TTVPlayerActionTypeClickResolutionButtonKeyIsShowing @"isShowing"

#define TTVPlayerActionTypeSwitchResolution @"TTVPlayerActionTypeSwitchResolution"
#define TTVPlayerActionTypeSwitchResolutionKeyResolution @"resolution"
#define TTVPlayerActionTypeSwitchResolutionKeyAfterDegrade @"isAfterDegrade"

#define TTVPlayerActionTypeChangeResolution @"TTVPlayerActionTypeChangeResolution"
#define TTVPlayerActionTypeChangeResolutionKeyResolution @"resolution"

#define TTVPlayerActionTypeSwitchResolutionFinished @"TTVPlayerActionTypeSwitchResolutionFinished"
#define TTVPlayerActionTypeSwitchResolutionFinishedKeyisDegrading @"isDegrading"
#define TTVPlayerActionTypeSwitchResolutionFinishedKeyisSuccess @"success"
#define TTVPlayerActionTypeSwitchResolutionFinishedKeyResolution @"resolution"
#define TTVPlayerActionTypeSwitchResolutionFinishedKeyisBegin @"begin"



#define TTVResolutionManager_resolutionButton @"TTVResolutionManager_resolutionButton"

@interface TTVPlayerStateResolution : NSObject
@property (nonatomic ,assign ,readonly)BOOL realEnableResolution;
@property (nonatomic ,assign ,readonly)BOOL isShowing;
@property (nonatomic ,assign ,readonly)BOOL resolutionSwitching;
- (NSString *)titleForResolution:(TTVideoEngineResolutionType)resolution;

@end

