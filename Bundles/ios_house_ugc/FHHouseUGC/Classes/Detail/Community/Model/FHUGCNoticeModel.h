//
//  FHUGCNoticeModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/10/8.
//

#import <Foundation/Foundation.h>
#import "FHBaseModelProtocol.h"
#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface FHUGCNoticeModelData: JSONModel
@property (nonatomic, copy) NSString *announcement;
@end

@interface FHUGCNoticeModel: JSONModel<FHBaseModelProtocol>
@property (nonatomic, strong) FHUGCNoticeModelData *data;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *message;
@end

NS_ASSUME_NONNULL_END
