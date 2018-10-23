//
//  TTActionButtonEventDelegate.m
//  Article
//
//  Created by Dai Dongpeng on 7/27/16.
//
//

#import "TTActionButtonEventDelegate.h"

@implementation TTActionButtonEventDelegate

- (instancetype)initWithTarget:(id <TTActionButtonEventProtocol>)target
{
    if (self = [super init]) {
        _target = target;
    }
    return self;
}

- (void)actionButtonPressed:(id)sender
{
    if ([self.target respondsToSelector:@selector(actionButtonPressed:)]) {
        [self.target actionButtonPressed:sender];
    }
}

@end
