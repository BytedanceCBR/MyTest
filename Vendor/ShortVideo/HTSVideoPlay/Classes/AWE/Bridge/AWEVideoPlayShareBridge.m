//
//  HTSVideoPlayShareBridge.m
//  Pods
//
//  Created by SongLi.02 on 18/11/2016.
//
//

#import "AWEVideoPlayShareBridge.h"
#import "TTModuleBridge.h"
#import "TSVShortVideoOriginalData.h"
#import "SDWebImageManager.h"
#import "HTSVideoPlayAccountBridge.h"
#import "AWEVideoConstants.h"

@implementation AWEVideoPlayShareBridge
/* 微信朋友圈、微信好友、微博、手机QQ、QQ空间、系统分享、保存视频、复制链接 */
+ (void)shareVideo:(TTShortVideoModel *)videoModel shareType:(AWEVideoPlayShareBridgeShareType)shareType controller:(UIViewController *)controller
{
    NSString *coverUrl = [videoModel.video.originCover.urlList firstObject];

    [self loadImageWithUrl:coverUrl completion:^(UIImage *coverImage) {
        NSMutableDictionary *shareParameters = [NSMutableDictionary dictionary];
        [shareParameters setValue:videoModel.itemID forKey:@"itemID"];
        if (videoModel.shareTitle.length > 0) {
            [shareParameters setValue:videoModel.shareTitle forKey:@"title"];
        } else {
            [shareParameters setValue:[NSString stringWithFormat:@"%@的精彩视频", videoModel.author.name] forKey:@"title"];
        }
        
        NSString *desc = videoModel.shareDesc;
        if (desc && desc.length > 0) {
           NSString *content = [desc length] > 30 ? [[desc substringToIndex:30] stringByAppendingString:@"..."] : desc;
            [shareParameters setValue:content forKey:@"content"];
        } else {
            [shareParameters setValue:@"这是我私藏的视频。一般人我才不分享！" forKey:@"content"];
        }
        
        
        NSString *contentType;
        NSString *copyContent;
        NSString *sinaWeiboContent;
        
        if ([videoModel.groupSource isEqualToString:AwemeGroupSource]) {
            contentType = @"shareAWEMEVideo";
            sinaWeiboContent = [NSString stringWithFormat:@"%@在抖音上分享了视频，快来围观！", videoModel.author.name];
            copyContent = [NSString stringWithFormat:@"%@在抖音上分享了视频，快来围观！传送门戳我>>%@", videoModel.author.name, videoModel.shareUrl];
        } else if ([videoModel.groupSource isEqualToString:HotsoonGroupSource]) {
            contentType = @"shareHotsoonVideo";
            sinaWeiboContent = [NSString stringWithFormat:@"%@在火山星球上分享了视频，快来围观！", videoModel.author.name];
            copyContent = [NSString stringWithFormat:@"%@在火山星球上分享了视频，快来围观！传送门戳我>>%@", videoModel.author.name, videoModel.shareUrl];
        } else if ([videoModel.groupSource isEqualToString:ToutiaoGroupSource]) {
            contentType = @"shareToutiaoVideo";
            sinaWeiboContent = [NSString stringWithFormat:@"%@在幸福里上分享了视频，快来围观！", videoModel.author.name];
            copyContent = [NSString stringWithFormat:@"%@在幸福里上分享了视频，快来围观！传送门戳我>>%@", videoModel.author.name, videoModel.shareUrl];
        } else {
            contentType = @"shareUnknownVideo";
            sinaWeiboContent = [NSString stringWithFormat:@"%@分享了视频，快来围观！", videoModel.author.name];
            copyContent = [NSString stringWithFormat:@"%@分享了视频，快来围观！传送门戳我>>%@", videoModel.author.name, videoModel.shareUrl];
        }
        
        [shareParameters setValue:videoModel.shareUrl forKey:@"shareURL"];
        [shareParameters setValue:coverImage forKey:@"shareImage"];
        [shareParameters setValue:sinaWeiboContent forKey:@"sinaWeiboContent"];
        [shareParameters setValue:copyContent forKey:@"copyContent"];
        [shareParameters setValue:controller forKey:@"viewController"];
        if (shareType == AWEVideoPlayShareBridgeShareTypeMore) {
            [shareParameters setValue:@(YES) forKey:@"allowDislike"];
            [shareParameters setValue:@(YES) forKey:@"allowReport"];
            [shareParameters setValue:@(NO) forKey:@"allowSave"];
        } else {
            [shareParameters setValue:@(NO) forKey:@"allowDislike"];
            [shareParameters setValue:@(NO) forKey:@"allowReport"];
            [shareParameters setValue:@(YES) forKey:@"allowSave"];
        }
        [shareParameters setValue:@(shareType) forKey:@"shareType"];
        [shareParameters setValue:contentType forKey:@"contentType"];
        [[TTModuleBridge sharedInstance_tt] triggerAction:@"com.toutiao.shareAction" object:self withParams:shareParameters.copy complete:nil];
    }];
}

+ (void)startListenShareWithBlock:(void(^)(id _Nullable params))block
{
    [[TTModuleBridge sharedInstance_tt] removeListener:self forKey:@"com.toutiao.shareItemAction"];
    [[TTModuleBridge sharedInstance_tt] registerListener:self object:nil forKey:@"com.toutiao.shareItemAction" withBlock:block];
}

+ (void)stopListenShare
{
    [[TTModuleBridge sharedInstance_tt] removeListener:self forKey:@"com.toutiao.shareItemAction"];
}

+ (void)loadImageWithUrl:(NSString *)urlStr completion:(void(^)(UIImage *image))completion
{
    if (urlStr.length == 0) {
        !completion ?: completion(nil);
        return;
    }
    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:urlStr] options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        !completion ?: completion((image));
    }];
}

@end
