//
//  TTVPlayerStatePlay.h
//  Article
//
//  Created by panxiang on 2018/8/30.
//

#import <Foundation/Foundation.h>

@class RACSignal;

typedef NS_ENUM(NSUInteger, TTVPlayTriggerActionType) {
    //小屏按钮
    TTVPlayTriggerActionTypePlayerButton = 0,
    //小屏双击
    TTVPlayTriggerActionTypePlayerDoubleClick,
    //全屏按钮
    TTVPlayTriggerActionTypeFullPlayerButton,
    //全屏双击
    TTVPlayTriggerActionTypeFullPlayerDoubleClick,
    //系统引发
    TTVPlayTriggerActionTypeSystem
};

typedef NS_ENUM(NSUInteger, TTVPlayerControlsCanDisableLocation) {
    TTVPlayerControlsCanDisableLocation_CenterPlay        =  1 << 0,
    TTVPlayerControlsCanDisableLocation_ProgressHub       =  1 << 1
};

#define TTVPlayerStatePlay_fullPlayButton @"TTVPlayerStatePlay_fullPlayButton"
#define TTVPlayerStatePlay_fullPlayPreviousButton @"TTVPlayerStatePlay_fullPlayPreviousButton"
#define TTVPlayerStatePlay_fullPlayNextButton @"TTVPlayerStatePlay_fullPlayNextButton"

@interface TTVPlayerStatePlay : NSObject
@property (nonatomic, assign ,readonly) BOOL changePlayStatusByTapWidget;//使用控件进行播放暂停（双击，点击播放按钮操作）（埋点需要）
@property (nonatomic, assign ,readonly) TTVPlayTriggerActionType triggerActionType;
@property (nonatomic, assign ,readonly) BOOL playControlsDisabled;
@property (nonatomic, assign ,readonly) TTVPlayerControlsCanDisableLocation location;
@property (nonatomic, assign ,readonly) BOOL showPlayButton;
@property (nonatomic, assign ,readonly) BOOL isIndetail;

//点击事件
@property (nonatomic, strong ,readonly) RACSignal *clickedPlayNextButtonSignal;
@property (nonatomic, strong ,readonly) RACSignal *clickedPlayPreviousButtonSignal;
@end

