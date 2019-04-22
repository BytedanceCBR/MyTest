//
//  ArticleBaseListView.h
//  Article
//
//  Created by Yu Tianhang on 13-2-22.
//
//

#import "SSViewBase.h"
#import "TTCategory.h"
#import "ListDataHeader.h"

@class ArticleBaseListView;
@protocol ArticleBaseListViewDelegate <NSObject>
- (void)listViewStartLoading:(ArticleBaseListView*)listView;
- (void)listViewStopLoading:(ArticleBaseListView*)listView;
@end

@interface ArticleBaseListView : SSViewBase

@property(nonatomic, assign, readonly)CGFloat bottomInset;
@property (nonatomic, strong) NSString * enterType;

 
#pragma mark - protected
/**
    @param name display:当前是显示的频道
 */
- (void)refreshListViewForCategory:(TTCategory *)category isDisplayView:(BOOL)display fromLocal:(BOOL)fromLocal fromRemote:(BOOL)fromRemote reloadFromType:(ListDataOperationReloadFromType)fromType;
- (void)refreshDisplayView:(BOOL)display;

- (void)pullAndRefresh;
- (void)scrollToBottomAndLoadmore;
- (void)refresh;
- (void)closePadComments;
- (void)scrollToTopEnable:(BOOL)enable;
- (void)cacheCleared:(NSNotification*)notification;
- (void)cancelAllOperation;
- (void)listViewWillEnterForground;
- (void)listViewWillEnterBackground;
- (BOOL)needClearRecommendTabBadge;
- (void)refreshCategory:(TTCategory *)model;

@property(nonatomic, assign)BOOL isCurrentDisplayView;//是否是当前正在显示的View
@property(nonatomic, retain)TTCategory *currentCategory;
@property(nonatomic, weak)NSObject<ArticleBaseListViewDelegate> *delegate;

- (void)trackPullDownEventForLabel:(NSString *)label;

@end
