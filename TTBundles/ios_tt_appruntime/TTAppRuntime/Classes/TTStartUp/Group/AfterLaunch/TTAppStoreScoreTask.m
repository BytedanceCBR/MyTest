//
//  TTAppStoreScoreTask.m
//  TTAppRuntime
//
//  Created by 张静 on 2019/10/28.
//

#import "TTAppStoreScoreTask.h"
#import "TTLaunchDefine.h"
#import <TTAppStoreStarManager/TTAppStoreStarManager.h>
#import <FHCHousePush/TTPushAlertManager.h>
#import <TTRoute/TTRoute.h>
#import <FHHouseBase/FHAppStoreCustomAlertView.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <FHHouseBase/FHCommonDefines.h>

DEC_TASK("TTAppStoreScoreTask",FHTaskTypeService,TASK_PRIORITY_HIGH);

@interface TTAppStoreScoreTask () <TTAppStoreStarManagerDelegate>

@end

@implementation TTAppStoreScoreTask

- (NSString *)taskIdentifier {
    return @"AppScore";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];

    //不用启动时初始化，确保调用设置好AppStoreAppID 以及delegate
    NSString *appId = @"id1434642658";

    [TTAppStoreStarManager sharedInstance].delegate = self;
    [TTAppStoreStarManager sharedInstance].appStoreAppID = appId;
        
    //监听显示苹果商店评分系统显示时机的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appStoreStarScoreView:) name:@"TTAppStoreStarManagerShowNotice" object:nil];
}

- (void)appStoreStarScoreView:(NSNotification *)notice
{
    //通用点赞动画需要特殊处理,有点赞动画的时候不执行
    NSDictionary *dic = [notice userInfo];
    NSString *trigger = dic[@"trigger"];
    NSMutableDictionary *trackInfo = @{}.mutableCopy;
    if ([trigger isKindOfClass:[NSString class]] && trigger.length > 0) {
        trackInfo[@"trigger"] = trigger;
    }else {
        trackInfo[@"trigger"] = @"be_null";
    }
    [TTAppStoreStarManager sharedInstance].trackerInfo = trackInfo;
    [[TTAppStoreStarManager sharedInstance]show];
}

#pragma mark TTAppStoreStarManagerDelegate

//setting开关，sdk通过代理读取setting开关
- (BOOL)appStoreStarEnable
{
    NSDictionary *archSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    BOOL isAppStoreEnable = [archSettings tt_boolValueForKey:@"store_score_enable"];
    return isAppStoreEnable;
}

//SDK 内部如果在播放视频不会调起弹窗，如果App没有视频播放功能直接返回 NO
- (BOOL)appStoreStarIsVideoPlaying
{
    BOOL meetCondition = [TTPushAlertManager meetsStrongAlertCondition];
    return !meetCondition;
}

- (BOOL)useSystemAlert
{
    BOOL isSytemBug = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"12.2") && SYSTEM_VERSION_LESS_THAN(@"12.4");
    //TODO zjing 系统好评弹窗展示时的window判断在iOS12和iOS13上面都有问题，导致系统好评弹窗和自定义好评弹窗h重合，在这两个版本上单独处理下
    if (isSytemBug) {
        return NO;
    }
    return YES;
}

- (void)showCustomStoreGoodReviewGuidView
{
    //TODO：更改为自定义y逻辑
    //默认自定义弹窗会在三次系统弹窗出现之后再出现
    //这里显示自定义弹窗，并且在自定义弹窗完成如下事件
    //好评按钮点击，调用[[TTAppStoreStarManager sharedInstance] goodReviewButtonClick]; SDK完成跳转和统一埋点
    //反馈按钮点击，自己完成页面跳转并且调用[[TTAppStoreStarManager sharedInstance] trackClickFeedBackButton]; SDK仅完成埋点上报
    //关闭按钮点击，调用[[TTAppStoreStarManager sharedInstance] trackClickCloseButton]; SDK仅仅完成埋点上报
    
    FHAppStoreCustomAlertView *alert = [FHAppStoreCustomAlertView alertWithTitle:@"喜欢“幸福里”吗？" message:@"您的鼓励对我们非常重要！" buttons:@[@"去鼓励",@"去吐槽"] tapBlock:^(NSInteger index) {

        switch (index) {
            case 1: {
                NSLog(@"用户点击了五星好评");
                [[TTAppStoreStarManager sharedInstance] goodReviewButtonClick];
                break;
            }
            case 2: {
                NSLog(@"用户点击了反馈按钮");
                [[TTRoute sharedRoute]openURLByPushViewController:[NSURL URLWithString:@"sslocal://feedback"]];
                [[TTAppStoreStarManager sharedInstance] trackClickFeedBackButton];
                break;
            }
            case 0: {
                NSLog(@"用户点击了取消");
                [[TTAppStoreStarManager sharedInstance] trackClickCloseButton];
                break;
            }
                
            default:
                break;
        }
    }];
    [alert show];
}



@end
