//
//  TTFeedFetchLocalOperation.h
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import <Foundation/Foundation.h>
#import "TTFeedGeneralOperation.h"

@class TTFeedContainerViewModel;

@interface TTFeedFetchLocalOperation : TTFeedGeneralOperation

@property (nonatomic, assign, readonly) BOOL canLoadMore;
@property (nonatomic, strong, readonly) NSArray *allItems;
@property (nonatomic, strong, readonly) NSError *error;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel
                 OfflineLoadCount:(NSUInteger)offlineLoadCount
                  normalLoadCount:(NSUInteger)normalLoadCount;
- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel;

@end
