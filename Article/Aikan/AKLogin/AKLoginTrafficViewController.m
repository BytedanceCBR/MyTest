//
//  AKLoginTrafficViewController.m
//  News
//
//  Created by chenjiesheng on 2018/3/15.
//

#import "AKHelper.h"
#import "AKUILayout.h"
#import "AKProfileLoginButton.h"
#import "AKLoginTrafficViewController.h"
#import "AKRedPacketOptionalLoginView.h"

#import <TTRoute.h>
#import <TTAccountManager.h>
#import <TTAlphaThemedButton.h>
#import "Bubble-Swift.h"
@interface AKLoginTrafficViewController () <AKRedPacketOptionalLoginViewDelegate>

@property (nonatomic, strong)UILabel                                *titleLabel;
@property (nonatomic, strong)TTAlphaThemedButton                    *closeButton;
@property (nonatomic, strong)AKRedPacketOptionalLoginView           *bottomLoginView;
@property (nonatomic, strong)AKProfileLoginButton                   *weixinLoginButton;
@property (nonatomic, strong)UILabel                                *weixinBottomDesLabel;
@property (nonatomic, strong)UIView                                 *weixinLoginRegion;
@property (nonatomic, copy)  CompleteBlock                          completeBlock;
@end

@implementation AKLoginTrafficViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(@"ak_login_traffic");
}

+ (TTRouteViewControllerOpenStyle)preferredRouteViewControllerOpenStyle
{
    return TTRouteViewControllerOpenStylePresent;
}

+ (void)presentLoginTrafficViewControllerWithCompleteBlock:(CompleteBlock)block
{
    QuickLoginVC *vc = [[QuickLoginVC alloc] initWithComplete:block];
    [ak_top_vc() presentViewController:vc animated:YES completion:nil];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.ttHideNavigationBar = YES;
    }
    return self;
}

- (instancetype)initWithCompleteBlock:(CompleteBlock)block
{
    self = [super init];
    if (self) {
        self.ttHideNavigationBar = YES;
        self.completeBlock = block;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createComponent];
    [self refreshUI];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (CGAffineTransformIsIdentity(self.view.transform)) {
        [self refreshUI];
    }
}

- (void)refreshUI
{
    self.closeButton.origin = CGPointMake(20, self.view.tt_safeAreaInsets.top + 20);
    self.titleLabel.centerX = self.view.width / 2;
    self.titleLabel.top = self.view.tt_safeAreaInsets.top + 48;
    
    self.weixinLoginRegion.centerX = self.view.width / 2;
    self.weixinLoginRegion.centerY = self.view.centerY - 60;
    
    self.bottomLoginView.centerX = self.view.centerX;
    self.bottomLoginView.bottom = self.view.height - self.view.tt_safeAreaInsets.bottom - 30;
}

- (void)createComponent
{
    [self createTitleAndCloseButton];
    [self createWeiXinLoginView];
    [self createBottomLoginView];
}

- (void)createTitleAndCloseButton
{
    _titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"登录";
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:24.f]];
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        label;
    });
    [self.view addSubview:_titleLabel];
    _closeButton = ({
        TTAlphaThemedButton *button = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        button.imageName = @"tt_titlebar_close";
        WeakSelf;
        [button addTarget:self withActionBlock:^{
            StrongSelf;
            if (self.completeBlock) {
                self.completeBlock(NO);
            }
            [self dismissSelf];
        } forControlEvent:UIControlEventTouchUpInside];
        button.size = CGSizeMake(20, 20);
        button.hitTestEdgeInsets = UIEdgeInsetsMake(-12, -12, -12, -12);
        button;
    });
    [self.view addSubview:self.closeButton];
}

- (void)createWeiXinLoginView
{
    _weixinLoginButton = ({
        AKProfileLoginButton *btn = [AKProfileLoginButton weiXinButtonWithTarget:self buttonClicked:^(AKProfileLoginButton * button) {
            [TTAccount requestLoginForPlatform:TTAccountAuthTypeWeChat completion:^(BOOL success, NSError *error) {
                if (self.completeBlock) {
                    self.completeBlock(success && !error);
                }
                if (success && !error) {
                    [self dismissSelfWithNoAnimation];
                }
            }];
        }];
        btn;
    });
    _weixinBottomDesLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"登录后可推荐更多你爱看的新闻";
        label.textColor = [UIColor colorWithHexString:@"999999"];
        label.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        label;
    });
    _weixinLoginRegion = [AKUILayout verticalLayoutViewWith:@[_weixinLoginButton,_weixinBottomDesLabel] padding:12 viewSize:nil];
    [self.view addSubview:_weixinLoginRegion];
}

- (void)createBottomLoginView
{
    _bottomLoginView = ({
        AKRedPacketOptionalLoginView *loginView = [[AKRedPacketOptionalLoginView alloc] initWithSupportPlatforms:@[PLATFORM_PHONE] delegate:self];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [loginView hiddenLoginButton];
        [CATransaction commit];
        loginView;
    });
    [self.view addSubview:_bottomLoginView];
}

- (void)dismissSelfWithNoAnimation
{
    if (self.navigationController.viewControllers.count>1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    } else {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
}

#pragma AKRedPacketOptionalLoginViewDelegate

- (void)loginButtonClicked:(UIButton *)button withPlatform:(NSString *)platform
{
    if ([platform isEqualToString:PLATFORM_PHONE]) {
        [TTAccountManager presentQuickLoginFromVC:self type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
            if (self.completeBlock) {
                self.completeBlock(state == TTAccountLoginStateLogin);
            }
            if (state == TTAccountLoginStateLogin) {
                [self dismissSelfWithNoAnimation];
            }
        }];
    }
}

@end
