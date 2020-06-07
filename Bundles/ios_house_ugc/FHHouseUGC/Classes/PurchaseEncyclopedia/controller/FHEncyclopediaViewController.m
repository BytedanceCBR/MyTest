//
//  FHEncyclopediaViewController.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/21.
//

#import "FHEncyclopediaViewController.h"
#import "FHEncyclopediaHeader.h"
#import "UIDevice+BTDAdditions.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHEncyclopediaViewModel.h"
#import "FHTracerModel.h"
#import "FHLynxManager.h"
@interface FHEncyclopediaViewController ()
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) FHEncyclopediaHeader *encyclopediaHeader;
@property (strong, nonatomic) FHEncyclopediaViewModel *viewModel;
@end

@implementation FHEncyclopediaViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        [self createTracerDic:paramObj.allParams];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self addDefaultEmptyViewFullScreen];
    [self checkLocalData];
}
- (void)checkLocalData {
    BOOL jumpLynxHeader = [[FHLynxManager sharedInstance] checkChannelTemplateIsAvalable:@"ugc_encyclopedia_lynx_header" templateKey:[FHLynxManager defaultJSFileName]];
   BOOL jumpLynxItem = [[FHLynxManager sharedInstance] checkChannelTemplateIsAvalable:@"ugc_encyclopedia_lynx_item" templateKey:[FHLynxManager defaultJSFileName]];
    if (jumpLynxHeader && jumpLynxItem) {
        [self initUI];
        [self initViewModel];
        [self.emptyView hideEmptyView];
    }else {
       [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }
}
- (void)initUI {
    [self.encyclopediaHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset([UIDevice btd_isIPhoneXSeries]?84:64);
        make.height.mas_equalTo(140);
    }];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.encyclopediaHeader.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)initNav {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"购房百科";
}

- (void)initViewModel {
    _viewModel = [[FHEncyclopediaViewModel alloc] initWithWithController:self collectionView:self.collectionView headerView:self.encyclopediaHeader
                  tracerModel:self.tracerModel];

}

- (FHEncyclopediaHeader *)encyclopediaHeader {
    if (!_encyclopediaHeader) {
        FHEncyclopediaHeader *encyclopediaHeader = [[FHEncyclopediaHeader alloc]init];
        [self.view addSubview:encyclopediaHeader];
        _encyclopediaHeader = encyclopediaHeader;
    }
    return _encyclopediaHeader;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        //1.初始化layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //设置collectionView滚动方向
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        //2.初始化collectionView
        UICollectionView *collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.allowsSelection = NO;
        collectionView.pagingEnabled = YES;
        collectionView.bounces = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = [UIColor themeGray7];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (void)createTracerDic:(NSDictionary *)param {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setDictionary:param];
    [dic addEntriesFromDictionary:param[@"tracer"]];
    [dic removeObjectForKey:@"tracer"];
    FHTracerModel *model =[FHTracerModel makerTracerModelWithDic:dic];
    self.tracerModel = model;
}

@end
