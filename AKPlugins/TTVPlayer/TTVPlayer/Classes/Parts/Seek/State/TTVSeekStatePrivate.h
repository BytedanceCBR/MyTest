//
//  TTVSeekStatePrivate.h
//  TTVPlayerPod
//
//  Created by panxiang on 2019/2/20.
//

#import "TTVSeekState.h"

@interface TTVSeekState()

@property (nonatomic, getter=isPanningOutOfSlider) BOOL panningOutOfSlider; // 是否有进度的滑动操作
@property (nonatomic) TTVPanSeekInfo panSeekingOutOfSliderInfo;    // 如果上面的panAndSeekingOutOfSlider == YES 或者 panOutOfSlider == YES，那么再去看 panSeekingOutOfSliderInfo 具体的值，来进行操作 ，当 panAndSeekingOutOfSlider 第一次从 YES 变为 NO 的时候，看 Info 里面那俩 bool 来看是怎么结束的
@property (nonatomic, getter=isSliderPanning) BOOL sliderPanning;
@property (nonatomic, getter=isHudShowed) BOOL hudShowed;           // hud正在展示中

@end

