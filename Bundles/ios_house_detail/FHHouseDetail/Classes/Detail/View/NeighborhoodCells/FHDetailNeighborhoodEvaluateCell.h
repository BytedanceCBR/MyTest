//
//  FHDetailNeighborhoodEvaluateCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/20.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"

NS_ASSUME_NONNULL_BEGIN

// 小区评测
@interface FHDetailNeighborhoodEvaluateCell : FHDetailBaseCell

@end

@interface FHDetailNeighborhoodEvaluateModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoModel *evaluationInfo ;

@end

// 
@interface FHDetailEvaluationItemCollectionCell : FHDetailBaseCollectionCell
@property (nonatomic, strong)   UIView       *backView;
@property (nonatomic, strong)   UILabel       *descLabel;
@property (nonatomic, strong)   UILabel       *nameLabel;
@property (nonatomic, strong)   UILabel       *scoreLabel;
@property (nonatomic, strong)   UILabel       *levelLabel;
- (void)layoutDescLabelForText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
