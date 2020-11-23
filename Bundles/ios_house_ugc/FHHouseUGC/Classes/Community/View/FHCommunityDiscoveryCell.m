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
#import "FHHouseComfortFindViewController.h"
#import "FHUGCShortVideoListController.h"

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
        self.vc.tracerDict = [self tracerDict].mutableCopy;
        
        if(cellModel.type == FHCommunityCollectionCellTypeNearby){
            FHNearbyViewController *vc = (FHNearbyViewController *)self.vc;
            [vc viewWillAppear];
        }else if(cellModel.type == FHCommunityCollectionCellTypeMyJoin){
            FHMyJoinViewController *vc = (FHMyJoinViewController *)self.vc;
            vc.withTips = self.withTips;
            [vc viewWillAppear];
        }else if(cellModel.type == FHCommunityCollectionCellTypeSmallVideo){
            FHUGCShortVideoListController *vc = (FHUGCShortVideoListController *)self.vc;
            [vc viewWillAppear];
        }else if(cellModel.type == FHCommunityCollectionCellTypeCustom){
            FHCommunityFeedListController *vc = (FHCommunityFeedListController *)self.vc;
            [vc viewWillAppear];
        }else if(_cellModel.type == FHCommunityCollectionCellTypeHouseComfortFind) {
            FHHouseComfortFindViewController *vc = (FHHouseComfortFindViewController *)self.vc;
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
    }else if(_cellModel.type == FHCommunityCollectionCellTypeSmallVideo){
        FHUGCShortVideoListController *vc = (FHUGCShortVideoListController *)self.vc;
        [vc viewWillDisappear];
    }else if(_cellModel.type == FHCommunityCollectionCellTypeCustom){
        FHCommunityFeedListController *vc = (FHCommunityFeedListController *)self.vc;
        [vc viewWillDisappear];
    }else if(_cellModel.type == FHCommunityCollectionCellTypeHouseComfortFind) {
        FHHouseComfortFindViewController *vc = (FHHouseComfortFindViewController *)self.vc;
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
    }else if(_cellModel.type == FHCommunityCollectionCellTypeSmallVideo){
        FHUGCShortVideoListController *vc = [[FHUGCShortVideoListController alloc] init];
        vc.needReportEnterCategory = YES;
        self.vc = vc;
    }else if(_cellModel.type == FHCommunityCollectionCellTypeCustom){
        FHCommunityFeedListController *vc = [[FHCommunityFeedListController alloc] init];
        vc.listType = FHCommunityFeedListTypeCustom;
        vc.isNewDiscovery = YES;
        vc.category = _cellModel.category;
        vc.needReportEnterCategory = YES;
        if(!_cellModel.isInHomePage && ([_cellModel.category isEqualToString:@"f_news_recommend"])){
            vc.isInsertFeedWhenPublish = YES;
        }
        self.vc = vc;
    } else if(_cellModel.type == FHCommunityCollectionCellTypeHouseComfortFind) {
        FHHouseComfortFindViewController *vc = [[FHHouseComfortFindViewController alloc] init];
        self.vc = vc;
    }
    
    self.vc.tracerDict = [self tracerDict].mutableCopy;
    
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
    }else if([self.vc isKindOfClass:[FHUGCShortVideoListController class]]){
        FHUGCShortVideoListController *vc = (FHUGCShortVideoListController *)self.vc;
        vc.isRefreshTypeClicked = isClick;
        if(isHead){
            [vc scrollToTopAndRefreshAllData];
        }else{
            [vc scrollToTopAndRefresh];
        }
    }else if([self.vc isKindOfClass:[FHCommunityFeedListController class]]){
        FHCommunityFeedListController *vc = (FHCommunityFeedListController *)self.vc;
        vc.isRefreshTypeClicked = isClick;
        if(isHead){
            [vc scrollToTopAndRefreshAllData];
        }else{
            [vc scrollToTopAndRefresh];
        }
    }else if([self.vc isKindOfClass:[FHHouseComfortFindViewController class]]) {
        FHHouseComfortFindViewController *vc = (FHHouseComfortFindViewController *)self.vc;
        vc.feedVC.isRefreshTypeClicked = isClick;
        if(isHead){
            [vc.feedVC scrollToTopAndRefreshAllData];
        }else{
            [vc.feedVC scrollToTopAndRefresh];
        }
    }
}

- (NSDictionary *)tracerDict {
    NSString *enterType = self.enterType ? self.enterType : @"default";
    NSString *originFrom = self.cellModel.tracerDict[@"origin_from"] ?: @"be_null";
    NSString *enterFrom = self.cellModel.tracerDict[@"origin_from"] ?: @"be_null";
    return @{
             @"origin_from":originFrom,
             @"enter_from":enterFrom,
             @"enter_type":enterType,
             };
}

@end
