//
//  FHDetailNewHouseNewsCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNewHouseNewsCell : FHDetailBaseCell

@end

@interface FHDetailNewHouseNewsCellModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;

@end

NS_ASSUME_NONNULL_END
