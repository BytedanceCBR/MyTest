//
//  TTFeedCellDefaultSelectHandler.m
//  Article
//
//  Created by Chen Hong on 2017/2/10.
//
//

#import "TTFeedCellDefaultSelectHandler.h"
#import "ExploreCellViewBase.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "TTIndicatorView.h"
#import "TTRoute.h"
#import "HuoShan.h"
#import "NetworkUtilities.h"
#import "TTLayOutCellDataHelper.h"
#import "TTTrackerWrapper.h"
#import "SSWebViewController.h"
#import "TTStringHelper.h"
#import "ArticleDetailHeader.h"
#import "NewsDetailConstant.h"
#import "ExploreMovieView.h"
#import "TTVideoShareMovie.h"
#import "TTVideoAutoPlayManager.h"
#import "ArticleDetailHeader.h"
//#import "LiveRoomPlayerViewController.h"
#import "ExploreFetchListDefines.h"
//#import "TTVideoFloatSingletonTransition.h"
//#import "TTVideoTabHuoShanCellView.h"
#import "TTThemedAlertController.h"
#import "TTArticleTabBarController.h"
#import "Article+TTADComputedProperties.h"

#import "ExploreOrderedActionCell.h"
#import <TTRelevantDurationTracker.h>

#import "ExploreOrderedData+TTAd.h"
#import "SSADEventTracker.h"
#import "TTAdFeedModel.h"
#import "TTAdFullScreenVideoManager.h"
#import "TTAdImpressionTracker.h"
#import "TTAdManager.h"
#import "TTAdManagerProtocol.h"
#import "TTAppLinkManager.h"

#import "TTAdFeedModel.h"
#import "TTVFeedPlayMovie.h"
#import "TTHotNewsData.h"

#import "TTLayOutCellViewBase.h"
//#import "TTForumCellHelper.h"
//#import "Thread.h"
#import "NewsDetailLogicManager.h"
#import "TTUIResponderHelper.h"

#import <TTServiceKit/TTServiceCenter.h>
#import "TTVideoTabBaseCellPlayControl.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTVAutoPlayManager.h"
#import <TTTracker/TTTrackerProxy.h>
//#import "TTCommonwealManager.h"
#import "TTURLUtils.h"
#import "TTRelevantDurationTracker.h"

///...
#import <TTUIWidget/TTNavigationController.h>
#import "TTAdFullScreenVideoManager.h"
#import "TTTabBarProvider.h"

@implementation  TTFeedCellSelectContext

@end

@implementation TTFeedCellDefaultSelectHandler

+ (void)postSelectCellView:(ExploreCellViewBase *)cellView context:(TTFeedCellSelectContext *)context {
    ExploreOrderedData *orderedData = cellView.cellData;
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }
}

+ (void)didSelectCellView:(ExploreCellViewBase *)cellView context:(TTFeedCellSelectContext *)context {
    ExploreOrderedData *orderedData = context.orderedData;
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }
    
    if ([orderedData.originalData isKindOfClass:[Article class]]) {
        [self didSelectArticleCellView:cellView context:context];
    }// Article
    
//    else if ([orderedData.originalData isKindOfClass:[HuoShan class]]) {
//        [self didSelectHuoShanCellView:cellView context:context];
//    }// Huoshan
    
//    else if ([orderedData.originalData isKindOfClass:[Thread class]]) {
//        [self didSelectThreadCellView:cellView context:context];
//    }// Thread
    else {
    }// Other
}


