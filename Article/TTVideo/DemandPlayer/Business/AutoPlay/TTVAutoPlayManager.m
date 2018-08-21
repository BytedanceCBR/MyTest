//
//  TTVAutoPlayManager.m
//  Article
//
//  Created by panxiang on 2017/7/3.
//
//

#import "TTVAutoPlayManager.h"
#import "TTUIResponderHelper.h"
#import "ExploreMovieView.h"
#import "ExploreOrderedData.h"
#import <TTTracker/TTTrackerProxy.h>
#import "TTSettingsManager.h"
#import "TTASettingConfiguration.h"
#import "TTVVideoPlayerModel.h"

@implementation TTVAutoPlayModel

+ (TTVAutoPlayModel *)modelWithOrderedData:(ExploreOrderedData *)data
{
    TTVAutoPlayModel *model = [[TTVAutoPlayModel alloc] init];
    model.uniqueID = data.uniqueID;
    model.adID = [NSString stringWithFormat:@"%@",data.adID];
    model.logExtra = data.logExtra;
    model.categoryID = data.categoryID;
    model.groupID = data.article.groupModel.groupID;
    return model;
}

+ (TTVAutoPlayModel *)modelWithArticle:(id <TTVArticleProtocol>)article category:(NSString *)categoryID
{
    TTVAutoPlayModel *model = [[TTVAutoPlayModel alloc] init];
    model.uniqueID = [NSString stringWithFormat:@"%lld",article.uniqueID];
    model.adID = [NSString stringWithFormat:@"%@", isEmptyString(article.adModel.ad_id) ? article.adIDStr: article.adModel.ad_id];
    model.logExtra = isEmptyString(article.adModel.log_extra) ? article.logExtra : article.adModel.log_extra;
    model.categoryID = categoryID;
    model.groupID = article.groupModel.groupID;
    return model;
}
@end

static CGFloat const bottomHeight = 45;
static CGFloat const topHeight = 64;

@interface TTVAutoPlayManager ()<TTVDemandPlayerDelegate>

@property (nonatomic, getter=isCancelled) BOOL cancel;

@property (nonatomic, assign) BOOL            isPaused;
@property (nonatomic, assign) NSTimeInterval  playInFeed;
@property (nonatomic, assign) NSTimeInterval  lastPlayTime;
@property (nonatomic, assign) NSTimeInterval  totalTime;
@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, weak) TTVPlayVideo        *cachedMovie;
//用来记录自动播放的player，用来统计事件
@property (nonatomic, weak) TTVPlayVideo        *autoPlayMovie;
@property (nonatomic, strong) TTVAutoPlayModel  *cachedPlayModel;

@property (nonatomic, weak  ) UITableView       *cacheFromView;
//@property (nonatomic, weak)   UITableViewCell <TTVAutoPlayingCell> *cachedCell;

@property (nonatomic) dispatch_queue_t updateStatusQueue;

@end

@implementation TTVAutoPlayManager

static TTVAutoPlayManager *manager = nil;

+ (TTVAutoPlayManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _updateStatusQueue = dispatch_queue_create("com.bytedance.videoAutoPlayUpdateStatusQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if (state == TTVVideoPlaybackStateFinished) {
        TTVDemandPlayerContext *context = self.cachedMovie.player.context;
        
        if (!context) {
        //由于从详情页回来继续播放后将cachedMovie置空了，这里是用autoPlayMovie的
            context = self.autoPlayMovie.player.context;
        }
        
        if (!context.inIndetail) {
            if (context.hasEnterDetail) {
                [self trackForFeedBackPlayOver:self.model movieView:self.autoPlayMovie];
            } else {
                [self trackForFeedPlayOver:self.model movieView:self.autoPlayMovie];
            }
        } else {
            [self trackForAutoDetailPlayOver:self.model movieView:self.cachedMovie];
        }
        
        if (self.autoPlayMovie.playerModel.isLoopPlay) {
            //循环播放时将辅助字段都清空
            self.playInFeed = 0;
            self.lastPlayTime = 0;
        }
//        [self reset];
    }
}

- (void)playerLoadingState:(TTVPlayerLoadState)state
{
    
}

- (void)playerOrientationState:(BOOL)isFullScreen
{
    
}

- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action
{
    
}
#pragma mark -
#pragma mark Public Methods


- (void)setCachedMovie:(TTVPlayVideo *)cachedMovie
{
    if (_cachedMovie != cachedMovie) {
        _cachedMovie = cachedMovie;
        [_cachedMovie.player registerDelegate:self];
    }
}

- (void)setAutoPlayMovie:(TTVPlayVideo *)autoPlayMovie
{
    //当没有进入详情页时，没有注册播放器回调无法统计自动播放埋点
    if (_autoPlayMovie != autoPlayMovie) {
        _autoPlayMovie = autoPlayMovie;
        if (!_cachedMovie) {
            [_autoPlayMovie.player registerDelegate:self];
        }
    }
}

- (void)resetForce
{
    [_cachedMovie.player unregisterDelegate:self];
    [_autoPlayMovie.player unregisterDelegate:self];
    self.model = nil;
    self.autoPlayMovie = nil;
    [self resetCache];
}

- (void)cancelTrying
{
    self.cancel = YES;
}

- (void)tryAutoPlayInTableView:(UITableView *)tableView
{
    [self cancelTrying];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ttv_updateAutoPlayStatusInTableView:) object:tableView];
    [self performSelector:@selector(ttv_updateAutoPlayStatusInTableView:) withObject:tableView afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
}

- (void)continuePlayCachedMovie
{
    if (self.cachedPlayModel && self.cachedMovie) {
        UITableViewCell <TTVAutoPlayingCell> *cacheCell = nil;
        for (UITableViewCell <TTVAutoPlayingCell> *cell in [self.cacheFromView visibleCells]) {
            if ([cell respondsToSelector:@selector(ttv_autoPlayModel)]) {
                if ([self.cachedPlayModel.uniqueID isEqualToString:[cell ttv_autoPlayModel].uniqueID]) {
                    cacheCell = cell;
                }
            }
        }

        [cacheCell ttv_autoPlayingAttachMovieView:self.cachedMovie];

        [self sendAutoDetailBackEndTrack:self.cachedPlayModel movieView:self.cachedMovie];
        [self resetCache];
    }
}

- (BOOL)cachedAutoPlayingCellInView:(UITableView *)view
{
    if (self.cachedPlayModel && self.cacheFromView == view) {
        return YES;
    }
    return NO;
}

- (void)cacheAutoPlayingCell:(UITableViewCell <TTVAutoPlayingCell> *)cell movie:(TTVPlayVideo *)movie fromView:(UITableView *)fromView
{
    if ([cell respondsToSelector:@selector(ttv_autoPlayModel)]) {
        self.cachedPlayModel = [cell ttv_autoPlayModel];
    }
    self.cachedMovie = movie;
    self.cacheFromView = fromView;
}

- (void)resetCache
{
    self.cachedMovie = nil;
    self.cachedPlayModel = nil;
}


#pragma mark -
#pragma mark Private Methods

