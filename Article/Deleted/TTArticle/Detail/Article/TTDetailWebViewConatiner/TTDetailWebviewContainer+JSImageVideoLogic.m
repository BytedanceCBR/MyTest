//
//  TTDetailWebviewContainer+JSImageVideoLogic.m
//  Article
//
//  Created by yuxin on 4/12/16.
//
//

#import "TTDetailWebviewContainer+JSImageVideoLogic.h"
#import "TTArticleDetailDefine.h"
#import "NSDictionary+TTAdditions.h"
#import <TTImage/TTWebImageManager.h>
#import "ArticleJSBridge.h"
#import "TTDetailWebViewRequestProcessor.h"
#import "TTRoute.h"
#import "NetworkUtilities.h"
#import "SSUserSettingManager.h"
#import "TTThemedAlertController.h"
#import "TTIndicatorView.h"
#import "TTStringHelper.h"
#import "TTUIResponderHelper.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"

@implementation TTDetailWebviewContainer (JSImageVideoLogic)

#pragma mark  Redirect Local Image Related Requests

- (BOOL)redirectRequestCanOpen:(NSURLRequest *)requestURL
{
    if ([requestURL.URL.scheme isEqualToString:kBytedanceScheme] ||
        [[requestURL.URL absoluteString] hasPrefix:TTLocalScheme] ||
        [[requestURL.URL absoluteString] hasPrefix:kLocalSDKDetailSCheme] ||
        [[requestURL.URL absoluteString] hasPrefix:kSNSSDKScheme]) {
        return YES;
    }
    return NO;
}


- (BOOL)redirectLocalRequest:(NSURL*)requestURL
{
    BOOL shouldStartLoad = YES;
    if([requestURL.scheme isEqualToString:kBytedanceScheme])
    {
        if([requestURL.host isEqualToString:kShowFullImageHost])
        {
            NSDictionary *parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            if([parameters count] > 0)
            {
                wrapperTrackEvent(@"detail", @"image_button");
                int index = [[parameters objectForKey:@"index"] intValue];
                NSValue * frameValue = nil;
                if ([parameters objectForKey:@"left"] && [parameters objectForKey:@"top"] && [parameters objectForKey:@"width"] && [parameters objectForKey:@"height"]) {
                    CGRect frame;
                    frame.origin.x = [[parameters objectForKey:@"left"] floatValue];
                    frame.origin.y = [[parameters objectForKey:@"top"] floatValue];
                    frame.size.width = [[parameters objectForKey:@"width"] floatValue];
                    frame.size.height = [[parameters objectForKey:@"height"] floatValue];
                    frameValue = [NSValue valueWithCGRect:frame];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(processRequestShowImgInPhotoScrollViewAtIndex:withFrameValue:)]) {
                    [self.delegate processRequestShowImgInPhotoScrollViewAtIndex:index withFrameValue:frameValue];
                }
            }
        }
        else if ([requestURL.host isEqualToString:kShowOriginImageHost]) { //4g网络下 缩略图 变原图
            NSArray * largeImgModels = self.largeImageInfoModels;// [_article detailLargeImageModels];
            NSDictionary *parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            int parIndex = (int)[[parameters objectForKey:@"index"] longLongValue];
            int index = parIndex;
            if (index < [largeImgModels count] && index >= 0) {
                TTImageInfosModel * largeModel = [largeImgModels objectAtIndex:index];

                BOOL cached = !isEmptyString([TTWebImageManager cachePathForModel:largeModel]);
                if (cached) {
                    [self p_webViewShowImageForModel:largeModel imageIndex:index imageType:JSMetaInsertImageTypeOrigin];
                }
                else {
                    
                    [self.downloadManager fetchImageWithModel:largeModel insertTop:YES];
                    //[self downloadImageModel:largeModels index:index insertTop:YES];
                }
                
                [self p_tryShowAlertForAlwaysDisplayLargeImage:YES];
            }
            
            TTNetworkTrafficSetting settingType = [TTUserSettingsManager networkTrafficSetting];
            if (settingType == TTNetworkTrafficSave) {
                wrapperTrackEvent(@"detail", @"show_one_image");
            }
            else {
                wrapperTrackEvent(@"detail", @"enlarger_image");
            }
        }
        else if ([requestURL.host isEqualToString:kWebViewUserClickLoadOriginImg] ) {//一键切换大图 按钮
            
            wrapperTrackEvent(@"detail", @"show_image");
            
            //[self updateArticleImageMode];
            if ([self.delegate respondsToSelector:@selector(processRequestUpdateArticleImageMode:)]) {
                [self.delegate processRequestUpdateArticleImageMode:@(1)];
            }
            
            if (!TTNetworkConnected()) {
                
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"无网络连接", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            }
            
            [self p_webViewShowImageIfCachedOrDownload:YES];
            
            [self p_tryShowAlertForAlwaysDisplayLargeImage:NO];
        }
        else if([requestURL.host isEqualToString:kWebViewCancelimageDownload])
        {
            NSArray * largeImgModels = self.largeImageInfoModels;// [_article detailLargeImageModels];
            NSArray * thumbImgModels = self.thumbImageInfoModels;// [_article detailThumbImageModels];
            
            NSDictionary *parameters = [TTStringHelper parametersOfURLString:requestURL.query];
            int parIndex = (int)[[parameters objectForKey:@"index"] longLongValue];
            
            if(parIndex < largeImgModels.count)
            {
                int index = parIndex;
                
                [self.downloadManager cancelDownloadForImageModel:largeImgModels[index]];
            }
            
            if(parIndex < thumbImgModels.count)
            {
                int index = parIndex;
                
                [self.downloadManager cancelDownloadForImageModel:thumbImgModels[index]];
            }
        }
        shouldStartLoad = NO;
    }
    return shouldStartLoad;
}


