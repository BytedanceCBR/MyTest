//
//  FHDetailNearbyMapCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/12.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNearbyMapCell : FHDetailBaseCell

//左右有切换回调
@property (nonatomic,copy) void (^indexChangeCallBack)();

@end

NS_ASSUME_NONNULL_END