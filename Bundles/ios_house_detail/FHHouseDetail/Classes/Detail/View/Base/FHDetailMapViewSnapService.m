//
// Created by zhulijun on 2019-12-02.
//

#import "FHDetailMapViewSnapService.h"
#import "MAMapView.h"
#import "FHCommonDefines.h"
#import "MASConstraintMaker.h"
#import "MAAnnotation.h"
#import "MAMapKit.h"
#import "TTBaseMacro.h"

@interface FHDetailMapSnapTask ()
@property(nonatomic, copy) FHDetailMapSnapTaskBlk block;
@property(nonatomic, weak) FHDetailMapViewSnapService *holder;
@property(nonatomic, assign) NSUInteger tryCount;
@end

@implementation FHDetailMapSnapTask
@end

@interface FHDetailMapViewSnapService ()
@property(nonatomic, strong) MAMapView *mapView;
@property(nonatomic, strong) NSMutableArray<FHDetailMapSnapTask *> *reverseQueue;
@end

@implementation FHDetailMapViewSnapService

+ (instancetype)sharedInstance {
    static FHDetailMapViewSnapService *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[FHDetailMapViewSnapService alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.reverseQueue = [NSMutableArray arrayWithCapacity:5];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    self.mapView.runLoopMode = NSRunLoopCommonModes;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomLevel = 14;
    self.mapView.showsUserLocation = NO;
    self.mapView.hidden = YES;

    //设置地图style
    NSString *stylePath = [[NSBundle mainBundle] pathForResource:@"gaode_house_detail_style.data" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:stylePath];
    NSString *extraPath = [[NSBundle mainBundle] pathForResource:@"gaode_house_detail_style_extra.data" ofType:nil];
    NSData *extraData = [NSData dataWithContentsOfFile:extraPath];
    MAMapCustomStyleOptions *options = [MAMapCustomStyleOptions new];
    options.styleData = data;
    options.styleExtraData = extraData;
    [_mapView setCustomMapStyleOptions:options];
    [_mapView setCustomMapStyleEnabled:YES];

    [[[UIApplication sharedApplication] keyWindow] insertSubview:self.mapView atIndex:0];
}


- (FHDetailMapSnapTask *)takeSnapWith:(CLLocationCoordinate2D)center frame:(CGRect)frame targetRect:(CGRect)targetRect annotations:(NSArray<id <MAAnnotation>> *)annotations delegate:(id <MAMapViewDelegate>)delegate block:(FHDetailMapSnapTaskBlk)block {
    FHDetailMapSnapTask *task = [self takeSnapWith:center frame:frame targetRect:targetRect annotations:annotations maxTryCount:3 delegate:delegate block:block];
    return task;
}

- (FHDetailMapSnapTask *)takeSnapWith:(CLLocationCoordinate2D)center frame:(CGRect)frame targetRect:(CGRect)targetRect annotations:(NSArray<id <MAAnnotation>> *)annotations maxTryCount:(NSUInteger)maxTryCount delegate:(id <MAMapViewDelegate>)delegate block:(FHDetailMapSnapTaskBlk)block {
    FHDetailMapSnapTask *task = [[FHDetailMapSnapTask alloc] init];
    task.frame = frame;
    task.centerPoint = center;
    task.annotations = annotations;
    task.delegate = delegate;
    task.block = block;
    task.maxTryCount = maxTryCount;
    task.targetRect = targetRect;
    [self takeSnapWithTask:task];
    return task;
}

- (void)takeSnapWithTask:(FHDetailMapSnapTask *)task {
    NSLog(@"zlj enqueue task :%@", task);
    if (self.reverseQueue.count > 0) {
        [self.reverseQueue addObject:task];
        return;
    }
    [self.reverseQueue addObject:task];
    [self flushSnapTasks];
}

- (void)flushSnapTasks {
    WeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        StrongSelf;
        if (wself.reverseQueue.count <= 0) {
            return;
        }
        FHDetailMapSnapTask *task = wself.reverseQueue.lastObject;
        [wself.reverseQueue removeLastObject];
        //任务不存在，或者已取消，进行下一个
        if (!task) {
            [wself flushSnapTasks];
            return;
        }

        wself.mapView.frame = task.frame;
        wself.mapView.centerCoordinate = task.centerPoint;
        wself.mapView.delegate = task.delegate;
        [wself.mapView removeAnnotations:wself.mapView.annotations];
        [wself.mapView addAnnotations:task.annotations];
        [wself.mapView takeSnapshotInRect:task.targetRect withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
            task.tryCount += 1;
            if (state == 1) {
                if (task.block) {
                    task.block(task, resultImage, YES);
                }
            } else {
                //加入重新调度
                if (task.tryCount < task.maxTryCount) {
                    [wself.reverseQueue addObject:task];
                }
                if (task.block) {
                    task.block(task, nil, NO);
                }
            }
            [wself flushSnapTasks];
        }];

    });
}

@end
