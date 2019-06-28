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

@interface FHCommunityCollectionCell ()

@property(nonatomic, strong) UIViewController *vc;

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

- (void)setType:(FHCommunityCollectionCellType)type {
    if(_type != type){
        _type = type;
        [self initViews];
    }else{
        [self.vc viewWillAppear:NO];
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
        self.vc = vc;
    }else if(self.type == FHCommunityCollectionCellTypeDiscovery){
        ArticleTabBarStyleNewsListViewController *ariticleListVC = [[ArticleTabBarStyleNewsListViewController alloc] init];
        ariticleListVC.isShowTopSearchPanel = NO;
        self.vc = ariticleListVC;
    }else{
        
    }
    
    if(self.vc){
        self.vc.view.frame = self.bounds;
        [self.contentView addSubview:self.vc.view];
    }
}

- (UIViewController *)contentViewController {
    return _vc;
}

- (void)refreshData {
    if([self.vc isKindOfClass:[FHNearbyViewController class]]){
        FHNearbyViewController *vc = (FHNearbyViewController *)self.vc;
        [vc.feedVC scrollToTopAndRefresh];
    }else if([self.vc isKindOfClass:[FHMyJoinViewController class]]){
        FHMyJoinViewController *vc = (FHMyJoinViewController *)self.vc;
        [vc.feedListVC scrollToTopAndRefresh];
    }
}

@end
