//
//  TTSFRedpacketManager.m
//  Article
//
//  Created by chenjiesheng on 2017/12/1.
//

#import "TTSFRedpacketManager.h"
#import "TTSFNetworkManager.h"
#import <TTDialogDirector.h>
#import <TTNavigationController.h>
#import <TTRoute/TTRoute.h>
#import "TTSFRedPacketStorage.h"
#import "TTSFAccountHelper.h"
#import "TTSFBubbleTipManager.h"
#import "TTSFShareManager.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import <TTAccountSDK/TTAccountSDK.h>
#import <TTAccountNavigationController.h>
#import <TTInstallIDManager.h>
#import <TTURLUtils.h>
#import "TTSFResourcesManager.h"

static TTSFRedpacketManager *_manager = nil;

@implementation TTSFRedpacketManager

+ (void)registerRedPackageAction
{
    TTSFRedpacketManager *manager = [TTSFRedpacketManager sharedManager];
    [manager registerPostTinyRedPackageAction];
    [manager registerTinyRedPackageAction];
    [manager registerInviteNewUserRedPackageAction];
    [manager registerNewbeeRedPackageAction];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[TTSFRedpacketManager alloc] init];
    });
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldShowSunshineRedPacket = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applySunshineRedPacket) name:TTSFResourcesReadyForUseNotification object:nil];
    }
    return self;
}

#pragma mark - 展示红包封皮

// 麻将红包
- (void)showMahjongWinnerRedpacketWith:(TTSponsorModel *)sponsor
                             shareInfo:(NSDictionary *)shareInfo
                                amount:(NSInteger)amount
                     disableTransition:(BOOL)disableTransition
{
    TTSFRedPacketViewModel *viewModel = [[TTSFRedPacketViewModel alloc] initWithSponsor:sponsor shareInfo:shareInfo amount:amount type:TTSFRedPacketViewTypeMahjongWinner token:nil];
    [self _showRedPacketWithViewModel:viewModel disableTransition:disableTransition dismissBlock:nil];
}

// 红包雨红包
- (void)showRainRedpacketWithToken:(NSString *)token
                         timeStamp:(int64_t)timeStamp
                            amount:(NSInteger)amount
                         sponsorID:(NSNumber *)sponsorID
                         shareInfo:(NSDictionary *)shareInfo
                 disableTransition:(BOOL)disableTransition
                      dismissBlock:(RPDetailDismissBlock)dismissBlock
{
    [TTSFRedPackageConfig sponsorModelWithID:sponsorID completionBlock:^(TTSponsorModel *model) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TTSFRedPacketViewModel *viewModel = [[TTSFRedPacketViewModel alloc] initWithSponsor:model shareInfo:shareInfo amount:amount type:TTSFRedPacketViewTypeRain token:token];
            viewModel.batch = @(timeStamp);
            [self _showRedPacketWithViewModel:viewModel disableTransition:disableTransition dismissBlock:dismissBlock];
        });
    }];
}

// 发布小视频红包
- (void)showPostTinyVideoRedpacketWithSponsor:(TTSponsorModel *)sponsor
                                    shareInfo:(NSDictionary *)shareInfo
                                       amount:(NSInteger)amount
                            disableTransition:(BOOL)disableTransition
{
    TTSFRedPacketViewModel *viewModel = [[TTSFRedPacketViewModel alloc] initWithSponsor:sponsor shareInfo:shareInfo amount:amount type:TTSFRedPacketViewTypePostTinyVideo token:nil];
    [self _showRedPacketWithViewModel:viewModel disableTransition:disableTransition dismissBlock:nil];
}

// 发布小视频红包token, 用于反作弊
static NSString *const TTSFPostTinyAntiSpamTokenKey = @"TTSFPostTinyAntiSpamTokenKey";
- (NSString *)postTinyAntiSpamToken
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TTSFPostTinyAntiSpamTokenKey]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:TTSFPostTinyAntiSpamTokenKey];
    } else {
        return nil;
    }
}

- (void)savePostTinyAntiSpamToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:TTSFPostTinyAntiSpamTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//- (void)updatePostTinyRedPacketStateByServer
//{
//    [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class fetchPostTinyRedPacketPath] params:nil method:@"POST" callback:^(NSError *error, id jsonObj) {
//        if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
//            TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
//            if (model.serviceErrNum == 100010) {
//                // 已领过
//                [[TTSFRedpacketManager sharedManager] setHasShownPostTinyRedPacket];
//            }
//        }
//    }];
//}

static NSString *const kStorePostTinyRedPacketKey = @"kStorePostTinyRedPacketKey";
- (BOOL)hasShownPostTinyRedPacket
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kStorePostTinyRedPacketKey];
}

- (void)setHasShownPostTinyRedPacket
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kStorePostTinyRedPacketKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 收到小视频红包
- (void)showTinyVideoRedpacketWithToken:(NSString *)token
                                 amount:(NSInteger)amount
                             senderInfo:(NSDictionary *)senderInfo
                              shareInfo:(NSDictionary *)shareInfo
                      disableTransition:(BOOL)disableTransition
{
    TTSFRedPacketViewModel *viewModel = [[TTSFRedPacketViewModel alloc] initWithSponsor:nil shareInfo:shareInfo amount:amount type:TTSFRedPacketViewTypeTinyVideo token:token];
    viewModel.senderUserInfo = [senderInfo copy];
    [self _showRedPacketWithViewModel:viewModel disableTransition:disableTransition dismissBlock:nil];
}

// 拉新红包。通过应用push，点击直接跳转红包详情页，disableTransition为YES
- (void)showInviteNewUserRedpacketWithToken:(NSString *)token
                                     amount:(NSInteger)amount
                                  shareInfo:(NSDictionary *)shareInfo
                          disableTransition:(BOOL)disableTransition
{
    TTSFRedPacketViewModel *viewModel = [[TTSFRedPacketViewModel alloc] initWithSponsor:nil shareInfo:shareInfo amount:amount type:TTSFRedPacketViewTypeInviteNewUser token:token];
    [self _showRedPacketWithViewModel:viewModel disableTransition:disableTransition dismissBlock:nil];
}

// 新人红包。有拆动作
- (void)showNewbeeRedpacketWithSponsor:(TTSponsorModel *)sponsor
                                amount:(NSInteger)amount
                                  type:(enum TTSFNewbeeRedPacketType)type
                                 token:(NSString *)token
                         invitorUserID:(NSString *)invitorUserID
                             shareInfo:(NSDictionary *)shareInfo
                     disableTransition:(BOOL)disableTransition
{
    TTSFRedPacketViewModel *viewModel = [[TTSFRedPacketViewModel alloc] initWithSponsor:sponsor shareInfo:shareInfo amount:amount type:TTSFRedPacketViewTypeNewbee token:token];
    viewModel.newbeeType = @(type);
    viewModel.invitorUserID = invitorUserID;
    [self _showRedPacketWithViewModel:viewModel disableTransition:disableTransition dismissBlock:nil];
}

- (void)showSunshineRedpacketWithToken:(NSString *)token
                                amount:(NSInteger)amount
                     disableTransition:(BOOL)disableTransition
{
    TTSFRedPacketViewModel *viewModel = [[TTSFRedPacketViewModel alloc] initWithSponsor:nil shareInfo:nil amount:amount type:TTSFRedPacketViewTypeSunshine token:token];
    // 标志复位，防止app一直运行状态有误
    self.shouldShowSunshineRedPacket = NO;
    self.sunshineRedPacketToken = nil;
    [self _showRedPacketWithViewModel:viewModel disableTransition:disableTransition dismissBlock:nil];
}

#pragma mark - 拆红包

