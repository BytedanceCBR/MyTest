//
//  FHHouseSecondCardViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHSearchHouseModel.h"

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

@property (nonatomic, strong) FHSearchHouseItemModel *model;

@property (nonatomic, assign) BOOL hasVr;

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model;

@end

NS_ASSUME_NONNULL_END
