//
//  FHHouseCoreInfoModel.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/6/17.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseCoreInfoModel <NSObject>

@end

@interface FHHouseCoreInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *attr;
@property (nonatomic, copy , nullable) NSString *value;

@end

NS_ASSUME_NONNULL_END
