//
//  TTUGCSentinel.m
//  Article
//
//  Created by Jiyee Sheng on 05/16/2017.
//
//

#import "TTUGCSentinel.h"
#import <libkern/OSAtomic.h>

@interface TTUGCSentinel ()

@property (nonatomic, assign, readwrite) int32_t value;

@end

@implementation TTUGCSentinel

- (int32_t)value {
    return _value;
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end
