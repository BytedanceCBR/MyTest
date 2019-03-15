//
//  FHBaseMainListViewModel+Old.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHBaseMainListViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHBaseModelProtocol;
@class TTHttpTask;
@interface FHBaseMainListViewModel (Old)

-(void)showOldMapSearch;

-(TTHttpTask *)loadData:(BOOL)isRefresh  query:(NSString *)query completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion;

-(TTHttpTask *)loadData:(BOOL)isRefresh fromRecommend:(BOOL)isFromRecommend query:(NSString *)query  completion:(void (^)(id<FHBaseModelProtocol> model ,NSError *error))completion;

- (void)updateRedirectTipInfo;

- (void)closeRedirectTip;

- (void)clickRedirectTip;


@end

NS_ASSUME_NONNULL_END
