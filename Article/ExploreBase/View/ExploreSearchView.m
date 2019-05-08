//
//  ExploreSearchView.m
//  Article
//
//  Created by Zhang Leonardo on 14-9-16.
//
//

#import "ExploreSearchView.h"
#import "TTArticleSearchHistoryView.h"
#import "ArticleSearchSuggestionView.h"

#import "NSStringAdditions.h"
#import "NSString+URLEncoding.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "UIImage+TTThemeExtension.h"

#import "TTRoute.h"
#import "ArticleSearchBar.h"
#import <TTUserSettingsManager+FontSettings.h>

#import "TTLocationManager.h"
#import "TTIndicatorView.h"
#import "TTDebugConsoleManager.h"
#import "TTMonitor.h"

#import <TTNetworkManager/TTNetworkManager.h>
#import "ArticleURLSetting.h"
#import <TTNetBusiness/TTNetworkUtilities.h>
#import "TTInstallIDManager.h"
#import "TTUIResponderHelper.h"
#import "TTURLUtils.h"
#import "TTNavigationController.h"
#import "TTNetworkHelper.h"
#import <TTTracker.h>
#import "TTCustomAnimationDelegate.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTTopBar.h"
#import "TTTopBarManager.h"
#import "ExploreSearchViewController.h"

@implementation ExploreSearchViewContext

@end

@interface ExploreSearchView()<TTSeachBarViewDelegate, YSWebViewDelegate, UIGestureRecognizerDelegate, TTArticleSearchHistoryViewDelegate>
{
    BOOL _willDisappear;
    
    /// 避免在viewDidAppear中重复做一些事
    BOOL _hasAppear;
    
    BOOL _isFirstSend;
    
    // 禁用搜索加载优化
    BOOL _isSearchOptimizeDisabled;
    
    BOOL _needReloadOverlayWebView;
    
    NSDate *_startDate;
}

@property (nonatomic, retain) ArticleSearchSuggestionView *suggestionView;

@property (nonatomic, strong) TTArticleSearchHistoryView *historyView;

@property (nonatomic, strong) SSThemedImageView    *bgImageView;
@property (nonatomic, strong) SSWebViewContainer    *webView;
@property (nonatomic, strong) SSWebViewContainer    *overlayWebView; // wap版搜索历史

@property (nonatomic, assign, readwrite) ExploreSearchViewType searchViewType;

@property (nonatomic, assign) BOOL hasSearchResult;
@property (nonatomic, copy) NSString *labelString;

@property (nonatomic, copy) NSString *realSearchUrlString;
@property (nonatomic, strong) NSTimer * countDownTimer;

@property (nonatomic, strong) NSDictionary *overlaySearchDict;

@property (nonatomic, copy) NSString *apiParam;

@property (nonatomic, copy) NSString *curTab;

@property (nonatomic) NSTimeInterval startLoadTime; //加载起始时间
@property (nonatomic) BOOL hasSendSuggestWebLoadTime;//是否已发送搜索推荐页面的加载时长
@property (nonatomic) BOOL hasSendSearchWebLoadTime;//是否已发送搜索页面的加载时长
@property (nonatomic) BOOL hasSendSuggestWebLoadFailTime;//是否已发送搜索推荐页面的加载失败时长
@property (nonatomic) BOOL hasSendSearchWebLoadFailTime;//是否已发送搜索页面的加载失败时长
@end

@implementation ExploreSearchView

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame searchViewContext:(ExploreSearchViewContext *)context {
    self = [super  initWithFrame:frame];
    if (self) {
        self.startLoadTime = CACurrentMediaTime();
        
        self.fromType = context.searchFromType;
        self.searchViewType = context.searchViewType;
        
        if (context.showNavigationBar) {
            if ([TTDeviceHelper isPadDevice]) {
                _backButton.hidden = YES;
            }
            self.animatedWhenDismiss = YES;
        }
        
        _isSearchOptimizeDisabled = [SSCommonLogic isSearchOptimizeDisabled];
        _isOverlayWebViewEnabled = [SSCommonLogic searchInitialPageWapEnabled];
        
        self.fromTabName = context.fromTabName;
        [self buildView];
        
        self.from = context.from;
        self.defaultQuery = context.defaultQuery;
        self.apiParam = context.apiParam;
        self.curTab = context.curTab;
        
        if ((self.fromType == ListDataSearchFromTypeTab || self.fromType == ListDataSearchFromTypeVideo) && [TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
            CGFloat topInset = 20;
            if (@available(iOS 11.0, *)) {
                topInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top;
            }
            self.bgImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, 44+topInset)];
            self.bgImageView.backgroundColor = UIColor.whiteColor;
            self.bgImageView.image = [TTTopBar searchBackgroundImage];
            [self addSubview:self.bgImageView];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame searchViewContext:nil];
}

