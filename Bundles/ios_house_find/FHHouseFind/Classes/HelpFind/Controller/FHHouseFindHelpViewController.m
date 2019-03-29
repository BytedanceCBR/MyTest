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
    [self initConstraints];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.viewModel viewWillDisappear:animated];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
//    [self.viewModel addStayCategoryLog:self.ttTrackStayTime];
//    [self tt_resetStayTime];
    
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
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"帮我找房";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 13;
    layout.minimumInteritemSpacing = 13;

    _contentView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _contentView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _contentView.backgroundColor = [UIColor whiteColor];
    _contentView.showsHorizontalScrollIndicator = NO;
    _contentView.pagingEnabled = YES;
    _contentView.scrollsToTop = NO;
    if (@available(iOS 11.0, *)) {
        _contentView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:_contentView];
    
    _bottomView = [[FHHouseFindHelpBottomView alloc]init];
    [self.view addSubview:_bottomView];

    __weak typeof(self)wself = self;
    _viewModel = [[FHHouseFindHelpViewModel alloc]initWithCollectionView:_contentView bottomView:_bottomView];
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
    CGFloat height = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    
    CGFloat bottomHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomHeight = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
    } else {
        // Fallback on earlier versions
    }
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(60);
        make.bottom.mas_equalTo(self.view).offset(-bottomHeight);
    }];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
}

@end
