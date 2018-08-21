//
//  TTRedPacketViewController.m
//  Article
//
//  Created by lipeilun on 2017/7/12.
//
//

#import "TTRedPacketViewController.h"
#import "TTRedPacketViewWrapper.h"
#import "SSNavigationBar.h"
#import "UIViewController+NavigationBarStyle.h"
#import <TTAccountManager.h>
#import "TTRedPacketManager.h"
#import "FRRequestManager.h"
#import <TTFollowManager.h>
#import <TTThemed/TTThemeManager.h>
#import "FRApiModel.h"


@interface TTRedPacketViewController () <CAAnimationDelegate>
@property (nonatomic, strong) TTRedPacketViewWrapper *innerWrapper;                         //红包视图
@property (nonatomic, strong) SSThemedView *customNaviBar;                                  //自定义导航栏
@property (nonatomic, strong) SSThemedView *redPacketInformationView;                       //红包结果视图
@property (nonatomic, strong) SSThemedLabel *nameLabel;                                     //姓名
@property (nonatomic, strong) SSThemedLabel *descriptionLabel;                              //红包描述
@property (nonatomic, strong) SSThemedLabel *moneyLabel;                                    //面值
@property (nonatomic, strong) SSThemedButton *withdrawButton;                               //提现
@property (nonatomic, strong) SSThemedButton *redPacketRuleButton;                          //红包规则
@property (nonatomic, strong) SSThemedLabel *hasFollowedLabel;                              //已关注
@property (nonatomic, strong) FRRedpackStructModel *redpacket;
@property (nonatomic, assign) TTRedPacketViewStyle style;
@property (nonatomic, strong) TTRedPacketTrackModel *trackModel;
@property (nonatomic, strong) FRRedpacketOpenResultStructModel *resultData;
@property (nonatomic, weak) UIViewController *fromController;
@property (nonatomic, strong) UIImageView *screenShotImageView;
@property (nonatomic, assign) BOOL expand;
@property (nonatomic, assign) UIStatusBarStyle originBarStyle;
@property (nonatomic, strong) UITapGestureRecognizer *bottomRecognier;
@end

@implementation TTRedPacketViewController

- (instancetype)initWithStyle:(TTRedPacketViewStyle)style
                    redpacket:(FRRedpackStructModel *)redpacket
                        track:(TTRedPacketTrackModel *)trackModel
               viewController:(UIViewController *)fromViewController {
    if (self = [super init]) {
        self.style = style;
        self.redpacket = redpacket;
        self.trackModel = trackModel;
        self.fromController = fromViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _innerWrapper = [[TTRedPacketViewWrapper alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds
                                                            style:self.style
                                                        redpacket:self.redpacket];
    _innerWrapper.delegate = self;
    _innerWrapper.hidden = YES;
    [self.view addSubview:_innerWrapper];
    
    self.ttHideNavigationBar = YES;
    
    self.originBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    self.customNaviBar = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 20.f, self.view.width, [TTDeviceUIUtils tt_newPadding:44])];
    self.customNaviBar.backgroundColor = [UIColor clearColor];
    self.customNaviBar.alpha = 0;
    [self.view addSubview:self.customNaviBar];
    
    [self setupCustomNavigationBar];
    [self setupRedPacketInformationView];
    [self.view addSubview:self.redPacketRuleButton];
    if (self.style != TTRedPacketViewStyleShortVideoBonus) {
        [self.view addSubview:self.hasFollowedLabel];
    }
    [self.view insertSubview:self.screenShotImageView belowSubview:self.innerWrapper];
    
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        self.screenShotImageView.hidden = NO;
        self.screenShotImageView.image = self.backingImage;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(customThemeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self expandRedPacket];
    });
}

