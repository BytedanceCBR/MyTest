//
//  TTDetailWebviewContainer+JSImageVideoLogic.m
//  Article
//
//  Created by yuxin on 4/12/16.
//
//

#import "TTDetailWebviewContainer+JSImageVideoLogic.h"

#import <TTUIWidget/TTThemedAlertController.h>
#import <TTUIWidget/TTIndicatorView.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <TTBaseLib/TTStringHelper.h>
#import <TTImage/TTWebImageManager.h>
#import <TTTracker/TTTracker.h>
#import <TTRoute/TTRoute.h>
#import <TTUserSettings/TTUserSettingsManager+NetworkTraffic.h>
#import "TTDetailWebviewGIFManager.h"
#import "TTVPlayerUrlTracker.h"
#import "TTVDemanderTrackerManager.h"


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
                ttTrackEvent(@"detail", @"image_button");
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
                ttTrackEvent(@"detail", @"show_one_image");
            }
            else {
                ttTrackEvent(@"detail", @"enlarger_image");
            }
        }
        else if ([requestURL.host isEqualToString:kWebViewUserClickLoadOriginImg] ) {//一键切换大图 按钮
            
            ttTrackEvent(@"detail", @"show_image");
            
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
    [self.class didClickShowOriginButtonOnceInNoWifiNetworkIfNotSetTTNetworkTrafficOptimum];
    
    BOOL shouldShow = [self.class shouldShowChangedNetworkTrafficAlertWhenClickShowOriginButtonInNoWifiNetwork] && ![[NSUserDefaults standardUserDefaults] boolForKey:hasChoosenShowOriginImageKey];
    
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
    [self.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSString *type = [result stringValueForKey:@"type" defaultValue:nil];
        int index = [result intValueForKey:@"index" defaultValue:0];
        NSString *cachedSizeForAllType = [result stringValueForKey:@"all_cache_size" defaultValue:nil];
        [weakSelf p_webViewShowImageAtIndex:index
                                  imageType:type
                       cachedSizeForAllType:cachedSizeForAllType
                 showOriginForThumbIfCached:showOriginForThumbIfCached];
    } forMethodName:@"loadDetailImage"];
}

- (void)tt_registerCarouselBackUpdateWithCallback:(void (^)(NSInteger index, CGRect updatedFrame))jsCallback {
    [self.webView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *result, TTRJSBResponse callback) {
        NSInteger index = [result tt_integerValueForKey:@"index"];
        CGFloat width = [result tt_doubleValueForKey:@"width"];
        CGFloat height = [result tt_doubleValueForKey:@"height"];
        CGFloat x = [result tt_doubleValueForKey:@"left"];
        CGFloat y = [result tt_doubleValueForKey:@"top"];
        CGRect rect = CGRectMake(x, y, width, height);
        if (jsCallback) {
            jsCallback(index, rect);
        }
    } forMethodName:@"updateCarouselBackPosition"];
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
                                   imageType:JSMetaInsertImageTypeThumb];
        }
    }
}

