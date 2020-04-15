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

// 专题页
@interface FHSpecialTopicViewController : FHBaseViewController

@property (nonatomic, copy) NSString *forumId;
@property (nonatomic, copy) NSString *tabName;
@property (nonatomic, strong) FHSpecialTopicHeaderView *headerView;
@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) FHCommunityDetailSegmentView *segmentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *titleContainer;
@property (nonatomic, strong) UIButton *shareButton;// 分享
@property(nonatomic, strong) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END