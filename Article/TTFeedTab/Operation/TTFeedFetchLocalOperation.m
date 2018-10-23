//
//  TTFeedFetchLocalOperation.m
//  Article
//
//  Created by fengyadong on 16/11/11.
//
//

#import "TTFeedFetchLocalOperation.h"
#import "TTFeedContainerViewModel.h"
#import "NetworkUtilities.h"
#import "ExploreCellBase.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOriginalData.h"
#import "ExploreListHelper.h"
#import <SDWebImage/SDWebImageCompat.h>
#import "LastRead.h"
#import "TTLayOutCellBaseModel.h"

@interface TTFeedFetchLocalOperation ()

@property (nonatomic, assign) uint64_t startTime;
@property (nonatomic, assign) uint64_t endTime;
@property (nonatomic, assign) NSUInteger offlineLoadCount;
@property (nonatomic, assign) NSUInteger normalLoadCount;
@property (nonatomic, assign) BOOL canLoadMore;
@property (nonatomic, strong) NSArray *allItems;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, assign) NSUInteger offset;
@end


@implementation TTFeedFetchLocalOperation

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel
                 OfflineLoadCount:(NSUInteger)offlineLoadCount
                  normalLoadCount:(NSUInteger)normalLoadCount {
    if (self = [super initWithViewModel:viewModel]) {
        _offlineLoadCount = offlineLoadCount;
        _normalLoadCount = normalLoadCount;
        _offset = 0;
    }
    return self;
}

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel {
    if (self = [super initWithViewModel:viewModel]) {
        _normalLoadCount = 20;
        _offlineLoadCount = 50;
        _offset = 0;
    }
    return self;
}

