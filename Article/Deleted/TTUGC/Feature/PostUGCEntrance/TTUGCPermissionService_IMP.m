//
//  TTUGCPermissionService_IMP.m
//  Article
//
//  Created by 王霖 on 16/10/23.
//
//

#import "TTUGCPermissionService_IMP.h"
#import "TTUGCPermissionService.h"
#import <TTAccountBusiness.h>
#import <TTNetworkManager.h>
#import "ArticleURLSetting.h"
#import "TTPostUGCEntrance.h"
#import "TTSettingsManager.h"
//#import "TTServerDateCalibrator.h"
//#import "TTSFRedpacketManager.h"
#import "TTVideoRecorderStickersConfig.h"
//#import "TTSFResourcesManager.h"
#import "TTkitchenHeader.h"
#import "TTTabBarProvider.h"


NSString * const kTTPostUGCTypeTextAndImage = @"text_img";
NSString * const kTTPostUGCTypeImage = @"img";
NSString * const kTTPostUGCTypeText = @"text";
NSString * const kTTPostUGCTypeUGCVideo = @"video";
NSString * const kTTPostUGCTypeShortVideo = @"short_video";
NSString * const kTTPostUGCTypeWenda = @"wenda";

static NSString * const kTTRefactorHadShowPostUGCTipsView = @"kTTRefactorHadShowPostUGCTipsView";
static NSString * const kTTPostUGCPermissionUserDefaultKey = @"kTTPostUGCPermissionUserDefaultKey";

//上次发布器的位置key
static NSString * const kTTLastPostUGCEntrancePositionKey = @"kTTLastPostUGCEntrancePositionKey";

@interface TTUGCPermissionService_IMP () <TTAccountMulticastProtocol>

@property (nonatomic, assign) BOOL needShowPostUGCTipsView;
@property (nonatomic, assign) BOOL lastShowNormalIntroView;
@property (nonatomic, assign) BOOL lastShowRedpackIntroView;

@end

@implementation TTUGCPermissionService_IMP

#pragma mark - Life cycle

+ (instancetype)sharedInstance {
    static TTUGCPermissionService_IMP * sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[[self class] alloc] init];
    });
    return sharedController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

- (void)startFetchPostUGCPermission {
    self.lastShowNormalIntroView = [self needShowShortVideoTabNormalIntro];
    self.lastShowRedpackIntroView = [self needShowShortVideoRedpackIntro];

    __weak typeof(self) wSelf = self;
    [[TTNetworkManager shareInstance] requestModel:[[FRUgcPublishVideoV3CheckAuthRequestModel alloc] init] callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if ([responseModel isKindOfClass:[FRUgcPublishVideoV3CheckAuthResponseModel class]]) {
            FRUgcPublishVideoV3CheckAuthResponseModel *videoAutoModel = (FRUgcPublishVideoV3CheckAuthResponseModel *)responseModel;
            [wSelf savePostUGCPermission:[videoAutoModel.publisher_permission_control toDictionary]];
            [wSelf clearShortVideoRedpackHasGot];
        }
        [self updateNeedShowShortVideoMainNormalIntro];
        [self updateNeedShowShortVideoRedpackIntro];
    }];
}

- (void)savePostUGCPermission:(NSDictionary *)permissionDict {
    //存储最新获取的数据
    if ([permissionDict isKindOfClass:[NSDictionary class]] && [permissionDict count] > 0) {
        [[NSUserDefaults standardUserDefaults] setValue:permissionDict forKey:kTTPostUGCPermissionUserDefaultKey];
    }else {
        permissionDict = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTTPostUGCPermissionUserDefaultKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTPostUGCPermissionUpdateNotification
                                                        object:nil];
}

- (NSDictionary *)savedPostUGCPermissionDict {
    NSDictionary * dict = [[NSUserDefaults standardUserDefaults] objectForKey:kTTPostUGCPermissionUserDefaultKey];
    return dict;
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self savePostUGCPermission:nil];
    [self startFetchPostUGCPermission];
}

- (BOOL)postUGCStatus {
    return [[self savedPostUGCPermissionDict] tt_boolValueForKey:@"post_ugc_status"];
}

- (NSUInteger)publishEntranceStyle {
    return [[self savedPostUGCPermissionDict] tt_unsignedIntegerValueForKey:@"publish_entrance_style"];
}
- (NSUInteger)disable_entrance {
    return [[self savedPostUGCPermissionDict] tt_unsignedIntegerValueForKey:@"disable_entrance"];
}

