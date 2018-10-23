//
//  TTVFeedCellSelectContext.m
//  Article
//
//  Created by panxiang on 2017/4/19.
//
//

#import "TTVFeedCellSelectContext.h"
#import "TTVFeedListVideoCellHeader.h"
#import "TTVFeedListItem.h"
#import "TTVFeedListCell.h"
#import "TTAdImpressionTracker.h"
#import "SSADEventTracker.h"
#import "TTVVideoArticle+Extension.h"
#import "SSWebViewController.h"
#import "TTStringHelper.h"
#import "TTCategoryDefine.h"
#import "ArticleDetailHeader.h"
#import "TTAppLinkManager.h"
#import "TTVPlayVideo.h"
#import "TTVideoShareMovie.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "Article+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "TTUIResponderHelper.h"
#import "TTRoute.h"
#import "TTVAutoPlayManager.h"
#import "TTVFeedItem+ComputedProperties.h"
#import "TTVADInfo+ActionTitle.h"
#import "TTVADCell+ADInfo.h"
#import <TTBaseLib/JSONAdditions.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTTrackerProxy.h"
#import "TTADEventTrackerEntity.h"

@implementation  TTVFeedCellSelectContext

- (NSMutableDictionary *)eventContext {
    if (!_eventContext) {
        _eventContext = [[NSMutableDictionary alloc] init];
    }
    return _eventContext;
}

@end

@implementation TTVFeedCellDefaultSelectHandler

+ (BOOL)canContinuePlayMovieOnView:(id <TTVFeedPlayMovie> )view withArticle:(TTVVideoArticle *)article
{
    if ([article isVideoSubject] && [view respondsToSelector:@selector(cell_movieView)] && [view cell_hasMovieView]) {
        return ([view cell_isPaused] || [view cell_isPlayingFinished] || [view cell_isPlaying]);
    }
    return NO;
}


+ (NewsGoDetailFromSource)goDetailFromSouce:(NSString *)categoryID
{
    if (!isEmptyString(categoryID) && [categoryID isEqualToString:kTTMainCategoryID]) {
        return NewsGoDetailFromSourceHeadline;
    }
    else
    {
        return NewsGoDetailFromSourceCategory;
    }
    return NewsGoDetailFromSourceUnknow;
}

+ (BOOL)openSchemaWithOpenUrl:(NSString *)openUrl article:(TTVVideoArticle *)article adid:(NSString *)adid logExtra:(NSString *)logExtra statParams:(NSMutableDictionary *)statParams
{
    //打开详情页：优先判断openURL是否可以用外部schema打开，否则判断内部schema
    BOOL canOpenURL = NO;

    NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
    [applinkParams setValue:logExtra forKey:@"log_extra"];

    if (!isEmptyString(adid) && !article.hasVideo) {
        if ([TTAppLinkManager dealWithWebURL:article.articleURL openURL:openUrl sourceTag:@"embeded_ad" value:adid extraDic:applinkParams]) {
            //针对广告并且能够通过sdk打开的情况
            canOpenURL = YES;
        }
    }

    if (!canOpenURL && !isEmptyString(openUrl)) {
        NSURL *url = [TTStringHelper URLWithURLString:openUrl];

        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            canOpenURL = YES;
            [[UIApplication sharedApplication] openURL:url];
        }
        else if ([[TTRoute sharedRoute] canOpenURL:url]) {

            canOpenURL = YES;
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(statParams)];
            //针对广告不能通过sdk打开，但是传的有内部schema的情况
            if(isEmptyString(adid)){
                wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", adid, nil, applinkParams);
            }
        }
    }
    return canOpenURL;
}

