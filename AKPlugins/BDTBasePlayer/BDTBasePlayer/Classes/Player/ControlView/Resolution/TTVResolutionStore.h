//
//  TTVResolutionStore.h
//  Article
//
//  Created by panxiang on 2017/5/25.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"

@interface TTVResolutionStore : NSObject
+ (TTVResolutionStore *)sharedInstance;
@property (nonatomic, assign) TTVPlayerResolutionType lastResolution;//最后一次旋转的要播放的清晰度,包括用户选择的和自动选择的.
@property (nonatomic, assign) BOOL userSelected; // 是否用户手动选择过；
@property (nonatomic, assign) BOOL forceSelected;//4g下 强制切换
@property (nonatomic, assign) BOOL resolutionAlertClick;//网络差,用户点击了立即切换按钮
@property (nonatomic, assign) TTVPlayerResolutionType autoResolution;//默认自动选择的清晰度

@property (nonatomic ,assign)TTVPlayerResolutionType actual_clarity;//最近一次实际播放的清晰度
@property (nonatomic ,assign)NSInteger clarity_change_time;//最近一次改变实际清晰度的时机（0-100）,记录用户播放该视频到百分之多少时，清晰度发生了改变，0表示用户没有调整过清晰度。
- (void)reset;//每次点击播放的时候设置初始状态
- (NSString *)lastDefinationStr;
- (NSString *)actualDefinationtr;
- (NSString *)stringWithDefination:(TTVPlayerResolutionType)defination;

@end