- (void)ontaps:(id)sender {
    [self redPacketClickRules];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.originBarStyle;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([TTDeviceHelper OSVersionNumber] < 8.f)
        return;
    if (!self.screenShotImageView.hidden) {
        [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.screenShotImageView.alpha = 0;
        } completion:^(BOOL finished) {
            self.screenShotImageView.alpha = 1;
            self.screenShotImageView.hidden = YES;
        }];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGFloat topInset = MAX(20.f, self.view.tt_safeAreaInsets.top);
    self.customNaviBar.top = topInset;
}

- (void)customThemeChanged:(NSNotification *)notification {
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    self.hasFollowedLabel.attributedText = [self obtainBottomFollowText];
    [self.innerWrapper refreshUIForNight:([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupCustomNavigationBar {
    SSThemedButton *navbarLeftButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [navbarLeftButton setTitle:@"关闭" forState:UIControlStateNormal];
    navbarLeftButton.backgroundColor = [UIColor clearColor];
    navbarLeftButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    navbarLeftButton.titleColorThemeKey = kColorText12;
    [navbarLeftButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [navbarLeftButton sizeToFit];
    navbarLeftButton.origin = CGPointMake([TTDeviceUIUtils tt_newPadding:20], ((_customNaviBar.height) - (navbarLeftButton.height)) / 2);
    [self.customNaviBar addSubview:navbarLeftButton];
    
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake((self.view.width - [TTDeviceUIUtils tt_newPadding:200]) / 2, (_customNaviBar.height - [TTDeviceUIUtils tt_newPadding:24]) / 2, [TTDeviceUIUtils tt_newPadding:200], [TTDeviceUIUtils tt_newPadding:24])];
    titleLabel.text = @"爱看红包";
    titleLabel.textColorThemeKey = kColorText12;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
    [self.customNaviBar addSubview:titleLabel];
}

- (void)setupRedPacketInformationView {
    self.redPacketInformationView = [[SSThemedView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - [TTDeviceUIUtils tt_newPadding:240]) / 2, [TTDeviceUIUtils tt_newPadding:188], [TTDeviceUIUtils tt_newPadding:240], [TTDeviceUIUtils tt_newPadding:300])];
    [self.redPacketInformationView addSubview:self.nameLabel];
    [self.redPacketInformationView addSubview:self.descriptionLabel];
    [self.redPacketInformationView addSubview:self.moneyLabel];
    [self.redPacketInformationView addSubview:self.withdrawButton];
    self.redPacketInformationView.hidden = YES;
    self.redPacketInformationView.layer.zPosition = 1.2;
    self.redPacketInformationView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
    [self.view addSubview:self.redPacketInformationView];
}

- (void)backButtonClicked {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCloseRedPackertNotification" object:nil userInfo:@{@"packet_opened":@(YES), @"packet_id":!isEmptyString(self.redpacket.redpack_id)?self.redpacket.redpack_id:@"0", @"packet_token":!isEmptyString(self.redpacket.token)?self.redpacket.token:@"0"}];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [TTRedPacketManager sharedManager].isShowingRedpacketView = NO;
}

- (void)expandRedPacket {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.innerWrapper.hidden = NO;
    self.innerWrapper.containerView.layer.affineTransform = CGAffineTransformMakeScale(0.01, 0.01);
    [CATransaction commit];
    
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.innerWrapper.containerView.transform = CGAffineTransformMakeScale(1, 1);
                     }
                     completion:nil];
    
    [UIView animateWithDuration:0.15 animations:^{
        self.innerWrapper.backgroundView.alpha = 0.4;
    }];
}

- (void)showRedPacketDetail {
    if ([TTDeviceHelper OSVersionNumber] < 8.f)
        self.screenShotImageView.hidden = YES;
    
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    
    self.redPacketInformationView.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        self.innerWrapper.backgroundView.alpha = 0;
        self.customNaviBar.alpha = 1;
    } completion:^(BOOL finished) {
        self.redPacketRuleButton.hidden = NO;
        self.hasFollowedLabel.hidden = NO;
        [self.innerWrapper.backgroundView removeFromSuperview];
    }];
    
    CABasicAnimation *informationAnimation = [CABasicAnimation animation];
    informationAnimation.keyPath = @"transform.scale";
    informationAnimation.toValue = [NSNumber numberWithFloat:1];
    informationAnimation.duration = 0.7;
    informationAnimation.fillMode = kCAFillModeForwards;
    informationAnimation.removedOnCompletion = NO;
    informationAnimation.delegate = self;
    informationAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.14 :1 :0.34 :1];
    [self.redPacketInformationView.layer addAnimation:informationAnimation forKey:@"informationAnim"];
    [self.innerWrapper openRedPacketAnimationBegin];
}

