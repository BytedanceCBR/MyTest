//
//  SSFeedbackManager.m
//  Article
//
//  Created by Zhang Leonardo on 13-1-6.
//
//

#import "SSFeedbackManager.h"
#import "NetworkUtilities.h"
#import "TTNetworkManager.h"
#import "SSFeedbackModel.h"
#import "CommonURLSetting.h"
#import "UIDevice+TTAdditions.h"
#import "SSCommonLogic.h"
#import "TTInstallIDManager.h"
#import "CommonURLSetting.h"
#import "TTProjectLogicManager.h"
#import "TTSandBoxHelper.h"
#import "TTNetworkHelper.h"
//#import "TTFantasyLogManager.h"
#import "SSFetchSettingsManager.h"
#import "TTPostDataHttpRequestSerializer.h"
#import "TTIndicatorView.h"

#define kNewestServerTypeFeedbackItemPubDateKey @"kNewestServerTypeFeedbackItemPubDateKey"//记录最新一条反馈的时间user default key
#define kNewestFeedbackItemIDKey @"kNewestFeedbackItemIDKey" //类似kNewestFeedbackItemPubDateKey
#define kHasNewFeedbackUserDefaultKey @"kHasNewFeedbackUserDefaultKey"
#define kFeedbackDefaultContactKey @"kFeedbackDefaultContactKey"
#define kFeedbackNeedPostImgURIKey @"kFeedbackNeedPostImgURIKey"
#define kFeedbackNeedPostMsgKey @"kFeedbackNeedPostMsgKey"
#define kSavedFeedbackModelsKey @"kSavedFeedbackModelsKey" //保存用户反馈的key
#define kSSFeedbackDefaultModelKey @"kSSFeedbackDefaultModelKey"//用户反馈的默认model

static NSString *curQuestionID;

@interface SSFeedbackManager()

@property(nonatomic, retain) NSString * feedbackKey;

@end

@implementation SSFeedbackManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        NSString * appKey = TTLogicStringNODefault(@"ssFeedbackAppKey");
        if ([appKey length] == 0) {
            SSLog(@" you must set ssFeedbackAppKey before startLoadComments");
        }

        self.feedbackKey = [NSString stringWithString:appKey];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pn_didReceiveMemoryWarningNotification:)
                                                     name:
        UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

static SSFeedbackManager *manager = nil;

+ (SSFeedbackManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSFeedbackManager alloc] init];
    });
    return manager;
}

//+ (instancetype)allocWithZone:(struct _NSZone *)zone
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        manager = [super allocWithZone:zone];
//    });
//    return manager;
//}

+ (void)saveFeedbackModels:(NSArray *)ary
{
    if ([ary count] == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedFeedbackModelsKey];
    }
    else {
        NSMutableArray * tempResults = [NSMutableArray arrayWithCapacity:fetchCount];
        int i = 0;
        for (SSFeedbackModel * model in ary) {
            i ++;
            if (i >= fetchCount) {//最大保存条数限制
                return;
            }
            id arch = [NSKeyedArchiver archivedDataWithRootObject:model];
            if (arch != nil) {
                [tempResults addObject:arch];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:tempResults] forKey:kSavedFeedbackModelsKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)recentFeedbackModels
{
    NSArray * savedAry = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedFeedbackModelsKey];
    NSMutableArray * tempResults= [NSMutableArray arrayWithCapacity:fetchCount];
    for (id temp in savedAry) {
        id model = [NSKeyedUnarchiver unarchiveObjectWithData:temp];
        if (model != nil) {
            [tempResults addObject:model];
        }
    }
    return [NSArray arrayWithArray:tempResults];
}


+ (void)saveDefaultContactString:(NSString *)string
{
    NSString * newStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!isEmptyString(newStr)) {
        [[NSUserDefaults standardUserDefaults] setObject:newStr forKey:kFeedbackDefaultContactKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSString *)defaultContactString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFeedbackDefaultContactKey];
}

+ (NSString *)needPostImgURI
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFeedbackNeedPostImgURIKey];
}

