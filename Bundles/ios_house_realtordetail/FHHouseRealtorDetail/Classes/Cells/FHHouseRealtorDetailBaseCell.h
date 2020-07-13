//
//  FHHouseDetailBaseCell.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRealtorDetailBaseCell : UITableViewCell
// 子类需要重写的方法，根据数据源刷新当前Cell，以及布局
- (void)refreshWithData:(id)data;
// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

// 当前cell的模型数据
@property (nonatomic, weak , nullable) id currentData;
@end

NS_ASSUME_NONNULL_END