- (void)ttv_updateAutoPlayStatusInTableView:(UITableView *)tableView
{
    self.cancel = NO;
    
    NSArray *visibleCell = tableView.visibleCells;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __block UITableViewCell <TTVAutoPlayingCell> *cellWaitingPlay = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block BOOL hasVideoPlaying = NO;
        for (UITableViewCell <TTVAutoPlayingCell> *cell in visibleCell) {
            [self.lock lock];
            BOOL shouldCancel = self.isCancelled;
            [self.lock unlock];
            if (shouldCancel) {
                cellWaitingPlay = nil;
                return;
            }
            if (![cell conformsToProtocol:@protocol(TTVAutoPlayingCell)] || ![cell respondsToSelector:@selector(ttv_cellCouldAutoPlaying)] || ![cell respondsToSelector:@selector(ttv_movieView)] || ![cell respondsToSelector:@selector(ttv_autoPlayModel)] || ![cell respondsToSelector:@selector(ttv_logoViewFrame)]) {
                continue;
            }
            if (![cell ttv_cellCouldAutoPlaying]) {
                continue;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect logoFrameInTableView = [tableView convertRect:[cell ttv_logoViewFrame] fromView:cell];
                CGRect frameInScreen = [[TTUIResponderHelper mainWindow] convertRect:logoFrameInTableView fromView:tableView];
                
                CGFloat topInset = frameInScreen.origin.y - topHeight;
                CGFloat bottomInset = ([TTUIResponderHelper mainWindow].frame.size.height - bottomHeight) - CGRectGetMaxY(frameInScreen);
                TTVPlayVideo *currentPlayVideo = [TTVPlayVideo currentPlayingPlayVideo];
                TTVPlayVideo *movieView = nil;
                if ([cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
                    movieView = [cell ttv_movieView];
                }
                dispatch_async(self.updateStatusQueue, ^{
                    @onExit {
                        dispatch_semaphore_signal(semaphore);
                    };
                    CGFloat movieViewTopShowHeight = bottomInset + frameInScreen.size.height;
                    CGFloat movieTopPartInScreen = movieViewTopShowHeight / frameInScreen.size.height;
                    CGFloat movieViewbottomShowHeight = topInset - 36 + frameInScreen.size.height;
                    CGFloat moviebottomPartInScreen = movieViewbottomShowHeight / frameInScreen.size.height;
                    BOOL isVideoAdAutoPlayedWhenHalfShow = [TTDeviceHelper isPadDevice] ? NO : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_autoplayad_halfshow" defaultValue:@NO freeze:NO] boolValue];
                    TTVPlayVideo *movieView = nil;
                    if ([cell conformsToProtocol:@protocol(TTVAutoPlayingCell)]) {
                        movieView = [cell ttv_movieView];
                    }
                    if ([self ttv_cellIsAutoPlaying:cell]) {
                        
                        BOOL isLeavingScreen = NO;
                        
                        CGFloat topPartOutScreen = topInset / frameInScreen.size.height;
                        CGFloat bottomPartOutScreen = bottomInset / frameInScreen.size.height;
                        
                        if (-topPartOutScreen > 0.5 || -bottomPartOutScreen > 0.5) {
                            isLeavingScreen = YES;
                        }
                        
                        if (isVideoAdAutoPlayedWhenHalfShow) {
                            if (movieTopPartInScreen < 0.5 && movieViewTopShowHeight > 0) {
                                isLeavingScreen = YES;
                            }else if (movieViewbottomShowHeight > 0 && moviebottomPartInScreen < 0.5) {
                                isLeavingScreen = YES;
                            }
                        }
                        
                        if (isLeavingScreen) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (movieView) {
                                    [self trackForFeedAutoOver:[cell ttv_autoPlayModel] movieView:movieView];
                                }
                                [ExploreMovieView removeAllExploreMovieView];
                            });
                        } else {
                            cellWaitingPlay = nil;
                            return;
                        }
                    }
                    
                    if (movieView.player.context.playbackState == TTVVideoPlaybackStateFinished ||
                        movieView.player.context.playbackState == TTVVideoPlaybackStateBreak ||
                        movieView.playerModel.adID.length > 0) {
                        return;
                    }
                    BOOL isFullInScreen = topInset > 0 && bottomInset > 0;
                    if (isVideoAdAutoPlayedWhenHalfShow) {
                        if (movieTopPartInScreen > 0.5 && topInset > 0) {
                            isFullInScreen = YES;
                        }else if (bottomInset > 0 && moviebottomPartInScreen > 0.5) {
                            isFullInScreen = YES;
                        }
                    }
                    if (isFullInScreen) {
                        //如果有正在播放的视频就不再触发自动播放
                        if (!currentPlayVideo || (currentPlayVideo && currentPlayVideo.player.context.playbackState != TTVVideoPlaybackStatePlaying)) {
                            cellWaitingPlay = cell;
                        }
                    }
                    if (movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
                        hasVideoPlaying = YES;
                    }
                });
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if (cellWaitingPlay && !hasVideoPlaying) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!ttas_isVideoScrollPlayEnable()) {
                    [self ttv_cellTriggerPlayVideoIfCould:cellWaitingPlay];
                }
            });
        }
    });
}

- (BOOL)IsCurrentAutoPlayingWithUniqueId:(NSString *)uniqueID
{
    return self.model && [self.model.uniqueID isEqualToString:uniqueID];
}

- (BOOL)ttv_cellIsAutoPlaying:(UITableViewCell <TTVAutoPlayingCell> *)cell
{
    return self.model && [[cell ttv_autoPlayModel].uniqueID isEqualToString:self.model.uniqueID];
}

