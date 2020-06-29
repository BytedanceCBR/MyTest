//
//  FHhouseDetailRGCListCell.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBrokerEvaluationModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHhouseDetailRGCListCellModel : FHDetailBaseModel
@property (copy, nonatomic) NSString *title;
@property (nonatomic, strong) NSNumber *count;
@property (strong, nonatomic) FHDetailBrokerContentModel *contentModel;
@property (assign, nonatomic) CGFloat cellHeight;
@property (strong, nonatomic) NSDictionary *extraDic;
@property(nonatomic , strong) NSMutableDictionary *detailTracerDic; // 详情页基础埋点数据
@property (nonatomic, weak) UIViewController *belongsVC;
@end


@interface FHhouseDetailRGCListCell : FHDetailBaseCell

@end

NS_ASSUME_NONNULL_END