+ (BOOL)didSelectItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context {
    if (![item isKindOfClass:[TTVFeedListItem class]]) {
        return NO;
    }
    TTVFeedListCell *cell = (TTVFeedListCell *)item.cell;
    if (![cell isKindOfClass:[TTVFeedListCell class]]) {
        return NO;
    }

    [self commonAdSelectionWithItem:item context:context];

    TTVVideoArticle *article = item.article;
    if ((article.groupFlags & kVideoArticleGroupFlagsOpenUseWebViewInList) > 0 && !isEmptyString(article.articleURL)) {
        return [self openWebviewWithItem:item context:context];
    }
    else{
        return [self openVideoDetailWithItem:item context:context];
    }
    return NO;
}

+ (BOOL)openWebviewWithItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    if (![item isKindOfClass:[TTVFeedListItem class]]) {
        return NO;
    }
    TTVFeedListCell *cell = (TTVFeedListCell *)item.cell;
    if (![cell isKindOfClass:[TTVFeedListCell class]]) {
        return NO;
    }
    UIViewController *topController = [TTUIResponderHelper correctTopViewControllerFor:cell];
    TTVVideoArticle *article = item.article;
    NSString *adid = isEmptyString(article.adId) ? nil : [NSString stringWithFormat:@"%@", article.adId];
    NSString *logExtra = article.logExtra;

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
    [parameters setValue:adid forKey:SSViewControllerBaseConditionADIDKey];
    [parameters setValue:logExtra forKey:@"log_extra"];
    ssOpenWebView([TTStringHelper URLWithURLString:article.articleURL], nil, topController.navigationController, !!(adid), parameters);
    return YES;
}

