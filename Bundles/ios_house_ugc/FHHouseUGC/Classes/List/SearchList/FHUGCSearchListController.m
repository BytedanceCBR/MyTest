//
//  FHUGCSearchListController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHUGCSearchListController.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHUserTracker.h"
#import "FHFakeInputNavbar.h"
#import "FHConditionFilterFactory.h"
#import "FHUGCScialGroupModel.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import "FHUGCConfig.h"
#import "FHUGCSearchListCell.h"
#import "FHHouseUGCAPI.h"
#import "TTNavigationController.h"
#import "FHEnvContext.h"
#import "FHUGCModel.h"
#import "ToastManager.h"
#import "FHUGCConfig.h"
#import "FHUGCCommunityListViewController.h"

@implementation FHUGCSearchCommunityItemData
@end

@interface FHUGCSearchListController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) FHUGCSuggectionTableView *tableView;
@property(nonatomic, strong) NSMutableArray *items;
@property(nonatomic, weak) TTHttpTask *sugHttpTask;
@property(nonatomic, copy) NSString *searchText;
@property(nonatomic, assign) BOOL isViewAppearing;
@property(nonatomic, assign) BOOL needReloadData;
@property(nonatomic, assign) BOOL isKeybordShow;
@property(nonatomic, assign) BOOL keyboardVisible;
@property(nonatomic, strong) NSMutableDictionary *showCache;
@property(nonatomic, assign) NSInteger associatedCount;

@property(nonatomic, assign) FHCommunityListType listType;
@property(nonatomic, weak) id <FHUGCCommunityChooseDelegate> chooseDelegate;
@end

@implementation FHUGCSearchListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.listType = FHCommunityListTypeFollow;
        if (paramObj.allParams[@"action_type"]) {
            self.listType = [paramObj.allParams[@"action_type"] integerValue];
        }
        NSHashTable <FHUGCCommunityChooseDelegate> *choose_delegate = paramObj.allParams[@"choose_delegate"];
        self.chooseDelegate = choose_delegate.anyObject;
        self.showCache = [NSMutableDictionary dictionary];
        self.associatedCount = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self setupData];
    __weak typeof(self) weakSelf = self;
    self.panBeginAction = ^{
        [weakSelf.naviBar.searchInput resignFirstResponder];
    };
    [self startLoadData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardVisibleChanged:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardVisibleChanged:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isViewAppearing = YES;
    if (self.needReloadData) {
        self.needReloadData = NO;
        [self.tableView reloadData];
    }
    if (self.isKeybordShow) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.naviBar.searchInput becomeFirstResponder];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isViewAppearing = NO;
}

- (void)followStateChanged:(NSNotification *)notification {
    if (notification) {
//        if (self.isViewAppearing) {
//            return;
//        }
//        NSDictionary *userInfo = notification.userInfo;
//        BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
//        NSString *groupId = notification.userInfo[@"social_group_id"];
//        if(groupId.length > 0){
//            [self.items enumerateObjectsUsingBlock:^(FHUGCScialGroupDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj.socialGroupId isEqualToString:groupId]) {
//                    obj.hasFollow = followed ? @"1" : @"0";
//                    self.needReloadData = YES;
//                    *stop = YES;
//                }
//            }];
//        }
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardVisibleChanged:(NSNotification *)notification {
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        _keyboardVisible = YES;
    } else {
        // 解决tableView的touch 事件先于 cell点击的问题
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakSelf.keyboardVisible = NO;
        });
    }
}

- (void)setupData {
    self.items = [NSMutableArray new];
    self.needReloadData = NO;
    self.isKeybordShow = YES;
    self.keyboardVisible = NO;
}

- (void)setupNaviBar {
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    _naviBar = [[FHUGCSearchBar alloc] initWithFrame:CGRectZero];
    [_naviBar setSearchPlaceHolderText:@"搜索圈子"];
    [self.view addSubview:_naviBar];
    CGFloat naviHeight = 44 + (isIphoneX ? 44 : 20);
    [_naviBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(naviHeight);
    }];
    [_naviBar.backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    _naviBar.searchInput.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledTextChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupUI {
    [self setupNaviBar];

    CGFloat height = [FHFakeInputNavbar perferredHeight];
    [self configTableView];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[FHUGCSearchListCell class] forCellReuseIdentifier:@"FHUGCSearchListCell"];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(height);
        make.bottom.mas_equalTo(self.view);
    }];
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEmptyViewAction:)];
    [self.emptyView addGestureRecognizer:tapGesturRecognizer];
}