+ (void)saveNeedPostImgURI:(NSString *)uri
{
    if (isEmptyString(uri)) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFeedbackNeedPostImgURIKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:uri forKey:kFeedbackNeedPostImgURIKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UIImage *)needPostImg
{
    NSString * path = [self needPostImgCachePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData * imgData = [[NSFileManager defaultManager] contentsAtPath:path];
        if (imgData != nil) {
            UIImage * img = [UIImage imageWithData:imgData];
            return img;
        }
    }
    return nil;
}

+ (void)saveNeedPostImg:(UIImage *)image
{
    NSString * path = [self needPostImgCachePath];
    
    if (image == nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        return;
    }
    
    [UIImageJPEGRepresentation(image, 1.f) writeToFile:path atomically:YES];
}

+ (NSString *)needPostImgCachePath
{
    NSString *cachePath = [[NSHomeDirectory()stringByAppendingPathComponent:@"Library"]stringByAppendingPathComponent:@"feedbackPostSavedImg"];
    return cachePath;
}

+ (NSString *)needPostMsg
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFeedbackNeedPostMsgKey];
}

+ (void)saveNeedPostMsg:(NSString *)msg
{
    if (isEmptyString(msg)) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFeedbackNeedPostMsgKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:msg forKey:kFeedbackNeedPostMsgKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+ (void)setHasNewFeedback:(BOOL)hasNew
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:hasNew] forKey:kHasNewFeedbackUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)newestServerTypeFeedbackItemPubDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kNewestServerTypeFeedbackItemPubDateKey];
}

+ (NSString *)newestFeedbackItemID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kNewestFeedbackItemIDKey];
}

+ (void)saveFeedbackItemServerTypePubDateIfIsNewest:(NSString *)date
{
    if (isEmptyString(date)) {
        return;
    }
    NSString * oriDate = [self newestServerTypeFeedbackItemPubDate];
    if ([oriDate longLongValue] < [date longLongValue]) {// has new
        if ([oriDate longLongValue] != 0) {
            [self setHasNewFeedback:YES];
        }
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:kNewestServerTypeFeedbackItemPubDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)saveFeedbackIDIfIsNewest:(NSString *)feedbackID
{
    if (isEmptyString(feedbackID)) {
        return;
    }
    NSString * oriID = [self newestFeedbackItemID];
    
    if ([oriID longLongValue] < [feedbackID longLongValue]) {// has new
        [[NSUserDefaults standardUserDefaults] setObject:feedbackID forKey:kNewestFeedbackItemIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)hasNewFeedback
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kHasNewFeedbackUserDefaultKey] boolValue];
}

- (void)checkHasNewFeedback
{
    [self startFetchComments:NO contextID:[SSFeedbackManager newestFeedbackItemID]];
}

