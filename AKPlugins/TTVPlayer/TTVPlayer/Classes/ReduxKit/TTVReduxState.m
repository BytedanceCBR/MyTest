//
//  TTVReduxState.m
//  Created by panxiang on 2018/7/20.
//

#import "TTVReduxState.h"

@interface TTVReduxState ()

@property (nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSObject<TTVReduxStateProtocol> *>* subStates;

@end

@implementation TTVReduxState

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setSubState:(NSObject<TTVReduxStateProtocol> *)subState forKey:(id<NSCopying>)key {
    if ([((NSObject *)key) conformsToProtocol:@protocol(NSCopying)]) {
        if (!self.subStates) {
            self.subStates = @{}.mutableCopy;
        }
        self.subStates[key] = subState;
    }
}

- (NSObject<TTVReduxStateProtocol> *)subStateForKey:(id<NSCopying>)key {
    if ([((NSObject *)key) conformsToProtocol:@protocol(NSCopying)]) {
        return self.subStates[key];
    }
    return nil;
}

#pragma NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    // super 不会调用
    TTVReduxState * copyed = [TTVReduxState allocWithZone:zone];
    copyed.subStates = [[NSMutableDictionary alloc] initWithDictionary:self.subStates copyItems:YES];
    return copyed;
}

- (BOOL)isEqual:(id)other {
    if (!other) {
        return NO;
    }
    if (self == other)  {
        return YES;
    }
    
    if (![other isKindOfClass:[TTVReduxState class]]) {
        return NO;
    }
    return [self isEqualToState:(TTVReduxState *)other];
}

- (BOOL)isEqualToState:(TTVReduxState *)other {
    if ([self.subStates isEqual:other.subStates]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.subStates hash];
}

@end
