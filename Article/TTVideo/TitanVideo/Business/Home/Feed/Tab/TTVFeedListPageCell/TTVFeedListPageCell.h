//
//  TTVFeedListPageCell.h
//  Article
//
//  Created by 刘廷勇 on 16/1/15.
//
//

#import <Foundation/Foundation.h>
#import "TTCollectionPageViewController.h"
@class TTCategory;
@class TTVFeedListViewController;
@protocol TTVFeedListPageCellDelegate;

@interface TTVFeedListPageCell : UICollectionViewCell <TTCollectionCell>

@property (nonatomic, weak)   id<TTVFeedListPageCellDelegate> delegate;
@property (nonatomic, strong) TTVFeedListViewController     *feedListViewController;
@property (nonatomic, strong) TTCategory                    *category;

- (void)refreshIfNeeded;
- (void)triggerPullRefresh;
- (void)setHeaderView:(UIView *)headerView;

@end

@protocol TTVFeedListPageCellDelegate <NSObject>

@optional
- (void)listViewOfTTCollectionPageCellStartLoading:(TTVFeedListPageCell *)collectionPageCell;
- (void)listViewOfTTCollectionPageCellEndLoading:(TTVFeedListPageCell *)collectionPageCell;
- (UIView *)headerViewForCell:(TTVFeedListPageCell *)collectionPageCell;

@end
