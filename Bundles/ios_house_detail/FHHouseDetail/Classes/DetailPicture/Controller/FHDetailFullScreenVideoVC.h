//
//  FHDetailFullScreenVideoVC.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/24.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "TTPhotoScrollViewController.h"
#import "FHDetailMediaHeaderCell.h"
#import "FHShowVideoView.h"

NS_ASSUME_NONNULL_BEGIN

// 视频全屏播放器
@interface FHDetailFullScreenVideoVC : FHBaseViewController

@property (nonatomic, strong)   FHShowVideoView       *videoView;

- (void)presentVideoViewWithDismissBlock:(dispatch_block_t)block;
- (void)dismissVC;

@end

NS_ASSUME_NONNULL_END
