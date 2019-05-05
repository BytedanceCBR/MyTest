//
//  DataListOperationManager.m
//  Essay
//
//  Created by Dianwei on 12-7-18.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "ListDataOperationManager.h"

@interface ListDataOperationManager()
@property(nonatomic, strong)NSMutableArray *operations;
- (void)buildChain;
@end

@implementation ListDataOperationManager
{
    BOOL _dirtyFlag;
}
@synthesize operations;

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"operations"];
}

//- (id)initWithOperations:(SSDataOperation*)operation,...
//{
//    self = [self init];
//    va_list args;
//    va_start(args, operation);
//    for(SSDataOperation *op = operation; op != nil; op = va_arg(args, SSDataOperation*))
//    {
//        [operations addObject:op];
//    }
//    
//    va_end(args);
//    _dirtyFlag = YES;
//    return self;
//}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.operations = [[NSMutableArray alloc] init];
        [self addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    }
    
    return self;
}

- (void)insertOperation:(SSDataOperation*)operation atIndex:(int)index
{
    [operations insertObject:operation atIndex:index];
}

- (void)removeOperation:(SSDataOperation*)operation
{
    [operations removeObject:operation];
}

- (void)removeOperationAtIndex:(int)index
{
    [operations removeObjectAtIndex:index];
}

- (NSUInteger)operationCount
{
    return [operations count];
}

- (void)addOperation:(SSDataOperation*)operation
{
    [operations addObject:operation];

    _dirtyFlag = YES;
}

- (SSDataOperation*)operationAtIndex:(int)index
{
    return [operations objectAtIndex:index];
}

- (void)startExecute:(id)operationContext
{
    if(_dirtyFlag)
    {
        [self buildChain];
    }
    
    if([operations count] > 0)
    {
        [[operations objectAtIndex:0] execute:operationContext];
    }
}

- (void)buildChain
{
    [operations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(idx < [operations count] - 1)
        {
            SSDataOperation *nextOperation = [operations objectAtIndex:idx + 1];
            [obj setNextOperation:nextOperation];
        }
        else 
        {
            [obj setNextOperation:nil];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"operations"])
    {
        _dirtyFlag = YES;
    }
}

- (void)cancelAllOperations
{
    for (SSDataOperation * op in operations) {
        [op cancel];
    }
}

- (void)reuserAllOperations
{
    for (SSDataOperation * op in operations) {
        [op reuseOperation];
    }

}

@end