- (void)unpackRainRedPacketWithToken:(NSString *)token
                         withConcern:(BOOL)concern
                     completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                           failBlock:(TTSFUnpackRedPacketFailBlock)failBlock
{
    void (^UnpackRedPacket)() = ^() {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:token forKey:@"redpackage_token"];
        [params setValue:@([TTSFRedPackageConfig curRedPackageVersion]) forKey:@"rp_rain_version"];
        [params setValue:@(concern) forKey:@"follow"];
        [[TTSFNetworkManager sharedManager] requestForJSONWithURL:[NSString stringWithFormat:@"%@%@", [TTSFRedPackageConfig preferredHost], [self.class unpackRainRedPacketPath]] params:params method:@"POST" callback:^(NSError *error, id jsonObj) {
            if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                if (model.serviceErrNum) {
                    if (failBlock) {
                        NSString *errorMessage = isEmptyString(model.serviceErrDesc) ? @"当前游戏人数过多\n请稍后到\"我的-我的红包\"查看" : model.serviceErrDesc;
                        failBlock(errorMessage);
                    }
                    NSLog(@"service error %ld : %@", model.serviceErrNum, model.serviceErrDesc);
                } else {
                    NSDictionary *data = [model.dataDict copy];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        NSNumber *sponsorID = [data valueForKey:@"sponsor_id"];
//                        sponsorID = @(1);
                        if (completion) {
                            [TTSFRedPackageConfig sponsorModelWithID:sponsorID completionBlock:^(TTSponsorModel *model) {
                                completion(token, [data tt_integerValueForKey:@"redpackage_count"], model, [data tt_dictionaryValueForKey:@"share_data"], nil);
                            }];
                        }
                        // 红包拆成功后端可能也有问题，暂不清除，等请求我的红包后删除
//                        [TTSFRedPacketStorage removeRedPacketToken:token];
                    }
                }
            } else {
                if (failBlock) {
                    failBlock(@"当前网络不给力\n请稍后到\"我的-我的红包\"查看");
                }
                NSLog(@"network error %@", error.localizedDescription);
            }
        }];
    };
    
    if (tta_IsLogin()) {
        UnpackRedPacket();
    } else {
        [TTSFAccountHelper presentLoginViewControllerFromVC:nil loginScene:TTSFNeedLoginSceneRedPacket source:@"sf_red_packet" completionBlock:^{
            UnpackRedPacket();
        } failBlock:^{
            if (failBlock) {
                failBlock(nil);
            }
        }];
    }
}

- (void)unpackTinyPacketWithToken:(NSString *)token
                  completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                        failBlock:(TTSFUnpackRedPacketFailBlock)failBlock
{
    void (^UnpackRedPacket)() = ^() {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:token forKey:@"redpackage_token"];
        [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class unpackTinyRedPacketPath] params:params method:@"POST" callback:^(NSError *error, id jsonObj) {
            if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                if (model.serviceErrNum) {
                    if (failBlock) {
                        failBlock(model.serviceErrDesc);
                    }
//                    if (model.serviceErrNum == 100009) {
//                        if (failBlock) {
//                            failBlock(@"来晚了，红包被领走了");
//                        }
//                    } else {
//                        if (failBlock) {
//                            failBlock(@"当前服务有问题\n请稍后到\"我的-新春红包\"查看");
//                        }
//                    }
                    
                    NSLog(@"service error %ld : %@", model.serviceErrNum, model.serviceErrDesc);
                } else {
                    NSDictionary *data = [model.dataDict copy];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        if (completion) {
                            NSInteger amount = [data tt_integerValueForKey:@"amount"];
                            NSDictionary *shareInfo = [data tt_dictionaryValueForKey:@"share_info"];
                            NSDictionary *userInfo = [data tt_dictionaryValueForKey:@"user_info"];
                            completion(token, amount, nil, shareInfo, userInfo);
                        }
                    }
                }
            } else {
                if (failBlock) {
                    failBlock(@"当前网络不给力\n请稍后到\"我的-我的红包\"查看");
                }
                NSLog(@"network error %@", error.localizedDescription);
            }
        }];
    };
    
    if (tta_IsLogin()) {
        UnpackRedPacket();
    } else {
        [TTSFAccountHelper presentLoginViewControllerFromVC:nil loginScene:TTSFNeedLoginSceneShortVideo source:@"sf_red_packet" completionBlock:^{
            UnpackRedPacket();
        } failBlock:^{
            if (failBlock) {
                failBlock(nil);
            }
        }];
    }
}

