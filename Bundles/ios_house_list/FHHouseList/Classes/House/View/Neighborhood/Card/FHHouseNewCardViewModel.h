//
//  FHHouseNewCardViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewComponentViewModel.h"
#import "FHSearchHouseModel.h"
#import "FHHouseListBaseItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseRecommendViewModel;
@interface FHHouseNewCardViewModel : FHHouseNewComponentViewModel

@property (nonatomic, strong, readonly) FHImageModel *leftImageModel;

@property (nonatomic, strong, readonly) FHImageModel *tagImageModel;

@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, copy, readonly) NSString *propertyText;

@property (nonatomic, copy, readonly) NSString *propertyBorderColor;

@property (nonatomic, copy, readonly) NSString *subtitle;

@property (nonatomic, copy, readonly) NSString *price;

@property (nonatomic, strong, readonly) NSArray<FHHouseTagsModel *> *tagList;

@property (nonatomic, strong, readonly) FHHouseRecommendViewModel *recommendViewModel;

@property (nonatomic, assign, readonly) BOOL hasVr;

@property (nonatomic, assign, readonly) BOOL hasVideo;

@property (nonatomic, strong, readonly) id model;

- (instancetype)initWithModel:(id)model;

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
