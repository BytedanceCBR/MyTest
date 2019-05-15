//
//  UIView+TTVPlayerSortPriority.m
//  Article
//
//  Created by yangshaobo on 2018/11/7.
//

#import "UIView+TTVPlayerSortPriority.h"
#import <objc/runtime.h>

@implementation UIView(TTVPlayerSortPriority)

- (double)ttvPlayerSortContainerPriority {
    double ret = [(NSNumber *)objc_getAssociatedObject(self, @selector(ttvPlayerSortContainerPriority)) doubleValue];
    return ret >= 0 ? ret : 0;
}

-(void)setTtvPlayerSortContainerPriority:(double)ttvPlayerSortContainerPriority {
    objc_setAssociatedObject(self, @selector(ttvPlayerSortContainerPriority), @(ttvPlayerSortContainerPriority >= 0 ? ttvPlayerSortContainerPriority : 0), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