- (void)unpackInviteNewUserPacketWithToken:(NSString *)token completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion failBlock:(TTSFUnpackRedPacketFailBlock)failBlock
{
    void (^UnpackRedPacket)() = ^() {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:token forKey:@"redpackage_token"];
        [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class unpackInviteNewUserPacketPath] params:params method:@"POST" callback:^(NSError *error, id jsonObj) {
            if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                if (model.serviceErrNum) {
                    if (failBlock) {
                        failBlock(model.serviceErrDesc);
                    }
                    NSLog(@"service error %ld : %@", model.serviceErrNum, model.serviceErrDesc);
                } else {
                    NSDictionary *data = [model.dataDict copy];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        if (completion) {
                            NSInteger amount = [data tt_integerValueForKey:@"amount"];
                            NSDictionary *shareInfo = [data tt_dictionaryValueForKey:@"share_info"];
                            completion(token, amount, nil, shareInfo, nil);
                        }
                    }
                }
            } else {
                if (failBlock) {
                    failBlock(@"当前网络不给力\n请稍后到\"我的-我的红包\"查看");
                }
                NSLog(@"network error %@", error.localizedDescription);
            }
        }];
    };
    
    if (tta_IsLogin()) {
        UnpackRedPacket();
    } else {
        [TTSFAccountHelper presentLoginViewControllerFromVC:nil loginScene:TTSFNeedLoginSceneInviteNew source:@"sf_red_packet" completionBlock:^{
            UnpackRedPacket();
        } failBlock:^{
            if (failBlock) {
                failBlock(nil);
            }
        }];
    }
}

- (void)unpackNewBeeRedPacketWithType:(enum TTSFNewbeeRedPacketType)type
                                token:(NSString *)token
                        invitorUserID:(NSString *)invitorUserID
                      completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                            failBlock:(TTSFUnpackRedPacketFailBlock)failBlock
{
    void (^UnpackRedPacket)() = ^() {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:token forKey:@"redpackage_token"];
        [params setValue:@(type) forKey:@"newbee_type"];
        [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class unpackNewbeeRedPacketPath] params:params method:@"POST" callback:^(NSError *error, id jsonObj) {
            if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                if (model.serviceErrNum) {
                    if (failBlock) {
                        failBlock(model.serviceErrDesc);
                    }
                    NSLog(@"service error %ld : %@", model.serviceErrNum, model.serviceErrDesc);
                } else {
                    NSDictionary *data = [model.dataDict copy];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        BOOL rpGot = [model.dataDict tt_boolValueForKey:@"is_get"];
                        // 是否有新人红包
                        if (rpGot) {
                            if (completion) {
                                NSInteger amount = [data tt_integerValueForKey:@"amount"];
                                NSDictionary *shareInfo = [data tt_dictionaryValueForKey:@"share_info"];
                                completion(token, amount, nil, shareInfo, nil);
                            }
                        } else {
                            if (failBlock) {
                                failBlock(@"您已经领取过红包");
                            }
                        }
                    }
                }
            } else {
                if (failBlock) {
                    failBlock(@"当前网络不给力\n请稍后到\"我的-我的红包\"查看");
                }
                NSLog(@"network error %@", error.localizedDescription);
            }
        }];
    };
    
    if (type == TTSFNewbeeRedPacketTypeWX) {
        BOOL hasWechatLoginInfo = NO;
        for (TTAccountPlatformEntity * entity in [TTAccount sharedAccount].user.connects) {
            TTAccountAuthType accountAuthType = TTAccountGetPlatformTypeByName(entity.platform);
            if (accountAuthType == TTAccountAuthTypeWeChat) {
                hasWechatLoginInfo = YES;
            }
        }
        if (hasWechatLoginInfo && tta_IsLogin()) {
            UnpackRedPacket();
        } else {
            // 直接去微信登录
            [TTAccount requestLoginForPlatform:TTAccountAuthTypeWeChat completion:^(BOOL success, NSError *error) {
                if (success && !error) {
                    UnpackRedPacket();
                } else {
                    if (failBlock) {
                        failBlock(nil);
                    }
                }
            }];
        }
    } else {
        if (tta_IsLogin()) {
            UnpackRedPacket();
        } else {
            [TTSFAccountHelper presentLoginViewControllerFromVC:nil loginScene:TTSFNeedLoginSceneInviteNew source:@"sf_red_packet" completionBlock:^{
                UnpackRedPacket();
            } failBlock:^{
                if (failBlock) {
                    failBlock(nil);
                }
            }];
        }
    }
}