+ (BOOL)openVideoDetailWithItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    if (![item isKindOfClass:[TTVFeedListItem class]]) {
        return NO;
    }
    TTVFeedListCell *cell = (TTVFeedListCell *)item.cell;
    if (![cell isKindOfClass:[TTVFeedListCell class]]) {
        return NO;
    }

    NSString *categoryID = context.categoryId;
    TTVVideoArticle *article = item.article;
    NSString *adid = isEmptyString(article.adId) ? nil : [NSString stringWithFormat:@"%@", article.adId];
    NSString *logExtra = article.logExtra;
    NSString *group_id = article.groupId > 0 ? @(article.groupId).stringValue : nil;
    NSString *item_id = article.itemId > 0 ? @(article.itemId).stringValue : nil;
    int64_t aggrType = article.aggrType;
    NSString *openUrl = nil;
    if (item.originData.hasAdCell && isEmptyString(openUrl)) {
        openUrl = item.originData.adCell.app.openURL;
    }
    if (item.originData.hasAdCell && isEmptyString(openUrl)) {
        openUrl = item.originData.adCell.normal.openURL;
    }
    if (isEmptyString(openUrl)) {
        openUrl = article.openURL;
    }
    NewsGoDetailFromSource fromSource = [[self class] goDetailFromSouce:categoryID];
    NSMutableDictionary *statParams = [NSMutableDictionary dictionary];
    [statParams setValue:categoryID forKey:@"kNewsDetailViewConditionCategoryIDKey"];
    [statParams setValue:@(fromSource) forKey:kNewsGoDetailFromSourceKey];

    if (context.clickComment) {
        [statParams setValue:@(YES) forKey:@"showcomment"];
    }

    [statParams setValue:group_id forKey:@"groupid"];
    [statParams setValue:group_id forKey:@"group_id"];
    [statParams setValue:item_id forKey:@"item_id"];
    [statParams setValue:@(aggrType) forKey:@"aggr_type"];
    [statParams setValue:item.originData.logPbDic forKey:@"log_pb"];
    [statParams setValue:[article.rawAdDataString tt_JSONValue] forKey:@"raw_ad_data"];
    [statParams setValue:logExtra forKey:@"log_extra"];
    [statParams setValue:adid forKey:@"ad_id"];
    
    // articleTypeWhenPreloaded不应该为YES。如果出问题了，就用settings来控制
    BOOL articleTypeWhenPreloaded = [[[TTSettingsManager sharedManager] settingForKey:@"video_feedArticleTypeWhenPreloaded" defaultValue:@NO freeze:NO] boolValue];
    if (articleTypeWhenPreloaded) {
        if (item.originData.savedConvertedArticle && item.originData.savedConvertedArticle.detailInfoUpdated) {
            [statParams setValue:item.originData.savedConvertedArticle forKey:@"video_feed"];
        } else {
            [statParams setValue:item.originData forKey:@"video_feed"];
        }
    } else {
        [statParams setValue:item.originData forKey:@"video_feed"];
    }
    [statParams setValue:context.feedListViewController forKey:@"video_feedListViewController"];
    
    //打开详情页：优先判断openURL是否可以用外部schema打开，否则判断内部schema
    BOOL canOpenURL = [self openSchemaWithOpenUrl:openUrl article:article adid:adid logExtra:logExtra statParams:statParams];
    if (canOpenURL) {
        return canOpenURL;
    }
    if(!canOpenURL) {
        NSString *detailURL = nil;
        if (group_id) {
            detailURL = [NSString stringWithFormat:@"sslocal://detail?groupid=%@", group_id];
        }
        if (!isEmptyString(adid)) {
            detailURL = [detailURL stringByAppendingFormat:@"&ad_id=%@", adid];
            NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
            [applinkParams setValue:logExtra forKey:@"log_extra"];
            //针对不能通过sdk和openurl打开的情况
            wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", adid, nil, applinkParams);
        }

        // 如果是视频cell且正在播放，则detach视频并传入详情页
        if ([cell conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {

            NSNumber *videoType = @(article.videoDetailInfo.videoType);
            [statParams setValue:videoType forKey:@"video_type"];

            if ([[self class] canContinuePlayMovieOnView:cell withArticle:article]) {

                TTVideoShareMovie *shareMovie = [[TTVideoShareMovie alloc] init];
                if ([cell respondsToSelector:@selector(cell_movieView)] && [[cell cell_movieView] isKindOfClass:[TTVPlayVideo class]]) {
                    shareMovie.movieView = [cell cell_movieView];
                }
                TTVPlayVideo *movieView = (TTVPlayVideo *)shareMovie.movieView;

                [statParams setValue:shareMovie forKey:@"movie_shareMovie"];
                if ([cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
                    if ([item.originData couldContinueAutoPlay]) {
                        shareMovie.isAutoPlaying = YES;
                        [[TTVAutoPlayManager sharedManager] cacheAutoPlayingCell:(id<TTVAutoPlayingCell>)cell movie:movieView fromView:cell.tableView];
                        TTVAutoPlayModel *model = [cell ttv_autoPlayModel];
                        TTVPlayVideo *movieView = nil;
                        if ([shareMovie.movieView isKindOfClass:[TTVPlayVideo class]]) {
                            movieView = (TTVPlayVideo *)shareMovie.movieView;
                        }
                        if (!movieView && [shareMovie.playerControl.movieView isKindOfClass:[TTVPlayVideo class]]) {
                            movieView = (TTVPlayVideo *)shareMovie.playerControl.movieView;
                        }
                        [[TTVAutoPlayManager sharedManager] trackForClickFeedAutoPlay:model movieView:movieView];
                    }
                }
                if ([cell respondsToSelector:@selector(cell_detachMovieView)]) {
                    [cell cell_detachMovieView];
                }
            }
        }

        BOOL isFloatVideo = [self gofloat];

        if (!isFloatVideo)
        {
            if (detailURL) {
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
                return YES;
            }
        }
    }
    return NO;
}

- (void)newMovieAutoOverTrack:(TTVFeedListCell *)cellBase feedItem:(TTVFeedItem *)feedItem stop:(BOOL)stop
{
    if (![feedItem isKindOfClass:[TTVFeedItem class]]) {
        return;
    }
    if ([[NSString stringWithFormat:@"%lld",feedItem.uniqueID] isEqualToString:[TTVAutoPlayManager sharedManager].model.uniqueID]) {
        //自动播放时，禁止出小窗
        if ([cellBase conformsToProtocol:@protocol(TTVAutoPlayingCell)] && [cellBase respondsToSelector:@selector(ttv_movieView)]) {
            UITableViewCell <TTVAutoPlayingCell> *movieCell = (UITableViewCell <TTVAutoPlayingCell> *)cellBase;
            if ([[movieCell ttv_movieView] isKindOfClass:[TTVPlayVideo class]]) {
                [[TTVAutoPlayManager sharedManager] trackForFeedAutoOver:[movieCell ttv_autoPlayModel] movieView:[movieCell ttv_movieView]];
                if (stop && [[TTVAutoPlayManager sharedManager].model.uniqueID isEqualToString:[NSString stringWithFormat:@"%lld",feedItem.uniqueID]]) {
                    [[TTVAutoPlayManager sharedManager] resetForce];
                }
            }
        }
    }
}


- (void)playMovieOnDetailViewControllerWithItem:(TTVFeedListItem *)item statParams:(NSMutableDictionary *)statParams
{
    if (![item isKindOfClass:[TTVFeedListItem class]]) {
        return;
    }
    TTVFeedListCell *cell = (TTVFeedListCell *)item.cell;
    if (![cell isKindOfClass:[TTVFeedListCell class]]) {
        return;
    }
    TTVideoShareMovie *shareMovie = [[TTVideoShareMovie alloc] init];
    if ([cell respondsToSelector:@selector(cell_movieView)] && [[cell cell_movieView] isKindOfClass:[TTVPlayVideo class]]) {
        shareMovie.movieView = (TTVPlayVideo *)[cell cell_movieView];
    }
    TTVPlayVideo *movieView = (TTVPlayVideo *)shareMovie.movieView;

    [statParams setValue:shareMovie forKey:@"movie_shareMovie"];
    [self newMovieAutoOverTrack:cell feedItem:item.originData stop:NO];
    if ([cell respondsToSelector:@selector(cell_detachMovieView)]) {
        [cell cell_detachMovieView];
    }
}

+ (void)commonAdSelectionWithItem:(TTVFeedListItem *)item context:(TTVFeedCellSelectContext *)context
{
    if (![item isKindOfClass:[TTVFeedListItem class]]) {
        return;
    }
    TTVFeedListCell *cell = (TTVFeedListCell *)item.cell;
    if (![cell isKindOfClass:[TTVFeedListCell class]]) {
        return;
    }
    TTVVideoArticle *article = item.originData.article;
    TTVADInfo *adInfo = item.originData.adCell.adInfo;
    NSString *adid = isEmptyString(article.adId) ? nil : [NSString stringWithFormat:@"%@", article.adId];
    TTADEventTrackerEntity *trackerEntity = [TTADEventTrackerEntity entityWithData:item.originData];
    
    if (!isEmptyString(adid)) {
        NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:1];
        [extrData setValue:[TTTouchContext format2JSON:[item.lastTouchContext touchInfo]] forKey:@"ad_extra_data"];
        //只有下载广告需要extra(groupid)为1
        if (item.originData.adCell.hasApp)
        {
            [extrData setValue:@"1" forKey:@"ext_value"];
            [extrData setValue:@"1" forKey:@"has_v3"];
            [[self class] trackRealTime:item extraData:extrData];
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];
        }
        else
        {
            //普通广告点击click事件
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];

        }

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [userInfo setValue:article.logExtra forKey:@"log_extra"];

        if ([item.originData.adCell.adInfo.type isEqualToString:@"form"]) {
            [[SSADEventTracker sharedManager] trackEventWithEntity:trackerEntity label:@"detail_show" eventName:@"embeded_ad"];
        }
        
    }
}

