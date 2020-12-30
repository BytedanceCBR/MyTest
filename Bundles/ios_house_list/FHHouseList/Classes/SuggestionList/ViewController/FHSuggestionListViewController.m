//
//  FHSuggestionListViewController.m
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import "FHSuggestionListViewController.h"
#import "UIDevice+BTDAdditions.h"
#import "FHHouseType.h"
#import "FHHouseTypeManager.h"
#import "FHSuggestionListViewModel.h"
#import "FHEnvContext.h"
#import "TTNavigationController.h"
#import "FHSugSubscribeListViewController.h"
#import "FHOldSuggestionItemCell.h"
#import "HMSegmentedControl.h"
#import "FHSuggestionSearchBar.h"
#import "FHSuggestionCollectionViewCell.h"
#import "FHSuggestionCollectionView.h"
#import "FHCommonDefines.h"
#import "NSDictionary+BTDAdditions.h"
#import "FHSuggestionListViewController+FHTracker.h"
#import "FHSuggestionDefines.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHSuggestionListViewController(FHDragBack)

- (void)fixDragBackConfict;

@end

@implementation FHSuggestionListViewController(FHDragBack)

//处理侧滑返回手势和collectionView手势冲突
- (void)fixDragBackConfict {
    if ([self.navigationController isKindOfClass:TTNavigationController.class]) {
        TTNavigationController *naviController = (TTNavigationController *)self.navigationController;
        if (naviController.panRecognizer && naviController.panRecognizer.enabled) {
            [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:naviController.panRecognizer];
        }
    }
}

//支持边缘侧滑返回
- (NSInteger)ttDragBackLeftEdge {
    return TTNavigationControllerDefaultSwapLeftEdge;
}

//边缘滑动时，往左滑动禁止返回
- (BOOL)shouldEnableBackActionWhenPanRight:(id)panRightValue {
    BOOL enableBackAction = NO;
    if ([panRightValue respondsToSelector:@selector(boolValue)]) {
        enableBackAction = [panRightValue boolValue];
    }
    return enableBackAction;
}

@end

@interface FHSuggestionListViewController ()<UITextFieldDelegate>

@property (nonatomic, strong)   FHSuggestionListViewModel      *viewModel;
@property (nonatomic, copy)   NSString*   autoFillInputText;

@property (nonatomic, strong)   NSMutableDictionary       *homePageRollDic;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) NSInteger defaultHouseType;
@property (nonatomic, copy) NSString *defaultSearchPlaceholder;
@property (nonatomic, strong) NSArray *segmentTitles;

@end

@implementation FHSuggestionListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.paramObj = paramObj;
        // 1、house_type
        _houseType = 0; // 特殊值，为了第一次setHouseType的时候执行相关功能
        
        _houseTypeArray = [[NSMutableArray alloc] init];
        _segmentTitles = [self getSegmentTitles];
        
        _viewModel = [[FHSuggestionListViewModel alloc] initWithController:self];
        _isNeedHouseTypeCache = [paramObj.allParams[@"isNeedHouseTypeCache"] boolValue];
        NSInteger hp = [paramObj.allParams[@"house_type"] integerValue];
        //针对不同城市显示的tab不同的逻辑，如果传的type改城市不显示，则设为默认值
        BOOL isHaveTab = [_houseTypeArray containsObject:@(hp)];
        if (hp >= 1 && hp <= 4 && isHaveTab) {
            _viewModel.houseType = hp;
        } else {
            _viewModel.houseType = 2;// 默认二手房
        }
        
        id dic = paramObj.allParams[@"homepage_roll_data"];
        if (dic) {
            self.homePageRollDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
        // 2、H5页面传入的其他字段 3.18号上 H5放到report_params
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithDictionary:paramObj.allParams];
        NSString *report_params = paramObj.allParams[@"report_params"];
        if ([report_params isKindOfClass:[NSString class]]) {
            NSDictionary *report_params_dic = [self getDictionaryFromJSONString:report_params];
            if (report_params_dic) {
                [paramDic addEntriesFromDictionary:report_params_dic];
            }
        }
   
        // 3、hint_text：text guess_search_id house_type
        NSString *hint_text = paramDic[@"hint_text"];
        if (!self.homePageRollDic) {
            self.homePageRollDic = [NSMutableDictionary new];
        }
        if (hint_text.length > 0) {
            self.homePageRollDic[@"text"] = hint_text;
        }
        //自动填充，并初始请求
        if (paramObj.allParams[@"search_history_text"]) {
            self.autoFillInputText = paramObj.allParams[@"search_history_text"];
        }
        
        _defaultHouseType = _viewModel.houseType;
        _defaultSearchPlaceholder = [self.homePageRollDic btd_stringValueForKey:@"text"];
    }
    return self;
}

