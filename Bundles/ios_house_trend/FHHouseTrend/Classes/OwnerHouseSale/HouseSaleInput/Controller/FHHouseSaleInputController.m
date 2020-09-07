//
//  FHHouseSaleInputController.m
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/6.
//

#import "FHHouseSaleInputController.h"
#import "FHHouseSaleInputViewModel.h"
#import "FHHouseSaleInputView.h"

@interface FHHouseSaleInputController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property(nonatomic, strong) FHHouseSaleInputViewModel *viewModel;
@property(nonatomic ,strong) FHHouseSaleInputView *inputView;

@end

@implementation FHHouseSaleInputController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _neighbourhoodId = paramObj.allParams[@"neighbourhoodId"];
        _neighbourhoodName = paramObj.allParams[@"neighbourhoodName"];
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
}

- (void)refreshContentOffset:(CGPoint)contentOffset {
    CGFloat alpha = contentOffset.y / 50;
    if(alpha > 1){
        alpha = 1;
    }
    if (alpha > 0) {
        self.customNavBarView.title.text = @"在线卖房";
        self.customNavBarView.title.textColor = [UIColor themeGray1];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return"] forState:UIControlStateHighlighted];
    }else {
        self.customNavBarView.title.text = @"";
        self.customNavBarView.title.textColor = [UIColor whiteColor];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateNormal];
        [self.customNavBarView.leftBtn setBackgroundImage:[UIImage imageNamed:@"icon-return-white"] forState:UIControlStateHighlighted];
    }
    [self.customNavBarView refreshAlpha:alpha];
    
    if (contentOffset.y > 0) {
        self.statusBarStyle = UIStatusBarStyleDefault;
    }else {
        self.statusBarStyle = UIStatusBarStyleLightContent;
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshContentOffset:scrollView.contentOffset];
}

@end
