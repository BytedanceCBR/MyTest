//
//  TTAppStoreStarManager.m
//  Article
//
//  Created by Zichao Xu on 2017/10/15.
//

#import "TTAppStoreStarManager.h"
#import "TTDiggScoreFeedBackView.h"
#import <StoreKit/SKStoreReviewController.h>
#import "TTInstallIDManager.h"
#import "NSDataAdditions.h"
#import "NSDictionary+TTAdditions.h"
#import "TTVersionHelper.h"
#import "NetworkUtilities.h"
#import "TTDeviceHelper.h"
#import "TTRoute.h"
#import "TTIndicatorView.h"

#import "TTVBasePlayVideo.h"
#import "ExploreMovieView.h"


NSString * const TTAppStoreStarManagerShowNotice = @"TTAppStoreStarManagerShowNotice"; //通知名称
NSString * const TTAppStoreStarManagerKey = @"TTAppStoreStarManagerKey"; //整个字典的数据
NSString * const TTAppStoreStarManagerCountKey = @"TTAppStoreStarManagerCountKey"; //系统的App评分展开次数
NSString * const TTAppStoreStarManagerLastTimeKey = @"TTAppStoreStarManagerLastTimeKey"; //上次展示时间
NSString * const TTAppStoreStarManagerTimeIntervalKey = @"TTAppStoreStarManagerTimeIntervalKey"; //展示的间隔时间
NSString * const TTAppStoreStarManagerUserValidKey = @"TTAppStoreStarManagerUserValidKey"; //是否有效用户
NSString * const TTAppStoreStarManagerGreenChannelKey = @"TTAppStoreStarManagerGreenChannelKey"; //是否走绿色通道
NSString * const TTAppStoreStarManagerAdvancedDebugKey = @"TTAppStoreStarManagerAdvancedDebugKey"; //是否走绿色通道

@interface TTAppStoreStarManager ()

@property (nonatomic,strong) NSMutableDictionary *savedDic;
@property (nonatomic,strong) TTDiggScoreFeedBackView *guideView;
@property (nonatomic,assign) BOOL isDelay;
@property (nonatomic,copy)   dispatch_block_t finishedBlock;

//统计
@property (nonatomic,copy) NSDictionary *trackerInfo;

@end

@implementation TTAppStoreStarManager

+ (instancetype)sharedInstance
{
    static TTAppStoreStarManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TTAppStoreStarManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.savedDic = [[NSMutableDictionary alloc] init];
        
        //获取之前存储的
        NSDictionary *savedDic = [self getSavedDictionary];
        if (savedDic && savedDic.allKeys.count > 0) {
            [self.savedDic addEntriesFromDictionary:savedDic];
        }
    }
    return self;
}

#pragma mark -- 条件判断和存储

/*
 * 频率条件：
 * 每个版本每人只出一次
 * 距离上次出现两周之后
 */
- (BOOL)userCanOpen
{
    //每个版本只允许弹一次
    NSString *countId = [NSString stringWithFormat:@"%@-%@",[[TTInstallIDManager sharedInstance] deviceID],[TTVersionHelper currentVersion]];
    if (!isEmptyString([self.savedDic tt_stringValueForKey:countId])) {
        return NO;
    }
    
    //系统判断小于的直接不显示
    if ([TTDeviceHelper OSVersionNumber] < 10.3) {
        return NO;
    }
    
    //默认两周之后打开下一次
    double timeInterval = [self.savedDic tt_doubleValueForKey:TTAppStoreStarManagerTimeIntervalKey];
    if (timeInterval <= 0 ) {
        timeInterval = 60 * 60 * 24 * 14;
    }
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    double lastShowTime = [self.savedDic tt_doubleValueForKey:TTAppStoreStarManagerLastTimeKey];
    BOOL reachTime = currentTime - lastShowTime > timeInterval;
    if (!reachTime) {
        return NO;
    }
    
    return YES;
}

/*
 * 用户条件：
 * 五天内累计打开App 3天或以上的用户
 * 服务端管理，AB开关控制
 */
