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

@interface FHBaseViewController ()<TTRouteInitializeProtocol, UIViewControllerErrorHandler>

@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, assign) UIEdgeInsets emptyEdgeInsets;
@property (nonatomic, assign)   BOOL       isFirstViewDidAppear;
/* 需要移除之前的某个页面 */
@property (nonatomic, assign)   BOOL       needRemoveLastVC;// fh_needRemoveLastVC_key @(YES)
@property (nonatomic, copy)     NSArray       *needRemovedVCNameStringArrs; // 类名数组key：fh_needRemoveedVCNamesString_key

@end

@implementation FHBaseViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super init];
    if (self) {
        self.isFirstViewDidAppear = YES;
        self.needRemoveLastVC = NO;
        self.titleName = [paramObj.userInfo.allInfo objectForKey:VCTITLE_KEY];
        NSDictionary *tracer = paramObj.allParams[TRACER_KEY];
        if (paramObj.allParams[@"fh_needRemoveLastVC_key"]) {
            self.needRemoveLastVC = [paramObj.allParams[@"fh_needRemoveLastVC_key"] boolValue];
            self.needRemovedVCNameStringArrs = paramObj.allParams[@"fh_needRemoveedVCNamesString_key"];
        }
        if ([tracer isKindOfClass:[FHTracerModel class]]) {
            self.tracerModel = (FHTracerModel *)tracer;
            self.tracerDict = [NSMutableDictionary new];
            if (self.tracerModel.toDictionary) {
                [self.tracerDict addEntriesFromDictionary:self.tracerModel.toDictionary];
            }
        }else if([tracer isKindOfClass:[NSDictionary class]]){
            self.tracerDict = [NSMutableDictionary new];
            [self.tracerDict addEntriesFromDictionary:tracer];
            self.tracerModel = [FHTracerModel makerTracerModelWithDic:self.tracerDict];
        } else {
            self.tracerDict = [NSMutableDictionary new];
            self.tracerModel = [[FHTracerModel alloc] init];
        }
    }
    return self;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // push过来的页面默认状态栏是隐藏的
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
        if (@available(iOS 11.0 , *)) {
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
        if (@available(iOS 11.0 , *)) {
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
        _customNavBarView = [[FHNavBarView alloc] init];
        [self.view addSubview:_customNavBarView];
        _customNavBarView.title.text = self.titleName;
        [_customNavBarView mas_makeConstraints:^(MASConstraintMaker *maker) {
            if (@available(iOS 11.0 , *)) {
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
                    [reversedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop2) {
                        if ([NSStringFromClass([obj class]) isEqualToString:clsName]) {
                            if ([arrVCs containsObject:obj]) {
                                [arrVCs removeObject:obj];
                                hasChanged = YES;
                                *stop2 = YES;
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