/**
 *  ‘总是显示大图’提示弹窗
 *
 *  @param showAll alert选择‘是’，下载页面内所有图片
 */
static NSString *const hasChoosenShowOriginImageKey = @"hasChoosenShowOriginImageKey";
- (void)p_tryShowAlertForAlwaysDisplayLargeImage:(BOOL)showAll
{
    [NewsDetailLogicManager didClickShowOriginButtonOnceInNoWifiNetworkIfNotSetTTNetworkTrafficOptimum];
    
    BOOL shouldShow = [NewsDetailLogicManager shouldShowChangedNetworkTrafficAlertWhenClickShowOriginButtonInNoWifiNetwork] && ![[NSUserDefaults standardUserDefaults] boolForKey:hasChoosenShowOriginImageKey];
    
    if (shouldShow) {
        __weak typeof(self) wself = self;
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"总是显示大图", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:NSLocalizedString(@"否", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert addActionWithTitle:NSLocalizedString(@"是", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [TTUserSettingsManager setNetworkTrafficSetting:TTNetworkTrafficOptimum];
            if (showAll) {
                //[wself updateArticleImageMode];
                if ([wself.delegate respondsToSelector:@selector(processRequestUpdateArticleImageMode:)]) {
                    [wself.delegate processRequestUpdateArticleImageMode:@(1)];
                }
                [wself p_webViewShowImageIfCachedOrDownload:YES];
            }
            
            //选择“是”后不再出现弹窗，即使用户改变trafficSetting设置，也不再弹出
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:hasChoosenShowOriginImageKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
    }
}
#pragma mark - 加载webView正文图片

- (void)tt_registerWebImageWithLargeImageModels:(NSArray <TTImageInfosModel *> *)largeImageModels
                               thumbImageModels:(NSArray <TTImageInfosModel *> *)thumbImageModels
                                  loadImageMode:(NSNumber *)imageMode
                     showOriginForThumbIfCached:(BOOL)showOriginForThumbIfCached
                        evaluateJsCallbackBlock:(TTLoadWebImageJsCallbackBlock)jsCallbackBlock
{
    self.downloadManager = [[NewsDetailImageDownloadManager alloc] init];
    self.downloadManager.delegate = self;
    self.largeImageInfoModels = largeImageModels;
    self.thumbImageInfoModels = thumbImageModels;
    self.imageMode = imageMode;
    self.imageJsCallBackBlock = jsCallbackBlock;
    
    __weak typeof(self) weakSelf = self;
    [self.webView.bridge registerHandlerBlock:^NSDictionary *(NSString *callbackId, NSDictionary *result, NSString *JSSDKVersion, BOOL *executeCallback) {
        if (executeCallback) {
            *executeCallback = NO;
        }
        NSString *type = [result stringValueForKey:@"type" defaultValue:nil];
        int index = [result intValueForKey:@"index" defaultValue:0];
        NSString *cachedSizeForAllType = [result stringValueForKey:@"all_cache_size" defaultValue:nil];
        [weakSelf p_webViewShowImageAtIndex:index
                                  imageType:type
                       cachedSizeForAllType:cachedSizeForAllType
                 showOriginForThumbIfCached:showOriginForThumbIfCached];
        return nil;
    } forJSMethod:@"loadDetailImage" authType:SSJSBridgeAuthPrivate];
}

- (void)p_webViewShowImageAtIndex:(NSInteger)index
                        imageType:(NSString *)typeStr
             cachedSizeForAllType:(NSString *)cachedSizeForAllType
       showOriginForThumbIfCached:(BOOL)showOriginForThumbIfCached
{
    
    /*
     * cachedSizeForAllType参数：在4G无图模式下，前端会请求all类型的图片，问答/文章详情页中，如果缓存了大图就会显示大图，缓存了小图就会显示小图；而帖子详情页中，即便缓存了大图也只能展示小图，展示小图由FE的all_cache_size参数指定
     */
    
    if ([typeStr isEqualToString:kShowOriginImageHost]) {
        if (index < [self.largeImageInfoModels count] && index >= 0) {
            TTImageInfosModel *largeModel = [self.largeImageInfoModels objectAtIndex:index];
            BOOL cached = !isEmptyString([TTWebImageManager cachePathForModel:largeModel]);
            if (cached) {
                [self p_webViewShowImageForModel:largeModel
                                      imageIndex:index
                                       imageType:JSMetaInsertImageTypeOrigin];
            }
            else {
                [self.downloadManager fetchImageWithModel:largeModel insertTop:YES];
            }
        }
    }
    else if ([typeStr isEqualToString:kWebViewShowThumbImage]) {
        [self p_webViewShowThumbImageAtIndex:index showOriginIfCached:showOriginForThumbIfCached];
    }
    else if ([typeStr isEqualToString:kJsMetaImageAllKey]) {
        if ([cachedSizeForAllType isEqualToString:kCacheSizeForAllTypeThumb]) {
            [self p_webViewShowThumbImageIfCachedOrDownload];
        }
        else {
            [self p_webViewShowImageIfCachedOrDownload:NO];
        }
    }
}

- (void)p_webViewShowThumbImageAtIndex:(NSInteger)index
                    showOriginIfCached:(BOOL)showOriginIfCached
{
    BOOL cached = NO;
    if (showOriginIfCached && index < self.largeImageInfoModels.count) {
        cached = !isEmptyString([TTWebImageManager cachePathForModel:self.largeImageInfoModels[index]]);
    }
    if(cached) {
        [self p_webViewShowImageForModel:self.largeImageInfoModels[index]
                              imageIndex:index
                               imageType:JSMetaInsertImageTypeOrigin];
    }
    else if(index < self.thumbImageInfoModels.count) {
        TTImageInfosModel *imageModel = self.thumbImageInfoModels[index];
        UIImage * thumbImg = [TTWebImageManager imageForModel:imageModel];
        if (thumbImg) {
            [self p_webViewShowImageForModel:imageModel
                                  imageIndex:index
                                   imageType:JSMetaInsertImageTypeThumb];
        }
        else {
            [self.downloadManager fetchImageWithModel:imageModel insertTop:YES];
        }
    }
}

- (void)p_webViewShowThumbImageIfCachedOrDownload {
    NSInteger listCount = MIN(self.largeImageInfoModels.count, self.thumbImageInfoModels.count);
    for (int i = 0; i < listCount; i ++) {
        TTImageInfosModel * thumbModel = [self.thumbImageInfoModels objectAtIndex:i];
        BOOL thumbImageCached = !isEmptyString([TTWebImageManager cachePathForModel:thumbModel]);
        if (thumbImageCached) {
            [self p_webViewShowImageForModel:thumbModel
                                  imageIndex:i
                                   imageType:JSMetaInsertImageTypeOrigin];
        }
    }
}

- (void)p_webViewShowImageIfCachedOrDownload:(BOOL)forseShowOriginImg
{
    JSMetaInsertImageType showImageType = [TTArticleDetailDefine tt_loadImageTypeWithImageMode:self.imageMode forseShowOriginImg:forseShowOriginImg];
    NSInteger listCount = MIN(self.largeImageInfoModels.count, self.thumbImageInfoModels.count);
    NSMutableArray * needDownloadModels = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < listCount; i ++) {
        TTImageInfosModel * largeModel = [self.largeImageInfoModels objectAtIndex:i];
        BOOL largeImageCached = !isEmptyString([TTWebImageManager cachePathForModel:largeModel]);
        
        if (showImageType == JSMetaInsertImageTypeOrigin || largeImageCached) {
            if (largeImageCached) {
                [self p_webViewShowImageForModel:largeModel
                                      imageIndex:i
                                       imageType:JSMetaInsertImageTypeOrigin];
            }
            else if (showImageType == JSMetaInsertImageTypeOrigin) {
                [needDownloadModels addObject:largeModel];
            }
        }
        else if (showImageType == JSMetaInsertImageTypeThumb) {
            TTImageInfosModel * thumbModel = [self.thumbImageInfoModels objectAtIndex:i];
            UIImage * thumbImage = [TTWebImageManager imageForModel:largeModel];
            BOOL thumbImageCached =  (thumbImage != nil);
            if (thumbImageCached) {
                [self p_webViewShowImageForModel:thumbModel
                                      imageIndex:i
                                       imageType:JSMetaInsertImageTypeThumb];
            }
            else {
                [needDownloadModels addObject:thumbModel];
            }
        }
    }
    if ([needDownloadModels count] > 0) {
        [self.downloadManager fetchImageWithModels:needDownloadModels insertTop:YES];
    }
}

- (void)p_webViewShowImageForModel:(TTImageInfosModel *)model
                        imageIndex:(NSInteger)index
                         imageType:(JSMetaInsertImageType)type
{
    if (model == nil) {
        return;
    }
    NSString * insertTypeStr = [TTArticleDetailDefine tt_loadImageJSStringKeyForType:type];
    NSString * path = [TTWebImageManager cachePathForModel:model];
    if (isEmptyString(path)) {
        return;
    }
    NSString * jsMethod = [NSString stringWithFormat:@"appendLocalImage(%ld,'file://%@','%@')", (long)index, path, insertTypeStr];
    if (self.imageJsCallBackBlock) {
        self.imageJsCallBackBlock(jsMethod);
    }
}

#pragma mark -- NewsDetailImageDownloadManagerDelegate

- (void)detailImageDownloadManager:(NewsDetailImageDownloadManager *)manager finishDownloadImageMode:(TTImageInfosModel *)model success:(BOOL)success
{
    NSUInteger index = [[[model userInfo] objectForKey:@"kArticleImgsIndexKey"] intValue];
    if ((model.imageType == TTImageTypeLarge || model.imageType == TTImageTypeThumb)) {
        JSMetaInsertImageType type = (model.imageType == TTImageTypeLarge) ? JSMetaInsertImageTypeOrigin : JSMetaInsertImageTypeThumb;
        [self p_webViewShowImageForModel:model
                              imageIndex:index
                               imageType:type];
    }
}

#pragma mark - 加载webView正文视频

- (void)tt_registerWebVideoWithMovieViewModel:(ExploreMovieViewModel *)movieViewModel
{
    self.movieViewModel = movieViewModel;
}

- (void)p_playVideoForVID:(NSString *)vid
                    frame:(CGRect)frame
                   status:(NSInteger)status
                       sp:(ExploreVideoSP)sp
                 videoUrl:(NSString *)videoUrl
               posterUrl:(NSString *)posterUrl
                 extra:(NSDictionary *)extra
{
    if (self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreMovieViewPlaybackFinishNotification object:self.movieView];
    }
    [self.movieView stopMovie];
    [self.movieView removeFromSuperview];
    self.movieView = nil;
    
    self.movieView = [[ExploreMovieView alloc] initWithFrame:frame
                                              movieViewModel:self.movieViewModel];
//    self.movieView.moviePlayerController.shouldShowShareMore = YES;
    self.movieView.stopMovieWhenFinished = YES;
    [self.movieView setVideoTitle:self.movieViewModel.movieTitle
             fontSizeStyle:TTVideoTitleFontStyleNormal
          showInNonFullscreenMode:NO];
    
    self.movieView.tracker.type = ExploreMovieViewTypeDetail;
    
    //额外信息,比如统计等
    if (extra && extra.allKeys.count > 0) {
        self.movieView.tracker.cID = [extra stringValueForKey:@"category_id" defaultValue:@""];
        self.movieView.tracker.ssTrackerDic = extra;
        //video_play&video_over 3.0埋点数据
        for (NSString *key in extra.allKeys) {
            [self.movieView.tracker addExtraValue:[extra valueForKey:key] forKey:key];
        }
    }
    
    if (!isEmptyString(posterUrl)) {
        [self.movieView setLogoImageUrl:posterUrl];
    }
    [self.webView.scrollView addSubview:self.movieView];
    
    if (isEmptyString(videoUrl)) {
        videoUrl = [self hasLocalVideoUrl:vid extra:extra];
    }
    
    if (!isEmptyString(videoUrl)) {
        [self.movieView playVideoForVideoURL:videoUrl];
    } else {
        
        [self.movieView playVideoForVideoID:vid exploreVideoSP:sp];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlayVideoFinishNotification:) name:kExploreMovieViewPlaybackFinishNotification object:self.movieView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlay:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:self.movieView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:self.movieView];
}

