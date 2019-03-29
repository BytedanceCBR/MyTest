//
//  FHPriceValuationMoreInfoController.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHBaseViewController.h"
#import "FHPriceValuationHistoryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationMoreInfoController : FHBaseViewController

@property(nonatomic ,strong) FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *infoModel;
@property (nonatomic, weak) id<FHHouseBaseDataProtocel> delegate;

@end

NS_ASSUME_NONNULL_END
