//
// Created by zhulijun on 2019-07-17.
//

#import <CoreLocation/CoreLocation.h>
#import "FHUGCCommunityListViewModel.h"
#import "FHUGCCommunityDistrictTabView.h"
#import "FHUGCScialGroupModel.h"
#import "FHLocManager.h"
#import "FHHouseUGCAPI.h"
#import "TTReachability.h"
#import "FHUGCCommunityCell.h"
#import "FHUGCCommunityListModel.h"
#import "FHUGCConfig.h"
#import "FHUserTracker.h"


typedef NS_ENUM(NSInteger, FHCommunityCategoryListState) {
    FHCommunityCategoryListStateIdle,//初始状态，没有请求过数据
    FHCommunityCategoryListStateLoading,//请求中
    FHCommunityCategoryListStateNetError,//请求过数据，但是网络出错了
    FHCommunityCategoryListStateOK//请求了数据，并且成功了
};

@interface FHCommunityCategoryListStateModel : NSObject
@property(nonatomic, assign) FHCommunityCategoryListState state;
@property(nonatomic, assign) CGFloat offsetY;
@property(nonatomic, strong) NSArray *communityList;
@property(nonatomic, strong) NSMutableDictionary *followDic;
@end

@implementation FHCommunityCategoryListStateModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = FHCommunityCategoryListStateIdle;
        self.offsetY = 0.1f;
        self.communityList = [NSArray array];
        self.followDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setCommunityList:(NSArray *)communityList{
    _communityList = communityList;
    if(_communityList){
        [self.followDic removeAllObjects];
        [_communityList enumerateObjectsUsingBlock:^(FHUGCScialGroupDataModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[FHUGCScialGroupDataModel class]] && obj.socialGroupId.length > 0){
                [self.followDic setValue:obj forKey:obj.socialGroupId];
            }
        }];
    }
}
@end

@interface FHUGCCommunityListViewModel () <FHUGCCommunityCategoryViewDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property(nonatomic, assign) FHCommunityListType listType;
@property(nonatomic, weak) UITableView *tableView;
@property(nonatomic, weak) FHUGCCommunityCategoryView *categoryView;
@property(nonatomic, weak) UILabel *districtListTitleLabel;
@property(nonatomic, weak) FHUGCCommunityListViewController *viewController;
@property(nonatomic, strong) NSArray <FHUGCCommunityDistrictTabModel *> *categories;
@property(nonatomic, strong) FHUGCCommunityDistrictTabModel *curCategory;
@property(nonatomic, strong) NSMutableDictionary *dataDic;
@end

@implementation FHUGCCommunityListViewModel

