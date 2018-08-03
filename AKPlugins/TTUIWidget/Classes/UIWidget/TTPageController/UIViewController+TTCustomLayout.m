//
//  UIViewController+TTCustomLayout.m
//  Article
//
//  Created by Dai Dongpeng on 4/18/16.
//
//

#import "UIViewController+TTCustomLayout.h"
@import ObjectiveC;

@implementation UIViewController (TTCustomLayout)

- (id<TTLayoutProtocol>)tt_layout
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTt_layout:(id<TTLayoutProtocol>)tt_layout
{
    if ([tt_layout respondsToSelector:@selector(layoutWillAddToTargetViewController:)]) {
        [tt_layout layoutWillAddToTargetViewController:self];
    }
    
    objc_setAssociatedObject(self, @selector(tt_layout), tt_layout, OBJC_ASSOCIATION_RETAIN);
   
    if ([tt_layout respondsToSelector:@selector(layoutDidAddToTargetViewController:)]) {
        [tt_layout layoutDidAddToTargetViewController:self];
    }
}

- (void)tt_resetLayoutToMinHeader:(BOOL)animated
{
    if ([self.tt_layout respondsToSelector:@selector(resetLayoutToMinHeader:)]) {
        [self.tt_layout resetLayoutToMinHeader:animated];
    }
}
- (void)tt_resetLayoutToMaxHeader:(BOOL)animated
{
    if ([self.tt_layout respondsToSelector:@selector(resetLayoutToMaxHeader:)]) {
        [self.tt_layout resetLayoutToMaxHeader:animated];
    }
}

- (void)tt_resetLayoutSubItems
{
    if ([self.tt_layout respondsToSelector:@selector(resetLayoutSubItems)]) {
        [self.tt_layout resetLayoutSubItems];
    }
}
@end
