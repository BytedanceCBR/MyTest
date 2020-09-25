//
//  FHNewHouseDetailRGCListSM.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionModel.h"
#import "FHDetailBrokerEvaluationModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailRGCListSM : FHNewHouseDetailSectionModel
@property(copy, nonatomic) FHDetailBrokerContentModel *contentModel;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *houseInfoBizTrace;
@property (nonatomic, strong) NSNumber *count;


@property(nonatomic, copy) NSDictionary *extraDic;
@property(nonatomic, copy) NSDictionary *detailTracerDic; // 详情页基础埋点数据
@end

NS_ASSUME_NONNULL_END
