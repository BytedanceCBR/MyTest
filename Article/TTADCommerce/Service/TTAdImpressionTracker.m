//
//  TTAdImpressionTracker.m
//  Article
//
//  Created by carl on 2017/3/3.
//
//

#import "TTAdImpressionTracker.h"
#import "KVOController.h"
#import "TTVAutoPlayManager.h"

#define FLOAT_EQUAL(A, B) (fabs((A) - (B)) <= 0.001)
static int k_video_percent_max_number = 10;

typedef NS_ENUM(NSUInteger, TTTrackState) {
    TTTrackStateUnKnow,
    TTTrackStateVisble,
    TTTrackStateUnvisble,
};

@interface TTVisibleTracker ()
@property (nonatomic, strong) NSDate *beginTimestamp;
@property (nonatomic, assign) NSInteger totalDuration;
@end

@implementation TTVisibleTracker

- (instancetype)init {
    self = [super init];
    if (self) {
        self.beginTimestamp = [NSDate date];
    }
    return self;
}

- (void)startTrackForce {

}

- (void)stopTrack {
    self.totalDuration = (NSInteger)([[NSDate date] timeIntervalSinceDate:self.beginTimestamp] * 1000);
}

- (BOOL)resetTrack:(id)context {
    return NO;
}

- (NSDictionary *)endTrack {
    [self stopTrack];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setValue:@(self.totalDuration) forKey:@"duration"];
    return dic;
}

@end

@interface TTPercentVisibleTracker ()
@property (nonatomic, assign, readwrite) CGRect visibleCanvas;
@property (nonatomic, assign, readwrite) CGFloat percent;
@property (nonatomic, assign)            CGFloat length;
@property (nonatomic, strong)            NSMutableArray <NSNumber *> *timestamps;
@property (nonatomic, assign)            TTTrackState traceState;
@property (nonatomic, strong)            NSDate *beginTimestamp;
@property (nonatomic, assign)            NSInteger totalDuration; // 毫秒
@property (nonatomic, strong)            UIScrollView *scrollView;// 不要改为weak，有可能会crash哈@小刚
@end

@implementation  TTPercentVisibleTracker

- (void)dealloc {
    [self.KVOController unobserveAll];
}

- (instancetype)initWithVisible:(CGRect)visibleRect percent:(CGFloat)percent scrollView:(UIScrollView *)view {
    self = [super init];
    if (self) {
        self.traceState = TTTrackStateUnKnow;
        self.totalDuration = 0;
        self.visibleCanvas = visibleRect;
        self.percent = percent;
        self.timestamps = [NSMutableArray arrayWithCapacity:k_video_percent_max_number];
        self.length = CGRectGetHeight(visibleRect) * percent;
        self.scrollView = view;
        [self.KVOController observe:view keyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)startTrackForce
{
    self.beginTimestamp = [NSDate date];
    self.traceState = TTTrackStateVisble;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self visibleChanged:self.scrollView.bounds];
    }
}

- (void)visibleChanged:(CGRect)inSence {
    CGRect rect = CGRectIntersection(self.visibleCanvas, inSence);
    CGFloat inSenceLength = CGRectGetHeight(rect);
    if (inSenceLength >= self.length) {
        if (self.traceState != TTTrackStateVisble) {
            self.traceState = TTTrackStateVisble;
            self.beginTimestamp = [NSDate date];
        }
    } else if (inSenceLength < self.length) {
        if (self.traceState == TTTrackStateVisble) {
            self.traceState = TTTrackStateUnvisble;
            NSInteger duration = (NSInteger)([[NSDate date] timeIntervalSinceDate:self.beginTimestamp] * 1000);
            if (self.timestamps.count < k_video_percent_max_number) {
                [self.timestamps addObject:@(duration)];
            }
            self.totalDuration += duration;
        }
    }
}

- (void)stopTrack {
    if (self.traceState == TTTrackStateVisble) {
        NSInteger duration = (NSInteger)([[NSDate date] timeIntervalSinceDate:self.beginTimestamp] * 1000);
        if (self.timestamps.count < k_video_percent_max_number) {
            [self.timestamps addObject:@(duration)];
        }
        self.totalDuration += duration;
    }
    self.traceState = TTTrackStateUnKnow;
}

- (BOOL)resetTrack:(id)context {
    if (context == self.scrollView) {
        [self stopTrack];
        self.totalDuration = 0;
        self.timestamps = [NSMutableArray arrayWithCapacity:k_video_percent_max_number];
        return YES;
    }
    return NO;
}

- (NSDictionary *)endTrack {
    [self stopTrack];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    [dic setValue:@(self.totalDuration) forKey:self.identify];
    [dic setValue:self.timestamps forKey:[NSString stringWithFormat:@"%@_part",self.identify]];
    return dic;
}

- (NSString *)debugDescription {
    NSMutableString *debugDesc = [NSMutableString string];
    [debugDesc appendFormat:@"< %@ \n", self];
    [debugDesc appendFormat:@"identify = %@ \n", self.identify];
    [debugDesc appendFormat:@"target = %@>",self.scrollView];
    return debugDesc;
}

@end


