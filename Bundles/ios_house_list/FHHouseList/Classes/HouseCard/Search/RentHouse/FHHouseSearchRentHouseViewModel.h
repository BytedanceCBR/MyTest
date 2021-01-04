//
//  FHHouseSearchRentHouseViewModel.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseNewComponentViewModel+HouseCard.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FHHouseCardOpacityDidChange)(void);

@interface FHHouseSearchRentHouseViewModel : FHHouseNewComponentViewModel

@property (nonatomic, copy) FHHouseCardOpacityDidChange opacityDidChange;

@end

NS_ASSUME_NONNULL_END