-(NSInteger)WendaEntranceShowEnable{
    return [[self savedPostUGCPermissionDict] tt_unsignedIntegerValueForKey:@"show_wenda"];
}

- (BOOL)showAuthorDeleteEntrance {
    BOOL localSwitchEnable = [KitchenMgr getBOOL:kKCUGCAuthorDeletePermission];
    if (localSwitchEnable) {
        return YES;
    }
    return [[self savedPostUGCPermissionDict] tt_boolValueForKey:@"show_author_delete_entrance"];
}

- (BOOL)hasDeletePermissionWithOriginCommentOrThreadUserID:(NSString *)uid {
    BOOL hasDeleteReplyPermission = NO;
    if ([TTAccountManager isLogin]
        && [GET_SERVICE_BY_PROTOCOL(TTUGCPermissionService) showAuthorDeleteEntrance]) {
        NSString *selfUID = [TTAccountManager userID];
        if (!isEmptyString(selfUID) && [uid isEqualToString:selfUID]) {
            hasDeleteReplyPermission = YES;
        }
    }
    return hasDeleteReplyPermission;
}

#pragma mark - Public

- (NSArray<FRPublishConfigStructModel *> *)publishTypeModels {
    NSDictionary *publishInfo = [self savedPostUGCPermissionDict];
    NSArray *items = publishInfo[@"main_publisher_type"];
    NSArray<FRPublishConfigStructModel *> *models = [FRPublishConfigStructModel arrayOfModelsFromDictionaries:items];
    if ([models count] > 0) {
        return [models copy];
    }
    return nil;
}

- (NSInteger)convertTypeString:(NSString *)typeString {
    if ([typeString isEqualToString:kTTPostUGCTypeText]) {
        return TTPostUGCEntranceButtonTypeText;
    }
    else if ([typeString isEqualToString:kTTPostUGCTypeImage]) {
        return TTPostUGCEntranceButtonTypeImage;
    }
    else if ([typeString isEqualToString:kTTPostUGCTypeUGCVideo]) {
        return TTPostUGCEntranceButtonTypeVideo;
    }
    else if ([typeString isEqualToString:kTTPostUGCTypeWenda]) {
        return TTPostUGCEntranceButtonTypeWenda;
    }
    else if ([typeString isEqualToString:kTTPostUGCTypeTextAndImage]) {
        return TTPostUGCEntranceButtonTypeImageAndText;
    }
    else if ([typeString isEqualToString:kTTPostUGCTypeShortVideo]) {
        return TTPostUGCEntranceButtonTypeShortVideo;
    }
    return 0;
}

- (BOOL)postUGCBan {
    return [[self savedPostUGCPermissionDict] tt_boolValueForKey:@"ban_status"];
}

- (nullable NSString *)postUGCBanTips {
    NSString * banTips = [[self savedPostUGCPermissionDict] tt_stringValueForKey:@"ban_tips"];
    if (isEmptyString(banTips)) {
        banTips = NSLocalizedString(@"账号已被封禁，无法发布任何内容", nil);
    }
    return banTips;
}

