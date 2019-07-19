//
// Created by zhulijun on 2019-07-17.
//

#import <CoreLocation/CoreLocation.h>
#import "FHUGCCommunityListViewModel.h"
#import "FHUGCCommunityDistrictTabView.h"
#import "FHUGCMyInterestModel.h"
#import "FHLocManager.h"
#import "FHHouseUGCAPI.h"
#import "TTReachability.h"
#import "FHUGCCommunityCell.h"
#import "FHUGCCommunityListModel.h"
#import "FHUGCConfig.h"


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
@end

@implementation FHCommunityCategoryListStateModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.state = FHCommunityCategoryListStateIdle;
        self.offsetY = 0.1f;
        self.communityList = [NSArray array];
    }
    return self;
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
    }
    return self;
}

- (void)viewWillAppear {
    [self.categoryView refreshWithCategories:self.categories];
    [self.categoryView select:self.viewController.defaultSelectDistrictTab];
}

- (void)viewWillDisappear {

}

- (void)viewDidAppear {

}

- (void)viewDidDisappear {

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

- (void)onCategorySelect:(FHUGCCommunityDistrictTabModel *)select before:(FHUGCCommunityDistrictTabModel *)before {
    if (!select) {
        return;
    }
    //记录之前选则分类内容的滚动位置
    if (before) {
        FHCommunityCategoryListStateModel *beforeState = self.dataDic[@(before.categoryId)];
        beforeState.offsetY = self.tableView.contentOffset.y;
    }

    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(select.categoryId)];
    if (!stateModel) {
        return;
    }

    self.curCategory = select;
    NSString* districtListTitle = [NSString stringWithFormat:@"%@的小区圈",select.title];
    if(select.categoryId == FHUGCCommunityDistrictTabIdFollow){
        districtListTitle = @"我关注的小区圈";
    }
    self.districtListTitleLabel.text = districtListTitle;
    [self onCateStateChange:self.curCategory];
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
        [self onCateStateChange:category];
        return;
    }

    stateModel.state = FHCommunityCategoryListStateLoading;
    [self onCateStateChange:category];

    CLLocation *currentLocation = [FHLocManager sharedInstance].currentLocaton;
    WeakSelf;
    [FHHouseUGCAPI requestCommunityList:category.categoryId source:@"social_group_list" latitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude class:[FHUGCCommunityListModel class] completion:^(id <FHBaseModelProtocol> _Nonnull model, NSError *_Nonnull error) {
        FHUGCCommunityListModel *listModel = (FHUGCCommunityListModel *) model;
        if (error || !listModel || !(listModel.data)) {
            if (error.code != -999) {
                stateModel.state = FHCommunityCategoryListStateNetError;
                [wself onCateStateChange:category];
            }
            return;
        }
        stateModel.state = FHCommunityCategoryListStateOK;
        stateModel.offsetY = 0.0f;
        stateModel.communityList = listModel.data.socialGroupList ?: [NSArray array];
        [wself onCateStateChange:category];
    }];
}

- (void)onCateStateChange:(FHUGCCommunityDistrictTabModel *)category {
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
        [self showNetWorkError];
    } else if (stateModel.state == FHCommunityCategoryListStateOK) {
        [self showLoaded];
    }
}

- (void)showLoaded {
    if (!self.curCategory) {
        return;
    }
    [self hideLoading];
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    if (stateModel.communityList.count <= 0) {
        self.viewController.errorView.hidden = NO;
        [self.viewController.errorView showEmptyWithTip:@"你还没有关注任何小区" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        return;
    }

    self.viewController.errorView.hidden = YES;
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    CGPoint offset = self.tableView.contentOffset;
    offset.y = stateModel.offsetY;
    [self.tableView setContentOffset:offset animated:NO];
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
        FHUGCMyInterestDataRecommendSocialGroupsModel *model = stateModel.communityList[indexPath.row];
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
        return cell;
    }

    FHUGCCommunityCell *noCrashCell = [[FHUGCCommunityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FHUGCCommunityCell"];
    return noCrashCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
    FHCommunityCategoryListStateModel *stateModel = self.dataDic[@(self.curCategory.categoryId)];
    if (stateModel.communityList.count > 0) {
        FHUGCMyInterestDataRecommendSocialGroupsModel *model = stateModel.communityList[indexPath.row];
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
            [self.viewController onItemSelected:data indexPath:indexPath];
            return;
        }

        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = data.socialGroupId;
        dict[@"tracer"] = @{@"enter_from": @"community_search_show",
                @"enter_type": @"click",
                @"log_pb": data.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        // 跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (NSArray<FHUGCCommunityDistrictTabModel *> *)categoriesFromUgcConfig {
    NSArray *ugcDistrict = [[FHUGCConfig sharedInstance] configData].data.ugcDistrict;
    if (ugcDistrict.count <= 0) {
        return [NSArray array];
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

@end
