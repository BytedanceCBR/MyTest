//
//  TTArticleSearchHistoryView.m
//  Article
//
//  Created by yangning on 2017/4/17.
//
//

#import "TTArticleSearchHistoryView.h"
#import "SSThemed.h"
#import "TTArticleSearchCell.h"
#import "TTArticleSearchViewModel.h"
#import "ArticleSearchBar.h"

static NSString *const kTTArticleSearchInboxCellIdentifer   = @"TTArticleSearchInboxKeywordsCellIdentifer";
static NSString *const kTTArticleSearchHeaderCellIdentifer          = @"TTArticleSearchHeaderCell";
static NSString *const kTTArticleSearchCellIdentifer                = @"TTArticleSearchCell";
static NSString *const kTTArticleSearchFooterCellIdentifer          = @"TTArticleSearchFooterCell";

@interface TTArticleSearchHistoryView () <UITableViewDataSource, UITableViewDelegate, TTArticleSearchManagerDelegate, TTArticleSearchViewModelDelegate>

@property (nonatomic, strong) SSThemedTableView *tableView;

@property (nonatomic) TTArticleSearchManager *manager;

@property (nonatomic) TTArticleSearchViewModel *viewModel;

@end

@implementation TTArticleSearchHistoryView

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame context:(void(^)(TTArticleSearchHistoryContext *))block
{
    if (self = [super initWithFrame:frame]) {
        _umengEventName = @"search_tab";
        
        [self setupUI];
        
        _manager = [[TTArticleSearchManager alloc] initWithContext:block];
        _manager.delegate = self;
        
        [self reload];
        [self fetchRemoteSuggest];
    }
    return self;
}

- (BOOL)isContentEmpty
{
    return [self.manager isContentEmpty];
}

- (void)setupUI
{
    [self addSubview:self.tableView];
}

- (void)fetchRemoteSuggest
{
    [self.manager fetchSearchSuggestInfo];
}

- (void)reload
{
    NSArray<TTArticleSearchKeyword *> *inboxKeywords = [self.manager inboxKeywords];
    NSArray<TTArticleSearchKeyword *> *historyKeywords = [self.manager historyKeywords];
    NSArray<TTArticleSearchKeyword *> *recommendKeywords = [self.manager recommendKeywords];
    
    if ([SSCommonLogic searchHintSuggestEnable]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (inboxKeywords.count > 0) {
            [array addObject:[inboxKeywords firstObject]];
            inboxKeywords = array;
        }
    }
    
    if (!self.viewModel) {
        self.viewModel = [[TTArticleSearchViewModel alloc] initWithManager:self.manager
                                                             inboxKeywords:inboxKeywords
                                                           historyKeywords:historyKeywords
                                                         recommendKeywords:recommendKeywords];
        self.viewModel.view = self;
    } else {
        [self.viewModel updateWithInboxKeywords:inboxKeywords historyKeywords:historyKeywords recommendKeywords:recommendKeywords];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(articleSearchHistoryViewDidContentUpdate:)]) {
        [self.delegate articleSearchHistoryViewDidContentUpdate:self];
    }
    
    [self.tableView reloadData];
}

- (NSString *)eventTrackTag
{
    return isEmptyString(self.umengEventName) ? @"search_tab" : self.umengEventName;
}

#pragma mark - Custom accessors

- (SSThemedTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[SSThemedTableView alloc] initWithFrame:self.bounds];
        _tableView.backgroundView = nil;
        _tableView.backgroundColorThemeKey = kColorBackground4;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollsToTop = NO;
        
        [_tableView registerClass:[TTArticleSearchInboxCell class] forCellReuseIdentifier:kTTArticleSearchInboxCellIdentifer];
        [_tableView registerClass:[TTArticleSearchHeaderCell class] forCellReuseIdentifier:kTTArticleSearchHeaderCellIdentifer];
        [_tableView registerClass:[TTArticleSearchCell class] forCellReuseIdentifier:kTTArticleSearchCellIdentifer];
        [_tableView registerClass:[TTArticleSearchFooterCell class] forCellReuseIdentifier:kTTArticleSearchFooterCellIdentifer];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.viewModel numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if ([self.viewModel isHeaderCellAtIndexPath:indexPath]) {
        TTArticleSearchHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTArticleSearchHeaderCellIdentifer
                                                                          forIndexPath:indexPath];
        
        TTArticleSearchHeaderCellViewModel *headerCellViewModel = [self.viewModel headerCellViewModelInSection:section];
        [cell configureWithViewModel:headerCellViewModel];
        return cell;
    } else if ([self.viewModel isFooterCellAtIndexPath:indexPath]) {
        TTArticleSearchFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTArticleSearchFooterCellIdentifer
                                                                          forIndexPath:indexPath];
        return cell;
    } else if ([self.viewModel isInboxCellAtIndexPath:indexPath]) {
        TTArticleSearchInboxCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTArticleSearchInboxCellIdentifer
                                                                         forIndexPath:indexPath];
        
        for (NSInteger i = 0; i < TTArticleSearchInboxCellItemCountPerRow; ++i) {
            TTArticleSearchCellItemViewModel *itemViewModel = [self.viewModel itemViewModelAtIndexPath:indexPath
                                                                                              subIndex:i
                                                                                                offset:0
                                                                                              rowCount:TTArticleSearchInboxCellItemCountPerRow];
            [cell configureWithItemViewModel:itemViewModel atSubIndex:i];
        }
        
        return cell;
    } else {
        TTArticleSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTArticleSearchCellIdentifer
                                                                    forIndexPath:indexPath];
        
        for (NSInteger i = 0; i < TTArticleSearchCellItemCountPerRow; ++i) {
            TTArticleSearchCellItemViewModel *itemViewModel = [self.viewModel itemViewModelAtIndexPath:indexPath
                                                                                              subIndex:i
                                                                                                offset:1
                                                                                              rowCount:TTArticleSearchCellItemCountPerRow];
            [cell configureWithItemViewModel:itemViewModel atSubIndex:i];
        }
        return cell;
    }
    
    NSAssert(0, @"Should not reach here.");
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blank"];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel heightForRowAtIndexPath:indexPath];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - TTArticleSearchManagerDelegate

- (void)articleSearchManager:(TTArticleSearchManager *)manager didUpdateWithError:(NSError *)error
{
    [self reload];
}

#pragma mark - TTArticleSearchViewModelDelegate

- (void)articleSearchViewModelDidUpate:(TTArticleSearchViewModel *)viewModel
{
    [self.tableView reloadData];
}

@end
