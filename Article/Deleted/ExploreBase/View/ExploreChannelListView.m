//
//  ExploreChannelListView.m
//  Article
//
//  Created by Chen Hong on 14-10-13.
//
//

#import "ExploreChannelListView.h"
#import "ArticleTitleImageView.h"
#import "SSNavigationBar.h"

#import "TTArticleCategoryManager.h"
#import "TTCategory.h"
#import "ArticleWebListView.h"

#import "TTCategorySelectorView.h"
#import "NewsBaseDelegate.h"
#import "UIScrollView+Refresh.h"
#import "TTIndicatorView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTRoute.h"

#import "WDDefines.h"
//#import "WDNativeListBaseListView.h"
#import "UIResponder+Router.h"

#define kSubscribeViewH 44.f
#define kInfoLabelX 15.f
#define kInfoFontSize 18.f
#define kSubscribeButtonH 29.f
#define kSubscribeButtonW 60.f
#define kSubscribeButtonRightPad 15.f
#define kSubscribeButtonCornerRadius 5.f
#define kSubscribeButtonFontSize 12.f
#define kNavigationBarHeight (self.tt_safeAreaInsets.top ? self.tt_safeAreaInsets.top + 44 : ([TTDeviceHelper isIPhoneXDevice] ? 44 : 20) + 44)

@interface ExploreChannelListView()<ExploreMixedListBaseViewDelegate/*, WDNativeListBaseListViewLoadingDelegate*/>
//@property(nonatomic, retain)WDNativeListBaseListView * wenDaListView;
@property(nonatomic, retain)ExploreMixedListBaseView * listView;
@property(nonatomic, retain)ArticleWebListView *webListView;
@property(nonatomic, retain)SSThemedView *subscribeViewContainer;
@property(nonatomic, retain)SSThemedButton *subscribeButton;
@property(nonatomic, copy)NSString *categoryID;
@property(nonatomic, copy)NSString *categoryName;
@property(nonatomic, copy)NSString *wapUrl;
@property(nonatomic, assign)ListDataType listType;
@property(nonatomic, assign)int flag;
@end

@implementation ExploreChannelListView

- (void)dealloc
{
    [_listView removeDelegates];
//    _wenDaListView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame baseCondition:nil];
    return self;
}

- (id)initWithFrame:(CGRect)frame baseCondition:(NSDictionary *)baseCondition
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
 
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //sslocal://feed?category=news_regimen&name=养生&show_subscribe=1
        
        NSDictionary *params = baseCondition;
        
        if ([params.allKeys containsObject:@"category"]) {
            self.categoryID = [NSString stringWithFormat:@"%@", [params objectForKey:@"category"]];
        }

        self.categoryName = [params objectForKey:@"name"];
        self.wapUrl = [params objectForKey:@"web_url"];
        self.flag = [[params objectForKey:@"flag"] intValue];
        if ([params.allKeys containsObject:@"type"]) {
            self.listType = (ListDataType)[[params objectForKey:@"type"] integerValue];
        } else {
            self.listType = ListDataTypeArticle;
        }
        
        NSString *from = [params objectForKey:@"enter_from"];
        NSString *extra = [params objectForKey:@"extra"];
        NSString *extJson = [params objectForKey:@"gd_ext_json"];
        
        // 是否显示‘关注’, 0 - 不显示 1 - 显示
        int showSubscribe = [[params objectForKey:@"show_subscribe"] intValue];
        
        self.backgroundColor = [UIColor clearColor];
        self.navigationBar = [[SSNavigationBar alloc] initWithFrame:[self frameForTitleImageView]];
        //[self addSubview:self.navigationBar];
        
        self.navigationBar.leftBarView = [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(backButtonClicked)];
        
        if (!isEmptyString(self.wapUrl) && ([self.wapUrl hasPrefix:@"http://"] || [self.wapUrl hasPrefix:@"https://"])) {
            // wap 频道
            self.webListView = [[ArticleWebListView alloc] initWithFrame:[self frameForWebListView]];
            _webListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:_webListView];
        }
        else {
//            //问答本地化频道是不同的
//            if ([self.categoryID isEqualToString:kWDCategoryId]) {
//
//                WDNativeListModel *model = [[WDNativeListModel alloc] initWithPageType:WDNativeListBaseListAtWDListCategory];
//                model.baseCondition = baseCondition;
//                _wenDaListView  = [[WDNativeListBaseListView alloc] initWithFrame:self.bounds widthModel:model];
//                _wenDaListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//                _wenDaListView.delegate = self;
//                [self addSubview:_wenDaListView];
//
//                CGFloat bottomPadding = 0;
//                CGFloat topPadding = kNavigationBarHeight;
//
//                [_wenDaListView setListTopInset:topPadding BottomInset:bottomPadding];
//            }
//            // native 频道
//            else {
            
                self.listView = [[ExploreMixedListBaseView alloc] initWithFrame:self.bounds
                                                                       listType:ExploreOrderedDataListTypeCategory
                                                                   listLocation:ExploreOrderedDataListLocationCategory];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:from forKey:kExploreFetchListConditionFromKey];
                [dict setValue:extra forKey:kExploreFetchListConditionExtraKey];
                [_listView setExternalCondtion:dict];
                
                _listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self addSubview:_listView];
                
                CGFloat bottomPadding = 0;
                CGFloat topPadding = kNavigationBarHeight;
                
                [self.listView setListTopInset:topPadding BottomInset:bottomPadding];