- (BOOL)isValidUser
{
    BOOL valid = [self.savedDic tt_boolValueForKey:TTAppStoreStarManagerUserValidKey];
    BOOL greenUser = [self.savedDic tt_boolValueForKey:TTAppStoreStarManagerGreenChannelKey];
    if (greenUser) {
        return YES;
    }
    return valid;
}

/*
 * 显示光放评分器 、 增加计数一次：
 * app内好评弹窗提示一年只允许弹三次不区分版本
 * 显示评分器必须有网络，显示完成通过视图层级判定
 * 只要执行一次代码就计数加一次
 */
- (BOOL)shouldOpenOfficialStoreView
{
    //不超过三次
    NSInteger count = [self.savedDic tt_integerValueForKey:TTAppStoreStarManagerCountKey];
    if (count >= 3) {
        return NO;
    }

    //没有网络则失效
    if (!TTNetworkConnected()) {
        return NO;
    }
    
    return YES;
}

#pragma mark -- 辅助函数

/*
 * 当前没有视频在播放
 */

- (BOOL)isVideoPlaying
{
    return [TTVBasePlayVideo currentPlayingPlayVideo].player.context.playbackState == TTVVideoPlaybackStatePlaying  || [TTVBasePlayVideo currentPlayingPlayVideo].player.context.isFullScreen || [ExploreMovieView currentVideoPlaying] || [ExploreMovieView isFullScreen];
}

/*
 * 创建并显示引导弹窗
 */
- (void)showGuideDiggView
{
    if (!self.guideView) {
        self.guideView = [[TTDiggScoreFeedBackView alloc] init];
    }
    
    [self.guideView setTrackDic:self.trackerInfo];
    [self.guideView show];
}

/*
 * 刷新点赞Action
 * 跳转到AppStore
 * 显示评分视图
 */
- (void)refreshGuideViewAction:(BOOL)jumpToStore
{
    __weak typeof(self.guideView) wselfGuideView = self.guideView;
    [self.guideView refreshActionDiggBlock:^{
        
        [wselfGuideView dismissFinished:^{
            
            if (jumpToStore) {
               
                [self openAppInAppleStore];
            }
            else {
                
                [self showOfficialStarViewAndPlusOne];
            }
            
            //结束状态调用
            if (self.finishedBlock) {
                self.finishedBlock();
            }
            
        }];
        
    } downBlock:^{
        
        [wselfGuideView dismissFinished:^{
            
            TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:@{@"enter_type":@"evaluate"}];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://feedback"] userInfo:info];
            
            //结束状态调用
            if (self.finishedBlock) {
                self.finishedBlock();
            }
            
        }];
        
    } cancelBlock:^{
        
        [wselfGuideView dismissFinished:^{
            
            //结束状态调用
            if (self.finishedBlock) {
                self.finishedBlock();
            }
        }];
        
    }];
}

/*
 * 尝试评分系统
 * 延迟1秒计算层级
 * 显示成功：增加计数、配置本次信息
 */
- (void)showOfficialStarViewAndPlusOne
{
//    NSArray *beforeArray = [[UIApplication sharedApplication] windows];
    
    //系统判断
    if ([TTDeviceHelper OSVersionNumber] >= 10.3) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        [SKStoreReviewController requestReview];
#pragma clang diagnostic pop
    }
    
    //延迟1.5秒
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *afterArray = [[NSArray alloc] init];
        afterArray = [[UIApplication sharedApplication] windows];
    
        //判断是否展示了评分视图
        NSString *boardName = [NSString stringWithFormat:@"board%@",@"Window"];
        NSString *windowName = [NSString stringWithFormat:@"UI%@%@%@",@"Remote",@"Key", boardName];
        BOOL shown = NO;
        for (UIWindow *win in afterArray) {
            if ([win isKindOfClass:[NSClassFromString(windowName) class]] && win.hidden == NO) {
                shown = YES;
            }
        }
        
        //记录结果
        if (shown) {
            NSInteger count = [self.savedDic tt_integerValueForKey:TTAppStoreStarManagerCountKey] + 1;
            [self.savedDic setObject:[NSNumber numberWithInteger:count] forKey:TTAppStoreStarManagerCountKey];
            [self saveDictionary];
        }
        
    });
    
}