- (void)unpackSunshineRedPacketWithToken:(NSString *)token
                         completionBlock:(TTSFUnpackRedPacketSuccessBlock)completion
                               failBlock:(TTSFUnpackRedPacketFailBlock)failBlock
{
    void (^UnpackRedPacket)() = ^() {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:token forKey:@"redpackage_token"];
        [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class unpackSunshineRedPacketPath] params:params method:@"POST" callback:^(NSError *error, id jsonObj) {
            if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                if (model.serviceErrNum) {
                    if (failBlock) {
                        failBlock(model.serviceErrDesc);
                    }
                    NSLog(@"service error %ld : %@", model.serviceErrNum, model.serviceErrDesc);
                } else {
                    NSDictionary *data = [model.dataDict copy];
                    if ([data isKindOfClass:[NSDictionary class]]) {
                        if (completion) {
                            NSInteger amount = [data tt_integerValueForKey:@"amount"];
                            completion(token, amount, nil, nil, nil);
                        }
                    }
                }
            } else {
                if (failBlock) {
                    failBlock(@"当前网络不给力\n请稍后到\"我的-我的红包\"查看");
                }
                NSLog(@"network error %@", error.localizedDescription);
            }
        }];
    };
    
    if (tta_IsLogin()) {
        UnpackRedPacket();
    } else {
        [TTSFAccountHelper presentLoginViewControllerFromVC:nil loginScene:TTSFNeedLoginSceneSunshine source:@"sf_red_packet" completionBlock:^{
            UnpackRedPacket();
        } failBlock:^{
            if (failBlock) {
                failBlock(nil);
            }
        }];
    }
}

static NSString *const kStoreNewbeeRedPacketKey = @"kStoreNewbeeRedPacketKey";
- (BOOL)hasShownNewBeeRedPacket
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kStoreNewbeeRedPacketKey]) {
        return NO;
    } else {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kStoreNewbeeRedPacketKey];
    }
}

- (void)setHasShownNewBeeRedPacket
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kStoreNewbeeRedPacketKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *const kStoreSunshineRedPacketKey = @"kStoreSunshineRedPacketKey";
- (BOOL)hasApplySunshineRedPacket
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kStoreSunshineRedPacketKey]) {
        return NO;
    } else {
        return [[NSUserDefaults standardUserDefaults] boolForKey:kStoreSunshineRedPacketKey];
    }
}

- (void)setHasApplySunshineRedPacket
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kStoreSunshineRedPacketKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (enum TTSpringActivityEventType)trackEventTypeWithRpViewType:(TTSFRedPacketViewType)viewType newbeeType:(TTSFNewbeeRedPacketType)newbeeType
{
    switch (viewType) {
        case TTSFRedPacketViewTypeMahjongWinner:
            return TTSpringActivityEventTypeMahjong;
        case TTSFRedPacketViewTypeRain:
            return TTSpringActivityEventTypeGame;
        case TTSFRedPacketViewTypePostTinyVideo:
        case TTSFRedPacketViewTypeTinyVideo:
            return TTSpringActivityEventTypeShortVideo;
        case TTSFRedPacketViewTypeInviteNewUser:
            return TTSpringActivityEventTypeNewUsers;
        case TTSFRedPacketViewTypeNewbee: {
            if (newbeeType == TTSFNewbeeRedPacketTypeWX) {
                return TTSpringActivityEventTypeNewUsers;
            } else {
                return TTSpringActivityEventTypeAll;
            }
        }
        case TTSFRedPacketViewTypeSunshine:
            return TTSpringActivityEventTypeSunshine;
        default:
            return TTSpringActivityEventTypeAll;
    }
}

//#pragma mark - 关注
//
- (void)followRedPacketPGCAccountWithMID:(NSString *)mid
{
    NSString *followURLPath = @"/relation/follow/";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:mid forKey:@"user_id"];
    [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:followURLPath params:params method:@"POST" callback:^(NSError *error, id jsonObj) {
        if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
            TTSFResponseModel *response = (TTSFResponseModel *)jsonObj;
            if (response.serviceErrNum == 0) {
//                NSLog(@"关注成功");
            }
        }
    }];
}

