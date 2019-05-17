//
//  TTContactsRedPacketViewController.m
//  Article
//
//  Created by Jiyee Sheng on 8/1/17.
//
//

#import "TTContactsRedPacketViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTContactsRedPacketView.h"
#import "TTAccountAlertView.h"
#import "TTAccountLoginAlert.h"
#import "TTAccountManager.h"
#import "TTRedPacketDetailBaseView.h"
#import "TTContactsRedPacketDetailView.h"
#import "TTContactsRecommendUserTableViewCell.h"
#import "TTNetworkManager.h"
#import "TTFollowNotifyServer.h"
#import "TTContactsUserDefaults.h"
#import "TTContactsRedPacketManager.h"
#import "FRRequestManager.h"
#import "FriendDataManager.h"
#import "TTRecommendRedpacketAction.h"
#import "TTContactsGuideManager.h"
#import <TTFollowManager.h>

@interface TTContactsRedPacketViewController () <TTRedPacketBaseViewDelegate>

@property (nonatomic, strong) SSThemedView *navigationBar;
@property (nonatomic, strong) TTContactsRedPacketView *redPacketView;
@property (nonatomic, strong) TTContactsRedPacketDetailView *redPacketDetailView;
@property (nonatomic, assign) UIStatusBarStyle originStatusBarStyle;
@property (nonatomic, strong) UIImageView *screenShotImageView;
@property (nonatomic, weak) UIViewController *fromViewController;

@property (nonatomic, strong) NSArray *contactUsers;

@property (nonatomic, assign) BOOL transitionAnimationDidFinished;
@property (nonatomic, strong) TTContactsRedPacketParam *params;
@property (nonatomic, assign) TTContactsRedPacketViewControllerType type;
@property (nonatomic, copy) NSDictionary *trackDict;

@property (nonatomic, strong) TTRedPacketDetailBaseViewModel *viewModel;
@end

@implementation TTContactsRedPacketViewController

- (instancetype)initWithContactUsers:(NSArray *)contactUsers
                  fromViewController:(UIViewController *)fromViewController
                                type:(TTContactsRedPacketViewControllerType)type
                           viewModel:(TTRedPacketDetailBaseViewModel *)viewModel
                         extraParams:(NSDictionary *)extraParams {
    if (self = [super init]) {
        self.fromViewController = fromViewController;
        self.params = [TTContactsRedPacketParam paramWithDict:extraParams];
        self.trackDict = extraParams;
        self.contactUsers = contactUsers;
        self.type = type;
        self.viewModel = viewModel;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ttHideNavigationBar = YES;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    self.originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;

    self.redPacketDetailView = [[TTContactsRedPacketDetailView alloc] initWithFrame:self.view.bounds];
    [self.redPacketDetailView setDefaultAvatar:self.params.redpacketIconUrl];
    self.redPacketDetailView.hidden = YES;
    self.redPacketDetailView.fromPush = self.fromPush;
    [self.view addSubview:self.redPacketDetailView];

    self.redPacketView = [[TTContactsRedPacketView alloc] initWithFrame:self.view.bounds type:self.type param:self.params];
    self.redPacketView.delegate = self;
    self.redPacketView.hidden = YES;
    self.redPacketView.contactUsers = self.contactUsers;
    [self.view addSubview:self.redPacketView];

    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        self.screenShotImageView.hidden = NO;
    }

    if (self.fromPush) {
        if ([self.navigationController isKindOfClass:[TTNavigationController class]]) {
            [(TTNavigationController *)self.navigationController panRecognizer].enabled = NO;
        }
        UIView *coverView = [UIView new];
        coverView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        coverView.frame = self.screenShotImageView.bounds;
        self.screenShotImageView.hidden = NO;
        self.screenShotImageView.image = self.backgroundImage;
        [self.screenShotImageView addSubview:coverView];
        self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
        [self.view insertSubview:self.screenShotImageView belowSubview:self.redPacketView];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];

    if (self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacket ||
        self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacketNoLogin) {
        //猛推人二期埋点
        [TTTrackerWrapper eventV3:@"red_button" params:@{
            @"position" : @"list",
            @"action_type" : @"show",
            @"source" : @"all_follow_card",
            @"category_name" : [self.trackDict tt_stringValueForKey:@"category_name"] ?: @""
        }];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startRedPacketTransformAnimation];
    });
}

