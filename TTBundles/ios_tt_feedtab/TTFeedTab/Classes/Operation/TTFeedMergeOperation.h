//
//  TTFeedMergeOperation.h
//  Article
//
//  Created by fengyadong on 16/11/15.
//
//

#import "TTFeedGeneralOperation.h"

@interface TTFeedMergeOperation : TTFeedGeneralOperation

@property (nonatomic, assign, readonly) BOOL canLoadMore;
@property (nonatomic, assign, readonly) BOOL hasNew;
@property (nonatomic, strong, readonly) NSArray *sortedAllItems;
@property (nonatomic, strong, readonly) NSArray *sortedIncreaseItems;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel;

@end
