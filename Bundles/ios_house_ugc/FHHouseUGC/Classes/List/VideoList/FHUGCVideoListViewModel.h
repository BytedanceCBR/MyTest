//
//  FHUGCVideoListViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/11.
//

#import "FHCommunityFeedListBaseViewModel.h"
#import "FHUGCVideoListController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVideoListViewModel : FHCommunityFeedListBaseViewModel

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHUGCVideoListController *)viewController;

- (void)autoPlayCurrentVideo;

- (void)stopCurrentVideo;

- (void)pauseCurrentVideo;

- (void)readyCurrentVideo;

- (void)startVideoPlay;

@property(nonatomic, weak) FHUGCVideoListController *viewController;

@end

NS_ASSUME_NONNULL_END