- (void)startRedPacketTransformAnimation {
    UIColor *initColor = self.fromPush ? SSGetThemedColorWithKey(kColorBackground4) : [UIColor clearColor];

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.redPacketView.hidden = NO;
    self.view.backgroundColor = initColor;
    self.redPacketView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [CATransaction commit];

    if (!self.fromPush) {
        [UIView animateWithDuration:0.15 animations:^{
            self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        }];
    }

    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.redPacketView.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        return;
    }

    if (!self.screenShotImageView.hidden && !self.fromPush) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            self.screenShotImageView.hidden = YES;
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [UIApplication sharedApplication].statusBarStyle = self.originStatusBarStyle;
}

- (void)customThemeChanged:(NSNotification *)notification {
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkUserLoginState {
    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypePost
                                      source:@"upload_contact_redpacket"
                                 inSuperView:self.navigationController.view
                                  completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                      if (type == TTAccountAlertCompletionEventTypeDone) {
//                                          [TTRedPacketManager trackRedPacketPresent:self.trackModel actionType:@"login_success"];
                                          [self redPacketDidClickOpenRedPacketButton];
                                      } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                          [TTAccountManager presentQuickLoginFromVC:self
                                                                               type:TTAccountLoginDialogTitleTypeDefault
                                                                             source:@"upload_contact_redpacket"
                                                                         completion:nil];
                                      }
                                  }];
}

#pragma mark - TTRedPacketViewDelegate

- (void)redPacketDidClickCloseButton {

    if (self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacket ||
        self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacketNoLogin) {
        //猛推人二期埋点
        [TTTrackerWrapper eventV3:@"red_button" params:@{
            @"position" : @"list",
            @"action_type" : @"close",
            @"source" : @"all_follow_card",
            @"category_name" : [self.trackDict tt_stringValueForKey:@"category_name"] ?: @""
        }];
    } else {
        [TTTrackerWrapper eventV3:@"upload_contact_redpacket" params:@{@"action_type": @"close"}];
    }


    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCloseRedPackertNotification" object:nil userInfo:nil];

    
    if (self.fromPush) {
        if ([self.navigationController isKindOfClass:[TTNavigationController class]]) {
            [(TTNavigationController *)self.navigationController panRecognizer].enabled = YES;
        }
        [UIView animateWithDuration:0.1 animations:^{
            self.redPacketView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.navigationController popViewControllerAnimated:NO];
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.redPacketView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
    }
}

- (void)redPacketDidClickOpenRedPacketButton {
    if (self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacket ||
        self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacketNoLogin) {
        //猛推人二期埋点
        [TTTrackerWrapper eventV3:@"red_button" params:@{
            @"position" : @"list",
            @"action_type" : @"open",
            @"source" : @"all_follow_card",
            @"category_name" : [self.trackDict tt_stringValueForKey:@"category_name"] ?: @""
        }];
    } else {
        [TTTrackerWrapper eventV3:@"upload_contact_redpacket" params:@{@"action_type": @"open"}];
    }

    if (![TTAccountManager isLogin]) {
        [self.redPacketView stopLoadingAnimation];
        [self checkUserLoginState];
        return;
    }

    [self.redPacketView startLoadingAnimation];

    if (self.type == TTContactsRedPacketViewControllerTypeContactsRedpacket) {
        [self multiFollowSelectedContactUsers];
        [self openContactRedPacket];
    } else if (self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacketNoLogin) { // 未登录用户，登录之后，出红包，并执行关注动作
        [self openRecommendContactRedPacket];
    } else if (self.type == TTContactsRedPacketViewControllerTypeRecommendRedpacket) { // 已登录用户，由外部关注完成之后，内部来单独出红包，不再执行关注动作
        NSMutableArray *selectedUsers = [NSMutableArray arrayWithCapacity:self.contactUsers.count];
        for (TTRecommendUserModel *contactUser in self.contactUsers) {
            if (contactUser.selected) {
                contactUser.selectable = NO;
                [selectedUsers addObject:contactUser];
            }
        }

        [self.redPacketDetailView setContactUsers:selectedUsers.copy];
        [self.redPacketDetailView configWithViewModel:self.viewModel];
        [self.redPacketView performSelector:@selector(startTransitionAnimation) withObject:nil afterDelay:0.45];

        [TTTrackerWrapper eventV3:@"red_button" params:@{
            @"position" : @"list",
            @"action_type" : @"success",
            @"source" : @"all_follow_card",
            @"category_name" : [self.trackDict tt_stringValueForKey:@"category_name"] ?: @"",
            @"value" : @(self.viewModel.money.floatValue * 100)
        }];
    }
}

- (void)redPacketWillStartTransitionAnimation {
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);

    self.redPacketDetailView.hidden = NO;
    self.redPacketDetailView.navBar.hidden = YES;
    self.redPacketDetailView.curveView.hidden = YES;
}

