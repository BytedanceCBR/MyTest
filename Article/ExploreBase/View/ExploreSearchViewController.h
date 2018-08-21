//
//  ExploreSearchViewController.h
//  Article
//
//  Created by SunJiangting on 14-9-10.
//
//

#import "SSViewControllerBase.h"
#import "ExploreSearchView.h"
#import "ListDataHeader.h"

@interface ExploreSearchViewController : SSViewControllerBase

@property (nonatomic, strong) ExploreSearchView *searchView;
@property (nonatomic, copy) NSString *fromTabName;
@property (nonatomic, assign) BOOL animatedWhenDismiss;
@property (nonatomic, strong) NSNumber *groupID;

@property (nonatomic, copy) NSString  *searchUrlString;

- (id)initWithNavigationBar:(BOOL)showNavigationBar;
- (id)initWithNavigationBar:(BOOL)showNavigationBar showBackButton:(BOOL)showBackButton queryStr:(NSString *)queryStr fromType:(ListDataSearchFromType)type;
- (id)initWithNavigationBar:(BOOL)showNavigationBar showBackButton:(BOOL)showBackButton queryStr:(NSString *)queryStr fromType:(ListDataSearchFromType)fromType searchType:(ExploreSearchViewType)searchType;

// 动画
- (void)showInViewWithCustomAnimation:(UIView *)view  searchViewDelegate:(id<ExploreSearchViewDelegate>)searchViewDelegate;
- (void)dismissFromViewWithCustomAnimation:(UIView *)view;
+ (ArticleSearchBar *)searchBarWithWidth:(CGFloat)width;

@end
