//
//  TTShortVideoModel+TTAdFactory.m
//  HTSVideoPlay
//
//  Created by carl on 2017/12/8.
//

#import "TTShortVideoModel+TTAdFactory.h"
#import <objc/runtime.h>

@implementation TTShortVideoModel (TTAdFactory)

- (BOOL)isAd {
    if (self.raw_ad_data.count < 2) {
        return NO;
    }
    return YES;
}

- (TTAdShortVideoModel *)rawAd {
    if (self.raw_ad_data.count < 2) {
        return nil;
    }
    TTAdShortVideoModel *result = objc_getAssociatedObject(self, @selector(rawAd));
    if (result == nil) {
        NSError *jsonError = nil;
        result = [[TTAdShortVideoModel alloc] initWithDictionary:self.raw_ad_data error:&jsonError];
        if (jsonError == nil && result != nil) {
            [self setRawAd:result];
        }
    }
    return result;
}

- (void)setRawAd:(TTAdShortVideoModel *)rawAd
{
    objc_setAssociatedObject(self, @selector(rawAd), rawAd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