- (void)redPacketDidStartTransitionAnimation {
    CABasicAnimation *transformAnimation = [CABasicAnimation animation];
    transformAnimation.keyPath = @"transform.scale";
    transformAnimation.fromValue = @0.5f;
    transformAnimation.toValue = @1.f;
    transformAnimation.duration = 0.7;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.14 :1 :0.34 :1];
    [self.redPacketDetailView.contentView.layer addAnimation:transformAnimation forKey:nil];
}

- (void)redPacketDidFinishTransitionAnimation {
    self.redPacketDetailView.navBar.hidden = NO;
    self.redPacketDetailView.curveView.hidden = NO;

    [self.redPacketView removeFromSuperview];

    self.transitionAnimationDidFinished = YES;
}

- (void)multiFollowSelectedContactUsers {
    NSMutableArray *userIds = [[NSMutableArray alloc] init];
    for (TTRecommendUserModel *contactUser in self.contactUsers) {
        if (contactUser.selected && contactUser.user_id) {
            [userIds addObject:contactUser.user_id];
        }
    }

    if (userIds.count == 0) {
        return;
    }
    NSString *to_user_list = [userIds componentsJoinedByString:@","];

    [[TTFollowManager sharedManager] multiFollowUserIdArray:userIds source:TTFollowNewSourceRedpacketViewFollow reason:0 completion:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        if (error) { // 错误情况下，提示关注成功，并后台重试一次
            [[TTFollowManager sharedManager] multiFollowUserIdArray:userIds source:TTFollowNewSourceRedpacketViewFollow reason:0 completion:nil];
            return;
        }
        
        FRUserRelationMfollowResponseModel *model = (FRUserRelationMfollowResponseModel *)responseModel;
        
        if (model.err_no.integerValue != 0) {
            [[TTFollowManager sharedManager] multiFollowUserIdArray:userIds source:TTFollowNewSourceRedpacketViewFollow reason:0 completion:nil];
        } else {
            NSString *followID = userIds.firstObject;
            if (isEmptyString(followID)) {
                followID = kFollowRefreshID;
            }
            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:followID actionType:TTFollowActionTypeFollow itemType:TTFollowItemTypeDefault userInfo:nil];
            
            NSMutableArray *selectedUsers = [NSMutableArray arrayWithCapacity:self.contactUsers.count];
            for (TTRecommendUserModel *contactUser in self.contactUsers) {
                if (contactUser.selected) {
                    contactUser.selectable = NO;
                    [selectedUsers addObject:contactUser];
                }
            }

            [TTTrackerWrapper eventV3:@"rt_follow" params:@{
                @"to_user_id_list": to_user_list ?: @"",
                @"follow_type": @"others",
                @"follow_num": @(userIds.count),
                @"source": @"upload_contact_redpacket",
                @"server_source": @1056,
            }];
            
            // 时机策略，动画执行完之后不再暂时
            if (!self.transitionAnimationDidFinished) {
                [self.redPacketDetailView setContactUsers:selectedUsers];
            }
        }
    }];
}

