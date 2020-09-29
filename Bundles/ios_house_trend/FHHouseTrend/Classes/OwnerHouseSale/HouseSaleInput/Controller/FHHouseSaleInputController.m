//
//  FHHouseSaleInputController.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleInputController.h"
#import "FHHouseSaleInputViewModel.h"
#import "FHHouseSaleInputView.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTBaseMacro.h"
#import "FHHouseSaleLeaveView.h"
#import "FHUserTracker.h"
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHHouseSaleInputController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property(nonatomic, strong) FHHouseSaleInputViewModel *viewModel;
@property(nonatomic ,strong) FHHouseSaleInputView *inputView;
@property(nonatomic ,strong) FHHouseSaleLeaveView *leaveView;

@end

@implementation FHHouseSaleInputController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _neighbourhoodId = paramObj.allParams[@"neighbourhood_id"];
        _neighbourhoodName = paramObj.allParams[@"neighbourhood_name"];
        
        NSString *report_params = paramObj.allParams[@"report_params"];
        if ([report_params isKindOfClass:[NSString class]]) {
            NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
            if (report_params_dic) {
                [self.tracerDict addEntriesFromDictionary:report_params_dic];
            }
        }
        
        self.tracerDict[@"page_type"] = @"house_publisher";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    self.ttDisableDragBack = YES;
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self addGoDetailLog];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshContentOffset:self.inputView.scrollView.contentOffset];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    WeakSelf;
    self.customNavBarView.leftButtonBlock = ^{
        StrongSelf;
        [self showLeaveView];
    };
}

- (void)showLeaveView {
    [self.view endEditing:YES];
    [self.view addSubview:self.leaveView];
    [self.leaveView show];
    [self addPopupShowLog];
}

- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat alpha = contentOffset.y / 50;
    if(alpha > 1){
        alpha = 1;
    }
    if (alpha > 0) {
        self.customNavBarView.title.text = @"在线卖房";
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:FHBackBlackImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:FHBackBlackImage forState:UIControlStateHighlighted];
    }else {
        self.customNavBarView.title.text = @"";
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:FHBackWhiteImage forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:FHBackWhiteImage forState:UIControlStateHighlighted];
    }
    [self.customNavBarView refreshAlpha:alpha];
    
    if (contentOffset.y > 0) {
        self.ttStatusBarStyle = UIStatusBarStyleDefault;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }else {
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)initView {
    [self.view layoutIfNeeded];
    self.inputView = [[FHHouseSaleInputView alloc] initWithFrame:self.view.bounds naviBarHeight:CGRectGetHeight(self.customNavBarView.frame)];
    _inputView.scrollView.delegate = self;
    [self.view addSubview:_inputView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [_inputView addGestureRecognizer:tap];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
}

- (void)initConstraints {
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHHouseSaleInputViewModel alloc] initWithView:self.inputView controller:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        if([change[@"new"] boolValue]){
            [self.view endEditing:YES];
            self.viewModel.isHideKeyBoard = NO;
        }else{
            self.viewModel.isHideKeyBoard = YES;
        }
    }
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (FHHouseSaleLeaveView *)leaveView {
    if(!_leaveView){
        _leaveView = [[FHHouseSaleLeaveView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        WeakSelf;
        _leaveView.alpha = 0;
        _leaveView.quitBlock = ^{
            [wself goBack];
            [wself addPopupClickLog:@"exit"];
        };
        _leaveView.continueBlock = ^{
            [wself addPopupClickLog:@"continue"];
        };
    }
    return _leaveView;
}

- (NSDictionary *)getDictionaryFromJSONString:(NSString *)jsonString {
    NSMutableDictionary *retDic = nil;
    if (jsonString.length > 0) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        retDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if ([retDic isKindOfClass:[NSDictionary class]] && error == nil) {
            return retDic;
        } else {
            return nil;
        }
    }
    return retDic;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshContentOffset:scrollView.contentOffset];
}

#pragma mark - 埋点
- (void)addGoDetailLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    tracerDict[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDict[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
    tracerDict[@"event_tracking_id"] = @"107634";
    TRACK_EVENT(@"go_detail", tracerDict);
}

- (void)addPopupShowLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"popup_name"] = @"unpublished";
    tracerDict[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDict[@"event_tracking_id"] = @"107637";
    TRACK_EVENT(@"popup_show", tracerDict);
}

- (void)addPopupClickLog:(NSString *)clickPosition {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"popup_name"] = @"unpublished";
    tracerDict[@"click_position"] = clickPosition;
    tracerDict[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDict[@"event_tracking_id"] = @"107638";
    TRACK_EVENT(@"popup_click", tracerDict);
}

@end
