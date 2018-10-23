//
//  TTStatusButton.m
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

#import "TTStatusButton.h"

@implementation TTStatusButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if ([self.delegate respondsToSelector:@selector(statusButtonHighlighted:)]) {
        [self.delegate statusButtonHighlighted:highlighted];
    }
}

@end