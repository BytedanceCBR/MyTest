//
//  TTUGCBDGIFLoadManager.m
//  Article
//
//  Created by jinqiushi on 2018/1/9.
//

#import "TTUGCBDGIFLoadManager.h"
#import <TTBaseLib/TTStringHelper.h>
#import <TTImage/TTWebImageManager.h>
#import "TTMonitor.h"
#import <TTBaseLib/TTBaseMacro.h>

#import "FRImageInfoModel.h"
#import "TTUGCImageView.h"
#import "TTUGCImageMonitor.h"
#import <TTKitchen.h>
#import <TTKitchenExtension/TTKitchenExtension.h>
#import <BDWebImage/BDWebImageManager.h>
#import "TTUGCImageHelper.h"

@interface TTUGCBDGIFLoadManager()

@property (nonatomic, strong) NSMutableSet<FRImageInfoModel *> *ugcGifInfoModelSet;

@end

@implementation TTUGCBDGIFLoadManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static TTUGCBDGIFLoadManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[TTUGCBDGIFLoadManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.ugcGifInfoModelSet = [NSMutableSet set];
    }
    return self;
}

- (void)startDownloadGifImageModel:(FRImageInfoModel *)gifImageModel {
    if ([self.ugcGifInfoModelSet containsObject:gifImageModel]) {
        //去重
        return;
    }
    //先进行cdn 降权排序
    NSArray *urlList = [[TTWebImageManager shareManger] sortedImageArray:gifImageModel.url_list];
    gifImageModel.url_list = (NSArray <TTImageURLInfoModel>*)urlList;
    
    //开始下载
    [self downloadGifImageModel:gifImageModel index:0 alreadyCostTime:0.0];
}

- (void)downloadGifImageModel:(FRImageInfoModel *)gifImageModel index:(NSUInteger)index alreadyCostTime:(NSTimeInterval)alreadyCostTime {
    if (index > gifImageModel.url_list.count - 1) {
        return;
    }
    
    [self.ugcGifInfoModelSet addObject:gifImageModel];
    
    NSString *urlString = ((TTImageURLInfoModel *)(gifImageModel.url_list[index])).url;
    NSURL *url = [urlString ttugc_feedImageURL];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    WeakSelf;
        [[BDWebImageManager sharedManager] requestImage:url
                                                options:BDImageRequestLowPriority
                                               complete:^(BDWebImageRequest *request, UIImage *image, NSData *data, NSError *error, BDWebImageResultFrom from) {
                                                   StrongSelf;
                                                   [self.ugcGifInfoModelSet removeObject:gifImageModel];
                                                   NSTimeInterval costTime = CFAbsoluteTimeGetCurrent() - startTime;

                                                   if (error) {
                                                       //影响对于cdn的请求排序

                                                       [[TTWebImageManager shareManger] recordOneFailItem:[TTStringHelper URLWithURLString:urlString]];
                                                       //失败处理
                                                       [self handleFailureGifModel:gifImageModel index:index costTimeInterval:alreadyCostTime + costTime];
                                                   } else {
                                                       //成功处理
                                                       [self handleSuccessGifModel:gifImageModel index:index costTimeInterval:alreadyCostTime + costTime];
                                                   }
                                               }];
    
}

- (void)handleFailureGifModel:(FRImageInfoModel *)gifImageModel index:(NSUInteger)index costTimeInterval:(NSTimeInterval)timeInterval
{
    if (index >= gifImageModel.url_list.count - 1) {
        //端监控 动图下载失败节点
        [TTUGCImageMonitor trackGifDownloadSucceed:NO index:index costTimeInterval:timeInterval];
        [TTUGCImageMonitor requestCompleteWithImageModel:gifImageModel withSuccess:NO];
        return;
    }
    [self downloadGifImageModel:gifImageModel index:index + 1 alreadyCostTime:timeInterval];
}

- (void)handleSuccessGifModel:(FRImageInfoModel *)gifImageModel index:(NSUInteger)index costTimeInterval:(NSTimeInterval)timeInterval
{
    //添加端监控 动图下载成功节点
    [TTUGCImageMonitor trackGifDownloadSucceed:YES index:index costTimeInterval:timeInterval];
    [TTUGCImageMonitor requestCompleteWithImageModel:gifImageModel withSuccess:YES];
    //发出通知
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:gifImageModel forKey:kUGCImageViewGifInfoModelKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUGCImageViewBDGifRequestOverNotification object:nil userInfo:userInfo];
}
@end

