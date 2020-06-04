//
//  FHBaseMainListViewController.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import "FHBaseMainListViewController.h"
#import "FHMainListTopView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/FHFakeInputNavbar.h>
#import <FHHouseBase/FHHouseType.h>
#import "FHBaseMainListViewModel.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHUserTracker.h>
#import <TTUIWidget/UIViewController+Track.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import <FHHouseBase/FHBaseTableView.h>
#import "FHMainOldTopView.h"
#import "FHMainRentTopView.h"

#define TOP_HOR_PADDING 3

@interface FHBaseMainListViewController ()

@property(nonatomic , strong) FHFakeInputNavbar *navbar;
@property(nonatomic , strong, readwrite) UIView *containerView;
@property(nonatomic , strong) UIView *topContainerView;
@property(nonatomic , strong) FHMainListTopView *topView;
@property(nonatomic , strong, readwrite) UITableView *tableView;
@property(nonatomic , assign) FHHouseType houseType;
@property(nonatomic , strong) FHBaseMainListViewModel *viewModel;
@property(nonatomic , strong) FHErrorView *errorView;
@property (nonatomic , strong) TTRouteParamObj *paramObj;
@property (nonatomic, assign)   BOOL     isViewDidDisapper;

@property (nonatomic , copy) NSString *associationalWord;// 联想词

@end

@implementation FHBaseMainListViewController


-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {        
        self.paramObj = paramObj;
        
        _houseType = FHHouseTypeSecondHandHouse;
        if (paramObj.allParams[@"house_type"]) {
            _houseType = [paramObj.allParams[@"house_type"] intValue];
        }else{
            NSString *host = paramObj.sourceURL.host;
            if ([host hasPrefix:@"rent"]) {
                _houseType = FHHouseTypeRentHouse;
            }
        }
        
        self.hidesBottomBarWhenPushed = YES;
        self.tracerModel.categoryName = [self categoryName];
        self.tracerDict = paramObj.userInfo.allInfo[@"tracer"];
        NSString *fullText = paramObj.queryParams[@"full_text"];
        NSString *displayText = paramObj.queryParams[@"display_text"];
        if (fullText.length > 0) {
            self.associationalWord = fullText;
        }else if (displayText.length > 0) {
            self.associationalWord = displayText;
        }
        self.ttTrackStayEnable = YES;
        
        
    }
    return self;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[FHBaseTableView alloc] init];
        if (@available(iOS 11.0 , *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            UIEdgeInsets inset = UIEdgeInsetsZero;
            inset.bottom = [[UIApplication sharedApplication]delegate].window.safeAreaInsets.bottom;
            _tableView.contentInset = inset;
        }
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.scrollsToTop = YES;
        _tableView.bounces = NO;
    }
    return _tableView;
}


-(void)initNavbar
{
    // FHFakeInputNavbarTypeMessageAndMap 二手房大类页显示消息和小红点
    FHFakeInputNavbarType type ;
    if (_houseType == FHHouseTypeRentHouse || _houseType == FHHouseTypeNewHouse) {
        type = FHFakeInputNavbarTypeMessageSingle;
    }else if(_houseType == FHHouseTypeSecondHandHouse){
        type = FHFakeInputNavbarTypeMessageAndMap;
    }else {
        type = FHFakeInputNavbarTypeDefault;
    }
    FHFakeInputNavbarStyle style = FHFakeInputNavbarStyleBorder;
    if (_houseType == FHHouseTypeSecondHandHouse && [FHMainOldTopView showBanner]) {
        style = FHFakeInputNavbarStyleDefault;
    }

    _navbar = [[FHFakeInputNavbar alloc] initWithType:type];
    _navbar.style = style;
    __weak typeof(self) wself = self;
    _navbar.defaultBackAction = ^{
        [wself.navigationController popViewControllerAnimated:YES];
    };
    _navbar.showMapAction = ^{
        [wself.viewModel showMapSearch];
    };
    
    _navbar.messageActionBlock = ^{
        [wself.viewModel showMessageList];
    };
    
    _navbar.tapInputBar = ^{
        [wself.viewModel showInputSearch];
    };
    [self.view addSubview:_navbar];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ttNeedIgnoreZoomAnimation = YES;
    
    [self initNavbar];
    _topContainerView = [[UIView alloc]init];
    _topContainerView.clipsToBounds = YES;
    _containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    [self.view addSubview:_topContainerView];
    
    _viewModel = [[FHBaseMainListViewModel alloc] initWithTableView:self.tableView houseType:_houseType routeParam:self.paramObj];
    
    [_viewModel addNotiWithNaviBar:self.navbar];
    
    _topView = [[FHMainListTopView alloc] initWithBannerView:self.viewModel.topBannerView filterView:self.viewModel.filterPanel filterTagsView:self.viewModel.topTagsView];
    
    self.tableView.tableHeaderView = _topView;
    
//    UIEdgeInsets insets = self.tableView.contentInset;
//    insets.top = CGRectGetHeight(_topView.bounds);
//    self.tableView.contentInset = insets;
//    _topView.top = -_topView.height;
//    [self.tableView addSubview:_topView];
    
    [self.containerView addSubview:self.tableView];

    _viewModel.viewController = self;
    _viewModel.navbar = self.navbar;
    _errorView = [[FHErrorView alloc] init];
    [self.containerView addSubview:_errorView];
    _viewModel.errorMaskView = _errorView;
    _errorView.hidden = YES;
    _viewModel.topContainerView = _topContainerView;
    _viewModel.topView = self.topView;
    
    [self.view addSubview:self.viewModel.filterBgControl];
    self.viewModel.filterBgControl.hidden = YES;
    
    [self.view bringSubviewToFront:_navbar];
    
    [self initConstraints];
    
    if (self.associationalWord.length > 0) {
        _navbar.placeHolder = self.associationalWord;
    }else{
        _navbar.placeHolder = [self.viewModel navbarPlaceholder];
    }
    self.tracerModel.categoryName = [_viewModel categoryName];
    [self.viewModel requestData:YES];
//    self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
    self.isViewDidDisapper = NO;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.viewModel refreshMessageDot];
    [self refreshContentOffset:self.tableView.contentOffset];
    self.isViewDidDisapper = NO;
    [self.viewModel viewDidAppear:animated];
}

