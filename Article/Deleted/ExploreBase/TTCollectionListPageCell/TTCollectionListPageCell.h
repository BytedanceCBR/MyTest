//
//  TTCollectionListPageCell.h
//  Article
//
//  Created by 刘廷勇 on 16/1/15.
//
//

#import <Foundation/Foundation.h>
#import "TTCollectionPageViewController.h"

@class ExploreMixedListView;
@class TTCategory;
@protocol TTCollectionListPageCellDelegate;

@interface TTCollectionListPageCell : UICollectionViewCell <TTCollectionCell>

@property (nonatomic, weak)   id<TTCollectionListPageCellDelegate> delegate;
@property (nonatomic, strong) ExploreMixedListView             *listView;
@property (nonatomic, strong) TTCategory                    *category;

- (void)refreshIfNeeded;
- (void)triggerPullRefresh;
- (void)setHeaderView:(UIView *)headerView;

@end

@protocol TTCollectionListPageCellDelegate <NSObject>

@optional
- (void)listViewOfTTCollectionPageCellStartLoading:(TTCollectionListPageCell *)collectionPageCell;
- (void)listViewOfTTCollectionPageCellEndLoading:(TTCollectionListPageCell *)collectionPageCell;
- (UIView *)headerViewForCell:(TTCollectionListPageCell *)collectionPageCell;

@end