//设置发布器的位置
- (TTPostUGCEntrancePosition)postUGCEntrancePosition {
    TTPostUGCEntrancePosition postUGCEntrancePosition = TTPostUGCEntrancePositionTabbar;
    //总控制，1标识屏蔽发布器
    if ([self disable_entrance] && [self disable_entrance] == 1) {
        postUGCEntrancePosition = TTPostUGCEntrancePositionNone;
    }else{
        
        if ([self postUGCStatus]) {
            //post_ugc_status为YES
            if ([self publishEntranceStyle] == 0) {
                //显示底部tabbar发布器入口
                postUGCEntrancePosition = TTPostUGCEntrancePositionTabbar;
            }else {
                if ([TTTabBarProvider isWeitoutiaoOnTabBar]) {
                    //第三个tab是微头条，显示微头条tab顶部发布器入口
                    postUGCEntrancePosition = TTPostUGCEntrancePositionWeitoutiaoTop;
                }else {
                    //显示底部tabbar发布器入口
                    postUGCEntrancePosition = TTPostUGCEntrancePositionTabbar;
                }
            }
        }else {
            //post_ugc_status为NO 或者 用户未登录
            if ([self publishEntranceStyle] == 0) {
                //显示微头条tab右下角发布器入口
                postUGCEntrancePosition = TTPostUGCEntrancePositionWeitoutiaoRightBottom;
            }else {
                //显示微头条tab顶部发布器入口
                postUGCEntrancePosition = TTPostUGCEntrancePositionWeitoutiaoTop;
            }
        }
    }
    //保存
    [[NSUserDefaults standardUserDefaults] setInteger:postUGCEntrancePosition forKey:kTTLastPostUGCEntrancePositionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return postUGCEntrancePosition;
}

- (BOOL)isShowWendaPulishEntrance{

    NSInteger isShowWenda = [self WendaEntranceShowEnable];
    if (isShowWenda == 1) {
        return YES;
    }

    return NO;
}

- (nullable NSString *)postUGCHint {
    return [[self savedPostUGCPermissionDict] tt_stringValueForKey:@"post_message_content_hint"];
}

- (FRShowEtStatus)postUGCShowEtStatus {
    return [[self savedPostUGCPermissionDict] tt_unsignedIntegerValueForKey:@"show_et_status"];
}

- (nonnull NSString *)postUGCTips {
    NSString * tips = [[self savedPostUGCPermissionDict] tt_stringValueForKey:@"first_tips"];
    if (isEmptyString(tips)) {
        tips = NSLocalizedString(@"开始分享新鲜事", nil);
    }
    return tips;
}

- (BOOL)isNeedShowPostUGCTipsView {
    BOOL hadShow = [[NSUserDefaults standardUserDefaults] boolForKey:kTTRefactorHadShowPostUGCTipsView];
    if (hadShow == NO && self.needShowPostUGCTipsView) {
        return YES;
    }else {
        return NO;
    }
}

- (void)setIsNeedShowPostUGCTipsView {
    self.needShowPostUGCTipsView = YES;
}

- (void)setHadShowPostUGCTipsView {
    self.needShowPostUGCTipsView = NO;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTTRefactorHadShowPostUGCTipsView];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 红包引导

static NSString * const TTShortVideoMainIntroHasOpenedUserDefaulsKey = @"TTShortVideoMainIntroHasOpenedUserDefaulsKey";
static NSString * const TTShortVideoTabIntroHasOpenedUserDefaulsKey = @"TTShortVideoTabIntroHasOpenedUserDefaulsKey";
static NSString * const TTShortVideoRecorderTabNormalIntroShowedUserDefaulsKey = @"TTShortVideoRecorderTabNormalIntroShowedUserDefaulsKey";
static NSString * const TTShortVideoRecorderRedpackGotUserDefaultsKey = @"TTShortVideoRecorderRedpackGotUserDefaultsKey";
static NSString * const TTShortVideoSpringRedpackTimesDefaultsKey = @"TTShortVideoSpringRedpackTimesDefaultsKey";

- (FRRedpackStructModel *)redpackModel {
    NSDictionary *savedDic = [self savedPostUGCPermissionDict];
    if (savedDic && [savedDic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *videoIntro = [savedDic tt_dictionaryValueForKey:@"video_intro"];
        NSDictionary *redpackDic = [videoIntro tt_dictionaryValueForKey:@"redpack"];
        FRRedpackStructModel *redpackModel = [[FRRedpackStructModel alloc] initWithDictionary:redpackDic error:nil];
        return redpackModel;
    }
    return nil;
}

- (BOOL)normalMainIntroEnabled {
    NSDictionary *savedDic = [self savedPostUGCPermissionDict];
    if (savedDic && [savedDic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *redpackDic = [savedDic tt_dictionaryValueForKey:@"video_intro"];
        BOOL normalIntroEnabled = [redpackDic tt_boolValueForKey:@"normal_intro"];
        return normalIntroEnabled;
    }
    return NO;
}

- (BOOL)normalShortVideoTabIntroEnabled {
    NSDictionary *savedDic = [self savedPostUGCPermissionDict];
    if (savedDic && [savedDic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *redpackDic = [savedDic tt_dictionaryValueForKey:@"video_intro"];
        BOOL normalIntroEnabled = [redpackDic tt_boolValueForKey:@"video_intro_tips"];
        return normalIntroEnabled;
    }
    return NO;
}

- (NSString *)shortVideoTabNormalIntroText {
    NSDictionary *savedDic = [self savedPostUGCPermissionDict];
    if (savedDic && [savedDic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *redpackDic = [savedDic tt_dictionaryValueForKey:@"video_intro"];
        NSString *text = [redpackDic tt_stringValueForKey:@"video_intro_tips_text"];
        if (!isEmptyString(text)) {
            return text;
        }
    }
    return @"点击拍小视频";
}

//设置主发布器入口被用户打开过
- (void)setShortVideoNormalMainIntroClicked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TTShortVideoMainIntroHasOpenedUserDefaulsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateNeedShowShortVideoMainNormalIntro];
}

//获取主发布器入口是否已经被用户打开过
- (BOOL)normalMainIntrolHasClicked {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TTShortVideoMainIntroHasOpenedUserDefaulsKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:TTShortVideoMainIntroHasOpenedUserDefaulsKey];
    }
    return NO;
}

//设置小视频tab入口被用户打开过
- (void)setShortVideoTabIntroHasClicked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TTShortVideoTabIntroHasOpenedUserDefaulsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//获取小视频tab入口是否被用户打开过
- (BOOL)shortVideoTabIntroHasClicked {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TTShortVideoTabIntroHasOpenedUserDefaulsKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:TTShortVideoTabIntroHasOpenedUserDefaulsKey];
    }
    return NO;
}

