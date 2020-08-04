//
//  FHUGCUserFollowListController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/10/14.
//

#import "FHUGCUserFollowListController.h"
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
#import "FHUGCUserFollowSearchView.h"
#import "FHUGCUserFollowModel.h"
#import "FHUGCUserFollowListVM.h"
#import "FHUGCUserFollowTC.h"
#import "FHRefreshCustomFooter.h"
#import "UIScrollView+Refresh.h"
#import "FHUserTracker.h"
#import "UIViewController+Track.h"

@interface FHUGCUserFollowListController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) FHUGCSuggectionTableView *tableView;// sug列表
@property(nonatomic, strong) FHUGCSuggectionTableView *userTableView;// 用户关注列表
@property(nonatomic, strong) NSMutableArray *items;// sug 列表
@property(nonatomic, weak) TTHttpTask *sugHttpTask;
@property (nonatomic, assign)   NSInteger       sugOffset;
@property (nonatomic, assign)   BOOL       hasMore;
@property(nonatomic, copy) NSString *searchText;
@property(nonatomic, assign) BOOL isViewAppearing;
@property(nonatomic, assign) BOOL needReloadData;
@property(nonatomic, assign) BOOL isKeybordShow;
@property(nonatomic, assign) BOOL keyboardVisible;
@property(nonatomic, assign) NSInteger associatedCount;
@property (nonatomic, strong)   FHUGCUserFollowSearchView       *searchView;
@property (nonatomic, copy)     NSString       *socialGroupId;
@property (nonatomic, strong)   FHUGCUserFollowListVM       *viewModel;// 用户列表VM
@property (nonatomic, strong)   FHRefreshCustomFooter       *refreshFooter;
@end

@implementation FHUGCUserFollowListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSDictionary *params = paramObj.allParams;
        NSString *social_group_id = params[@"social_group_id"];
        self.associatedCount = 0;
        self.socialGroupId = social_group_id;
        self.tracerDict[@"page_type"] = @"community_group_join_member";
        self.ttTrackStayEnable = YES;
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
        [weakSelf.searchView.searchInput resignFirstResponder];
    };
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.emptyView hideEmptyView];
    [self startLoadData];

    [self addGoDetailLog];
    
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
        self.isKeybordShow = NO;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.searchView.searchInput becomeFirstResponder];
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.isViewAppearing = NO;
    [self addStayPageLog];
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
    self.isKeybordShow = NO;
    self.keyboardVisible = NO;
    self.sugOffset = 0;
}

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
    self.ttNeedHideBottomLine = YES;
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    
    self.searchView = [[FHUGCUserFollowSearchView alloc] init];
    [self.view addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(height);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(36+4);
    }];
    
    self.searchView.searchInput.delegate = self;
    self.searchView.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledTextChangeNoti:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setupUI {
    [self setupNaviBar];

    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    // 用户列表
    self.userTableView = [self configTableView2];
    [self.view addSubview:self.userTableView];
    self.viewModel = [[FHUGCUserFollowListVM alloc] initWithController:self tableView:self.userTableView];
    self.viewModel.socialGroupId = self.socialGroupId;
    
    [self.userTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.view);
    }];
    
    // sug列表
    [self configTableView];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[FHUGCUserFollowTC class] forCellReuseIdentifier:@"FHUGCUserFollowTC_Sug"];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.view);
    }];
    _tableView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        if (![TTReachability isNetworkConnected]) {
            [[ToastManager manager] showToast:@"网络异常"];
            [weakSelf updateTableViewWithMoreData:weakSelf.tableView.hasMore];
        } else {
            [weakSelf requestSuggestion:weakSelf.searchText];
        }
    }];
    [self.refreshFooter setUpNoMoreDataText:@""];
    self.tableView.mj_footer = self.refreshFooter;
    self.tableView.mj_footer.hidden = YES;
}