- (void)openContactRedPacket {
    FRUserRelationContactcheckResponseModel *checkResultModel = [[TTContactsGuideManager sharedManager] contactsCheckResultInUserDefaults];

    if (!checkResultModel) { // checkResultModel 无法解析
        return;
    }

    if (checkResultModel.data.redpack.status.integerValue != TTContactsRedPacketAvailable) { // 判断红包状态
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.redPacketView stopLoadingAnimation];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"领取失败" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        });

        return;
    }

    FRUgcActivityUploadContactRedpackV1OpenRequestModel *requestModel = [[FRUgcActivityUploadContactRedpackV1OpenRequestModel alloc] init];
    requestModel.redpack_id = checkResultModel.data.redpack.redpack_id;
    requestModel.token = checkResultModel.data.redpack.token;

    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (!error) {
            FRUgcActivityUploadContactRedpackV1OpenResponseModel *model = (FRUgcActivityUploadContactRedpackV1OpenResponseModel *) responseModel;

            if (model && model.err_no.integerValue == 0) {
                TTRedPacketDetailBaseViewModel *viewModel = [[TTRedPacketDetailBaseViewModel alloc] init];
                viewModel.userName = [[TTContactsUserDefaults dictionaryOfContactsRedPacketContents] stringValueForKey:@"redpack" defaultValue:@"好友红包"];
                viewModel.desc = nil;
                viewModel.money = [NSString stringWithFormat:@"%.2f", model.data.redpack_amount.floatValue / 100];
                viewModel.withdrawUrl = model.data.my_redpacks_url;

                [self.redPacketDetailView configWithViewModel:viewModel];
                [self.redPacketView performSelector:@selector(startTransitionAnimation) withObject:nil afterDelay:0.45];
            }
        } else if ([error.domain isEqualToString:kTTNetworkErrorDomain]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.redPacketView stopLoadingAnimation];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:[error.userInfo stringValueForKey:@"description" defaultValue:kNetworkConnectionErrorTipMessage]
                                         indicatorImage:nil
                                            autoDismiss:YES
                                         dismissHandler:nil];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.redPacketView stopLoadingAnimation];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"领取失败" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            });
        }
    }];
}