//            }
        }

        [self bringSubviewToFront:self.navigationBar];
        
        if (showSubscribe == 1) {
            // 检查频道是否位于首页
            BOOL bVisible = [[self categorySelectorView] isCategoryInFirstScreen:self.categoryID];
            BOOL hasBadge = [[self categorySelectorView] isCategoryShowBadge:self.categoryID];
            
            BOOL showSubView = !bVisible && !hasBadge;

#if 0
            // 添加此频道到首页
            BOOL bSubscribed = NO;
            
            // 如果已经有本地频道则不显示‘添加’
            if ([self.categoryID isEqualToString:kTTNewsLocalCategoryID]) {
                TTCategory *localCategory = [TTArticleCategoryManager newsLocalCategory];
                if (localCategory) {
                    bSubscribed = YES;
                }
            }
            
            if (!bSubscribed) {
                for (TTCategory *category in [[TTArticleCategoryManager sharedManager] subScribedCategories]) {
                    if ([category.categoryID isEqualToString:self.categoryID]) {
                        if (isEmptyString(_categoryName)) {
                            _categoryName = category.name;
                        }
                        bSubscribed = YES;
                        break;
                    }
                }
            }
#endif
            
            if (showSubView) {
                [self createSubscribeView];
            }
        }

        [self setTitleWithCategoryName:_categoryName];
        
        if (!isEmptyString(self.categoryID)) {
            if (isEmptyString(self.wapUrl)) {
                if (_listView) {
                    [_listView setCategoryID:self.categoryID];
                    [_listView.listView triggerPullDown];
                }
                
//                if (_wenDaListView) {
//                    [_wenDaListView triggerPullDown];
//                }
                
            } else {
                TTCategory *categoryModel = [self queryCategoryModel];
                
                if (categoryModel) {
                    [_webListView refreshListViewForCategory:categoryModel isDisplayView:YES fromLocal:YES fromRemote:YES reloadFromType:ListDataOperationReloadFromTypeNone];
                }
            }
        }
    
        
        wrapperTrackEvent(@"channel_detail", @"enter");
        
        if (!isEmptyString(from)) {
            NSString *label = [NSString stringWithFormat:@"enter_from_%@", from];
            [TTTrackerWrapper event:@"channel_detail" label:label json:extJson];
        }
    }
    
    return self;
}

//#pragma mark - WDNativeListBaseListViewLoadingDelegate
//
//- (void)WDNativeListBaseListView:(WDNativeListBaseListView *)listView isPullRefresh:(BOOL)isPullRefresh FinishError:(NSError *)error
//{
//    if ([self.delegate respondsToSelector:@selector(listViewFinishRequest:error:)]) {
//        [self.delegate listViewFinishRequest:self error:error];
//    }
//}

- (TTCategory *)queryCategoryModel {
    TTCategory *categoryModel = [TTArticleCategoryManager categoryModelByCategoryID:self.categoryID];
    if (!categoryModel) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:self.categoryID forKey:@"category"];
        [dict setValue:self.categoryName forKey:@"name"];
        [dict setValue:@(self.listType) forKey:@"type"];
        [dict setValue:self.wapUrl forKey:@"web_url"];
        [dict setValue:@(self.flag) forKey:@"flags"];
        
        categoryModel = [TTArticleCategoryManager insertCategoryWithDictionary:dict];
    }
    return categoryModel;
}

- (void)createSubscribeView {
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    
    if (!_subscribeViewContainer) {
        _subscribeViewContainer = [[SSThemedView alloc] initWithFrame:[self frameForSubscribeViewContainer]];
        _subscribeViewContainer.backgroundColors = @[[[UIColor blackColor] colorWithAlphaComponent:0.8],
        [UIColor colorWithHexString:@"3636367f"]];
        [self addSubview:_subscribeViewContainer];
        
        SSThemedLabel *infoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        infoLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        infoLabel.text = NSLocalizedString(@"把此频道添加到首屏", nil);
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.textColors = @[[UIColor colorWithHexString:@"fafafa"],[UIColor colorWithHexString:@"cacaca"]];
        infoLabel.font = [UIFont systemFontOfSize:kInfoFontSize];
        [infoLabel sizeToFit];
        infoLabel.origin = [self frameOriginForSubscribeInfoLabel];
        [_subscribeViewContainer addSubview:infoLabel];
        
        self.subscribeButton = [[SSThemedButton alloc] initWithFrame:[self frameForSubscribeBtn]];
        self.subscribeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.subscribeButton.backgroundColors = @[[UIColor colorWithHexString:@"d43d3d"],[UIColor colorWithHexString:@"935656"]];
        self.subscribeButton.highlightedBackgroundColors = @[[UIColor colorWithHexString:@"b11919"],[UIColor colorWithHexString:@"d43d3d"]];
        self.subscribeButton.titleColors = @[[UIColor colorWithHexString:@"fafafa"],[UIColor colorWithHexString:@"cacaca"]];
        self.subscribeButton.layer.cornerRadius = kSubscribeButtonCornerRadius;
        [self.subscribeButton setTitle:NSLocalizedString(@"立即添加", nil) forState:UIControlStateNormal];
        [self.subscribeButton.titleLabel setFont:[UIFont systemFontOfSize:kSubscribeButtonFontSize]];
        [self.subscribeButton addTarget:self action:@selector(subscribe:) forControlEvents:UIControlEventTouchUpInside];
        [_subscribeViewContainer addSubview:self.subscribeButton];
    }
}

