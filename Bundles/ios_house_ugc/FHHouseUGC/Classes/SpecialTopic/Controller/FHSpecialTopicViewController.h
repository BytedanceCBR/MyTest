//
//  FHSpecialTopicViewController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/20.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "UIViewAdditions.h"
#import "FHSpecialTopicHeaderView.h"
#import "FHCommunityDetailSegmentView.h"
#import "TTHorizontalPagingView.h"

@class FHSpecialTopicViewController;

NS_ASSUME_NONNULL_BEGIN

// 圈子详情页
@interface FHSpecialTopicViewController : FHBaseViewController

@property (nonatomic, copy) NSString *communityId;
@property (nonatomic, copy) NSString *tabName;
@property (nonatomic, strong) FHSpecialTopicHeaderView *headerView;
@property (nonatomic, strong) FHCommunityDetailSegmentView *segmentView;
@property (nonatomic, strong) FHUGCFollowButton *rightBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIView *titleContainer;

@property(nonatomic, strong) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
