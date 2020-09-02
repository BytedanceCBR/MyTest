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
#import "FHEnvContext.h"

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
        }else if(self.type == FHCommunityCollectionCellTypeCustom){
            FHCommunityFeedListController *vc = (FHCommunityFeedListController *)self.vc;
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
    }else if(self.type == FHCommunityCollectionCellTypeCustom){
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
    
    if(self.type == FHCommunityCollectionCellTypeNearby){
        FHNearbyViewController *vc = [[FHNearbyViewController alloc] init];
        self.vc = vc;
    }else if(self.type == FHCommunityCollectionCellTypeMyJoin){
        FHMyJoinViewController *vc = [[FHMyJoinViewController alloc] init];
        vc.withTips = self.withTips;
        self.vc = vc;
    }else if(self.type == FHCommunityCollectionCellTypeCustom){
        FHCommunityFeedListController *vc = [[FHCommunityFeedListController alloc] init];
        vc.listType = FHCommunityFeedListTypeVideoList;
        vc.isNewDiscovery = NO;
        vc.category = @"f_house_video";
        vc.needReportEnterCategory = YES;
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

- (NSDictionary *)tracerDict {
    NSString *enterType = self.enterType ? self.enterType : @"default";
    NSString *originFrom = self.tracerDic[@"origin_from"] ?: @"be_null";
     NSString *enterFrom = self.tracerDic[@"origin_from"] ?: @"be_null";
    if([[FHEnvContext sharedInstance].enterChannel isEqualToString:@"push"]){
        originFrom = [FHEnvContext sharedInstance].enterChannel;
        enterFrom = [FHEnvContext sharedInstance].enterChannel;
    }
    
    return @{
             @"origin_from":originFrom,
             @"enter_from":enterFrom,
             @"enter_type":enterType,
             };
}

@end
