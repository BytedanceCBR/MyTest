//
//  FHBaseMainListViewModel+New.h
//  FHHouseList
//
//  Created by wangxinyu on 2020/10/29.
//

#import "FHBaseMainListViewModel.h"
#import <TTNetworkManager/TTHttpTask.h>
#import "FHBaseModelProtocol.h"
#import "FHTracerModel.h"
#import "FHHouseNewTopContainer.h"
#import "FHHouseNewTopContainerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHBaseMainListViewModel (New)

@property (nonatomic, strong) FHHouseNewTopContainerViewModel *houseNewTopViewModel;

- (TTHttpTask *)requestNewData:(BOOL)isRefresh query:(NSString *)query completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion;
- (void)addNewHouseTopViewWithTracerModel:(FHTracerModel *)tracerModel;
- (FHTracerModel *)prepareForTracerModel;

@end

NS_ASSUME_NONNULL_END