#pragma mark - private

- (void)_showRedPacketWithViewModel:(TTSFRedPacketViewModel *)viewModel disableTransition:(BOOL)disableTransition dismissBlock:(RPDetailDismissBlock)dismissBlock
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TTForceToDismissLoginViewControllerNotification object:nil];
    CGFloat delay = [sf_present_login_topvc() isKindOfClass: [TTAccountNavigationController class]] ? .3f : 0.f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TTSFRedPacketViewController *viewController = [[TTSFRedPacketViewController alloc] initWithViewModel:viewModel disableTransition:disableTransition dismissBlock:dismissBlock];
        if (disableTransition) {
            // 找到真正的顶层nav
            UINavigationController *correctNav = nil;
            if ([sf_present_login_topvc() isKindOfClass:[UINavigationController class]]) {
                correctNav = (UINavigationController *)sf_present_login_topvc();
            }
            
            if (!correctNav) {
                correctNav = sf_present_login_topvc().navigationController;
            }
            
            if (!correctNav) {
                correctNav = [TTUIResponderHelper correctTopNavigationControllerFor:[TTUIResponderHelper correctTopmostViewController]];
            }
            [correctNav pushViewController:viewController animated:YES];
            
        } else {
            
            TTNavigationController *navController = [[TTNavigationController alloc] initWithRootViewController:viewController];
            navController.view.backgroundColor = [UIColor clearColor];
            navController.definesPresentationContext = YES;
            navController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            
            [TTDialogDirector enqueueShowDialog:navController withPriority:TTDialogPriorityHigh shouldShowMe:nil showMe:^(id  _Nonnull dialogInst) {
                [sf_present_login_topvc() presentViewController:navController animated:NO completion:nil];
                
                [TTSFTracker event:@"red_env_show" eventType:[self trackEventTypeWithRpViewType:viewModel.viewType newbeeType:viewModel.newbeeType.integerValue] params:({
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [dict setValue:viewModel.sponsor.ID forKey:@"sponsor_id"];
                    [dict copy];
                })];
            } hideForcedlyMe:^(id  _Nonnull dialogInst) {
                [navController dismissViewControllerAnimated:NO completion:^{
                    
                    if (dismissBlock) {
                        dismissBlock();
                    }
                    
                    [TTDialogDirector dequeueDialog:navController];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTTSFReceivedRedPackageNotification object:self userInfo:nil];
                    
                }];
            }];
        }
    });
}

+ (NSString *)unpackRainRedPacketPath
{
    //拆红包雨红包
    return @"festival/redpackage/unpack/";
}

+ (NSString *)unpackTinyRedPacketPath
{
    //拆红包雨红包
    return @"/redpackage/video_visit/open/";
}

+ (NSString *)unpackInviteNewUserPacketPath
{
    //拆拉新红包
    return @"/redpackage/inviter/open/";
}

+ (NSString *)unpackNewbeeRedPacketPath
{
    //拆新人红包
    return @"/redpackage/fresh/open/";
}

+ (NSString *)unpackSunshineRedPacketPath
{
    //拆阳光普照红包
    return @"/redpackage/sunshine/open/";
}

+ (NSString *)fetchPostTinyRedPacketPath
{
    //获取首次发布小视频红包
    return @"/festival_video/redpackage/";
}

+ (NSString *)fetchTinyRedPacketPath
{
    //获取分享小视频红包
    return @"/redpackage/small_video/visit/";
}

+ (NSString *)applyNewbeeRedPacketPath
{
    //获取分享小视频红包
    return @"/redpackage/fresh/apply/";
}

+ (NSString *)applySunshineRedPacketPath
{
    //获取分享小视频红包
    return @"/redpackage/sunshine/get/";
}

