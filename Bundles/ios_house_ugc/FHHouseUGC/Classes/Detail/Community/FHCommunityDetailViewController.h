//
//  FHCommunityDetailViewController.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "UIViewAdditions.h"

@class FHCommunityFeedListController;

NS_ASSUME_NONNULL_BEGIN

// 圈子详情页
@interface FHCommunityDetailViewController : FHBaseViewController

@property(nonatomic, copy) NSString *communityId;

@end

NS_ASSUME_NONNULL_END
