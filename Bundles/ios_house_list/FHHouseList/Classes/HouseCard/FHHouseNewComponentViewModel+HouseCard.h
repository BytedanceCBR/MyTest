//
//  FHHouseNewComponentViewModel+HouseCard.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/2.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHHouseCardCellViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseNewComponentViewModel(HouseCard)<FHHouseCardCellViewModelProtocol>

@property (nonatomic, strong, readonly) id model;

@property (nonatomic, assign) NSInteger cardIndex;

@property (nonatomic, assign) NSInteger cardCount;

- (instancetype)initWithModel:(id)model;

@end

NS_ASSUME_NONNULL_END
