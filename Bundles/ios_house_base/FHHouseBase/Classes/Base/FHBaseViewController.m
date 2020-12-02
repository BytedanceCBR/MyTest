//
//  FHBaseViewController.m
//  Article
//
//  Created by 谷春晖 on 2018/10/24.
//

#import "FHBaseViewController.h"
#import "FHTracerModel.h"
#import "FHHouseBridgeManager.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTReachability.h"
#import "FHErrorView.h"
#import "UIViewAdditions.h"
#import "TTProjectLogicManager.h"
#import "FHIntroduceManager.h"
#import <FHIntroduceManager.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <ByteDanceKit/ByteDanceKit.h>
#import "UIImage+FIconFont.h"
#import <TTUIWidget/TTNavigationController.h>

@interface FHBaseViewController ()<TTRouteInitializeProtocol, UIViewControllerErrorHandler>

@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, assign) UIEdgeInsets emptyEdgeInsets;
@property (nonatomic, assign)   BOOL       isFirstViewDidAppear;
/* 需要移除之前的某个页面 */
@property (nonatomic, assign)   BOOL       needRemoveLastVC;// fh_needRemoveLastVC_key @(YES)
@property (nonatomic, copy)     NSArray       *needRemovedVCNameStringArrs; // 类名数组key：fh_needRemoveedVCNamesString_key


@property (nonatomic , strong) UIView *loadingView;

@end

@implementation FHBaseViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        self.isFirstViewDidAppear = YES;
        self.needRemoveLastVC = NO;
        self.isResetStatusBar = YES;
        self.ttDisableDragBack = NO;
//        self.ttDragBackLeftEdge = TTNavigationControllerDefaultSwapLeftEdge; //屏幕边缘左滑
        self.ttDragBackLeftEdge = 0; //全屏

        self.titleName = [paramObj.allParams objectForKey:VCTITLE_KEY];
        NSDictionary *tracer = paramObj.allParams[TRACER_KEY];
        if (paramObj.allParams[@"fh_needRemoveLastVC_key"]) {
            self.needRemoveLastVC = [paramObj.allParams[@"fh_needRemoveLastVC_key"] boolValue];
            self.needRemovedVCNameStringArrs = paramObj.allParams[@"fh_needRemoveedVCNamesString_key"];
        }
        if ([tracer isKindOfClass:[FHTracerModel class]]) {
            self.tracerModel = (FHTracerModel *)tracer;
        }else if([tracer isKindOfClass:[NSDictionary class]]){
            [self.tracerDict addEntriesFromDictionary:tracer];
            self.tracerModel = [FHTracerModel makerTracerModelWithDic:self.tracerDict];
        } else {
            self.tracerModel = [FHTracerModel makerTracerModelWithDic:paramObj.allParams];
        }
        [self complementTrackerDataIfNeeded:paramObj.allParams];
    }
    return self;
}

