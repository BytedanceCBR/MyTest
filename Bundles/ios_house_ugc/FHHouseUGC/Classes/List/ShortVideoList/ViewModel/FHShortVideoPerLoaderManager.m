//
//  FHShortVideoPerLoaderManager.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/10/20.
//

#import "FHShortVideoPerLoaderManager.h"
#import "TTVideoEngine+Preload.h"
#import "TTVVideoURLParser.h"

@interface FHShortVideoPerLoaderManager ()
@property (strong, nonatomic) NSMutableDictionary *cacheVidWithKeyMap;

@end

@implementation FHShortVideoPerLoaderManager


+ (void)startPrefetchShortVideoInDetailWithDataFetchManager:(FHShortVideoDetailFetchManager *)manager
{
//    if (![self isPrefetchEnabled]) {
//        return;
//    }
    NSInteger currentIndex = manager.currentIndex;
    
//    NSInteger preIndex = currentIndex - 1;
//    if (preIndex >= 0 && preIndex < [manager numberOfShortVideoItems]) {
//        FHFeedUGCCellModel *shortVideoModel = [manager itemAtIndex:preIndex];
//        [self preloadWithVideoModel:shortVideoModel];
//    }
    
    NSInteger nextIndex = currentIndex + 1;
    if (nextIndex >= 0 && nextIndex < [manager numberOfShortVideoItems]) {
        FHFeedUGCCellModel *shortVideoModel = [manager itemAtIndex:nextIndex];
        [self preloadWithVideoModel:shortVideoModel];
    }
    
}


+ (void)preloadWithVideoModel:(FHFeedUGCCellModel *)videoDetail {
    
    
    TTVideoEnginePreloaderVidItem *vidItem = [TTVideoEnginePreloaderVidItem preloaderVidItem:videoDetail.video.videoId reslution:TTVideoEngineResolutionTypeFullHD preloadSize:500 * 1024 isByteVC1:NO];
    vidItem.dashEnable = NO; /// 非 dash 资源
    vidItem.httpsEnable = NO;/// 非 https 资源
    vidItem.priorityLevel = TTVideoEnginePrloadPriorityDefault;/// 默认优先级
    /// apiVersion,apiStringCall,authCall 可以参照 play 接口说明
    vidItem.apiVersion = TTVideoEnginePlayAPIVersion1;
    vidItem.apiStringCall = ^NSString *(TTVideoEnginePlayAPIVersion apiVersion, NSString * _Nonnull vid) {
        return  [TTVVideoURLParser urlWithVideoID:videoDetail.video.videoId categoryID:videoDetail.categoryId itemId:videoDetail.itemId adID:@"" sp:TTVPlayerSPToutiao base:nil];;/// 参照播放器的 apiForFetcher: 代理方法的实现
    };
    /// Version1 需要实现该接口
    vidItem.authCall = ^NSString *(TTVideoEnginePlayAPIVersion apiVersion, NSString * _Nonnull vid) {
            return @"";/// 参照播放器的 setPlayAPIVersion:auth: 方法中 auth 的传参
    };
        
    vidItem.fetchDataEnd = ^(TTVideoEngineModel * _Nullable model, NSError * _Nullable error) {///获取VideoModel时的回调
            
    };
    /// 具体使用的 url 信息，包含 key， resoLution 的信息
    /// 对于新版的 dash 资源，这里可能返回两个 info 对象，一个音频一个视频，普通资源只有一个 info
    vidItem.usingUrlInfo = ^(NSArray<TTVideoEngineURLInfo *> * _Nonnull urlInfos) {
//            TTVideoEngineURLInfo *urlInfo = urlInfos.firstObject;
//            NSString *key = [urlInfo getValueStr:VALUE_FILE_HASH]; /// taskKey
//            TTVideoEngineResolutionType type = urlInfo.getVideoDefinitionType; /// Resolution
    };
        // 如果自定义缓存文件路径
    //    vidItem.cacheFilePath = ^NSString * _Nonnull(TTVideoEngineURLInfo * _Nonnull urlInfo) {
    //        NSString *cacheDir = nil;// 这里是自定义缓存文件夹路径，明确文件夹已创建
    //        NSString *fileNameYourCustom = nil;/// 自定义文件名部分
    //        NSString *fileHash = [urlInfo getValueStr:VALUE_FILE_HASH];
    //        NSString *fileName = [NSString stringWithFormat:@"%@%@",fileNameYourCustom,fileHash];
    //        return [cacheDir stringByAppendingPathComponent:fileName];
    //    };
    vidItem.preloadEnd = ^(TTVideoEngineLocalServerTaskInfo * _Nullable info, NSError * _Nullable error) {/// 预加载结束

    };
    /// 添加任务，开始预加载
    [TTVideoEngine ls_addTaskWithVidItem:vidItem];
}
@end
