//
//  FHUGCUserVWhiteModel.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/12/10.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCUserVWhiteModel : JSONModel
@property (nonatomic, copy , nullable) NSString *code;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) NSDictionary *data;
@end

NS_ASSUME_NONNULL_END