- (void)complementTrackerDataIfNeeded:(NSDictionary *)allParams {
    if (!allParams || ![allParams isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *(^shouldUpdateTrackValueIfNeed)(NSString *trackerKey, NSString *currentValue) = ^NSString *(NSString *trackerKey, NSString *currentValue) {
        //异常状态
        if (!trackerKey.length) {
            return currentValue;
        }
        NSString *trackerValue =  [allParams btd_stringValueForKey:trackerKey default:@""];
        //allParams 不包含通用埋点字段
        if (!trackerValue.length) {
            return currentValue;
        }
        //allParams 包含通用埋点字段， 并且tracerModel中为有值，赋值
        //或者传be_null 的时候也需要调换
        if (!currentValue.length || [currentValue isEqualToString:@"be_null"]) {
            return trackerValue;
        }
        return currentValue;
    };
    
    self.tracerModel.originFrom = shouldUpdateTrackValueIfNeed(@"origin_from", self.tracerModel.originFrom);

    self.tracerModel.elementFrom = shouldUpdateTrackValueIfNeed(@"element_from", self.tracerModel.elementFrom);
    
    self.tracerModel.enterFrom = shouldUpdateTrackValueIfNeed(@"enter_from", self.tracerModel.enterFrom);
    
    self.tracerModel.enterType = shouldUpdateTrackValueIfNeed(@"enter_type", self.tracerModel.enterType);
    
    self.tracerModel.categoryName = shouldUpdateTrackValueIfNeed(@"category_name", self.tracerModel.categoryName);
    
    self.tracerModel.searchId = shouldUpdateTrackValueIfNeed(@"search_id", self.tracerModel.searchId);
    
    self.tracerModel.originSearchId = shouldUpdateTrackValueIfNeed(@"origin_search_id", self.tracerModel.originSearchId);
    
    id logPb = allParams[@"log_pb"];
    if (logPb && [logPb isKindOfClass:[NSDictionary class]]) {
        self.tracerModel.logPb = (NSDictionary *)logPb;
    } else if (logPb && [logPb isKindOfClass:[NSString class]]){
        self.tracerModel.logPb = [(NSString *)logPb btd_jsonDictionary];
    }
    [self.tracerDict addEntriesFromDictionary:[self.tracerModel toDictionary]];
    
    NSString *report_params = allParams[@"report_params"];
    if (report_params && [report_params isKindOfClass:[NSString class]]) {
        NSDictionary *report_params_dic = [report_params btd_jsonDictionary];
        if (report_params_dic && report_params_dic.count) {
            [self.tracerDict addEntriesFromDictionary:report_params_dic];
        }
    }
}

-(void)initNavbar
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationBackButtonWithTarget:self action:@selector(goBack)]];
    UILabel *label = [self defaultTitleView];
    label.text = self.titleName;
    [label sizeToFit];
    // titleView以及leftBarButtonItem
    self.navigationItem.titleView = label;
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.ttHideNavigationBar = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (NSMutableDictionary *)tracerDict {
    if (!_tracerDict) {
        _tracerDict = [NSMutableDictionary dictionary];
    }
    return _tracerDict;
}

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    self.titleName = title;
    if ([self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
        titleLabel.text = title;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // push过来的页面默认状态栏是隐藏的
    UIApplication *application = [UIApplication sharedApplication];
    if(application.statusBarHidden && ![FHIntroduceManager sharedInstance].isShowing){
        [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
    
    if(application.statusBarStyle != UIStatusBarStyleDefault && self.isResetStatusBar){
        [application setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.ttHideNavigationBar = YES;
    self.isLoadingData = NO;
    self.navigationController.navigationBar.hidden = YES;
    [self _setupData];
}

- (void)addDefaultEmptyViewWithEdgeInsets:(UIEdgeInsets)emptyEdgeInsets {
    [self _setupEmptyView];
    self.emptyEdgeInsets = emptyEdgeInsets;
}

- (void)addDefaultEmptyViewFullScreen
{
    _emptyView = [[FHErrorView alloc] init];
    _emptyView.hidden = YES;
    [self.view addSubview:_emptyView];
    [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    __weak typeof(self) wself = self;
    _emptyView.retryBlock = ^{
        [wself retryLoadData];
    };
}

- (void)_setupEmptyView {
    _emptyView = [[FHErrorView alloc] init];
    _emptyView.hidden = YES;
    [self.view addSubview:_emptyView];
    [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 13.0, *)) {
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(44.f + [UIApplication sharedApplication].keyWindow.safeAreaInsets.top);
        } else if (@available(iOS 11.0 , *)) {
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(44.f + self.view.tt_safeAreaInsets.top);
        } else {
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(65);
        }
    }];
    __weak typeof(self) wself = self;
    _emptyView.retryBlock = ^{
        [wself retryLoadData];
    };
}

- (void)retryLoadData {
    // 重新加载数据
}

- (void)_setupData {
    _hasValidateData = NO;
    _emptyEdgeInsets = UIEdgeInsetsZero;
    _showenRetryButton = YES;
    _statusBarStyle = UIStatusBarStyleDefault;
}

- (void)setShowenRetryButton:(BOOL)showenRetryButton {
    _showenRetryButton = showenRetryButton;
    _emptyView.retryButton.hidden = !_showenRetryButton;
}

- (void)setEmptyEdgeInsets:(UIEdgeInsets)emptyEdgeInsets {
    _emptyEdgeInsets = emptyEdgeInsets;
    // 暂时只支持top和bottom的内边距
    CGFloat topInset = _emptyEdgeInsets.top;
    CGFloat bottomInset = _emptyEdgeInsets.bottom;
    [_emptyView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 13.0 , *)) {
            CGFloat appTopInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).offset(-bottomInset);
            make.top.mas_equalTo(self.view).offset(44.f + appTopInset + topInset);
        } else if (@available(iOS 11.0 , *)) {
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).offset(-bottomInset);
            make.top.mas_equalTo(self.view).offset(44.f + self.view.tt_safeAreaInsets.top + topInset);
        } else {
            make.left.right.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view).offset(-bottomInset);
            make.top.mas_equalTo(self.view).offset(65 + topInset);
        }
    }];
}

