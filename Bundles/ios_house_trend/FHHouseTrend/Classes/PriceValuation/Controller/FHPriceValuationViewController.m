//
//  FHPriceValuationViewController.m
//  FHHouseTrend
//
//  Created by 春晖 on 2019/3/19.
//

#import "FHPriceValuationViewController.h"
#import "FHPriceValuationViewModel.h"
#import "FHPriceValuationView.h"
#import "UIFont+House.h"

@interface FHPriceValuationViewController ()<TTRouteInitializeProtocol>

@property(nonatomic, strong) FHPriceValuationViewModel *viewModel;
@property(nonatomic ,strong) FHPriceValuationView *priceValuationView;

@end

@implementation FHPriceValuationViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel viewWillAppear];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
//        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.viewModel viewWillDisappear];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
    [self.customNavBarView setNaviBarTransparent:YES];
    
    self.historyBtn = [[UIButton alloc] init];
    [_historyBtn setTitle:@"估价历史" forState:UIControlStateNormal];
    [_historyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _historyBtn.titleLabel.font = [UIFont themeFontRegular:16];
    [_historyBtn addTarget:self action:@selector(goToHistory) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavBarView addRightViews:@[_historyBtn] viewsWidth:@[@64] viewsHeight:@[@22] viewsRightOffset:@[@20]];
}

- (void)initView {
    [self.view layoutIfNeeded];
    self.priceValuationView = [[FHPriceValuationView alloc] initWithFrame:self.view.bounds naviBarHeight:CGRectGetHeight(self.customNavBarView.frame)];
    [self.view addSubview:_priceValuationView];
    _priceValuationView.scrollView.delegate = self;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [_priceValuationView addGestureRecognizer:tap];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
}

- (void)initConstraints {
    [self.priceValuationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHPriceValuationViewModel alloc] initWithView:self.priceValuationView controller:self];
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

- (void)goToHistory {
    [self.viewModel goToHistory];
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