-(void)initConstraints
{
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self.navbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self.view);
        make.height.mas_equalTo(height);
    }];
    
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(0);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.containerView);
    }];
    
    [self.viewModel.filterBgControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.navbar.mas_bottom).offset(self.viewModel.filterPanel.height);
    }];
    
    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.viewModel.filterPanel.mas_bottom);
    }];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view addObserver:self forKeyPath:@"userInteractionEnabled" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow)  name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow)  name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardDidHideNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view removeObserver:self forKeyPath:@"userInteractionEnabled"];
    [self.viewModel addStayLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isViewDidDisapper = YES;
}

- (void)keyboardWillShow {
//    self.iskeyBoardVisible = YES;
    self.originY = self.tableView.contentOffset.y;
//    self.iskeyBoardShowing = YES;
}

- (void)keyboardDidShow {
//    self.iskeyBoardVisible = YES;
//    self.iskeyBoardShowing = NO;
}

- (void)keyboardDidHide {
//    self.iskeyBoardShowing = NO;
//    self.iskeyBoardVisible = NO;
}

- (void)refreshContentOffset:(CGPoint)contentOffset
{
    CGFloat alpha = 0;
    CGFloat offset = 0;
    CGFloat offsetY = 0;
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    UIColor *bgColor = [UIColor whiteColor];
    if ([self.viewModel.topBannerView isKindOfClass:[FHMainOldTopView class]]) {
        FHMainOldTopView *oldTopView = (FHMainOldTopView *)self.viewModel.topBannerView;
        offsetY = contentOffset.y;
        if ([FHMainOldTopView showBanner]) {
            offset = [FHMainOldTopView bannerHeight] - 42 + 10;
        }else if ([FHMainOldTopView showEntrance]) {
            offset = [FHMainOldTopView entranceHeight];
        }else {
            offset = [FHFakeInputNavbar perferredHeight];
        }
        if (contentOffset.y >= self.topView.height) {
            alpha = 1;
        }else if (offset != self.topView.height){
            CGFloat notiBarHeight = self.viewModel.animateShowNotify ? self.topView.notifyHeight : 0;
            alpha = (offsetY - notiBarHeight) / offset;
        }
        if (alpha >= 0.5 || _navbar.style == FHFakeInputNavbarStyleBorder) {
            statusBarStyle = UIStatusBarStyleDefault;
        }else {
            statusBarStyle = UIStatusBarStyleLightContent;
        }
        bgColor = [oldTopView topBackgroundColor];
    }else if ([self.viewModel.topBannerView isKindOfClass:[FHMainRentTopView class]]) {
//        if ([FHMainRentTopView showEntrance]) {
//            offset = [FHMainRentTopView entranceHeight];
//        }else {
//            offset = [FHFakeInputNavbar perferredHeight];
//        }
        offsetY = contentOffset.y;
        offset = [FHFakeInputNavbar perferredHeight];

        if (contentOffset.y >= self.topView.height) {
            alpha = 1;
        } else {
            CGFloat notiBarHeight = self.viewModel.animateShowNotify ? self.topView.notifyHeight : 0;
            alpha = (offsetY - notiBarHeight) / offset;
        }
        bgColor = [UIColor themeGray8];
    }
    [self.navbar refreshAlpha:alpha];
    self.navbar.backgroundColor = bgColor;
    if (!self.isViewDidDisapper) {
        [[UIApplication sharedApplication]setStatusBarStyle:statusBarStyle];
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    
    [self.viewModel addStayLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
    
    if (self.houseType == FHHouseTypeSecondHandHouse) {
        NSArray *tableCells = [self.tableView visibleCells];
        if (tableCells) {
            [tableCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj respondsToSelector:@selector(resumeVRIcon)]) {
                        [obj performSelector:@selector(resumeVRIcon)];
                    }
            }];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"userInteractionEnabled"]) {
        [self.view endEditing:YES];
    }
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