- (void)backButtonClicked
{
    [[TTUIResponderHelper topNavigationControllerFor:self] popViewControllerAnimated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat topInset = self.tt_safeAreaInsets.top;
    if (topInset <= 0){
        topInset = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    if (topInset <= 0){
        topInset = 20;
    }
    
    topInset += TTNavigationBarHeight;
    self.webView.frame = self.contentView.bounds;
    self.contentView.frame = CGRectMake(0, topInset, self.width, self.height - topInset);
}

- (void)buildView
{
    // Do any additional setup after loading the view.
    CGFloat originY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        originY += 20.f;
    }
    
    // 搜索框
    ArticleSearchBar * searchBar = [[ArticleSearchBar alloc] initWithFrame:CGRectMake(0, originY, self.width, 44)];
    searchBar.delegate = self;
    
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled]) {
        if (_fromType == ListDataSearchFromTypeTab) {
            if (![TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
                searchBar.backgroundColors = @[[UIColor colorWithHexString:@"0xD43D3D"],[UIColor colorWithHexString:@"0x651414"]];
            } else {
                searchBar.backgroundColor = [UIColor clearColor];
            }
        }
    } else {
        searchBar.backgroundColorThemeKey = kColorBackground4;
    }
    
    searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground3;
    
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.showsCancelButton = YES;
    [self addSubview:searchBar];
    [searchBar setEditing:YES animated:NO];
    NSString *placeholder = kSearchBarPlaceholdString;
    if ([SSCommonLogic searchHintSuggestEnable]) {
        placeholder = [SSCommonLogic searchBarTipForNormal];
        if ([SSCommonLogic threeTopBarEnable] && self.fromType == ListDataSearchFromTypeVideo){
            placeholder = [SSCommonLogic searchBarTipForVideo];
        }
        if ([self.fromTabName isEqualToString:@"video"]) {
            placeholder = [SSCommonLogic searchBarTipForVideo];
        }
        NSArray *array = [placeholder componentsSeparatedByString:@"|"];
        if (array.count > 0) {
            placeholder = [array firstObject];
            placeholder = [placeholder trimmed];
        }
        if (placeholder.length == 0) {
            placeholder = kSearchBarPlaceholdString;
        }
    }
    searchBar.searchField.placeholder = placeholder;
    self.searchBar = searchBar;
    
    self.contentView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, searchBar.bottom, self.width, self.height - searchBar.bottom)];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView.backgroundColorThemeKey = kColorBackground4;
    [self addSubview:self.contentView];

    // 搜索默认页
    if (!_isOverlayWebViewEnabled) {
        ExploreSearchHotView * hotSearchView = [[ExploreSearchHotView alloc] initWithFrame:self.contentView.bounds];
        hotSearchView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.hotSearchView = hotSearchView;
        [self.contentView addSubview:hotSearchView];
    }
    
    // 搜索结果
    self.webView = [[SSWebViewContainer alloc] initWithFrame:self.contentView.bounds];
    [self.webView.ssWebView addDelegate:self];
    self.webView.ssWebView.backgroundColor = [UIColor clearColor];
    self.webView.ssWebView.opaque = NO;
    self.webView.ssWebView.useCustomVisibleEvent = YES;
    self.webView.ssWebView.scrollView.bounces = NO;
    WeakSelf;
    [self.webView.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        self.curTab = [NSString stringWithFormat:@"%@", result[@"cur_tab"]];
        self.suggestionView.curTab = self.curTab;
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"searchParams"];
    UIGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.delegate = self;
    [self.webView.ssWebView.scrollView addGestureRecognizer:tapGesture];
    
    __weak ExploreSearchView * weakSelf = self;
    
    // wap版搜索历史
    if (_isOverlayWebViewEnabled) {
        self.overlayWebView = [[SSWebViewContainer alloc] initWithFrame:self.contentView.bounds];
        [self.overlayWebView.ssWebView addDelegate:self];
        self.overlayWebView.ssWebView.backgroundColor = [UIColor clearColor];
        self.overlayWebView.ssWebView.opaque = NO;
        self.overlayWebView.ssWebView.scrollView.bounces = NO;
        [self.overlayWebView hiddenProgressView:YES];
        [self.contentView addSubview:self.overlayWebView];
        [self registerOverlayWebViewJSBridge];
    }
    
    // 搜索提示
    self.suggestionView = [[ArticleSearchSuggestionView alloc] initWithFrame:self.contentView.bounds];
    self.suggestionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.suggestionView.hidden = YES;
    self.suggestionView.curTab = self.curTab;
    self.suggestionView.selectedHandler = ^(NSString * title) {
        /////// 友盟统计
        wrapperTrackEvent(weakSelf.labelString, [NSString stringWithFormat:@"inputsug_%lu", (unsigned long)weakSelf.searchBar.text.length]);
        weakSelf.searchBar.text = title;
        weakSelf.fromType = ListDataSearchFromTypeSuggestion;
        [weakSelf searchWithLabel:@"sug_keyword_search"];
        weakSelf.suggestionView.tableView.scrollsToTop = NO;
    };
    [self.contentView addSubview:self.suggestionView];
    
    if (self.searchViewType == ExploreSearchViewTypeEntrySearch) {
        self.from = @"media";
    }

    NSString * historyCacheKey = nil;
    NSString * historViewUmengEventName = nil;
    if (_searchViewType == ExploreSearchViewTypeEntrySearch) {
        historyCacheKey = TTArticleEntrySearchHistoryCacheKey;
        historViewUmengEventName = @"subscription";
    }
    else {
        historyCacheKey = TTArticleDefaultSearchHistoryCacheKey;
        historViewUmengEventName = self.labelString;
    }
    
    if (_fromType == ListDataSearchFromTypeSubscribe) {
        historViewUmengEventName = @"sub_search_tab";
    }
    
    // 搜索历史
    NSString *from = nil;
    NSString *category = nil;
    
    if (self.fromType == ListDataSearchFromTypeTab ||
        self.fromType == ListDataSearchFromTypeFeed) {
        from = @"feed";
        category= self.categoryID;
    }
    else if (self.fromType == ListDataSearchFromTypeVideo) {
        from = @"video";
    }
    else if (self.fromType == ListDataSearchFromTypeConcern) {
        from = @"concern";
    }
    else if (self.fromType == ListDataSearchFromTypeWeitoutiao){
        from = @"weitoutiao";
    }
    
    NSString *homePageSuggest = [SSCommonLogic searchBarTipForNormal];
    
    if ([SSCommonLogic threeTopBarEnable] && self.fromType == ListDataSearchFromTypeVideo){
        homePageSuggest = [SSCommonLogic searchBarTipForVideo];
    }
    
    NSString *usedHomePageSuggest = homePageSuggest;
    if ([SSCommonLogic searchHintSuggestEnable]) {
        // 在推荐词直接搜索的情况下，不展示推荐搜索词
        usedHomePageSuggest = nil;
    }
    
    self.historyView = [[TTArticleSearchHistoryView alloc] initWithFrame:self.contentView.bounds
                                                                 context:^(TTArticleSearchHistoryContext *context) {
                                                                     context.cacheKey = historyCacheKey;
                                                                     context.from = from;
                                                                     context.category = category;
                                                                     context.homePageSuggest = usedHomePageSuggest;
                                                                 }];
    self.historyView.delegate = self;
    self.historyView.searchBar = self.searchBar;
    self.historyView.umengEventName = historViewUmengEventName;
    self.historyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.historyView.hidden = [self.historyView isContentEmpty];
    self.historyView.selectedHandler = ^(TTArticleSearchKeyword *searchKeyword) {
        weakSelf.searchBar.text = searchKeyword.keyword;
        weakSelf.fromType = ListDataSearchFromTypeHistory;
        NSString *label = nil;
        switch (searchKeyword.type) {
            case TTArticleSearchKeywordHistory:
                label = @"history_keyword_search";
                break;
            case TTArticleSearchKeywordRecommend:
            case TTArticleSearchKeywordInbox:
                label = @"hot_keyword_search";
                break;
        }
        [weakSelf searchWithLabel:label keywordTypeString:searchKeyword.typeString resignSearchView:YES];
    };
    
    if (!_isOverlayWebViewEnabled) {
        [self.contentView addSubview:self.historyView];
    }
    
    [self reloadThemeUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cacheCleared:) name:kClearCacheFinishedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (void)setFrom:(NSString *)from {
    _from = [from copy];
    self.suggestionView.fromParam = _from;
}

