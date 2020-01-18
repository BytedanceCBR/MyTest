//
//  FHHomeMainViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHHomeMainViewController.h"
#import "FHHomeMainViewModel.h"
#import <TTDeviceHelper.h>
#import <FHEnvContext.h>
#import <FHMainApi.h>
#import <TTThemedAlertController.h>
#import <TTUIResponderHelper.h>
#import <FHUtils.h>
#import <TTSandBoxHelper.h>
#import "TTSandBoxHelper+House.h"
#import <TTAppUpdateHelper.h>
#import <TTInstallIDManager.h>
#import <CommonURLSetting.h>
#import <FHMinisdkManager.h>
#import "FHSpringHangView.h"

static NSString * const kFUGCPrefixStr = @"fugc";

@interface FHHomeMainViewController ()<TTAppUpdateHelperProtocol>
@property (nonatomic,strong)FHHomeMainViewModel *viewModel;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isHaveCheckUpgrage;
//春节活动运营位
@property (nonatomic, strong) FHSpringHangView *springView;

@end

@implementation FHHomeMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView]; //初始化视图
    [self initConstraints]; //更新约束
    [self initViewModel]; //创建viewModel
    [self initNotifications];//订阅通知
    [self initCityChangeSubscribe];//城市变化通知
    [self bindTopIndexChanged];//绑定头部选中index变化
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.isShowing = YES;

    //UGC地推包检查粘贴板
    [self checkPasteboard:NO];
    
    //如果是inhouse的，弹升级弹窗
    if ([TTSandBoxHelper isInHouseApp] && !self.isHaveCheckUpgrage) {
        //#if INHOUSE
        self.isHaveCheckUpgrage = YES;
        [self checkLocalTestUpgradeVersionAlert];
        //#endif
    }
    
    if ([[FHEnvContext sharedInstance] hasConfirmPermssionProtocol]) {
        //春节活动
        [[FHMinisdkManager sharedInstance] goSpring];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isShowing = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [FHEnvContext addTabUGCGuid];
    
    [TTSandBoxHelper setAppFirstLaunchForAd];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    //春节活动运营位
    if([FHEnvContext isSpringHangOpen]){
        [self addSpringView];
        [self.springView show:[FHEnvContext enterTabLogName]];
    }
}

- (void)addSpringView {
    if(!_springView){
        self.springView = [[FHSpringHangView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_springView];
        _springView.hidden = YES;
        
        CGFloat bottom = 49;
        if (@available(iOS 11.0 , *)) {
            bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
        }
        
        [_springView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(-bottom - 85);
            make.width.mas_equalTo(84);
            make.height.mas_equalTo(79);
            make.right.mas_equalTo(self.view).offset(-11);
        }];
    }
}

- (void)initView {
    self.view.backgroundColor = [UIColor themeHomeColor];
    self.isHaveCheckUpgrage = NO;

    self.topView = [[FHHomeMainTopView alloc] init];
    _topView.backgroundColor = [UIColor themeHomeColor];
    [self.view addSubview:_topView];
    
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    //2.初始化collectionView
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.allowsSelection = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = NO;
    _collectionView.scrollEnabled = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_collectionView];
}

- (void)initConstraints {
    
    CGFloat bottom = 49;
    if (@available(iOS 11.0, *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    CGFloat top = 0;
    CGFloat safeTop = 20;
    if (@available(iOS 11.0, *)) {
        safeTop = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
    }
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(44 + (safeTop == 0 ? 20 : safeTop));
    }];
    [self.topView setBackgroundColor:[UIColor themeHomeColor]];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
    [self.containerView setBackgroundColor:[UIColor themeHomeColor]];
    
    
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
}

- (void)initViewModel{
    self.viewModel = [[FHHomeMainViewModel alloc] initWithCollectionView:self.collectionView controller:self];
}

