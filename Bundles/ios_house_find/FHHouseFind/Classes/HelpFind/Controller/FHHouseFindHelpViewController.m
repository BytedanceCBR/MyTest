//
//  FHHouseFindHelpViewController.m
//  FHHouseFind
//
//  Created by 张静 on 2019/3/25.
//

#import "FHHouseFindHelpViewController.h"
#import <FHCommonUI/FHErrorView.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "FHHouseFindHelpViewModel.h"
#import "FHHouseFindHelpBottomView.h"

@interface FHHouseFindHelpViewController ()

@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) FHHouseFindHelpBottomView *bottomView;
@property (nonatomic , strong) UICollectionView *contentView;
@property (nonatomic , strong) FHHouseFindHelpViewModel *viewModel;

@end

@implementation FHHouseFindHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"帮我找房";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    _contentView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.pagingEnabled = YES;
    _contentView.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        _contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:_contentView];
    
    _bottomView = [[FHHouseFindHelpBottomView alloc]init];
    _bottomView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_bottomView];

    
}


@end