- (void)p_webViewShowImageIfCachedOrDownload:(BOOL)forseShowOriginImg
{
    JSMetaInsertImageType showImageType = [TTDetailWebContainerDefine tt_loadImageTypeWithImageMode:self.imageMode forseShowOriginImg:forseShowOriginImg];
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
    NSString * insertTypeStr = [TTDetailWebContainerDefine tt_loadImageJSStringKeyForType:type];
    NSString * path = [TTWebImageManager cachePathForModel:model];
    if (isEmptyString(path)) {
        return;
    }
    if ([self.gifManager shouldUseNativeGIFPlayer:model imageIndex:index]) {
        NSString * jsMethod = [NSString stringWithFormat:@"appendLocalImage(%ld, '','%@',%@,%@)", (long)index, insertTypeStr, @(model.width), @(model.height)];
        if (self.imageJsCallBackBlock) {
            self.imageJsCallBackBlock(jsMethod);
        }
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

- (void)tt_registerWebVideoWithMovieViewInfo:(NSDictionary *)movieViewModel
{
    self.movieViewInfo = movieViewModel;
}

- (TTVBasePlayVideo *)playVideoWithParameters:(NSDictionary *)aparams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:aparams];
    NSDictionary *extra = [params valueForKey:@"extra"];
    if (extra) {
        [params addEntriesFromDictionary:extra];
    }
    CGRect frame = [params[@"frame"] CGRectValue];
    NSString *localUrl = [params valueForKey:@"localUrl"];
    NSString *videoUrl = [params valueForKey:@"videoUrl"];
    NSNumber *sp = [params valueForKey:@"sp"];
    
    NSString *videoID = [params valueForKey:@"video_id"];
    NSString *enterFrom = [params valueForKey:@"enter_from"];
    NSString *categoryName = [params valueForKey:@"category_name"];
    NSDictionary *logPb = [params valueForKey:@"log_pb"];
    NSString *posterUrl = [params valueForKey:@"posterUrl"];
    NSString *movieTitle = [params valueForKey:@"movieTitle"];
    BOOL isInDetail = [[params valueForKey:@"isInDetail"] boolValue];
    NSString *itemID = [params valueForKey:@"item_id"];
    NSString *groupID = [params valueForKey:@"group_id"];
    NSNumber *aggrType = [params valueForKey:@"aggr_type"];
    NSString *aID = [params valueForKey:@"aID"];
    NSString *cID = [params valueForKey:@"cID"];
    NSString *logExtra = [params valueForKey:@"log_extra"];
    NSString *gdLabel = [params valueForKey:@"gd_label"];
    NSString *videoThirdMonitorUrl = [params valueForKey:@"videoThirdMonitorUrl"];
    NSArray *adClickTrackURLs = [params valueForKey:@"adClickTrackURLs"];
    NSArray *adPlayOverTrackUrls = [params valueForKey:@"adPlayOverTrackUrls"];
    NSArray *adPlayEffectiveTrackUrls = [params valueForKey:@"adPlayEffectiveTrackUrls"];
    NSArray *adPlayActiveTrackUrls = [params valueForKey:@"adPlayActiveTrackUrls"];
    NSArray *adPlayTrackUrls = [params valueForKey:@"adPlayTrackUrls"];
    NSNumber *effectivePlayTime = [params valueForKey:@"effectivePlayTime"];
    NSString *authorId = [params valueForKey:@"author_id"];
    NSInteger video_watch_count = [[params valueForKey:@"video_watch_count"] integerValue];
    NSDictionary *videoLargeImageDict = [params valueForKey:@"largeImageDict"];
    NSObject <TTVBaseDemandPlayerDelegate> *delegate = [params valueForKey:@"playerDelegate"];
    if (isEmptyString(cID)) {
        cID = [extra valueForKey:@"category_id"];
        if (!cID) {
            cID = @"";
        }
    }
    if ([[extra allKeys] containsObject:@"position"]) {
        if ([[extra valueForKey:@"position"] isEqualToString:@"detail"]) {
            isInDetail = YES;
        }
    }
    //TTVPlayerModel
    TTVBasePlayerModel *model = [[TTVBasePlayerModel alloc] init];
    model.categoryID = cID;
    model.groupID = groupID;
    model.itemID = itemID;
    model.aggrType = [aggrType integerValue];
    model.adID = aID;
    model.logExtra = logExtra;
    model.videoID = videoID;
    model.trackLabel = gdLabel;
    model.isAutoPlaying = NO;
    model.logPb = logPb;
    model.enterFrom = enterFrom;
    model.categoryName = categoryName;
    model.authorId = authorId;
    model.sp = [sp integerValue];
    model.localURL = localUrl;
    model.commonExtra = extra;
    model.urlString = videoUrl;
    model.removeWhenFinished = YES;
    model.enableCommonTracker = YES;
    //movieView
    TTVBasePlayVideo *movie = [[TTVBasePlayVideo alloc] initWithFrame:frame playerModel:model];
    movie.player.enableRotate = YES;
    movie.player.delegate = delegate;
    {
        TTVPlayerUrlTracker *urlTracker = [[TTVPlayerUrlTracker alloc] init];
        urlTracker.effectivePlayTime = [effectivePlayTime floatValue];
        urlTracker.clickTrackURLs = adClickTrackURLs;
        urlTracker.playTrackUrls = adPlayTrackUrls;
        urlTracker.activePlayTrackUrls = adPlayActiveTrackUrls;
        urlTracker.effectivePlayTrackUrls = adPlayEffectiveTrackUrls;
        urlTracker.videoThirdMonitorUrl = videoThirdMonitorUrl;
        urlTracker.playOverTrackUrls = adPlayOverTrackUrls;
        [movie.commonTracker registerTracker:urlTracker];
    }
    movie.player.tipCreator = [[TTVPlayerTipNoFinishedViewCreator alloc] init];
    [movie setVideoLargeImageDict:videoLargeImageDict];
    [movie.player readyToPlay];
    movie.player.muted = NO;
    movie.player.isInDetail = isInDetail;
    movie.player.showTitleInNonFullscreen = NO;
    [movie.player play];
    
    [movie.player setVideoTitle:movieTitle];
    [movie.player setVideoWatchCount:video_watch_count playText:@"次播放"];
    //额外信息,比如统计等
    if (extra && extra.allKeys.count > 0) {
        //video_play&video_over 3.0埋点数据
        for (NSString *key in extra.allKeys) {
            [movie.commonTracker addExtra:extra forEvent:key];
        }
    }
    
    if (!isEmptyString(posterUrl)) {
        [movie setVideoLargeImageUrl:posterUrl];
    }
    
    return movie;
}