- (void)subscribe:(id)sender
{
    TTCategory *model = [self queryCategoryModel];
    model.tipNew = YES;

    if (model) {
        NSDictionary *userInfo = @{kTTInsertCategoryNotificationCategoryKey:model};
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTInsertCategoryToLastPositionNotification object:nil userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kArticleCategoryTipNewChangedNotification object:nil];
        
        self.subscribeViewContainer.hidden = YES;
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"已放到首屏", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        
        wrapperTrackEvent(@"channel_detail", @"add");
    }
}

- (void)willAppear
{
    [super willAppear];
    [_listView willAppear];
//    [_wenDaListView willAppear];
}

- (void)didAppear
{
    [super didAppear];
    [_listView didAppear];
//    [_wenDaListView didAppear];
}

- (void)willDisappear
{
    [super willDisappear];
    [_listView willDisappear];
//    [_wenDaListView willDisappear];
}

- (void)didDisappear
{
    [super didDisappear];
    [_listView didDisappear];
//    [_wenDaListView willDisappear];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.navigationBar.frame = [self frameForTitleImageView];
//    _wenDaListView.frame = self.bounds;
    _listView.frame = self.bounds;
    _subscribeViewContainer.frame = [self frameForSubscribeViewContainer];
    
}

- (void)backButtonClicked
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (CGRect)frameForTitleImageView
{
    return CGRectMake(0, 0, self.width, [ArticleTitleImageView titleBarHeight]);
}

- (CGRect)frameForWebListView
{
    CGRect rect = CGRectMake(0, [ArticleTitleImageView titleBarHeight], self.width, self.height - [ArticleTitleImageView titleBarHeight]);
    return rect;
}

- (CGRect)frameForSubscribeViewContainer
{
    CGRect rect = CGRectMake(0, self.height - kSubscribeViewH, self.width, kSubscribeViewH);
    return rect;
}

- (CGPoint)frameOriginForSubscribeInfoLabel
{
    CGPoint origin = CGPointMake(kInfoLabelX, (kSubscribeViewH - kInfoFontSize)/2);
    return origin;
}

- (CGRect)frameForSubscribeBtn
{
    CGRect rect = CGRectMake(self.width - kSubscribeButtonW - kSubscribeButtonRightPad,
                             (kSubscribeViewH - kSubscribeButtonH)/2,
                             kSubscribeButtonW,
                             kSubscribeButtonH);
    return rect;
}

//- (void)mixListView:(ExploreMixedListBaseView *)listView didFinishWithFetchedItems:(NSArray *)fetchedItems operationContext:(id)operationContext error:(NSError *)error {
//    if (!error) {
//        NSDictionary *categoryDict = [[[operationContext objectForKey:kExploreFetchListResponseRemoteDataKey] objectForKey:@"result"] objectForKey:@"category"];
//        if ([categoryDict isKindOfClass:[NSDictionary class]]) {
//            NSString *categoryName = [categoryDict objectForKey:@"cn_name"];
//            if (!isEmptyString(categoryName)) {
//                [self setTitleWithCategoryName:categoryName];
//            }
//        }
//    }
//}

- (void)setTitleWithCategoryName:(NSString *)categoryName {
    NSString *title;
    if (!isEmptyString(categoryName)) {
        title = [NSString stringWithFormat:@"%@%@", categoryName, NSLocalizedString(@"频道", nil)];
    } else {
        title = NSLocalizedString(@"频道", nil);
    }
    
    self.navigationBar.title = title;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearCacheHeightNotification object:nil];
    if (_listView) {
        [_listView.listView reloadData];
    }
//    if (_wenDaListView) {
//        [_wenDaListView.tableView reloadData];
//    }
}
 
// 取得categorySelectorView
- (TTCategorySelectorView *)categorySelectorView {
    
    return [(NewsBaseDelegate*)[[UIApplication sharedApplication] delegate] categorySelectorView];

}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    if ([eventName isEqualToString:@"PostQuestionButtonClick"]) {
        NSString *schema = [userInfo objectForKey:@"schema"];
        if (!isEmptyString(schema)) {
            schema = [schema stringByAppendingString:@"&list_entrance=answer_list"];
            [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:schema] userInfo:nil];
        }
    }
}

@end
