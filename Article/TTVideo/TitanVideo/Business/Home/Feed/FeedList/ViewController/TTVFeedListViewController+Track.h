//
//  TTVFeedListViewController+Track.h
//  Article
//
//  Created by panxiang on 2017/3/27.
//
//

#import "TTVFeedListViewController.h"

@interface TTVFeedListViewController (Track)

- (void)trackEventStartLoad;

- (void)trackEventUpdateRemoteItemsCount:(NSUInteger)remoteItemsCount;

- (void)trackEventUpdateRemoteItemsCountAfterMerge:(NSUInteger)remoteItemsCountAfterMerge;

- (void)trackEventForLabel:(NSString *)label;

- (NSString *)modifyEventLabelForRefreshEvent:(NSString *)label;

- (void)trackLoadStatusEventWithErorr:(NSError *)error isLoadMore:(BOOL)isLoadMore;

- (void)trackLoadStatusEventForLabel:(NSString *)label isLoadMore:(BOOL)isLoadMore status:(NSInteger)status;

- (void)trackRefreshV3ForCategory:(NSString *)categoryName refreshMethod:(NSString *)methodName;

- (void)trackRefreshV3ForCategory:(NSString *)categoryName refreshMethod:(NSString *)methodName erorr:(NSError *)error isLoadMore:(BOOL)isLoadMore;

- (void)trackRefreshV3ForCategory:(NSString *)categoryName refreshMethod:(NSString *)methodName label:(NSString *)label isloadMore:(BOOL)isLoadMore status:(NSInteger)status;


@end

@interface TTVFeedListViewController ()

@property (nonatomic, strong) NSDate * startLoadDate;

/**
 *  统计使用 用来上报 服务端返回数据条数 和merge后条数-- 4.9 nick
 */
@property (nonatomic) NSUInteger remoteItemsCount;
@property (nonatomic) NSUInteger remoteItemsCountAfterMerge;

@end
