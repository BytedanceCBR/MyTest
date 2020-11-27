//
//  FHHouseSecondCardViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHSearchHouseModel.h"
#import "FHHouseListBaseItemModel.h"
#import "FHSingleImageInfoCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseTitleAndTagViewModel;
@class FHHouseRecommendViewModel;
@interface FHHouseSecondCardViewModel : FHHouseNewComponentViewModel

@property (nonatomic, strong, readonly) FHImageModel *leftImageModel;

@property (nonatomic, strong, readonly) FHHouseTitleAndTagViewModel *titleAndTag;

@property (nonatomic, copy, readonly) NSString *subtitle;

@property (nonatomic, strong, readonly) NSArray<FHHouseTagsModel *> *tagList;

@property (nonatomic, copy, readonly) NSString *price;

@property (nonatomic, copy, readonly) NSString *pricePerSqm;

@property (nonatomic, strong, readonly) FHHouseRecommendViewModel *recommendViewModel;

@property (nonatomic, strong, readonly) FHSearchHouseItemModel *model;

@property (nonatomic, assign, readonly) BOOL hasVr;

- (instancetype)initWithModel:(id)model;

@end

NS_ASSUME_NONNULL_END
