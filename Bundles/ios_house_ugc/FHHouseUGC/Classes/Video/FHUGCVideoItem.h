//
//  FHUGCVideoItem.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/9/8.
//

#import "TTVFeedListItem.h"
#import "FHFeedContentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVideoItem : TTVFeedListItem

@property (nonatomic, strong , nullable) FHFeedContentModel *ugcFeedContent;

@end

NS_ASSUME_NONNULL_END
