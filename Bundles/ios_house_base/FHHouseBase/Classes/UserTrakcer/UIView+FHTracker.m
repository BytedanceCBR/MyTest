//
//  UIView+FHTracker.m
//  FHHouseBase
//
//  Created by bytedance on 2020/10/13.
//

#import "UIView+FHTracker.h"
#import <objc/runtime.h>

@implementation UIView(FHTracker)

static const char fh_pageType_key, fh_originFrom_key;
- (void)setFh_pageType:(NSString *)fh_pageType {
    objc_setAssociatedObject(self, &fh_pageType_key, fh_pageType, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)fh_pageType {
    return objc_getAssociatedObject(self, &fh_pageType_key);
}

- (void)setFh_originFrom:(NSString *)fh_originFrom {
    objc_setAssociatedObject(self, &fh_originFrom_key, fh_originFrom, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)fh_originFrom {
    return objc_getAssociatedObject(self, &fh_originFrom_key);
}

@end
