//
//  TTFeedCollectionCell.h
//  Article
//
//  Created by Chen Hong on 2017/3/28.
//
//

#import <Foundation/Foundation.h>
#import "TTCategoryDefine.h"
#import "ListDataHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTFeedCategory;

@protocol TTFeedCollectionCell <NSObject>

- (void)setupCellModel:(nonnull id<TTFeedCategory>)model isDisplay:(BOOL)isDisplay;
- (id<TTFeedCategory>)categoryModel;

- (void)refreshDataWithType:(ListDataOperationReloadFromType)refreshType;
- (void)refreshIfNeeded;

- (void)willAppear;
- (void)didAppear;
- (void)willDisappear;
- (void)didDisappear;
- (void)cellWillEnterForground;
- (void)cellWillEnterBackground;

// iPad刷新按钮
- (BOOL)shouldAnimateRefreshView;
- (BOOL)shouldHideRefreshView;
- (BOOL)IsEmptySubscribeList;

@optional
@property (nonatomic, weak) UIViewController *sourceViewController;

@end

@protocol TTFeedCollectionCellDelegate <NSObject>

@optional
- (void)ttFeedCollectionCellStartLoading:(id<TTFeedCollectionCell>)feedCollectionCell;

- (void)ttFeedCollectionCellStopLoading:(id<TTFeedCollectionCell>)feedCollectionCell isPullDownRefresh:(BOOL)isPullDownRefresh;

@end

@interface TTFeedCollectionCell : UICollectionViewCell <TTFeedCollectionCell>

@property (nonatomic, weak, nullable) id<TTFeedCollectionCellDelegate> delegate;

@end



// 频道助手类，频道Cell提供方注册自己的cellHelper
@protocol TTFeedCollectionCellHelper <NSObject>

// 分发不同的频道model到对应的FeedCollectionCell类，只处理自己关心的频道Model，否则返回nil
+ (nullable Class<TTFeedCollectionCell>)cellClassFromFeedCategory:(nonnull id<TTFeedCategory>)feedCategory;

+ (NSArray<Class<TTFeedCollectionCell>> *)supportedCellClasses;

@end

NS_ASSUME_NONNULL_END
