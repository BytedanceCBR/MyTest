//
//  FHHouseNewComponentViewModel.m
//  FHHouseList
//
//  Created by bytedance on 2020/10/28.
//

#import "FHHouseNewComponentViewModel.h"

@interface FHHouseNewComponentViewModel() 
@end

@implementation FHHouseNewComponentViewModel
@synthesize cachedHeight = _cachedHeight, needCalculateHeight = _needCalculateHeight;

- (instancetype)init {
    self = [super init];
    if (self) {
        _needCalculateHeight = YES;
        _observers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)dealloc {
    [_observers removeAllObjects];
}

- (void)addObserver:(id<FHHouseNewComponentViewModelObserver>)observer {
    if (![_observers containsObject:observer]) {
        [_observers addObject:observer];
    }
}

- (void)removeObserver:(id<FHHouseNewComponentViewModelObserver>)observer {
    if ([_observers containsObject:observer]) {
        [_observers removeObject:observer];
    }
}

- (BOOL)isValid {
    return NO;
}

- (void)setNeedCalculateHeight {
    _needCalculateHeight = YES;
}

@end
