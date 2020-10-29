//
//  FHBaseMainListViewModel+New.h
//  FHHouseList
//
//  Created by wangxinyu on 2020/10/29.
//

#import "FHBaseMainListViewModel.h"
#import <TTNetworkManager/TTHttpTask.h>
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBaseMainListViewModel (New)

- (TTHttpTask *)loadData:(BOOL)isRefresh query:(NSString *)query completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
