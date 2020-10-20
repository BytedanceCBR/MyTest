//
//  FHShortVideoPerLoaderManager.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/10/20.
//

#import <Foundation/Foundation.h>
#import "TTVideoEngine+Preload.h"
#import "FHShortVideoDetailFetchManager.h"
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHShortVideoPerLoaderManager : NSObject
+ (void)preloadWithVideoModel:(FHFeedUGCCellModel *)videoDetail;
+ (void)startPrefetchShortVideoInDetailWithDataFetchManager:(FHShortVideoDetailFetchManager *)manager;
@end

NS_ASSUME_NONNULL_END