- (void)cacheCleared:(NSNotification*)notification {
    _searchBar.text = nil;
    [self displayHotSearchView];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.backgroundColor = [UIColor colorWithDayColorName:@"ebebed" nightColorName:@"363636"];
    self.webView.ssWebView.scrollView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.overlayWebView.ssWebView.scrollView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.suggestionView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.historyView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.searchBar.searchField.tintColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)willAppear
{
    if (self.hasSearchResult) {
        [self resetStayPageTrack];
    }
    
    _willDisappear = NO;
    
    [self.webView willAppear];
    
    // 主动触发visible事件通知web
    [self.webView.ssWebView invokeVisibleEvent];
    
    // 如果第一次出现，就去搜索
    if (!_hasAppear) {
        if (_isOverlayWebViewEnabled) {
            [self loadOverlayWebView];
        }
        
        if (_hotSearchView.superview || self.webView) {
            if (_isSearchOptimizeDisabled) {
                if (self.defaultQuery) {
                    self.searchBar.text = self.defaultQuery;
                    [self searchWithLabel:self.defaultQuery];
                }
            } else {
                NSString *defaultQuery = self.defaultQuery ?: @"";
                BOOL resignFirstResponder = self.defaultQuery ? YES : NO;
                self.searchBar.text = defaultQuery;
                [self searchWithLabel:defaultQuery resignSearchView:resignFirstResponder];
            }
            
            // 带着搜索词进入页面时，由于overlay此时还未加载完毕，需要在主搜索webview加载完毕后reload一下overlayWeb，确保搜索历史显示正确
            _needReloadOverlayWebView = !isEmptyString(self.defaultQuery);
        }
        _hasAppear = YES;
    }
    
    switch (self.fromType) {
        case ListDataSearchFromTypeFeed: {
            
            self.labelString = @"feed_search";
            break;
        }
        case ListDataSearchFromTypeSubscribe: {
            
            self.labelString = @"sub_search_tab";
            break;
        }
        default:
            
            self.labelString = @"search_tab";
            break;
    }
}

- (void)didAppear
{
    _willDisappear = NO;
    [self.webView didAppear];
}

- (void)willDisappear
{
    [self.webView willDisappear];
    _willDisappear = YES;
    
    [self sendStayPageTrack];
}

- (void)didDisappear
{
    [self.webView didDisappear];
    _willDisappear = YES;
    
    // 主动触发invisible事件通知web
    [self.webView.ssWebView invokeInvisibleEvent];
}

- (void)searchBarBecomeFirstResponder {
    if(![_searchBar isFirstResponder]) {
        [_searchBar becomeFirstResponder];
    }
}

- (void)searchWithLabel:(NSString*)label {
    [self searchWithLabel:label resignSearchView:YES];
}

- (void)searchWithLabel:(NSString*)label resignSearchView:(BOOL)resign
{
    [self searchWithLabel:label keywordTypeString:nil resignSearchView:resign];
}

- (void)searchWithLabel:(NSString *)label keywordTypeString:(NSString *)keywordTypeString resignSearchView:(BOOL)resign
{
    _isFirstSend = YES;
    NSString *text = [self.searchBar.text trimmed];
    
    if (text.length == 0 && label.length > 0) {
        if ([SSCommonLogic searchHintSuggestEnable]) {
            text = self.searchBar.searchField.placeholder;
            self.searchBar.text = self.searchBar.searchField.placeholder;
        }
    }
    
    self.hasSearchResult = YES;
    
    if (resign) {
        [_searchBar resignFirstResponder];
    }

    BOOL preLoad = (!_hasAppear && isEmptyString(text));
    
    BOOL hasText;
    if (_isSearchOptimizeDisabled) {
        hasText = !isEmptyString(text);
    } else {
        hasText = !isEmptyString(text) || preLoad;
    }
    
    if (!isEmptyString(text)) {
        [self resetStayPageTrack];
    }
    if (hasText) {
        [[TTDebugConsoleManager sharedTTDebugConsoleManager] processCommand:text];
        
#if INHOUSE
        if (!isEmptyString(text)) {
            if ([[TTRoute sharedRoute] canOpenURL:[NSURL URLWithString:text]]) {
                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:text]];
            }
        }
