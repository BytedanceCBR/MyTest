//
//  TTImageView+TrafficSave.m
//  Article
//
//  Created by Chen Hong on 14-9-28.
//
//

#import "TTImageView+TrafficSave.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "ExploreCellHelper.h"

@implementation TTImageView (TrafficSave)

- (void)setImageWithURLStringInTrafficSaveMode:(NSString *)URLString placeholderImage:(UIImage *)placeholder
{
    if ([ExploreCellHelper shouldDownloadImage]) {
        [self setImageWithURLString:URLString placeholderImage:placeholder options:0];
    } else {
        [[SDWebImageAdapter sharedAdapter] diskImageExistsWithKey:URLString completion:^(BOOL isInCache) {
            if (isInCache) {
                [self setImageWithURLString:URLString placeholderImage:placeholder options:0];
            } else {
                // 需要设置model，imageView依赖model计算实际显示的宽和高
                TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithURL:URLString];
                [self updateWithModel:model placeholderImage:placeholder placeholderView:nil options:0];
                [self setImage:placeholder];
            }
        }];
    }
}

- (void)setImageWithModelInTrafficSaveMode:(TTImageInfosModel *)model placeholderImage:(UIImage *)placeholder
{
    [self setImageWithModelInTrafficSaveMode:model
                            placeholderImage:placeholder
                                     success:nil
                                     failure:^(NSError *error) {
                                         if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                             if (error.code != NSURLErrorNotConnectedToInternet &&
                                                 error.code != NSURLErrorCancelled &&
                                                 error.code != NSURLErrorTimedOut) {
                                                 NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                                                 [extra setValue:model.URI forKey:@"URI"];
                                                 [extra setValue:@(error.code) forKey:@"code"];
                                                 [[TTMonitor shareManager] trackService:@"error_picture_url" status:1 extra:extra];
                                             }
                                         }
                                     }];
}

- (void)setImageWithModelInTrafficSaveMode:(TTImageInfosModel *)model
                          placeholderImage:(UIImage *)placeholder
                                   success:(TTImageViewSuccessBlock)success
                                   failure:(TTImageViewFailureBlock)failure
{
    if ([ExploreCellHelper shouldDownloadImage]) {
        [self setImageWithModel:model placeholderImage:placeholder options:0 success:success failure:failure];
    } else {
        // 需要设置model，imageView依赖model计算实际显示的宽和高
        [self updateWithModel:model placeholderImage:placeholder placeholderView:nil options:0];
        [self setImage:placeholder];
        
        [self setImageFromCacheWithModel:model atIndex:0 placeholderImage:placeholder success:success failure:failure];
    }
}

- (void)setImageFromCacheWithModel:(TTImageInfosModel *)model atIndex:(int)index placeholderImage:(UIImage *)placeholder success:(TTImageViewSuccessBlock)success failure:(TTImageViewFailureBlock)failure
{
    if (index >= model.urlWithHeader.count) {
        return;
    }
    
    NSString *url = [model urlStringAtIndex:index];
    
    [[SDWebImageAdapter sharedAdapter] diskImageExistsWithKey:url completion:^(BOOL isInCache) {
        if (isInCache) {
            [self setImageWithURLString:url placeholderImage:placeholder options:0 success:success failure:failure];
        } else {
            [self setImageFromCacheWithModel:model atIndex:index+1 placeholderImage:placeholder success:success failure:failure];
        }
    }];
}
@end
