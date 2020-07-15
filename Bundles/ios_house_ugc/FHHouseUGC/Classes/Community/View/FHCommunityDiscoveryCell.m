//
//  FHCommunityDiscoveryCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/20.
//

#import "FHCommunityDiscoveryCell.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "FHCommunityFeedListController.h"
#import "FHNearbyViewController.h"
#import "FHMyJoinViewController.h"
#import "FHHouseFindViewController.h"

@interface FHCommunityDiscoveryCell ()

@property(nonatomic, strong) FHBaseViewController *vc;

@end

@implementation FHCommunityDiscoveryCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)setCellModel:(FHCommunityDiscoveryCellModel *)cellModel {
    if(_cellModel != cellModel){
        _cellModel = cellModel;
        [self initViews];
    }else{
        self.vc.tracerDict = [self traceDic].mutableCopy;
        
        if(cellModel.type == FHCommunityCollectionCellTypeNearby){
            FHNearbyViewController *vc = (FHNearbyViewController *)self.vc;
            [vc viewWillAppear];
        }else if(cellModel.type == FHCommunityCollectionCellTypeMyJoin){
            FHMyJoinViewController *vc = (FHMyJoinViewController *)self.vc;
            vc.withTips = self.withTips;
            [vc viewWillAppear];
        }else if(cellModel.type == FHCommunityCollectionCellTypeCustom){
            FHCommunityFeedListController *vc = (FHCommunityFeedListController *)self.vc;
            [vc viewWillAppear];
        }
    }
}

- (void)cellDisappear {
    if(_cellModel.type == FHCommunityCollectionCellTypeNearby){
        FHNearbyViewController *vc = (FHNearbyViewController *)self.vc;
        [vc viewWillDisappear];
    }else if(_cellModel.type == FHCommunityCollectionCellTypeMyJoin){
        FHMyJoinViewController *vc = (FHMyJoinViewController *)self.vc;
        [vc viewWillDisappear];
    }else if(_cellModel.type == FHCommunityCollectionCellTypeCustom){
        FHCommunityFeedListController *vc = (FHCommunityFeedListController *)self.vc;
        [vc viewWillDisappear];
    }
}

- (void)initViews {
    if(self.vc){
        [self.vc.view removeFromSuperview];
        [self.vc removeFromParentViewController];
        self.vc = nil;
    }
    
    if(_cellModel.type == FHCommunityCollectionCellTypeNearby){
        FHNearbyViewController *vc = [[FHNearbyViewController alloc] init];
        vc.isNewDiscovery = YES;
        self.vc = vc;
    }else if(_cellModel.type == FHCommunityCollectionCellTypeMyJoin){
        FHMyJoinViewController *vc = [[FHMyJoinViewController alloc] init];
        vc.withTips = self.withTips;
        vc.isNewDiscovery = YES;
        self.vc = vc;
    }else if(_cellModel.type == FHCommunityCollectionCellTypeCustom){
        FHCommunityFeedListController *vc = [[FHCommunityFeedListController alloc] init];
        vc.listType = FHCommunityFeedListTypeCustom;
        vc.isNewDiscovery = YES;
        vc.category = _cellModel.category;
        vc.needReportEnterCategory = YES;
        self.vc = vc;
    }
    
    self.vc.tracerDict = [self traceDic].mutableCopy;
    
    if(self.vc){
        self.vc.view.frame = self.bounds;
        [self.contentView addSubview:self.vc.view];
        
        if([self.vc isKindOfClass:[FHCommunityFeedListController class]]){
            FHCommunityFeedListController *vc = (FHCommunityFeedListController *)self.vc;
            [vc viewWillAppear];
        }
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
    }else if([self.vc isKindOfClass:[FHCommunityFeedListController class]]){
        FHCommunityFeedListController *vc = (FHCommunityFeedListController *)self.vc;
        vc.isRefreshTypeClicked = isClick;
        if(isHead){
            [vc scrollToTopAndRefreshAllData];
        }else{
            [vc scrollToTopAndRefresh];
        }
    }
}

- (NSDictionary *)traceDic {
    NSString *enterType = self.enterType ? self.enterType : @"default";
    return @{
             @"origin_from":@"neighborhood_tab",
             @"enter_from":@"neighborhood_tab",
             @"enter_type":enterType,
             };
}

@end