- (void)startFetchComments:(BOOL)isLoadMore contextID:(NSString *)cId
{
    if (!TTNetworkConnected()) {
        
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络异常，请检查网络后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        return;
    }
    
    if ([_feedbackKey length] == 0) {
        
        return;
    }
    
    NSString * url = [CommonURLSetting feedbackFetch];
    
    NSMutableDictionary * parameterDict = [NSMutableDictionary dictionaryWithCapacity:10];
    [parameterDict setValue:_feedbackKey forKey:@"appkey"];
    [parameterDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    if (isLoadMore) {
        [parameterDict setValue:cId forKey:@"max_id"];
    }
    else {
        [parameterDict setValue:cId forKey:@"min_id"];
    }
    [parameterDict setObject:[NSNumber numberWithInt:fetchCount] forKey:@"count"];
    [parameterDict setValue:[NSNumber numberWithInt:fetchCount] forKey:@"count"];
    [parameterDict setValue:[TTSandBoxHelper ssAppID] forKey:@"aid"];
    [parameterDict setValue:[TTSandBoxHelper appName] forKey:@"app_name"];

    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameterDict method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSArray *models = [[NSArray alloc] init];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:[NSNumber numberWithBool:isLoadMore] forKey:@"isLoadMore"];
        if (!error) {
            __autoreleasing NSError *jsonError;
            SSFeedbackResponse *response = [[SSFeedbackResponse alloc] initWithDictionary:jsonObj error:&jsonError];
            [userInfo setValue:response.hasMore forKey:@"hasMore"];
            //保存serverType最新一条的时间,和最新一条itemID
            for (SSFeedbackModel * m in response.data) {
                [SSFeedbackManager saveFeedbackIDIfIsNewest:m.feedbackID];
                if ([m.feedbackType intValue] == feedbackTypeServer) {
                    [SSFeedbackManager saveFeedbackItemServerTypePubDateIfIsNewest:m.pubDate];
                }
            }
            models = response.data;
            if (response.defaultItem) {
                [SSFeedbackManager saveDefaultFeedbackModel:response.defaultItem];
            }
        }
        
        if (wself.delegate && [wself.delegate respondsToSelector:@selector(feedbackManager:fetchedNewModels:userInfo:error:)]) {
            [wself.delegate feedbackManager:self fetchedNewModels:models userInfo:[NSDictionary dictionaryWithDictionary:userInfo] error:error];
        }
    }];
}

- (void)startPostFeedbackContent:(NSString *)contentStr userContact:(NSString *)contactStr imgURI:(NSString *)URI backgorundImgURI:(NSString *)backURI imageCreateDate:(NSDate *)imageCreateDate
{
    NSMutableDictionary *customPostParam = [[NSMutableDictionary alloc] initWithCapacity:3];
    if (!isEmptyString(contentStr)) {
        [customPostParam setObject:contentStr forKey:@"content"];
    }
    if (!isEmptyString(contactStr)) {
        [customPostParam setObject:contactStr forKey:@"contact"];
    }
    if(!isEmptyString(backURI))
    {
        [customPostParam setObject:backURI forKey:@"background_image_uri"];
    }
    
    //有截屏时才上传DOM, 减少脏数据 @zengruihuan
    if (!isEmptyString(URI)) {
        [customPostParam setValue:URI forKey:@"image_uri"];
        NSDate *snapshotDate = self.snapshotDate? :[SSFeedbackManager shareInstance].snapshotDate;
        
        NSString *snapshotURL = isEmptyString(self.snapshotURL)? (isEmptyString([SSFeedbackManager shareInstance].snapshotURL)? nil: [SSFeedbackManager shareInstance].snapshotURL): self.snapshotURL;
        
        NSString *snapshotDOM = isEmptyString(self.snapshotDOM)? (isEmptyString([SSFeedbackManager shareInstance].snapshotDOM)? nil: [SSFeedbackManager shareInstance].snapshotDOM): self.snapshotDOM;
        
        //1. 如果imageCreateDate为空, 上传
        //2. 如果两个时间误差在10s内, 上传
        if (!imageCreateDate || (ABS([snapshotDate timeIntervalSinceDate:imageCreateDate]) < 10)) {
            [customPostParam setValue:snapshotURL forKey:@"url_0"];
            [customPostParam setValue:snapshotDOM forKey:@"html_0"];
            [customPostParam setValue:@"1" forKey:@"html_count"];
        }
    }
    
    //带上常见问题id
    if (!isEmptyString(curQuestionID)) {
        [customPostParam setValue:[curQuestionID copy] forKey:@"qr_id"];
    }
    
    self.snapshotURL = nil;
    self.snapshotDOM = nil;
    self.snapshotDate = nil;
    
    [SSFeedbackManager shareInstance].snapshotURL = nil;
    [SSFeedbackManager shareInstance].snapshotDOM = nil;
    [SSFeedbackManager shareInstance].snapshotDate = nil;
    
    [self startPostFeedbackWithCustomPostParam:customPostParam];
}