- (void)ttv_cellTriggerPlayVideoIfCould:(UITableViewCell <TTVAutoPlayingCell> *)cell
{
    if (![self ttv_cellIsAutoPlaying:cell]) {
        [self.lock lock];
        TTVAutoPlayModel *model = [cell ttv_autoPlayModel];
        [cell ttv_autoPlayVideo];
        self.autoPlayMovie = [cell ttv_movieView];
        self.model = model;
        [self ttv_trackForFeedAutoPlay:model];
        [self.lock unlock];
    }
}

- (void)ttv_trackForFeedAutoPlay:(TTVAutoPlayModel *)data
{
    wrapperTrackEventWithCustomKeys(@"video_play", @"feed_auto_play", data.uniqueID, nil, @{@"item_id" : data.itemID ?: @""});
    if (data.adID.length > 0) {
        [self ttv_sendADEvent:@"embeded_ad" label:@"feed_auto_play" value:data.adID extra:nil logExtra:data.logExtra extValue:data.groupID];
    }
}

- (void)ttv_setDurationWithExtra:(NSMutableDictionary *)extra movieView:(TTVPlayVideo *)movieView
{
    NSNumber *totalTime = [self ttv_watchedDuration:movieView];
    self.totalTime = [totalTime doubleValue];
    self.playInFeed += self.totalTime - self.lastPlayTime;
    [extra setValue:@(self.playInFeed) forKey:@"duration"];
    self.lastPlayTime = self.totalTime;
}

- (NSMutableDictionary *)ttv_commonParams:(TTVAutoPlayModel *)data movie:(TTVPlayVideo *)movieView
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:data.itemID forKey:@"item_id"];
    [dic setValue:@([movieView.player.context playPercent]) forKey:@"percent"];
    return dic;
}

- (NSNumber *)ttv_watchedDuration:(TTVPlayVideo *)movieView
{
    return @((NSInteger)([movieView.player.context playPercent] * movieView.player.context.duration * 10));
}

- (void)ttv_sendADEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extra:(NSDictionary *)extra logExtra:(NSString *)logExtra extValue:(NSString *)extValue
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:value forKey:@"value"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    [dict setValue:extValue forKey:@"ext_value"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];

    if (logExtra) {
        [dict setValue:logExtra forKey:@"log_extra"];
    } else {
        [dict setValue:@"" forKey:@"log_extra"];
    }

    if ([[extra allKeys] count] > 0) {
        [dict addEntriesFromDictionary:extra];
    }

    NSLog(@"%@",dict);
    [TTTrackerWrapper eventData:dict];
}

#pragma mark -
#pragma mark getters and setters

- (void)setModel:(TTVAutoPlayModel *)model
{
    [self.lock lock];
    self.totalTime = 0;
    self.lastPlayTime = 0;
    self.playInFeed = 0;
    if (![_model.uniqueID isEqualToString:model.uniqueID]) {
        _model = model;
    }
    [self.lock unlock];
}

- (void)setCancel:(BOOL)cancel
{
    [self.lock lock];
    if (_cancel != cancel) {
        _cancel = cancel;
    }
    [self.lock unlock];
}

- (NSRecursiveLock *)lock
{
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    return _lock;
}

#pragma mark 统计

/**
 自动播放,每次从详情页返回,还得发over事件
 */
- (void)sendAutoDetailBackEndTrack:(TTVAutoPlayModel *)data movieView:(TTVPlayVideo *)movieView
{
    //普通视频不发.
    if ([data.adID length] <= 0) {
        return;
    }
    if (movieView) {
        NSDictionary *extra = [self ttv_commonParams:data movie:movieView];
        //playPercent是整数应该还需／100  =>  10 = 1000 ／ 100
        NSNumber *totalTime = @([movieView.player.context playPercent] * movieView.player.context.duration * 10);
        self.totalTime = [totalTime doubleValue];
        [extra setValue:@(MAX(self.totalTime - self.lastPlayTime, 0)) forKey:@"duration"];
        self.lastPlayTime = self.totalTime;
        
        wrapperTrackEventWithCustomKeys(@"video_over", movieView.playerModel.trackLabel, data.uniqueID, nil, extra);
        if (data.adID.length > 0) {
            [self ttv_sendADEvent:@"embeded_ad" label:@"feed_play_over" value:data.adID extra:extra logExtra:data.logExtra extValue:data.groupID];
        }
    }
}