- (instancetype)initWithTableView:(UITableView *)tableView
                     categoryView:(FHUGCCommunityCategoryView *)categoryView
               districtTitleLabel:(UILabel *)districtTitleLabel
                       controller:(FHUGCCommunityListViewController *)viewController
                         listType:(FHCommunityListType)listType; {
    self = [super init];
    if (self) {
        self.districtListTitleLabel = districtTitleLabel;
        self.tableView = tableView;
        self.categoryView = categoryView;
        self.viewController = viewController;
        self.listType = listType;
        [self initData];
        [self initView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDidLoad;{
    [self.categoryView refreshWithCategories:self.categories];
    [self.categoryView select:self.viewController.defaultSelectDistrictTab selectType:FHUGCCommunityDistrictTabSelectTypeDefault];
}

- (void)initData {
    self.categories = [self categoriesFromUgcConfig];
    self.dataDic = [NSMutableDictionary dictionary];
    for (FHUGCCommunityDistrictTabModel *categoryItem in self.categories) {
        self.dataDic[@(categoryItem.categoryId)] = [[FHCommunityCategoryListStateModel alloc] init];
    }
}

- (void)initView {
    self.categoryView.delegate = self;
    [self.tableView registerClass:[FHUGCCommunityCell class] forCellReuseIdentifier:@"FHUGCCommunityCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)onCategorySelect:(FHUGCCommunityDistrictTabModel *)select
                 before:(FHUGCCommunityDistrictTabModel *)before selectType:(FHUGCCommunityDistrictTabSelectType)selectType{
    if (!select) {
        return;
    }
    //记录之前选则分类内容的滚动位置
    if (before) {
        FHCommunityCategoryListStateModel *beforeState = self.dataDic[@(before.categoryId)];
        CGFloat offsetY = self.tableView.contentOffset.y;
        //这个地方是处理向上滑到顶部继续拉或者向下滑到底部继续拉的同时，另一只手点击tab切换的情况
        if(offsetY <= 0){
            offsetY = fmaxf(-self.tableView.contentInset.top, offsetY);
        }else{
            CGFloat tableViewHeight = self.tableView.bounds.size.height;
            CGFloat tableViewContentHeight = self.tableView.contentSize.height;
            CGFloat tableViewInsetBottom = self.tableView.contentInset.bottom;
            CGFloat maxOffSetY = fmaxf((tableViewContentHeight + tableViewInsetBottom) - tableViewHeight,0.0f);
            offsetY = fminf(offsetY,maxOffSetY);
        }
        beforeState.offsetY = offsetY;
    }
    
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(select.categoryId)];
    if (!stateModel) {
        return;
    }
    
    self.curCategory = select;
    NSString* districtListTitle = [NSString stringWithFormat:@"%@的圈子",select.title];
    if(select.categoryId == FHUGCCommunityDistrictTabIdFollow){
        districtListTitle = @"我关注的圈子";
    }
    self.districtListTitleLabel.text = districtListTitle;
    [self onCateStateChange:self.curCategory reload:YES resetOffset:YES];
    [self addClickOptionsLog:selectType];
}

- (void)requestCommunityList:(FHUGCCommunityDistrictTabModel *)category {
    if (!category) {
        return;
    }
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(category.categoryId)];
    if (!stateModel) {
        return;
    }
    
    if (![TTReachability isNetworkConnected]) {
        stateModel.state = FHCommunityCategoryListStateNetError;
        [self onCateStateChange:category reload:NO resetOffset:YES];
        return;
    }
    
    stateModel.state = FHCommunityCategoryListStateLoading;
    [self onCateStateChange:category reload:NO resetOffset:YES];
    
    CLLocation *currentLocation = [FHLocManager sharedInstance].currentLocaton;
    WeakSelf;
    [FHHouseUGCAPI requestCommunityList:category.categoryId source:@"social_group_list" latitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude class:[FHUGCCommunityListModel class] completion:^(id <FHBaseModelProtocol> _Nonnull model, NSError *_Nonnull error) {
        FHUGCCommunityListModel *listModel = (FHUGCCommunityListModel *) model;
        if (error || !listModel || !(listModel.data)) {
            if (error.code != -999) {
                stateModel.state = FHCommunityCategoryListStateNetError;
                [wself onCateStateChange:category reload:NO resetOffset:YES];
            }
            return;
        }
        stateModel.state = FHCommunityCategoryListStateOK;
        stateModel.offsetY = 0.0f;
        stateModel.communityList = listModel.data.socialGroupList ?: [NSArray array];
        [wself onCateStateChange:category reload:NO resetOffset:YES];
    }];
}

/**
 ** reload 如果当前状态为家在错误，是否reload
 ** resetOffset 如果切换回到某一个列表，是否需要恢复之前的offset
 **/
- (void)onCateStateChange:(FHUGCCommunityDistrictTabModel *)category reload:(BOOL)reload resetOffset:(BOOL)resetOffset{
    if (!self.curCategory) {
        return;
    }
    if (self.curCategory.categoryId != category.categoryId) {
        return;
    }
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    if (!stateModel) {
        return;
    }
    if (stateModel.state == FHCommunityCategoryListStateIdle) {
        [self requestCommunityList:category];
    } else if (stateModel.state == FHCommunityCategoryListStateLoading) {
        [self showLoading];
    } else if (stateModel.state == FHCommunityCategoryListStateNetError) {
        if(reload){
            [self requestCommunityList:category];
        }else{
            [self showNetWorkError];
        }
        
    } else if (stateModel.state == FHCommunityCategoryListStateOK) {
        [self showLoaded:resetOffset];
    }
}

/**
 ** resetOffset 如果切换回到某一个列表，是否需要恢复之前的offset
 **/
- (void)showLoaded:(BOOL)resetOffset{
    if (!self.curCategory) {
        return;
    }
    [self hideLoading];
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    if (stateModel.communityList.count <= 0) {
        self.viewController.errorView.hidden = NO;
        NSString *tips = @"你还没有关注任何圈子";
        if (self.curCategory.categoryId == FHUGCCommunityDistrictTabIdRecommend) {
            // 推荐
            tips = @"更多圈子正在开通，敬请期待";
        }
        [self.viewController.errorView showEmptyWithTip:tips errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        return;
    }
    
    self.viewController.errorView.hidden = YES;
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    if(resetOffset){
        CGPoint offset = self.tableView.contentOffset;
        offset.y = stateModel.offsetY;
        [self.tableView setContentOffset:offset animated:NO];
    }
}

- (void)followStateChanged:(NSNotification *)notification {
    BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
    NSString *socialGroupId = notification.userInfo[@"social_group_id"];
    
    if(!self.dataDic || [self.dataDic allValues].count <= 0 || isEmptyString(socialGroupId)){
        return;
    }
    NSMutableDictionary *dataDic = [self.dataDic mutableCopy];
    
    BOOL shoulReloadData;
    for(FHCommunityCategoryListStateModel* item in [self.dataDic allValues]){
        if(!item || item.communityList.count <= 0){
            continue;
        }
        FHUGCScialGroupDataModel* community = item.followDic[socialGroupId];
        if(community){
            [[FHUGCConfig sharedInstance] updateScialGroupDataModel:community byFollowed:followed];
            shoulReloadData = YES;
        }
    }
    [self onCateStateChange:self.curCategory reload:NO resetOffset:NO];
}


- (void)showNetWorkError {
    [self hideLoading];
    self.tableView.hidden = YES;
    self.viewController.errorView.hidden = NO;
    [self.viewController.errorView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
}

- (void)showLoading {
    self.tableView.hidden = YES;
    self.viewController.errorView.hidden = YES;
    [self.viewController startLoading];
}

- (void)hideLoading {
    [self.viewController endLoading];
}

- (void)retryLoadData {
    [self requestCommunityList:self.curCategory];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    return stateModel.communityList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    if (stateModel.communityList.count > 0) {
        FHUGCScialGroupDataModel *model = stateModel.communityList[indexPath.row];
        FHUGCCommunityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FHUGCCommunityCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        FHUGCCommunityCellType cellType = FHUGCCommunityCellTypeFollow;
        if (self.listType == FHCommunityListTypeChoose) {
            cellType = FHUGCCommunityCellTypeChoose;
        } else {
            if (self.curCategory.categoryId == FHUGCCommunityDistrictTabIdFollow) {
                cellType = FHUGCCommunityCellTypeNone;
            }
        }
        [cell refreshWithData:model type:cellType];
        NSMutableDictionary* followTracerDict = [self joinTracerDict:indexPath.row data:model];
        cell.followButton.tracerDic = followTracerDict;
        return cell;
    }
    
    FHUGCCommunityCell *noCrashCell = [[FHUGCCommunityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FHUGCCommunityCell"];
    return noCrashCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    if (stateModel.communityList.count > 0) {
        FHUGCScialGroupDataModel *model = stateModel.communityList[indexPath.row];
        return [FHUGCCommunityCell heightForData:model];
    }
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    NSInteger row = indexPath.row;
    if (row >= 0 && row < stateModel.communityList.count) {
        FHUGCScialGroupDataModel *data = stateModel.communityList[row];
        //        [self addCommunityClickLog:data rank:row];
        
        if (self.listType == FHCommunityListTypeChoose) {
            [self addSelectLog:indexPath.row data:data];
            [self.viewController onItemSelected:data indexPath:indexPath];
            return;
        }
        
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = data.socialGroupId;
        dict[@"tracer"] = @{@"origin_from": self.viewController.tracerDict[@"origin_from"] ?: @"be_null",
                            @"enter_from": [self categoryName],
                            @"enter_type": @"click",
                            @"rank":@(row),
                            @"log_pb": data.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        // 跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    NSInteger row = indexPath.row;
    if (row >= 0 && row < stateModel.communityList.count) {
        FHUGCScialGroupDataModel *data = stateModel.communityList[row];
        [self addCommunityGroupShowLog:row data:data];
    }
}

- (NSArray<FHUGCCommunityDistrictTabModel *> *)categoriesFromUgcConfig {
    NSArray *ugcDistrict = [[FHUGCConfig sharedInstance] configData].data.ugcDistrict;
    if (ugcDistrict.count <= 0) {
        //ugc config没有，返回关注与推荐
        NSMutableArray<FHUGCCommunityDistrictTabModel *> *mockArray = [NSMutableArray array];
        FHUGCCommunityDistrictTabModel* recommond = [[FHUGCCommunityDistrictTabModel alloc] init];
        recommond.categoryId = FHUGCCommunityDistrictTabIdRecommend;
        recommond.title = @"推荐";
        
        FHUGCCommunityDistrictTabModel* follow = [[FHUGCCommunityDistrictTabModel alloc] init];
        follow.categoryId = FHUGCCommunityDistrictTabIdFollow;
        follow.title = @"关注";
        
        [mockArray addObject:follow];
        [mockArray addObject:recommond];
        return [mockArray copy];
    }
    
    NSMutableArray<FHUGCCommunityDistrictTabModel *> *mutableArray = [NSMutableArray array];
    for (FHUGCConfigDataDistrictModel *ugcDistrictItem in ugcDistrict) {
        if (!isEmptyString(ugcDistrictItem.districtName)) {
            FHUGCCommunityDistrictTabModel *model = [[FHUGCCommunityDistrictTabModel alloc] init];
            model.categoryId = ugcDistrictItem.districtId;
            model.title = ugcDistrictItem.districtName;
            model.selected = NO;
            [mutableArray addObject:model];
        }
    }
    return [mutableArray copy];
}

-(NSString*)categoryName{
    return @"all_community_list";
}

-(NSMutableDictionary*)joinTracerDict:(NSInteger)position data:(FHUGCScialGroupDataModel *)data{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"page_type"] = @"all_community_list";
    params[@"card_type"] = @"left_pic";
    params[@"house_type"] = @"community";
    params[@"rank"] = @(position);
    params[@"log_pb"] = data.logPb;
    NSString* classifyLabel = @"be_null";
    if(self.curCategory.categoryId == FHUGCCommunityDistrictTabIdFollow){
        classifyLabel = @"join";
    }else if(self.curCategory.categoryId == FHUGCCommunityDistrictTabIdRecommend){
        classifyLabel = @"recommend";
    }else{
        classifyLabel = @"district";
    }
    params[@"calssify_label"] = classifyLabel;
    return params;
}

-(void)addSelectLog:(NSInteger)position data:(FHUGCScialGroupDataModel *)data{
    NSMutableDictionary* selectTracerDict = [self joinTracerDict:position data:data];
    selectTracerDict[@"click_position"] = @"select_like";
    [FHUserTracker writeEvent:@"click_select" params:selectTracerDict];
}

-(void)addClickOptionsLog:(FHUGCCommunityDistrictTabSelectType)selectType{
    //进入默认选中不上报
    if(selectType ==FHUGCCommunityDistrictTabSelectTypeDefault){
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"category_name"] = [self categoryName];
    NSString* classifyLabel;
    if(self.curCategory.categoryId == FHUGCCommunityDistrictTabIdFollow){
        classifyLabel = @"join";
    }else if(self.curCategory.categoryId == FHUGCCommunityDistrictTabIdRecommend){
        classifyLabel = @"recommend";
    }else{
        classifyLabel = @"district";
    }
    params[@"click_positon"] = classifyLabel;
    [FHUserTracker writeEvent:@"click_options" params:params];
}

- (void)addCommunityGroupShowLog:(NSInteger)position data:(FHUGCScialGroupDataModel *)data{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"page_type"] = [self categoryName];
    params[@"card_type"] = @"left_pic";
    params[@"house_type"] = @"community";
    params[@"rank"] = @(position);
    params[@"log_pb"] = data.logPb;
    NSString* classifyLabel = @"be_null";
    if(self.curCategory.categoryId == FHUGCCommunityDistrictTabIdFollow){
        classifyLabel = @"join";
    }else if(self.curCategory.categoryId == FHUGCCommunityDistrictTabIdRecommend){
        classifyLabel = @"recommend";
    }else{
        classifyLabel = @"district";
    }
    params[@"calssify_label"] = classifyLabel;
    [FHUserTracker writeEvent:@"community_group_show" params:params];
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"category_name"] = [self categoryName];
    [FHUserTracker writeEvent:@"enter_category" params:params];
}

- (void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ?: @"be_null";
    params[@"enter_type"] = self.tracerDict[@"enter_type"] ?: @"be_null";
    params[@"category_name"] = [self categoryName];
    params[@"stay_time"] = [NSNumber numberWithInteger:duration];
    [FHUserTracker writeEvent:@"stay_category" params:params];
}

@end