- (void)startPostFeedbackWithCustomPostParam:(NSDictionary *)customPostParam {

    if (!TTNetworkConnected() || [_feedbackKey length] == 0) {
        if (_delegate && [_delegate respondsToSelector:@selector(feedbackManager:postMsgUserInfo:error:)]) {
            NSError * er = [NSError errorWithDomain:kCommonErrorDomain code:kNoNetworkErrorCode userInfo:nil];
            [_delegate feedbackManager:self postMsgUserInfo:nil error:er];
        }
        return ;
    }
    
    NSMutableDictionary * postParameterDict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    
    [postParameterDict setValue:_feedbackKey forKey:@"appkey"];
    [postParameterDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
    [postParameterDict setObject:[TTNetworkHelper connectMethodName] forKey:@"network_type"];
    [postParameterDict setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
    [postParameterDict setValue:[[UIDevice currentDevice] platformString] forKey:@"device"];
    [postParameterDict setObject:[TTSandBoxHelper versionName] forKey:@"app_version"];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] valueForKey:@"ttv_video_settings"];
    NSString *value = @"";
    BOOL isFirst = YES;
    if ([dic isKindOfClass:[NSDictionary class]]) {
        for (NSString *aValue in [dic allValues]) {
            if (isFirst) {
                value = [NSString stringWithFormat:@"%@%@",value,aValue];
            }else{
                value = [NSString stringWithFormat:@"%@_%@",value,aValue];
            }
            isFirst = NO;
        }
    }
    if (value.length > 0) {
        [postParameterDict setValue:value forKey:@"ttv_video_settings"];
    }
    
//    //fantasy log
//    if ([[TTFantasyLogManager sharedManager] getLatestLogs].count) {
//        NSMutableString *fantasyLog = [[NSMutableString alloc] init];
//        for (NSString *log in [[TTFantasyLogManager sharedManager] getLatestLogs]) {
//            [fantasyLog appendString:log];
//        }
//        [postParameterDict setValue:fantasyLog forKey:@"fantasy_log"];
//    }
    
    //外面传入的优先级高, 会覆盖之前的 @zengruihuan
    if ([customPostParam isKindOfClass:[NSDictionary class]]) {
        [postParameterDict addEntriesFromDictionary:customPostParam];
    }
    // 附加Setting接口数据
    NSDictionary *settings = [SSFetchSettingsManager shareInstance].settingsDict;
    if (![settings tt_boolValueForKey:@"disable_feedback_settings"]) {
        [postParameterDict setValue:settings forKey:@"settings"];
    }
    
    NSString * url = [CommonURLSetting feedbackPostMsg];
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:postParameterDict method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (wself.delegate && [wself.delegate respondsToSelector:@selector(feedbackManager:postMsgUserInfo:error:)]) {
            [wself.delegate feedbackManager:self postMsgUserInfo:nil error:error];
        }
    }];
}

//获取之前保存的默认项（位于列表最上面）
+ (SSFeedbackModel *)queryDefaultFeedbackModel
{
    NSData * arch = [[NSUserDefaults standardUserDefaults] objectForKey:kSSFeedbackDefaultModelKey];
    if (arch == nil) {
        return nil;
    }
    SSFeedbackModel * model = [NSKeyedUnarchiver unarchiveObjectWithData:arch];
    return model;
}
//保存默认项（位于列表最上面）
+ (void)saveDefaultFeedbackModel:(SSFeedbackModel *)model
{
    if (model == nil) {
        return;
    }
    //TODO f100 这里临时禁掉服务器下发的文案
    model.content = @"你好~有任何产品问题或建议都可以在这里反馈给我们哦～也可以通过QQ3507049274与我们取得联系。";
    NSData * arch = [NSKeyedArchiver archivedDataWithRootObject:model];
    [[NSUserDefaults standardUserDefaults] setObject:arch forKey:kSSFeedbackDefaultModelKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)pn_didReceiveMemoryWarningNotification:(NSNotification *)notification {
    self.snapshotDOM = nil;
    self.snapshotURL = nil;
    self.snapshotDate = nil;
}

+ (void)updateCurQuestionID:(NSString *)questionID
{
    curQuestionID = questionID;
}
@end