/**
 自动播放的视频 feed -> 播放结束
 */

- (void)trackForFeedAutoOver:(TTVAutoPlayModel *)data movieView:(TTVPlayVideo *)movieView
{
    if (!movieView) {
        return;
    }
    if (movieView.player.context.playbackState == TTVVideoPlaybackStateFinished) {
        //中断的时候的打点
        return;
    }
    NSMutableDictionary *extra = [self ttv_commonParams:data movie:movieView];
    //同 trackForClickFeedAutoPlay
    [self ttv_setDurationWithExtra:extra movieView:movieView];
    
    wrapperTrackEventWithCustomKeys(@"video_over", @"feed_auto_over", data.uniqueID, nil, extra);
}

//列表播放结束
- (void)trackForFeedPlayOver:(TTVAutoPlayModel *)data movieView:(TTVPlayVideo *)movieView
{
    NSMutableDictionary *extra = [self ttv_commonParams:data movie:movieView];
    [self ttv_setDurationWithExtra:extra movieView:movieView];
    
    wrapperTrackEventWithCustomKeys(@"video_over", @"feed_play_over", data.uniqueID, nil, extra);
    if (data.adID.longLongValue > 0) {
        [self ttv_sendADEvent:@"embeded_ad" label:@"feed_play_over" value:data.adID extra:extra logExtra:data.logExtra extValue:data.groupID];
    }
}

/**
 自动播放的视频 feed -> detail -> feed -> 播放结束
 */
- (void)trackForFeedBackPlayOver:(TTVAutoPlayModel *)data movieView:(TTVPlayVideo *)movieView
{
    NSDictionary *extra = [self ttv_commonParams:data movie:movieView];
    NSNumber *totalTime = [self ttv_watchedDuration: movieView];
    self.totalTime = [totalTime doubleValue];
    [extra setValue:@(self.totalTime - self.lastPlayTime) forKey:@"duration"];
    self.lastPlayTime = self.totalTime;
    wrapperTrackEventWithCustomKeys(@"video_over", @"feed_back_play_over", data.uniqueID, nil, extra);
    if (data.adID.longLongValue > 0) {
        [self ttv_sendADEvent:@"embeded_ad" label:@"feed_back_play_over" value:data.adID extra:extra logExtra:data.logExtra extValue:data.groupID];
    }
}

/**
 自动播放的视频 feed -> detail -> 播放结束
 */
- (void)trackForAutoDetailPlayOver:(TTVAutoPlayModel *)data movieView:(TTVPlayVideo *)movieView
{
    NSMutableDictionary *extra = [self ttv_commonParams:data movie:movieView];
    NSNumber *totalTime = @([movieView.player.context totalWatchTime]);
    self.totalTime = [totalTime doubleValue];
    [extra setValue:@(self.totalTime - self.lastPlayTime) forKey:@"duration"];
    self.lastPlayTime = self.totalTime;
    wrapperTrackEventWithCustomKeys(@"video_over", @"auto_detail_play_over", data.uniqueID, nil, extra);
    if (data.adID.longLongValue > 0) {
        [self ttv_sendADEvent:@"detail_ad" label:@"detail_play_over" value:data.adID extra:extra logExtra:data.logExtra extValue:data.groupID];
    }
}

/**
 列表中播放的时候,点击,进入详情页
 自动播放的视频 feed -> detail
 */
- (void)trackForClickFeedAutoPlay:(TTVAutoPlayModel *)data movieView:(TTVPlayVideo *)movieView
{
    NSMutableDictionary *extra = [self ttv_commonParams:data movie:movieView];
    [self ttv_setDurationWithExtra:extra movieView:movieView];
    wrapperTrackEventWithCustomKeys(@"enter_detail", @"click_feed_auto_play", data.uniqueID, nil, extra);
    if (data.adID.longLongValue > 0) {
        [self ttv_sendADEvent:@"embeded_ad" label:@"click_feed_auto_play" value:data.adID extra:extra logExtra:data.logExtra extValue:data.groupID];
    }
}

@end
