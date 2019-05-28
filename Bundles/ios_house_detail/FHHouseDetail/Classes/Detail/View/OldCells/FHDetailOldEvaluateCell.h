//
//  FHDetailOldEvaluateCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/5/21.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHHouseDetailBaseViewModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"

NS_ASSUME_NONNULL_BEGIN
// 二手房小区评测
@interface FHDetailOldEvaluateCell : FHDetailBaseCell

@end

@interface FHDetailOldEvaluateModel : FHDetailBaseModel

@property (nonatomic, strong)   NSDictionary *log_pb;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodNeighborhoodInfoEvaluationInfoModel *evaluationInfo ;

@end

//
@interface FHDetailOldEvaluationItemCollectionCell : FHDetailBaseCollectionCell
@property (nonatomic, strong)   UIView       *backView;
@property (nonatomic, strong)   UILabel       *descLabel;
@property (nonatomic, strong)   UILabel       *nameLabel;
@property (nonatomic, strong)   UILabel       *scoreLabel;
@property (nonatomic, strong)   UILabel       *levelLabel;
- (void)layoutDescLabelForText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END
