//
//  ExploreMixedListBaseView+TrackEvent.h
//  Article
//
//  Created by Chen Hong on 16/5/24.
//
//

#import "ExploreMixedListBaseView.h"

@interface ExploreMixedListBaseView (TrackEvent)

- (void)trackEventStartLoad;

- (void)trackEventUpdateRemoteItemsCount:(NSUInteger)remoteItemsCount;

- (void)trackEventUpdateRemoteItemsCountAfterMerge:(NSUInteger)remoteItemsCountAfterMerge;

- (void)trackEventForLabel:(NSString *)label;

- (void)trackRefershEvent3ForLabel:(NSString *)label;

- (NSString *)modifyEventLabelForRefreshEvent:(NSString *)label;

- (void)trackLoadStatusEventWithErorr:(NSError *)error isLoadMore:(BOOL)isLoadMore;

- (void)trackLoadStatusEventForLabel:(NSString *)label isLoadMore:(BOOL)isLoadMore status:(NSInteger)status;

@end

@interface ExploreMixedListBaseView ()

@property (nonatomic, strong) NSDate * startLoadDate;

/**
 *  统计使用 用来上报 服务端返回数据条数 和merge后条数-- 4.9 nick
 */
@property (nonatomic) NSUInteger remoteItemsCount;
@property (nonatomic) NSUInteger remoteItemsCountAfterMerge;

@end