- (void)initNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainCollectionScrollBegin) name:@"FHHomeMainDidScrollBegin" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainCollectionScrollEnd) name:@"FHHomeMainDidScrollEnd" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)initCityChangeSubscribe
{
    BOOL isOpen = [FHEnvContext isCurrentCityNormalOpen];
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        FHConfigDataModel *xConfigDataModel = (FHConfigDataModel *)x;
        [FHEnvContext changeFindTabTitle];
        [FHEnvContext showRedPointForNoUgc];
        self.viewModel = [[FHHomeMainViewModel alloc] initWithCollectionView:self.collectionView controller:self];
    }];
}

- (void)_willEnterForeground:(NSNotification *)notification
{
    if (self.isShowing) {
        [self checkPasteboard:NO];
    }
    //春节活动运营位
    if([FHEnvContext isSpringHangOpen]){
        [self addSpringView];
        [self.springView show:[FHEnvContext enterTabLogName]];
    }
}

- (void)bindTopIndexChanged
{
    WeakSelf;
    self.topView.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if ([self.collectionView numberOfItemsInSection:0] > index && index != self.viewModel.currentIndex) {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
            
            [self.viewModel sendEnterCategory:(index == 0 ? FHHomeMainTraceTypeHouse : FHHomeMainTraceTypeFeed) enterType:FHHomeMainTraceEnterTypeClick];
            [self.viewModel sendStayCategory:(index == 0 ? FHHomeMainTraceTypeFeed : FHHomeMainTraceTypeHouse) enterType:FHHomeMainTraceEnterTypeClick];
        }
        
    };
}

- (void)changeTopStatusShowHouse:(BOOL)isShowHouse
{
    self.topView.segmentControl.hidden = isShowHouse;
    self.topView.houseSegmentControl.hidden = !isShowHouse;
    //房源显示时，禁止滑动
    if (isShowHouse) {
        self.collectionView.scrollEnabled = NO;
    }
}

- (void)changeTopSearchBtn:(BOOL)isShow {
    self.topView.searchBtn.hidden = !isShow;
}

#pragma mark notifications

- (void)mainCollectionScrollBegin{
    self.collectionView.scrollEnabled = NO;
}

- (void)mainCollectionScrollEnd{
    self.collectionView.scrollEnabled = YES;
}

#pragma mark UGC线上线下推广

- (void)checkPasteboard:(BOOL)isAutoJump
{
    __weak typeof(self) weakSelf = self;
    //据说主线程读剪切板会导致app卡死。。。改为子线程读
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSArray<NSString *> *pasteboardStrs = [pasteboard strings];
        
        if (([pasteboardStrs isKindOfClass:[NSArray class]] && pasteboardStrs.count > 0)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __block NSString *pasteboardStr = nil;
                [pasteboardStrs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj hasPrefix:kFUGCPrefixStr]) {
                        pasteboardStr = obj;
                        *stop = YES;
                    }
                }];
                
                if (pasteboardStr) {
                    NSString *base64Str = [pasteboardStr stringByReplacingOccurrencesOfString:kFUGCPrefixStr withString:@""];
                    
                    if (base64Str) {
                        [weakSelf requestSendUGCUserAD:base64Str];
                    }
                    //清空剪切板
                    NSMutableArray * strs = pasteboardStrs.mutableCopy;
                    [strs removeObject:pasteboardStr];
                    pasteboard.strings = strs;
                }
            });
        }
    });
}

