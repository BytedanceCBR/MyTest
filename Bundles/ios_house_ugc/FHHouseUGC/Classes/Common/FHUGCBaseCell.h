//
//  FHUGCBaseCell.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/3.
//

#import <UIKit/UIKit.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCBaseCell : UITableViewCell

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

@end

// FHUGCBaseCollectionCell
@interface FHUGCBaseCollectionCell : UICollectionViewCell

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;

// 当前方法不需重写
+ (Class)cellViewClass;

// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

@end

NS_ASSUME_NONNULL_END
