//
//  SSDataOperation.m
//  Essay
//
//  Created by Dianwei on 12-7-10.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSDataOperation.h"
#import "ListDataHeader.h"

@interface SSDataOperation()
@property(nonatomic, readwrite)BOOL cancelled;

@end

@implementation SSDataOperation
@synthesize hasFinished, didFinishedBlock, shouldExecuteBlock;
@synthesize nextOperation, cancelled;

// for synchronized operation, do nothing
- (void)cancel
{
    self.cancelled = YES;
}

- (void)reuseOperation
{
    self.cancelled = NO;
}

- (void)execute:(id)operationContext
{
    if (_opDelegate && [_opDelegate respondsToSelector:@selector(dataOperationStartExecute:)]) {
        [_opDelegate dataOperationStartExecute:self];
    }
}

- (void)executeNext:(id)operationContext
{
    if(!self.cancelled && self.nextOperation)
    {
        [nextOperation execute:operationContext];
    }
}

- (void)notifyWithData:(NSArray*)newlistData error:(NSError*)error userInfo:(NSDictionary*)userInfo
{
    if (_opDelegate && [_opDelegate respondsToSelector:@selector(dataOperation:increaseData:error:userInfo:)]) {
        [_opDelegate dataOperation:self increaseData:newlistData error:error userInfo:userInfo];
        return;
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:3];
    if(newlistData)
    {
        [data setObject:newlistData forKey:@"dataList"];
    }
    
    if(error)
    {
        [data setObject:error forKey:@"error"];
    }
    
    if(userInfo)
    {
        [data setObject:userInfo forKey:@"userInfo"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ssGetListDataFinishedNotification
                                                            object:self
                                                          userInfo:data];
}

@end
