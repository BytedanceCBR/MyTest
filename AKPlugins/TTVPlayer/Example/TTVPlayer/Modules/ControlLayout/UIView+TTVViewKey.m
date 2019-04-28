//
//  UIView+TTVViewKey.m
//  Article
//
//  Created by yangshaobo on 2018/11/25.
//

#import "UIView+TTVViewKey.h"
#import <objc/runtime.h>

@implementation UIView(TTVViewKey)

- (NSString *)ttvPlayerLayoutViewKey {
    return objc_getAssociatedObject(self, @selector(ttvPlayerLayoutViewKey));
}

- (void)setTtvPlayerLayoutViewKey:(NSString *)ttvKey {
    objc_setAssociatedObject(self, @selector(ttvPlayerLayoutViewKey), ttvKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
