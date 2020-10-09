//
//  FHNewHouseDetailAssessSM.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailSectionModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHNewHouseDetailAssessCellModel;

@interface FHNewHouseDetailAssessSM : FHNewHouseDetailSectionModel

- (void)updateDetailTracer:(NSDictionary *)tracerDict;

@property (nonatomic, strong) FHNewHouseDetailAssessCellModel *assessCellModel;

@end

NS_ASSUME_NONNULL_END