#endif

        NSDictionary *parameters = [self _defaultSearchParameters];
        NSMutableDictionary *mParameters = [parameters mutableCopy];
        [mParameters setValue:text forKey:@"keyword"];
        [mParameters setValue:@(1) forKey:@"forum"];
        
        if (self.isFromTopSearchbar) {
            [mParameters setValue:@(1) forKey:@"is_top_searchbar"];
        }
        
        NSString *type = @"";
        if (_isOverlayWebViewEnabled) {
            if ([self.overlaySearchDict isKindOfClass:[NSDictionary class]]) {
                type = [self.overlaySearchDict stringValueForKey:@"type" defaultValue:@""];
                self.overlaySearchDict = nil;
                [mParameters setValue:type forKey:@"type"];
            }
        } else {
            if ([keywordTypeString isKindOfClass:[NSString class]]) {
                type = keywordTypeString;
                [mParameters setValue:type forKey:@"type"];
            }
        }
        
        if ([self.from isEqualToString:@"search_detail"]) {
            // 点详情页顶部搜索框进入的搜索
            wrapperTrackEvent(@"search", @"click_search_detail_icon");
        }
        
        // 进入页面首次搜索有效
        if (!isEmptyString(_apiParam)) {
            [mParameters setValue:_apiParam forKey:@"api_param"];
            _apiParam = nil;
        }
        
        if (!isEmptyString(_curTab)){
            [mParameters setValue:_curTab forKey:@"cur_tab"];
        }
        
        if (!isEmptyString(label)) {
            [mParameters setValue:label forKey:@"action_type"];
        }
        
        NSString *searchUrlString = self.searchUrlString ?: [self defaultSearchURL];
        NSString *realSearchURLString = [[self class] constructURLStringFrom:searchUrlString getParameter:mParameters];;

        if (self.webView.ssWebView.isDomReady && !_isSearchOptimizeDisabled) {
            // 前端页面事件，domReady后下次搜索使用js，research(keyword)
            NSString *js = [NSString stringWithFormat:@"research('%@', {keyword_type: '%@', action_type: '%@'})", text, type ?: @"", label ?: @""];
            [self.webView.ssWebView evaluateJavaScriptFromString:js completionBlock:nil];
        }
        else {
            self.realSearchUrlString = realSearchURLString;
            [self.webView.ssWebView stopLoading];
            [self.webView.ssWebView loadRequest:[NSURLRequest requestWithURL:[TTStringHelper URLWithURLString:realSearchURLString]]];
            // 开启监控计时器
            [self startCountDownTimer];
        }
        self.webView.ssWebView.scrollView.scrollsToTop = YES;
        
        if (!isEmptyString(text)) {
            [self.historyView.manager insertKeyword:text];
            [self updateOverlayWebViewSearchHistory:text];
            
            [Answers logSearchWithQuery:text customAttributes:nil];
        }
        _suggestionView.tableView.scrollsToTop = NO;
    }
    else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"请输入关键字" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
    }
    
    BOOL showWebView = YES;
    if (!_isSearchOptimizeDisabled && preLoad) {
        // 搜索加载优化，第一次显示，搜索词为空时不显示webview
        showWebView = NO;
    }
    
    if (showWebView) {
        [_hotSearchView removeFromSuperview];
        [self.contentView addSubview:self.webView];
    }
    if (!isEmptyString(self.labelString) && [SSCommonLogic threeTopBarEnable] && !isEmptyString(_fromTabName)){
        [TTTrackerWrapper eventV3:@"search_tab_hot_keyword_search" params:@{@"search_source" : @"top_bar",
                                                                     @"from_tab_name" : _fromTabName}];
    }
    else {
        wrapperTrackEvent(self.labelString, @"hot_keyword_search");
    }
}

- (NSDictionary *)_defaultSearchParameters {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    NSString *from = _from;
    if (isEmptyString(from)) {
        if (_searchViewType == ExploreSearchViewTypeEntrySearch) {
            from = @"media";
        } else if (_searchViewType == ExploreSearchViewTypeChannelSearch) {
            from = @"search_channel";
        } else {
            switch (_fromType) {
                case ListDataSearchFromTypeHotword:
                    from = @"hot";
                    break;
                case ListDataSearchFromTypeTag:
                    from = @"tag";
                    break;
                case ListDataSearchFromTypeContent:
                    from = @"content";
                    break;
                case ListDataSearchFromTypeWebViewMenuItem:
                    from = @"webview_selection";
                    break;
                case ListDataSearchFromDetail:
                    from = @"detail";
                    break;
                case ListDataSearchFromTypeAddFriend:
                    from = @"media";
                case ListDataSearchFromTypeMineTab:
                    break;
                case ListDataSearchFromTypeTab:
                case ListDataSearchFromTypeSuggestion:
                default:
                    from = @"search_tab";
                    break;
            }
        }
        self.from = from;
    }
    
    [parameters setValue:from forKey:@"from"];
    [parameters setValue:self.groupID forKey:@"from_group_id"];
    parameters[@"search_sug"] = @1;
    if ([TTLocationManager sharedManager].placemarkItem) {
        CLLocationCoordinate2D coordinate = [TTLocationManager sharedManager].placemarkItem.coordinate;
        parameters[@"longitude"] = [NSString stringWithFormat:@"%.5f", coordinate.longitude];
        parameters[@"latitude"] = [NSString stringWithFormat:@"%.5f", coordinate.latitude];
    }
    [parameters setValue:[TTSandBoxHelper getCurrentChannel] forKey:@"channel"];
    if ([_from isEqualToString:@"favorite"] || [_from isEqualToString:@"read_history"] || [_from isEqualToString:@"push_history"]) {
        parameters[@"from"] = _from;
    }
    NSString *followButtonColorSetting = [SSCommonLogic followButtonColorStringForWap];
    if (followButtonColorSetting) {
        parameters[@"followbtn_template"] = followButtonColorSetting;
    }
    
    return [parameters copy];
}

- (void) displayHotSearchView {
    [self.contentView addSubview:_hotSearchView];
    [_webView removeFromSuperview];
}

