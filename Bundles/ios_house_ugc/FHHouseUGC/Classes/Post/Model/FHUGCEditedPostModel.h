//
//  FHUGCEditedPostModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/12/23.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCEditedPostModel : JSONModel<FHBaseModelProtocol>
@property (nonatomic, strong)   NSDictionary *data;
@property (nonatomic, copy)     NSString *status;
@property (nonatomic, copy)     NSString *message;
@end

NS_ASSUME_NONNULL_END
