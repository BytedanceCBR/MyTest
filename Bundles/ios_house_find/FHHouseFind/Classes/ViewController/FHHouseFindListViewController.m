//
//  FHHouseFindListViewController.m
//  Pods-FHHouseFind_Example
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindListViewController.h"
#import <TTRoute.h>
#import <Masonry.h>
#import <FHHouseBase/FHHouseBridgeManager.h>
#import <UIViewAdditions.h>
#import "FHTracerModel.h"
#import "FHErrorView.h"
#import "FHHouseFindListViewModel.h"
#import "TTDeviceHelper.h"
#import "NSDictionary+TTAdditions.h"
#import "FHConditionFilterViewModel.h"
#import "HMSegmentedControl.h"
#import "FHHouseFindSearchBar.h"
#import "TTDeviceHelper.h"

@interface FHHouseFindListViewController ()

@property (nonatomic , strong) HMSegmentedControl *segmentView;
@property (nonatomic , strong) FHHouseFindSearchBar *searchBar;
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) FHErrorView *errorMaskView;

@property (nonatomic , strong) FHHouseFindListViewModel *viewModel;

@end

@implementation FHHouseFindListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self)wself = self;
    [self setupUI];
    [self startLoading];
    [self setupViewModel];

}

- (void)setupViewModel
{
    __weak typeof(self)wself = self;
    _viewModel = [[FHHouseFindListViewModel alloc]initWithScrollView:_scrollView viewController:self];
    [_viewModel setErrorMaskView:_errorMaskView];
    [_viewModel setSegmentView:_segmentView];
    [_viewModel addConfigObserver];
    _viewModel.sugSelectBlock = ^(NSString * _Nullable placeholder) {
        [wself.searchBar setPlaceHolder:placeholder];
    };
 
}

- (void)setupUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSegmentControl];
    
    __weak typeof(self)wself = self;
    _searchBar = [[FHHouseFindSearchBar alloc]initWithFrame:CGRectZero];
    [_searchBar setPlaceHolder:@"你想住在哪？"];
    _searchBar.tapInputBar = ^{
        [wself.viewModel jump2GuessVC];
    };
    [self.view addSubview:_searchBar];

    [self setupScrollView];
    
    self.errorMaskView = [[FHErrorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.errorMaskView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
    [self.view addSubview:self.errorMaskView];
    
    CGFloat height = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    CGFloat marginX = [TTDeviceHelper isScreenWidthLarge320] ? 40 : 30;
    [_segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).mas_offset(marginX);
        make.right.mas_equalTo(self.view).mas_offset(-marginX);
        make.top.mas_equalTo(self.view).mas_offset(height);
        make.height.mas_equalTo(40);
    }];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.segmentView.mas_bottom);
        make.height.mas_equalTo(32);
    }];
    height = 50 + 32;
    height +=  [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchBar.mas_bottom);
        make.height.mas_equalTo(@([UIScreen mainScreen].bounds.size.height - height));
    }];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.viewModel viewDidLayoutSubviews];
}

- (void)setupSegmentControl
{
    _segmentView = [[HMSegmentedControl alloc]initWithFrame:CGRectZero];
    self.segmentView.sectionTitles = @[@"",@"",@"",@""];
    _segmentView.selectionIndicatorHeight = 0;
    _segmentView.selectionIndicatorColor = [UIColor colorWithHexString:@"#f85959"];
    _segmentView.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentView.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentView.isNeedNetworkCheck = YES;
    
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:18],NSFontAttributeName,
                                     [UIColor themeGray],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontMedium:18],NSFontAttributeName,
                                     [UIColor themeBlue1],NSForegroundColorAttributeName,nil];
    _segmentView.titleTextAttributes = attributeNormal;
    _segmentView.selectedTitleTextAttributes = attributeSelect;
    [self.view addSubview:_segmentView];
}

- (void)setupScrollView
{
    CGFloat height = 50 + 32;
    height +=  [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - height)];
    _scrollView.pagingEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.alwaysBounceHorizontal = NO;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, [TTDeviceHelper isIPhoneXDevice] ? 83 : 49, 0);
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];

}

@end
