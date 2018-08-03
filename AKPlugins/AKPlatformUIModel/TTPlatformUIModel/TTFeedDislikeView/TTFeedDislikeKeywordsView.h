//
//  TTFeedDislikeKeywordsView.h
//  Article
//
//  Created by Chen Hong on 14/11/19.
//
//

#import "SSViewBase.h"

@protocol TTFeedDislikeKeywordsViewDelegate;

@interface TTFeedDislikeKeywordsView : SSViewBase

@property(nonatomic,weak)id<TTFeedDislikeKeywordsViewDelegate> delegate;

- (void)refreshWithData:(NSArray *)keywords;

// 所有选中的
- (NSArray *)selectedKeywords;

// 是否有选中的
- (BOOL)hasKeywordSelected;

- (CGFloat)paddingY;

@end

@protocol TTFeedDislikeKeywordsViewDelegate <NSObject>

@optional
// 选中/未选切换
- (void)dislikeKeywordsSelectionChanged;

@end
