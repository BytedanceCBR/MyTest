//
//  TTFeedGeneralOperation.h
//  Article
//
//  Created by fengyadong on 16/11/14.
//
//

#import "TTConcurrentOperation.h"
#import "ExploreCellBase.h"
#import "ListDataHeader.h"
#import "UIViewController+Refresh_ErrorHandler.h"

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

@class TTFeedContainerViewModel;

@interface TTFeedGeneralOperation : TTConcurrentOperation

@property (nonatomic, assign, readonly) uint64_t startTime;
@property (nonatomic, assign, readonly) uint64_t endTime;
@property (nonatomic, copy, readonly)   NSString *categoryID;
@property (nonatomic, copy, readonly)   NSString *concernID;
@property (nonatomic, assign, readonly) ListDataOperationReloadFromType reloadType;
@property (nonatomic, strong, readonly) TTFeedContainerViewModel *viewModel;
@property (nonatomic, assign, readonly) ExploreOrderedDataListType listType;
@property (nonatomic, assign, readonly) ExploreOrderedDataListLocation listLocation;
@property (nonatomic, assign, readonly) NSUInteger loadMoreCount;
@property (nonatomic, weak, readonly)   UIViewController *targetVC;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel;
- (Class)orderedDataClass;

@end
