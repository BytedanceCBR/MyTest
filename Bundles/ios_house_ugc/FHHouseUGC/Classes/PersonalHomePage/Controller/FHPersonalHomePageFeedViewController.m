//
//  FHPersonalHomePageFeedViewController.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageFeedViewController.h"
#import "FHPersonalHomePageFeedViewModel.h"
#import "UIColor+Theme.h"

@interface FHPersonalHomePageFeedViewController () 
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) FHPersonalHomePageFeedViewModel *viewModel;
@end

@implementation FHPersonalHomePageFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initViewModel];
}

- (void)initView {
    self.view.backgroundColor = [UIColor themeWhite];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionHeadersPinToVisibleBounds = YES;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
}

- (void)initViewModel {
    self.viewModel = [[FHPersonalHomePageFeedViewModel alloc] initWithController:self collectionView:self.collectionView];
}

-(void)updateWithHeaderViewMdoel:(FHPersonalHomePageTabListModel *)model {
    self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    [self.viewModel updateWithHeaderViewMdoel:model];
}




@end
