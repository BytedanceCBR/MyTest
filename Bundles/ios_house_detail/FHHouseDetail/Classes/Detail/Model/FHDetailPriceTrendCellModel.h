//
//  FHDetailPriceTrendCellModel.h
//  Pods
//
//  Created by 张静 on 2019/2/18.
//

#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHDetailPriceTrendCellModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendModel *> *priceTrends;
@property (nonatomic, strong , nullable) FHDetailOldDataNeighborhoodInfoModel *neighborhoodInfo;
@property (nonatomic, strong , nullable) FHDetailOldDataPriceAnalyzeModel *priceAnalyze ;
@property (nonatomic, copy , nullable) NSString *pricingPerSqmV;
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, assign)   CGFloat       bottomHeight;  
@property (nonatomic, weak)     UITableView       *tableView;

@end

NS_ASSUME_NONNULL_END
