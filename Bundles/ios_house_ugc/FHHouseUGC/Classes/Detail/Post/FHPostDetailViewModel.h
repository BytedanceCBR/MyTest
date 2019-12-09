//
//  FHPostDetailViewModel.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHUGCBaseViewModel.h"
#import "FHCommentBaseDetailViewModel.h"
#import "FHPostDetailHeaderCell.h"

NS_ASSUME_NONNULL_BEGIN

// 帖子详情ViewModel
@interface FHPostDetailViewModel : FHCommentBaseDetailViewModel

@property (nonatomic, assign) int64_t threadID;// 帖子id
@property (nonatomic, assign) int64_t forumID; // 暂时无用
@property (nonatomic, copy) NSString *category;
@property (nonatomic, weak)   FHFeedUGCCellModel       *detailData;

@property (nonatomic, weak)     FHPostDetailHeaderModel       *detailHeaderModel;
@property (nonatomic, copy)     NSString       *lastPageSocialGroupId;
@property (nonatomic, weak)     UIButton       *weakShareButton;

@end

NS_ASSUME_NONNULL_END
