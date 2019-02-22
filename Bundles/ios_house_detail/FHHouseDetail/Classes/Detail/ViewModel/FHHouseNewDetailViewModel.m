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

@interface FHHouseNewDetailViewModel ()

@property (nonatomic, strong , nullable) FHDetailRelatedCourtModel *relatedHouseData;

@property (nonatomic, strong , nullable) FHDetailNewModel *dataModel;
//@property (nonatomic, strong , nullable) FHDetailNewModel *newDetailDataModel;

@end

@implementation FHHouseNewDetailViewModel

// 注册cell类型
- (void)registerCellClasses {
    [self.tableView registerClass:[FHDetailPhotoHeaderCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailPhotoHeaderCell class])];

    [self.tableView registerClass:[FHDetailHouseNameCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailHouseNameCell class])];
    
    [self.tableView registerClass:[FHDetailGrayLineCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailGrayLineCell class])];

    [self.tableView registerClass:[FHDetailNewHouseCoreInfoCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewHouseCoreInfoCell class])];
    
    [self.tableView registerClass:[FHDetailNewMutiFloorPanCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewMutiFloorPanCell class])];
    
    [self.tableView registerClass:[FHDetailNewHouseNewsCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewHouseNewsCell class])];
    
    [self.tableView registerClass:[FHDetailDisclaimerCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailDisclaimerCell class])];
    
    [self.tableView registerClass:[FHDetailNewTimeLineItemCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewTimeLineItemCell class])];

    [self.tableView registerClass:[FHDetailNearbyMapCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNearbyMapCell class])];
    
    [self.tableView registerClass:[FHDetailNewListSingleImageCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewListSingleImageCell class])];

}
// cell class
- (Class)cellClassForEntity:(id)model {
    if ([model isKindOfClass:[FHDetailPhotoHeaderModel class]]) {
        return [FHDetailPhotoHeaderCell class];
    }
    
    // 标题
    if ([model isKindOfClass:[FHDetailHouseNameModel class]]) {
        return [FHDetailHouseNameCell class];
    }
    
    // 核心信息
    if ([model isKindOfClass:[FHDetailNewHouseCoreInfoModel class]]) {
        return [FHDetailNewHouseCoreInfoCell class];
    }
    
    // 灰色分割线
    if ([model isKindOfClass:[FHDetailGrayLineModel class]]) {
        return [FHDetailGrayLineCell class];
    }
    
    //楼盘户型
    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        return [FHDetailNewMutiFloorPanCell class];
    }
    
    //楼盘动态标题
    if ([model isKindOfClass:[FHDetailNewHouseNewsCellModel class]]) {
        return [FHDetailNewHouseNewsCell class];
    }
    
    //楼盘动态标题
    if ([model isKindOfClass:[FHDetailNewTimeLineItemModel class]]) {
        return [FHDetailNewTimeLineItemCell class];
    }
    
    //周边配套
    if ([model isKindOfClass:[FHDetailNearbyMapModel class]]) {
        return [FHDetailNearbyMapCell class];
    }
    
    //周边新盘
    if ([model isKindOfClass:[FHNewHouseItemModel class]]) {
        return [FHDetailNewListSingleImageCell class];
    }
    
    //版权信息
    if ([model isKindOfClass:[FHDetailDisclaimerModel class]]) {
        return [FHDetailDisclaimerCell class];
    }
    
    return [FHDetailBaseCell class];
}
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
            wSelf.dataModel = model;
            wSelf.detailController.hasValidateData = YES;
            [self.detailController.emptyView hideEmptyView];
            wSelf.bottomBar.hidden = NO;
            [wSelf processDetailData:model];
        }else
        {
            wSelf.detailController.hasValidateData = NO;
            wSelf.bottomBar.hidden = YES;
            [wSelf.detailController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
        }
    }];
}


- (void)processDetailData:(FHDetailNewModel *)model {
    self.detailData = model;
    self.logPB = model.data.logPb;
    // 清空数据源
    [self.items removeAllObjects];
    if (model.data.highlightedRealtor) {
        self.contactViewModel.contactPhone = model.data.highlightedRealtor;
    }else {
        self.contactViewModel.contactPhone = model.data.contact;
    }
    self.contactViewModel.shareInfo = model.data.shareInfo;
    self.contactViewModel.followStatus = model.data.userStatus.courtSubStatus;

    __weak typeof(self) wSelf = self;
    if (model.data) {
        [FHHouseDetailAPI requestRelatedFloorSearch:self.houseId offset:@"0" query:nil count:0 completion:^(FHDetailRelatedCourtModel * _Nullable model, NSError * _Nullable error) {
            wSelf.relatedHouseData = model;
            [wSelf processDetailRelatedData];
        }];
    }
    
    if (model.data.imageGroup) {
        FHDetailPhotoHeaderModel *headerCellModel = [[FHDetailPhotoHeaderModel alloc] init];
        NSMutableArray *arrayHouseImage = [NSMutableArray new];
        for (NSInteger i = 0; i < model.data.imageGroup.count; i++) {
            FHDetailNewDataImageGroupModel * groupModel = model.data.imageGroup[i];
            for (NSInteger j = 0; j < groupModel.images.count; j++) {
                [arrayHouseImage addObject:groupModel.images[j]];
            }
        }
        headerCellModel.houseImage = arrayHouseImage;
        [self.items addObject:headerCellModel];
    }
    
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
    
    //周边配套
    if (model.data.coreInfo.gaodeLat && model.data.coreInfo.gaodeLng) {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        
        FHDetailNearbyMapModel *nearbyMapModel = [[FHDetailNearbyMapModel alloc] init];
        nearbyMapModel.gaodeLat = model.data.coreInfo.gaodeLat;
        nearbyMapModel.gaodeLng = model.data.coreInfo.gaodeLng;
//        nearbyMapModel.tableView = self.tableView;
        [self.items addObject:nearbyMapModel];
        
        __weak typeof(self) wSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ((FHDetailNearbyMapCell *)nearbyMapModel.cell) {
                ((FHDetailNearbyMapCell *)nearbyMapModel.cell).indexChangeCallBack = ^{
                    [self reloadData];
                };
            }
        });
    }
    
    [self reloadData];
}

// 处理详情页周边新盘请求数据
- (void)processDetailRelatedData {
    if(_relatedHouseData.data && self.relatedHouseData.data.items.count > 0)
    {
        // 添加分割线--当存在某个数据的时候在顶部添加分割线
        FHDetailGrayLineModel *grayLine = [[FHDetailGrayLineModel alloc] init];
        [self.items addObject:grayLine];
        
        FHDetailNewHouseNewsCellModel *newsCellModel = [[FHDetailNewHouseNewsCellModel alloc] init];
        newsCellModel.hasMore = NO;
        newsCellModel.titleText = @"周边新盘";
        [self.items addObject:newsCellModel];
        
        for(NSInteger i = 0;i < _relatedHouseData.data.items.count; i++)
        {
            FHNewHouseItemModel *itemModel = [[FHNewHouseItemModel alloc] initWithData:[(_relatedHouseData.data.items[i]) toJSONData] error:nil];
            itemModel.index = i;
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

@end
