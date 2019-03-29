//
//  FHPriceValuationResultController.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/3/25.
//

#import "FHPriceValuationResultController.h"
#import "FHPriceValuationResultViewModel.h"
#import "FHPriceValuationResultView.h"
#import "UIViewController+Refresh_ErrorHandler.h"

@interface FHPriceValuationResultController()<UIViewControllerErrorHandler,UIScrollViewDelegate>

@property(nonatomic, strong) FHPriceValuationResultViewModel *viewModel;
@property(nonatomic ,strong) FHPriceValuationResultView *resultView;

@end

@implementation FHPriceValuationResultController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
        self.model = params[@"model"];
        self.infoModel = params[@"infoModel"];
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
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"查房价";
    [self setNavBar:NO];
}

- (void)setNavBar:(BOOL)error {
    if(error){
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:NO];
    }else{
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
        [self.customNavBarView setNaviBarTransparent:YES];
    }
}

- (void)initView {
    [self.view layoutIfNeeded];
    self.resultView = [[FHPriceValuationResultView alloc] initWithFrame:self.view.bounds naviBarHeight:CGRectGetHeight(self.customNavBarView.frame)];
    _resultView.hidden = YES;
    _resultView.scrollView.delegate = self;
    [self.view addSubview:_resultView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initConstraints {
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHPriceValuationResultViewModel alloc] initWithView:self.resultView controller:self];
    [_viewModel requestData];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat alpha = scrollView.contentOffset.y / 30;
    if (alpha > 0) {
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
    }else {
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
    }
    [self.customNavBarView refreshAlpha:alpha];
}

@end
