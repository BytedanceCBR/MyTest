//
//  FHSuggestionListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewController.h"
#import "FHSuggestionListNavBar.h"
#import "TTDeviceHelper.h"
#import "FHHouseType.h"
#import "FHHouseTypeManager.h"
#import "FHPopupMenuView.h"
#import "FHSuggestionItemCell.h"
#import "FHSuggestionListViewModel.h"

@interface FHSuggestionListViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)     FHSuggestionListNavBar     *naviBar;
@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, weak)     FHPopupMenuView       *popupMenuView;
@property (nonatomic, strong)   FHSuggectionTableView       *historyTableView;
@property (nonatomic, strong)   FHSuggectionTableView       *suggestTableView;
@property (nonatomic, strong)   FHSuggestionListViewModel      *viewModel;


@property (nonatomic, strong)     FHSuggestionListReturnBlock       retBlk;

@end

@implementation FHSuggestionListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
//        self.neighborhoodId = paramObj.userInfo.allInfo[@"neighborhoodId"];
//        self.houseId = paramObj.userInfo.allInfo[@"houseId"];
//        self.searchId = paramObj.userInfo.allInfo[@"searchId"];
        _houseType = [paramObj.userInfo.allInfo[@"house_type"] integerValue];
//        self.relatedHouse = [paramObj.userInfo.allInfo[@"related_house"] boolValue];
//        self.neighborListVCType = [paramObj.userInfo.allInfo[@"list_vc_type"] integerValue];
//
//        NSLog(@"%@\n", self.searchId);
        NSLog(@"%@\n",paramObj.userInfo.allInfo);
        _retBlk = paramObj.userInfo.allInfo[@"callback_block"];
        NSLog(@"_wBlk:%@",_retBlk);
        TTRouteObject *route = nil;//= [[TTRoute sharedRoute] routeObjWithOpenURL:NSURL URLWithString:paramObj userInfo:paramObj];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.retBlk(route);
        });
        _viewModel = [[FHSuggestionListViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)setupUI {
    [self setupNaviBar];
    [self setupTableView];
}

- (void)setupNaviBar {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHSuggestionListNavBar alloc] init];
    [self.view addSubview:_naviBar];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(naviHeight);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_naviBar setSearchPlaceHolderText:[[FHHouseTypeManager sharedInstance] searchBarPlaceholderForType:self.houseType]];
    _naviBar.searchTypeLabel.text = [[FHHouseTypeManager sharedInstance] stringValueForType:self.houseType];
    CGSize size = [self.naviBar.searchTypeLabel sizeThatFits:CGSizeMake(100, 20)];
    [self.naviBar.searchTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
    [_naviBar.searchTypeBtn addTarget:self action:@selector(searchTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _naviBar.searchInput.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledTextChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupTableView {
    self.historyTableView  = [self createTableView];
    self.historyTableView.tag = 1;
    
    self.suggestTableView  = [self createTableView];
    self.suggestTableView.tag = 2;
    self.suggestTableView.hidden = YES;
}

- (FHSuggectionTableView *)createTableView {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    FHSuggectionTableView *tableView = [[FHSuggectionTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    __weak typeof(self) weakSelf = self;
    tableView.handleTouch = ^{
        [weakSelf.view endEditing:YES];
    };
    tableView.backgroundColor = UIColor.whiteColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (isIphoneX) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.naviBar.mas_bottom);
        make.bottom.mas_equalTo(self.view);
    }];
    tableView.delegate  = self.viewModel;
    tableView.dataSource = self.viewModel;
    [tableView registerClass:[FHSuggestionItemCell class] forCellReuseIdentifier:@"suggestItemCell"];
    [tableView registerClass:[FHSuggestionNewHouseItemCell class] forCellReuseIdentifier:@"suggestNewItemCell"];
    if (@available(iOS 11.0 , *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return tableView;
}

- (void)setHouseType:(FHHouseType)houseType {
    _houseType = houseType;
    [_naviBar setSearchPlaceHolderText:[[FHHouseTypeManager sharedInstance] searchBarPlaceholderForType:houseType]];
    _naviBar.searchTypeLabel.text = [[FHHouseTypeManager sharedInstance] stringValueForType:houseType];
    CGSize size = [self.naviBar.searchTypeLabel sizeThatFits:CGSizeMake(100, 20)];
    [self.naviBar.searchTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
    }];
}

- (void)searchTypeBtnClick:(UIButton *)btn {
    NSArray *items = @[@(FHHouseTypeSecondHandHouse),
                       @(FHHouseTypeRentHouse),
                       @(FHHouseTypeNewHouse),
                       @(FHHouseTypeNeighborhood),];
    //TODO: add by zyk configCcache中数据获取
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FHHouseType houseType = [obj integerValue];
        FHPopupMenuItem *item = [self getPopupItemBy:houseType];
        [menuItems addObject:item];
    }];
    
    FHPopupMenuView *popup = [[FHPopupMenuView alloc] initWithTargetView:self.naviBar.searchTypeBtn menus:menuItems];
    [self.view addSubview:popup];
    self.popupMenuView = popup;
    [popup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.mas_equalTo(self.view);
    }];
    [self.popupMenuView showOnTargetView];
    
}
- (FHPopupMenuItem *)getPopupItemBy:(FHHouseType)ht {
    FHPopupMenuItem *item = [[FHPopupMenuItem alloc] initWithHouseType:ht isSelected:self.houseType == ht];
    __weak typeof(self) weakSelf = self;
    item.itemClickBlock = ^(FHHouseType houseType) {
        weakSelf.houseType = houseType;
        [weakSelf.popupMenuView removeFromSuperview];
    };
    return item;
}

// 文本框文字变化，进行sug请求
- (void)textFiledTextChangeNoti:(NSNotification *)noti {
    NSInteger maxCount = 80;
    NSString *text = self.naviBar.searchInput.text;
    if (text.length > maxCount) {
        text = [text substringToIndex:maxCount];
        self.naviBar.searchInput.text = text;
    }
    BOOL hasText = text.length > 0;
    _suggestTableView.hidden = !hasText;
    _historyTableView.hidden = hasText;
    if (hasText) {
        [self requestSuggestion:text];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (self.popupMenuView) {
        [self.popupMenuView removeFromSuperview];
    }
    return YES;
}

// 输入框执行搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *userInputText = self.naviBar.searchInput.text;
    NSLog(@"%@",userInputText);
    return YES;
}

#pragma mark - Request

// 历史记录
- (void)requestHistoryFromRemote {
    
}

// 删除历史记录
- (void)requestDeleteHistory {
    
}

// 猜你想搜
- (void)requestGuessYouWantData {
    
}

// sug建议
- (void)requestSuggestion:(NSString *)text {
    
}

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"dealloc");
}

@end