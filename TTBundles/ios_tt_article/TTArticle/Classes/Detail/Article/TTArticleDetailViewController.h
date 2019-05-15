//
//  TTArticleDetailViewController.h
//  Article
//
//  Created by 冯靖君 on 16/4/8.
//
//

#import "SSViewControllerBase.h"
#import "TTDetailModel.h"
#import "TTArticleDetailView.h"
#import "TTArticleDetailDefine.h"
#import "ArticleInfoManager.h"
#import "ExploreItemActionManager.h"

@interface TTArticleDetailViewController : SSViewControllerBase

@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, strong) TTArticleDetailView *detailView;
@property (nonatomic, strong) ArticleInfoManager *articleInfoManager;
@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;
@property (nonatomic, assign, readonly) BOOL shouldShowTipsOnNavBar;

@end
