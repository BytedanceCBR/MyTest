//
//  SSWeakObject.m
//  Article
//
//  Created by Dianwei on 14-11-1.
//
//

#import "SSWeakObject.h"

@implementation SSWeakObject
- (void)dealloc {
    NSLog(@"=====WeakObjectDealloced");
}

+ (instancetype)weakObjectWithContent:(NSObject *)content {
    return [[self alloc] initWithContent:content];
}

- (instancetype)initWithContent:(NSObject *)content {
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

@end