- (void)configTableView {
    _tableView = [[FHUGCSuggectionTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak typeof(self) weakSelf = self;
    _tableView.handleTouch = ^{
        [weakSelf.view endEditing:YES];
    };
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 70;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
}

- (void)tapEmptyViewAction:(id)sender {
    [self.naviBar.searchInput resignFirstResponder];
}

- (void)startLoadData {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
    }
}

- (void)retryLoadData {

}

// 文本框文字变化，进行sug请求
- (void)textFiledTextChangeNoti:(NSNotification *)noti {

    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }

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
    BOOL hasText = text.length > 0;
    self.searchText = text;
    if (hasText) {
        [self requestSuggestion:text];
    } else {
        // 清空sug列表数据
        [self.items removeAllObjects];
        [self.tableView reloadData];
    }
}

// sug建议
- (void)requestSuggestion:(NSString *)text {
    // NSInteger cityId = [[FHEnvContext getCurrentSelectCityIdFromLocal] integerValue];
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    __weak typeof(self) weakSelf = self;
    self.sugHttpTask = [FHHouseUGCAPI requestSocialSearchByText:text class:[FHUGCSearchModel class] completion:^(id <FHBaseModelProtocol> _Nonnull model, NSError *_Nonnull error) {
        if (model != NULL && error == NULL) {
            weakSelf.associatedCount +=1;
            [weakSelf.items removeAllObjects];
            FHUGCSearchModel *tModel = model;
            if (tModel.data.count > 0 && weakSelf.searchText.length > 0)  {
                [weakSelf.emptyView hideEmptyView];
                [weakSelf.items addObjectsFromArray:tModel.data];
            }
            [weakSelf addAssociateCommunityShowLog];
            [weakSelf.tableView reloadData];
            
            if (weakSelf.items.count == 0) {
                [weakSelf.emptyView showEmptyWithTip:@"暂无搜索结果" errorImageName:@"ugc_search_list_null" showRetry:NO];
            };
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

// 输入框执行搜索
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //  NSString *userInputText = self.naviBar.searchInput.text;
}

#pragma mark - dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCSearchListCell *cell = (FHUGCSearchListCell *) [tableView dequeueReusableCellWithIdentifier:@"FHUGCSearchListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        cell.highlightedText = self.searchText;
        FHUGCScialGroupDataModel *data = self.items[row];
        // 埋点
        NSMutableDictionary *tracerDic = @{}.mutableCopy;
        tracerDic[@"card_type"] = @"left_pic";
        tracerDic[@"page_type"] = @"community_search";
        tracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
        tracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
        tracerDic[@"rank"] = @(row);
        tracerDic[@"click_position"] = @"join_like";
        tracerDic[@"log_pb"] = data.logPb ?: @"be_null";
        cell.tracerDic = tracerDic;
        // 刷新数据

        FHUGCSearchCommunityItemData *wrapData = [[FHUGCSearchCommunityItemData alloc] init];
        wrapData.model = data;
        wrapData.listType = self.listType;
        [cell refreshWithData:wrapData];
    }

    return cell;
}

-(void)onItemSelected:(FHUGCScialGroupDataModel*)item{
    NSMutableArray<UIViewController *> *viewControllers = [self.navigationController.viewControllers mutableCopy];

    UIViewController *last = viewControllers.lastObject;
    UIViewController *pre = nil;

    if (self.chooseDelegate) {
        [self.chooseDelegate selectedItem:item];
    }

    //至少存在根控制器
    if(viewControllers.count > 2){
        pre = viewControllers[viewControllers.count - 2];
    }
    if(last == self && [pre isKindOfClass:[FHUGCCommunityListViewController class]]){
        [viewControllers removeObject:pre];
        self.navigationController.viewControllers = [viewControllers copy];
        [self.navigationController popViewControllerAnimated:YES];
    }

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        // 键盘是否显示
        self.isKeybordShow = self.keyboardVisible;
        
        FHUGCScialGroupDataModel *data = self.items[row];
        if (self.listType == FHCommunityListTypeChoose) {
            [self addSelectLog:data rank:row];
            [self onItemSelected:data];
            return;
        }

        //点击埋点
        [self addCommunityClickLog:data rank:row];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = data.socialGroupId;
        dict[@"tracer"] = @{@"enter_from":@"community_search_show",
                            @"enter_type":@"click",
                            @"rank":@(row),
                            @"log_pb":data.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        // 跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

// 联想词埋点
- (void)addAssociateCommunityShowLog {
    NSMutableArray *wordList = [NSMutableArray new];
    for (NSInteger index = 0; index < self.items.count; index++) {
        FHUGCScialGroupDataModel *item = self.items[index];
        NSDictionary *dic = @{
                @"text": item.socialGroupName ?: @"be_null",
                @"word_id": item.socialGroupId ?: @"be_null",
                @"rank": @(index)
        };
        [wordList addObject:dic];
    }
    NSError *error = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:wordList options:NSJSONReadingAllowFragments error:&error];
    NSString *wordListStr = @"";
    if (data && error == NULL) {
        wordListStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    NSDictionary *logPb;
    if (self.items.count > 0) {
        FHUGCScialGroupDataModel *item = self.items[0];
        logPb = item.logPb;
        NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
        tracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
        tracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
        tracerDic[@"community_list"] = wordListStr ?: @"be_null";
        tracerDic[@"associate_cnt"] = @(self.associatedCount);
        tracerDic[@"associate_type"] = @"community_group";
        tracerDic[@"community_cnt"] = @(wordList.count);
        tracerDic[@"element_type"] = self.tracerDict[@"element_type"] ?: @"be_null";
        tracerDic[@"log_pb"] = logPb;
        [FHUserTracker writeEvent:@"associate_community_show" params:tracerDic];
    }
}

- (void)addCommunityClickLog:(FHUGCScialGroupDataModel *)model rank:(NSInteger)rank  {
    if(!model){
        return;
    }

    NSMutableArray *wordList = [NSMutableArray new];
    for (NSInteger index = 0; index < self.items.count; index++) {
        FHUGCScialGroupDataModel *item = self.items[index];
        NSDictionary *dic = @{
                @"text": item.socialGroupName ?: @"be_null",
                @"word_id": item.socialGroupId ?: @"be_null",
                @"rank": @(index)
        };
        [wordList addObject:dic];
    }
    NSError *error = NULL;
    NSData *data = [NSJSONSerialization dataWithJSONObject:wordList options:NSJSONReadingAllowFragments error:&error];
    NSString *wordListStr = @"";
    if (data && error == NULL) {
        wordListStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
    tracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    tracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    tracerDic[@"community_list"] = wordListStr ?: @"be_null";
    tracerDic[@"associate_cnt"] = @(self.associatedCount);
    tracerDic[@"associate_type"] = @"community_group";
    tracerDic[@"community_cnt"] = @(wordList.count);
    tracerDic[@"element_type"] = self.tracerDict[@"element_type"] ?: @"be_null";
    tracerDic[@"word_id"] = model.socialGroupId;
    tracerDic[@"rank"] = @(rank);
    tracerDic[@"log_pb"] = model.logPb;
    [FHUserTracker writeEvent:@"associate_community_click" params:tracerDic];
}

-(void)addSelectLog:(FHUGCScialGroupDataModel *)model rank:(NSInteger)rank{
    NSMutableDictionary *tracerDic = @{}.mutableCopy;
    tracerDic[@"card_type"] = @"left_pic";
    tracerDic[@"page_type"] = @"community_search";
    tracerDic[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    tracerDic[@"rank"] = @(rank);
    tracerDic[@"log_pb"] = model.logPb ?: @"be_null";
    tracerDic[@"click_position"] = @"select_like";
    [FHUserTracker writeEvent:@"click_select" params:tracerDic];
}

@end
