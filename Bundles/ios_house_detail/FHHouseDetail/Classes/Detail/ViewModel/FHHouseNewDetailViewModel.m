//
//  FHHouseNewDetailViewModel.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHHouseNewDetailViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNewModel.h"
#import "FHDetailBaseCell.h"
#import "FHDetailNearbyMapCell.h"
#import "FHDetailPhotoHeaderCell.h"
#import "FHDetailHouseNameCell.h"
#import "FHDetailNewHouseCoreInfoCell.h"
#import "FHDetailNewHouseNewsCell.h"
#import "FHDetailNewTimeLineItemCell.h"
#import "FHDetailGrayLineCell.h"
#import "FHDetailNewMutiFloorPanCell.h"
#import "FHDetailRelatedHouseResponseModel.h"
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHDetailRelatedCourtModel.h"
#import "FHNewHouseItemModel.h"
#import "FHDetailDisclaimerCell.h"
#import "FHDetailNewListSingleImageCell.h"
#import "FHDetailStaticMapCell.h"
#import <HMDTTMonitor.h>
#import <FHHouseBase/FHCommonDefines.h>

@interface FHHouseNewDetailViewModel ()

@property (nonatomic, strong , nullable) FHDetailRelatedCourtModel *relatedHouseData;

@property (nonatomic, strong , nullable) FHDetailNewModel *dataModel;
//@property (nonatomic, strong , nullable) FHDetailNewModel *newDetailDataModel;

@end

@implementation FHHouseNewDetailViewModel

