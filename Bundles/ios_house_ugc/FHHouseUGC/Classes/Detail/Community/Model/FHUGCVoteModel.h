//
//  FHUGCVoteModel.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/11/12.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCVoteModel: JSONModel<FHBaseModelProtocol>
@property (nonatomic, strong) NSString *data;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *message;
@end

NS_ASSUME_NONNULL_END



