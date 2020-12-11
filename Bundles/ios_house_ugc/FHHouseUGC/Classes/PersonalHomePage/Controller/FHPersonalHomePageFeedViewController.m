//
//  FHPersonalHomePageFeedViewController.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageFeedViewController.h"
#import "FHPersonalHomePageFeedViewModel.h"
#import "FHPersonalHomePageManager.h"
#import "TTNavigationController.h"
#import "FHPersonalHomePageFeedCollectionViewCell.h"
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"


@interface FHPersonalHomePageCollectionView : UICollectionView <UIGestureRecognizerDelegate>

@end

@implementation FHPersonalHomePageCollectionView

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if([[FHPersonalHomePageManager shareInstance].viewController.navigationController isKindOfClass:[TTNavigationController class]]){
//        TTNavigationController *navigationController = (TTNavigationController *)[FHPersonalHomePageManager shareInstance].viewController.navigationController;
//        if(otherGestureRecognizer == navigationController.panRecognizer){
//            if(otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentOffset.x == 0) {
//                return YES;
//            }
//        }
//    }
//
//    return NO;
//}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    return NO;
//}

@end


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
    
    [self initHeaderView];
    [self initCollectionView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initHeaderView {
    _headerView = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 34)];
    _headerView.type = HMSegmentedControlTypeText;
    
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
            NSForegroundColorAttributeName: [UIColor themeGray1]};
    _headerView.titleTextAttributes = titleTextAttributes;

    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontMedium:18],
            NSForegroundColorAttributeName: [UIColor themeGray1]};
    _headerView.selectedTitleTextAttributes = selectedTitleTextAttributes;
    
    _headerView.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _headerView.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _headerView.isNeedNetworkCheck = NO;
    _headerView.firstLeftMargain = 8;
    _headerView.lastRightMargin = 20;
    _headerView.segmentEdgeInset = UIEdgeInsetsMake(5, 14, 0, 14);
    
    _headerView.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _headerView.selectionIndicatorWidth = 20.0f;
    _headerView.selectionIndicatorHeight = 4.0f;
    _headerView.selectionIndicatorCornerRadius = 2.0f;
    _headerView.shouldFixedSelectPosition = YES;
    _headerView.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    _headerView.bounces = NO;
    
    WeakSelf;
    _headerView.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        [self.viewModel updateSelectCell:index];
    };
    
    [self.view addSubview:self.headerView];
}


- (void)initCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[FHPersonalHomePageCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
}

- (void)initViewModel {
    self.viewModel = [[FHPersonalHomePageFeedViewModel alloc] initWithController:self collectionView:self.collectionView];
}

-(void)setHomePageManager:(FHPersonalHomePageManager *)homePageManager {
    _homePageManager = homePageManager;
    _viewModel.homePageManager = _homePageManager;
}

-(void)updateWithHeaderViewMdoel:(FHPersonalHomePageTabListModel *)model {
    if(model.data.tabList.count > 1) {
        self.headerView.hidden = NO;
        self.collectionView.frame = CGRectMake(0, 44, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 44);
    } else {
        self.headerView.hidden = YES;
        self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    }
    [self.viewModel updateWithHeaderViewMdoel:model];
}



@end
