//
//  FHDemanderTrackerManager.h
//  Article
//
//  Created by 张静 on 2018/9/19.
//

#import "TTVDemanderTrackerManager.h"
@class TTVPlayerStateStore;

@interface FHDemanderTrackerManager : TTVDemanderTrackerManager

@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;

@end