- (BOOL)shouldHideHistorySearchViewWithText:(NSString *)searchText
{
    return (searchText.length > 0) || [self.historyView isContentEmpty];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(TTSeachBarView *)searchBar_ {
    _fromType = ListDataSearchFromTypeTab;
    [self searchWithLabel:@"input_keyword_search"];
}

- (void)searchBar:(TTSeachBarView *)searchBar_ textDidChange:(NSString *)searchText {
    self.fromType = ListDataSearchFromTypeTab;
    
    if (isEmptyString(searchText)) {
        self.suggestionView.searchText = nil;
        if (_isOverlayWebViewEnabled) {
            self.overlayWebView.hidden = NO;
            [self.contentView bringSubviewToFront:self.overlayWebView];
            return;
        } else {
            [self displayHotSearchView];
        }
    }
    
    BOOL previousHidden = self.historyView.hidden;
    self.historyView.hidden = [self shouldHideHistorySearchViewWithText:searchText];
    
    self.suggestionView.hidden = self.hideRecommend || (searchText.length == 0);
    if (!self.suggestionView.hidden) {
        
        // 去掉处于联想状态的单词字母间的1/6空格
        if (searchBar_.searchField.markedTextRange != nil) {
            NSString *markedText = [searchBar_.searchField textInRange:searchBar_.searchField.markedTextRange];
            NSString *markedTextWithNoSpace = [markedText stringByReplacingOccurrencesOfString:@"\u2006" withString:@""];
            UITextRange *markedRange = searchBar_.searchField.markedTextRange;
            UITextPosition* beginning = searchBar_.searchField.beginningOfDocument;
            UITextPosition *selectionStart = markedRange.start;
            UITextPosition *selectionEnd = markedRange.end;
            NSInteger location = [searchBar_.searchField offsetFromPosition:beginning toPosition:selectionStart];
            NSInteger length = [searchBar_.searchField offsetFromPosition:selectionStart toPosition:selectionEnd];
            NSRange range = NSMakeRange(location, length);
            searchText = [searchText stringByReplacingCharactersInRange:range withString:markedTextWithNoSpace];
        }
        
        self.suggestionView.searchText = searchText;
        [self.contentView bringSubviewToFront:self.suggestionView];
        
        self.webView.ssWebView.scrollView.scrollsToTop = NO;
        self.suggestionView.tableView.scrollsToTop = YES;
    }
    else {
        self.webView.ssWebView.scrollView.scrollsToTop = YES;
        self.suggestionView.tableView.scrollsToTop = NO;
    }
    
    /// 先判断原来是不是 可见的,如果本来就可见，说明已经有其他地方统计过了，就不重复统计
    if (!_isOverlayWebViewEnabled && !self.historyView.hidden) {
        [self.contentView bringSubviewToFront:self.historyView];
        if (previousHidden) {
            wrapperTrackEvent(self.labelString, @"history_explore");
        }
    }
}

- (void)searchBarCancelButtonClicked:(TTSeachBarView *)searchBar_ {
    wrapperTrackEvent(self.labelString, @"cancel_search");
    
    
    if ([SSCommonLogic searchCancelClickActionChangeEnable]
        && [self controllersInNavigationControllerHasOnlyOneSearchViewController]
        && [self isShowSearchResultView]
        ) {
        //当前只有一个搜索页面且显示搜索结果页面时点击取消
        //先执行clear操作
        [searchBar_ setText:nil];
        [self searchBar:searchBar_ textDidChange:nil];
        //刷新推荐
        [self.historyView fetchRemoteSuggest];
    }else{
        //不显示搜索结果页面时点击取消，返回到上个页面
        if (self.searchViewDelegate && [self.searchViewDelegate respondsToSelector:@selector(searchViewCancelButtonClicked:)]) {
            [self.searchViewDelegate searchViewCancelButtonClicked:self];
        }
        
        UIViewController * controller = [TTUIResponderHelper topViewControllerFor: self];
        if (controller.navigationController.viewControllers.count > 1) {
            if ([TTCustomAnimationManager sharedManager].pushSearchVCWithCustomAnimation) {
                [((TTNavigationController *)controller.navigationController) popViewControllerByTransitioningAnimationAnimated:self.animatedWhenDismiss];
                [TTCustomAnimationManager sharedManager].pushSearchVCWithCustomAnimation = NO;
            }
            else{
                [controller.navigationController popViewControllerAnimated:self.animatedWhenDismiss];
            }
        } else {
            if (controller.presentingViewController) {
                [controller dismissViewControllerAnimated:self.animatedWhenDismiss completion:nil];
            } else if (controller.navigationController.presentingViewController && controller.navigationController.viewControllers.count == 1) {
                [controller.navigationController dismissViewControllerAnimated:self.animatedWhenDismiss completion:NULL];
            }
        }
    }
    
    if (_fromType == ListDataSearchFromTypeConcern) {
        wrapperTrackEvent(_umengEventString, @"search_cancel");
    }
}

- (void)searchBarTextDidBeginEditing:(TTSeachBarView *)searchBar {
    // 点击了搜索输入框， 判断有无历史搜索记录，如果有历史搜索记录，则显示历史搜索记录
    [self sendStayPageTrack];
    
    self.hasSearchResult = NO;

    self.historyView.hidden = [self shouldHideHistorySearchViewWithText:searchBar.text];
    self.overlayWebView.hidden = NO;//self.historyView.hidden;
    
    if (!self.historyView.hidden && searchBar.isFirstResponder) {
        /////// 友盟统计
        [self.contentView bringSubviewToFront:self.historyView];
        if (!_willDisappear) {
            wrapperTrackEvent(self.labelString, @"history_explore");
        }
    }
    else if (searchBar.text.length > 0) {
        [self searchBar:searchBar textDidChange:searchBar.text];
    }
}

#pragma mark - TTArticleSearchHistoryViewDelegate

- (void)articleSearchHistoryViewDidContentUpdate:(TTArticleSearchHistoryView *)view
{
    if ([self.searchBar isFirstResponder]) {
        self.historyView.hidden = [self shouldHideHistorySearchViewWithText:self.searchBar.text];
    } else {
        self.historyView.hidden = [self.historyView isContentEmpty];
    }
}

#pragma mark - UIKeyboardNotification

- (void) keyboardWillChangeFrame:(NSNotification *) notification {
    NSDictionary * userInfo = notification.userInfo;
    /// keyboard相对于屏幕的坐标
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
	UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
	switch (animationCurve) {
		case UIViewAnimationCurveEaseInOut:
			options = UIViewAnimationOptionCurveEaseInOut;
			break;
		case UIViewAnimationCurveEaseIn:
			options = UIViewAnimationOptionCurveEaseIn;
			break;
		case UIViewAnimationCurveEaseOut:
			options = UIViewAnimationOptionCurveEaseOut;
			break;
		case UIViewAnimationCurveLinear:
			options = UIViewAnimationOptionCurveLinear;
			break;
		default:
            options = animationCurve << 16;
			break;
	}
    
    CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.contentView.bounds;
    frame.size.height = CGRectGetMinY(keyboardScreenFrame) - CGRectGetMinY(frame) - CGRectGetMinY(self.contentView.frame);
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.suggestionView.frame = frame;
        self.historyView.frame = frame;
        self.overlayWebView.frame = frame;
    } completion:NULL];
}

