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
@property (nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , strong) FHErrorView *errorMaskView;

@property (nonatomic , strong) FHHouseFindListViewModel *viewModel;

@end

@implementation FHHouseFindListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self)wself = self;
    [self setupUI];
    [self setupViewModel];

}

- (void)setupViewModel
{
    _viewModel = [[FHHouseFindListViewModel alloc]initWithCollectionView:_collectionView];
 
}


- (void)updateSegementTitles:(NSArray <NSString *> *)titles
{
    if (titles.count == 0) {
        return;
    }
    _segmentView.sectionTitles = titles;
    _segmentView.selectedSegmentIndex = 0;
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

    [self setupCollectionView];
    
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
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchBar.mas_bottom);
    }];
}

- (void)setupSegmentControl
{
    _segmentView = [[HMSegmentedControl alloc]initWithFrame:CGRectZero];
    _segmentView.sectionTitles = @[@"二手房",@"租房",@"新房",@"小区"];
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
    __weak typeof(self)wself = self;
    _segmentView.indexChangeBlock = ^(NSInteger index) {

//        if (self.clickIndexCallBack) {
//            self.clickIndexCallBack(index);
//        }
    };
    [self.view addSubview:_segmentView];
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    // add by zjing for test 布局问题
    CGFloat height = 50 + 32 + 49;
    height +=  [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    flowLayout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - height);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.alwaysBounceHorizontal = YES;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, [TTDeviceHelper isIPhoneXDevice] ? 83 : 49, 0);
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];

}

@end
