//
//  TTVDemandPlayerContext.h
//  Article
//
//  Created by panxiang on 2017/6/18.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"
@class TTVPlayerStateModel;
@interface TTVDemandPlayerContext : NSObject
- (void)setPlayerStateModel:(TTVPlayerStateModel *)state;
/**
 视频总播放时间
 */
@property (nonatomic, assign ,readonly) NSTimeInterval duration;

/**
 当前播放的时间
 */
@property (nonatomic, assign ,readonly) NSTimeInterval currentPlaybackTime;


/**
 总共播放时间
 */
@property(nonatomic, assign ,readonly) float totalWatchTime;

/**
 当前视频展示的tip类型
 */
@property(nonatomic, assign ,readonly)TTVPlayerControlTipViewType tipType;
@property (nonatomic, assign ,readonly) BOOL showVideoFirstFrame;
@property (nonatomic, assign ,readonly) TTVVideoPlaybackState playbackState;
@property (nonatomic, assign ,readonly) TTVPlayerLoadState loadState;
@property (nonatomic, assign ,readonly) BOOL isShowingTrafficAlert;
@property (nonatomic, assign ,readonly) BOOL inIndetail;
@property (nonatomic, assign ,readonly) BOOL isFullScreen;//是否是全屏
@property (nonatomic, assign ,readonly) BOOL isRotating;//视频正在旋转中
@property (nonatomic, assign ,readonly) BOOL hasEnterDetail;//曾经进入过视频详情页
@property(nonatomic, assign ,readonly) NSInteger playPercent;
@property(nonatomic, assign ,readonly) BOOL muted;
@end
