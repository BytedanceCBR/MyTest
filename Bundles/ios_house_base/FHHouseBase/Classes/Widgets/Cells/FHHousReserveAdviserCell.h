//
//  FHHousReserveAdviserCell.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2020/6/1.
//

#import <Foundation/Foundation.h>
#import "FHListBaseCell.h"
@class FHHouseReserveAdviserModel;

NS_ASSUME_NONNULL_BEGIN


@interface FHHousReserveAdviserCell : FHListBaseCell

@property (nonatomic, copy) void (^textFieldShouldBegin)(void);
@property (nonatomic, copy) void (^textFieldDidEnd)(void);

- (void)bindData:(FHHouseReserveAdviserModel *)model traceParams:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
