//
//  TTVPlayerStateRetry.h
//  Article
//
//  Created by panxiang on 2018/8/30.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTVPlayerGestureDirection) {
    TTVPlayerGestureDirectionUnknown = 0,
    TTVPlayerGestureDirectionVertical = 1 << 0,
    TTVPlayerGestureDirectionHorizontal = 1 << 1,
    TTVPlayerGestureDirectionAll = TTVPlayerGestureDirectionHorizontal | TTVPlayerGestureDirectionVertical
};

#define TTVGestureManagerActionTypeSeekingToProgress @"TTVGestureManagerActionTypeSeekingToProgress" //(CGFloat fromProgress,CGFloat currentProgress)
#define TTVGestureManagerActionTypeVolumeDidChanged @"TTVGestureManagerActionTypeVolumeDidChanged" //(CGFloat volume ,BOOL isSystemVolumeButton)
#define TTVGestureManagerActionTypeDoubleTapClick @"TTVGestureManagerActionTypeDoubleTapClick"
#define TTVGestureManagerActionTypeSingleTapClick @"TTVGestureManagerActionTypeSingleTapClick" //void(^controlShowingBySingleTap)(void)
#define TTVGestureManagerActionTypeChangeVolumeClick @"TTVGestureManagerActionTypeChangeVolumeClick"//(BOOL panStateChanged)
#define TTVGestureManagerActionTypeChangeBrightnessClick @"TTVGestureManagerActionTypeChangeBrightnessClick"//(BOOL panStateChanged)
#define TTVGestureManagerActionTypeProgressViewShow @"TTVGestureManagerActionTypeProgressViewShow"//(BOOL show)

#define TTVGestureManagerActionTypeVolumeDidChanged @"TTVGestureManagerActionTypeVolumeDidChanged"//(CGFloat volume, BOOL isSystemVolumeButton)
#define TTVGestureManagerActionTypeSwipeProgressSeeking @"TTVGestureManagerActionTypeSwipeProgressSeeking"//(CGFloat fromProgress, CGFloat currentProgress)
@interface TTVPlayerStateGesture : NSObject
@property (nonatomic, assign, readonly) BOOL isDragging;

@end
