//
//  FHDetailOldNearbyMapCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailOldNearbyMapCell : FHDetailBaseCell

// 左右有切换回调
@property (nonatomic,copy) void (^indexChangeCallBack)();

@end

NS_ASSUME_NONNULL_END