#pragma mark -WebViewDelegate

- (BOOL)webView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    
    NSString * URLString = request.URL.absoluteString;
    if (!request || !URLString) {
        [self refreshData];
        return NO;
    }
    
    // bridge logic
    if([request.URL.scheme isEqualToString:@"bytedance"]) {
        return NO;
    }
    else if ([request.URL.scheme isEqualToString:@"sslocal"]) {
        /// 如果是SSLocal的，则同意处理
        [[TTRoute sharedRoute] openURLByPushViewController:request.URL];
        return NO;
    }
    else if (([URLString rangeOfString:@"/wap/search/"].location != NSNotFound && [URLString rangeOfString:@"snssdk.com/"].location != NSNotFound) || (!isEmptyString(self.searchUrlString) && [URLString rangeOfString:self.searchUrlString].location != NSNotFound))  {
        BOOL needTimestamp = NO;
        if ([URLString rangeOfString:@"#tt_daymode"].location != NSNotFound) {
            // 判断如果已经包含了日夜间的fragment
            NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
            if ([self.class tt_isValidNativeSettingFragmentWithFontTypeString:fontSizeType forURL:request.URL]) {
                NSString *query = request.URL.query;
                NSDictionary *parameters = [TTStringHelper parametersOfURLString:query];
                NSString *searchKey = [parameters valueForKey:@"keyword"];
                BOOL hotWord = [[parameters valueForKey:@"hot_words"] boolValue];
                if (hotWord) {
                    NSString * text = searchKey;
                    if ([searchKey rangeOfString:@"%"].location != NSNotFound) {
                        text = [searchKey stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    }
                    self.searchBar.text = text;
                    [self.historyView.manager insertKeyword:text];
                    _suggestionView.tableView.scrollsToTop = NO;
                }
                return YES;
            }
            /// 如果有夜间模式，但是夜间模式不对的情况下，需要加一个临时的时间戳，不然只修改fragment是不行的
            needTimestamp = YES;
        }
        NSMutableURLRequest *URLRequest = [request mutableCopy];
        NSURL *requestURL = needTimestamp ? [TTURLUtils URLByInsertOrUpdateParameters:@{@"_timestamp":@([[NSDate date] timeIntervalSince1970])} toURL:request.URL] : request.URL;
        NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
        URLRequest.URL = [self.class tt_URLByAppendingNativeSettingFragmentWithFontTypeString:fontSizeType forURL:requestURL];
        [webView loadRequest:URLRequest];
        return NO;
    }
    return YES;
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!([error.domain isEqualToString:kCommonErrorDomain] && error.code == TTNetworkErrorCodeNoNetwork)) {
        NSTimeInterval now = CACurrentMediaTime();
        NSDictionary *userInfo = error.userInfo;
        NSString *failingURLString = [userInfo tt_stringValueForKey:NSURLErrorFailingURLStringErrorKey];
        
        if (self.overlayWebView.ssWebView == webView) {
            if (!self.hasSendSuggestWebLoadFailTime) {
                NSURL *URL = [NSURL tt_URLWithString:[ArticleURLSetting searchInitialPageURLString] parameters:nil];
                if (URL.path && [failingURLString rangeOfString:URL.path].length > 0) {
                    [[TTMonitor shareManager] trackService:@"search_suggest_load_fail" status:1 extra:nil];
                    [Answers logCustomEventWithName:@"searchView" customAttributes:@{@"suggest_load_fail":@((now - self.startLoadTime) * 1000)}];
                    self.hasSendSuggestWebLoadFailTime = YES;
                }
            }
        }
        
        if (self.webView.ssWebView == webView) {
            if (!self.hasSendSearchWebLoadFailTime) {
                NSString *searchUrlString = self.searchUrlString ?: [self defaultSearchURL];
                NSURL *URL = [NSURL tt_URLWithString:searchUrlString parameters:nil];
                if (URL.path && [failingURLString rangeOfString:URL.path].length > 0) {
                    [[TTMonitor shareManager] trackService:@"search_load_fail" status:1 extra:nil];
                    [Answers logCustomEventWithName:@"searchView" customAttributes:@{@"load_fail":@((now - self.startLoadTime) * 1000)}];
                    self.hasSendSearchWebLoadFailTime = YES;
                }
            }
            [self stopCountDownTimer];
        }
    }
    else {
        [self stopCountDownTimer];
    }
}

