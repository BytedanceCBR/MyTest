//
//  FHUGCWendaModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/26.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCWendaModel: JSONModel<FHBaseModelProtocol>
@property (nonatomic, strong) NSString *data;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *message;
@end

NS_ASSUME_NONNULL_END
