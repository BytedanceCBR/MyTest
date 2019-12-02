//
//  FHCommunityDetailViewController.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "UIViewAdditions.h"
#import "FHCommunityDetailHeaderView.h"
#import "FHCommunityDetailSegmentView.h"
#import "TTHorizontalPagingView.h"
#import "TTBadgeNumberView.h"

@class FHCommunityFeedListController;

NS_ASSUME_NONNULL_BEGIN

// 圈子详情页
@interface FHCommunityDetailViewController : FHBaseViewController

@property(nonatomic, copy) NSString *communityId;
@property(nonatomic, strong) FHCommunityDetailHeaderView *headerView;
@property(nonatomic, strong) FHCommunityDetailSegmentView *segmentView;
@property(nonatomic, strong) FHUGCFollowButton *rightBtn;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;
@property(nonatomic, strong) UIView *titleContainer;
//发布按钮
@property (nonatomic, strong) UIButton *publishBtn;
//群聊按钮
@property(nonatomic, strong) UIButton *groupChatBtn;
//群聊红泡提示按钮
@property(nonatomic, strong) TTBadgeNumberView *bageView;

@end

NS_ASSUME_NONNULL_END