//设置小视频红包已经被用户领取
- (void)setShortVideoRedpackHasGot {
    self.lastShowRedpackIntroView = [self needShowShortVideoRedpackIntro];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TTShortVideoRecorderRedpackGotUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateNeedShowShortVideoRedpackIntro];
}

//获取小视频红包是否已经被用户领取
- (BOOL)shortVideoRedpackHasGot {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TTShortVideoRecorderRedpackGotUserDefaultsKey]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:TTShortVideoRecorderRedpackGotUserDefaultsKey];
    }
    return NO;
}

//清空红包领取状态，在video_auth接口获取成功时清空，准备下一轮红包
- (void)clearShortVideoRedpackHasGot {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TTShortVideoRecorderRedpackGotUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//是否需要展示小视频tab右上角普通引导
- (BOOL)needShowShortVideoTabNormalIntro {
    //春节小视频红包活动优先级最高
//    if ([self shouldShowSpringShortVideoRedPackGuide]) {
//        return NO;
//    }
//
    if ([self normalShortVideoTabIntroEnabled]) {
        return ![self shortVideoTabIntroHasClicked];
    }
    return NO;
}

//是否需要展示主发布器普通引导
- (BOOL)needShowShortVideoMainNormalIntro {
    //春节小视频红包活动优先级最高
//    if ([self shouldShowSpringShortVideoRedPackGuide]) {
//        return NO;
//    }
    
    if ([self normalMainIntroEnabled]) {
        return ![self normalMainIntrolHasClicked];
    }
    
    return NO;
}

//更新普通引导，发出通知
- (void)updateNeedShowShortVideoMainNormalIntro {
    BOOL needShow = [self needShowShortVideoMainNormalIntro];
    if (self.lastShowNormalIntroView != needShow) {
        self.lastShowNormalIntroView = needShow;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTNotificationNameNormalIntroUpdated object:nil];
    }
}

//是否需要展示红包引导
- (BOOL)needShowShortVideoRedpackIntro {
    //春节活动优先级最高
//    if ([self shouldShowSpringShortVideoRedPackGuide]) {
//        return NO;
//    }
    if (!isEmptyString([self redpackModel].token) && !isEmptyString([self redpackModel].redpack_id) && [[self redpackModel].redpack_id integerValue] > 0) {
        if ([self shortVideoRedpackHasGot]) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}

//更新红包引导，发出通知
- (void)updateNeedShowShortVideoRedpackIntro {
    BOOL needShow = [self needShowShortVideoRedpackIntro];
    if (self.lastShowRedpackIntroView != needShow) {
        self.lastShowRedpackIntroView = needShow;
        [[NSNotificationCenter defaultCenter] postNotificationName:kTTNotificationNameRedpackIntroUpdated object:nil];
    }
}

//点击进入小视频拜年红包
- (void)didEnterSpringShortVideoRedPackEntrance {
//    NSUInteger times = [self enterSpringShortVideoRedPackEntranceTimes];
//    [[NSUserDefaults standardUserDefaults] setInteger:times+1 forKey:TTShortVideoSpringRedpackTimesDefaultsKey];
}

//- (NSInteger)enterSpringShortVideoRedPackEntranceTimes {
//    NSInteger times = [[NSUserDefaults standardUserDefaults] integerForKey:TTShortVideoSpringRedpackTimesDefaultsKey];
//    return times;
//}

//设置小视频春节活动入口是否展示成红包样式
//1.进入小视频红包入口次数小于上限 2.未领取成功过红包 3.日期在有效期内 4.贴纸开关打开 5.贴纸资源ready
- (BOOL)shouldShowSpringShortVideoRedPackGuide {
    return NO;
}

@end
