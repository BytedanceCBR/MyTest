//
//  FHVoteDetailViewModel.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/11/8.
//

#import <UIKit/UIKit.h>
#import "FHUGCBaseViewModel.h"
#import "FHCommentBaseDetailViewModel.h"
#import "FHPostDetailHeaderCell.h"

NS_ASSUME_NONNULL_BEGIN

// 投票详情页ViewModel
@interface FHVoteDetailViewModel : FHCommentBaseDetailViewModel

@property (nonatomic, assign) int64_t threadID;// 投票id
@property (nonatomic, assign) int64_t forumID; // 暂时无用
@property (nonatomic, copy) NSString *category;
@property (nonatomic, weak)   FHFeedUGCCellModel       *detailData;

@property (nonatomic, weak)     FHPostDetailHeaderModel       *detailHeaderModel;
@property (nonatomic, copy)     NSString       *lastPageSocialGroupId;

@end

NS_ASSUME_NONNULL_END
