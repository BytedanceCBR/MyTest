//
//  FHPriceValuationResultController.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHBaseViewController.h"
#import "FHPriceValuationEvaluateModel.h"
#import "FHPriceValuationHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationResultController : FHBaseViewController

@property(nonatomic ,strong) FHPriceValuationEvaluateModel *model;
@property(nonatomic ,strong) FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *infoModel;

- (void)setNavBar:(BOOL)error;

- (void)refreshContentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
