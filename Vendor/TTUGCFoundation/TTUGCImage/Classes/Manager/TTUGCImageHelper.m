//
//  TTUGCImageCategory.m
//  TTUGCFoundation
//
//  Created by jinqiushi on 2019/2/27.
//

#import "TTUGCImageHelper.h"
#import <TTBaselib/TTStringHelper.h>
#import <objc/runtime.h>
#import <BDWebImage/BDWebImageManager.h>

NSString * const kTTUGCImageSource = @"kTTUGCImageSource";

@implementation TTUGCImageHelper

+ (NSString *)imageKeyForImageModel:(FRImageInfoModel *)imageModel {
    NSString *key = nil;
    NSURL *url = [imageModel.url ttugc_feedImageURL];
    key = [[BDWebImageManager sharedManager] requestKeyWithURL:url];
    return key;
}


@end


@implementation NSURL (TTUGCSource)

- (NSString *)ttugc_source {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTtugc_source:(NSString *)ttugc_source {
    objc_setAssociatedObject(self, @selector(ttugc_source), ttugc_source, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSString (TTUGCFeedImage)
- (NSURL *)ttugc_feedImageURL {
    NSURL *url = [TTStringHelper URLWithURLString:self];
    url.ttugc_source = kTTUGCImageSource;
    return url;
}

@end


