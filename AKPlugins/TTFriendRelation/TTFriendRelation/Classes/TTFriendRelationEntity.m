//
//  TTFriendRelationEntity.m
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import "TTFriendRelationEntity.h"

@interface TTFriendRelationEntity()
@property (nonatomic, assign) BOOL needSave;
@property (nonatomic, strong, readwrite) TTFriendRelationFollowingNotifier *notifier;
@end

@implementation TTFriendRelationEntity

+ (NSInteger)dbVersion {
    return 2;
}

+ (NSString *)dbName {
    return @"fr_relation";
}

+ (NSString *)primaryKey {
    return @"userID";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[
                       @"userID",
                       @"isFollowing"
                       ];
    }
    return properties;
}

- (NSUInteger)hash {
    return [self.userID hash];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[TTFriendRelationEntity class]]) {
        return [self hash] == [object hash];
    } else {
        return NO;
    }
}

- (void)setIsFollowing:(BOOL)isFollowing {
    if (_isFollowing != isFollowing) {
        _isFollowing = isFollowing;
        [self.notifier notifyAllObserversValue:@(isFollowing)];
        [self trySave];
    }
}

//只有一个属性，暂时不换数据库了，先用柴淞的方法规避一下crash
- (void)trySave {
    if (self.needSave) {
        return;
    }
    self.needSave = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (self.needSave) {
            self.needSave = NO;
            [self save];
        }
    });
}

- (TTFriendRelationFollowingNotifier *)notifier {
    if (!_notifier) {
        _notifier = [[TTFriendRelationFollowingNotifier alloc] init];
    }
    return _notifier;
}

#pragma mark - TTFriendRelationNotifyProtocol

- (void)notifyAllObserversValue:(id)value {
    [self.notifier notifyAllObserversValue:value];
}

- (void)removeObserver:(id)observer {
    [self.notifier removeObserver:observer];
}

- (void)registerSelectorObserver:(id)observer {
    [self.notifier registerSelectorObserver:observer];
}

- (void)registerPropertyObserver:(id)observer keypath:(NSString *)keypath {
    [self.notifier registerPropertyObserver:observer keypath:keypath];
}

@end



























