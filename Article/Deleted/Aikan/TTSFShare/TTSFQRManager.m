//
//  TTSFQRManager.m
//  QRDemo
//
//  Created by chenjiesheng on 2018/2/8.
//  Copyright © 2018年 陈杰生. All rights reserved.
//

#import "TTSFQRManager.h"
//#import "TTMahjongHelper.h"
#import "ArticleURLSetting.h"
//#import "UIImage+TTSFResource.h"
#import "TTServerDateCalibrator.h"

#import <TTURLUtils.h>
#import <SDWebImageManager.h>
#import <TTNetworkManager.h>
@implementation TTSFQRManager

static TTSFQRManager *shareInstance = nil;
+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[TTSFQRManager alloc] init];
    });
    
    return shareInstance;
}

+ (void)downLoadInfoWithInfoDict:(NSDictionary *)dict
                  withCompletion:(completionBlock)completionBlock
                       shareType:(TTSFQRShareType)shareType
                       mahjong:(TTMahjongModel *)mahjong
{
    NSInteger commonShareType = [dict tt_integerValueForKey:@"type"];
    NSInteger wechatShareType = [dict tt_integerValueForKey:@"wechat_share_type"];
    NSInteger timelineShareType = [dict tt_integerValueForKey:@"timeline_share_type"];
    NSInteger qqShareType = [dict tt_integerValueForKey:@"qq_share_type"];
    if ([self ignoreHandleQRShareWithType:commonShareType] &&
        [self ignoreHandleQRShareWithType:wechatShareType] &&
        [self ignoreHandleQRShareWithType:timelineShareType] &&
        [self ignoreHandleQRShareWithType:qqShareType]) {
        return;
    }
    
    //下载图片
    NSString *bgImageURL = [dict tt_stringValueForKey:@"share_bg_url"];
    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:bgImageURL] options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            NSString *targetURL = [dict tt_stringValueForKey:@"target_url"];
            NSInteger curTimeStamp = (NSInteger)[[[TTServerDateCalibrator sharedCalibrator] accurateCurrentServerDate] timeIntervalSince1970];
            NSURL *url = [TTURLUtils URLWithString:targetURL queryItems:@{@"timestamp":@(curTimeStamp).stringValue}];
            targetURL = url.absoluteString;
            NSString *requestURL = [ArticleURLSetting SFShareShotLinkURLString];
            NSString *shareTitle = [dict tt_stringValueForKey:@"pic_share_title"];
            NSMutableArray *params = [NSMutableArray array];
            if (!isEmptyString(targetURL)) {
                [params addObject:@{@"targets":targetURL}];
            }
            [params addObject:@{@"belong":@"TTSF"}];
            
            [[TTNetworkManager shareInstance] uploadWithURL:requestURL parameters:nil constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
                /**
                 *  key Generator
                 */
                
                for (NSDictionary * dict in params) {
                    for (NSString * key in dict) {
                        [formData appendPartWithFormData:[dict[key] dataUsingEncoding:NSUTF8StringEncoding] name:key];
                    }
                }
                
            } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([jsonObj isKindOfClass:[NSDictionary class]] && !error) {
                        NSDictionary *json = (NSDictionary *)jsonObj;
                        NSDictionary *data = [json tt_arrayValueForKey:@"data"].firstObject;
                        if ([data isKindOfClass:[NSDictionary class]]) {
                            NSString *shortLink = [data tt_stringValueForKey:@"short_url"];
                            if (!isEmptyString(shortLink)) {
                                UIImage *mahjongImage = nil;
                                if (mahjong) {
//                                    mahjongImage = [TTMahjongHelper foreContentImageWithMahjong:mahjong outlineType:TTMahjongOutlineTypeFrontBig];
                                }
                                UIImage *shareImage = [TTSFQRShareView shareImageWithMahjongImage:mahjongImage backImage:image tipText:shareTitle qrContent:shortLink type:shareType];
                                if (shareImage && completionBlock){
                                    completionBlock(shareImage);
                                }
                                return ;
                            }
                        }
                    }
                    NSString *shortLink = targetURL;
                    if (!isEmptyString(shortLink)) {
                        UIImage *mahjongImage = nil;
                        if (mahjong) {
//                            mahjongImage = [TTMahjongHelper foreContentImageWithMahjong:mahjong outlineType:TTMahjongOutlineTypeFrontBig];
                        }
                        UIImage *shareImage = [TTSFQRShareView shareImageWithMahjongImage:mahjongImage backImage:image tipText:shareTitle qrContent:shortLink type:shareType];
                        if (shareImage && completionBlock){
                            completionBlock(shareImage);
                        }
                    }
                });
            }];
        }
    }];
}

+ (BOOL)ignoreHandleQRShareWithType:(NSInteger)shareType
{
    return (shareType != 4 && shareType != 5);
}

+ (UIImage *)QRImageWithText:(NSString *)text
{
    // 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 恢复滤镜的默认属性
    [filter setDefaults];
    // 将字符串转换成NSData
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    // 通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
    [filter setValue:data forKey:@"inputMessage"];
    // 设置二维码 filter 容错等级
    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];
    // 生成二维码
    CIImage *outputImage = [filter outputImage];
    UIImage *image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:220.f];
    return image;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