- (NSDictionary *)getDictionaryFromJSONString:(NSString *)jsonString {
    NSMutableDictionary *retDic = nil;
    if (jsonString.length > 0) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        retDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if ([retDic isKindOfClass:[NSDictionary class]] && error == nil) {
            return retDic;
        } else {
            return nil;
        }
    }
    return retDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if (self.autoFillInputText) {
        self.naviBar.searchInput.text = self.autoFillInputText;
    }
    __weak typeof(self) weakSelf = self;
    self.panBeginAction = ^{
        [weakSelf.naviBar.searchInput resignFirstResponder];
    };
    self.houseType = self.viewModel.houseType;
    
    [self trackPageShow];
}

- (void)refreshSearchPlaceHolderText {
    //目前只有二手房支持这个
    if (self.defaultSearchPlaceholder.length > 0 && self.houseType == FHHouseTypeSecondHandHouse) {
        [self.naviBar setSearchPlaceHolderText:self.defaultSearchPlaceholder];
        return;
    }
    
    [self.naviBar setSearchPlaceHolderText:[[FHHouseTypeManager sharedInstance] searchBarPlaceholderForType:self.houseType]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshSearchPlaceHolderText];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.naviBar resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fixDragBackConfict];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.naviBar.searchInput resignFirstResponder];
}

- (void)setupUI {
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor themeGray8];
    [self.view addSubview:_topView];
    BOOL isIphoneX = [UIDevice btd_isIPhoneXSeries];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20) + 54;
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(naviHeight);
    }];
    [self setupSegmentedControl];
    
    self.naviBar = [[FHSuggestionSearchBar alloc] initWithFrame:CGRectZero];
    [self.naviBar setSearchPlaceHolderText:@"二手房/租房/小区"];
    [self.topView addSubview:_naviBar];
    [self.naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.segmentControl.mas_bottom).offset(6);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(54);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self refreshSearchPlaceHolderText];
    _naviBar.searchInput.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledTextChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];
    
    self.containerView = [[UIView alloc] init];
    [self.view addSubview:_containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(self.topView.mas_bottom);
    }];
    
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - naviHeight);
    //设置collectionView滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    //2.初始化collectionView
    self.collectionView = [[FHSuggestionCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.allowsSelection = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.bounces = YES;
    _collectionView.scrollEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:_collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    [self.viewModel initCollectionView:_collectionView];
}

- (void)textFiledTextChangeNoti:(NSNotification *)noti {
    NSInteger maxCount = 80;
    NSString *text = self.naviBar.searchInput.text;
    UITextRange *selectedRange = [self.naviBar.searchInput markedTextRange];
    //获取高亮部分
    UITextPosition *position = [self.naviBar.searchInput positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，说明不是拼音输入
    if (position) {
        return;
    }
    if (text.length > maxCount) {
        text = [text substringToIndex:maxCount];
        self.naviBar.searchInput.text = text;
    }
    [self.viewModel textFieldTextChange:text];
}                                      

- (void)setupSegmentedControl {
    _segmentControl = [[HMSegmentedControl alloc] initWithSectionTitles:self.segmentTitles];
    NSDictionary *titleTextAttributes = @{NSFontAttributeName: [UIFont themeFontRegular:16],
                                          NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.titleTextAttributes = titleTextAttributes;
    NSDictionary *selectedTitleTextAttributes = @{NSFontAttributeName: [UIFont themeFontSemibold:18],
                                                  NSForegroundColorAttributeName: [UIColor themeGray1]};
    _segmentControl.selectedTitleTextAttributes = selectedTitleTextAttributes;
    _segmentControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    _segmentControl.isNeedNetworkCheck = NO;
    _segmentControl.segmentEdgeInset = UIEdgeInsetsMake(5, 0, 5, 0);
    _segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentControl.selectionIndicatorWidth = 20.0f;
    _segmentControl.selectionIndicatorHeight = 4.0f;
    _segmentControl.selectionIndicatorCornerRadius = 2.0f;
    _segmentControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 0, -3, 0);
    _segmentControl.selectionIndicatorColor = [UIColor colorWithHexStr:@"#ff9629"];
    [_segmentControl setBackgroundColor:[UIColor clearColor]];
    self.viewModel.segmentControl = _segmentControl;
    [self bindTopIndexChanged];
    [self.topView addSubview:_segmentControl];
    NSInteger count = _segmentControl.sectionTitles.count;
    float tabMargin = ([UIScreen mainScreen].bounds.size.width - (count - 1) * 32 - count * 36 - 18) / 2;
    [_segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(-60);
        make.left.mas_equalTo(tabMargin);
        make.right.mas_equalTo(-tabMargin);
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.viewModel textFieldShouldReturn:_naviBar.searchInput.text];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.viewModel textFieldWillClear];
    return YES;
}

-(void)bindTopIndexChanged
{
    WeakSelf;
    self.segmentControl.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        [self.view endEditing:YES];
        [self scrollToIndex:index];
    };
}

