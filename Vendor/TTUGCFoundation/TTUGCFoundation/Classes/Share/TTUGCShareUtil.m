//
//  TTUGCShareUtil.m
//  Article
//
//  Created by 王霖 on 17/2/21.
//
//

#import "TTUGCShareUtil.h"
#import "Thread.h"
#import "FRConcernEntity.h"

#import <SDImageCache.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>

#import <BDWebImage/SDWebImageAdapter.h>


@implementation TTUGCShareUtil

+ (nullable UIImage *)shareThumbImageForThread:(Thread *)thread {
    //分享图片使用优先级：帖子的第一张图片 > 帖子所包含文章的第一张图片 > 话题icon > 帖子作者头像 > 默认分享图
    __block UIImage * thumbImage = nil;
    
    //优先使用帖子的第一张图片
    if (thread.getThumbImageModels.count > 0) {
        [[thread getThumbImageModels] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[FRImageInfoModel class]]) {
                FRImageInfoModel *infoModel = (FRImageInfoModel *)obj;
                NSString *thumgImageUrl = [infoModel urlStringAtIndex:0];
                thumbImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:thumgImageUrl];
                if (thumbImage) {
                    *stop = YES;
                }
            }
        }];
    }
    
    //使用帖子所包含文章的第一张图片
    if (!thumbImage && [thread.groupDict tt_stringValueForKey:@"thumb_url"]) {
        thumbImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:[thread.groupDict tt_stringValueForKey:@"thumb_url"]];
    }
    
    //使用话题icon
    if (!thumbImage && [thread.forum tt_stringValueForKey:@"avatar_url"]) {
        thumbImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:[thread.forum tt_stringValueForKey:@"avatar_url"]];
    }
    
    //使用帖子作者头像
    if (!thumbImage && [thread.user tt_stringValueForKey:@"avatar_url"]) {
        thumbImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:[thread.user tt_stringValueForKey:@"avatar_url"]];
    }
    
    //优先使用share_icon.png分享
    if (!thumbImage) {
        thumbImage = [UIImage imageNamed:@"share_icon.png"];
    }
    //否则使用icon
    if(!thumbImage) {
        thumbImage = [UIImage imageNamed:@"Icon.png"];
    }
    
    return thumbImage;
}

+ (nullable NSString *)shareThumbImageURLForThread:(Thread *)thread {
    //分享图片使用优先级：帖子的第一张图片 > 帖子所包含文章的第一张图片 > 话题icon > 帖子作者头像 > 默认分享图
    __block NSString * thumbImageURL = nil;
    
    //优先使用帖子的第一张图片
    if ([thread.getThumbImageModels.firstObject isKindOfClass:[FRImageInfoModel class]]) {
        FRImageInfoModel * firstImageInfoModel = thread.getThumbImageModels.firstObject;
        thumbImageURL = [firstImageInfoModel urlStringAtIndex:0];
    }
    
    //使用帖子所包含文章的第一张图片
    if (isEmptyString(thumbImageURL)) {
        thumbImageURL = [thread.groupDict tt_stringValueForKey:@"thumb_url"];
    }
    
    //使用话题icon
    if (isEmptyString(thumbImageURL)) {
        thumbImageURL = [thread.forum tt_stringValueForKey:@"avatar_url"];
    }
    
    //使用帖子作者头像
    if (isEmptyString(thumbImageURL)) {
        thumbImageURL = [thread.user tt_stringValueForKey:@"avatar_url"];
    }
    
    return thumbImageURL;
}

+ (nullable UIImage *)shareThumbImageForConcernEntity:(FRConcernEntity *)concernEntity {
    UIImage * thumbImage = nil;
    
    //关心分享数据中分享图片URL
    if (!isEmptyString(concernEntity.share_data.image_url)) {
        thumbImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:concernEntity.share_data.image_url];
    }
    
    //关心avatar
    if (!thumbImage) {
        thumbImage = [[SDWebImageAdapter sharedAdapter] imageFromDiskCacheForKey:concernEntity.avatar_url];
    }
    
    //无数据时默认图：
    //优先使用share_icon.png分享
    if (!thumbImage) {
        thumbImage = [UIImage imageNamed:@"share_icon.png"];
    }
    //否则使用icon
    if(!thumbImage){
        thumbImage = [UIImage imageNamed:@"Icon.png"];
    }
    
    return thumbImage;
}

+ (nullable NSString *)shareThumbImageURLForConcernEntity:(FRConcernEntity *)concernEntity {
    NSString * thumbImageURL = concernEntity.share_data.image_url;
    
    if (isEmptyString(thumbImageURL)) {
        thumbImageURL = concernEntity.avatar_url;
    }
    
    return thumbImageURL;
}

@end
