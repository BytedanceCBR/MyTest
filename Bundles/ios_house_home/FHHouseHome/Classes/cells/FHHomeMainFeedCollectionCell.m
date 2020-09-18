//
//  FHHomeMainFeedCollectionCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/22.
//

#import "FHHomeMainFeedCollectionCell.h"
#import "ArticleTabbarStyleNewsListViewController.h"
#import "FHCommunityViewController.h"
#import "FHUGCShortVideoListController.h"
#import "FHEnvContext.h"

@implementation FHHomeMainFeedCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        if([FHEnvContext isHasShortVideoList]){
            [self addShortVideoVC];
        }else{
            [self addCommunityVC];
        }
    }
    return self;
}

- (void)addArticleVC {
    ArticleTabBarStyleNewsListViewController *ariticleListVC = [[ArticleTabBarStyleNewsListViewController alloc] init];
    ariticleListVC.isShowTopSearchPanel = NO;
    self.contentVC = ariticleListVC;
    ariticleListVC.view.frame = self.bounds;
    [self.contentView addSubview:ariticleListVC.view];
}

- (void)addCommunityVC {
    FHCommunityViewController *vc = [[FHCommunityViewController alloc] init];
    vc.isNewDiscovery = YES;
    vc.tracerDict = @{
        @"origin_from":@"discover_stream",
        @"enter_from":@"maintab",
        @"category_name":@"discover_stream"
    }.mutableCopy;
    
    self.contentVC = vc;
    vc.view.frame = self.bounds;
    [self.contentView addSubview:vc.view];
}

- (void)addShortVideoVC {
    FHUGCShortVideoListController *vc = [[FHUGCShortVideoListController alloc] init];
    vc.tracerDict = @{
        @"origin_from":@"discover_stream",
        @"enter_from":@"maintab",
        @"category_name":@"discover_stream"
    }.mutableCopy;
    
    self.contentVC = vc;
    vc.view.frame = self.bounds;
    [self.contentView addSubview:vc.view];
}

@end
