//
//  EssayInsertRemoteDataOperation.m
//  Essay
//
//  Created by 于天航 on 12-8-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoInsertRemoteDataOperation.h"
#import "ListDataHeader.h"
#import "OrderedVideoData.h"

@implementation VideoInsertRemoteDataOperation

- (Class)orderedDataClass
{
    return [OrderedVideoData class];
}

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
    
    [super execute:operationContext];
}

@end
