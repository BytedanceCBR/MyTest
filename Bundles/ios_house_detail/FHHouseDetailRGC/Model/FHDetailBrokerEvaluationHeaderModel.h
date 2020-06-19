//
//  FHDetailBrokerEvaluationHeaderModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHDetailBrokerEvaluationHeaderModel <NSObject>

@end
@interface FHDetailBrokerEvaluationHeaderModel : JSONModel
@property (nonatomic, copy , nullable) NSString *showName;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, copy , nullable) NSNumber*count;
@end

NS_ASSUME_NONNULL_END