- (void)configTableView {
    _tableView = [[FHUGCSuggectionTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) weakSelf = self;
    _tableView.handleTouch = ^{
        [weakSelf.view endEditing:YES];
    };
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 66;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
}

- (UITableView *)configTableView2 {
    FHUGCSuggectionTableView *tableView = [[FHUGCSuggectionTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    __weak typeof(self) weakSelf = self;
    tableView.handleTouch = ^{
        [weakSelf.view endEditing:YES];
    };
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    tableView.estimatedRowHeight = 66;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    return tableView;
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        // 请求用户列表
        [self.viewModel requestUserList];
    } else {
        //[[ToastManager manager] showToast:@"网络异常"];
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

- (void)setHasValidateData:(BOOL)hasValidateData {
    [super setHasValidateData:hasValidateData];
    self.searchView.hidden = !hasValidateData;
}

// 文本框文字变化，进行sug请求
- (void)textFiledTextChangeNoti:(NSNotification *)noti {

    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }

    NSInteger maxCount = 80;
    NSString *text = self.searchView.searchInput.text;
    UITextRange *selectedRange = [self.searchView.searchInput markedTextRange];
    // 获取高亮部分
    UITextPosition *position = [self.searchView.searchInput positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，说明不是拼音输入
    if (position) {
        return;
    }
    if (text.length > maxCount) {
        text = [text substringToIndex:maxCount];
        self.searchView.searchInput.text = text;
    }
    BOOL hasText = text.length > 0;
    self.searchText = text;
    if (hasText) {
        self.tableView.hidden = NO;
        self.sugOffset = 0;
        self.hasMore = NO;
        [self requestSuggestion:text];
    } else {
        // 清空sug列表数据
        [self.items removeAllObjects];
        [self.tableView reloadData];
        self.tableView.hidden = YES;
    }
}

// sug建议
- (void)requestSuggestion:(NSString *)text {
    if (self.sugHttpTask) {
        [self.sugHttpTask cancel];
    }
    __weak typeof(self) weakSelf = self;
    self.sugHttpTask = [FHHouseUGCAPI requestFollowSugSearchByText:text socialGroupId:self.socialGroupId offset:self.sugOffset class:[FHUGCUserFollowModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (model != NULL && error == NULL) {
            weakSelf.associatedCount +=1;
            [weakSelf.items removeAllObjects];
            [weakSelf processDataWith:(FHUGCUserFollowModel *)model];
        } else {
            [weakSelf processDataWith:nil];
        }
    }];
}

- (void)processDataWith:(FHUGCUserFollowModel *)model {
    if (model && [model isKindOfClass:[FHUGCUserFollowModel class]] && model.data) {
        if (model.data.suggestList.count > 0) {
            [self.items addObjectsFromArray:model.data.suggestList];
        }
        self.hasMore = model.data.hasMore;
        self.sugOffset = model.data.offset;
    }
    // 后处理
    if (self.items.count > 0) {
        self.tableView.hasMore = self.hasMore;
        [self updateTableViewWithMoreData:self.hasMore];
        [self.tableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.tableView.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@""];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self addMemberSearchLog];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

// 输入框执行搜索
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    
//}

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
    FHUGCUserFollowTC *cell = (FHUGCUserFollowTC *) [tableView dequeueReusableCellWithIdentifier:@"FHUGCUserFollowTC_Sug" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger row = indexPath.row;
    if (row < self.items.count) {
        FHUGCUserFollowDataFollowListModel *itemData = (FHUGCUserFollowDataFollowListModel *)self.items[row];
        [cell refreshWithData:itemData];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

// 联想词点击
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        // 键盘是否显示
        self.isKeybordShow = self.keyboardVisible;
        
        FHUGCUserFollowDataFollowListModel *data = self.items[row];
        if (data.schema.length > 0) {
            // 跳转到个人主页
            NSURL *openUrl = [NSURL URLWithString:data.schema];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
        }
    }
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Tracer

-(void)addGoDetailLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [FHUserTracker writeEvent:@"go_detail" params:tracerDict];
}

-(void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_page" params:tracerDict];
    [self tt_resetStayTime];
}

-(void)addMemberSearchLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    [FHUserTracker writeEvent:@"click_member_search" params:tracerDict];
}

// 联想词埋点
/*
- (void)addAssociateCommunityShowLog {
    NSMutableArray *wordList = [NSMutableArray new];
    for (NSInteger index = 0; index < self.items.count; index++) {
        FHUGCUserFollowDataFollowListModel *item = self.items[index];
        NSDictionary *dic = @{
                @"text": item.userName ?: @"be_null",
                @"word_id": item.userId ?: @"be_null",
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
    tracerDic[@"community_list"] = wordListStr ?: @"be_null";
    tracerDic[@"associate_cnt"] = @(self.associatedCount);
    tracerDic[@"associate_type"] = @"join_menber";
    tracerDic[@"community_cnt"] = @(wordList.count);
    tracerDic[@"element_type"] = self.tracerDict[@"element_type"] ?: @"be_null";
    [FHUserTracker writeEvent:@"associate_member_show" params:tracerDic];
}

- (void)addCommunityClickLog:(FHUGCUserFollowDataFollowListModel *)model rank:(NSInteger)rank  {
    if(!model){
        return;
    }

    NSMutableArray *wordList = [NSMutableArray new];
    for (NSInteger index = 0; index < self.items.count; index++) {
        FHUGCUserFollowDataFollowListModel *item = self.items[index];
        NSDictionary *dic = @{
                @"text": item.userName ?: @"be_null",
                @"word_id": item.userId ?: @"be_null",
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
    tracerDic[@"community_list"] = wordListStr ?: @"be_null";
    tracerDic[@"associate_cnt"] = @(self.associatedCount);
    tracerDic[@"associate_type"] = @"join_menber";
    tracerDic[@"community_cnt"] = @(wordList.count);
    tracerDic[@"element_type"] = self.tracerDict[@"element_type"] ?: @"be_null";
    tracerDic[@"word_id"] = model.userId;
    tracerDic[@"rank"] = @(rank);
    [FHUserTracker writeEvent:@"associate_member_click" params:tracerDic];
}
*/
@end

