//
//  FHHouseDetailRealtorTabListModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/21.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailRealtorTabListModel : JSONModel
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, copy , nullable) NSDictionary *data;
@end

NS_ASSUME_NONNULL_END
