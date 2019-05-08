//
//  TTVFluxDispatcher.m
//  Pods
//
//  Created by xiangwu on 2017/3/3.
//
//

#import "TTVFluxDispatcher.h"
#import "TTVFluxAction.h"
#import "TTVFluxStore.h"

@interface TTVFluxDispatcher ()

@property (nonatomic, strong) NSHashTable *storeTable;

@end

@implementation TTVFluxDispatcher
- (instancetype)init {
    self = [super init];
    if (self) {
        _storeTable = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)dispatchAction:(TTVFluxAction *)action {
    for (TTVFluxStore *store in self.storeTable) {
        if ([store respondToAction:action]) {
            [store receiveAction:action];
        }
    }
}

- (void)registerStore:(TTVFluxStore *)store {
    if (store) {
        if (![self.storeTable containsObject:store]) {
            [self.storeTable addObject:store];
        }
    }
}

@end
