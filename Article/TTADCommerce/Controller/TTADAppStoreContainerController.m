//
//  TTADAppStoreContainerController.m
//  Article
//
//  Created by rongyingjie on 2017/11/17.
//

#import "TTADAppStoreContainerController.h"
#import <StoreKit/StoreKit.h>
#import "TTNavigationController.h"
#import "TTAnimatedImageView.h"
#import "TTAdAppDownloadManager.h"
#import "SSAppStore.h"
#import "TTImageView+TrafficSave.h"
#import "NSDictionary+TTAdditions.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+TTAdditions.h"
#import "TTADAppStoreContainerViewModel.h"
#import "UIViewController+Track.h"

#define kLeftMargin     10.f
#define kBottomMaskH    80
#define kDesLabelH      22

@interface TTADAppStoreContainerController ()

@property (nonatomic, strong) TTImageView *headImageView;
@property (nonatomic, strong) SKStoreProductViewController *skController;
@property (nonatomic, strong) TTAlphaThemedButton *backButton;
@property (nonatomic, strong) SSThemedLabel *desLabel;
@property (nonatomic, strong) TTADAppStoreContainerViewModel *viewModel;
@property (nonatomic, strong) SSThemedView *statusBarBackgrView;
@property (nonatomic, assign) BOOL ttv_statusBarHidden;

@end

@implementation TTADAppStoreContainerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithViewModel:nil];
}

- (instancetype)initWithViewModel:(TTADAppStoreContainerViewModel *)viewModel
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _viewModel = viewModel;
        _ttv_statusBarHidden = ![TTDeviceHelper isIPhoneXDevice];
        [self addNotification];
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self trySendCurrentPageStayTime];
}

#pragma mark -- Notification
- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewWillDisappear:) name:SKStoreProductViewWillDisappearKey object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:![TTDeviceHelper isIPhoneXDevice]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    self.statusBarBackgrView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.ttv_statusBarHidden ? 0 : self.view.tt_safeAreaInsets.top)];
    self.statusBarBackgrView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.statusBarBackgrView];
    
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;

    _headImageView = [TTADAppStoreContainerViewModel initalizeImageView];
    [self.view addSubview:_headImageView];

    [self buildBackButton];
    self.hidesBottomBarWhenPushed = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    __block CGFloat imageHeight = 0;
    CGFloat width = self.view.bounds.size.width;
    imageHeight = [self.viewModel imageHeight:width];
    WeakSelf;
    self.headImageView.frame = CGRectMake(0, topMargin, self.view.bounds.size.width, imageHeight);
    
    UIImage *topMaskImage = [[UIImage imageNamed:@"appstore_bottom_shadow"] resizableImageWithCapInsets:UIEdgeInsetsZero];
    UIImageView *_topMaskView = [[UIImageView alloc] initWithImage:topMaskImage];
    _topMaskView.frame = CGRectMake(0, imageHeight - kBottomMaskH + topMargin, self.view.bounds.size.width, kBottomMaskH);
    _topMaskView.hidden = [self.viewModel isHiddenDescription];
    [self.headImageView addSubview:_topMaskView];
    
    _desLabel = [TTADAppStoreContainerViewModel initializeDesLabel];
    _desLabel.frame = CGRectMake(0, imageHeight - kDesLabelH - 10 + topMargin, self.view.bounds.size.width, kDesLabelH);
    [self.headImageView addSubview:_desLabel];
    _desLabel.text = self.viewModel.surfaceDes;
    _desLabel.hidden = [self.viewModel isHiddenDescription];
    [self.headImageView setImageWithModelInTrafficSaveMode:self.viewModel.imageInfoModel
                                          placeholderImage:nil
                                                   success:^(UIImage *image, BOOL cached) {
                                                       StrongSelf;
                                                       if (!imageHeight) {
                                                           imageHeight = image.size.height / image.size.width * width;
                                                           self.headImageView.frame = CGRectMake(0, topMargin, width, imageHeight);
                                                       }
    }
                                                   failure:^(NSError *error) {
                                                       StrongSelf;
                                                       // 如果图片加载失败直接将appstore上移
                                                       self.viewModel.isImageLoadFailed = YES;
                                                       [self.backButton removeFromSuperview];
                                                   }];
    
    self.skController = [[TTAdAppDownloadManager sharedManager] SKViewControllerPreloadId:self.viewModel.itunesId
                                                                          dismissAnimated:NO
                                                                          completionBlock:^(BOOL result) {
        StrongSelf;
        self.viewModel.isAppStoreLoadFinish = YES;
        if (self.viewModel.isWaitTimeout) {
            [self animateAppStoreToTop];
        }
    }];
    
    [self.skController didMoveToParentViewController:self];
    self.skController.modalPresentationStyle = UIModalPresentationCustom;
    self.skController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.skController.providesPresentationContextTransitionStyle = YES;
    self.skController.definesPresentationContext = YES;
    BOOL animated = YES;
    if ([TTADAppStoreContainerViewModel systemlowThan9]) {
        animated = NO;
    }
    if (@available(iOS 11.0, *)){
        self.skController.view.hidden = YES;
    }
    [self presentViewController:self.skController animated:animated completion:^{
        StrongSelf;
        [self.skController.view.superview addSubview:_backButton];
        if (!self.viewModel.displayTime || self.viewModel.isImageLoadFailed) {
            imageHeight = 0;
            [self.backButton removeFromSuperview];
        }
        self.skController.view.frame = CGRectMake(0, imageHeight + topMargin, self.view.frame.size.width, self.view.frame.size.height - imageHeight - topMargin);
        if (@available(iOS 11.0, *)){
            self.skController.view.hidden = NO;
        }
    }];
    
    [self performSelector:@selector(loadFinish) withObject:nil afterDelay:self.viewModel.displayTime];
}

