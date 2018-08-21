//
//  TTTagViewConfig.m
//  Article
//
//  Created by fengyadong on 16/5/25.
//
//

#import "TTTagViewConfig.h"

@implementation TTTagViewConfig

- (instancetype)init {
    if (self = [super init]) {
        _padding = UIEdgeInsetsZero;
        _lineSpacing = 5.f;
        _interitemSpacing = 5.f;
    }
    return self;
}

@end