- (NSString *)hasLocalVideoUrl:(NSString *)videoId extra:(NSDictionary *)extra
{
    NSString *draftPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"TTVideoDraftFolder"];
    NSString * groupFolder = [draftPath stringByAppendingPathComponent:[extra stringValueForKey:@"qid" defaultValue:@""]];
    NSString * videoFolder = [groupFolder stringByAppendingPathComponent:@"uploadVideos"];
    
    NSString *videoUrl;
    NSString *file;
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:videoFolder];
    while (file = [enumerator nextObject]) {
        if ([file.stringByDeletingPathExtension isEqualToString:videoId]) { //判断文件名字
            videoUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",videoFolder,file]].absoluteString;
            break;
        }
    }
    return videoUrl;
    
}

- (CGRect)p_frameFromObject:(id)frameID
{
    CGRect frame = CGRectZero;
    if ([frameID isKindOfClass:[NSString class]] && [((NSString *)frameID) length] > 0) {
        frame = CGRectFromString(frameID);
    }
    else if ([frameID isKindOfClass:[NSArray class]] && [((NSArray *)frameID) count] == 4) {
        NSArray * frameAry = (NSArray *)frameID;
        frame.origin.x = (int)([[frameAry objectAtIndex:0] longLongValue]);
        frame.origin.y = (int)([[frameAry objectAtIndex:1] longLongValue]);
        frame.size.width = (int)([[frameAry objectAtIndex:2] longLongValue]);
        frame.size.height = (int)([[frameAry objectAtIndex:3] longLongValue]);
    }
    return frame;
}