- (void)p_playVideoForVID:(NSString *)vid
                    frame:(CGRect)frame
                   status:(NSInteger)status
                       sp:(NSUInteger)sp
                 videoUrl:(NSString *)videoUrl
               posterUrl:(NSString *)posterUrl
                 extra:(NSDictionary *)extra
{
    [self.movieView stopWithFinishedBlock:^{
        
    }];
    [self.movieView removeFromSuperview];
    self.movieView = nil;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:self.movieViewInfo];
    [params setValue:[NSValue valueWithCGRect:frame] forKey:@"frame"];
    [params setValue:posterUrl forKey:@"posterUrl"];
    [params setValue:videoUrl forKey:@"videoUrl"];
    [params setValue:[self hasLocalVideoUrl:vid extra:extra] forKey:@"localUrl"];
    [params setValue:extra forKey:@"extra"];
    [params setValue:self forKey:@"playerDelegate"];
    if (!isEmptyString(vid)) {
        [params setValue:vid forKey:@"video_id"];
    }
    [params setValue:@(sp) forKey:@"sp"];
    
    self.movieView = [self playVideoWithParameters:params];
    [self.webView.scrollView addSubview:self.movieView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAllMovieViewPlay:) name:@"kExploreNeedStopAllMovieViewPlaybackNotification" object:self.movieView];
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
                                                 name:@"kArticleJSBridgePlayVideoNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePauseVideoNotification:)
                                                 name:@"kArticleJSBridgePauseVideoNotification"
                                               object:nil];
}

#pragma mark -- Notification center observer

- (void)stopAllMovieViewPlay:(NSNotification *)notification
{
    if ([notification object] == self.movieView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kExploreNeedStopAllMovieViewPlaybackNotification" object:self.movieView];
        [self.movieView.player exitFullScreen:YES completion:^(BOOL finished) {
            
        }];
        [self.movieView.player stop];
        [self.movieView removeFromSuperview];
        self.movieView = nil;
    }
}

