//
//  FHDetailDetectiveCell.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/7/2.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailBaseModel;
@interface FHDetailDetectiveCell : FHDetailBaseCell

@end

@interface FHDetailDetectiveModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailDataBaseExtraDetectiveModel *detective ;
@property(nonatomic , copy) void (^feedBack)(NSInteger type , id data , void (^compltion)(BOOL success));

@end

NS_ASSUME_NONNULL_END
