//
//  FHDetailBottomOpenAllView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/17.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailBottomOpenAllView : UIView

// Cell点击事件，可以不用实现
@property (nonatomic, copy)     dispatch_block_t       didClickCellBlk;

@end

NS_ASSUME_NONNULL_END