@interface TTVideoPercentVisibleTracker ()

@property (nonatomic, weak) id<TTVAutoPlayingCell> cell;
@property (nonatomic, assign) float startTimestamp;

@end

@implementation TTVideoPercentVisibleTracker

- (instancetype)initWithVisible:(CGRect)visibleRect percent:(CGFloat)percent scrollView:(UIScrollView *)view movieCell:(id<TTVAutoPlayingCell>)cell {
    if (self = [super initWithVisible:visibleRect percent:percent scrollView:view]) {
        self.cell = cell;
    }
    return self;
}

- (void)startTrackForce
{
    [super startTrackForce];
    [[self.cell ttv_movieView].player refreshTotalWatchTime];
    self.startTimestamp = [self.cell ttv_movieView].player.context.totalWatchTime;
}

- (void)visibleChanged:(CGRect)inSence {
    if (!self.cell) {
        return;
    }

    CGRect rect = CGRectIntersection(self.visibleCanvas, inSence);
    CGFloat inSenceLength = CGRectGetHeight(rect);

    if (inSenceLength >= self.length) {
        if (self.traceState != TTTrackStateVisble) {
            self.traceState = TTTrackStateVisble;
            [[self.cell ttv_movieView].player refreshTotalWatchTime];
            self.startTimestamp = [self.cell ttv_movieView].player.context.totalWatchTime;
            self.beginTimestamp = [NSDate date];
        }
    } else if (inSenceLength < self.length) {
        if (self.traceState == TTTrackStateVisble) {
            self.traceState = TTTrackStateUnvisble;
            NSInteger duration;
            if ([self.cell ttv_movieView]) {
                [[self.cell ttv_movieView].player refreshTotalWatchTime];
                duration = [self.cell ttv_movieView].player.context.totalWatchTime - self.startTimestamp;
            } else {
                //进入详情页自动播放的时候movieView已经被置空，通过停留时长计算
                duration = (NSInteger)([[NSDate date] timeIntervalSinceDate:self.beginTimestamp] * 1000);
            }
            
            if (self.timestamps.count < k_video_percent_max_number) {
                [self.timestamps addObject:@(duration)];
            }
            self.totalDuration += duration;
        }
    }
}

- (void)stopTrack {
    if (self.traceState == TTTrackStateVisble) {
        NSInteger duration;
        if ([self.cell ttv_movieView]) {
            [[self.cell ttv_movieView].player refreshTotalWatchTime];
            duration = [self.cell ttv_movieView].player.context.totalWatchTime - self.startTimestamp;
        } else {
            //进入详情页自动播放的时候movieView已经被置空，通过停留时长计算
            duration = (NSInteger)([[NSDate date] timeIntervalSinceDate:self.beginTimestamp] * 1000);
        }

        if (self.timestamps.count < k_video_percent_max_number) {
            [self.timestamps addObject:@(duration)];
        }
        self.totalDuration += duration;
    }
    self.traceState = TTTrackStateUnKnow;
}

@end

@interface TTCompositeVisibleTracker ()

@property (nonatomic, strong) NSArray *leafTracks;

@end

@implementation TTCompositeVisibleTracker

+ (instancetype)defaultCompositeTracker:(CGRect)visibleRect scrollView:(UIScrollView *)view {
    TTPercentVisibleTracker *tracker_30 = [[TTPercentVisibleTracker alloc] initWithVisible:visibleRect percent:0.3 scrollView:view];
    tracker_30.identify = @"show_30";
    TTPercentVisibleTracker *tracker_50 = [[TTPercentVisibleTracker alloc] initWithVisible:visibleRect percent:0.5 scrollView:view];
    tracker_50.identify = @"show_50";
    TTPercentVisibleTracker *tracker_100 = [[TTPercentVisibleTracker alloc] initWithVisible:visibleRect percent:1.0 scrollView:view];
    tracker_100.identify = @"show_100";
    TTCompositeVisibleTracker *tracker = [[TTCompositeVisibleTracker alloc] initWithTrackers:@[tracker_30, tracker_50, tracker_100]];
    return tracker;
}

+ (instancetype)defaultVideoCompositeTracker:(CGRect)visibleRect scrollView:(UIScrollView *)view movieCell:(id<TTVAutoPlayingCell>)cell{
    TTPercentVisibleTracker *tracker_30 = [[TTPercentVisibleTracker alloc] initWithVisible:visibleRect percent:0.3 scrollView:view];
    tracker_30.identify = @"show_30";
    TTPercentVisibleTracker *tracker_50 = [[TTPercentVisibleTracker alloc] initWithVisible:visibleRect percent:0.5 scrollView:view];
    tracker_50.identify = @"show_50";
    TTPercentVisibleTracker *tracker_100 = [[TTPercentVisibleTracker alloc] initWithVisible:visibleRect percent:1.0 scrollView:view];
    tracker_100.identify = @"show_100";
    TTVideoPercentVisibleTracker *video_tracker_50 = [[TTVideoPercentVisibleTracker alloc] initWithVisible:visibleRect percent:0.5 scrollView:view movieCell:cell];
    video_tracker_50.identify = @"play_50";
    TTVideoPercentVisibleTracker *video_tracker_100 = [[TTVideoPercentVisibleTracker alloc] initWithVisible:visibleRect percent:1.0 scrollView:view movieCell:cell];
    video_tracker_100.identify = @"play_100";
    TTCompositeVisibleTracker *tracker = [[TTCompositeVisibleTracker alloc] initWithTrackers:@[tracker_30, tracker_50, tracker_100, video_tracker_50, video_tracker_100]];
    return tracker;
}

