//
//  TTVPlayerStatePlay.h
//  Article
//
//  Created by panxiang on 2018/8/30.
//

#import <Foundation/Foundation.h>
#import "TTVPlayerStatePlay.h"

@interface TTVPlayerStatePlay()
@property (nonatomic, assign) BOOL changePlayStatusByTapWidget;//使用控件进行播放暂停（双击，点击播放按钮操作）（埋点需要）
@property (nonatomic, assign) TTVPlayTriggerActionType triggerActionType;
@property (nonatomic, assign) BOOL playControlsDisabled;
@property (nonatomic, assign) TTVPlayerControlsCanDisableLocation location;
@property (nonatomic, assign) BOOL showPlayButton;//显示play 还是 pause button
@property (nonatomic, assign) BOOL isIndetail;
//点击事件
@property (nonatomic, strong) RACSignal *clickedPlayNextButtonSignal;
@property (nonatomic, strong) RACSignal *clickedPlayPreviousButtonSignal;
@end


