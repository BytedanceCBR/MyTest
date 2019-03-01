//
//  TTVDemanderPlayerTracker.h
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import "TTVPlayerTracker.h"

@interface TTVDemanderPlayerTracker : TTVPlayerTracker
/**
 是否是自动播放
 为了过滤自动播放统计对推荐的影响，只有没有用户主动操作过的自动播放，isAutoPlaying 才为 YES，不发正常的统计。（只做统计用）
 */
- (void)sendEndTrack;
@end