/*
 * 本地存储
 * 引导页面已经展示了一次
 */
- (void)guideViewHasShowOnce
{
    NSString *countId = [NSString stringWithFormat:@"%@-%@",
                         [[TTInstallIDManager sharedInstance] deviceID],
                         [TTVersionHelper currentVersion]];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *time = [NSNumber numberWithInteger:round(currentTime)];
    [self.savedDic setObject:time forKey:TTAppStoreStarManagerLastTimeKey];
    [self.savedDic setObject:@"HasShownOnce" forKey:countId];
    [self saveDictionary];
    self.isDelay = NO;
}

/*
 * 本地存储
 * 记录显示情况、用户版本情况
 */
- (void)saveDictionary
{
    NSString *str = [self.savedDic JSONRepresentation];
    [[NSUserDefaults standardUserDefaults] setValue:str forKey:TTAppStoreStarManagerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)getSavedDictionary
{
    NSString *str = [[NSUserDefaults standardUserDefaults] valueForKey:TTAppStoreStarManagerKey];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [data JSONValue];
    return dictionary;
}


#pragma mark -- public

- (BOOL)meetOpenCondition
{
    return (![self isVideoPlaying] && [self isValidUser] && [self userCanOpen]) || [self advancedDebug];
}

- (void)showView
{
    //等上面的弹窗消失，之后走弹窗统一管理
    [TTIndicatorView dismissIndicators];
    
    //延迟展示
    NSInteger time = 2;
    if (self.isDelay) {
        time--;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //首先需要命中AB测用户、达到弹窗条件
        if ([self meetOpenCondition]) {
            
            //显示点赞或者踩的弹窗
            [self showGuideDiggView];
            
            //更新点赞的响应逻辑
            [self refreshGuideViewAction:![self shouldOpenOfficialStoreView]];
            
            //记录本版本已经打开过和打开时间
            [self guideViewHasShowOnce];

        }
    });

}
- (void)showViewFromNotice:(NSNotification *)notice
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[notice userInfo]];
    if ([dic objectForKey:@"isDelay"]) {
        self.isDelay = [dic tt_boolValueForKey:@"isDelay"];
        [dic removeObjectForKey:@"isDelay"];
    }
    
    self.trackerInfo = [dic copy];
    
    [self showView];
}

- (void)dismissView
{
    [self.guideView dismissFinished:self.finishedBlock];
}

- (void)setDismissFinishedBlock:(dispatch_block_t)block
{
    self.finishedBlock = block;
}

- (void)openAppInAppleStore
{
    NSString *appId = @"id1434642658";
//    NSString *bundleString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
//    if([bundleString rangeOfString:@"article.NewsSocial"].location !=NSNotFound)
//    {
//        appId = @"id582528844"; //专业版
//    }
//    else if([bundleString rangeOfString:@"article.Explore"].location !=NSNotFound)
//    {
//        appId = @"id672151725"; //探索版
//    }
//    else {
//        appId = @"id529092160"; //普通版
//    }
        
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/%@?mt=8",appId]];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)setValidUser:(BOOL)valid
    showTimeInterval:(double)timeInterVal
      isGreenChannel:(BOOL)isGreen
{
    [self.savedDic setObject:@(round(timeInterVal)) forKey:TTAppStoreStarManagerTimeIntervalKey];
    [self.savedDic setObject:@(valid) forKey:TTAppStoreStarManagerUserValidKey];
    [self.savedDic setObject:@(isGreen) forKey:TTAppStoreStarManagerGreenChannelKey];
    [self saveDictionary];
    
}
/*
 * 高级调试打开
 */
- (BOOL)advancedDebug
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:TTAppStoreStarManagerAdvancedDebugKey];
}
- (void)setAdvancedDebug:(BOOL)on
{
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:TTAppStoreStarManagerAdvancedDebugKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
