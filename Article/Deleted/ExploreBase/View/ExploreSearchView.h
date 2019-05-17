//
//  ExploreSearchView.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-16.
//
//

#import "SSViewBase.h"
#import "ListDataHeader.h"
#import "ExploreSearchHotView.h"
#import "SSWebViewContainer.h"

#define kSearchBarPlaceholdString NSLocalizedString(@"请输入关键字", nil)

@class ExploreSearchView;
@class ArticleSearchBar;

@protocol ExploreSearchViewDelegate <NSObject>

- (void)searchViewCancelButtonClicked:(ExploreSearchView *)searchView;

@end

typedef NS_ENUM(NSUInteger, ExploreSearchViewType)
{
    ExploreSearchViewTypeWapSearch,
    ExploreSearchViewTypeEntrySearch,
    ExploreSearchViewTypeChannelSearch,
};

@interface ExploreSearchViewContext : NSObject
@property(nonatomic) BOOL showNavigationBar;
@property(nonatomic) ExploreSearchViewType searchViewType;
@property(nonatomic) ListDataSearchFromType searchFromType;
@property(nonatomic, copy) NSString *from;
@property(nonatomic, copy) NSString *defaultQuery;
@property(nonatomic, copy) NSString *apiParam;  // 透传schema中的apiParam
@property(nonatomic, copy) NSString *curTab; // 透传schema中的curTab
@property(nonatomic, copy) NSString *fromTabName;
@end

@interface ExploreSearchView : SSViewBase

@property (nonatomic, retain) NSString * defaultQuery;

// 只有顶部搜索框进入的搜索才能使用百度搜索
@property(nonatomic, assign)BOOL isFromTopSearchbar;

@property (nonatomic, strong) NSNumber *groupID;

@property (nonatomic, assign) ListDataSearchFromType fromType;
/// 搜索的from字段, 如果有from，则使用from。否则默认是search_tab
@property (nonatomic, copy) NSString    *from;
@property (nonatomic, assign) BOOL                   animatedWhenDismiss;
@property (nonatomic, assign) BOOL useCustomAnimation;

@property (nonatomic, strong, readonly) SSWebViewContainer    *webView;
@property (nonatomic, weak) id<ExploreSearchViewDelegate> searchViewDelegate;
//iPad 默认隐藏
@property (nonatomic, retain) UIButton * backButton;
@property (nonatomic, copy) NSString * umengEventString;

@property (nonatomic, strong) ExploreSearchHotView *hotSearchView;

@property (nonatomic, assign, readonly) ExploreSearchViewType searchViewType;

@property (nonatomic, copy) NSString  * searchUrlString;

//@property (nonatomic, retain) SSNavigationBar * navigationBar;

@property (nonatomic, weak) ArticleSearchBar *searchBar;
@property (nonatomic, strong)SSThemedView    *contentView;

// 如果不需要显示推荐列表，也不使用Web的推荐列表，设置为YES
@property (nonatomic, assign) BOOL hideRecommend;

// 搜索历史搜索提示wap化
@property (nonatomic, assign) BOOL isOverlayWebViewEnabled;

@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, copy) NSString *fromTabName;

//- (id)initWithFrame:(CGRect)frame showNavigationBar:(BOOL)show;//默认为ExploreSearchViewTypeWapSearch
//- (id)initWithFrame:(CGRect)frame showNavigationBar:(BOOL)show searchType:(ExploreSearchViewType)type;
//
//- (id)initWithFrame:(CGRect)frame showNavigationBar:(BOOL)show searchType:(ExploreSearchViewType)type fromType:(ListDataSearchFromType)fromType;
- (instancetype)initWithFrame:(CGRect)frame searchViewContext:(ExploreSearchViewContext *)context;

- (void)resetStayPageTrack;

- (void)sendStayPageTrack;

@end