// 设置默认导航栏，子类可以实现自己的样式，不调用父类的setupNavbar，即可隐藏
- (void)setupDefaultNavbar {
    [self initNavbar];
}

- (void)setupDefaultNavBar:(BOOL)isDefault {
    if (_customNavBarView != NULL) {
        [_customNavBarView removeFromSuperview];
    }
    if (isDefault) {
        [self setupDefaultNavbar];
    } else {
        // 自定义NaviBar
        self.ttHideNavigationBar = YES;
        self.navigationController.navigationBar.hidden = YES;
        self.customNavBarView = [[FHNavBarView alloc] init];
        [self.customNavBarView.leftBtn setBackgroundImage:FHBackBlackImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:FHBackBlackImage forState:UIControlStateHighlighted];
        [self.view addSubview:_customNavBarView];
        _customNavBarView.title.text = self.titleName;
        [_customNavBarView mas_makeConstraints:^(MASConstraintMaker *maker) {
            if (@available(iOS 13.0 , *)) {
                CGFloat topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
                maker.left.right.top.mas_equalTo(self.view);
                maker.height.mas_equalTo(44.f + topInset);
            } else if (@available(iOS 11.0 , *)) {
                maker.left.right.top.mas_equalTo(self.view);
                maker.height.mas_equalTo(44.f + self.view.tt_safeAreaInsets.top);
            } else {
                maker.left.right.top.mas_equalTo(self.view);
                maker.height.mas_equalTo(65);
            }
        }];
        __weak typeof(self) wself = self;
        _customNavBarView.leftButtonBlock = ^{
            [wself goBack];
        };
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    if (_customNavBarView != NULL) {
        [self.view bringSubviewToFront:_customNavBarView];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _statusBarStyle;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.isFirstViewDidAppear && self.needRemoveLastVC && self.needRemovedVCNameStringArrs.count > 0) {
        self.isFirstViewDidAppear = NO;
        self.needRemoveLastVC = NO;
        if (self.navigationController && self.navigationController.viewControllers.count > 0) {
            __block BOOL hasChanged = NO;
            NSMutableArray *arrVCs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
            // 从后向前移除页面
            [self.needRemovedVCNameStringArrs enumerateObjectsUsingBlock:^(NSString *  _Nonnull clsName, NSUInteger idx, BOOL * _Nonnull stop1) {
                if (clsName.length > 0) {
                    NSArray *reversedArray = [[arrVCs reverseObjectEnumerator] allObjects];
                    [reversedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop2) {
                        if (index != 0) {
                            
                            if ([NSStringFromClass([obj class]) isEqualToString:clsName]) {
                                if ([arrVCs containsObject:obj]) {
                                    [arrVCs removeObject:obj];
                                    hasChanged = YES;
                                    *stop2 = YES;
                                }
                            }
                        }
                    }];
                }
            }];
            if (hasChanged) {
                self.navigationController.viewControllers = arrVCs;
            }
        }
    }
    self.isFirstViewDidAppear = NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)goBack
{
    UIViewController *popVC = [self.navigationController popViewControllerAnimated:YES];
    
    if (nil == popVC) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

-(NSString *)categoryName
{
    return @"be_null";
}

- (NSString *)fh_pageType {
    NSAssert(NO, @"子类需要重写才能使用这个方法");
    return NSStringFromClass(self.class);
}

- (NSString *)fh_originFrom {
    if (!self.tracerDict || ![self.tracerDict isKindOfClass:NSDictionary.class]) return @"be_null";
    return [self.tracerDict btd_objectForKey:UT_ORIGIN_FROM default:@"be_null"];
}
/**
 * 支持禁止Push跳转（与TopVC是同一个VC以及，参数相同的页面），默认是NO（走之前逻辑）
 * 当Push来了后，如果当前顶部VC与Push不是同一个或者参数不同（比如和不同的经纪人聊天），则新建页面
 * 用于判断页面是否是同一个页面
 */
- (BOOL)isSamePageAndParams:(NSURL *)openUrl {
    if (openUrl && [openUrl isKindOfClass:[NSURL class]]) {
        NSString *host = openUrl.host;
        if (host.length > 0) {
            NSString *result = [[TTProjectLogicManager sharedInstance_tt] logicStringForKey:host];
            if (result.length > 0) {
                Class cls = NSClassFromString(result);
                if ([cls isEqual:[self class]]) {
                    // 页面相同
                    NSURLComponents *components = [[NSURLComponents alloc] initWithString:openUrl.absoluteString];
                    NSMutableDictionary *queryParams = [NSMutableDictionary new];
                    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.name && obj.value) {
                            queryParams[obj.name] = obj.value;
                        }
                    }];
                    return [self isOpenUrlParamsSame:queryParams];
                }
            }
        }
    }
    return NO;
}
/**
 * 子类重载当前页面
 * 用于判断页面参数是否相同
 */
