//
//  SSControllerViewBase.m
//  Article
//
//  Created by Zhang Leonardo on 13-2-24.
//
//

#import "SSControllerViewBase.h"

@implementation SSControllerViewBase

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self trySSLayoutSubviews];
}

- (void)ssLayoutSubviews
{
    if (_delegate && [_delegate respondsToSelector:@selector(controllerViewBaseLayoutSubviews:)]) {
        [_delegate controllerViewBaseLayoutSubviews:self];
    }
}

@end
