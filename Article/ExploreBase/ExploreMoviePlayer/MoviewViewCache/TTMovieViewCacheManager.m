//
//  TTMovieViewCacheManager.m
//  Article
//
//  Created by songxiangwu on 2016/10/19.
//
//

#import "TTMovieViewCacheManager.h"
#import "ExploreMovieView.h"
#import "ExploreMovieViewTracker.h"
#import "TTModuleBridge.h"

@interface TTMovieViewCacheObject : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString *stopEvent; //list_over, detail_over

- (instancetype)initWithKey:(NSString *)key progress:(CGFloat)progress stopEvent:(NSString *)stopEvent;

@end

@implementation TTMovieViewCacheObject

- (instancetype)initWithKey:(NSString *)key progress:(CGFloat)progress stopEvent:(NSString *)stopEvent {
    self = [super init];
    if (self) {
        _key = [key copy];
        _progress = progress;
        _stopEvent = [stopEvent copy];
    }
    return self;
}

@end

static NSString *const kLastResolution = @"kLastResolution";
static NSString *const kUserSelected = @"kResolutionUserSelected"; // 用户手动选择

@interface TTMovieViewCacheManager ()

@property (nonatomic, assign) NSInteger maxCacheCount;
@property (nonatomic, strong) NSMutableArray *cacheArray;

@end

@implementation TTMovieViewCacheManager

+ (void)load
{
    
    //问答获取视频播放器
    [[TTModuleBridge sharedInstance_tt] registerAction:@"WenDaCreateMovieView" withBlock:^id(id object,NSDictionary *params) {
        
        NSString *videoId = [params tt_stringValueForKey:@"videoId"];
        CGRect frame = CGRectFromString([params tt_stringValueForKey:@"frame"]);
        ExploreMovieViewType type = (ExploreMovieViewType)[params tt_integerValueForKey:@"type"];
        NSDictionary *trackerDic = [params tt_dictionaryValueForKey:@"trackerDic"];
        NSDictionary *v3Dic = [params tt_dictionaryValueForKey:@"trackerDicV3"];
        ExploreMovieViewModel *viewModel = (ExploreMovieViewModel *)[params tt_objectForKey:@"moviewViewModel"];
        NSTimeInterval duration = [params tt_longlongValueForKey:@"duration"];
        NSDictionary *logoImageDict = [params tt_dictionaryValueForKey:@"logoImageDict"];
        NSString *videoTitle = [params tt_stringValueForKey:@"videoTitle"];
        TTVideoTitleFontStyle style = (TTVideoTitleFontStyle)[params tt_integerValueForKey:@"videoFontStyle"];
        id movieViewDelegate = [params tt_objectForKey:@"movieViewDelegate"];
        
        ExploreMovieView *movieView = [[TTMovieViewCacheManager sharedInstance] movieViewWithVideoID:videoId frame:frame type:type trackerDic:trackerDic movieViewModel:viewModel];
        movieView.hidden = NO;
        movieView.tracker.ssTrackerDic = trackerDic;
        [movieView.tracker addExtraValueFromDic:v3Dic];
        movieView.shouldShowNewFinishUI = YES;
        movieView.enableMultiResolution = YES;
        [movieView enableRotate:YES];
        movieView.stopMovieWhenFinished = YES;
        movieView.tracker.isAutoPlaying = NO;
        movieView.movieViewDelegate = movieViewDelegate;
        
        [movieView setVideoTitle:videoTitle fontSizeStyle:style showInNonFullscreenMode:YES];
        [movieView setLogoImageDict:logoImageDict];
        [movieView setVideoDuration:duration];
        return movieView;
        
    }];
}

+ (TTMovieViewCacheManager *)sharedInstance {
    static TTMovieViewCacheManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTMovieViewCacheManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxCacheCount = 2;
        _cacheArray = [[NSMutableArray alloc] init];
        _registMovieViewHash = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:kLastResolution]) {
            _lastDefinitionType = [[NSUserDefaults standardUserDefaults] integerForKey:kLastResolution];
        } else {
            _lastDefinitionType = ExploreVideoDefinitionTypeSD;
        }
        
        _userSelected = [[NSUserDefaults standardUserDefaults] boolForKey:kUserSelected];
    }
    return self;
}

