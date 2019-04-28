//
//  TTArticleSearchViewModel.h
//  Article
//
//  Created by yangning on 2017/4/18.
//
//

#import <Foundation/Foundation.h>

extern const NSInteger TTArticleSearchCellItemCountPerRow;
extern const NSInteger TTArticleSearchInboxCellItemCountPerRow;

@class TTArticleSearchManager;
@class TTArticleSearchKeyword;
@class TTArticleSearchHistoryView;
@class TTArticleSearchHeaderCellViewModel;
@class TTArticleSearchCellItemViewModel;

@protocol TTArticleSearchViewModelDelegate;
@interface TTArticleSearchViewModel : NSObject

@property (nonatomic, weak) TTArticleSearchHistoryView<TTArticleSearchViewModelDelegate> *view;

- (instancetype)initWithManager:(TTArticleSearchManager *)manager
                  inboxKeywords:(NSArray<TTArticleSearchKeyword *> *)inboxKeywords
                historyKeywords:(NSArray<TTArticleSearchKeyword *> *)historyKeywords
              recommendKeywords:(NSArray<TTArticleSearchKeyword *> *)recommendKeywords;

- (void)updateWithInboxKeywords:(NSArray<TTArticleSearchKeyword *> *)inboxKeywords
                historyKeywords:(NSArray<TTArticleSearchKeyword *> *)historyKeywords
              recommendKeywords:(NSArray<TTArticleSearchKeyword *> *)recommendKeywords;

- (NSInteger)numberOfSections;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

- (BOOL)isInboxCellAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isHeaderCellAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isFooterCellAtIndexPath:(NSIndexPath *)indexPath;

- (TTArticleSearchHeaderCellViewModel *)headerCellViewModelInSection:(NSInteger)section;

- (TTArticleSearchCellItemViewModel *)itemViewModelAtIndexPath:(NSIndexPath *)indexPath
                                                      subIndex:(NSInteger)subIndex
                                                        offset:(NSInteger)offset
                                                      rowCount:(NSInteger)rowCount;

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol TTArticleSearchViewModelDelegate <NSObject>

@required
- (void)articleSearchViewModelDidUpate:(TTArticleSearchViewModel *)viewModel;

@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchCellItemViewModel : NSObject

@property (nonatomic, readonly, copy) NSString *text;
@property (nonatomic, readonly, getter=isEditing) BOOL editing;
@property (nonatomic, readonly, copy) void(^actionBlock)(BOOL isEditing);

@end

//////////////////////////////////////////////////////////////////////////////////////

@interface TTArticleSearchHeaderCellViewModel : NSObject

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *titleIcon;
@property (nonatomic, readonly, copy) NSString *actionText;
@property (nonatomic, readonly, copy) NSString *actionIcon;
@property (nonatomic, readonly, copy) void(^titleBlock)();
@property (nonatomic, readonly, copy) void(^actionBlock)();
@property (nonatomic, readonly, getter=isClosing) BOOL closing;

@end