- (void)webViewDidFinishLoad:(YSWebView *)webView {
    NSTimeInterval now = CACurrentMediaTime();
    
    if (_overlayWebView.ssWebView == webView && !self.hasSendSuggestWebLoadTime) {
        [[TTMonitor shareManager] trackService:@"search_suggest_load" value:@((now - self.startLoadTime) * 1000) extra:nil];
        [Answers logCustomEventWithName:@"searchView" customAttributes:@{@"suggest_load_finish":@((now - self.startLoadTime) * 1000)}];
        self.hasSendSuggestWebLoadTime = YES;
        return;
    }
    
    if (_webView.ssWebView == webView && !self.hasSendSearchWebLoadTime) {
        [[TTMonitor shareManager] trackService:@"search_load" value:@((now - self.startLoadTime) * 1000) extra:nil];
        [Answers logCustomEventWithName:@"searchView" customAttributes:@{@"load_finish":@((now - self.startLoadTime) * 1000)}];
        self.hasSendSearchWebLoadTime = YES;
    }

    if (_isFirstSend) {
        wrapperTrackEvent(self.labelString, @"search_success");
        _isFirstSend = NO;
    }
    
    // 带有搜索词第一次进入时，overlay可能没有加载完毕，搜索历史传不到overlay，所以需要在搜索页加载完毕后刷新一次历史页面
    if (_needReloadOverlayWebView && self.webView.ssWebView.isDomReady) {
        [self loadOverlayWebView];
        _needReloadOverlayWebView = NO;
    }
    
    [self stopCountDownTimer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    return NO;
}

#pragma mark - Helper

+ (BOOL)tt_isValidNativeSettingFragmentWithFontTypeString:(NSString*)fontType forURL:(NSURL *)url
{
    NSString *fragment = url.fragment;
    NSDictionary *parameters = [TTStringHelper parametersOfURLString:fragment];
    BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
    return ([parameters[@"tt_daymode"] boolValue] == isDayMode) && [fontType isEqualToString:parameters[@"tt_font"]];
}

+ (NSURL *)tt_URLByAppendingNativeSettingFragmentWithFontTypeString:(NSString*)fontType forURL:(NSURL *)url
{
    BOOL isDayMode = ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay);
    // 如果已经存在fragment,就去掉原来的fragment（王老师说头条这边肯定没问题），然后添加新的fragment
    NSString *fragment = [NSString stringWithFormat:@"#tt_daymode=%@&tt_font=%@",@(isDayMode), fontType];
    NSString *temp = url.absoluteString;
    NSRange range = [temp rangeOfString:@"#"];
    if (range.location != NSNotFound) {
        temp = [temp substringToIndex:range.location];
    }
    NSString *absoluteString = [temp stringByAppendingString:fragment];
    return [NSURL URLWithString:absoluteString];
}

- (BOOL)controllersInNavigationControllerHasOnlyOneSearchViewController{
    UIViewController * controller = [TTUIResponderHelper topViewControllerFor: self];
    NSInteger searchViewControllerCount = 0;
    for (UIViewController *vc in controller.navigationController.viewControllers) {
        if ([vc isKindOfClass:[ExploreSearchViewController class]]) {
            searchViewControllerCount += 1;
        }
        if (searchViewControllerCount >= 2) {
            return NO;
        }
    }
    return searchViewControllerCount == 1;
}

- (BOOL)isShowSearchResultView{
    //contentView的subView的frame都是self.contentView.bounds,因此如果最上层显示的View是self.webView,即是显示了搜索结果
    UIView *topView = nil;
    for (NSInteger i = self.contentView.subviews.count - 1; i >= 0; i --) {
        UIView *tmpView = self.contentView.subviews[i];
        if (!tmpView.isHidden) {
            topView = tmpView;
            break;
        }
    }
    return topView != nil && topView == self.webView;
}
#pragma mark - WhitePageMonitor

- (void)startCountDownTimer{
    if (![SSCommonLogic enabledWhitePageMonitor]) {
        return;
    }
    if (self.countDownTimer) {
        if ([self.countDownTimer isValid]) {
            [self.countDownTimer invalidate];
        }
        self.countDownTimer = nil;
    }
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(guardTimerExceeded:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCountDownTimer{
    if (self.countDownTimer) {
        if ([self.countDownTimer isValid]) {
            [self.countDownTimer invalidate];
        }
        self.countDownTimer = nil;
    }
}

- (void)guardTimerExceeded:(id)sender{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] init];
    [params setValue:[self.realSearchUrlString URLEncodedString] forKey:@"url"];
    NSURL * url = [NSURL URLWithString:self.realSearchUrlString];
    if (url) {
        [params setValue:[url host] forKey:@"hostname"];
    }
    [params setValue:@"search" forKey:@"pathname"];
    [params setValue:@"fail" forKey:@"page_status"];
    [params setValue:[TTNetworkHelper connectMethodName] forKey:@"net_type"];
    [self stopCountDownTimer];
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:@"http://toutiao.com/__utm.gif" params:params method:@"GET" needCommonParams:YES callback:nil];
}

#pragma mark -

- (void)refreshData {
    NSString *text = [self.searchBar.text trimmed];
    if (!isEmptyString(text)) {
        [self searchWithLabel:text];
    }
}

