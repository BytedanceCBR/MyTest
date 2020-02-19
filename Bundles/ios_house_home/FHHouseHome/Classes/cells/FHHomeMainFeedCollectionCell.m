//
//  FHHomeMainFeedCollectionCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/22.
//

#import "FHHomeMainFeedCollectionCell.h"
#import "ArticleTabbarStyleNewsListViewController.h"

@implementation FHHomeMainFeedCollectionCell
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        self.contentView.backgroundColor = [UIColor clearColor];
        ArticleTabBarStyleNewsListViewController *ariticleListVC = [[ArticleTabBarStyleNewsListViewController alloc] init];
        ariticleListVC.isShowTopSearchPanel = NO;
        self.contentVC = ariticleListVC;
        [self.contentView addSubview:ariticleListVC.view];
    }
    return self;
}
@end
