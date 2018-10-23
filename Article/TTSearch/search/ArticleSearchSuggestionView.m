//
//  ArticleSearchSuggestionView.m
//  Article
//
//  Created by SunJiangting on 14-7-6.
//
//

#import "ArticleSearchSuggestionView.h"
#import "TTNetworkManager.h"
#import "ArticleURLSetting.h"
#import "ArticleSearchBaseCell.h"
#import "NSDictionary+TTAdditions.h"
#import "TTSearchSugModel.h"

@interface ArticleSearchSuggestionView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) TTHttpTask *httpTask;

@property (nonatomic, strong) NSArray    *suggestions;

@end


@implementation ArticleSearchSuggestionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tableView = [[SSThemedTableView alloc] initWithFrame:self.bounds];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColorThemeKey = kColorBackground4;
        self.tableView.rowHeight = 42.0;
        [self addSubview:self.tableView];
        [self.tableView registerClass:[ArticleSearchBaseCell class] forCellReuseIdentifier:@"Identifier"];
        [self reloadThemeUI];
    }
    return self;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.suggestions.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArticleSearchBaseCell * tableViewCell = (ArticleSearchBaseCell *)[tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    NSString * title = ((TTSearchSugItem *)[self.suggestions objectAtIndex:indexPath.row]).keyword ?: @"";
    NSString * keyWord = _searchText;
    NSAssert(keyWord != nil, @"keyword is nil");
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:title];
    if (keyWord) {
        NSRange keyWordRange = [title rangeOfString:keyWord];
        NSRange titleRange = [title rangeOfString:title];
        [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText1] range:titleRange];
        if (keyWordRange.location != NSNotFound) {
            [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText4] range:keyWordRange];
        }
    }
    tableViewCell.keywordLabel.attributedText = attStr;
    return tableViewCell;
}

#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * title = ((TTSearchSugItem *)[self.suggestions objectAtIndex:indexPath.row]).keyword;
    /////// 友盟统计
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.searchText forKey:@"raw_query"];
    [dic setValue:title forKey:@"click_query"];
    TLS_LOG(@"click_query=%@",self.searchText);
    wrapperTrackEventWithCustomKeys(@"search_tab", [NSString stringWithFormat:@"clicksug_%ld",(long) indexPath.row + 1], nil, nil, dic);
    if (self.selectedHandler) {
        self.selectedHandler(title);
    }
}

- (void) fetchSuggestionKeyword {
    if (self.searchText.length == 0) {
        self.suggestions = nil;
        [self.tableView reloadData];
        return;
    }
    WeakSelf;
    NSMutableDictionary * getParamDicts = [NSMutableDictionary dictionaryWithCapacity:10];
    [getParamDicts setValue:_searchText forKey:@"keyword"];
    [getParamDicts setValue:_fromParam forKey:@"from"];
    [getParamDicts setValue:_curTab forKey:@"cur_tab"];
    NSString *keyword = [_searchText copy];
    
    self.httpTask = [[TTNetworkManager shareInstance] requestForJSONWithURL:[ArticleURLSetting searchSuggestionURLString] params:getParamDicts method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (error) {
            return;
        }
        
        StrongSelf;
        
        if (![keyword isEqualToString:self.searchText]) {
            return;
        }
        
        NSError *jsonError = nil;
        
        if (jsonObj) {
            jsonObj = @{@"result":jsonObj};
        }
        TTSearchSugModel *model = [[TTSearchSugModel alloc] initWithDictionary:jsonObj error:&jsonError];
        if (!jsonError && model.result.data) {
            self.suggestions = model.result.data;
            [self.tableView reloadData];
        }
    }];
}

- (void) setSearchText:(NSString *)searchText {
    _searchText = [searchText copy];
    if (self.httpTask) {
        [self.httpTask cancel];
    }
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(fetchSuggestionKeyword) object:nil];
    if (searchText.length == 0 /*|| [searchText dataUsingEncoding:NSUTF8StringEncoding].length <= 1*/) {
        self.suggestions = nil;
        [self.tableView reloadData];
        return;
    }
    [self performSelector:@selector(fetchSuggestionKeyword) withObject:nil afterDelay:0.3];
}

@end
