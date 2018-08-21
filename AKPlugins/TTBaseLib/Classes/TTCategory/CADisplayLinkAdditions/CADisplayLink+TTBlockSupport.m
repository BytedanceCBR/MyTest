//
//  CADisplayLink+TTBlockSupport.m
//  Article
//
//  Created by 王霖 on 16/10/13.
//
//

#import "CADisplayLink+TTBlockSupport.h"
#import <objc/runtime.h>

#pragma mark - CADisplayLink block support(fix retain cycle)

@implementation CADisplayLink (TTBlockSupport)

+ (instancetype)ttDisplayLinkWithBlock:(void(^)())block {
    CADisplayLink * displayLink = [self displayLinkWithTarget:self selector:@selector(_ttBlockInvoke:)];
    displayLink.block = block;
    return displayLink;
}

+ (void)_ttBlockInvoke:(CADisplayLink *)displayLink {
    void (^block)() = displayLink.block;
    if (block) {
        block();
    }
}

- (void)setBlock:(void (^)())block {
    objc_setAssociatedObject(self, _cmd, [block copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void(^)())block {
    return objc_getAssociatedObject(self, @selector(setBlock:));
}

@end
