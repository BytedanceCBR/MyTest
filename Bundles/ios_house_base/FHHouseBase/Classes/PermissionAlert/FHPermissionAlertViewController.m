//
//  FHPermissionAlertViewController.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/12/31.
//

#import "FHPermissionAlertViewController.h"
#import <YYText/YYLabel.h>
#import <Masonry/Masonry.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <TTUIWidget/TTNavigationController.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "FHCommonDefines.h"
#import "FHURLSettings.h"
#import <TTRoute/TTRoute.h>
#import "FHEnvContext.h"
#import "FHUserTracker.h"

#define OUT_HOR_MARGIN     38
#define IN_HOR_MARGIN      20
#define IN_VER_MARGIN      30
#define CONTENT_TO_TITLE   8
#define CONFIRM_TO_CONTENT 20
#define CONFIRM_HEIGHT     40

@interface FHPermissionAlertViewController ()

@property(nonatomic , strong) UIImageView *bgImgView;
@property(nonatomic , strong) UIView *maskView;
@property(nonatomic , strong) UIView *containerView;
@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) YYLabel *contentLabel;
@property(nonatomic , strong) UIButton *confirmButton;
@property(nonatomic , assign) NSRange userRange;
@property(nonatomic , assign) NSRange privacyRange;
@property(nonatomic , strong) NSDate *enterDate;

@end

@implementation FHPermissionAlertViewController

+(void)show
{
    FHPermissionAlertViewController *controller = [[FHPermissionAlertViewController alloc]initWithNibName:nil bundle:nil];
    TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:controller];
    
    [UIApplication sharedApplication].delegate.window.rootViewController = navigationController;
    
    [[FHEnvContext sharedInstance] pauseForPermissionProtocol];
    
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.ttHideNavigationBar = YES;
        self.enterDate = [NSDate date];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUIs];
    [self addPopShowLog];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (UIImage *)getLaunchImage
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOr = @"Portrait";//垂直
    NSString *launchImage = nil;
    NSArray *launchImages =  [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    
    for (NSDictionary *dict in launchImages) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        
        if (CGSizeEqualToSize(viewSize, imageSize) && [viewOr isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    return [UIImage imageNamed:launchImage];
}

-(void)initUIs
{
    _bgImgView = [[UIImageView alloc] initWithImage:[self getLaunchImage]];
    
    _maskView = [[UIView alloc]init];
    _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    _containerView = [[UIView alloc] init];
    _containerView.layer.cornerRadius = 10;
    _containerView.layer.masksToBounds = YES;
    _containerView.backgroundColor = [UIColor themeWhite];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont themeFontSemibold:18];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.text = @"个人信息保护指引";
    
    _contentLabel = [[YYLabel alloc] init];
    _contentLabel.numberOfLines = 0;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.headIndent = 0;
    paragraphStyle.tailIndent = 0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"permission_tip" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSMutableAttributedString *attrContent = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:[UIFont themeFontRegular:14],NSForegroundColorAttributeName:[UIColor themeGray2],NSParagraphStyleAttributeName:paragraphStyle}];
    
    _userRange = [content rangeOfString:@"用户协议"];
    _privacyRange = [content rangeOfString:@"隐私政策"];
    
    NSDictionary *linkAttr = @{NSForegroundColorAttributeName:[UIColor themeGray1],NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),NSUnderlineColorAttributeName:[UIColor themeGray1]};
    [attrContent addAttributes:linkAttr range:_userRange];
    [attrContent addAttributes:linkAttr range:_privacyRange];

    
    
    __weak typeof(self) wself = self;
    _contentLabel.textTapAction = ^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        if (wself) {
            if (range.location >= wself.userRange.location && range.location+range.length <= wself.userRange.location+wself.userRange.length) {
                // 用户协议
                [wself showProtocolDetail:@"/f100/download/user_agreement.html" title:@"用户协议"];
            }else if (range.location >= wself.privacyRange.location && range.location+range.length <= wself.privacyRange.location+wself.privacyRange.length){
                    //隐私协议
                [wself showProtocolDetail:@"/f100/download/private_policy.html" title:@"隐私政策"];
            }
        }
    };
    
    _contentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 2*(OUT_HOR_MARGIN+IN_HOR_MARGIN);
    
    
    _contentLabel.attributedText = attrContent;
    
    _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmButton.layer.cornerRadius = 20;
    _confirmButton.layer.masksToBounds = YES;
    _confirmButton.backgroundColor = RGB(0xff, 0x96, 0x29);
    _confirmButton.titleLabel.font = [UIFont themeFontSemibold:18];
    [_confirmButton setTitleColor:[UIColor themeWhite] forState:UIControlStateNormal];
    
    [_confirmButton addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmButton setTitle:@"我知道了" forState:UIControlStateNormal];
    
    CGSize fitSize = [_contentLabel sizeThatFits:CGSizeMake(_contentLabel.preferredMaxLayoutWidth, CGFLOAT_MAX)];
    
    _contentLabel.bounds = CGRectMake(0, 0, fitSize.width, fitSize.height);
    
    [self.containerView addSubview:_titleLabel];
    [self.containerView addSubview:_contentLabel];
    [self.containerView addSubview:_confirmButton];
    
    [self.view addSubview:_bgImgView];
    [self.view addSubview:_maskView];
    [self.view addSubview:_containerView];
    
    [self initConstraints];
}

-(void)initConstraints
{
    [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(SCREEN_WIDTH - 2*OUT_HOR_MARGIN);
        make.height.mas_equalTo(153+ CGRectGetHeight(self.contentLabel.bounds));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(IN_HOR_MARGIN);
        make.right.mas_equalTo(-IN_HOR_MARGIN);
        make.top.mas_equalTo(IN_VER_MARGIN);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(CONTENT_TO_TITLE);
        make.height.mas_equalTo(CGRectGetHeight(self.contentLabel.bounds));
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(CONFIRM_HEIGHT);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(CONFIRM_TO_CONTENT);
    }];
}

-(void)showProtocolDetail:(NSString *)urlPath title:(NSString *)title
{
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@%@&title=%@&hide_more=1",[FHURLSettings baseURL],urlPath,title];
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

-(void)confirmAction:(id)sender
{
    [self addConfirmLog:YES];
    [[FHEnvContext sharedInstance] userConfirmedPermssionProtocol];
}

-(void)addPopShowLog
{
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = @"first_start";
    param[@"popup_name"] = @"privacy";
    
    TRACK_EVENT(@"popup_show", param);
}

-(void)addConfirmLog:(BOOL)confirm
{

    NSTimeInterval ts = [[NSDate date]timeIntervalSinceDate:self.enterDate]*1000;
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[UT_PAGE_TYPE] = @"first_start";
    param[@"popup_name"] = @"privacy";
    param[@"click_position"] = confirm?@"confirm":@"cancel";
    param[@"stay_time"] = [NSString stringWithFormat:@"%.0f",ts];
    
    TRACK_EVENT(@"popup_click", param);
    
}

- (BOOL)shouldAutorotate
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
