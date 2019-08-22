//
//  TTUGCImageKitchen.h
//  TTUGCFoundation
//
//  Created by song on 2019/1/15.
//

#import <Foundation/Foundation.h>
#import <TTKitchen/TTKitchen.h>

static NSString * kTTKUGCImageCacheOptimizeHosts = @"tt_ugc_base_config.image_cache_optimize_hosts"; // TTUGCImage缓存优化host
static NSString * kTTKUGCImageRequestRepeatEnable = @"tt_ugc_image_request_repeat_enable"; // 图片加载重复请求保护
static NSString * kTTKUGCImageUploadTimeout = @"tt_ugc_image_upload.timeout"; //图片上传超时时间
static NSString * kTTKUGCImageUploadRetryCount = @"tt_ugc_image_upload.retry_count"; //图片上传自动重试次数
static NSString * kTTKUGCBrowserQRCode = @"tt_ugc_reface_dict.browser_qr_code2";//图片浏览器识别二维码
static NSString * kTTKUGCPicUsingImageWithoutDataEnabled = @"tt_ugc_image_bd_based.pic_using_image_without_data_enabled"; //当只有image没有data的时候，再次查询
static NSString * kTTKUGCPicRecordCostTimeSample = @"tt_ugc_image_bd_based.pic_record_cost_sample";//cost统计的比例
static NSString * kTTKUGCPicRecordThumbEnabled = @"tt_ugc_image_bd_based.pic_record_thumb_enabled";//thumb统计开关
static NSString * kTTKUGCPicRecordGifEnabled = @"tt_ugc_image_bd_based.pic_record_gif_enabled";//gif统计开关

@interface TTUGCImageKitchen : NSObject

+ (BOOL)matchImageCacheOptimizeHost:(NSString *)aHost;

@end
