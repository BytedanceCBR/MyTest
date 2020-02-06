//
//  TTSentienl.m
//  Article
//
//  Created by zhaoqin on 13/11/2016.
//
//

#import "TTSentienl.h"
#import <libkern/OSAtomic.h>

@interface TTSentienl ()
@property (nonatomic, assign, readwrite) int32_t value;
@end

@implementation TTSentienl

- (int32_t)value {
    return _value;
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end
