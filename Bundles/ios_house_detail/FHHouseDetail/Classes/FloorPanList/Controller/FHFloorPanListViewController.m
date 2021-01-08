//
//  FHFloorPanListViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListViewController.h"
#import "HMSegmentedControl.h"
#import "FHEnvContext.h"
#import "FHFloorPanListViewModel.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHFloorPanListViewController ()
@property (nonatomic , strong) HMSegmentedControl *segmentedControl;
@property (nonatomic , strong) UIView *segementBottomLine;
@property (nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , strong) FHFloorPanListViewModel *panListModel;
@property (nonatomic , strong) NSString *courtId;
@property (nonatomic , strong) UIView *segmentedView;
@end

@implementation FHFloorPanListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        if (paramObj.userInfo.allInfo[@"court_id"]) {
            _courtId = paramObj.userInfo.allInfo[@"court_id"];
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpSegmentedControl];
    
    [self initCollectionView];

    self.panListModel = [[FHFloorPanListViewModel alloc] initWithController:self collectionView:self.collectionView SegementView:self.segmentedControl courtId:self.courtId];
    
    self.panListModel.navBar = [self getNaviBar];
    self.viewModel = self.panListModel; // IM线索使用，不可以删除
    
    [self setNavBarTitle:@"户型列表"];
    
    [(FHDetailNavBar *)[self getNaviBar] removeBottomLine];

    
    [self addDefaultEmptyViewFullScreen];

    if (![TTReachability isNetworkConnected]) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
        [self.view bringSubviewToFront:[self getNaviBar]];
        return;
    }
    
    self.view.backgroundColor = [UIColor themeGray7];
    [self.view bringSubviewToFront:[self getNaviBar]];
}

- (void)setUpSegmentedControl
{
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(5, 15, 0, 13);
    _segmentedControl.selectionIndicatorHeight = 4;
    _segmentedControl.selectionIndicatorCornerRadius = 2;
    _segmentedControl.selectionIndicatorWidth = 20;
    _segmentedControl.selectionIndicatorColor = [UIColor themeOrange4];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentedControl.isNeedNetworkCheck = YES;
    //    _segmentedControl.selec
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:16],NSFontAttributeName,
                                     [UIColor themeGray1],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontMedium:18],NSFontAttributeName,
                                     [UIColor themeGray1],NSForegroundColorAttributeName,nil];
    _segmentedControl.titleTextAttributes = attributeNormal;
    _segmentedControl.selectedTitleTextAttributes = attributeSelect;
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;

    self.segmentedView = [[UIView alloc] init];
    [self.segmentedView addSubview:self.segmentedControl];
    self.segmentedView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.segmentedView];

    [self.segmentedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self getNaviBar].mas_bottom);
        make.left.right.equalTo(self.segmentedView);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(44);
    }];
    
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentedView.mas_top).offset(5);
        make.left.right.equalTo(self.view);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(34);
    }];
    
    _segementBottomLine = [UIView new];
    _segementBottomLine.backgroundColor = [UIColor themeGray6];
    [_segmentedControl addSubview:_segementBottomLine];
    [_segementBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.segmentedView);
        make.left.right.equalTo(self.segmentedView);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(0.5);
    }];
}

-(void)initCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view);
        make.top.equalTo(self.segmentedView.mas_bottom);
        make.bottom.equalTo([self getBottomBar].mas_top);
    }];
}

@end
