//
//  FHHouseRealtorDetailVC.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/16.
//

#import "FHBaseViewController.h"
#import "UIViewAdditions.h"
#import "FHHouseRealtorDetailHeaderView.h"
#import "FHCommunityDetailSegmentView.h"
#import "TTHorizontalPagingView.h"
#import "TTBadgeNumberView.h"

@class FHCommunityFeedListController;
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailVC : FHBaseViewController
@property (nonatomic, copy) NSString *communityId;
@property (nonatomic, copy) NSString *tabName;
@property (nonatomic, strong) FHHouseRealtorDetailHeaderView *headerView;
@property (nonatomic, strong) FHCommunityDetailSegmentView *segmentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UIView *titleContainer;
@end

NS_ASSUME_NONNULL_END
