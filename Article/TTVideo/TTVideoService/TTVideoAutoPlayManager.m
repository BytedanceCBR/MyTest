//
//  TTVideoAutoPlayManager.m
//  Article
//
//  Created by 刘廷勇 on 16/3/15.
//
//

#import "TTVideoAutoPlayManager.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData+TTAd.h"
#import "ExploreCellViewBase.h"
#import "ExploreMovieView.h"
#import "Article.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTASettingConfiguration.h"
#import "TTTrackerProxy.h"

static CGFloat const bottomHeight = 45;
static CGFloat const topHeight = 64;

@interface TTVideoAutoPlayManager ()

@property (nonatomic, getter=isCancelled) BOOL cancel;

@property (nonatomic, copy  ) NSString        *autoPlayID;
@property (nonatomic, assign) BOOL            isPaused;
@property (nonatomic, assign) NSTimeInterval  playInFeed;
@property (nonatomic, assign) NSTimeInterval  lastPlayTime;
@property (nonatomic, assign) NSTimeInterval  totalTime;
@property (nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, strong) ExploreMovieView *cachedMovie;
@property (nonatomic, weak  ) UITableView      *cacheFromView;
@property (nonatomic, weak)   id<ExploreMovieViewCellProtocol> cachedCell;

@property (nonatomic) dispatch_queue_t updateStatusQueue;

@end

@implementation TTVideoAutoPlayManager

static TTVideoAutoPlayManager *manager = nil;

+ (TTVideoAutoPlayManager *)sharedManager
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

#pragma mark -
#pragma mark Public Methods

- (void)clearAutoPlaying
{
    self.autoPlayID = nil;
    [self resetCache];
}

- (void)dataStopAutoPlay:(ExploreOrderedData *)data
{
    if ([self dataIsAutoPlaying:data]) {
        [self clearAutoPlaying];
    }
}

- (BOOL)cellIsAutoPlaying:(ExploreCellBase *)cell
{
    ExploreOrderedData *data = nil;
    if ([cell.cellData isKindOfClass:[ExploreOrderedData class]]) {
        data = cell.cellData;
        return [self dataIsAutoPlaying:data];
    }
    return NO;
}

- (BOOL)dataIsAutoPlaying:(ExploreOrderedData *)data
{
    return [self videoUniqueIDIsAutoPlaying:data.article.uniqueID];
}

- (BOOL)videoUniqueIDIsAutoPlaying:(int64_t)uniqueID
{
    if ([[@(uniqueID) stringValue] isEqualToString:self.autoPlayID]) {
        return YES;
    }
    return NO;
}

- (void)cancelTrying
{
    self.cancel = YES;
}

- (void)tryAutoPlayInTableView:(UITableView *)tableView
{
    [self cancelTrying];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateAutoPlayStatusInTableView:) object:tableView];
    [self performSelector:@selector(updateAutoPlayStatusInTableView:) withObject:tableView afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
}

- (BOOL)cachedAutoPlayingCellInView:(UITableView *)view
{
    if (self.cachedCell && self.cacheFromView == view) {
        return YES;
    }
    return NO;
}

- (void)cacheAutoPlayingCell:(ExploreCellBase *)cell movie:(ExploreMovieView *)movie fromView:(UITableView *)fromView
{
    ExploreOrderedData *data = nil;
    if ([cell.cellData isKindOfClass:[ExploreOrderedData class]]) {
        data = cell.cellData;
        if (![data couldContinueAutoPlay]) {
            return;
        }
    }
    self.cachedCell = (id<ExploreMovieViewCellProtocol>)cell;
    self.cachedMovie = movie;
    self.cacheFromView = fromView;
}

- (void)restoreCellMovieIfCould
{
    if (self.cachedCell && self.cachedMovie && !_isPaused) {
        [self.cachedCell attachMovieView:self.cachedMovie];
        self.cachedMovie.tracker.type = ExploreMovieViewTypeList;
        if (![self.cachedMovie isPlaying]) {
            [self.cachedMovie.moviePlayerController.controlView setToolBarHidden:YES];
            [self.cachedMovie userPlay];
        }
        [self sendAutoDetailBackEndTrack:self.cachedMovie.movieDelegateData movieView:self.cachedMovie];
        [self resetCache];
    }
    _isPaused = NO;
}