- (void)p_addWebViewVideoObservers
{
    
    //监听视频播放状态 回调JS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePlayVideoNotification:)
                                                 name:kArticleJSBridgePlayVideoNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePauseVideoNotification:)
                                                 name:kArticleJSBridgePauseVideoNotification
                                               object:nil];
}

#pragma mark -- Notification center observer

- (void)receivePlayVideoFinishNotification:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreMovieViewPlaybackFinishNotification object:self.movieView];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
    }
}

- (void)stopMovieViewPlay:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreNeedStopAllMovieViewPlaybackNotification object:self.movieView];
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView stopMovie];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
    }
}

- (void)stopMovieViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:self.movieView];
        [self.movieView exitFullScreenIfNeed:NO];
        [self.movieView pauseMovieAndShowToolbar];
    }
}

- (void)receivePlayVideoNotification:(NSNotification *)notification
{
    if (self.webView.bridge != [notification object] && self.webView != [notification object]) {
        return;
    }
    
    CGRect frame = CGRectZero;
    @try {
        id frameID = [[notification userInfo] objectForKey:@"frame"];
        frame = [self p_frameFromObject:frameID];
    }
    @catch (NSException *exception) {
        frame = CGRectZero;
    }
    @finally {
        
    }
    
    if (CGRectEqualToRect(CGRectZero, frame)) {
        return;
    }
    
    
    ExploreVideoSP sp = (int)([[[notification userInfo] objectForKey:@"sp"] longLongValue]);
    if (!(sp == ExploreVideoSPToutiao || sp == ExploreVideoSPLeTV)) {
        return;
    }
    
    NSInteger status = (int)([[[notification userInfo] objectForKey:@"status"] longLongValue]);
    if (!(status == 0 || status == 1)) {
        return;
    }
    
    NSString * vid = [[notification userInfo] objectForKey:@"vid"];
    if ([self.movieView.playVID isEqualToString:vid]) {
        return;
    }

    NSString * url = [[notification userInfo] objectForKey:@"url"];
    url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([self.movieView.playMainURL isEqualToString:url]) {
        return;
    }
    
    NSDictionary *extra = [[notification userInfo] dictionaryValueForKey:@"extra" defalutValue:nil];
    NSString *posterurl = [[notification userInfo] stringValueForKey:@"poster" defaultValue:nil];
    [self p_playVideoForVID:vid frame:frame status:status sp:sp videoUrl:url posterUrl:posterurl extra:extra];
}

- (void)receivePauseVideoNotification:(NSNotification *)notification
{
    if (self.webView.bridge != [notification object] && self.webView != [notification object]) {
        return;
    }
    
    if (!self.movieView) {
        return;
    }
    
    [self.movieView pauseMovie];
}

@end
