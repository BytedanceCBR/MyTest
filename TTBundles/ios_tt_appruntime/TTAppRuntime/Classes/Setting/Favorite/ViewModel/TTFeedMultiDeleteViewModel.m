//
//  TTFeedMultiDeleteViewModel.m
//  Article
//
//  Created by fengyadong on 16/11/20.
//
//

#import "TTFeedMultiDeleteViewModel.h"

@implementation TTFeedMultiDeleteViewModel

- (instancetype)initWithDelegate:(id<TTFeedContainerViewModelDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        _deletingItems = [NSMutableSet set];
    }
    return self;
}

#pragma mark -- KVO Method

- (NSUInteger)countOfDeletingItems {
    return self.deletingItems.count;
}

- (void)addDeletingItemsObject:(id)object {
    [self.deletingItems addObject:object];
}

- (void)removeDeletingItemsObject:(id)object{
    [self.deletingItems removeObject:object];
}

@end
