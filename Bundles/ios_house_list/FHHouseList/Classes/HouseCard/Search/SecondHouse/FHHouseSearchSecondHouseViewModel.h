//
//  FHHouseSearchSecondHouseViewModel.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/1.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHHouseCardCellViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class FHSearchHouseItemModel;
@interface FHHouseSearchSecondHouseViewModel : FHHouseNewComponentViewModel<FHHouseCardCellViewModelProtocol>

@property (nonatomic, strong, readonly) FHSearchHouseItemModel *model;

@property (nonatomic, assign) NSInteger cardIndex;

@property (nonatomic, assign) NSInteger cardCount;

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model;

@end

NS_ASSUME_NONNULL_END
