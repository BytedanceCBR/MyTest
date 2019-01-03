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

    [self setupUI];

    [self setupViewModel];

}

-(void)jump2GuessVC {
    
    
}

-(void)setupViewModel {

    _viewModel = [[FHHouseFindListViewModel alloc]initWithCollectionView:_collectionView];
    
}

-(void)setupUI {
    
    __weak typeof(self)wself = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    CGFloat statusBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    _segmentView = [[HMSegmentedControl alloc]initWithFrame:CGRectMake(0, statusBarHeight, [UIScreen mainScreen].bounds.size.width, 50)];
    _segmentView.backgroundColor = [UIColor redColor];
    _searchBar = [[FHHouseFindSearchBar alloc]initWithFrame:CGRectMake(0, _segmentView.bottom, [UIScreen mainScreen].bounds.size.width, 32)];

    [self setupCollectionView];
    [self.view addSubview:_segmentView];
    [self.view addSubview:_searchBar];
    _searchBar.tapInputBar = ^{
        [self jump2GuessVC];
    };

    [self.view addSubview:_collectionView];
    

}

-(void)setupCollectionView {

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;

    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    CGFloat y = self.searchBar.bottom;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - y;

    CGRect frame = CGRectMake(0, y, self.view.width, height);
    _collectionView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:flowLayout];
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

}

@end
