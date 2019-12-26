//
//  FHIntroduceManager.m
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/12/18.
//

#import "FHIntroduceManager.h"
#import <FHIntroduceView.h>
#import "FHIntroduceModel.h"
#import <FHUserTracker.h>

#define kFHIntroduceAlreadyShow @"kFHIntroduceAlreadyShow"

@interface FHIntroduceManager ()

@property (nonatomic , strong) FHIntroduceView *view;
@property (nonatomic , strong) FHIntroduceModel *model;
@property (nonatomic , assign) BOOL isShowing;
@property (nonatomic, assign) NSTimeInterval enterTimestamp;

@end

@implementation FHIntroduceManager

+ (instancetype)sharedInstance {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isShowing = NO;
        [self generateModel];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)showIntroduceView:(UIView *)keyWindow {
    self.isShowing = YES;
    self.view = [[FHIntroduceView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) model:self.model];
    [keyWindow addSubview:_view];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self addGoDetailLog];
}

- (void)hideIntroduceView {
    self.isShowing = NO;
    [self.view removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self addStayCategoryLog];
}

- (void)generateModel {
    self.model = [[FHIntroduceModel alloc] init];
    NSMutableArray *items = [NSMutableArray array];
    FHIntroduceItemModel *model = nil;
    
    model = [[FHIntroduceItemModel alloc] init];
    model.showJumpBtn = YES;
    model.showEnterBtn = NO;
    model.lottieJsonStr = @"introduce_1";
    model.indicatorImageName = @"fh_introduce_indicator_1";
    [items addObject:model];
    
    model = [[FHIntroduceItemModel alloc] init];
    model.showJumpBtn = YES;
    model.showEnterBtn = NO;
    model.lottieJsonStr = @"introduce_2";
    model.indicatorImageName = @"fh_introduce_indicator_2";
    [items addObject:model];
    
    model = [[FHIntroduceItemModel alloc] init];
    model.showJumpBtn = NO;
    model.showEnterBtn = YES;
    model.lottieJsonStr = @"introduce_3";
    model.indicatorImageName = nil;
    [items addObject:model];
    
    self.model.items = items;
}

- (void)applicationDidEnterBackground {
    [self addStayCategoryLog];
}

- (void)applicationDidBecomeActive {
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - 记录状态，显示过就不在显示了

- (void)setAlreadyShow:(BOOL)alreadyShow {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:alreadyShow] forKey:kFHIntroduceAlreadyShow];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)alreadyShow {
    return NO;
//    return [[[NSUserDefaults standardUserDefaults] objectForKey:kFHIntroduceAlreadyShow] boolValue];
}

#pragma mark - 埋点
- (void)addGoDetailLog {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"enter_from"] = @"be_null";
    dict[@"page_type"] = @"introduction";
    TRACK_EVENT(@"go_detail", dict);
    
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)addStayCategoryLog {
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - self.enterTimestamp;
    if (duration <= 0 || duration >= 24*60*60) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"enter_from"] = @"be_null";
    dict[@"page_type"] = @"introduction";
    dict[@"stay_time"] = [NSNumber numberWithInteger:(duration * 1000)];
    TRACK_EVENT(@"stay_page", dict);
    
    self.enterTimestamp = [[NSDate date] timeIntervalSince1970];
}

@end