- (void)loadFinish {
    if (self.viewModel.isAppStoreLoadFinish) {
        [self animateAppStoreToTop];
    } else {
        self.viewModel.isWaitTimeout = YES;
    }
}

- (void)animateAppStoreToTop {
    CGFloat topMargin = [TTDeviceHelper isIPhoneXDevice] ? 44 : 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.skController.view.frame = CGRectMake(0, topMargin, self.view.frame.size.width, self.view.frame.size.height);
        [self.backButton removeFromSuperview];
    }];
    [[TTMonitor shareManager] trackService:@"ios_detail_pic_go_top" status:1 extra:nil];
}


- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    self.statusBarBackgrView.height = self.ttv_statusBarHidden ? 0 : self.view.tt_safeAreaInsets.top;
}

- (void)buildBackButton
{
    _backButton = [[TTAlphaThemedButton alloc] init];
    _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -12, -15, -36);

    NSString *imgName = [TTDeviceHelper isPadDevice] ? @"leftbackbutton_video_detais" : @"shadow_lefterback_titlebar";
    UIImage *image = [UIImage imageNamed:imgName];
    [_backButton setImage:image forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"shadow_lefterback_titlebar_press"] forState:UIControlStateHighlighted];
    [_backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _backButton.frame = CGRectMake(kLeftMargin, kLeftMargin + ([TTDeviceHelper isIPhoneXDevice] ? 44 : 0), image.size.width, image.size.height);
}

- (void)backButtonPressed:(id)sender {
    [[TTAdAppDownloadManager sharedManager] clearResource];
    [self.skController dismissViewControllerAnimated:NO completion:^{
        [self.navigationController popViewControllerAnimated:YES];        
    }];
}

- (void)skStoreViewWillDisappear:(NSNotification*)noti {
    if (self.skController == [noti object]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self trySendCurrentPageStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)trySendCurrentPageStayTime {
    if (self.ttTrackStartTime == 0) {//当前页面没有在展示过
        return;
    }
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration <= 200) {//低于200毫秒，忽略
        self.ttTrackStartTime = 0;
        [self tt_resetStayTime];
        return;
    }
    [self sendCurrentPageStayTime:duration];
    
    self.ttTrackStartTime = 0;
    [self tt_resetStayTime];
}

- (void)sendCurrentPageStayTime:(NSTimeInterval)duration {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.viewModel.itunesId forKey:@"itunes_id"];
    [dict setValue:self.viewModel.adId forKey:@"ad_id"];
    [dict setValue:self.viewModel.logExtra forKey:@"log_extra"];

    [[TTMonitor shareManager] trackService:@"ios_detail_pic_stay_page" value:@{@"value":@(duration)} extra:dict];
}

@end
