//
//  TTCategoryStayTrackManager.m
//  Article
//
//  Created by xuzichao on 2017/5/23.
//
//

#import "TTCategoryStayTrackManager.h"
#import "TTTrackerWrapper.h"
#import "TTBaseMacro.h"

#define kMomentListFakeCategoryID @"kMomentListFakeCategoryID"

#define kIgnoreMinTime 5        //忽略5秒以下的统计,针对频道
#define kMomentIgnoreMinTime 3  //忽略3秒以下的统计,针对动态

@interface TTCategoryStayTrackManager()

@property(nonatomic, assign)NSTimeInterval categoryStartInterval;   //正在统计的category的启动时间

@property(nonatomic, retain)NSString * suspendCategoryID;           //保存因为进入后台停止统计的category ID， 回到前台后，会判断是否有该值， 如果有，将重新计时
@property(nonatomic, copy)NSString * suspendConcernID;              //保存因为进入后台停止统计的concern ID

@property(nonatomic, copy)NSString * lastTrackingCategoryID;      //上一个频道的category ID
@property(nonatomic, copy)NSString * enterFromCategoryID;

@end

@implementation TTCategoryStayTrackManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

static TTCategoryStayTrackManager * manager;
+ (TTCategoryStayTrackManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTCategoryStayTrackManager alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveWillEnterForgroundNotification:) name:UIApplicationWillEnterForegroundNotification  object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification  object:nil];
    }
    return self;
}

- (void)receiveWillEnterForgroundNotification:(NSNotification *)notification
{
    if (!isEmptyString(_suspendCategoryID)) {
        [self startTrackForCategoryID:_suspendCategoryID concernID:_suspendConcernID enterType:nil];
    }
}

- (void)receiveDidEnterBackgroundNotification:(NSNotification *)notification
{
    if (!isEmptyString(_trackingCategoryID)) {
        self.suspendCategoryID = _trackingCategoryID;
        self.suspendConcernID = _trackingConcernID;
    }
    [self endTrackCategory:_trackingCategoryID];
}



- (void)clearIncludeSuspendInfo:(BOOL)include
{
    self.categoryStartInterval = 0;
    self.trackingCategoryID = nil;
    self.trackingConcernID = nil;
    if (include) {
        self.suspendCategoryID = nil;
        self.suspendConcernID = nil;
    }
}

- (float)ignoreMinTime
{
    if ([_trackingCategoryID isEqualToString:kMomentListFakeCategoryID]) {
        return kMomentIgnoreMinTime;
    }
    return kIgnoreMinTime;
}

