//
//  ArticleSearchSuggestionView.h
//  Article
//
//  Created by SunJiangting on 14-7-6.
//
//

#import "SSViewBase.h"
#import "SSThemed.h"

@interface ArticleSearchSuggestionView : SSViewBase

@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, copy) NSString *fromParam;
@property (nonatomic, copy) NSString *curTab;

@property (nonatomic, copy) void (^selectedHandler)(NSString * keyword);

@end
