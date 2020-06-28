//
//  FHDetailBrokerEvaluationModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import "JSONModel.h"
#import "FHDetailBrokerEvaluationHeaderModel.h"

NS_ASSUME_NONNULL_BEGIN

//1.0.1经纪人评测模块
@protocol FHDetailBrokerDataModel
@end
@interface FHDetailBrokerDataModel : JSONModel
@property (nonatomic, strong , nullable) NSNumber *code;
@property (nonatomic, copy , nullable) NSString *content;
@end

@interface FHDetailBrokerContentModel : JSONModel
@property (nonatomic, strong , nullable) NSArray  *data;
@property (nonatomic, strong , nullable) NSArray  *fHFeedUGCCellModelDataArr;
@property (nonatomic, strong , nullable) NSNumber *count;
@property (nonatomic, copy , nullable) NSString *schema;
@end

@interface FHDetailBrokerEvaluationModel : JSONModel
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHDetailBrokerContentModel *content;
@property (nonatomic, strong , nullable) NSArray  <FHDetailBrokerEvaluationHeaderModel>*tabList;
@end

NS_ASSUME_NONNULL_END
