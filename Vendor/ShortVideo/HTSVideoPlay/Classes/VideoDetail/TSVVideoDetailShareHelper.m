//
//  TSVVideoDetailShareHelper.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2017/11/29.
//

#import "TSVVideoDetailShareHelper.h"
#import "TTShortVideoModel.h"
#import "TTImageInfosModel.h"
#import "TTRoute.h"
#import "HTSDeviceManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
//#import <AFNetworking/AFNetworking.h>
#import "HTSVideoPlayToast.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <TTServiceProtocols/TTRepostServiceProtocol.h>
#import <TTServiceCenter.h>


@implementation TSVVideoDetailShareHelper

+ (void)handleForwardUGCVideoWithModel:(TTShortVideoModel *)model
{
    NSDictionary *repostParams = [TSVVideoDetailShareHelper repostParamsWithShortVideoModel:model];
    [GET_SERVICE_BY_PROTOCOL(TTRepostServiceProtocol) showRepostVCWithRepostParams:repostParams];
}

+ (NSDictionary *)repostParamsWithShortVideoModel:(TTShortVideoModel *)model {
    NSString *fw_id = model.itemID;
    NSString *fw_user_id = model.author.userID;
    NSString *cover_url = [model.detailCoverImageModel urlStringAtIndex:0];
    NSString *forwardTitle = [NSString stringWithFormat:@"%@：%@",model.author.name,model.title];
    
    NSMutableDictionary *repostParams = [NSMutableDictionary dictionary];
    [repostParams setValue:cover_url forKey:@"cover_url"];
    [repostParams setValue:forwardTitle forKey:@"title"];
    [repostParams setValue:@(1) forKey:@"is_video"];
    [repostParams setValue:@(6) forKey:@"opt_id_type"];
    [repostParams setValue:fw_id forKey:@"opt_id"];
    [repostParams setValue:@(213) forKey:@"repost_type"];
    [repostParams setValue:@(6) forKey:@"fw_id_type"];
    [repostParams setValue:fw_user_id forKey:@"fw_user_id"];
    [repostParams setValue:fw_id forKey:@"fw_id"];
    
    return repostParams;
}

//+ (void)handleSaveVideoWithModel:(TTShortVideoModel *)model
//{
//    UIView *containerView = [[UIApplication sharedApplication] keyWindow];
//    [HTSDeviceManager requestPhotoLibraryPermission:^(BOOL success) {
//        if (!success) {
//            [HTSDeviceManager presentPhotoLibraryDeniedAlert];
//        } else {
//            UIView *indicatorMaskView = [[UIView alloc] initWithFrame:containerView.bounds];
//            [containerView addSubview:indicatorMaskView];
//
//            [MBProgressHUD hideAllHUDsForView:indicatorMaskView animated:YES];
//            [[MBProgressHUD showHUDAddedTo:indicatorMaskView animated:YES] setLabelText:@"正在下载..."];
//
//            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[model.video.downloadAddr.urlList firstObject]]];
//            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//                NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[response suggestedFilename]];
//                return [NSURL fileURLWithPath:path];
//            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//                if (error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (containerView) {
//                            [MBProgressHUD hideAllHUDsForView:indicatorMaskView animated:YES];
//                            [indicatorMaskView removeFromSuperview];
//                            NSString *message = error.userInfo[@"prompts"] ?: @"下载失败";
//                            [HTSVideoPlayToast show:message];
//                        }
//                    });
//                } else {
//                    ALAssetsLibrary *library = [ALAssetsLibrary new];
//                    [library writeVideoAtPathToSavedPhotosAlbum:filePath completionBlock:^(NSURL *assetURL, NSError *error) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            if (containerView) {
//                                [MBProgressHUD hideAllHUDsForView:indicatorMaskView animated:YES];
//                                [indicatorMaskView removeFromSuperview];
//                                [HTSVideoPlayToast show:(error ? @"视频保存失败" : @"已保存到相册，快去分享吧")];
//                            }
//                        });
//                        [[NSFileManager defaultManager] removeItemAtURL:filePath error:NULL];
//                    }];
//                }
//            }];
//            [downloadTask resume];
//        }
//    }];
//}
@end