- (ExploreMovieView *)movieViewWithVideoID:(NSString *)videoID frame:(CGRect)frame type:(ExploreMovieViewType)type trackerDic:(NSDictionary *)trackerDic movieViewModel:(ExploreMovieViewModel *)movieViewModel {
    ExploreMovieView *view = [[ExploreMovieView alloc] initWithFrame:frame type:type trackerDic:trackerDic movieViewModel:movieViewModel];
    view.enableMultiResolution = YES;
    view.hidden = NO;
    return view;
}

- (void)setCacheBlock:(ExploreMovieView *)movieView videoID:(NSString *)videoID
{
    void (^block)(TTMovieViewCacheObject *obj) = ^(TTMovieViewCacheObject *obj) {
        if (obj.progress > 0) {
            [movieView.tracker sendContinuePlayTrack:obj.stopEvent];
            movieView.needsSeekToTimeWhenStart = YES;
            __weak ExploreMovieView *weakView = movieView;
            movieView.playStartBlock = ^ {
                __strong ExploreMovieView *strongView = weakView;
                [strongView.moviePlayerController seekToProgress:obj.progress];
            };
        }
    };
    for (TTMovieViewCacheObject *obj in _cacheArray) {
        if ([obj.key isEqualToString:videoID]) {
            block(obj);
            [_cacheArray removeObject:obj];
            break;
        }
    }
}

- (void)cacheMovieView:(ExploreMovieView *)view forVideoID:(NSString *)videoID {
    NSTimeInterval currentPlayTime = view.moviePlayerController.currentPlaybackTime;
    NSTimeInterval duration = view.moviePlayerController.duration;
    if (currentPlayTime <= 0 || isnan(currentPlayTime) || duration <= 0 || isnan(duration)) {
        return ;
    }
    CGFloat progress = currentPlayTime * 100 / duration;
    if (progress >= 100 || view.isPlayingFinished) {
        progress = 0;
    }
    NSString *stopEvent = @"list_over";
    if (view.tracker.type == ExploreMovieViewTypeList) {
        stopEvent = @"list_over";
    } else if (view.tracker.type == ExploreMovieViewTypeDetail) {
        stopEvent = @"detail_over";
    }
    TTMovieViewCacheObject *obj = [[TTMovieViewCacheObject alloc] initWithKey:videoID progress:progress stopEvent:stopEvent];
    for (TTMovieViewCacheObject *obj in _cacheArray) {
        if ([obj.key isEqualToString:videoID]) {
            [_cacheArray removeObject:obj];
            break;
        }
    }
    [_cacheArray addObject:obj];
    if (_cacheArray.count > _maxCacheCount) {
        [_cacheArray removeObjectAtIndex:0];
    }
}

- (void)removeCacheMovieView:(ExploreMovieView *)view forVideoID:(NSString *)videoID {
    
    if (isEmptyString(videoID)) {
        
        return ;
    }
    
    [_cacheArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[TTMovieViewCacheObject class]] &&
            [((TTMovieViewCacheObject *)obj).key isEqualToString:videoID]) {
            
            [_cacheArray removeObject:obj];
            *stop = YES;
        }
    }];
}

- (BOOL)hasCachedForKey:(NSString *)videoID {
    for (TTMovieViewCacheObject *obj in _cacheArray) {
        if ([obj.key isEqualToString:videoID]) {
            return YES;
        }
    }
    return NO;
}

- (void)setLastDefinitionType:(ExploreVideoDefinitionType)lastDefinitionType
{

    _lastDefinitionType = lastDefinitionType;
    [[NSUserDefaults standardUserDefaults] setInteger:_lastDefinitionType forKey:kLastResolution];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setUserSelected:(BOOL)userSelected {
    
    _userSelected = userSelected;
    
    [[NSUserDefaults standardUserDefaults] setBool:userSelected forKey:kUserSelected];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