// 注册cell类型
- (void)registerCellClasses {

    [self.tableView registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderModel class])];
    
    [self.tableView registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameModel class])];
    
    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineModel class])];
    
    [self.tableView registerClass:[FHDetailNewHouseCoreInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewHouseCoreInfoModel class])];
    
    [self.tableView registerClass:[FHDetailNewMutiFloorPanCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewDataFloorpanListModel class])];
    
    [self.tableView registerClass:[FHDetailNewHouseNewsCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewHouseNewsCellModel class])];
    
    [self.tableView registerClass:[FHDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailDisclaimerModel class])];
    
    [self.tableView registerClass:[FHDetailNewTimeLineItemCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewTimeLineItemModel class])];
    
    [self.tableView registerClass:[FHDetailNearbyMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNearbyMapModel class])];
    
    [self.tableView registerClass:[FHDetailNewListSingleImageCell class] forCellReuseIdentifier:NSStringFromClass([FHNewHouseItemModel class])];

    [self.tableView registerClass:[FHDetailStaticMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailStaticMapCellModel class])];
    
}
//// cell class
//- (Class)cellClassForEntity:(id)model {
//    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
//        return [FHDetailPhotoHeaderCell class];
//    }
//
//    // 标题
//    if ([model isKindOfClass:[FHDetailHouseNameModel class]]) {
//        return [FHDetailHouseNameCell class];
//    }
//
//    // 核心信息
//    if ([model isKindOfClass:[FHDetailNewHouseCoreInfoModel class]]) {
//        return [FHDetailNewHouseCoreInfoCell class];
//    }
//
//    // 灰色分割线
//    if ([model isKindOfClass:[FHDetailGrayLineModel class]]) {
//        return [FHDetailGrayLineCell class];
//    }
//
//    //楼盘户型
//    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
//        return [FHDetailNewMutiFloorPanCell class];
//    }
//
//    //楼盘动态标题
//    if ([model isKindOfClass:[FHDetailNewHouseNewsCellModel class]]) {
//        return [FHDetailNewHouseNewsCell class];
//    }
//
//    //楼盘动态标题
//    if ([model isKindOfClass:[FHDetailNewTimeLineItemModel class]]) {
//        return [FHDetailNewTimeLineItemCell class];
//    }
//
//    //周边配套
//    if ([model isKindOfClass:[FHDetailNearbyMapModel class]]) {
//        return [FHDetailNearbyMapCell class];
//    }
//
//    //周边新盘
//    if ([model isKindOfClass:[FHNewHouseItemModel class]]) {
//        return [FHDetailNewListSingleImageCell class];
//    }
//
//    //版权信息
//    if ([model isKindOfClass:[FHDetailDisclaimerModel class]]) {
//        return [FHDetailDisclaimerCell class];
//    }
//
//    return [FHDetailBaseCell class];
//}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)startLoadData
{
    __weak typeof(self) wSelf = self;
    [FHHouseDetailAPI requestNewDetail:self.houseId logPB:self.listLogPB completion:^(FHDetailNewModel * _Nullable model, NSError * _Nullable error) {
        if ([model isKindOfClass:[FHDetailNewModel class]] && !error) {
            if (model.data) {
                wSelf.dataModel = model;
                wSelf.detailController.hasValidateData = YES;
                [wSelf.detailController.emptyView hideEmptyView];
                wSelf.bottomBar.hidden = NO;
                [wSelf processDetailData:model];
            }else {
                wSelf.detailController.isLoadingData = NO;
                wSelf.detailController.hasValidateData = NO;
                wSelf.bottomBar.hidden = YES;
                [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
                [wSelf addDetailRequestFailedLog:model.status.integerValue message:@"empty"];
            }
        }else {
            wSelf.detailController.isLoadingData = NO;
//            if (wSelf.detailController.instantData) {
//                SHOW_TOAST(@"请求失败");
//            }else{
            wSelf.detailController.hasValidateData = NO;
            wSelf.bottomBar.hidden = YES;
            [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            [wSelf addDetailRequestFailedLog:model.status.integerValue message:error.domain];
//            }
        }
    }];
}

-(void)handleInstantData:(id)data
{
    FHDetailNewModel *model = [[FHDetailNewModel alloc]init];
    model.isInstantData = YES;
    FHDetailNewDataModel *dataModel = [[FHDetailNewDataModel alloc]init];
    model.data = dataModel;
    if ([data isKindOfClass:[FHNewHouseItemModel class ]]) {
        
        FHNewHouseItemModel *item = (FHNewHouseItemModel *)data;
        if (item.images) {
            FHDetailNewDataImageGroupModel *imgGroup = [FHDetailNewDataImageGroupModel new];
            imgGroup.images = item.images;
            imgGroup.type = @"7";
            
            dataModel.imageGroup = @[imgGroup];
        }
        
        dataModel.tags = item.tags;
        if (item.coreInfo) {
            dataModel.coreInfo = [[FHDetailNewDataCoreInfoModel alloc] initWithDictionary:item.coreInfo.toDictionary error:nil];
        }
        dataModel.imprId = item.imprId;
        if (item.floorpanList && item.floorpanList.count > 0){
            dataModel.floorpanList = [[FHDetailNewDataFloorpanListModel alloc] initWithDictionary:item.floorpanList error:nil];
        }
        if (item.contact) {
            dataModel.contact = [[FHDetailContactModel alloc] initWithDictionary:item.contact error:nil];
            dataModel.contact.isInstantData = YES;
        }
        if (item.timeline) {
            dataModel.timeline = [[FHDetailNewDataTimelineModel alloc]initWithDictionary:item.timeline error:nil];
        }
        
        if (item.globalPricing) {
            dataModel.globalPricing = [[FHDetailNewDataGlobalPricingModel alloc] initWithDictionary:item.globalPricing error:nil];
        }
        
        if (item.userStatus) {
            dataModel.userStatus = [[FHDetailNewDataUserStatusModel alloc] initWithDictionary:item.userStatus error:nil];
        }
        
        dataModel.logPb = item.logPb;
        
    }else if ([data isKindOfClass:[FHHomeHouseDataItemsModel class]]){
        FHHomeHouseDataItemsModel *item = (FHHomeHouseDataItemsModel *)data;
        
        if (item.images) {
            FHDetailNewDataImageGroupModel *imgGroup = [FHDetailNewDataImageGroupModel new];
            imgGroup.images = item.images;
            imgGroup.type = @"7";
            
            dataModel.imageGroup = @[imgGroup];
        }
        if (item.coreInfo) {
            dataModel.coreInfo = [[FHDetailNewDataCoreInfoModel alloc] initWithDictionary:item.coreInfo.toDictionary error:nil];
        }
        dataModel.tags = item.tags;
        if (item.floorpanList && item.floorpanList.list.count > 0){
            dataModel.floorpanList = [[FHDetailNewDataFloorpanListModel alloc] initWithDictionary:item.floorpanList.toDictionary error:nil];
        }
        
        if (item.contact) {
            dataModel.contact = [[FHDetailContactModel alloc] initWithDictionary:item.contact.toDictionary error:nil];
        }
        
        if (item.timeline) {
            dataModel.timeline = [[FHDetailNewDataTimelineModel alloc]initWithDictionary:item.timeline.toDictionary error:nil];
        }
        
        dataModel.imprId = item.imprId;
        
        dataModel.logPb = item.logPb;
    }
    else{
        self.detailController.instantData = nil;
        return;
    }
    if (!dataModel.contact) {
        dataModel.contact = [FHDetailContactModel new];
    }
    
    if (IS_EMPTY_STRING(dataModel.coreInfo.constructionOpendate)) {
        dataModel.coreInfo.constructionOpendate = @"暂无";
    }
    if ([dataModel.coreInfo.aliasName isEqualToString:@"[]"]) {
        dataModel.coreInfo.aliasName = nil;
    }
    
    self.bottomBar.hidden = NO;
    [self processDetailData:model];
}

-(BOOL)currentIsInstantData
{
    return [(FHDetailNewModel *)self.detailData isInstantData];
}

-(NSArray *)instantHouseImages
{
    id data = self.detailController.instantData;
    if ([data isKindOfClass:[FHNewHouseItemModel class ]]) {
        
        FHNewHouseItemModel *item = (FHNewHouseItemModel *)data;
        return item.images;
        
    }else if ([data isKindOfClass:[FHHomeHouseDataItemsModel class]]){
        FHHomeHouseDataItemsModel *item = (FHHomeHouseDataItemsModel *)data;
        return item.images;
    }
    return nil;
}

- (void)processDetailData:(FHDetailNewModel *)model{
    self.detailData = model;
    [self addDetailCoreInfoExcetionLog];

    // 清空数据源
    [self.items removeAllObjects];
    FHDetailContactModel *contactPhone = nil;
    
    if (model.data.highlightedRealtor) {
        contactPhone = model.data.highlightedRealtor;
    }else {
        contactPhone = model.data.contact;
    }
    if (contactPhone.phone.length > 0) {
        contactPhone.isFormReport = NO;
    }else {
        contactPhone.isFormReport = YES;
    }
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.userStatus.courtSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;
    __weak typeof(self) wSelf = self;
    if (!model.isInstantData && model.data) {
        [FHHouseDetailAPI requestRelatedFloorSearch:self.houseId offset:@"0" query:nil count:0 completion:^(FHDetailRelatedCourtModel * _Nullable model, NSError * _Nullable error) {
            wSelf.relatedHouseData = model;
            [wSelf processDetailRelatedData];
        }];
    }
    
    FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
    if (model.data.imageGroup) {        
        NSMutableArray *arrayHouseImage = [NSMutableArray new];
        for (NSInteger i = 0; i < model.data.imageGroup.count; i++) {
            FHDetailNewDataImageGroupModel * groupModel = model.data.imageGroup[i];
            for (NSInteger j = 0; j < groupModel.images.count; j++) {
                [arrayHouseImage addObject:groupModel.images[j]];
            }
        }
  
        headerCellModel.isNewHouse = YES;
        headerCellModel.smallImageGroup = model.data.smallImageGroup;
        headerCellModel.houseImage = arrayHouseImage;
        if (!model.isInstantData) {
            headerCellModel.instantHouseImages = [self instantHouseImages];
        }
        headerCellModel.isInstantData = model.isInstantData;
        
    }else{
        //无图片时增加默认图
        FHImageModel *imgModel = [FHImageModel new];
        headerCellModel.houseImage = @[imgModel];
    }
    [self.items addObject:headerCellModel];
    
    FHDetailHouseNameModel *houseName = [[FHDetailHouseNameModel alloc] init];
    // 添加标题
    if (model.data) {
        houseName.type = 1;
        houseName.name = model.data.coreInfo.name;
        houseName.aliasName = model.data.coreInfo.aliasName;
        houseName.type = 2;
        houseName.tags = model.data.tags;
        [self.items addObject:houseName];
    }
  
    //核心信息
    if (model.data.coreInfo) {
        FHDetailNewHouseCoreInfoModel *houseCore = [[FHDetailNewHouseCoreInfoModel alloc] init];
        houseCore.pricingPerSqm = model.data.coreInfo.pricingPerSqm;
        houseCore.constructionOpendate = model.data.coreInfo.constructionOpendate;
        houseCore.courtAddress = model.data.coreInfo.courtAddress;
        houseCore.pricingSubStauts = model.data.userStatus.pricingSubStatus;
        houseCore.gaodeLat = model.data.coreInfo.gaodeLat;
        houseCore.gaodeLng = model.data.coreInfo.gaodeLng;
        houseCore.courtId = model.data.coreInfo.id;
        houseCore.houseName = houseName;
        houseCore.contactModel = self.contactViewModel;
        
        FHDetailDisclaimerModel *disclaimerModel = [[FHDetailDisclaimerModel alloc] init];
        disclaimerModel.disclaimer = [[FHDisclaimerModel alloc] initWithData:[self.dataModel.data.disclaimer toJSONData] error:nil];
        houseCore.disclaimerModel = disclaimerModel;
        
        [self.items addObject:houseCore];
    }
    
    //楼盘户型
    if ([model.data.floorpanList.list isKindOfClass:[NSArray class]] && model.data.floorpanList.list.count > 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        model.data.floorpanList.courtId = model.data.coreInfo.id;
        [self.items addObject:model.data.floorpanList];
    }
    
    //楼盘动态
    if (model.data.timeline.list.count != 0) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        
        FHDetailNewHouseNewsCellModel *newsCellModel = [[FHDetailNewHouseNewsCellModel alloc] init];
        newsCellModel.hasMore = model.data.timeline.hasMore;
        newsCellModel.titleText = @"楼盘动态";
        newsCellModel.courtId = model.data.coreInfo.id;
        newsCellModel.clickEnable = YES;
        
        [self.items addObject:newsCellModel];
        
        for (NSInteger i = 0; i < model.data.timeline.list.count; i++) {
            FHDetailNewDataTimelineListModel *itemModel = model.data.timeline.list[i];
            FHDetailNewTimeLineItemModel *item = [[FHDetailNewTimeLineItemModel alloc] init];
            item.desc = itemModel.desc;
            item.title = itemModel.title;
            item.createdTime = itemModel.createdTime;
            item.isFirstCell = (i == 0);
            item.isLastCell = (i == model.data.timeline.list.count - 1);
            item.courtId = model.data.coreInfo.id;
            [self.items addObject:item];
        }
    }

    //地图
    if(model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng){
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];

        FHDetailStaticMapCellModel *staticMapModel = [[FHDetailStaticMapCellModel alloc] init];
        staticMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
        staticMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
        staticMapModel.title = model.data.coreInfo.name;
        staticMapModel.tableView = self.tableView;
        staticMapModel.staticImage = model.data.coreInfo.gaodeImage;
        staticMapModel.useStarHeader = NO;
        staticMapModel.mapOnly = NO;
        [self.items addObject:staticMapModel];

    } else{
        NSString *eventName = @"detail_map_location_failed";
        NSDictionary *cat = @{@"status": @(1)};

        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
        [params setValue:@"经纬度缺失" forKey:@"reason"];
        [params setValue:model.data.coreInfo.id forKey:@"house_id"];
        [params setValue:@(FHHouseTypeNewHouse) forKey:@"house_type"];
        [params setValue:model.data.coreInfo.name forKey:@"name"];

        [[HMDTTMonitor defaultManager] hmdTrackService:eventName metric:nil category:cat extra:params];
    }

//    //周边配套
//    if (model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng) {
//        // 添加分割线--当存在某个数据的时候在顶部添加分割线
//        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
//        [self.items addObject:grayLine];
//
//        FHDetailNearbyMapModel *nearbyMapModel = [[FHDetailNearbyMapModel alloc] init];
//        nearbyMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
//        nearbyMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
//        nearbyMapModel.title = model.data.coreInfo.name;
//
//
//        if (!model.data.coreInfo.gaodeLat || !model.data.coreInfo.gaodeLng) {
//            NSMutableDictionary *params = [NSMutableDictionary new];
//            [params setValue:@"用户点击详情页地图进入地图页失败" forKey:@"desc"];
//            [params setValue:@"经纬度缺失" forKey:@"reason"];
//            [params setValue:model.data.coreInfo.id forKey:@"house_id"];
//            [params setValue:@(1) forKey:@"house_type"];
//            [params setValue:model.data.coreInfo.name forKey:@"name"];
//            [[HMDTTMonitor defaultManager] hmdTrackService:@"detail_map_location_failed" attributes:params];
//        }
//
//
////        nearbyMapModel.tableView = self.tableView;
//        [self.items addObject:nearbyMapModel];
//
//        __weak typeof(self) wSelf = self;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            if ((FHDetailNearbyMapCell *)nearbyMapModel.cell) {
//                ((FHDetailNearbyMapCell *)nearbyMapModel.cell).indexChangeCallBack = ^{
//                    [self reloadData];
//                };
//            }
//        });
//    }
    
    if (model.isInstantData) {
        [self.tableView reloadData];
    }else{
        [self reloadData];
    }
    
    [self.detailController updateLayout:model.isInstantData];
}

