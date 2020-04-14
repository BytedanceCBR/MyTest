//
//  FHFloorTimeLineViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorPanDetailViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNewTimeLineItemCell.h"
#import "FHDetailNewModel.h"
#import "FHRefreshCustomFooter.h"
#import "FHEnvContext.h"
#import "FHDetailNewCoreDetailModel.h"
#import "FHDetailHouseNameCell.h"
#import "FHFloorPanCorePropertyCell.h"
#import "FHDetailGrayLineCell.h"
#import "FHDetailFloorPanDetailInfoModel.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHFloorPanTitleCell.h"
#import "FHFloorPanDetailPropertyCell.h"
#import "FHFloorPanDetailMutiFloorPanCell.h"
#import "FHHouseDetailSubPageViewController.h"
#import "FHDetailBottomBar.h"

@interface FHFloorPanDetailViewModel()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , weak) UITableView *infoListTable;
@property (nonatomic , strong) NSMutableArray *currentItems;
@property (nonatomic , strong) NSString *floorPanId;
@property (nonatomic , strong) FHDetailFloorPanDetailInfoModel *currentModel;
@property(nonatomic , weak) FHHouseDetailSubPageViewController *subPageVC;
@property (nonatomic, strong)   NSMutableDictionary       *elementShowCaches;

@end
@implementation FHFloorPanDetailViewModel

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView floorPanId:(NSString *)floorPanId
{
    self = [super init];
    if (self) {
        _elementShowCaches = [NSMutableDictionary new];
        self.detailController = viewController;
        _subPageVC = viewController;
        _infoListTable = tableView;
        _floorPanId = floorPanId;
        _currentItems = [NSMutableArray new];
        [self configTableView];
        WeakSelf;
        FHDetailBottomBar *bottomBar = [_subPageVC getBottomBar];
        if ([bottomBar isKindOfClass:[FHDetailBottomBar class]]) {
            bottomBar.bottomBarContactBlock = ^{
                StrongSelf;
                [wself contactAction];
            };
            bottomBar.bottomBarImBlock = ^{
                StrongSelf;
                [wself imAction];
            };
        }
        self.contactViewModel = [_subPageVC getContactViewModel];
        self.bottomBar = bottomBar;
        bottomBar.hidden = YES;
        [self startLoadData];
    }
    return self;
}

- (void)contactAction
{
    if (!self.contactViewModel) {
        return;
    }
    [self.contactViewModel contactAction];
}

- (void)imAction
{
    FHDetailContactModel *contactPhone = self.contactViewModel.contactPhone;
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"source_from"] = @"house_model_detail";
    imExtra[@"im_open_url"] = contactPhone.imOpenUrl;
    [self.contactViewModel onlineActionWithExtraDict:imExtra];
}

// 注册cell类型
- (void)registerCellClasses {
    [self.infoListTable registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderCell class])];
    
    [self.infoListTable registerClass:[FHFloorPanTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanTitleCell class])];
    
    [self.infoListTable registerClass:[FHFloorPanDetailPropertyCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanDetailPropertyCell class])];

    [self.infoListTable registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameCell class])];
    
    [self.infoListTable registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineCell class])];
    
    [self.infoListTable registerClass:[FHFloorPanDetailMutiFloorPanCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanDetailMutiFloorPanCell class])];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    // 图片头部
    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return [FHDetailPhotoHeaderCell class];
    }
    
    // 标题
    if ([model isKindOfClass:[FHFloorPanTitleCellModel class]]) {
        return [FHFloorPanTitleCell class];
    }
    
    // 灰色分割线
    if ([model isKindOfClass:[FHDetailGrayLineModel class]]) {
        return [FHDetailGrayLineCell class];
    }

    // 属性信息
    if ([model isKindOfClass:[FHFloorPanDetailPropertyCellModel class]]) {
        return [FHFloorPanDetailPropertyCell class];
    }
    
    //楼盘推荐
    if ([model isKindOfClass:[FHFloorPanDetailMutiFloorPanCellModel class]]) {
        return [FHFloorPanDetailMutiFloorPanCell class];
    }
    
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)configTableView
{
    [self registerCellClasses];
    _infoListTable.delegate = self;
    _infoListTable.dataSource = self;
}