- (void)markTargetMoviePause:(BOOL)isPaused
{
    _isPaused = isPaused;
}

#pragma mark -
#pragma mark Private Methods

- (void)updateAutoPlayStatusInTableView:(UITableView *)tableView
{
    self.cancel = NO;
    
    NSArray *visibleCell = tableView.visibleCells;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __block ExploreCellBase *cellWaitingPlay = nil;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for (ExploreCellBase *cell in visibleCell) {
            [self.lock lock];
            BOOL shouldCancel = self.isCancelled;
            [self.lock unlock];
            if (shouldCancel) {
                cellWaitingPlay = nil;
                return;
            }
            if (![cell isKindOfClass:[ExploreCellBase class]] || ![cell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)]) {
                continue;
            }
            if (![self cellCouldAutoPlay:cell]) {
                continue;
            }
            id<ExploreMovieViewCellProtocol> videoCell = (id<ExploreMovieViewCellProtocol>)cell;
            if ([videoCell conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)] && [videoCell respondsToSelector:@selector(movieView)]) {
                ExploreMovieView *movieView = [videoCell movieView];
                if ([movieView isPlayingFinished] && [movieView isAdMovie]) {
                    continue;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                CGRect logoFrameInTableView = [tableView convertRect:[videoCell logoViewFrame] fromView:cell];
                CGRect frameInScreen = [[TTUIResponderHelper mainWindow] convertRect:logoFrameInTableView fromView:tableView];
                CGFloat topInset = frameInScreen.origin.y - topHeight;
                CGFloat bottomInset = ([TTUIResponderHelper mainWindow].frame.size.height - bottomHeight) - CGRectGetMaxY(frameInScreen);
                dispatch_async(self.updateStatusQueue, ^{
                    @onExit {
                        dispatch_semaphore_signal(semaphore);
                    };
                    CGFloat movieViewTopShowHeight = bottomInset + frameInScreen.size.height;
                    CGFloat movieTopPartInScreen = movieViewTopShowHeight / frameInScreen.size.height;
                    CGFloat movieViewbottomShowHeight = topInset - 36 + frameInScreen.size.height;
                    CGFloat moviebottomPartInScreen = movieViewbottomShowHeight / frameInScreen.size.height;
                    BOOL isVideoAdAutoPlayedWhenHalfShow = [TTDeviceHelper isPadDevice] ? NO : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_autoplayad_halfshow" defaultValue:@NO freeze:NO] boolValue];
                    
                    if ([self cellIsAutoPlaying:cell]) {
                        
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
                                [self trackForFeedAutoOver:cell.cellData movieView:[videoCell movieView]];
                                [ExploreMovieView removeAllExploreMovieView];
                            });
                        } else {
                            cellWaitingPlay = nil;
                            return;
                        }
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
                        cellWaitingPlay = cell;
                    }
                });
            });
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if (cellWaitingPlay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!ttas_isVideoScrollPlayEnable()) {
                    [self cellViewTriggerPlayVideoIfCould:cellWaitingPlay.cellView];
                }
            });
        }
    });
}

/**
 *  判断cell是否能够自动播放
 *
 *  @param cell
 *
 *  @return YES表示可以自动播放
 */
- (BOOL)cellCouldAutoPlay:(ExploreCellBase *)cell
{
    ExploreOrderedData *data = [cell cellData];
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        return [self dataCouldAutoPlay:data];;
    }
    return NO;
}

/**
 *  判断data是否能够自动播放
 *
 *  @param data
 *
 *  @return YES表示可以自动播放
 */
- (BOOL)dataCouldAutoPlay:(ExploreOrderedData *)data
{
    return [data couldAutoPlay];
}