// 首次发布小视频红包, 发布器完成后进。干掉微头条分享
- (void)registerPostTinyRedPackageAction
{
    [TTSFShareManager registerOpenURLAction:^(NSDictionary *params) {
        if (![self hasShownPostTinyRedPacket]) {
            // 需要把发布后云端返回的小视频gid传过来
            NSString *uniqueID = [params tt_stringValueForKey:@"id"];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:uniqueID forKey:@"id"];
            [dict setValue:[self postTinyAntiSpamToken] forKey:@"token"];
            [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class fetchPostTinyRedPacketPath] params:dict method:@"POST" callback:^(NSError *error, id jsonObj) {
                if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                    TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                    if (model.serviceErrNum == 0 && model.dataDict.count > 0) {
                        NSDictionary *shareInfo = [[model.dataDict tt_dictionaryValueForKey:@"share_info"] copy];
                        NSInteger amout = [model.dataDict tt_intValueForKey:@"amount"];
                        NSError *error = nil;
                        TTSponsorModel *sponsor = [[TTSponsorModel alloc] initWithDictionary:[model.dataDict tt_dictionaryValueForKey:@"sponsor_info"] error:&error];
                        if (sponsor == nil || error) {
                            NSNumber *sponsorID = [[model.dataDict tt_dictionaryValueForKey:@"sponsor_info"] valueForKey:@"id"];
                            if (sponsorID.integerValue) {
                                [TTSFRedPackageConfig sponsorModelWithID:sponsorID completionBlock:^(TTSponsorModel *model) {
                                    [[TTSFRedpacketManager sharedManager] showPostTinyVideoRedpacketWithSponsor:model shareInfo:shareInfo amount:amout disableTransition:NO];
                                }];
                            } else {
                                [[TTSFRedpacketManager sharedManager] showPostTinyVideoRedpacketWithSponsor:nil shareInfo:shareInfo amount:amout disableTransition:NO];
                            }
                        } else {
                            [[TTSFRedpacketManager sharedManager] showPostTinyVideoRedpacketWithSponsor:sponsor shareInfo:shareInfo amount:amout disableTransition:NO];
                        }
                    } else {
//                        if (model.serviceErrNum == 100010) {
//                            [[TTSFRedpacketManager sharedManager] setHasShownPostTinyRedPacket];
//                            showIndicatorWithTip(@"您已领过红包");
//                        }
                        showIndicatorWithTip(model.serviceErrDesc);
                        [self setHasShownPostTinyRedPacket];
                    }
                } else {
                    // 网络错误 do nothing
                }
            }];
        }
    } withIdentifier:@"post_tiny_rp"];
}

// 小视频拜年红包。外部链接或剪贴板识别进
- (void)registerTinyRedPackageAction
{    
    [TTSFShareManager registerOpenURLAction:^(NSDictionary *params) {
        // 带入小视频vid
        NSString *vid = [params tt_stringValueForKey:@"gid"];
        NSString *token = [params tt_stringValueForKey:@"token"];
        NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
        [requestParams setValue:vid forKey:@"gid"];
        [requestParams setValue:token forKey:@"token"];
        [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class fetchTinyRedPacketPath] params:requestParams method:@"POST" callback:^(NSError *error, id jsonObj) {
            if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                if (model.serviceErrNum == 0 && model.dataDict.count > 0) {
                    NSDictionary *userInfo = [[model.dataDict tt_dictionaryValueForKey:@"user_info"] copy];
                    NSString *token = [model.dataDict tt_stringValueForKey:@"redpackage_token"];
                    if (!isEmptyString(token)) {
                        [[TTSFRedpacketManager sharedManager] showTinyVideoRedpacketWithToken:token amount:0 senderInfo:userInfo shareInfo:nil disableTransition:NO];
                    }
                } else {
//                    if (model.serviceErrNum == 200010) {
//                        showIndicatorWithTip(@"你已领过红包");
//                    } else {
//                        showIndicatorWithTip(@"来晚了，红包被领走了");
//                    }
                    showIndicatorWithTip(model.serviceErrDesc);
                }
            }
        }];
    } withIdentifier:@"share_tiny_rp"];
}

