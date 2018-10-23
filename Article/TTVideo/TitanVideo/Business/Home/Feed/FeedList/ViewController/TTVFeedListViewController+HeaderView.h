//
//  TTVFeedListViewController+HeaderView.h
//  Article
//
//  Created by panxiang on 2017/3/28.
//
//

#import "TTVFeedListViewController.h"

@interface TTVFeedListViewController (HeaderView)
- (void)setListHeader:(UIView *)headerView;

- (void)refreshHeaderView;


- (BOOL)needShowPGCBar;

- (void)updateCustomTopOffset;

- (void)refreshSubEntranceBar;

- (void)dockHeaderViewBar;
@end
