//
//  TTAdCanvasProjectModel+Resource.m
//  Article
//
//  Created by carl on 2017/8/11.
//
//

#import "TTAdCanvasProjectModel+Resource.h"

#import "SSSimpleCache.h"
#import "TTAdCanvasUtils.h"

@implementation TTAdCanvasProjectModel (Resource)

- (BOOL)layoutResourceReady {
    if ([[SSSimpleCache sharedCache] isCacheExist:self.resource.jsonString]) {
        return YES;
    }
    return NO;
}

- (BOOL)imageResourceReady {
    
    BOOL (^imageCacheReady)(NSDictionary *imageInfo) = ^BOOL(NSDictionary *imageInfo) {
        NSError *jsonError;
        TTAdImageModel *infoModel = [[TTAdImageModel alloc] initWithDictionary:imageInfo error:&jsonError];
        if (!infoModel) {
            return NO;
        }
        if ([[SSSimpleCache sharedCache] data4AdImageModel:infoModel]) {
            return YES;
        }
        return NO;
    };
    
    __block BOOL imageReady = YES;
    if (self.resource.image.count > 0) {
        [self.resource.image enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!imageCacheReady(obj)) {
                imageReady = NO;
                *stop = YES;
            }
        }];
    }
    
    return imageReady;
}

- (BOOL)flagImageResourceReady {
    BOOL (^imageCacheReady)(NSDictionary *imageInfo) = ^BOOL(NSDictionary *imageInfo) {
        NSError *jsonError;
        BOOL flag = [imageInfo[@"preloading_flag"] boolValue];
        if (!flag) {
            return YES;
        }
        TTAdImageModel* infoModel = [[TTAdImageModel alloc] initWithDictionary:imageInfo error:&jsonError];
        if (!infoModel) {
            return NO;
        }
        if ([[SSSimpleCache sharedCache] data4AdImageModel:infoModel]) {
            return YES;
        }
        return NO;
    };
    __block BOOL imageReady = YES;
    [self.resource.image enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!imageCacheReady(obj)) {
            imageReady = NO;
            *stop = YES;
        }
    }];
    return imageReady;
}

- (BOOL)checkRequiredResource {
    if (![self layoutResourceReady]) {
        return NO;
    }
    return YES;
}

- (BOOL)checkFlagResource {
    if (![self layoutResourceReady]) {
        return NO;
    }
    if (![self flagImageResourceReady]) {
        return NO;
    }
    return YES;
}

- (BOOL)checkAllResource {
    if (![self layoutResourceReady]) {
        return NO;
    }
    if (![self imageResourceReady]) {
        return NO;
    }
    return YES;
}

- (BOOL)checkResource {
    TTAdCanvasOpenStrategy strategy = [TTAdCanvasUtils openStrategy];
    switch (strategy) {
        case TTAdCanvasOpenStrategyImmediately:
            if (![self checkRequiredResource]) {
                return NO;
            }
            break;
        case TTAdCanvasOpenStrategyFirstScreen: {
            if (![self checkFlagResource]) {
                return NO;
            }
        } break;
        default:
            if (![self checkAllResource]) {
                return NO;
            }
            break;
    }
    return YES;
}

@end
