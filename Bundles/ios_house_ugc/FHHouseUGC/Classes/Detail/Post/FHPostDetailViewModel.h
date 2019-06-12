//
//  FHPostDetailViewModel.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import <Foundation/Foundation.h>
#import "FHUGCBaseViewModel.h"
#import "FHCommentDetailViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPostDetailViewModel : FHCommentDetailViewModel

@property (nonatomic, assign) int64_t threadID;
@property (nonatomic, assign) int64_t forumID;
@property (nonatomic, copy) NSString *category;

@end

NS_ASSUME_NONNULL_END
