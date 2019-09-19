//
//  FHHMDTManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define VIDEO_TTVPlayerController @"Video_TTVPlayerController"
#define VIDEO_FHVideoViewController @"Video_FHVideoViewController"
#define SHORT_VIDEO_AWEVideoPlayView @"Short_Video_AWEVideoPlayView"

@interface FHHMDTManager : NSObject

//视频开始播放时间
@property(nonatomic ,assign) NSTimeInterval videoCreateTime;
//小视频开始播放时间
@property(nonatomic ,assign) NSTimeInterval shortVideoCreateTime;

+ (instancetype)sharedInstance;
//视频首帧时长上报
- (void)videoFirstFrameReport:(NSString *)category;
//小视频首帧时长上报
- (void)shortVideoFirstFrameReport:(NSString *)category;

@end

NS_ASSUME_NONNULL_END
