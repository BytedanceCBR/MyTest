//
//  FHHouseFindViewController.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import "FHHouseFindViewController.h"
#import <FHCommonUI/HMSegmentedControl.h>
#import "FHHouseFindFakeSearchBar.h"
#import <FHCommonUI/FHErrorView.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import "FHHouseFindViewModel.h"

@interface FHHouseFindViewController ()

@property (nonatomic , strong) HMSegmentedControl *segmentView;
@property (nonatomic , strong) FHHouseFindFakeSearchBar *searchBar;
@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) UIButton *searchButton;
@property (nonatomic , strong) UICollectionView *contentView;
@property (nonatomic , strong) FHHouseFindViewModel *viewModel;
@property (nonatomic , strong) UIView *splitLine;

@end

@implementation FHHouseFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSegmentControl];

    __weak typeof(self)wself = self;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    _contentView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.pagingEnabled = YES;
    
    [self.view addSubview:_contentView];
    _viewModel = [[FHHouseFindViewModel alloc] initWithCollectionView:_contentView segmentControl:self.segmentView];
    _viewModel.showNoDataBlock = ^(BOOL noData,BOOL available) {
        if (noData) {
            [wself.errorMaskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }else if(!available){
            [wself.errorMaskView showEmptyWithTip:@"找房服务即将开通，敬请期待" errorImage:[UIImage imageNamed:kFHErrorMaskNetWorkErrorImageName] showRetry:NO];
        }else{
            wself.errorMaskView.hidden = YES;
        }
        wself.searchButton.hidden = !wself.errorMaskView.isHidden;
    };
    _viewModel.updateSegmentWidthBlock = ^ {
        [wself.view setNeedsLayout];        
    };
    _searchBar = [[FHHouseFindFakeSearchBar alloc]initWithFrame:CGRectZero];
    [_searchBar setPlaceholder:@"你想住在哪？"];
    _searchBar.tapBlock = ^{
//        [wself.viewModel jump2GuessVC];
        [wself.viewModel showSugPage];
    };
    [self.view addSubview:_searchBar];
    
    
    _splitLine = [[UIView alloc] initWithFrame:CGRectZero];
    _splitLine.backgroundColor = [UIColor themeGray6];
    _splitLine.hidden = YES;
    [self.view addSubview:_splitLine];
    
    self.errorMaskView = [[FHErrorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.errorMaskView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
    [self.view addSubview:self.errorMaskView];
    self.errorMaskView.hidden = YES;
    
    [self.view addSubview:self.searchButton];
    [self.searchButton addTarget:self.viewModel action:@selector(showSearchHouse) forControlEvents:UIControlEventTouchUpInside];
    
    [self initConstraints];
    
    _viewModel.searchBar = _searchBar;
    _viewModel.splitLine = _splitLine;
    _viewModel.searchButton = _searchButton;
    
    [_viewModel setupHouseContent:nil];
    
}

-(void)initConstraints
{
    CGFloat height = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
//    CGFloat marginX = [TTDeviceHelper isScreenWidthLarge320] ? 45 : 15;
    [_segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_greaterThanOrEqualTo(self.view).mas_offset(marginX);
//        make.right.mas_lessThanOrEqualTo(self.view).mas_offset(-marginX);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).mas_offset(height+6);
        make.height.mas_equalTo(40);
    }];
    [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(20);
        make.right.mas_equalTo(self.view).offset(-20);
        make.top.mas_equalTo(self.segmentView.mas_bottom).offset(14);
        make.height.mas_equalTo(44);
    }];
    
    [_splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(0.5);
        make.top.mas_equalTo(self.searchBar.mas_bottom).offset(10);
    }];
    
    CGFloat bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchBar.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.view).mas_offset(-bottomHeight);
    }];
    
    [_searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 50));
        make.bottom.mas_equalTo(self.contentView).offset(-70);
    }];
    
}

- (void)setupSegmentControl
{
    _segmentView = [[HMSegmentedControl alloc]initWithFrame:CGRectZero];
    _segmentView.sectionTitles = @[@"",@"",@"",@""];
    _segmentView.selectionIndicatorHeight = 0;
    _segmentView.selectionIndicatorColor = [UIColor colorWithHexString:@"#f85959"];
    _segmentView.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentView.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentView.isNeedNetworkCheck = NO;
    _segmentView.segmentEdgeInset = UIEdgeInsetsMake(0, 15, 0, 15);
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:18],NSFontAttributeName,
                                     [UIColor themeGray],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontMedium:18],NSFontAttributeName,
                                     [UIColor themeBlue1],NSForegroundColorAttributeName,nil];
    _segmentView.titleTextAttributes = attributeNormal;
    _segmentView.selectedTitleTextAttributes = attributeSelect;
    _segmentView.titleFormatter = ^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        
        NSDictionary *attr = @{NSFontAttributeName:selected?[UIFont themeFontSemibold:20]:[UIFont themeFontRegular:20],
                               NSForegroundColorAttributeName:selected?[UIColor themeBlue1]:[UIColor themeGray4]
                               };        
        return  [[NSAttributedString alloc] initWithString:title attributes:attr];
        
    };
    [self.view addSubview:_segmentView];
}

-(UIButton *)searchButton
{
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:@"开始找房" attributes:
                                         @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                           NSFontAttributeName:[UIFont themeFontMedium:16]}];
        [_searchButton setAttributedTitle:attrTitle forState:UIControlStateNormal];
        _searchButton.backgroundColor = HEXINTRGB(0x299cff);
        _searchButton.layer.shadowOffset = CGSizeMake(0, 2);
        _searchButton.layer.shadowColor = [RGBA(41, 156, 255,0.4) CGColor];
        _searchButton.layer.cornerRadius = 26;
        _searchButton.layer.shadowRadius = 10;
//        _searchButton.layer.masksToBounds = YES;
    }
    return _searchButton;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [_viewModel viewWillAppear];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_viewModel viewWillDisappear];
    
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat width = [self.segmentView totalSegmentedControlWidth];
    CGFloat fitWidth = MIN(width, self.view.frame.size.width - 40);
    [self.segmentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(fitWidth);
    }];
    
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground
{
    [self.viewModel endTrack];
    [self.viewModel addStayCategoryLog];
    [self.viewModel resetStayTime];
}

- (void)trackStartedByAppWillEnterForground
{
    [self.viewModel resetStayTime];
    [self.viewModel startTrack];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
