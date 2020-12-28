//
//  FHHouseSecondCardViewModel.h
//  FHHouseList
//
//  Created by xubinbin on 2020/11/26.
//

#import "FHHouseNewComponentViewModel+HouseCard.h"
#import "FHSearchHouseModel.h"
#import "FHHouseListBaseItemModel.h"
#import "FHSingleImageInfoCellModel.h"
#import "UIFont+House.h"

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

@property (nonatomic, strong, readonly) id model;

@property (nonatomic, assign, readonly) BOOL hasVr;

@property (nonatomic, assign, readonly) BOOL isFirst;

@property (nonatomic, assign) CGFloat topMargin;

@property (nonatomic, assign) CGFloat tagListMaxWidth;

- (instancetype)initWithModel:(id)model;

- (void)showCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)clickCardAtIndexPath:(NSIndexPath *)indexPath;

- (void)setTitleMaxWidth:(CGFloat)maxWidth;

- (void)cutTagListWithFont:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
