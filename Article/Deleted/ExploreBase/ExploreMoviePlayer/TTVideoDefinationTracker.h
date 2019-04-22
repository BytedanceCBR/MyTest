//
//  TTVideoDefinationTracker.h
//  Article
//
//  Created by panxiang on 2017/3/16.
//
//
#import <Foundation/Foundation.h>
#import "ExploreVideoSP.h"

@interface TTVideoDefinationTracker : NSObject
+ (TTVideoDefinationTracker *)sharedTTVideoDefinationTracker;
@property (nonatomic ,assign ,readonly)NSInteger definationNumber;//可选的清晰度种类
@property (nonatomic ,assign)ExploreVideoDefinitionType lastDefination;//最近一次用户选择的清晰度
@property (nonatomic ,assign)ExploreVideoDefinitionType actual_clarity;//最近一次实际播放的清晰度
@property (nonatomic ,assign)NSInteger clarity_change_time;//最近一次改变实际清晰度的时机（0-100）,记录用户播放该视频到百分之多少时，清晰度发生了改变，0表示用户没有调整过清晰度。
- (void)definationNumber:(NSInteger)definationNumber;
- (void)reset;//每次点击播放的时候设置初始状态
- (NSString *)lastDefinationStr;
- (NSString *)actualDefinationtr;
@end