- (void)openRecommendContactRedPacket {
    NSMutableArray *userIdsArray = [NSMutableArray array];
    for (TTRecommendUserModel *model in self.contactUsers) {
        if (!isEmptyString(model.user_id) && model.selected) {
            [userIdsArray addObject:model.user_id];
        }
    }
    
    if (userIdsArray.count == 0) {
        return;
    }

    NSInteger rel_type = [self.trackDict tt_integerValueForKey:@"rel_type"];
    TTFollowNewSource server_source;
    if (rel_type == 2) {
        server_source = TTFollowNewSourceFeedRecommendStarsRedpacketCard;
    } else {
        server_source = TTFollowNewSourceFeedRecommendRedpacketCard;
    }

    FRUserRelationCredibleFriendsRequestModel *requestModel = [[FRUserRelationCredibleFriendsRequestModel alloc] init];
    requestModel.user_ids = [userIdsArray componentsJoinedByString:@","];
    requestModel.redpack_id = self.params.redpacketId;
    requestModel.token = self.params.redpacketToken;
    requestModel.rel_type = @(rel_type);

    [FRRequestManager requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (!error) {
            FRUserRelationCredibleFriendsResponseModel *model = (FRUserRelationCredibleFriendsResponseModel *) responseModel;

            if (model && [model.message isEqualToString:@"success"]) {
                TTRedPacketDetailBaseViewModel *viewModel = [[TTRedPacketDetailBaseViewModel alloc] init];
                viewModel.userName = self.params.redpacketIconText;
                viewModel.title = self.params.redpacketTitle;
                viewModel.avatar = self.params.redpacketIconUrl;
                viewModel.desc = model.data.redpack.sub_title;
                viewModel.money = [NSString stringWithFormat:@"%.2f", [model.data.redpack.amount floatValue] / 100];
                viewModel.withdrawUrl = model.data.redpack.schema;
                viewModel.listTitle = model.data.title;

                [self.redPacketDetailView configWithViewModel:viewModel];

                NSMutableArray *contactUsers = [NSMutableArray array];
                for (FRCommonUserStructModel *userModel in model.data.users) {
                    TTRecommendUserModel *newModel = [TTRecommendUserModel new];
                    newModel.user_id = userModel.info.user_id;
                    newModel.screen_name = userModel.info.name;
                    newModel.recommend_reason = userModel.info.desc;
                    newModel.mobile_name = userModel.info.desc;
                    newModel.avatar_url = userModel.info.avatar_url;
                    newModel.user_auth_info = userModel.info.user_auth_info;
                    newModel.selected = YES;
                    newModel.selectable = NO;
                    [contactUsers addObject:newModel];
                }

                NSString *followID = [contactUsers firstObject] ? [(TTRecommendUserModel *)[contactUsers firstObject] user_id] : kFollowRefreshID;
                [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:followID actionType:TTFollowActionTypeFollow itemType:TTFollowItemTypeDefault userInfo:nil];

                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:[self.trackDict tt_stringValueForKey:@"enter_from"] forKey:@"enter_from"];
                [dict setValue:[self.trackDict tt_stringValueForKey:@"category_name"] forKey:@"category_name"];
                [dict setValue:@(server_source) forKey:@"server_source"];
                [dict setValue:[self.trackDict tt_dictionaryValueForKey:@"log_pb"] forKey:@"log_pb"];
                [dict setValue:[self.trackDict tt_stringValueForKey:@"recommend_type"] forKey:@"recommend_type"];
                [dict setValue:requestModel.user_ids ?: @"" forKey:@"to_user_id_list"];
                [dict setValue:@"from_recommend" forKey:@"follow_type"];
                [dict setValue:@(userIdsArray.count) forKey:@"follow_num"];
                [dict setValue:@"all_follow_card" forKey:@"source"];
                [dict setValue:@([self.trackDict tt_integerValueForKey:@"head_image_num"]) forKey:@"head_image_num"];
                [dict setValue:@(1) forKey:@"is_redpacket"];
                [dict setValue:[self.trackDict tt_stringValueForKey:@"relation_type"] forKey:@"relation_type"];

                [TTTrackerWrapper eventV3:@"rt_follow" params:dict];

                if (self.fromPush) {
                    [self performSelector:@selector(backgroundTurnGrey) withObject:nil afterDelay:0.45];
                }

                [TTTrackerWrapper eventV3:@"red_button" params:@{
                    @"position" : @"list",
                    @"action_type" : @"success",
                    @"source" : @"all_follow_card",
                    @"category_name" : [self.trackDict tt_stringValueForKey:@"category_name"] ?: @"",
                    @"value" : model.data.redpack.amount
                }];

                [self.redPacketView performSelector:@selector(startTransitionAnimation) withObject:nil afterDelay:0.45];
                [self.redPacketDetailView setContactUsers:contactUsers.copy];

                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFollowAndGainMoneySuccessNotification object:nil userInfo:@{
                    @"show_label" : model.data.show_label ?: @"",
                    @"button_text" : model.data.button_text ?: @"",
                    @"button_schema" : model.data.button_schema ?: @"",
                }];
            }
        }else if ([error.domain isEqualToString:kTTNetworkServerDataFormatErrorDomain]) {
            if (!isEmptyString([error.userInfo tt_stringValueForKey:@"description"])) {
                [TTTrackerWrapper eventV3:@"red_button" params:@{
                    @"position" : @"list",
                    @"action_type" : @"fail_over",
                    @"source" : @"all_follow_card",
                    @"category_name" : [self.trackDict tt_stringValueForKey:@"category_name"] ?: @"",
                }];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.redPacketView stopLoadingAnimation];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:!isEmptyString([error.userInfo tt_stringValueForKey:@"description"])?[error.userInfo tt_stringValueForKey:@"description"]:@"手慢了, 红包已领完"
                                         indicatorImage:nil
                                            autoDismiss:YES
                                         dismissHandler:nil];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.redPacketView stopLoadingAnimation];
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"手慢了, 红包已领完" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            });
        }
    }];
}

- (void)backgroundTurnGrey {
    [self.screenShotImageView removeFromSuperview];
    UIView *coverView = [UIView new];
    coverView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    coverView.frame = self.screenShotImageView.bounds;
    [self.view insertSubview:coverView belowSubview:self.redPacketDetailView];
}

#pragma mark - setter and getter

- (UIImageView *)screenShotImageView {
    if (!_screenShotImageView) {
        _screenShotImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _screenShotImageView.hidden = YES;
    }

    return _screenShotImageView;
}

@end
