//
//  TTArticleSearchHistoryView.h
//  Article
//
//  Created by yangning on 2017/4/17.
//
//

#import "SSViewBase.h"
#import "TTArticleSearchManager.h"

@protocol TTArticleSearchHistoryViewDelegate;
@class ArticleSearchBar;
@interface TTArticleSearchHistoryView : SSViewBase

@property (nonatomic, weak) ArticleSearchBar *searchBar;

@property (nonatomic, readonly) TTArticleSearchManager *manager;

@property (nonatomic, copy) void(^selectedHandler)(TTArticleSearchKeyword *searchKeyword);

// Default is `search_tab`
@property (nonatomic, copy) NSString *umengEventName;

@property (nonatomic, weak) id<TTArticleSearchHistoryViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                      context:(void(^)(TTArticleSearchHistoryContext *))block;

- (BOOL)isContentEmpty;

- (NSString *)eventTrackTag;

- (void)fetchRemoteSuggest;
@end

@protocol TTArticleSearchHistoryViewDelegate <NSObject>

@optional
- (void)articleSearchHistoryViewDidContentUpdate:(TTArticleSearchHistoryView *)view;

@end

