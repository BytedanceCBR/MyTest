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

typedef void (^FHHouseCardOpacityDidChange)(void);

@class FHHouseTitleAndTagViewModel;
@class FHImageModel;
@interface FHHouseNeighborhoodCardViewModel : FHHouseNewComponentViewModel

@property (nonatomic, copy) FHHouseCardOpacityDidChange opacityDidChange;

@property (nonatomic, strong, readonly) FHImageModel *leftImageModel;

@property (nonatomic, copy, readonly) NSString *subtitle;

@property (nonatomic, copy, readonly) NSString *stateInfo;

@property (nonatomic, copy, readonly) NSString *price;

@property (nonatomic, strong, readonly) FHHouseTitleAndTagViewModel *titleAndTag;

@property (nonatomic, strong) FHSearchHouseItemModel *model;

@property (nonatomic, copy, readonly) NSString *houseId;

@property (nonatomic, assign, readonly) CGFloat opacity;

@property (nonatomic, assign, readonly) CGFloat topMargin;

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model;

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
