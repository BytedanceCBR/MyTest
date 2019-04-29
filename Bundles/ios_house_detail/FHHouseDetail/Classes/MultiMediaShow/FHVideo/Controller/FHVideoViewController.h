//
//  FHVideoViewController.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import <UIKit/UIKit.h>
#import "FHVideoModel.h"
#import "TTVPlayerKitHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHVideoViewControllerDelegate <NSObject>

//播放状态改变
- (void)playbackStateDidChanged:(TTVPlaybackState)playbackState;
//弹出流量提示时调用
- (void)playerDidPauseByCellularNet;


@end

@interface FHVideoViewController : UIViewController

@property(nonatomic , weak) id<FHVideoViewControllerDelegate> delegate;

@property(nonatomic, strong) FHVideoModel *model;

@property (nonatomic, assign, readonly) NSTimeInterval currentPlaybackTime;

@property (nonatomic, assign, readonly) TTVPlaybackState playbackState;

@property (nonatomic, assign) CGFloat videoWidth;

@property (nonatomic, assign) CGFloat videoHeight;

@property (nonatomic, assign)   CGRect videoFrame;
//是否正在显示流量提示view
@property (nonatomic, assign)   BOOL isShowingNetFlow;

- (void)updateData:(FHVideoModel *)model;

- (void)play;

- (void)pause;

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime complete:(void(^)(BOOL success))finised;

@end

NS_ASSUME_NONNULL_END
