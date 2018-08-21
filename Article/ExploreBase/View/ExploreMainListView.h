//
//  ExploreMainListView.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-5.
//
//

#import "SSViewBase.h"
#import "SSHorizenScrollView.h"
#import "SSThemed.h"
#import "CategorySelectorView.h"

@protocol ExploreMainListViewDelegate;

@class TTFeedRefreshView;

@interface ExploreMainListView : SSThemedView

@property(nonatomic, assign)id<ExploreMainListViewDelegate>delegate;
@property(nonatomic, strong, readonly)SSHorizenScrollView * exploreListView;
@property(nonatomic, strong, readonly)CategorySelectorView *categorySelectorView;
@property(nonatomic, retain)CategoryModel *currentCategory;
@property (nonatomic, assign, readonly) CGFloat bottomInset;

@property(nonatomic, strong)UIView *barView;
@property (nonatomic, strong) TTFeedRefreshView *refreshView;

- (UIView *)currentDisplayView;

- (id)initWithFrame:(CGRect)frame topInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset;

@end

@protocol ExploreMainListViewDelegate <NSObject>

@optional

- (void)exploreMainListViewDisplayViewDidStartLoad:(ExploreMainListView *)listView;
- (void)exploreMainListViewDisplayViewDidEndLoad:(ExploreMainListView *)listView;

@end