- (instancetype)initWithTrackers:(NSArray<id<TTVisibleTrackerProtocol>> *)trackers {
    self =[super init];
    if (self) {
        self.leafTracks = [trackers copy];
    }
    return self;
}

- (BOOL)resetTrack:(id)context {
    BOOL flag = NO;
    for (id<TTVisibleTrackerProtocol> tracker in self.leafTracks) {
        flag = flag | [tracker resetTrack:context];
    }
    return flag;
}

- (void)startTrackForce {
    for (id<TTVisibleTrackerProtocol> tracker in self.leafTracks) {
        [tracker startTrackForce];
    }
}

- (void)stopTrack {
    for (id<TTVisibleTrackerProtocol> tracker in self.leafTracks) {
        [tracker stopTrack];
    }
}

- (NSDictionary *)endTrack {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:self.leafTracks.count];
    for (id<TTVisibleTrackerProtocol> tracker in self.leafTracks) {
        [dic addEntriesFromDictionary:[tracker endTrack]];
    }
    return dic;
}

- (NSString *)debugDescription {
    NSMutableString *debugDesc = [NSMutableString string];
    for (id<TTVisibleTrackerProtocol> tracker in self.leafTracks) {
        [debugDesc appendString: [tracker debugDescription]];
    }
    return debugDesc;
}

@end

@interface TTAdImpressionTracker ()

@property (nonatomic, strong) NSMutableDictionary<id, id<TTVisibleTrackerProtocol>> *trackers;

@end

@implementation TTAdImpressionTracker

+ (instancetype)sharedImpressionTracker {
    static TTAdImpressionTracker *sharedTracker = nil;
    static BOOL shouldImpressionTrack;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shouldImpressionTrack = [SSCommonLogic isAdImpressionTrack];
        if (shouldImpressionTrack) {
            sharedTracker = [[TTAdImpressionTracker alloc] init];
        }
    });
    return sharedTracker;
}

- (void)track:(id)keyObj visible:(CGRect)visibleRect scrollView:(UIScrollView *)view {
    if (!keyObj || !view) {
        return;
    }
    
    id<TTVisibleTrackerProtocol> tracker = nil;
    if (self.trackers[keyObj]) {
        // lost show over
        tracker = self.trackers[keyObj];
        [tracker endTrack];
        [self.trackers removeObjectForKey:keyObj];
    }
    tracker = [TTCompositeVisibleTracker defaultCompositeTracker:visibleRect scrollView:view];
    [self track:keyObj tracker:tracker];
}

- (void)track:(id)keyObj visible:(CGRect)visibleRect scrollView:(UIScrollView *)view movieCell:(id<TTVAutoPlayingCell>)cell{
    if (!keyObj || !view) {
        return;
    }
    
    id<TTVisibleTrackerProtocol> tracker = nil;
    if (self.trackers[keyObj]) {
        // lost show over
        tracker = self.trackers[keyObj];
        [tracker endTrack];
        [self.trackers removeObjectForKey:keyObj];
    }
    tracker = [TTCompositeVisibleTracker defaultVideoCompositeTracker:visibleRect scrollView:view movieCell:cell];
    [self track:keyObj tracker:tracker];
}

- (void)track:(id)keyObj tracker:(id<TTVisibleTrackerProtocol>)tracker {
    if (!self.trackers) {
        self.trackers = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    self.trackers[keyObj] = tracker;
}

- (NSString *)endTrack:(id)keyObj {
    id<TTVisibleTrackerProtocol> tracker = self.trackers[keyObj];
    NSString *json = nil;
    if (!tracker) {
        // lost show
    } else  {
        [self.trackers removeObjectForKey:keyObj];
        NSDictionary *trackInfo = [tracker endTrack];
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:trackInfo options:0 error:&error];
        json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return json;
}

- (void)startTrackForce {
    for (id keyObj in self.trackers) {
        id<TTVisibleTrackerProtocol> tracker = self.trackers[keyObj];
        [tracker startTrackForce];
    }
}

- (void)reset:(id)context {
    NSMutableArray *restTrackers = [NSMutableArray arrayWithCapacity:4];
    for (id keyObj in self.trackers) {
        id<TTVisibleTrackerProtocol> tracker = self.trackers[keyObj];
        if ([tracker resetTrack:context]) {
            [restTrackers addObject:keyObj]; //bug
        }
    }
    [self.trackers removeObjectsForKeys:restTrackers];
}

- (NSString *)debugDescription {
    NSMutableString *debugDesc = [NSMutableString string];
    [debugDesc appendFormat:@"trackers = <%@>", self.trackers];
    return debugDesc;
}

@end
