//
//  WKNavigation+TTAdditions.m
//  Article
//
//  Created by muhuai on 01/11/2016.
//
//

#import "WKNavigation+TTAdditions.h"
#import <objc/runtime.h>

@implementation WKNavigation(TTAdditions)
@dynamic tt_URL;

- (void)setTt_URL:(NSURL *)tt_URL {
    objc_setAssociatedObject(self, @selector(tt_URL), tt_URL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)tt_URL {
    return objc_getAssociatedObject(self, _cmd);
}

@end
