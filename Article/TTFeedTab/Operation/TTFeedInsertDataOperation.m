//
//  TTFeedInsertDataOperation.m
//  Article
//
//  Created by fengyadong on 16/11/14.
//
//


#import "TTFeedInsertDataOperation.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTFeedContainerViewModel.h"
#import "ExploreOriginalData.h"
#import "TTHistoryEntryGroup.h"
#import "Article.h"

@interface TTFeedInsertDataOperation ()

@property (nonatomic, assign) uint64_t startTime;
@property (nonatomic, assign) uint64_t endTime;
@property (nonatomic, copy)   NSArray *ignoreIDs;
@property (nonatomic, copy)   NSArray *increaseItems;
@property (nonatomic, assign) NSUInteger newNumber;

@end

@implementation TTFeedInsertDataOperation

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel {
    if (self = [super initWithViewModel:viewModel]) {
    }
    return self;
}

- (void)asyncOperation {
    //持久数据
    self.startTime = [NSObject currentUnixTime];
    
    NSUInteger newNumber = 0;
    
    NSArray *insertedArray = nil;
    NSArray *insertedlistData = [[self orderedDataClass] insertObjectsWithDataArray:self.viewModel.flattenList];
    
    NSMutableArray * mutInsertedlistData = [NSMutableArray arrayWithCapacity:[insertedlistData count]];
    
    for(ExploreOrderedData *data in insertedlistData)
    {
        if([data isKindOfClass:[ExploreOrderedData class]]) {
            newNumber += 1;
            [mutInsertedlistData addObject:data];
        } else if([data isKindOfClass:[TTHistoryEntryGroup class]]) {
            [mutInsertedlistData addObject:data];
        }
    }
    
    //        objectIDs = [mutInsertedlistData valueForKeyPath:@"objectID"];
    insertedArray = [mutInsertedlistData copy];
    
    if ([self orderedDataClass] == [ExploreOrderedData class]) {
        [self updateAllItemsForNextCellTypeForArray:insertedArray];
    } else if ([self orderedDataClass] == [TTHistoryEntryGroup class]) {
        for (TTHistoryEntryGroup *group in insertedArray) {
            [self updateAllItemsForNextCellTypeForArray:group.orderedDataList];
        }
    }
    
    self.increaseItems = insertedArray;
    self.newNumber = newNumber;
    self.endTime = [NSObject currentUnixTime];
    [self didFinishCurrentOperation];
}

- (void)updateAllItemsForNextCellTypeForArray:(NSArray<ExploreOrderedData *> *)allItems {
    __block ExploreOrderedData *lastObj = nil;
    
    [allItems enumerateObjectsUsingBlock:^(ExploreOrderedData *obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[ExploreOrderedData class]]) {
            return;
        }
        
        if (lastObj == nil) {
            lastObj = self.viewModel.allItems.lastObject;
        }
        
        if ([lastObj isKindOfClass:[TTHistoryEntryGroup class]]) {
            lastObj = ((TTHistoryEntryGroup *)lastObj).orderedDataList.lastObject;
        }
        
        if([lastObj isKindOfClass:[ExploreOrderedData class]]) {
            if (lastObj) {
                lastObj.nextCellType = obj.cellType;
                lastObj.nextCellHasTopPadding = obj.hasTopPadding;
                obj.preCellType = lastObj.cellType;
            } else {
                //第一个cell的preCellType = ExploreOrderedDataCellTypeNull
                obj.preCellType = ExploreOrderedDataCellTypeNull;
            }
            
            lastObj = obj;
        }
        
        if (!lastObj) {
            obj.preCellType = ExploreOrderedDataCellTypeNull;
            lastObj = obj;
        }
    }];
    
    lastObj.nextCellType = ExploreOrderedDataCellTypeNull;
    lastObj.nextCellHasTopPadding = YES;
}
@end