- (void)checkUserLoginState {
    [TTAccountLoginManager showLoginAlertWithTitle:@"登录爱看领取红包"
                                            source:@"follow_red_button"
                                       inSuperView:self.navigationController.view
                                        completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                                            if (type == TTAccountAlertCompletionEventTypeDone) {
                                                //不要想太多，这里登录成功
                                                [TTRedPacketManager trackRedPacketPresent:self.trackModel actionType:@"login_success"];
                                                [self requestOpenRedPacketWithLogin:YES];
                                            } else if (type == TTAccountAlertCompletionEventTypeTip) {
                                                [TTAccountLoginManager presentLoginViewControllerFromVC:self
                                                                                                  title:@"登录爱看领取红包"
                                                                                                 source:@"follow_red_button"
                                                                                             completion:nil];
                                            }
                                        }];
}

- (void)showBackgroundImage {
    if ([TTDeviceHelper OSVersionNumber] < 8.f)
        return;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.fromController.view drawViewHierarchyInRect:self.fromController.view.bounds afterScreenUpdates:NO];
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.screenShotImageView.image = screenImage;
    self.screenShotImageView.hidden = NO;
}

- (void)requestOpenRedPacketWithLogin:(BOOL)login {
    if (![TTAccountManager isLogin]) {
        [self.innerWrapper resetOpenState];
        self.innerWrapper.openButton.enabled = YES;
        [self checkUserLoginState];
        return;
    }
    
    [TTRedPacketManager trackRedPacketPresent:self.trackModel actionType:@"open"];
    TTRequestModel *requestModel = nil;
    if (self.style == TTRedPacketViewStyleShortVideoBonus) {
        requestModel = [[FRUgcActivityVideoIntroRedpackV1OpenRequestModel alloc] init];
        ((FRUgcActivityVideoIntroRedpackV1OpenRequestModel *)requestModel).redpack_id = self.redpacket.redpack_id;
        ((FRUgcActivityVideoIntroRedpackV1OpenRequestModel *)requestModel).is_login_open = login ? @(1) : @(0);
        ((FRUgcActivityVideoIntroRedpackV1OpenRequestModel *)requestModel).token = self.redpacket.token;
    }
    else {
        requestModel = [[FRUgcActivityFollowRedpackV1OpenRequestModel alloc] init];
        ((FRUgcActivityFollowRedpackV1OpenRequestModel *)requestModel).redpack_id = self.redpacket.redpack_id;
        ((FRUgcActivityFollowRedpackV1OpenRequestModel *)requestModel).is_login_open = login ? @(1) : @(0);
        ((FRUgcActivityFollowRedpackV1OpenRequestModel *)requestModel).token = self.redpacket.token;
    }

    [[TTFollowManager sharedManager] tt_requestWrapperChangedSingleFollowStateModel:requestModel userId:self.redpacket.user_info.user_id actionType:FriendActionTypeFollow completion:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        FRRedpacketOpenResultStructModel *resultData = nil;
        if (self.style == TTRedPacketViewStyleShortVideoBonus) {
            FRUgcActivityVideoIntroRedpackV1OpenResponseModel* model = (FRUgcActivityVideoIntroRedpackV1OpenResponseModel *)responseModel;
            resultData = model.data;
        }
        else {
            FRUgcActivityFollowRedpackV1OpenResponseModel* model = (FRUgcActivityFollowRedpackV1OpenResponseModel *)responseModel;
            resultData = model.data;
        }
        
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTRedpackOpenedNotification
                                                                object:nil
                                                              userInfo:@{TTRedpackNotifyKeyStyle : @(self.style)}];
            self.resultData = resultData;
            NSInteger statusCode = [self.resultData.status_code integerValue];
            if (statusCode == 0) {
                //领取成功
                self.trackModel.money = [self.resultData.bonus.amount integerValue];
                [self.withdrawButton setTitle:self.resultData.bonus.show_tips.text forState:UIControlStateNormal];
                [self.redPacketRuleButton setTitle:self.resultData.footer.text forState:UIControlStateNormal];
                [self.redPacketRuleButton sizeToFit];
                self.redPacketRuleButton.frame = CGRectMake((self.view.width - self.redPacketRuleButton.width) / 2, self.view.height - [TTDeviceUIUtils tt_newPadding:60], self.redPacketRuleButton.width, [TTDeviceUIUtils tt_newPadding:20]);
                [TTRedPacketManager trackRedPacketPresent:self.trackModel actionType:@"success"];
                if ([[self.resultData.bonus.amount stringValue] length] > 0) {
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", [self.resultData.bonus.amount floatValue] / 100] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:48]]}];
                    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" 元" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]]}]];
                    self.moneyLabel.attributedText = attributedString;
                }
                //开始做红包形变
                self.expand = YES;
                [self showRedPacketDetail];
            } else if (statusCode == -1) {
                [self.innerWrapper resetOpenState];
                self.innerWrapper.openButton.enabled = YES;
                [self checkUserLoginState];
            } else if (statusCode == 1) {
                //手慢
                [TTRedPacketManager trackRedPacketPresent:self.trackModel actionType:@"fail_over"];
                [self.innerWrapper showRedPacketFail:self.resultData];
            } else {
                //达到上限
                [TTRedPacketManager trackRedPacketPresent:self.trackModel actionType:@"fail_limit"];
                [self.innerWrapper showRedPacketFail:self.resultData];
            }
        } else if ([error.domain isEqualToString:kTTNetworkServerErrorDomain]) {//业务造成的错误
            //请求错误
            [self.innerWrapper resetOpenState];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:[error.userInfo tt_stringValueForKey:@"description"]? :@"网络繁忙"
                                     indicatorImage:nil
                                        autoDismiss:YES
                                     dismissHandler:nil];
            self.innerWrapper.openButton.enabled = YES;
        } else {
            [self.innerWrapper resetOpenState];
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"网络出现问题，请稍后再试", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            self.innerWrapper.openButton.enabled = YES;
        }
    }];
}