- (BOOL)isOpenUrlParamsSame:(NSDictionary *)queryParams {
    return NO;
}

-(UIView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectZero];
        _loadingView.backgroundColor = [UIColor whiteColor];
    }
    return _loadingView;
}

-(void)showLoading:(UIView *)inView
{
    [self showLoading:inView offset:CGPointZero];
}

-(void)showLoading:(UIView *)inView offset:(CGPoint)offset
{
    if (!inView) {
        inView = self.view;
    }
    [inView addSubview:self.loadingView];
    _loadingView.frame = inView.bounds;
    [inView addSubview:_loadingView];
}

-(void)hideLoading
{
    [_loadingView removeFromSuperview];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return _hasValidateData;
}

- (void)startLoading {
    [self tt_startUpdate];
}

- (void)endLoading {
    [self tt_endUpdataData];
}

- (void)setHasValidateData:(BOOL)hasValidateData {
    _hasValidateData = hasValidateData;
    [self endLoading];
}

@end

NSHashTable *wrap_weak(NSObject * obj)
{
    if (!obj) {
        return nil;
    }
    
    NSHashTable *table = [NSHashTable weakObjectsHashTable];
    [table addObject:obj];
    return table;
}
NSObject *unwrap_weak(NSHashTable *table)
{
    if([table isKindOfClass:[NSHashTable class]]){
        NSHashTable *t = (NSHashTable *)table;
        return [t anyObject];
    }
    return nil;
}



NSString *const TRACER_KEY = @"tracer";
NSString *const VCTITLE_KEY = @"title";
