//
//  FHHouseNeighborhoodCardViewModel.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHHouseCardCellViewModelProtocol.h"
#import "FHSearchHouseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseTitleAndTagViewModel;
@class FHImageModel;
@interface FHHouseNeighborhoodCardViewModel : FHHouseNewComponentViewModel

@property (nonatomic, strong, readonly) FHImageModel *leftImageModel;

@property (nonatomic, copy, readonly) NSString *subtitle;

@property (nonatomic, copy, readonly) NSString *stateInfo;

@property (nonatomic, copy, readonly) NSString *price;

@property (nonatomic, strong, readonly) FHHouseTitleAndTagViewModel *titleAndTag;

@property (nonatomic, strong) id model;

- (instancetype)initWithModel:(id)model;

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