- (void)scrollToIndex:(NSInteger)index {
    if (index >= 0 && index < self.houseTypeArray.count) {
        NSInteger oldHouseType = self.houseType;
        self.houseType = [self.houseTypeArray[index] integerValue];
        if (self.houseType != oldHouseType) {
            [self trackTabIndexChange];
            [self notifyHouseTypeChanged:self.houseType];
            if(self.isNeedHouseTypeCache){
                [FHEnvContext setLastSearchSugHouseType:self.houseType];
            }
        }
    }
}

- (void)notifyHouseTypeChanged:(FHHouseType)houseType {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHSuggestionHouseTypeDidChanged object:@(houseType)];
}

-(NSArray *)getSegmentTitles
{
    NSArray *items = @[[[FHHouseTypeManager sharedInstance] stringValueForType:FHHouseTypeSecondHandHouse],
                       [[FHHouseTypeManager sharedInstance] stringValueForType:FHHouseTypeNewHouse],
                       [[FHHouseTypeManager sharedInstance] stringValueForType:FHHouseTypeRentHouse],
                       [[FHHouseTypeManager sharedInstance] stringValueForType:FHHouseTypeNeighborhood],];
    FHConfigDataModel *model = [[FHEnvContext sharedInstance] getConfigFromCache];
    [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeSecondHandHouse]];
    [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeNewHouse]];
    [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeRentHouse]];
    [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeNeighborhood]];
    if (model) {
        items = [self houseTypeSectionByConfig:model];
    }
    return items;
}

- (void)setHouseType:(FHHouseType)houseType
{
    if (_houseType == houseType) {
        return;
    }
    _houseType = houseType;
    [self refreshSearchPlaceHolderText];
    _segmentControl.selectedSegmentIndex = [self getSegmentControlIndex];
    self.viewModel.currentTabIndex = _segmentControl.selectedSegmentIndex;
    [self.collectionView layoutIfNeeded];
    [self.viewModel updateSubVCTrackStatus];
    //[self.viewModel textFieldTextChange:self.naviBar.searchInput.text];
}

-(NSInteger)getSegmentControlIndex
{
    for (int i = 0; i < _segmentControl.sectionTitles.count; i++) {
        if ([[[FHHouseTypeManager sharedInstance] stringValueForType:_houseType] isEqualToString:_segmentControl.sectionTitles[i]]) {
            return i;
        }
    }
    return 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (NSArray *)houseTypeSectionByConfig:(FHConfigDataModel *)config {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [self.houseTypeArray removeAllObjects];
    if (config.searchTabFilter.count > 0) {
        [items addObject: [[FHHouseTypeManager sharedInstance] stringValueForType:FHHouseTypeSecondHandHouse]];
        [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeSecondHandHouse]];
    }
    if (config.searchTabCourtFilter.count > 0) {
        [items addObject:[[FHHouseTypeManager sharedInstance] stringValueForType:FHHouseTypeNewHouse]];
        [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeNewHouse]];
    }
    if (config.searchTabRentFilter.count > 0) {
        [items addObject:[[FHHouseTypeManager sharedInstance] stringValueForType:FHHouseTypeRentHouse]];
        [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeRentHouse]];
    }
    if (config.searchTabNeighborhoodFilter.count > 0) {
        [items addObject:[[FHHouseTypeManager sharedInstance] stringValueForType:FHHouseTypeNeighborhood]];
        [self.houseTypeArray addObject:[NSNumber numberWithInt: FHHouseTypeNeighborhood]];
    }
    return items;
}

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