- (void)startLoadData
{
    if (![TTReachability isNetworkConnected]) {
        [self.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
        return;
    }
    if (_floorPanId) {
        [self.detailController startLoading];
        __weak typeof(self) wSelf = self;
        self.bottomBar.hidden = YES;
        [FHHouseDetailAPI requestFloorPanDetailCoreInfoSearch:_floorPanId completion:^(FHDetailFloorPanDetailInfoModel * _Nullable model, NSError * _Nullable error) {
            if(model.data && !error)
            {
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.detailController.hasValidateData = YES;
                [wSelf processDetailData:model];
            }else
            {
                wSelf.detailController.hasValidateData = NO;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
            wSelf.bottomBar.hidden = NO;
        }];
    }
}

- (NSString *)checkPValueStr:(NSString *)str
{
    if ([str isKindOfClass:[NSString class]]) {
        return str;
    }else
    {
        return @"-";
    }
}

- (void)processDetailData:(FHDetailFloorPanDetailInfoModel *)model {
    NSMutableArray *itemsArray = [NSMutableArray new];
    
    self.currentModel = model;
    
    if (model.data.images) {
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        headerCellModel.houseImage = model.data.images;
        [self.currentItems addObject:headerCellModel];
    }
    
    if (model.data) {
        FHFloorPanTitleCellModel *cellModel = [[FHFloorPanTitleCellModel alloc] init];
        cellModel.title = model.data.title;
        cellModel.pricing = model.data.pricing;
        cellModel.pricingPerSqm = model.data.pricingPerSqm;
        cellModel.saleStatus = model.data.saleStatus;
        [self.currentItems addObject:cellModel];
    }
    
    if (model.data.baseInfo) {
        FHFloorPanDetailPropertyCellModel *cellModel = [[FHFloorPanDetailPropertyCellModel alloc] init];
        cellModel.baseInfo = model.data.baseInfo;
        [self.currentItems addObject:cellModel];
    }
    
    //楼盘户型
    if (model.data.recommend && model.data.recommend.count > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.currentItems addObject:grayLine];
        
        FHFloorPanDetailMutiFloorPanCellModel *mutiDataModel = [[FHFloorPanDetailMutiFloorPanCellModel alloc] init];
        mutiDataModel.recommend = model.data.recommend;
        mutiDataModel.subPageVC = self.subPageVC;
        for (NSInteger i = 0; i < mutiDataModel.recommend.count; i++) {
            FHDetailFloorPanDetailInfoDataRecommendModel *modelItem = mutiDataModel.recommend[i];
            if ([modelItem isKindOfClass:[FHDetailFloorPanDetailInfoDataRecommendModel class]]) {
                modelItem.index = i;
            }
        }
        [self.currentItems addObject:mutiDataModel];
    }
    
    FHDetailContactModel *contactPhone = nil;
    if (model.data.highlightedRealtor) {
        contactPhone = model.data.highlightedRealtor;
    }else {
        contactPhone = model.data.contact;
        contactPhone.unregistered = YES;
    }
    if (contactPhone.phone.length > 0) {
        contactPhone.isFormReport = NO;
    }else {
        contactPhone.isFormReport = YES;
    }
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.followStatus = model.data.userStatus.courtSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;

    [_infoListTable reloadData];
}



#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_currentItems count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.currentItems.count) {
        id data = self.currentItems[row];
        NSString *identifier = [self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHDetailBaseCell *cell = (FHDetailBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[NSClassFromString(identifier) alloc] init];
            }
            cell.baseViewModel = self;
            [cell refreshWithData:data];
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    // 添加element_show埋点
    if (!self.elementShowCaches[tempKey]) {
        self.elementShowCaches[tempKey] = @(YES);
        FHDetailBaseCell *tempCell = (FHDetailBaseCell *)cell;
        NSString *element_type = [tempCell elementTypeString:self.houseType];
        if (element_type.length > 0) {
            // 上报埋点
            NSMutableDictionary *tracerDic = self.detailTracerDic.mutableCopy;
            tracerDic[@"element_type"] = element_type;
            [tracerDic removeObjectForKey:@"card_type"];
            [tracerDic removeObjectForKey:@"enter_from"];
            [tracerDic removeObjectForKey:@"element_from"];
            [FHUserTracker writeEvent:@"element_show" params:tracerDic];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.infoListTable) {
        return;
    }
}

@end
