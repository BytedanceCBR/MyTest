//
//  TTVSeekState.h
//  TTVPlayer
//
//  Created by lisa on 2019/1/29.
//

#import <Foundation/Foundation.h>
#import "TTVReduxProtocol.h"


NS_ASSUME_NONNULL_BEGIN


struct TTVPanSeekInfo {
    CGFloat progress;               // seek 后的进度
    CGFloat fromProgress;           // 从哪个 seek 来的
    BOOL    isCancelledOutArea;     // 超出范围取消手势
    BOOL    isMovingForward;        // 是向前进度还是向后进度
    BOOL    isSwipeGesture;         // 识别为 swipe
    UIGestureRecognizerState gestureState; //
};

typedef struct TTVPanSeekInfo TTVPanSeekInfo;

@interface TTVSeekState : NSObject<TTVReduxStateProtocol, NSCopying>

@property (nonatomic, readonly, getter=isPanningOutOfSlider) BOOL panningOutOfSlider; // 是否有进度的在进度条外滑动操作
@property (nonatomic, readonly) TTVPanSeekInfo panSeekingOutOfSliderInfo;    // 如果上面的panAndSeekingOutOfSlider == YES 或者 panOutOfSlider == YES，那么再去看 panSeekingOutOfSliderInfo 具体的值，来进行操作 ，当 panAndSeekingOutOfSlider 第一次从 YES 变为 NO 的时候，看 Info 里面那俩 bool 来看是怎么结束的
@property (nonatomic, readonly, getter=isSliderPanning) BOOL sliderPanning;  // 在控件拖动滑动
@property (nonatomic, readonly, getter=isHudShowed) BOOL hudShowed;          // hud正在展示中



@end

NS_ASSUME_NONNULL_END
