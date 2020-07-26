//
//  FHHouseDetailBaseCell.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^cellRefreshComplete)(void);
@interface FHHouseRealtorDetailBaseCell : UITableViewCell
// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;
// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

@property (nonatomic, copy) cellRefreshComplete cellRefreshComplete;
//@property (nonatomic, copy) cellRefreshComplete cellRefreshComplete;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;
@end

@class FHHouseRealtorDetailCollectionCell;
@protocol FHHouseRealtorDetailCollectionCellDelegate <NSObject>

- (void)clickCellItem:(UIView *)itemView onCell:(FHHouseRealtorDetailCollectionCell*)cell;

@end
// FHDetailBaseCollectionCell
@interface FHHouseRealtorDetailCollectionCell : UICollectionViewCell

@property (assign, nonatomic) NSInteger selfIndex;

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

// 当前cell的代理对象
@property (nonatomic, weak) id<FHHouseRealtorDetailCollectionCellDelegate> delegate;

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

@property (nonatomic, copy) cellRefreshComplete cellRefreshComplete;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;
@end
NS_ASSUME_NONNULL_END
