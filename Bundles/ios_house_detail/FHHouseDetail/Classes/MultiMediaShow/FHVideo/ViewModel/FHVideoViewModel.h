//
//  FHVideoViewModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/4/16.
//

#import <Foundation/Foundation.h>
#import "FHVideoView.h"
#import "FHVideoViewController.h"
#import "TTVPlayerKitHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHVideoViewModel : NSObject

- (instancetype)initWithView:(FHVideoView *)view controller:(FHVideoViewController *)viewController player:(TTVPlayer *)player;

- (void)didFinishedWithStatus:(TTVPlayFinishStatus *)finishStatus;

- (void)hideCoverView;

- (void)showCoverViewStartBtn;

@end

NS_ASSUME_NONNULL_END
