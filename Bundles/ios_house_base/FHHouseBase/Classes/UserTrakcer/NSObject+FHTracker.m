//
//  NSObject+FHTracker.m
//  FHHouseBase
//
//  Created by bytedance on 2020/10/13.
//

#import "NSObject+FHTracker.h"
#import <objc/runtime.h>

@implementation NSObject(FHTracker)

static const char fh_pageType_key, fh_originFrom_key, fh_trackModel_key;
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

- (void)setFh_trackModel:(FHTracerModel *)fh_trackModel {
    objc_setAssociatedObject(self, &fh_trackModel_key, fh_trackModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FHTracerModel *)fh_trackModel {
    return objc_getAssociatedObject(self, &fh_trackModel_key);
}

@end
