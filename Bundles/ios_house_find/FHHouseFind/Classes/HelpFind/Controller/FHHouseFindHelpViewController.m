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
#import "FHHouseFindHelpSubmitCell.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHHouseFindRecommendModel.h"

@interface FHHouseFindHelpViewController ()

@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) UICollectionView *contentView;
@property (nonatomic , strong) FHHouseFindHelpViewModel *viewModel;
@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;

@end

@implementation FHHouseFindHelpViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *recommendDict = [paramObj.allParams tt_dictionaryValueForKey:@"recommend_house"];
        if (recommendDict.count > 0) {
            _recommendModel = [[FHHouseFindRecommendDataModel alloc]initWithDictionary:recommendDict error:nil];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self initConstraints];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.viewModel viewWillDisappear:animated];
//    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
//    [self tt_resetStayTime];
    
}

- (FHHouseFindRecommendDataModel *)getRecommendModel
{
    return self.viewModel.recommendModel;
}

- (void)refreshRecommendModel:(FHHouseFindRecommendDataModel *)recommendModel
{
    self.viewModel.recommendModel = recommendModel;
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

- (void)setupUI
{
    __weak typeof(self)wself = self;
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"帮我找房";
    self.customNavBarView.leftButtonBlock = ^{
        if (wself.parentViewController) {
            [wself.parentViewController.navigationController popViewControllerAnimated:YES];
        }else {
            [wself.navigationController popViewControllerAnimated:YES];
        }
    };
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 13;
    layout.minimumInteritemSpacing = 13;

    _contentView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        _contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:_contentView];

    _viewModel = [[FHHouseFindHelpViewModel alloc]initWithCollectionView:_contentView recommendModel:self.recommendModel];
    _viewModel.viewController = self;
    _viewModel.showNoDataBlock = ^(BOOL noData,BOOL available) {
        if (noData) {
            [wself.errorMaskView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }else if(!available){
            [wself.errorMaskView showEmptyWithTip:@"找房服务即将开通，敬请期待" errorImage:[UIImage imageNamed:kFHErrorMaskNetWorkErrorImageName] showRetry:NO];
        }else{
            wself.errorMaskView.hidden = YES;
        }
    };
    
    self.errorMaskView = [[FHErrorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.errorMaskView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
    [self.view addSubview:self.errorMaskView];
    self.errorMaskView.hidden = YES;
    
}

-(void)initConstraints
{
    CGFloat bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.bottom.mas_equalTo(-bottomHeight);
    }];
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
}

@end
