//
//  TTFeedCollectionViewController.h
//  Article
//
//  Created by Chen Hong on 2017/3/28.
//
//

#import <UIKit/UIKit.h>
#import "TTFeedCollectionCell.h"
#import "TTFeedCollectionViewControllerDelegate.h"
#import "TTCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFeedCollectionViewController : UIViewController

- (instancetype)initWithName:(NSString *)name topInset:(CGFloat)topInset bottomInset:(CGFloat)bottomInset;

@property (nonatomic, copy, readonly) NSString *name;

/**
 *  Model. Page will reload after setting newValue.
 */
@property (nonatomic, copy) NSArray<TTCategory *> *pageCategories;

/**
 *  Currently selected page index
 */
@property (nonatomic, readonly) NSInteger currentIndex;

/**
 *  Delegate
 */
@property (nonatomic, weak, nullable) id<TTFeedCollectionViewControllerDelegate> delegate;

/**
 *  Update current page index and scroll to centered position
 */
- (void)setCurrentIndex:(NSInteger)index scrollToPositionAnimated:(BOOL)animated;

/// 获取 CollectionView 当前展示的 Cell
- (UICollectionViewCell<TTFeedCollectionCell> *)currentCollectionPageCell;

- (UICollectionViewCell<TTFeedCollectionCell> *)pageCellAtIndex:(NSInteger)index;

- (nullable TTCategory *)currentCategory;

- (TTCategory *)categoryAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