// 处理详情页周边新盘请求数据
- (void)processDetailRelatedData {
    self.detailController.isLoadingData = NO;
    if(_relatedHouseData.data && self.relatedHouseData.data.items.count > 0)
    {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        
        FHDetailNewHouseNewsCellModel *newsCellModel = [[FHDetailNewHouseNewsCellModel alloc] init];
        newsCellModel.hasMore = NO;
        newsCellModel.titleText = @"周边新盘";
        newsCellModel.clickEnable = NO;
        
        [self.items addObject:newsCellModel];
        
        for(NSInteger i = 0;i < _relatedHouseData.data.items.count; i++)
        {
            FHNewHouseItemModel *itemModel = [[FHNewHouseItemModel alloc] initWithData:[(_relatedHouseData.data.items[i]) toJSONData] error:nil];
            itemModel.index = i;
            if (i == _relatedHouseData.data.items.count - 1) {
                itemModel.isLast = YES;
            }
            [self.items addObject:itemModel];
        }
    }
    
    //楼盘版权信息
    if ([self.dataModel.data.disclaimer isKindOfClass:[FHDetailNewDataDisclaimerModel class]]){
        FHDetailDisclaimerModel *disclaimerModel = [[FHDetailDisclaimerModel alloc] init];
        disclaimerModel.disclaimer = [[FHDisclaimerModel alloc] initWithData:[self.dataModel.data.disclaimer toJSONData] error:nil];
        [self.items addObject:disclaimerModel];
    }
    
    [self reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FHDetailBaseCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.didClickCellBlk) {
        cell.didClickCellBlk();
    }
}

- (BOOL)isMissTitle
{
    FHDetailNewModel *model = (FHDetailNewModel *)self.detailData;
    return model.data.coreInfo.name.length < 1;
}

- (BOOL)isMissImage
{
    FHDetailNewModel *model = (FHDetailNewModel *)self.detailData;
    return model.data.imageGroup.count < 1;
}

- (BOOL)isMissCoreInfo
{
    FHDetailNewModel *model = (FHDetailNewModel *)self.detailData;
    return model.data.coreInfo == nil;
}

@end