- (void)cellViewTriggerPlayVideoIfCould:(ExploreCellViewBase *)cellView
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([[cellView cellData] isKindOfClass:[ExploreOrderedData class]]) {
        if ([cellView respondsToSelector:@selector(playButtonClicked)]) {
            ExploreOrderedData *orderedData = (ExploreOrderedData *)cellView.cellData;
            if (![self cellIsAutoPlaying:cellView.cell]) {
                [self.lock lock];
                self.autoPlayID = [@(orderedData.article.uniqueID) stringValue];
                [cellView performSelector:@selector(playButtonClicked) withObject:nil afterDelay:0];
                if ([cellView conformsToProtocol:@protocol(ExploreMovieViewCellProtocol)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ExploreMovieView *movie = [((id <ExploreMovieViewCellProtocol>)cellView) movieView];
                        movie.pauseMovieWhenEnterForground = NO;
                        [self trackForFeedAutoPlay:orderedData movieView:movie];
                    });
                }
                
                [self.lock unlock];
            }
        }
    }
#pragma clang diagnostic pop
}

- (void)resetCache
{
    self.cachedMovie = nil;
    self.cachedCell = nil;
}

#pragma mark -
#pragma mark track

- (void)trackForFeedAutoPlay:(ExploreOrderedData *)data movieView:(ExploreMovieView*)movieView
{
    wrapperTrackEventWithCustomKeys(@"video_play", @"feed_auto_play", [@(data.article.uniqueID) stringValue], nil, @{@"item_id" : data.article.itemID ?: @""});
    if (data.ad_id.longLongValue > 0) {
        [self sendADEvent:@"embeded_ad" label:@"feed_auto_play" value:data.ad_id extra:nil logExtra:data.log_extra];
        [movieView.tracker mzTrackVideoUrls:data.adPlayTrackUrls adView:movieView];
    }
}

//自动播放,每次从详情页返回,还得发over事件
- (void)sendAutoDetailBackEndTrack:(ExploreOrderedData *)data movieView:(ExploreMovieView *)movieView
{
    //普通视频不发.
    if ([data.ad_id longLongValue] <= 0) {
        return;
    }
    if (movieView) {
        NSDictionary *extra = [self commonParams:data movie:movieView];
        NSNumber *totalTime = @([movieView.tracker playPercent]);
        self.totalTime = [totalTime doubleValue];
        [extra setValue:@(self.totalTime - self.lastPlayTime) forKey:@"duration"];
        self.lastPlayTime = self.totalTime;

        wrapperTrackEventWithCustomKeys(@"video_over", [movieView.tracker dataTrackLabel], [@(data.article.uniqueID) stringValue], nil, extra);
        if (data.ad_id.longLongValue > 0) {
            [self sendADEvent:@"embeded_ad" label:@"feed_play_over" value:data.ad_id extra:extra logExtra:data.log_extra];
        }
    }
}

- (void)setDurationWithExtra:(NSMutableDictionary *)extra movieView:(ExploreMovieView *)movieView
{
    NSNumber *totalTime = [self watchedDuration:movieView];
    self.totalTime = [totalTime doubleValue];
    self.playInFeed += self.totalTime - self.lastPlayTime;
    [extra setValue:@(self.playInFeed) forKey:@"duration"];
    self.lastPlayTime = self.totalTime;
}

//列表中播放的时候,点击,进入详情页
- (void)trackForFeedAutoOver:(ExploreOrderedData *)data movieView:(ExploreMovieView *)movieView
{
    if (!movieView) {
        return;
    }
    NSMutableDictionary *extra = [self commonParams:data movie:movieView];
    //同 trackForClickFeedAutoPlay
    [self setDurationWithExtra:extra movieView:movieView];

    wrapperTrackEventWithCustomKeys(@"video_over", @"feed_auto_over", [@(data.article.uniqueID) stringValue], nil, extra);
    if (data.ad_id.longLongValue > 0) {
        [self sendADEvent:@"embeded_ad" label:@"feed_auto_over" value:data.ad_id extra:extra logExtra:data.log_extra];
        [movieView.tracker mzStopTrack];
    }
}

