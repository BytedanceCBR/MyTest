//
//  FHHouseNewCardViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHSearchHouseModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseRecommendViewModel;
@interface FHHouseNewCardViewModel : FHHouseNewComponentViewModel

@property (nonatomic, strong, readonly) FHImageModel *leftImageModel;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, copy, readonly) NSString *propertyText;

@property (nonatomic, copy, readonly) NSString *propertyBorderColor;

@property (nonatomic, copy, readonly) NSString *subtitle;

@property (nonatomic, copy, readonly) NSString *price;

@property (nonatomic, strong, readonly) NSArray<FHHouseTagsModel *> *tagList;

@property (nonatomic, strong, readonly) FHHouseRecommendViewModel *recommendViewModel;

@property (nonatomic, assign) BOOL hasVr;

@property (nonatomic, assign) BOOL hasVideo;

@property (nonatomic, strong) FHSearchHouseItemModel *model;

- (instancetype)initWithModel:(FHSearchHouseItemModel *)model;

@end

NS_ASSUME_NONNULL_END
