//
//  FHHouseNeighborhoodCardViewModel.h
//  ABRInterface
//
//  Created by bytedance on 2020/11/9.
//

#import "FHHouseNewComponentViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseTitleAndTagViewModel;
@class FHSearchHouseItemModel;
@class FHImageModel;
@interface FHHouseNeighborhoodCardViewModel : FHHouseNewComponentViewModel

@property (nonatomic, strong, readonly) FHImageModel *leftImageModel;

@property (nonatomic, copy, readonly) NSString *subtitle;

@property (nonatomic, copy, readonly) NSString *stateInfo;

@property (nonatomic, copy, readonly) NSString *price;

@property (nonatomic, strong, readonly) FHHouseTitleAndTagViewModel *titleAndTag;


- (instancetype)initWithModel:(FHSearchHouseItemModel *)model;

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