- (void)asyncOperation {
    self.startTime = [NSObject currentUnixTime];
    
    dispatch_main_sync_safe(^{
        [self.targetVC tt_startUpdate];
    });
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithCapacity:5];
    
    if (self.listType == ExploreOrderedDataListTypeCategory) {
        [queryDict setValue:self.categoryID forKey:@"categoryID"];
        [queryDict setValue:self.concernID forKey:@"concernID"];
    }
    
    [queryDict setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
    [queryDict setValue:@(self.listLocation) forKey:@"listLocation"];
    [queryDict setValue:@"__all__" forKey:@"categoryID"];
    
    if ([SSCommonLogic feedRefreshClearAllEnable]) {
        [queryDict setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
        [queryDict setValue:@(self.listLocation) forKey:@"listLocation"];
        [queryDict setValue:@"__all__" forKey:@"categoryID"];
    } else {
        [queryDict setValue:@(self.listType) forKey:@"listType"];
        [queryDict setValue:@(self.listLocation) forKey:@"listLocation"];
    }
    
    NSArray *allItems = self.viewModel.allItems;

    if ([SSCommonLogic feedRefreshClearAllEnable]) {
        //如果没有内容，从数据库读取
        // from store
        NSUInteger count = self.normalLoadCount;
        if (!TTNetworkConnected())
        {
            count = self.offlineLoadCount;
        }
        
        NSArray *sortedDataList = [ExploreOrderedData objectsWithQuery:queryDict orderBy:@"itemIndex DESC" offset:self.viewModel.allItems.count limit:count];
        self.offset += sortedDataList.count;
        //sortedDataList = [self fixOrderedDataWhenQueryFromDB:sortedDataList];
        
        allItems = [NSArray arrayWithArray:sortedDataList];
        NSMutableArray *ary = [[NSMutableArray alloc] init];
        [ary addObjectsFromArray:self.viewModel.allItems];

        NSMutableDictionary * uniqueIDDicts = [[NSMutableDictionary alloc] init];
        for (ExploreOrderedData *orderedData in ary) {
            if ([orderedData isKindOfClass:[ExploreOrderedData class]]) {
                NSNumber * uniqueID = @(((ExploreOrderedData *)orderedData).originalData.uniqueID);
                [uniqueIDDicts setValue:orderedData forKey:[uniqueID stringValue]];
            }
        }
        
        NSUInteger lastReadCount = 0;
        NSUInteger repeatCount = 0;
        for (ExploreOrderedData *orderedData in allItems) {
            NSNumber * uniqueID = @(((ExploreOrderedData *)orderedData).originalData.uniqueID);
            BOOL repeate = [[uniqueIDDicts allKeys] containsObject:[uniqueID stringValue]];
            ExploreOrderedData *copyOrderedData = nil;
            if (orderedData.stickStyle > 0) {
                copyOrderedData = [orderedData copy];
                copyOrderedData.stickStyle = 0;
                copyOrderedData.stickLabel = nil;
                copyOrderedData.label = nil;
                copyOrderedData.isStick = NO;
                copyOrderedData.cellLayOut.typeLabelHidden = YES;
            }
            
            if (![orderedData.originalData isKindOfClass:[LastRead class]]) {
                if ([orderedData.adID longLongValue] < 1 && !repeate && !orderedData.originalData.notInterested) {
                    if (orderedData.stickStyle > 0 && copyOrderedData) {
                        [ary addObject:copyOrderedData];
                    } else {
                        [ary addObject:orderedData];
                    }
                } else {
                    ++repeatCount;
                }
            } else {
                ++lastReadCount;
            }
            
            [uniqueIDDicts setValue:orderedData forKey:[uniqueID stringValue]];
        }
        
        // update context
        BOOL canLoadMore = YES;
        if (!TTNetworkConnected()) {
            canLoadMore = NO;
        }
        if (sortedDataList.count == 0) {
            canLoadMore = NO;
        }
        if (sortedDataList.count == lastReadCount) {
            canLoadMore = NO;
        }
        if (sortedDataList.count == (lastReadCount + repeatCount)) {
            canLoadMore = NO;
        }
        self.canLoadMore = canLoadMore;
        
        self.allItems = ary;
        [self didFinishCurrentOperation];
        
    } else {
        if ([allItems count] == 0) {
            // from store
            NSUInteger count = self.normalLoadCount;
            if (!TTNetworkConnected())
            {
                count = self.offlineLoadCount;
            }
            
            //        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"orderIndex" ascending:NO];
            //        NSArray * sortedDataList = [[SSModelManager sharedManager] entitiesWithQuery:queryDict
            //                                                               entityClass:[self orderedDataClass]
            //                                                                unFaulting:NO
            //                                                                    offset:0
            //                                                                     count:count
            //                                                           sortDescriptors:[NSArray arrayWithObject:sd]
            //                                                                     error:nil];
            
            NSArray *sortedDataList = [ExploreOrderedData objectsWithQuery:queryDict orderBy:@"orderIndex DESC" offset:0 limit:count];
            
            sortedDataList = [self fixOrderedDataWhenQueryFromDB:sortedDataList];
            
            allItems = [NSArray arrayWithArray:sortedDataList];
        }
        
        // update context
        BOOL canLoadMore = YES;
        if (!TTNetworkConnected()) {
            canLoadMore = NO;
        }
        
        self.canLoadMore = canLoadMore;
        
        self.allItems = [ExploreListHelper sortByIndexForArray:allItems listType:self.listType];
        
        [self didFinishCurrentOperation];
    }
}

- (NSArray *)fixOrderedDataWhenQueryFromDB:(NSArray *)sortedDataList
{
    NSMutableArray * ary = [NSMutableArray arrayWithCapacity:[sortedDataList count]];
    
    for (ExploreOrderedData * data in sortedDataList) {
        BOOL couldAdd = YES;
        
        @try {
            if ([data.originalData.notInterested boolValue]) {
                couldAdd = NO;
            }
            else if (data.cellDeleted) {
                couldAdd = NO;
            }
            
            if (couldAdd) {
                [ary addObject:data];
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
    
    return [NSArray arrayWithArray:ary];
}

@end
