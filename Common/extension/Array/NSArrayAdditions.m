//
//  NSArrayAdditions.m
//  Base
//
//  Created by David Alpha Fox on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "NSArrayAdditions.h"

@implementation NSArray(SSNSArrayAddtions)

- (NSArray *)sortedArray {
	return [self sortedArrayUsingSelector:@selector(compare:)];
}

- (NSArray *)mergeArray:(NSArray *)newArray
              mergeSelector:(SEL)merger {
    return [self mergeArray:newArray
                compareSelector:@selector(compare:)
                  mergeSelector:merger];
}

- (NSArray *)mergeArray:(NSArray *)newArray
            compareSelector:(SEL)comparer
              mergeSelector:(SEL)merger {
    // 如果没有可恨的比较器，我们直接返回空
    if (!comparer) return nil;
    
    // 开始合并自己和newArray
    NSArray *sortedMergedArray = nil;
    // 分三种情况的
    if ([self count] && [newArray count]) {
        //创建一个自身的可变复制，并且排序下
        NSMutableArray *mergingArray = [NSMutableArray arrayWithArray:self];
        [mergingArray sortUsingSelector:comparer];
        
        //对newArray进行排序
        NSArray *sortedNewArray = [newArray sortedArrayUsingSelector:comparer];
        
        NSUInteger oldIndex = 0;
        NSUInteger oldCount = [mergingArray count];
        id oldItem = (oldIndex < oldCount)? [mergingArray objectAtIndex:0]: nil;
        
        id newItem = nil;
        for(newItem in sortedNewArray) {
            BOOL stillLooking = YES;
            //这个地方不需要重置的，立刻从上次的位置开始找，效率。。。不知道
            while (oldIndex < oldCount && stillLooking) {
                //得到排序结果
                NSComparisonResult result = ((NSComparisonResult (*)(id, SEL, id))objc_msgSend)(newItem, comparer, oldItem);
                if (result == NSOrderedSame && merger) {
                    // 两个相同的东东，哎。。。。我们呼叫merger
                    id repItem = [oldItem performSelector:merger withObject:newItem];
                    [mergingArray replaceObjectAtIndex:oldIndex withObject:repItem];
                    ++oldIndex;
                    oldItem = (oldIndex < oldCount)? [mergingArray objectAtIndex:oldIndex]:nil;
                    stillLooking = NO;
                } else if (result == NSOrderedAscending
                           || (result == NSOrderedSame && !merger)) {
                    //newArray的内容比自身的内容靠前，或者相同，但是没有提供合并器，直接插到自身复制前面好了
                    [mergingArray insertObject:newItem atIndex:oldIndex];
                    ++oldIndex;
                    ++oldCount;
                    stillLooking = NO;
                } else {
                    ++oldIndex;
                    oldItem = (oldIndex < oldCount)? [mergingArray objectAtIndex:oldIndex]: nil;
                }
            }
            if (stillLooking) {
                // newArray的内容比自身的所有内容都靠后了
                [mergingArray addObject:newItem];
            }
        }
        //完成工作了，考虑是不是要进行非可变的复制
        sortedMergedArray = mergingArray;
    } else if ([self count]) {
        sortedMergedArray = [self sortedArrayUsingSelector:comparer];
    } else if ([newArray count]) {
        sortedMergedArray = [newArray sortedArrayUsingSelector:comparer];
    }
    return sortedMergedArray;
}

- (NSData *)archivedArray
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}
@end