+ (void)trackRealTime:(TTVFeedListItem *)feedListItem extraData:(NSDictionary *)extraData
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:feedListItem.article.adId forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:feedListItem.article.logExtra forKey:@"log_extra"];
    [params setValue:@"1" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [params addEntriesFromDictionary:[feedListItem realTimeAdExtraData:@"embeded_ad" label:@"click" extraData:extraData]];
    [TTTracker eventV3:@"realtime_click" params:params];
}

#pragma mark - video


+ (BOOL)gofloat
{
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"TTTestVideoFacebook"] boolValue]) {
        //                isFloatVideo = [self openVideoFloatWithOrderedData:orderedData videoView:(id <TTSharedViewTransitionFrom>)cellView.cell statParams:statParams detailURL:detailURL cellView:cellView];
    }
    else
    {
        if ([SSCommonLogic isVideoFloatingEnabled])
        {
            //                    isFloatVideo = [self openVideoFloatWithOrderedData:orderedData videoView:(id <TTSharedViewTransitionFrom>)cellView.cell statParams:statParams detailURL:detailURL cellView:cellView];
        }
    }
    return NO;
}

//第二期做 float
//+ (BOOL)openVideoFloatWithOrderedData:(ExploreOrderedData *)orderedData videoView:(id<TTSharedViewTransitionFrom>)videoView statParams:(NSDictionary *)statParams detailURL:(NSString *)detailURL cellView:(ExploreCellViewBase *)cellView
//{
//    Article * article = (Article *)orderedData.originalData;
//    if (![article isKindOfClass:[Article class]]) {//上头条是Card.
//        return NO;
//    }
//    UINavigationController *topMost = [SSCommonAppExtension topNavigationControllerFor: cellView];
//    UITabBarController *tabBarController = topMost.tabBarController;
//
//    BOOL isValidChannel = [orderedData.categoryID isEqualToString:@"__all__"];
//    BOOL isPannoVideo = [orderedData.article.videoDetailInfo tt_boolValueForKey:@"is_pano_video"];//全景视频
//    long long _flags = 0;
//    if (statParams[@"flags"]) {
//        _flags = [statParams[@"flags"] longLongValue];
//    }
//    BOOL isVideoSubject = ([article isVideoSubject] &&
//                           !SSIsEmptyDictionary(article.videoDetailInfo))
//    || !!(_flags & kArticleGroupFlagsDetailTypeVideoSubject);
//
//    BOOL isFloatVideo = NO;
//    BOOL isUGC = [article isVideoSourceUGCVideoOrHuoShan];
//
//    NSObject <TTSharedViewTransitionFrom> *cell = (NSObject <TTSharedViewTransitionFrom> *)videoView;
//    TTVideoFloatSingletonTransition *transitionView = [TTVideoFloatSingletonTransition sharedInstance_tt];
//    if ([cell respondsToSelector:@selector(animationFromView)]) {
//        transitionView.fromAnimatedView = [cell animationFromView];
//    }
//
//    if (article.groupFlags.integerValue != kArticleGroupFlagsDetailTypeArticleSubject &&
//        ![TTDeviceHelper isPadDevice]  &&
//        orderedData.categoryID.length > 0 && isEmptyString(orderedData.ad_id) &&
//        ![[TTVideoAutoPlayManager sharedManager] dataIsAutoPlaying:orderedData] &&
//        tabBarController.selectedIndex == TTTabbarIndexNews &&
//        isValidChannel && isVideoSubject && !isUGC && !isPannoVideo &&
//        transitionView.fromAnimatedView) {
//
//        isFloatVideo = YES;
//        [statParams setValue:[NSNumber numberWithBool:NO] forKey:@"pushAnimated"];
//        [statParams setValue:[NSNumber numberWithBool:YES] forKey:@"isFloatVideoController"];
//        [statParams setValue:[NSNumber numberWithBool:YES] forKey:@"floatTransition"];
//        [statParams setValue:[TTSharedViewTransition sharedInstance] forKey:@"transitioningDelegate"];
//
//        if ([cell respondsToSelector:@selector(animationFromImage)]) {
//            transitionView.fromAnimatedImage = [cell animationFromImage];
//            float largeWidth = [[[article largeImageDict] valueForKey:@"width"] floatValue];
//            float largeHeight = [[[article largeImageDict] valueForKey:@"height"] floatValue];
//            float rate = 0.0;
//            if (largeHeight > 0) {
//                rate = largeWidth/ largeHeight;
//            }
//
//            if (fabs(transitionView.fromAnimatedImage.size.width / transitionView.fromAnimatedImage.size.height - rate) > 0.25) {//fromAnimatedImage中的图片和浮层中的图片比例不相同,那么动画就会出现闪的情况
//                transitionView.fixedAnimatedImage = [[self class] clipImage:transitionView.fromAnimatedImage toFillSize:CGSizeMake(largeWidth, largeHeight)];
//            }
//            else
//            {
//                transitionView.fixedAnimatedImage = transitionView.fromAnimatedImage;
//            }
//        }
//        transitionView.isPresent = YES;
//        transitionView.fromViewController = topMost;
//        transitionView.fromView = cell;
//        [[TTRoute sharedRoute] openURL:[TTStringHelper URLWithURLString:detailURL] displayType:SSAppPageDisplayTypePresented baseCondition:statParams];
//
//    }
//    return isFloatVideo;
//}
//
//+ (UIImage *)clipImage:(UIImage *)image toFillSize:(CGSize)newSize
//{
//
//    size_t destWidth, destHeight;
//    if (image.size.width > image.size.height)
//    {
//        destWidth = (size_t)newSize.width;
//        destHeight = (size_t)(image.size.height * newSize.width / image.size.width);
//    }
//    else
//    {
//        destHeight = (size_t)newSize.height;
//        destWidth = (size_t)(image.size.width * newSize.height / image.size.height);
//    }
//    if (destWidth > image.size.width)
//    {
//        destWidth = (size_t)image.size.width;
//        destHeight = (size_t)(newSize.height * image.size.width / newSize.width);
//    }
//    if (destHeight > image.size.height)
//    {
//        destHeight = (size_t)image.size.height;
//        destWidth = (size_t)(newSize.width * image.size.height / newSize.height);
//    }
//
//    return [self scaleImage:image toFillSize:CGSizeMake(destWidth, destHeight)];
//}
//
//+ (UIImage *)scaleImage:(UIImage *)image toFillSize:(CGSize)newSize
//{
//    size_t destWidth = (size_t)(newSize.width * image.scale);
//    size_t destHeight = (size_t)(newSize.height * image.scale);
//    if (image.imageOrientation == UIImageOrientationLeft
//        || image.imageOrientation == UIImageOrientationLeftMirrored
//        || image.imageOrientation == UIImageOrientationRight
//        || image.imageOrientation == UIImageOrientationRightMirrored)
//    {
//        size_t temp = destWidth;
//        destWidth = destHeight;
//        destHeight = temp;
//    }
//
//    /// Create an ARGB bitmap context
//    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
//    BOOL hasAlpha = (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
//
//    CGImageAlphaInfo alphaInfo = (hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst);
//    CGContextRef bmContext = CGBitmapContextCreate(NULL, destWidth, destHeight, 8/*Bits per component*/, destWidth * 4, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault | alphaInfo);
//
//    if (!bmContext)
//        return nil;
//
//    /// Image quality
//    CGContextSetShouldAntialias(bmContext, true);
//    CGContextSetAllowsAntialiasing(bmContext, true);
//    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
//
//    /// Draw the image in the bitmap context
//
//    UIGraphicsPushContext(bmContext);
//    CGContextDrawImage(bmContext, CGRectMake(0.0f, 0.0f, destWidth, destHeight), image.CGImage);
//    UIGraphicsPopContext();
//
//    /// Create an image object from the context
//    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bmContext);
//    UIImage* scaled = [UIImage imageWithCGImage:scaledImageRef scale:image.scale orientation:image.imageOrientation];
//
//    /// Cleanup
//    CGImageRelease(scaledImageRef);
//    CGContextRelease(bmContext);
//
//    return scaled;
//}

#pragma mark -

@end
