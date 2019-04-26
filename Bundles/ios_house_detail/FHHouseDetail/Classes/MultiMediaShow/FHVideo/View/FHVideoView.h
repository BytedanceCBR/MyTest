//
//  FHVideoView.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/12.
//

#import <UIKit/UIKit.h>
#import "FHVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoView : UIView

- (void)updateData:(FHVideoModel *)model;

- (void)play;

- (void)pause;
//刷新迷你播放进度条
- (void)refreshMiniSlider;

@end

NS_ASSUME_NONNULL_END