- (void)loadOverlayWebView {
    NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithCapacity:3];
    
    NSString *from = nil;
    NSString *category = nil;
    
    if (self.fromType == ListDataSearchFromTypeTab ||
        self.fromType == ListDataSearchFromTypeFeed) {
        from = @"feed";
        category= self.categoryID;
    }
    else if (self.fromType == ListDataSearchFromTypeVideo) {
        from = @"video";
    }
    else if (self.fromType == ListDataSearchFromTypeConcern) {
        from = @"concern";
    }
    else if (self.fromType == ListDataSearchFromTypeWeitoutiao){
        from = @"weitoutiao";
    }
    
    if (from) [mParameters setValue:from forKey:@"from"];
    if (category) [mParameters setValue:category forKey:@"sug_category"];
    
    NSString *placeholder = [SSCommonLogic searchBarTipForNormal];
    
    if ([SSCommonLogic threeTopBarEnable] && self.fromType == ListDataSearchFromTypeVideo){
        placeholder = [SSCommonLogic searchBarTipForVideo];
    }

    [mParameters setValue:(placeholder?:@"") forKey:@"homepage_search_suggest"];

    NSDictionary *dict = [TTNetworkUtilities commonURLParametersAppendKeyAndValues:mParameters];
    
    NSURL *URL = [NSURL tt_URLWithString:[ArticleURLSetting searchInitialPageURLString] parameters:dict];
    URL = [URL tt_URLByUpdatingFragmentForNativeSetting];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [self.overlayWebView loadRequest:request];
}

- (void)registerOverlayWebViewJSBridge {
    WeakSelf;
    [self.overlayWebView.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        StrongSelf;
        self.overlaySearchDict = result;
        NSString *keyword = [result tt_stringValueForKey:@"keyword"];
        self.overlayWebView.hidden = YES;
        self.searchBar.text = keyword;
        self.fromType = ListDataSearchFromTypeHotword;
        [self searchWithLabel:@"hot_keyword_search"];
        
        TTR_CALLBACK_SUCCESS
    } forMethodName:@"search"];
}

- (void)updateOverlayWebViewSearchHistory:(NSString *)text {
    NSString *js = [NSString stringWithFormat:@"updateHistory('%@')", text];
    [self.overlayWebView.ssWebView evaluateJavaScriptFromString:js completionBlock:nil];
}

#pragma mark -- stay page track

- (void)resetStayPageTrack
{
    _startDate = [NSDate date];
}

- (void)sendStayPageTrack
{
    if (!_startDate) {
        return;
    }
    
    if (!self.hasSearchResult){
        return;
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_startDate];
    
    if (timeInterval < 0) {
        return;
    }

    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
        wrapperTrackEventWithCustomKeys(@"stay_page_search", @"click_search", [NSString stringWithFormat:@"%.0f", timeInterval*1000], self.from , nil);
    }

    //log3.0
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:5];
    [param setValue:@"search" forKey:@"category_name"];
    [param setValue:@"click_search" forKey:@"enter_from"];
    [param setValue:self.from forKey:@"source"];
    [param setValue:@((long long)(timeInterval * 1000)) forKey:@"stay_time"];
    [param setValue:self.defaultQuery forKey:@"query"];
    [TTTrackerWrapper eventV3:@"stay_page_search" params:param isDoubleSending:YES];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:@(timeInterval) forKey:@"stayPage"];
    [dict setValue:self.from forKey:@"from"];
    [Answers logCustomEventWithName:@"searchView" customAttributes:dict];
    
    [self resetStayPageTrack];
}

+ (NSString*)constructURLStringFrom:(NSString*)urlStr getParameter:(NSDictionary*)getParameter
{
    NSMutableString *string = [NSMutableString stringWithString:urlStr];
    NSRange range = [urlStr rangeOfString:@"?"];
    NSString *sep = (range.location == NSNotFound) ? @"?" : @"&";
    NSEnumerator *getEnum = [getParameter keyEnumerator];
    NSString *key = nil;
    
    if(!isEmptyString([[TTInstallIDManager sharedInstance] installID]) && [string rangeOfString:@"iid"].location == NSNotFound)
    {
        [string appendFormat:@"%@iid=%@", sep, [[TTInstallIDManager sharedInstance] installID]];
        sep = @"&";
    }
    
    // append city, latitiude, longitude first
    if([getParameter objectForKey:@"city"])
    {
        [string appendFormat:@"%@city=%@", sep, [getParameter objectForKey:@"city"]];
        sep = @"&";
    }
    
    if([getParameter objectForKey:@"longitude"])
    {
        [string appendFormat:@"%@longitude=%@", sep, [getParameter objectForKey:@"longitude"]];
        sep = @"&";
    }
    
    if([getParameter objectForKey:@"latitude"])
    {
        [string appendFormat:@"%@latitude=%@", sep, [getParameter objectForKey:@"latitude"]];
        sep = @"&";
    }
    
    NSString *str = [TTNetworkUtilities customURLStringFromString:string];
    
    // 处理"device=iPhone Simulator"中的空格，否则URLWithString会返回nil
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    string = [NSMutableString stringWithString:str];
    
    while((key = [getEnum nextObject]) != nil)
    {
        // appended before
        if(![key isEqualToString:@"city"] && ![key isEqualToString:@"longitude"] && ![key isEqualToString:@"latitude"])
        {
            NSString *fieldStr = [NSString stringWithFormat:@"%@", [getParameter objectForKey:key]];
            NSString *value = (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)fieldStr, NULL, (__bridge CFStringRef)@":/?&=;+!@#$()',*", kCFStringEncodingUTF8);
            
            [string appendFormat:@"%@%@=%@", sep, key, value];
            sep = @"&";
        }
    }
    
    return [string copy];
}

- (NSString *)defaultSearchURL {
    NSDictionary *config = [[TTSettingsManager sharedManager] settingForKey:@"tt_h5_offline_config" defaultValue:@{} freeze:NO];
    
    if (![config isKindOfClass:[NSDictionary class]]) {
        return [ArticleURLSetting searchWebURLString];
    }
    
    NSDictionary *searchConfig = [config tt_dictionaryValueForKey:@"search"];
    if (![searchConfig tt_boolValueForKey:@"enable"]) {
        return [ArticleURLSetting searchWebURLString];
    }
    
    NSInteger projectID = [searchConfig tt_integerValueForKey:@"project_id"];
    if (projectID > 0) {
        return [[ArticleURLSetting searchWebURLString] stringByAppendingFormat:@"?tt_project_id=%ld", projectID];
    }
    
    return [ArticleURLSetting searchWebURLString];
}
@end
