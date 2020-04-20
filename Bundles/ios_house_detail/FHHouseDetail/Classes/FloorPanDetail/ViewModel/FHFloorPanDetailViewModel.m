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

#import "FHDetailMediaHeaderCorrectingCell.h"
#import "FHDetailPropertyListCorrectingCell.h"
#import "FHFloorPanDetailModuleHelper.h"
#import "FHOldDetailDisclaimerCell.h"
#import "FHDetailListSectionTitleCell.h"
#import "FHFloorPanDetailPropertyListCell.h"

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
    // todo zjing test
    if (!self.contactViewModel) {
        return;
    }
    NSMutableDictionary *extraDic = @{}.mutableCopy;
    NSNumber *cluePage = nil;
    if(self.contactViewModel.contactPhone.phone.length > 0) {
        cluePage = @(FHClueCallPageTypeCFloorPlan);
    }else {
        cluePage = @(FHClueFormPageTypeCFloorPlan);
    }
    if (cluePage) {
        extraDic[kFHCluePage] = cluePage;
    }

    [self.contactViewModel contactActionWithExtraDict:extraDic];
}

- (void)imAction
{
    // todo zjing test
    FHDetailContactModel *contactPhone = self.contactViewModel.contactPhone;
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"source_from"] = @"house_model_detail";
    imExtra[@"im_open_url"] = contactPhone.imOpenUrl;
    imExtra[kFHClueEndpoint] = [NSString stringWithFormat:@"%ld",FHClueEndPointTypeC];
    imExtra[kFHCluePage] = [NSString stringWithFormat:@"%ld",FHClueIMPageTypeFloorplan];
    imExtra[@"from"] = @"app_floorplan";
    [self.contactViewModel onlineActionWithExtraDict:imExtra];
}

// 注册cell类型
- (void)registerCellClasses {
    //头部轮播
    [self.infoListTable registerClass:[FHDetailMediaHeaderCorrectingCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailMediaHeaderCorrectingModel class])];
    
    //户型信息
    [self.infoListTable registerClass:[FHFloorPanDetailPropertyListCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanDetailPropertyListModel class])];
    //楼盘推荐
    [self.infoListTable registerClass:[FHFloorPanDetailMutiFloorPanCell class] forCellReuseIdentifier:NSStringFromClass([FHFloorPanDetailMutiFloorPanCellModel class])];
    //标题
    [self.infoListTable registerClass:[FHDetailListSectionTitleCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailListSectionTitleModel class])];
    //免责声明
    [self.infoListTable registerClass:[FHOldDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHOldDetailDisclaimerModel class])];
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
    //头部轮播图
    if (1) {
        FHMultiMediaItemModel *itemModel = nil;
        FHDetailMediaHeaderCorrectingModel *headerCellModel = [[FHDetailMediaHeaderCorrectingModel alloc] init];
        if ([model.data.images isKindOfClass:[NSArray class]] && model.data.images.count > 0) {
            NSMutableArray *houseImageList = @[].mutableCopy;
            FHDetailOldDataHouseImageDictListModel *houseImageDictList = [[FHDetailOldDataHouseImageDictListModel alloc] init];
            NSMutableArray *houseImages = model.data.images;
            houseImageDictList.houseImageList = houseImages;
            [houseImageList addObject:houseImageDictList];
            headerCellModel.houseImageDictList = houseImageList;
        }
        FHDetailHouseTitleModel *houseTitleModel = [[FHDetailHouseTitleModel alloc] init];
        houseTitleModel.titleStr = model.data.title;
        if (model.data.saleStatus) {
            FHHouseTagsModel *tag = [[FHHouseTagsModel alloc]init];
            tag.backgroundColor = model.data.saleStatus.backgroundColor;
            tag.content = model.data.saleStatus.content;
            tag.id = model.data.saleStatus.id;
            tag.textColor = model.data.saleStatus.textColor;
            houseTitleModel.tags = @[tag];
        }
        houseTitleModel.totalPicing = model.data.pricing;
        houseTitleModel.isFloorPan = YES;
        headerCellModel.vedioModel = itemModel;
        headerCellModel.contactViewModel = self.contactViewModel;
        headerCellModel.isInstantData = nil;
        headerCellModel.titleDataModel = houseTitleModel;
        [self.currentItems addObject:headerCellModel];
    }
    //基础信息
    if (model.data.baseInfo) {
        FHFloorPanDetailPropertyListModel *propertyModel = [[FHFloorPanDetailPropertyListModel alloc] init];
        propertyModel.baseInfo = model.data.baseInfo;
        propertyModel.houseModelType = FHFloorPanHouseModelTypeCoreInfo;
        [self.currentItems addObject:propertyModel];
        
    }
    
    //楼盘户型
    if (model.data.recommend && model.data.recommend.count > 0) {
        
        FHFloorPanDetailMutiFloorPanCellModel *mutiDataModel = [[FHFloorPanDetailMutiFloorPanCellModel alloc] init];
        mutiDataModel.recommend = model.data.recommend;
        mutiDataModel.subPageVC = self.subPageVC;
        for (NSInteger i = 0; i < mutiDataModel.recommend.count; i++) {
            FHDetailFloorPanDetailInfoDataRecommendModel *modelItem = mutiDataModel.recommend[i];
            if ([modelItem isKindOfClass:[FHDetailFloorPanDetailInfoDataRecommendModel class]]) {
                modelItem.index = i;
            }
        }
        mutiDataModel.houseModelType = FHFloorPanHouseModelTypeFloorPlan;
        [self.currentItems addObject:mutiDataModel];
    }
    // 免责声明
    if (model.data.disclaimer) {
        FHOldDetailDisclaimerModel *infoModel = [[FHOldDetailDisclaimerModel alloc] init];
        infoModel.disclaimer = model.data.disclaimer;
        //infoModel.disclaimer.text = @"楼盘信息仅供参考，请以开发商公示为准，若有误可反馈纠错";
        infoModel.houseModelType = FHHouseModelTypeDisclaimer;
        [self.currentItems addObject:infoModel];
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
    self.currentItems = [FHFloorPanDetailModuleHelper moduleClassificationMethod:self.currentItems];
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
        NSString *identifier = NSStringFromClass([data class]);//[self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHDetailBaseCell *cell = (FHDetailBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[NSClassFromString(identifier) alloc] init];
            }
            cell.backgroundColor = [UIColor clearColor];
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
   
    [self.detailController refreshContentOffset:scrollView.contentOffset];
}

@end
