//
//  FHEncyclopediaListViewController.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/13.
//

#import "FHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHEncyclopediaListViewController : FHBaseViewController
@property (copy, nonatomic) NSString *channel_id;
- (void)startLoadData;
- (void)showNotify:(NSString *)message;
- (void)hideImmediately;
- (void)showNotify:(NSString *)message completion:(void(^)(void))completion;
@end

NS_ASSUME_NONNULL_END
