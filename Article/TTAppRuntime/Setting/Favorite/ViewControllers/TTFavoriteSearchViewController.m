//  TTFavoriteSearchViewController.m
//  Article
//
//  Created by lizhuoli on 16/12/29.
//
//

#import "TTFavoriteSearchViewController.h"
#import "SSThemed.h"
#import "ArticleSearchBar.h"

@interface TTFavoriteSearchViewController ()

@property (nonatomic, copy) NSString *from;

@end

@implementation TTFavoriteSearchViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithNavigationBar:YES showBackButton:![TTDeviceHelper isPadDevice] queryStr:nil fromType:ListDataSearchFromTypeMineTab searchType:ExploreSearchViewTypeWapSearch];
    if (self) {
        if (paramObj.allParams && [paramObj.allParams isKindOfClass:[NSDictionary class]]) {
            self.from = paramObj.allParams[@"from"];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchView.searchUrlString = [CommonURLSetting userSearchPageURLString];
    self.searchView.searchBar.searchField.placeholder = @"搜索收藏、阅读历史、推送历史";
    self.searchView.from = self.from;
    self.searchView.hideRecommend = YES;
    self.searchView.isOverlayWebViewEnabled = NO;
    
    [self.searchView.hotSearchView removeFromSuperview];
    SSThemedView *hotSearchView = [[SSThemedView alloc] initWithFrame:self.searchView.contentView.bounds];
    hotSearchView.backgroundColorThemeKey = kColorBackground4;
    hotSearchView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.searchView.hotSearchView = (ExploreSearchHotView *)hotSearchView;
    [self.searchView.contentView addSubview:hotSearchView];
}

@end
