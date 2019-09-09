//
//  FHUGCVideoCell.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/5.
//

#import "FHUGCBaseCell.h"
#import <TTVFeedListItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVideoCell : FHUGCBaseCell

@property(nonatomic ,strong) TTVFeedListItem *videoItem;

- (void)willDisplay;

- (void)endDisplay;

@end

NS_ASSUME_NONNULL_END