#pragma mark - action

- (void)onClickWithDrawButton:(id)sender {
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.resultData.bonus.show_tips.url]];
}

- (void)onClickRedPacketRuleButton:(id)sender {
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.resultData.footer.url]];
}

- (void)bottomRecognierTap:(UITapGestureRecognizer *)gesture {
    [self redPacketClickAvatar];
}

#pragma mark - GET/SET

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:240], [TTDeviceUIUtils tt_newPadding:26])];
        _nameLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:19]];
        _nameLabel.textColorThemeKey = kColorText1;
        _nameLabel.text = self.redpacket.user_info.name;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (SSThemedLabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:4], [TTDeviceUIUtils tt_newPadding:240], [TTDeviceUIUtils tt_newPadding:44])];
        _descriptionLabel.numberOfLines = 2;
        _descriptionLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.textColorThemeKey = kColorText1;
        _descriptionLabel.text = self.redpacket.content;
        _descriptionLabel.verticalAlignment = ArticleVerticalAlignmentTop;
    }
    return _descriptionLabel;
}

- (SSThemedLabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, self.descriptionLabel.bottom + [TTDeviceUIUtils tt_newPadding:25], [TTDeviceUIUtils tt_newPadding:240], [TTDeviceUIUtils tt_newPadding:57])];
        _moneyLabel.textAlignment = NSTextAlignmentCenter;
        _moneyLabel.textColorThemeKey = kColorText1;
    }
    return _moneyLabel;
}

