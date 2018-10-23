//
//  EssaySaveRemoteDataOperation.m
//  Essay
//
//  Created by 于天航 on 12-8-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoSaveRemoteDataOperation.h"
#import "ListDataHeader.h"
#import "OrderedVideoData.h"

@implementation VideoSaveRemoteDataOperation

- (id)init
{
    self = [super init];
    if (self) {
        self.shouldExecuteBlock = ^(id dataContext){
            BOOL fromRemote = [[dataContext objectForKey:kSSDataOperationFromRemoteKey] boolValue];
            return fromRemote;
        };
    }
    return self;
}

- (void)execute:(id)operationContext
{
    if (!self.shouldExecuteBlock(operationContext)) {
        [self executeNext:operationContext];
        return;
    }
    
    DataSortType sortType = [[[operationContext objectForKey:kSSDataOperationConditionKey] objectForKey:kListDataConditionSortTypeKey] intValue];
    NSArray *data = [operationContext objectForKey:kSSDataOperationInsertedDataKey];
    switch (sortType)
    {
//        case DataSortTypeTop:
//        {
//            int order = 0;
//            for(int idx = [data count] - 1; idx >= 0; idx --)
//                
//            {
//                OrderedData *essayData = [data objectAtIndex:idx];
//                essayData.orderIndex = [NSNumber numberWithInt:order ++];
//            }
//        }
//            break;
        case DataSortTypeRecent:
        case DataSortTypeHot:
        {
            for(OrderedData *orderedData in data)
            {
                orderedData.orderIndex = [orderedData.originalData valueForKeyPath:@"behotTime"];
            }
        }
            break;
        case DataSortTypeFavorite:
        {
            for (OrderedData * orderedData in data) {
                orderedData.orderIndex = [orderedData.originalData valueForKeyPath:@"userRepinTime"];
            }
        }
            break;
        default:
            break;
    }
    
    NSError *error = nil;
    [[SSModelManager sharedManager] save:&error];
    [self executeNext:operationContext];
}

@end
