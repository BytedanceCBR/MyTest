//
//  FHFHClearHistoryModel.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/15.
//

#import "JSONModel.h"
#import <FHHouseBase/FHBaseModelProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHFHClearHistoryModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;

@end

NS_ASSUME_NONNULL_END