//列表播放结束
- (void)trackForFeedPlayOver:(ExploreOrderedData *)data movieView:(ExploreMovieView *)movieView
{
    NSMutableDictionary *extra = [self commonParams:data movie:movieView];
    [self setDurationWithExtra:extra movieView:movieView];

    wrapperTrackEventWithCustomKeys(@"video_over", @"feed_play_over", [@(data.article.uniqueID) stringValue], nil, extra);
    if (data.ad_id.longLongValue > 0) {
        [self sendADEvent:@"embeded_ad" label:@"feed_play_over" value:data.ad_id extra:extra logExtra:data.log_extra];
        [movieView.tracker mzStopTrack];
    }
}

//详情页播放结束
- (void)trackForFeedBackPlayOver:(ExploreOrderedData *)data movieView:(ExploreMovieView *)movieView
{
    NSDictionary *extra = [self commonParams:data movie:movieView];
    NSNumber *totalTime = @([movieView.tracker playPercent]);
    self.totalTime = [totalTime doubleValue];
    [extra setValue:@(self.totalTime - self.lastPlayTime) forKey:@"duration"];
    self.lastPlayTime = self.totalTime;
    wrapperTrackEventWithCustomKeys(@"video_over", @"feed_back_play_over", [@(data.article.uniqueID) stringValue], nil, extra);
    if ([data.ad_id longLongValue] > 0) {
        [self sendADEvent:@"embeded_ad" label:@"feed_back_play_over" value:data.ad_id extra:extra logExtra:data.log_extra];
    }
}

//详情页播放结束
- (void)trackForAutoDetailPlayOver:(ExploreOrderedData *)data movieView:(ExploreMovieView *)movieView
{
    NSMutableDictionary *extra = [self commonParams:data movie:movieView];
    NSNumber *totalTime = @([movieView.tracker playPercent]);
    self.totalTime = [totalTime doubleValue];
    [extra setValue:@(self.totalTime - self.lastPlayTime) forKey:@"duration"];
    self.lastPlayTime = self.totalTime;
    wrapperTrackEventWithCustomKeys(@"video_over", @"auto_detail_play_over", [@(data.article.uniqueID) stringValue], nil, extra);
}

//列表中播放的时候,点击,进入详情页
- (void)trackForClickFeedAutoPlay:(ExploreOrderedData *)data movieView:(ExploreMovieView *)movieView
{
    NSMutableDictionary *extra = [self commonParams:data movie:movieView];
    [self setDurationWithExtra:extra movieView:movieView];
    wrapperTrackEventWithCustomKeys(@"enter_detail", @"click_feed_auto_play", [@(data.article.uniqueID) stringValue], nil, extra);
    if (data.ad_id.longLongValue > 0) {
        [self sendADEvent:@"embeded_ad" label:@"click_feed_auto_play" value:data.ad_id extra:extra logExtra:data.log_extra];
    }
}

- (NSMutableDictionary *)commonParams:(ExploreOrderedData *)data movie:(ExploreMovieView *)movieView
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:data.article.itemID forKey:@"item_id"];
    [dic setValue:@([movieView.tracker playPercent]) forKey:@"percent"];
    return dic;
}

- (NSNumber *)watchedDuration:(ExploreMovieView *)movieView
{
    return @((NSInteger)([movieView.tracker watchedDuration] * 1000));
}

- (void)sendADEvent:(NSString *)event label:(NSString *)label value:(NSString *)value extra:(NSDictionary *)extra logExtra:(NSString *)logExtra
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:event forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:value forKey:@"value"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    TTInstallNetworkConnection connectionType = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(connectionType) forKey:@"nt"];
    [dict setValue:logExtra forKey:@"log_extra"];

    if (extra.count > 0) {
        [dict addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:dict];
}

#pragma mark -
#pragma mark getters and setters

- (void)setAutoPlayID:(NSString *)autoPlayID
{
    [self.lock lock];
    self.playInFeed = 0;
    self.totalTime = 0;
    self.lastPlayTime = 0;
    if (![_autoPlayID isEqualToString:autoPlayID]) {
        _autoPlayID = autoPlayID;
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

@end
