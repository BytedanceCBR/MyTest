//
//  TTFriendRelationBaseNotifier.m
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import "TTFriendRelationBaseNotifier.h"

@implementation TTFriendRelationBaseNotifier

- (NSMapTable *)propertyNotifyMap {
    if (!_propertyNotifyMap) {
        _propertyNotifyMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality];
    }
    return _propertyNotifyMap;
}

- (NSHashTable *)selectorNotifyTable {
    if (!_selectorNotifyTable) {
        _selectorNotifyTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality];
    }
    
    return _selectorNotifyTable;
}

- (void)notifyAllObserversValue:(id)value {
    //子类实现
}

- (void)removeObserver:(id)observer {
    [self.propertyNotifyMap removeObjectForKey:observer];
    [self.selectorNotifyTable removeObject:observer];
}

- (void)registerPropertyObserver:(id)observer keypath:(NSString *)keypath {
    [self.propertyNotifyMap setObject:keypath forKey:observer];
}

- (void)registerSelectorObserver:(id<TTFriendRelationValueChangedProtocol>)observer {
    [self.selectorNotifyTable addObject:observer];
}

@end
