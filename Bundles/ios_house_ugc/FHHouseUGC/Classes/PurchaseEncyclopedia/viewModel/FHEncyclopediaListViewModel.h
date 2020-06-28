//
//  FHEncyclopediaListViewModel.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/13.
//

#import <Foundation/Foundation.h>
#import "FHEncyclopediaListViewController.h"
#import "FHEncyclopediaHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHEncyclopediaListViewModel : NSObject

- (instancetype)initWithWithController:(FHEncyclopediaListViewController *)viewController tableView:(UITableView *)table  userInfo:(NSDictionary *)userInfo;

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst;

@property (copy, nonatomic) NSString *channel_id;
@property(nonatomic, assign) BOOL isRefreshingTip;
@property(nonatomic, strong) FHTracerModel *tracerModel;
@end


NS_ASSUME_NONNULL_END