- (SSThemedButton *)withdrawButton {
    if (!_withdrawButton) {
        _withdrawButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _withdrawButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _withdrawButton.titleColorThemeKey = kColorText6;
        _withdrawButton.frame = CGRectMake(0, self.moneyLabel.bottom + [TTDeviceUIUtils tt_newPadding:12], [TTDeviceUIUtils tt_newPadding:240], [TTDeviceUIUtils tt_newPadding:20]);
        [_withdrawButton addTarget:self action:@selector(onClickWithDrawButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _withdrawButton;
}

- (SSThemedButton *)redPacketRuleButton {
    if (!_redPacketRuleButton) {
        _redPacketRuleButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _redPacketRuleButton.hidden = YES;
        _redPacketRuleButton.titleColorThemeKey = kColorText6;
        _redPacketRuleButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _redPacketRuleButton.frame = CGRectZero;
        [_redPacketRuleButton addTarget:self action:@selector(onClickRedPacketRuleButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _redPacketRuleButton;
}

- (SSThemedLabel *)hasFollowedLabel {
    if (!_hasFollowedLabel) {
        _hasFollowedLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, self.view.height - [TTDeviceUIUtils tt_newPadding:35], [TTDeviceUIUtils tt_newPadding:240], [TTDeviceUIUtils tt_newPadding:20])];
        _hasFollowedLabel.centerX = self.view.width / 2;
        _hasFollowedLabel.hidden = YES;
        _hasFollowedLabel.textAlignment = NSTextAlignmentCenter;
        _hasFollowedLabel.textColorThemeKey = kColorText1;
        
        _hasFollowedLabel.attributedText = [self obtainBottomFollowText];
        self.bottomRecognier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomRecognierTap:)];
        self.hasFollowedLabel.userInteractionEnabled = YES;
        [self.hasFollowedLabel addGestureRecognizer:self.bottomRecognier];
    }
    return _hasFollowedLabel;
}

- (UIImageView *)screenShotImageView {
    if (!_screenShotImageView) {
        _screenShotImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _screenShotImageView.hidden = YES;
    }
    return _screenShotImageView;
}

- (NSMutableAttributedString *)obtainBottomFollowText {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"已关注" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]], NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText1)}];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@", self.redpacket.user_info.name] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]], NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText6)}]];
    return attributedString;
}

#pragma mark - TTRedPacketViewWrapperDelegate

- (void)redPacketClickCloseButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCloseRedPackertNotification" object:nil userInfo:@{@"packet_opened":@(NO), @"packet_id":!isEmptyString(self.redpacket.redpack_id)?self.redpacket.redpack_id:@"0", @"packet_token":!isEmptyString(self.redpacket.token)?self.redpacket.token:@"0"}];
    [TTRedPacketManager sharedManager].isShowingRedpacketView = NO;
    [TTRedPacketManager trackRedPacketPresent:self.trackModel actionType:@"close"];
    [UIView animateWithDuration:0.1 animations:^{
        self.innerWrapper.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)redPacketClickOpenButton {
    [self requestOpenRedPacketWithLogin:NO];
}

- (void)redPacketClickRules {
    [self showBackgroundImage];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.resultData.footer.url]];
}

- (void)redPacketClickAvatar {
    if (self.expand) {
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.redpacket.user_info.schema]];
    }
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([anim isEqual:[self.redPacketInformationView.layer animationForKey:@"informationAnim"]]) {
        self.redPacketInformationView.layer.transform = CATransform3DIdentity;
    }
    [self.redPacketInformationView.layer removeAllAnimations];
}


@end
