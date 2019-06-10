//
//  FHCommunityCollectionCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHCommunityCollectionCell.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "FHCommunityFeedListController.h"

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
    if(_type == FHCommunityCollectionCellTypeNone){
        _type = type;
        [self initViews];
    }
}

- (void)initViews {
    if(self.type == FHCommunityCollectionCellTypeNearby){
        FHCommunityFeedListController *vc = [[FHCommunityFeedListController alloc] init];
        vc.listType = FHCommunityFeedListTypeNearby;
        self.vc = vc;
    }else if(self.type == FHCommunityCollectionCellTypeMyJoin){
        FHCommunityFeedListController *vc = [[FHCommunityFeedListController alloc] init];
        vc.listType = FHCommunityFeedListTypeMyJoin;
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

@end