- (void)receivePlayVideoNotification:(NSNotification *)notification
{
    if (self.webView != [notification object]) {
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
    
    
    /*ExploreVideoSP*/NSUInteger sp = (int)([[[notification userInfo] objectForKey:@"sp"] longLongValue]);
    if (!(sp == /*ExploreVideoSPToutiao*/0 || sp == /*ExploreVideoSPLeTV*/1)) {
        return;
    }
    
    NSInteger status = (int)([[[notification userInfo] objectForKey:@"status"] longLongValue]);
    if (!(status == 0 || status == 1)) {
        return;
    }
    
    NSString * vid = [[notification userInfo] objectForKey:@"vid"];
    NSString * url = [[notification userInfo] objectForKey:@"url"];
    NSDictionary *extra = [[notification userInfo] dictionaryValueForKey:@"extra" defalutValue:nil];
    NSString *posterurl = [[notification userInfo] stringValueForKey:@"poster" defaultValue:nil];
    [self p_playVideoForVID:vid frame:frame status:status sp:sp videoUrl:url posterUrl:posterurl extra:extra];
}

- (void)receivePauseVideoNotification:(NSNotification *)notification
{
    if (self.webView != [notification object]) {
        return;
    }
    
    [self.movieView.player pause];
}

//moved form NewsDetailLogicManager

//移动网络下累积点击5次查看大图，弹窗提示：总是显示大图？（可在设置里修改）。如果用户选择是，修改流量设置。
//移动网络下，当设置没有设置为最佳效果的时候，记录一次点击查看原图
#define kClickShowOriginButtonOnceInNoWifiNetworkIfNotSetTTNetworkTrafficOptimumKey @"kClickShowOriginButtonOnceInNoWifiNetworkIfNotSetTTNetworkTrafficOptimumKey"
+ (void)didClickShowOriginButtonOnceInNoWifiNetworkIfNotSetTTNetworkTrafficOptimum
{
    if (TTNetworkConnected() && !TTNetworkWifiConnected() && [TTUserSettingsManager networkTrafficSetting] != TTNetworkTrafficOptimum) {
        NSNumber * num = [[NSUserDefaults standardUserDefaults] objectForKey:kClickShowOriginButtonOnceInNoWifiNetworkIfNotSetTTNetworkTrafficOptimumKey];
        //        if ([num intValue] > kShowChangeNetworkSettingWhenClickOriginButtonNumber) {
        //            return;
        //        }
        NSNumber * result = [NSNumber numberWithInt:([num intValue] + 1)];
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:kClickShowOriginButtonOnceInNoWifiNetworkIfNotSetTTNetworkTrafficOptimumKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//是否应该显示改变加载图片方案的UIAlert
+ (BOOL)shouldShowChangedNetworkTrafficAlertWhenClickShowOriginButtonInNoWifiNetwork
{
    if (TTNetworkConnected() && !TTNetworkWifiConnected() && [TTUserSettingsManager networkTrafficSetting] != TTNetworkTrafficOptimum) {
        NSNumber * num = [[NSUserDefaults standardUserDefaults] objectForKey:kClickShowOriginButtonOnceInNoWifiNetworkIfNotSetTTNetworkTrafficOptimumKey];
        if ([num intValue] == 2) {
            return YES;
        }
        else if ([num intValue] == 5 ||
                 [num intValue] == 10 ||
                 [num intValue] == 20 ||
                 [num intValue] == 50) {
            return [self enabledShowAlwaysOriginImageAlertRepeatly];
        }
        
    }
    return NO;
}

+ (BOOL)enabledShowAlwaysOriginImageAlertRepeatly{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"SSCommonLogicSettingShowAlwaysOriginImageAlertRepeatlyKey"]) {
        return [[userDefaults objectForKey:@"SSCommonLogicSettingShowAlwaysOriginImageAlertRepeatlyKey"] boolValue];
    }
    return YES;
}

#pragma mark player delegate
/**
 播放器当前的播放状态
 */
- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if (state == TTVVideoPlaybackStateFinished) {
        [self.movieView removeFromSuperview];
        self.movieView = nil;
    }
}

/**
 播放器当前的loading状态
 */
- (void)playerLoadingState:(TTVPlayerLoadState)state
{
    
}
/**
 播放器改变旋转方向的回调
 */
- (void)playerOrientationState:(BOOL)isFullScreen
{
    
}
/**
 播放器内部各种事件的回掉,比如,点击了播放按钮,点击了全屏按钮,点击了暂停按钮等.
 */
- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
    
}
/**
 退出全屏,获取父view frame
 */
- (CGRect)ttv_movieViewFrameAfterExitFullscreen
{
    if ([TTDeviceHelper isPadDevice] || [TTDeviceHelper OSVersionNumber] < 9.0) {
        __block CGRect frame = CGRectZero;
        
        NSString *vid = self.movieView.playerModel.videoID;
        if (!isEmptyString(vid)) {
            NSString *js = [NSString stringWithFormat:@"getVideoFrame('%@')", vid];
            [self.webView stringByEvaluatingJavaScriptFromString:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                frame = [self p_frameFromObject:result];
                if (CGRectEqualToRect(frame, CGRectZero)) {
                    [self.movieView.player exitFullScreen:NO completion:^(BOOL finished) {
                        
                    }];
                    [self.movieView stop];
                    [self.movieView removeFromSuperview];
                    self.movieView = nil;
                }
            }];
        }
        return frame;
    }
    return CGRectZero;
}


- (void)layoutMovieViewsIfNeeded
{
    if ([TTDeviceHelper isPadDevice] && self.movieView) {
        __block CGRect frame = CGRectZero;
        NSString *vid = self.movieView.playerModel.videoID;
        if (!isEmptyString(vid)) {
            NSString *js = [NSString stringWithFormat:@"getVideoFrame('%@')", vid];
            __weak typeof(self) weakSelf = self;
            [self.webView stringByEvaluatingJavaScriptFromString:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                frame = [weakSelf p_frameFromObject:result];
                if (!CGRectEqualToRect(frame, CGRectZero)) {
                    if (!self.movieView.player.context.isFullScreen) {
                        weakSelf.movieView.frame = frame;
                    }
                }
                else {
                    [self.movieView.player exitFullScreen:NO completion:^(BOOL finished) {
                        
                    }];
                    [weakSelf.movieView stop];
                    [weakSelf.movieView removeFromSuperview];
                    weakSelf.movieView = nil;
                }
            }];
        }
    }
}


@end
