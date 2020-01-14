//
//  FHUGCCommentListViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import <Foundation/Foundation.h>
#import "FHCommunityFeedListBaseViewModel.h"
#import "FHUGCCommentListController.h"
#import "TTHttpTask.h"
#import "FHUGCCellManager.h"
#import <FHCommonUI/FHRefreshCustomFooter.h>
#import "FHUGCBaseCell.h"
#import "FHFeedUGCCellModel.h"
#import "FHFeedListModel.h"
#import "FHUGCConfig.h"
#import "FHUserTracker.h"
#import "TSVShortVideoDetailExitManager.h"
#import "HTSVideoPageParamHeader.h"
#import "AWEVideoConstants.h"
#import "TTVFeedListItem.h"
#import <TTReachability.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCommentListViewModel : FHCommunityFeedListBaseViewModel

@property(nonatomic, copy) NSString *socialGroupId;

@end

NS_ASSUME_NONNULL_END
