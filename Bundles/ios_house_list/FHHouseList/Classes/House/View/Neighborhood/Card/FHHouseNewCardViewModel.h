//
//  FHHouseNewCardViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/27.
//

#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHSearchHouseModel.h"
#import "FHHouseListBaseItemModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^FHHouseCardOpacityDidChange)(void);

@class FHHouseRecommendViewModel;
@interface FHHouseNewCardViewModel : FHHouseNewComponentViewModel

@property (nonatomic, copy) FHHouseCardOpacityDidChange opacityDidChange;

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

@property (nonatomic, copy, readonly) NSString *houseId;

@property (nonatomic, assign, readonly) CGFloat opacity;

- (instancetype)initWithModel:(id)model;

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
