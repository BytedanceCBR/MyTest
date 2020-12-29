//
//  FHHousePlaceholderCell.h
//  FHHouseList
//
//  Created by bytedance on 2020/12/1.
//

#import "FHPlaceHolderCell.h"
#import "FHHomePlaceHolderCell.h"
#import "FHHouseCardTableViewCell.h"


NS_ASSUME_NONNULL_BEGIN

//列表页-新房
@interface FHHousePlaceholderStyle1Cell : FHPlaceHolderCell<FHHouseCardTableViewCellProtocol>

@property (nonatomic, strong) id<FHHouseNewComponentViewModelProtocol> viewModel;

@end

//列表页-二手房/大类页-all
@interface FHHousePlaceholderStyle2Cell : FHHomePlaceHolderCell<FHHouseCardTableViewCellProtocol>

@property (nonatomic, strong) id<FHHouseNewComponentViewModelProtocol> viewModel;

@end

//列表页-通勤找房
@interface FHHousePlaceholderStyle3Cell : FHPlaceHolderCell<FHHouseCardTableViewCellProtocol>

@property (nonatomic, strong) id<FHHouseNewComponentViewModelProtocol> viewModel;

@end

NS_ASSUME_NONNULL_END
