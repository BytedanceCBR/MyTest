//
//  ArticleTabBarStyleNewsListViewController.h
//  Article
//
//  Created by Dianwei on 14-9-2.
//
//

#import "SSViewControllerBase.h"
#import "TTExploreMainViewController.h"
#import <FHHomeMainViewModel.h>

@interface ArticleTabBarStyleNewsListViewController : SSViewControllerBase

@property (nonatomic, strong) TTExploreMainViewController *mainVC;
@property (nonatomic, assign) BOOL isShowTopSearchPanel;

- (void)viewAppearForEnterType:(FHHomeMainTraceEnterType)enterType;

- (void)viewDisAppearForEnterType:(FHHomeMainTraceEnterType)enterType;

@end
