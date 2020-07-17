//
//  FHCommunityCollectionCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHCommunityCollectionCell.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "FHCommunityFeedListController.h"
#import "FHNearbyViewController.h"
#import "FHMyJoinViewController.h"
#import "FHHouseFindViewController.h"

@interface FHCommunityCollectionCell ()

@property(nonatomic, strong) FHBaseViewController *vc;

@end

@implementation FHCommunityCollectionCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        _type = FHCommunityCollectionCellTypeNone;
    }
    
    return self;
}

- (void)setType:(FHCommunityCollectionCellType)type tracerDict:(nonnull NSDictionary *)tracerDic {
    if(_type != type){
        _type = type;
        _tracerDic = tracerDic;
        [self initViews];
    }else{
        self.vc.tracerDict = [self tracerDict].mutableCopy;

        if(self.type == FHCommunityCollectionCellTypeNearby){
            FHNearbyViewController *vc = (FHNearbyViewController *)self.vc;
            [vc viewWillAppear];
        }else if(self.type == FHCommunityCollectionCellTypeMyJoin){
            FHMyJoinViewController *vc = (FHMyJoinViewController *)self.vc;
            vc.withTips = self.withTips;
            [vc viewWillAppear];
        }
    }
}

- (void)cellDisappear {
    if(self.type == FHCommunityCollectionCellTypeNearby){
        FHNearbyViewController *vc = (FHNearbyViewController *)self.vc;
        [vc viewWillDisappear];
    }else if(self.type == FHCommunityCollectionCellTypeMyJoin){
        FHMyJoinViewController *vc = (FHMyJoinViewController *)self.vc;
        [vc viewWillDisappear];
    }
}

- (void)initViews {
    if(self.vc){
        [self.vc.view removeFromSuperview];
        [self.vc removeFromParentViewController];
        self.vc = nil;
    }
    
    if(self.type == FHCommunityCollectionCellTypeNearby){
        FHNearbyViewController *vc = [[FHNearbyViewController alloc] init];
        self.vc = vc;
    }else if(self.type == FHCommunityCollectionCellTypeMyJoin){
        FHMyJoinViewController *vc = [[FHMyJoinViewController alloc] init];
        vc.withTips = self.withTips;
        self.vc = vc;
    }
    
    self.vc.tracerDict = [self tracerDict].mutableCopy;
    
    if(self.vc){
        self.vc.view.frame = self.bounds;
        [self.contentView addSubview:self.vc.view];
    }
}

- (UIViewController *)contentViewController {
    return _vc;
}

- (void)refreshData:(BOOL)isHead isClick:(BOOL)isClick {
    if([self.vc isKindOfClass:[FHNearbyViewController class]]){
        FHNearbyViewController *vc = (FHNearbyViewController *)self.vc;
        vc.feedVC.isRefreshTypeClicked = isClick;
        if(isHead){
            [vc.feedVC scrollToTopAndRefreshAllData];
        }else{
            [vc.feedVC scrollToTopAndRefresh];
        }
    }else if([self.vc isKindOfClass:[FHMyJoinViewController class]]){
        FHMyJoinViewController *vc = (FHMyJoinViewController *)self.vc;
        vc.feedListVC.isRefreshTypeClicked = isClick;
        [vc refreshFeedListData:isHead];
    }
}

- (NSDictionary *)tracerDict {
    NSString *enterType = self.enterType ? self.enterType : @"default";
    NSString *originFrom = self.tracerDic[@"origin_from"] ?: @"be_null";
    NSString *enterFrom = self.tracerDic[@"origin_from"] ?: @"be_null";
    return @{
             @"origin_from":originFrom,
             @"enter_from":enterFrom,
             @"enter_type":enterType,
             };
}

@end
