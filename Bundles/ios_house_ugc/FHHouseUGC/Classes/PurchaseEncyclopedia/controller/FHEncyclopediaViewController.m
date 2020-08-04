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
#import "TTReachability.h"
#import "UIView+BTDAdditions.h"
#import "TTAccountManager.h"
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
    [self checkLocalData];
}
- (void)checkLocalData {
    BOOL jumpLynxHeader = [[FHLynxManager sharedInstance] checkChannelTemplateIsAvalable:@"ugc_encyclopedia_lynx_header" templateKey:[FHLynxManager defaultJSFileName]];
    BOOL jumpLynxItem = [[FHLynxManager sharedInstance] checkChannelTemplateIsAvalable:@"ugc_encyclopedia_lynx_item" templateKey:[FHLynxManager defaultJSFileName]];
    if (jumpLynxHeader && jumpLynxItem) {
        [self initUI];
        [self addDefaultEmptyViewFullScreen];
        [self initViewModel];
    }else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
    }
    
}

-(void)retryLoadData {
    [_viewModel requestHeaderConfig];
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
    self.customNavBarView.seperatorLine.hidden = YES;
    self.customNavBarView.title.text = @"购房百科";
    UIButton *rightbtn = [self questionBtn];
    [self.customNavBarView addSubview:rightbtn];
    [rightbtn setBtd_y:self.customNavBarView.leftBtn.btd_centerY];
    [rightbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.customNavBarView.title);
        make.right.equalTo(self.customNavBarView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(90, 20));
    }];
}

- (UIButton *)questionBtn {
    UIButton *questionBtn = [[UIButton alloc]init];
    [questionBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    [questionBtn setTitle:@"我要提问" forState:UIControlStateNormal];
    questionBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [questionBtn setImage:[UIImage imageNamed:@"right_write"] forState:UIControlStateNormal];
    questionBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    questionBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [questionBtn setAdjustsImageWhenHighlighted:NO];
    questionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [questionBtn addTarget:self action:@selector(writeQuestion:) forControlEvents:UIControlEventTouchUpInside];
    return questionBtn;
}



- (void)writeQuestion:(UIButton *)btn {
    if ([TTAccountManager isLogin]) {
        [self gotoWendaPublishVC];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"f_house_encyclopedia" forKey:@"enter_from"];
    [params setObject:@"want_question" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [wSelf gotoWendaPublishVC];
                });
            }
        }
    }];
}

- (void)gotoWendaPublishVC {
    NSURL *openUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://ugc_wenda_publish"]];
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"title"] = @"提问";
    NSMutableDictionary *dic = @{}.mutableCopy;
    dic[@"enter_from"] = @"f_house_encyclopedia";
    info[@"tracer"] = dic;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
    [[TTRoute sharedRoute] openURLByViewController:openUrl userInfo:userInfo];
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