- (void)requestSendUGCUserAD:(NSString *)requestStr
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:requestStr forKey:@"promotion_code"];
    __weak typeof(self) weakSelf = self;
    
    [FHMainApi uploadUGCPostPromotionparams:params completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
        
        if (!error && [result isKindOfClass:[NSDictionary class]]) {
            NSNumber *cityId = nil;
            NSString *alertStr = nil;
            NSNumber *inviteStatus = nil;
            NSDictionary *dataDict = result[@"data"];
            if ([dataDict isKindOfClass:[NSDictionary class]] && [dataDict[@"city_id"] isKindOfClass:[NSNumber class]]) {
                cityId = dataDict[@"city_id"];
            }
            
            if ([dataDict isKindOfClass:[NSDictionary class]] && [dataDict[@"tips"] isKindOfClass:[NSString class]]) {
                alertStr = dataDict[@"tips"];
            }
            
            if ([dataDict isKindOfClass:[NSDictionary class]] && [dataDict[@"invite_status"] isKindOfClass:[NSNumber class]]) {
                inviteStatus = dataDict[@"invite_status"];
            }
            
            if (alertStr && [inviteStatus isKindOfClass:[NSNumber class]] && [inviteStatus integerValue] != 2) {
                TTThemedAlertController *alertVC = [[TTThemedAlertController alloc] initWithTitle:alertStr message:nil preferredType:TTThemedAlertControllerTypeAlert];
                
                [alertVC addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                    
                }];
                
                UIViewController *topVC = [TTUIResponderHelper topmostViewController];
                if (topVC) {
                    [alertVC showFrom:topVC animated:YES];
                }
                
                [FHUtils setContent:@"1" forKey:kFHUGCPromotionUser];
            }
            
            if ([inviteStatus integerValue] != 2 && cityId) {
                [[FHEnvContext sharedInstance] switchCityConfigForUGCADUser:cityId];
            }
            //只保存数据
            [[FHEnvContext sharedInstance] checkUGCADUserIsLaunch:NO];
        }
    }];
}

#pragma mark 内测弹窗
- (void)checkLocalTestUpgradeVersionAlert
{
    //内测弹窗
    NSString * iidValue = [[TTInstallIDManager sharedInstance] installID];
    NSString * didValue = [[TTInstallIDManager sharedInstance] deviceID];
    NSString * channelValue = [[NSBundle mainBundle] infoDictionary][@"CHANNEL_NAME"];
    NSString * aidValue = @"1370";
    NSString * baseUrl = [CommonURLSetting baseURL];
    //    NSString * baseUrl = @"https://i.snssdk.com";
    
    [TTAppUpdateHelper sharedInstance].delegate = self;
    [[TTAppUpdateHelper sharedInstance] checkVersionUpdateWithInstallID:iidValue deviceID:didValue channel:channelValue aid:aidValue checkVersionBaseUrl:baseUrl correctVC:self completionBlock:^(__kindof UIView *view, NSError * _Nullable error) {
        [self.view addSubview:view];
    } updateBlock:^(BOOL isTestFlightUpdate, NSString *downloadUrl) {
        //        if (!downloadUrl) {
        //            return;
        //        }
        //        NSURL *url = [NSURL URLWithString:downloadUrl];
        //        [[UIApplication sharedApplication] openURL:url];
    } closeBlock:^{
        
    }];
}

/** 通知代理对象已获取到弹窗升级Title和具体升级内容,如果自定义弹窗，必须实现此方法
 @params title 弹窗升级title,ex: 6.x.x内测更新了..
 @param content 更新具体内容
 @params tipVersion 弹窗升级版本号,ex: 6.7.8
 @param downloadUrl TF弹窗下载地址
 */
//- (void)showUpdateTipTitle:(NSString *)title content:(NSString *)content tipVersion:(NSString *)tipVersion updateButtonText:(NSString *)text downloadUrl:(NSString *)downloadUrl error:(NSError * _Nullable)error
//{
//
//}

/** 通知代理对象弹窗需要remove
 *  代理对象需要在此方法里面将弹窗remove掉
 */
- (void)dismissTipView
{
    
}

///*
// 判断是否是内测包，当打包注入与头条主工程不一致时
// 可以实现自行进行判断，默认与头条判断方式相同
// 通过检查bundleID是否有inHouse字段进行判断
// */
- (BOOL)decideIsInhouseApp
{
    return YES;
}
//
///*
// 判断是否是LR包，当打包注入与头条主工程不一致时
// 可以实现自行进行判断，默认与头条判断方式相同
// 通过检查buildinfo字段进行判断
// 注意：只有lr包才弹内测弹窗，如果业务方没有
// lr包的概念，则返回YES即可
// */
- (BOOL)decideIsLrPackage
{
    return YES;
}
//
///*
// 判断是否需要上报用户did，主要用来上报用户是否安装tTestFlight
// 的情况，业务方可以自行通过开关控制
// */
//- (BOOL)decideShouldReportDid
//{
//
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
