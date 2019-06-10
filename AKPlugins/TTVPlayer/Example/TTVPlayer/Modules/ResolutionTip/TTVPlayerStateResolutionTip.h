//
//  TTVPlayerStateResolutionTip.h
//  Article
//
//  Created by panxiang on 2018/8/23.
//

#import <Foundation/Foundation.h>


#define TTVPlayerActionTypeClickResolutionDegrade @"TTVPlayerActionTypeClickResolutionDegrade"
#define TTVPlayerActionTypeClickResolutionDegradeKeyResolutionType @"resolution_type"
#define TTVPlayerActionTypeClickResolutionDegradeKeyResolutionTypeBefore @"resolution_type_before_degrade"

#define TTVPlayerActionTypeCloseResolutionDegrade @"TTVPlayerActionTypeCloseResolutionDegrade"
#define TTVPlayerActionTypeShowResolutionDegrade @"TTVPlayerActionTypeShowResolutionDegrade"
#define TTVPlayerActionTypeShowResolutionDegradeKeyCurrentResolution @"current_resolution"


@interface TTVPlayerStateResolutionTip : NSObject
@property (nonatomic ,assign ,readonly)BOOL realEnableResolution;
@property (nonatomic ,assign ,readonly)BOOL showingResolutionTip;
@end