+ (void)didSelectArticleCellView:(ExploreCellViewBase *)cellView context:(TTFeedCellSelectContext *)context {
    ExploreOrderedData *orderedData = context.orderedData;
    UIViewController *topController = [TTUIResponderHelper correctTopViewControllerFor: cellView];
    
    //u11
    if ([orderedData isU11Cell]) {
        NSDictionary *extraDic = [TTLayOutCellDataHelper getLogExtraDictionaryWithOrderedData:orderedData];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"cell" label:@"go_detail" value:orderedData.uniqueID source:nil extraDic:extraDic];
    }
    
    Article *article = (Article *)orderedData.originalData;
    
    NSString *categoryID = context.categoryId ?: orderedData.categoryID;
    
    // 点击'评论'进入文章统计
    if (context.clickComment) {
        NSDictionary *comentDic = article.displayComment;
        long long commentID = [[comentDic objectForKey:@"comment_id"] longLongValue];
        if (commentID != 0) {
            NSString *label = nil;
            if (!isEmptyString(categoryID) && ![categoryID isEqualToString:kTTMainCategoryID]) {
                label = [NSString stringWithFormat:@"click_%@", orderedData.categoryID];
            } else {
                label = @"click_headline";
            }
            [NewsDetailLogicManager trackEventTag:@"click_list_comment" label:label value:@(commentID) extValue:nil  groupModel:article.groupModel];
        }
    }
    
    NSDictionary *(^ad_click_extra)() = ^NSDictionary *(ExploreCellViewBase *cellView) {
        NSMutableDictionary *ad_extra_data = [NSMutableDictionary dictionaryWithCapacity:8];
        NSDictionary *adCellLayoutInfo = nil;
        if ([cellView respondsToSelector:@selector(adCellLayoutInfo)]) {
            adCellLayoutInfo = [cellView adCellLayoutInfo];
        }
        if (!adCellLayoutInfo && [cellView.cell respondsToSelector:@selector(adCellLayoutInfo)]) {// for ExploreADCell
            adCellLayoutInfo = [(id<TTAdCellLayoutInfo>)cellView.cell adCellLayoutInfo];
        }
        if (adCellLayoutInfo) {
            [ad_extra_data addEntriesFromDictionary:adCellLayoutInfo];
        }
        
        NSDictionary *touchInfo = cellView.lastTouchContext.touchInfo;
        if (touchInfo) {
            [ad_extra_data addEntriesFromDictionary:touchInfo];
        }
        return ad_extra_data;
    };
    
    if ([orderedData.adID longLongValue] != 0) {
        NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:1];
        [extrData setValue:[TTTouchContext format2JSON:ad_click_extra(cellView)] forKey:@"ad_extra_data"];
        //只有下载广告需要extra(groupid)为1
        if (orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
            [extrData setValue:@"1" forKey:@"ext_value"];
            [extrData setObject:@"1" forKey:@"has_v3"];
            [self trackRealTime:orderedData extraData:extrData];
        } else {
            if (orderedData.article.hasVideo.boolValue == YES && !isEmptyString(orderedData.adModel.apple_id)) {
                [extrData setValue:@"1" forKey:@"ext_value"];
                [extrData setObject:@"1" forKey:@"has_v3"];
                [self trackRealTime:orderedData extraData:extrData];
            }
            [extrData setValue:orderedData.uniqueID forKey:@"ext_value"];
        }
        //广告点击click事件
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click" eventName:@"embeded_ad" extra:extrData duration:0];
        
        id<TTAdFeedModel> adModel = orderedData.adModel;
        if ([adModel.type isEqualToString:@"form"]) {
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"detail_show" eventName:@"embeded_ad"];
        }
        BOOL isNormalLBSAd = ([orderedData.raw_ad hasLocationInfo] && orderedData.raw_ad.adType == ExploreActionTypeWeb);
        if ([adModel adType] == ExploreActionTypeLocationForm || [adModel adType] == ExploreActionTypeLocationAction || [ adModel adType] == ExploreActionTypeLocationcounsel || isNormalLBSAd) {
            [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"click_content" eventName:@"embeded_ad"];
        }
    } else if (orderedData.raw_ad) {
        NSMutableDictionary *extrData = [NSMutableDictionary dictionaryWithCapacity:1];
        [extrData setValue:[TTTouchContext format2JSON:ad_click_extra(cellView)] forKey:@"ad_extra_data"];
        [extrData setValue:orderedData.uniqueID forKey:@"ext_value"];
        [SSADEventTracker trackWithModel:orderedData.raw_ad tag:@"embeded_ad" label:@"click" extra:extrData];
        [SSADEventTracker sendTrackURLs:orderedData.raw_ad.click_track_url_list with:orderedData.raw_ad];
    }
    
    void (^ad_showOver)(ExploreOrderedData *) = ^(ExploreOrderedData *orderedData ) {
        NSString *ad_id = orderedData.ad_id;
        NSMutableDictionary *adExtra = [NSMutableDictionary dictionaryWithCapacity:1];
        NSString *trackInfo = [[TTAdImpressionTracker sharedImpressionTracker] endTrack:ad_id];
        [adExtra setValue:trackInfo forKey:@"ad_extra_data"];
        NSTimeInterval duration = [[SSADEventTracker sharedManager] durationForAdThisTime:ad_id];
        [[SSADEventTracker sharedManager] trackEventWithOrderedData:orderedData label:@"show_over" eventName:@"embeded_ad" extra:adExtra duration:duration];
    };
    
    if (orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        ad_showOver(orderedData);
    }
    else if ([TTAdManageInstance canvas_showCanvasView:orderedData cell:cellView.cell])
    {
        // nothing
    }
    
    else if (([article.groupFlags longLongValue] & kArticleGroupFlagsOpenUseWebViewInList) > 0 && !isEmptyString(article.articleURLString)) {
        TTAdFeedModel *rawAd = orderedData.raw_ad;
        if (!isEmptyString(rawAd.apple_id)) {
            TTAdFeedModel *rawAd = orderedData.raw_ad;
            TTAdAppModel *appModel  = [[TTAdAppModel alloc] init];
            appModel.ad_id = rawAd.ad_id;
            appModel.log_extra = rawAd.log_extra;
            appModel.apple_id = rawAd.apple_id;
            appModel.open_url = article.openURL;
            [TTAdAppDownloadManager downloadApp:appModel];
        }
        else{
            NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:2];
            NSString *ad_id = [NSString stringWithFormat:@"%@",orderedData.ad_id];
            [parameters setValue:ad_id forKey:SSViewControllerBaseConditionADIDKey];
            [parameters setValue:orderedData.log_extra forKey:@"log_extra"];
            [parameters setValue:orderedData.logPb forKey:@"log_pb"];
            ssOpenWebView([TTStringHelper URLWithURLString:article.articleURLString], nil, topController.navigationController, !!(orderedData.ad_id), parameters);
        }
    }
    else {
        NewsGoDetailFromSource fromSource = [self goDetailFromSouce:orderedData];
        NSMutableDictionary *statParams = [NSMutableDictionary dictionary];
        [statParams setValue:categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
        [statParams setValue:@(fromSource) forKey:kNewsGoDetailFromSourceKey];
        [statParams setValue:orderedData.logPb forKey:@"log_pb"];
        
        if (!isEmptyString(context.cardId)) {
            NSDictionary *cardParam = @{@"card_id":context.cardId, @"card_position":@(context.cardIndex)};
            [statParams setValue:cardParam forKey:@"stat_params"];
        }
        
        if (context.clickComment) {
            [statParams setValue:@(YES) forKey:@"showcomment"];
            
            if ([orderedData.cellLayoutStyle integerValue] == 8 || [orderedData.cellLayoutStyle integerValue] == 9) {
                if (orderedData.originalData.commentCount){
                    [statParams setValue:@(YES) forKey:@"showCommentUGC"];
                }else {
                    [statParams setValue:@(YES) forKey:@"writeCommentUGC"];
                }
                [statParams setValue:@(YES) forKey:@"clickComment"];
            }
        }
        
        if ([orderedData isU11Cell]) {
            [statParams setValue:@YES forKey:@"fromU11Cell"];
        }
        
        [statParams setValue:@(article.uniqueID) forKey:@"groupid"];
        [statParams setValue:@(article.uniqueID) forKey:@"group_id"];
        [statParams setValue:article.itemID forKey:@"item_id"];
        [statParams setValue:article.aggrType forKey:@"aggr_type"];
        [statParams setValue:orderedData forKey:@"ordered_data"];
        [statParams setValue:NSStringFromCGRect(context.picViewFrame) forKey:@"picViewFrame"];
        [statParams setValue:@(context.picViewStyle) forKey:@"picViewStyle"];
        [statParams setValue:context.targetView forKey:@"targetView"];
        
        [statParams setValue:orderedData.log_extra forKey:@"log_extra"];
        [statParams setValue:orderedData.ad_id forKey:@"ad_id"];

        
        
        // 如果是广告cell，则加入hiddenWebView
//        if (!isEmptyString(orderedData.ad_id)) {
//            // 如果预加载webview存在，将预加载webview放入字典
//            if (context.hiddenWebView) {
//                [statParams setValue:context.hiddenWebView forKey:@"hidden_web_view"];
//            }
//            if (context.transformDelegate) {
//                [statParams setValue:context.transformDelegate forKey:@"hidden_web_view_delegate"];
//            }
//        }
        
        //打开详情页：优先判断openURL是否可以用外部schema打开，否则判断内部schema
        BOOL canOpenURL = NO;
        
        NSMutableDictionary *applinkParams = [NSMutableDictionary dictionary];
        [applinkParams setValue:orderedData.log_extra forKey:@"log_extra"];
        
        //视频广告被点击不尝试吊起淘宝、京东SDK
        BOOL isVideo = orderedData.article.hasVideo.integerValue;
        if ([orderedData.ad_id longLongValue] > 0 && isVideo==NO) {
            TTAdFeedModel *rawAd = orderedData.raw_ad;
            if (!isEmptyString(rawAd.apple_id)) {
                TTAdAppModel *appModel  = [[TTAdAppModel alloc] init];
                appModel.ad_id = rawAd.ad_id;
                appModel.log_extra = rawAd.log_extra;
                appModel.apple_id = rawAd.apple_id;
                appModel.open_url = article.openURL;
                [TTAdAppDownloadManager downloadApp:appModel];
                canOpenURL = YES;
            }
            else if ([TTAppLinkManager dealWithWebURL:article.articleURLString openURL:orderedData.openURL sourceTag:@"embeded_ad" value:orderedData.ad_id extraDic:applinkParams]) {
                //针对广告并且能够通过sdk打开的情况
                canOpenURL = YES;
            }
        }
        
        if (!canOpenURL && !isEmptyString(orderedData.openURL)) {
            NSURL *url = [TTStringHelper URLWithURLString:orderedData.openURL];
            if ([[UIApplication sharedApplication] canOpenURL:url]&&!isVideo) {
                canOpenURL = YES;
                [[UIApplication sharedApplication] openURL:url];
            }
            else if ([[TTRoute sharedRoute] canOpenURL:url]) {
                
                canOpenURL = YES;
                
                if ([article isImageSubject] && ![SSCommonLogic appGalleryTileSwitchOn] && [SSCommonLogic appGallerySlideOutSwitchOn]) {
                    
                    [statParams setValue:@(0) forKey:@"animated"];
                }
                
//                //公益项目拼接时间参数
//                if([orderedData.openURL rangeOfString:@"st_time"].location != NSNotFound) {
//                    NSString *timeStr = [NSString stringWithFormat:@"%.0lf", [[TTCommonwealManager sharedInstance] todayUsingTime]];
//                    NSString *encodingTimeStr = [TTURLUtils queryItemAddingPercentEscapes:timeStr];
//                    NSString *urlStr = [NSString stringWithFormat:@"%@%@",orderedData.openURL,encodingTimeStr];
//                    url =  [TTStringHelper URLWithURLString:urlStr];
//                    [[TTCommonwealManager sharedInstance] trackerWithSource:@"feed"];
//                }
                [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(statParams)];
                //针对广告不能通过sdk打开，但是传的有内部schema的情况
                if(!isEmptyString(orderedData.ad_id)){
                    wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", orderedData.ad_id, nil, applinkParams);
                }
            }
        }
        
        if(!canOpenURL) {
            
            NSString *detailHost = @"detail";
            // 全屏视频广告详情页
            if ([orderedData.raw_ad isFullScreenVideoStyle]) {
                detailHost = @"ad_full_screen_video";
            }
            
            NSString *detailURL = [NSString stringWithFormat:@"sslocal://%@?groupid=%lld", detailHost, orderedData.article.uniqueID];
            
            if (!isEmptyString(orderedData.article.itemID)) {
                detailURL = [detailURL stringByAppendingFormat:@"&item_id=%@", orderedData.article.itemID];
            }
            
            if (!isEmptyString(orderedData.ad_id)) {
                detailURL = [detailURL stringByAppendingFormat:@"&ad_id=%@", orderedData.ad_id];
                //针对不能通过sdk和openurl打开的情况
                if (!isEmptyString(orderedData.openURL)) { //open_url存在,没有成功唤起app @muhuai
                    wrapperTrackEventWithCustomKeys(@"embeded_ad", @"open_url_h5", orderedData.ad_id, nil, applinkParams);
                }
            }
            
            // 如果是视频cell且正在播放，则detach视频并传入详情页
            if ([cellView.cell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] ||
                [cellView conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)]) {
                
                id<ExploreMovieViewCellProtocol> videoView = nil;
                
                if ([cellView conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)]) {
                    videoView = (id<ExploreMovieViewCellProtocol>)cellView;
                }
                
                if ([cellView.cell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)]) {
                    videoView = (id<ExploreMovieViewCellProtocol>)cellView.cell;
                }
                
                NSNumber *videoType = 0;
                if ([[article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
                    videoType = (NSNumber *)[article.videoDetailInfo objectForKey:@"video_type"];
                }
                
                [statParams setValue:videoType forKey:@"video_type"];

                //新播放器暂时不支持自动播放
                BOOL isAuto = [[TTVideoAutoPlayManager sharedManager] dataIsAutoPlaying:orderedData];
                if ([self canContinuePlayMovieOnView:videoView withArticle:article]) {
                    BOOL canUseNewPlayer = !isAuto;
                    if ([videoView respondsToSelector:@selector(ttv_canUseNewPlayer)]) {
                        canUseNewPlayer = [videoView ttv_canUseNewPlayer];
                    }
                    if (canUseNewPlayer) {
                        [self detachNewMovieViewWithCell:videoView cellView:cellView orderedData:orderedData statParams:statParams];
                    }else{
                        [self detachOldMovieViewWithCell:videoView cellView:cellView orderedData:orderedData statParams:statParams];
                    }
                }
            } else if ([cellView conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                
                id<TTVFeedPlayMovie> videoView = nil;
                if ([cellView conformsToProtocol:@protocol(TTVFeedPlayMovie)]) {
                    videoView = (id<TTVFeedPlayMovie>)cellView;
                }

                id<TTVAutoPlayingCell> cell = nil;
                if ([cellView.cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
                    cell = (id<TTVAutoPlayingCell>)cellView.cell;
                }

                NSNumber *videoType = 0;
                if ([[article.videoDetailInfo allKeys] containsObject:@"video_type"]) {
                    videoType = (NSNumber *)[article.videoDetailInfo objectForKey:@"video_type"];
                }
                
                [statParams setValue:videoType forKey:@"video_type"];
                
                if ([[self class] canContinuePlayNewMovieOnView:videoView withArticle:article]) {
                    
                    TTVideoShareMovie *shareMovie = [[TTVideoShareMovie alloc] init];
                    if ([videoView respondsToSelector:@selector(cell_movieView)] && [[videoView cell_movieView] isKindOfClass:[TTVPlayVideo class]]) {
                        shareMovie.movieView = [videoView cell_movieView];
                    }
                    TTVPlayVideo *movieView = (TTVPlayVideo *)shareMovie.movieView;
                    
                    [statParams setValue:shareMovie forKey:@"movie_shareMovie"];
                    if ([cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
                        if ([orderedData couldContinueAutoPlay]) {
                            shareMovie.isAutoPlaying = YES;
                            [[TTVAutoPlayManager sharedManager] cacheAutoPlayingCell:(id<TTVAutoPlayingCell>)cell movie:movieView fromView:cellView.cell.tableView];
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
                    if ([videoView respondsToSelector:@selector(cell_detachMovieView)]) {
                        [videoView cell_detachMovieView];
                    }
                }
            }
            
            BOOL isFloatVideo = NO;
//            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"TTTestVideoFacebook"] boolValue]) {
//                isFloatVideo = [self openVideoFloatWithOrderedData:orderedData videoView:(id <TTSharedViewTransitionFrom>)cellView.cell statParams:statParams detailURL:detailURL cellView:cellView];
//            }
//            else
//            {
//                if ([SSCommonLogic isVideoFloatingEnabled])
//                {
//                    isFloatVideo = [self openVideoFloatWithOrderedData:orderedData videoView:(id <TTSharedViewTransitionFrom>)cellView.cell statParams:statParams detailURL:detailURL cellView:cellView];
//                }
//            }
            if (!isFloatVideo)
            {
                //5.7详情页图集特殊
                if ([article isImageSubject] && ![SSCommonLogic appGalleryTileSwitchOn] && [SSCommonLogic appGallerySlideOutSwitchOn]) {
                    
                    [statParams setValue:@(0) forKey:@"animated"];
                }
                
                if ([orderedData isU11Cell]) {
                    NSDictionary *extraDic = [TTLayOutCellDataHelper getLogExtraDictionaryWithOrderedData:orderedData];
                    [statParams setValue: [extraDic tt_JSONRepresentation] forKey:@"gd_ext_json"];
                }

                ///...
                if ([orderedData.raw_ad isFullScreenVideoStyle]) {
                    [statParams setValue:@(0) forKey:@"animated"];
                }
                
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
                
                // 文章、图集等 启动关联时长统计
                [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
            }
        }
    }
    
    article.hasRead = [NSNumber numberWithBool:YES];
    [article save];
    
    if (!isEmptyString(orderedData.ad_id)) {
        if (orderedData.videoChannelADType == 1 ||
            orderedData.videoChannelADType == 2 ||
            orderedData.adModel.displayType == TTAdFeedCellDisplayTypeLarge_VideoChannel) {//大图广告停掉视频播放
            [ExploreMovieView removeAllExploreMovieView];
        }
    }
    
}

+ (void)trackRealTime:(ExploreOrderedData*)orderData extraData:(NSDictionary *)extraData
{
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:@"umeng" forKey:@"category"];
    [params setValue:orderData.ad_id forKey:@"value"];
    [params setValue:@"realtime_ad" forKey:@"tag"];
    [params setValue:orderData.log_extra forKey:@"log_extra"];
    [params setValue:@"2" forKey:@"ext_value"];
    [params setValue:@(connectionType) forKey:@"nt"];
    [params setValue:@"1" forKey:@"is_ad_event"];
    [params addEntriesFromDictionary:[orderData realTimeAdExtraData:@"embeded_ad" label:@"click" extraData:extraData]];
    [TTTracker eventV3:@"realtime_click" params:params];
}


+ (void)detachOldMovieViewWithCell:(id<ExploreMovieViewCellProtocol>)videoView cellView:(ExploreCellViewBase *)cellView orderedData:(ExploreOrderedData *)orderedData statParams:(NSMutableDictionary *)statParams
{
    TTVideoShareMovie *shareMovie = [[TTVideoShareMovie alloc] init];
    if ([videoView respondsToSelector:@selector(movieView)]) {
        shareMovie.movieView = [videoView movieView];
    }
    if ([shareMovie.movieView isKindOfClass:[ExploreMovieView class]]) {
        ExploreMovieView *movieView = (ExploreMovieView *)shareMovie.movieView;
        if (movieView.tracker.isAutoPlaying) {
            //正在自动播放的视频点击进入详情页，需要单独发送一次video_play（恶心的统计需求）
            [movieView.tracker sendVideoPlayTrack];
        }

        [statParams setValue:shareMovie forKey:@"movie_shareMovie"];
        [statParams setValue:[NSNumber numberWithBool:YES] forKey:@"disableNewVideoDetailViewController"]; //决定是TTVVideoDetailViewController 还是 TTVideoDetailViewController, 如果选择TTVideoDetailViewController，点击评论按钮进入详情页会出现白屏和闪退问题。

        if ([cellView.cell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)]) {
            if ([[TTVideoAutoPlayManager sharedManager] dataIsAutoPlaying:orderedData]) {
                [[TTVideoAutoPlayManager sharedManager] cacheAutoPlayingCell:(id<ExploreMovieViewCellProtocol>)cellView.cell movie:shareMovie.movieView fromView:cellView.cell.tableView];
                [[TTVideoAutoPlayManager sharedManager] trackForClickFeedAutoPlay:orderedData movieView:shareMovie.movieView];
            }
        }
        if ([videoView respondsToSelector:@selector(detachMovieView)]) {
            [videoView detachMovieView];
        }
    }
}

+ (void)detachNewMovieViewWithCell:(id<ExploreMovieViewCellProtocol>)videoView cellView:(ExploreCellViewBase *)cellView orderedData:(ExploreOrderedData *)orderedData statParams:(NSMutableDictionary *)statParams
{
    TTVideoTabBaseCellPlayControl *control = nil;
    TTVideoShareMovie *shareMovie = [[TTVideoShareMovie alloc] init];
    if ([videoView respondsToSelector:@selector(movieView)]) {
        shareMovie.movieView = [videoView movieView];
    }
    if ([videoView respondsToSelector:@selector(ttv_playerController)]) {
        control = (TTVideoTabBaseCellPlayControl *)[videoView ttv_playerController];
        shareMovie.playerControl = control;
    }
    if ([shareMovie.playerControl isKindOfClass:[TTVideoTabBaseCellPlayControl class]]) {
        if ([orderedData couldContinueAutoPlay]) {
            [control goVideoDetail];
        }
        [statParams setValue:shareMovie forKey:@"movie_shareMovie"];
        
        if ([cellView.cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
            if ([orderedData couldContinueAutoPlay]) {
                [[TTVAutoPlayManager sharedManager] cacheAutoPlayingCell:(id<TTVAutoPlayingCell>)cellView.cell movie:shareMovie.playerControl.movieView fromView:cellView.cell.tableView];
                TTVAutoPlayModel *model = [TTVAutoPlayModel modelWithOrderedData:orderedData];
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
        if ([videoView respondsToSelector:@selector(detachMovieView)]) {
            [videoView detachMovieView];
        }
    }
}


//+ (void)didSelectHuoShanCellView:(ExploreCellViewBase *)cellView context:(TTFeedCellSelectContext *)context {
//    ExploreOrderedData *orderedData = context.orderedData;
//    HuoShan * huoShanModel = (HuoShan *)orderedData.originalData;
//    NSString *categoryID = context.categoryId ?: orderedData.categoryID;
//
//    //入口需要发送统计
//    NSString *labelStr = @"";
//    if ([categoryID isEqualToString:@"__all__"]) {
//        labelStr = @"click_headline";
//    }
//    else if ([categoryID isEqualToString:@"hotsoon"]) {
//        NSNumber *tab = [context.externalRequestCondtion objectForKey:kExploreFetchListConditionListFromTabKey];
//        if (tab.integerValue == TTCategoryModelTopTypeVideo) {
//
//            labelStr = @"click_subv_hotsoon";
//        }
//        else if (tab.integerValue == TTCategoryModelTopTypeNews) {
//
//            labelStr = @"click_hotsoon";
//        }
//    }
//    else if ([categoryID isEqualToString:@"image_ppmm"]) {
//        labelStr = @"click_image_ppmm";
//    }
//
//    if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//        wrapperTrackEventWithCustomKeys(@"go_detail", labelStr, huoShanModel.liveId.stringValue, nil, @{@"room_id":huoShanModel.liveId,@"user_id":[huoShanModel.userInfo objectForKey:@"user_id"]});
//    }
//
//    //log3.0 doubleSending
//    NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:4];
//    [logv3Dic setValue:huoShanModel.liveId.stringValue forKey:@"room_id"];
//    [logv3Dic setValue:[huoShanModel.userInfo objectForKey:@"user_id"] forKey:@"user_id"];
//    [logv3Dic setValue:labelStr forKey:@"enter_from"];
//    [logv3Dic setValue:orderedData.logPb forKey:@"log_pb"];
//    [TTTrackerWrapper eventV3:@"go_detail" params:logv3Dic isDoubleSending:YES];
//
//
//    if (TTNetworkConnected()) {
//        if (TTNetworkWifiConnected() || !huoShanShowConnectionAlertCount) {
//            NSMutableDictionary *params = [NSMutableDictionary dictionary];
//            [params setValue:@(huoShanModel.uniqueID) forKey:@"id"];
//            [params setValue:labelStr forKey:@"refer"];
//            LiveRoomPlayerViewController *huoShanVC = [[LiveRoomPlayerViewController alloc] initFromPushService:params];
//            UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: cellView];
//            [topMost pushViewController:huoShanVC animated:YES];
//
//        }
//        else {
//            if (huoShanShowConnectionAlertCount) {
//                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"您当前正在使用移动网络，继续播放将消耗流量", nil) message:nil preferredType:TTThemedAlertControllerTypeAlert];
//                [alert addActionWithTitle:NSLocalizedString(@"停止播放", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
//
//                }];
//                [alert addActionWithTitle:NSLocalizedString(@"继续播放", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
//                    huoShanShowConnectionAlertCount = NO;
//                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                    [params setValue:@(huoShanModel.uniqueID) forKey:@"id"];
//                    [params setValue:labelStr forKey:@"refer"];
//                    LiveRoomPlayerViewController *huoShanVC = [[LiveRoomPlayerViewController alloc] initFromPushService:params];
//                    UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: cellView];
//                    [topMost pushViewController:huoShanVC animated:YES];
//
//
//                }];
//                [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
//
//            }
//        }
//    }
//    else {
//        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"没有网络" indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
//    }
//}

//+ (void)didSelectThreadCellView:(ExploreCellViewBase *)cellView context:(TTFeedCellSelectContext *)context {
//    ExploreOrderedData *orderedData = context.orderedData;
//    NSString *categoryID = context.categoryId ?: orderedData.categoryID;
//    NSString *schema = [(Thread *)orderedData.originalData schema];
//    if (!isEmptyString(schema)) {
//        NSDictionary *extra = nil;
////        if ([orderedData isU11Cell] || [orderedData isU13Cell]) {
////            NSDictionary *extraDic = [TTForumCellHelper getLogExtraDictionaryWithOrderedData:orderedData refer:context.refer];
////            wrapperTrackEventWithCustomKeys(@"cell", @"go_detail", [orderedData thread].threadId, categoryID, extraDic);
////            if ([extraDic objectForKey:@"recommend_reason"]) {
////                extra = @{@"recommend_reason": extraDic[@"recommend_reason"]};
////            }
////        }
//        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:schema] userInfo:TTRouteUserInfoWithDict(extra)];
//        orderedData.originalData.hasRead = @(YES);
//        [orderedData.originalData save];
//    }
//
//}

+ (NewsGoDetailFromSource)goDetailFromSouce:(ExploreOrderedData *)orderedData
{
    if (!isEmptyString(orderedData.categoryID) && [orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        return NewsGoDetailFromSourceHeadline;
    }
    else if (orderedData.listType == ExploreOrderedDataListTypeCategory) {
        return NewsGoDetailFromSourceCategory;
    }
    else if (orderedData.listType == ExploreOrderedDataListTypeFavorite) {
        return NewsGoDetailFromSourceFavorite;
    }
    else if (orderedData.listType == ExploreOrderedDataListTypeReadHistory) {
        return NewsGoDetailFromSourceReadHistory;
    }
    else if (orderedData.listType == ExploreOrderedDataListTypePushHistory) {
        return NewsGoDetailFromSourcePushHistory;
    }
    return NewsGoDetailFromSourceUnknow;
}

+ (BOOL)canContinuePlayMovieOnView:(id <ExploreMovieViewCellProtocol> )view withArticle:(Article *)article
{
    if ([article isVideoSubject] && [view respondsToSelector:@selector(ttv_playerController)]) {
        TTVideoTabBaseCellPlayControl *control = [view ttv_playerController];
        if ([control isKindOfClass:[TTVideoTabBaseCellPlayControl class]]) {
            return ([control isPause] || [control isStopped] || [control isPlaying]);
        }
        if ([view respondsToSelector:@selector(movieView)] && [view hasMovieView]) {
            ExploreMovieView *movieView = [view movieView];
            if ([movieView isKindOfClass:[ExploreMovieView class]]) {
                return ([movieView isPaused] || [movieView isPlayingFinished] || [movieView isPlaying]);
            }
        }
    }else if ([article isVideoSubject] && [view respondsToSelector:@selector(movieView)] && [view hasMovieView]) {
        ExploreMovieView *movieView = [view movieView];
        if ([movieView isKindOfClass:[ExploreMovieView class]]) {
            return ([movieView isPaused] || [movieView isPlayingFinished] || [movieView isPlaying]);
        }
    }
    return NO;
}

+ (BOOL)canContinuePlayNewMovieOnView:(id <TTVFeedPlayMovie> )view withArticle:(Article *)article
{
    if ([article isVideoSubject] && [view respondsToSelector:@selector(cell_movieView)] && [view cell_hasMovieView]) {
        return ([view cell_isPaused] || [view cell_isPlayingFinished] || [view cell_isPlaying]);
    }
    return NO;
}

#pragma mark - video
//+ (BOOL)openVideoFloatWithOrderedData:(ExploreOrderedData *)orderedData videoView:(id<TTSharedViewTransitionFrom>)videoView statParams:(NSDictionary *)statParams detailURL:(NSString *)detailURL cellView:(ExploreCellViewBase *)cellView
//{
//    Article * article = (Article *)orderedData.originalData;
//    if (![article isKindOfClass:[Article class]]) {//上头条是Card.
//        return NO;
//    }
//    UINavigationController *topMost = [TTUIResponderHelper topNavigationControllerFor: cellView];
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
//        [[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHomeTabKey] &&
//        isValidChannel && isVideoSubject && !isUGC && !isPannoVideo &&
//        transitionView.fromAnimatedView) {
//
//        isFloatVideo = YES;
//        [statParams setValue:[NSNumber numberWithBool:NO] forKey:@"animated"];
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
//        [[TTRoute sharedRoute] openURLByPresentViewController:[TTStringHelper URLWithURLString:detailURL] userInfo:TTRouteUserInfoWithDict(statParams)];
//
//    }
//    return isFloatVideo;
//}

+ (UIImage *)clipImage:(UIImage *)image toFillSize:(CGSize)newSize
{
    
    size_t destWidth, destHeight;
    if (image.size.width > image.size.height)
    {
        destWidth = (size_t)newSize.width;
        destHeight = (size_t)(image.size.height * newSize.width / image.size.width);
    }
    else
    {
        destHeight = (size_t)newSize.height;
        destWidth = (size_t)(image.size.width * newSize.height / image.size.height);
    }
    if (destWidth > image.size.width)
    {
        destWidth = (size_t)image.size.width;
        destHeight = (size_t)(newSize.height * image.size.width / newSize.width);
    }
    if (destHeight > image.size.height)
    {
        destHeight = (size_t)image.size.height;
        destWidth = (size_t)(newSize.width * image.size.height / newSize.height);
    }
    
    return [self scaleImage:image toFillSize:CGSizeMake(destWidth, destHeight)];
}

+ (UIImage *)scaleImage:(UIImage *)image toFillSize:(CGSize)newSize
{
    size_t destWidth = (size_t)(newSize.width * image.scale);
    size_t destHeight = (size_t)(newSize.height * image.scale);
    if (image.imageOrientation == UIImageOrientationLeft
        || image.imageOrientation == UIImageOrientationLeftMirrored
        || image.imageOrientation == UIImageOrientationRight
        || image.imageOrientation == UIImageOrientationRightMirrored)
    {
        size_t temp = destWidth;
        destWidth = destHeight;
        destHeight = temp;
    }
    
    /// Create an ARGB bitmap context
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = (alpha == kCGImageAlphaFirst || alpha == kCGImageAlphaLast || alpha == kCGImageAlphaPremultipliedFirst || alpha == kCGImageAlphaPremultipliedLast);
    
    CGImageAlphaInfo alphaInfo = (hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst);
    CGContextRef bmContext = CGBitmapContextCreate(NULL, destWidth, destHeight, 8/*Bits per component*/, destWidth * 4, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrderDefault | alphaInfo);
    
    if (!bmContext)
        return nil;
    
    /// Image quality
    CGContextSetShouldAntialias(bmContext, true);
    CGContextSetAllowsAntialiasing(bmContext, true);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
    
    /// Draw the image in the bitmap context
    
    UIGraphicsPushContext(bmContext);
    CGContextDrawImage(bmContext, CGRectMake(0.0f, 0.0f, destWidth, destHeight), image.CGImage);
    UIGraphicsPopContext();
    
    /// Create an image object from the context
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bmContext);
    UIImage* scaled = [UIImage imageWithCGImage:scaledImageRef scale:image.scale orientation:image.imageOrientation];
    
    /// Cleanup
    CGImageRelease(scaledImageRef);
    CGContextRelease(bmContext);
    
    return scaled;
}

#pragma mark -

@end