- (void)trackStayEventStayTime:(NSTimeInterval)stayTime
{
    //频道切换埋点
    NSString *categoryID = _trackingCategoryID;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
    [dict setValue:@"house_app2c_v2" forKey:@"event_type"];
    [dict setValue:@(((long long) (stayTime * 1000))) forKey:@"stay_time"];
    if (!isEmptyString(_trackingCategoryID)) {
        [dict setValue:_trackingCategoryID forKey:@"category_name"];
    }
    if (!isEmptyString(_enterType)) {
        [dict setValue:_enterType forKey:@"enter_type"];
    }
    [BDTrackerProtocol eventV3:@"stay_category" params:dict isDoubleSending:NO];

    self.lastTrackingCategoryID = _trackingCategoryID;
    /* //lite 频道切换埋点代码
    if (stayTime >= [self ignoreMinTime]) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
        if ([_trackingCategoryID isEqualToString:kMomentListFakeCategoryID]) {//统计动态
            [dict setValue:@"article" forKey:@"category"];
            [dict setValue:@"stay_update" forKey:@"tag"];
            [dict setValue:@"update" forKey:@"label"];
            [dict setValue:@(((long long) (stayTime * 1000))) forKey:@"value"];
        }
        else {
            //统计频道
            NSString *eventStr = @"stay_category";
            NSString *categoryID = _trackingCategoryID;
            
            //服务端应当区分视频tab和推荐tab下的火山频道字段，遗留逻辑导致客户端这样尴尬的判断
            UIWindow * mainWindow = [[UIApplication sharedApplication].delegate window];
            if ([mainWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
                UITabBarController * tabBarController = (UITabBarController *)mainWindow.rootViewController;
                if ([categoryID isEqualToString: @"hotsoon"] && tabBarController.selectedIndex == 1) {
                    categoryID = @"subv_hotsoon";
                }
            }
            
            [dict setValue:@"article" forKey:@"category"];
            [dict setValue:eventStr forKey:@"tag"];
            [dict setValue:categoryID forKey:@"label"];
            [dict setValue:@(((long long) (stayTime * 1000))) forKey:@"value"];
            [dict setValue:@(1) forKey:@"refer"];
            [dict setValue:_trackingCategoryID forKey:@"category_id"];
            [dict setValue:_trackingConcernID forKey:@"concern_id"];
        }
    
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [BDTrackerProtocol eventData:dict];
        }
    } else {
        //NSLog(@"~~~~~~~~~~~~~~~~~~ignore, %f less than %f", stayTime, [self ignoreMinTime]);
    }
 
    // log3.0去掉了最短时间判断
    if (![_trackingCategoryID isEqualToString:kMomentListFakeCategoryID]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        [dict setValue:@(((long long) (stayTime * 1000))) forKey:@"stay_time"];
        [dict setValue:@(1) forKey:@"refer"];
        [dict setValue:_trackingCategoryID forKey:@"category_name"];
        [dict setValue:_trackingConcernID forKey:@"concern_id"];
        if (!isEmptyString(_enterType) && !isEmptyString(self.enterFromCategoryID) && ![self.enterFromCategoryID isEqualToString:_trackingCategoryID]) {
            [dict setValue:_enterType forKey:@"enter_type"];
            NSString *enterFrom = [NSString stringWithFormat:@"%@_%@", _enterType, self.enterFromCategoryID];
            [dict setValue:enterFrom forKey:@"enter_from"];
        }
        [TTTrackerWrapper eventV3:@"stay_category" params:dict isDoubleSending:YES];
        
        self.lastTrackingCategoryID = _trackingCategoryID;
    }
     */
}

#pragma mark -- list

- (void)startTrackForCategoryID:(NSString *)categoryID concernID:(NSString *)concernID enterType:(NSString *)enterType
{
    NSString * tmpCategoryID = categoryID;
    if (![tmpCategoryID isEqualToString:_trackingCategoryID]) {
        [self endTrackCategory:_trackingCategoryID];
        [self clearIncludeSuspendInfo:YES];
    }
    
    self.categoryStartInterval = [[NSDate date] timeIntervalSince1970];
    self.trackingCategoryID = tmpCategoryID;
    self.trackingConcernID = concernID;
    
    if (![categoryID isEqualToString:self.lastTrackingCategoryID]) {
        self.enterType = enterType;
        self.enterFromCategoryID = self.lastTrackingCategoryID;
    }
    //NSLog(@"~~~~~~~~~~~~~~~~~~start category = %@", self.trackingCategoryID);
}

- (void)endTrackCategory:(NSString *)categoryID
{
    if (isEmptyString(_trackingCategoryID) || _categoryStartInterval <= 0) {
        [self clearIncludeSuspendInfo:NO];
        return;
    }
    
    if ([categoryID isEqualToString:_trackingCategoryID]) {
        //NSLog(@"~~~~~~~~~~~~~~~~~~end category = %@", self.trackingCategoryID);
        
        double stayTime = [[NSDate date] timeIntervalSince1970] - _categoryStartInterval;
        
        [self trackStayEventStayTime:stayTime];
        
        [self clearIncludeSuspendInfo:NO];
    }
}

#pragma mark -- moment

/**
 *  开始统计动态列表的停留时常
 */
- (void)startTrackForMomentList
{
    [self startTrackForCategoryID:kMomentListFakeCategoryID concernID:nil enterType:nil];
}

/**
 *  结束统计动态列表的停留时常
 */
- (void)endTrackForMomentList
{
    [self endTrackCategory:kMomentListFakeCategoryID];
}


@end