// 拉新红包，推送进
- (void)registerInviteNewUserRedPackageAction
{
    //  格式 sslocal://target?action=invite_user_rp&token=100
    [TTSFShareManager registerOpenURLAction:^(NSDictionary *params) {
        NSString *token = [params tt_stringValueForKey:@"token"];
        [[TTSFRedpacketManager sharedManager] showInviteNewUserRedpacketWithToken:token amount:0 shareInfo:nil disableTransition:NO];
    } withIdentifier:@"invite_user_rp"];
}

// 新人红包
- (void)registerNewbeeRedPackageAction
{
    //  格式 sslocal://target?action=newbee_rp&uid=12345  带邀请人uid
    [TTSFShareManager registerOpenURLAction:^(NSDictionary *params) {
        if (![self hasShownNewBeeRedPacket]) {
            TTSFNewbeeRedPacketType type = [params tt_intValueForKey:@"type"];
            NSString *invitorUserID = [params tt_stringValueForKey:@"uid"];
            [self applyNewbeeRedPacketWithType:type invitorUserID:invitorUserID];
        }
    } withIdentifier:@"newbee_rp"];
}

- (void)applyNewbeeRedPacketWithType:(TTSFNewbeeRedPacketType)type
                       invitorUserID:(NSString *)invitorUserID
{
    // 取到did后申请红包, did通过通用参数携带，不直接写入params
    [[TTInstallIDManager sharedInstance] setDidRegisterBlock:^(NSString *deviceID, NSString *installID) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
            [requestParams setValue:@(type) forKey:@"redpackage_type"];
            //需要传uid，防止用户不立刻拆红包
            [requestParams setValue:invitorUserID forKey:@"user_id"];
            [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class applyNewbeeRedPacketPath] params:requestParams method:@"GET" callback:^(NSError *error, id jsonObj) {
                if (![self hasShownNewBeeRedPacket]) {
                    if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                        TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                        if (model.serviceErrNum == 0 && model.dataDict.count > 0) {
                            BOOL isNewUser = [model.dataDict tt_boolValueForKey:@"is_fresh"];
                            if (isNewUser) {
                                NSString *token = [model.dataDict tt_stringValueForKey:@"redpackage_token"];
                                [[TTSFRedpacketManager sharedManager] showNewbeeRedpacketWithSponsor:nil amount:0 type:type token:token invitorUserID:invitorUserID shareInfo:nil disableTransition:NO];
                            } else {
                                if (type == TTSFNewbeeRedPacketTypeWX) {
                                    // 后端下发的url直接带old_user=1
                                    NSString *activityURLString = [model.dataDict tt_stringValueForKey:@"activity_url"];
                                    NSURL *h5URL = [TTURLUtils URLWithString:activityURLString];
                                    if ([[TTRoute sharedRoute] canOpenURL:h5URL]) {
                                        [[TTRoute sharedRoute] openURLByPushViewController:h5URL];
                                    }
                                }
                            }
                            
                            // 申请新人红包后本地记录，无论是否成功。下次不再请求
                            [self setHasShownNewBeeRedPacket];
                        }
                    }
                }
            }];
        });
    }];
}

- (void)applySunshineRedPacket
{
    if (![self hasApplySunshineRedPacket]) {
        [[TTInstallIDManager sharedInstance] setDidRegisterBlock:^(NSString *deviceID, NSString *installID) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TTSFNetworkManager sharedManager] requestForJSONWithURLPath:[self.class applySunshineRedPacketPath] params:nil method:@"GET" callback:^(NSError *error, id jsonObj) {
                    if (![self hasApplySunshineRedPacket]) {
                        if (!error && [jsonObj isKindOfClass:[TTSFResponseModel class]]) {
                            TTSFResponseModel *model = (TTSFResponseModel *)jsonObj;
                            if (model.serviceErrNum == 0 && model.dataDict.count > 0) {
                                NSString *token = [model.dataDict tt_stringValueForKey:@"redpackage_token"];
                                if (!isEmptyString(token)) {
                                    self.sunshineRedPacketToken = [token copy];
                                    self.shouldShowSunshineRedPacket = YES;
                                } else {
                                    self.shouldShowSunshineRedPacket = NO;
                                }
                            }
                        }
                        
                        // 本地标记。下次不再请求
                        [self setHasApplySunshineRedPacket];
                    }
                }];
            });
        }];
    }
}

@end
