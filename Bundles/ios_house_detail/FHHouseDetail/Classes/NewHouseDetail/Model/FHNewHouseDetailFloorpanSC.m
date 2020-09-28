//
//  FHNewHouseDetailFloorpanSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailFloorpanSC.h"
#import "FHNewHouseDetailFloorpanSM.h"
#import "FHNewHouseDetailMultiFloorpanCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHAssociateIMModel.h"
#import "FHNewHouseDetailViewController.h"
#import "FHNewHouseDetailViewModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHHouseIMClueHelper.h"

@interface FHNewHouseDetailFloorpanSC ()<IGListSupplementaryViewSource>

@end


@implementation FHNewHouseDetailFloorpanSC

- (instancetype)init {
    if (self = [super init]) {
//        self.minimumLineSpacing = 20;
        self.supplementaryViewSource = self;
    }
    return self;
}

#pragma mark - Action
// 查看更多
- (void)moreButtonAction {
    FHNewHouseDetailFloorpanSM *sectionModel = (FHNewHouseDetailFloorpanSM *)self.sectionModel;
    FHDetailNewDataFloorpanListModel *model = sectionModel.floorpanCellModel.floorPanList;

    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        NSMutableDictionary *infoDict = [NSMutableDictionary new];
        [infoDict setValue:model.list forKey:@"court_id"];
        NSMutableDictionary *dictM = [self subPageParams].mutableCopy;
        if (dictM[@"tracer"] && [dictM[@"tracer"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tempDict = dictM[@"tracer"];
            NSMutableDictionary *tracerDict = tempDict.mutableCopy;
            tracerDict[@"enter_from"] = @"new_detail";
            dictM[@"tracer"] = tracerDict;
        }
        [infoDict addEntriesFromDictionary:dictM];
        infoDict[@"house_type"] = @(FHHouseTypeNewHouse);
        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_pan_list"] userInfo:info];
    }

}

// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHNewHouseDetailFloorpanSM *sectionModel = (FHNewHouseDetailFloorpanSM *)self.sectionModel;
    FHDetailNewDataFloorpanListModel *model = sectionModel.floorpanCellModel.floorPanList;
    
    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]] && model.list.count > index) {
        FHDetailNewDataFloorpanListListModel *floorPanInfoModel = model.list[index];
        if (![floorPanInfoModel isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
            return;
        }
        NSMutableDictionary *traceParam = [NSMutableDictionary new];
        traceParam[@"enter_from"] = @"new_detail";
        traceParam[@"log_pb"] = floorPanInfoModel.logPb;
        traceParam[@"origin_from"] = self.detailTracerDict[@"origin_from"];
        traceParam[@"card_type"] = @"left_pic";
        traceParam[@"rank"] = @(floorPanInfoModel.index);
        traceParam[@"origin_search_id"] = self.detailTracerDict[@"origin_search_id"];
        traceParam[@"element_from"] = @"house_model";
        NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
        infoDict[@"house_type"] = @(1);
        [infoDict setValue:floorPanInfoModel.id forKey:@"floor_plan_id"];
        NSMutableDictionary *subPageParams = [self subPageParams].mutableCopy;
        subPageParams[@"contact_phone"] = nil;
        [infoDict addEntriesFromDictionary:subPageParams];
        infoDict[@"tracer"] = traceParam;
        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
    }
}

- (void)collectionCellShow:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%@_%ld_%ld",NSStringFromClass([self class]),(long)indexPath.section,(long)indexPath.row];
    if (self.elementShowCaches[tempKey]) {
        return;
    }
    self.elementShowCaches[tempKey] = @(YES);
    NSInteger index = indexPath.row;
    FHNewHouseDetailFloorpanSM *sectionModel = (FHNewHouseDetailFloorpanSM *)self.sectionModel;
    FHDetailNewDataFloorpanListModel *model = sectionModel.floorpanCellModel.floorPanList;

    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]] && model.list.count > index) {
        FHDetailNewDataFloorpanListListModel *itemModel = model.list[index];
        if (![itemModel isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
            return;
        }
        // house_show
        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
        tracerDic[@"rank"] = [@(index) stringValue];
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = itemModel.logPb ? itemModel.logPb : @"be_null";
        tracerDic[@"house_type"] = @"house_model";
        tracerDic[@"element_type"] = @"house_model";
        if (itemModel.logPb) {
            [tracerDic addEntriesFromDictionary:itemModel.logPb];
        }
        if (itemModel.searchId) {
            [tracerDic setValue:itemModel.searchId forKey:@"search_id"];
        }
        if ([itemModel.groupId isKindOfClass:[NSString class]] && itemModel.groupId.length > 0) {
            [tracerDic setValue:itemModel.groupId forKey:@"group_id"];
        }else
        {
            [tracerDic setValue:itemModel.id forKey:@"group_id"];
        }
        if (itemModel.imprId) {
            [tracerDic setValue:itemModel.imprId forKey:@"impr_id"];
        }
        //[tracerDic removeObjectForKey:@"enter_from"];
        [tracerDic removeObjectForKey:@"element_from"];
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}

- (void)imButtonClick:(NSInteger )index {
        // 一键咨询户型按钮点击
    FHNewHouseDetailFloorpanSM *sectionModel = (FHNewHouseDetailFloorpanSM *)self.sectionModel;
    FHDetailNewDataFloorpanListModel *model = sectionModel.floorpanCellModel.floorPanList;
    
    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]] && model.list.count > index) {
        FHDetailNewDataFloorpanListListModel *itemModel = model.list[index];
        if (![itemModel isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
            return;
        }
          // IM 透传数据模型
        FHAssociateIMModel *associateIMModel = [FHAssociateIMModel new];
        associateIMModel.houseId = self.detailViewController.viewModel.houseId;
        associateIMModel.houseType = FHHouseTypeNewHouse;
        associateIMModel.associateInfo = itemModel.associateInfo;

            // IM 相关埋点上报参数
        FHAssociateReportParams *reportParams = [FHAssociateReportParams new];
        reportParams.enterFrom = self.detailTracerDict[@"enter_from"];
        reportParams.elementFrom = @"house_model";
        reportParams.logPb = itemModel.logPb;
        reportParams.originFrom = self.detailTracerDict[@"origin_from"];
        reportParams.rank = self.detailTracerDict[@"rank"];
        reportParams.originSearchId = self.detailTracerDict[@"origin_search_id"];
        reportParams.searchId = self.detailTracerDict[@"search_id"];
        reportParams.pageType = [self.detailViewController.viewModel pageTypeString];
        FHDetailContactModel *contactPhone = self.detailViewController.viewModel.contactViewModel.contactPhone;
        reportParams.realtorId = contactPhone.realtorId;
        reportParams.realtorRank = @(0);
        reportParams.conversationId = @"be_null";
        reportParams.realtorLogpb = contactPhone.realtorLogpb;
        reportParams.realtorPosition = @"house_model";
        reportParams.sourceFrom = @"house_model";
        reportParams.extra = @{@"house_model_rank":@(index)};
        associateIMModel.reportParams = reportParams;
            
            // IM跳转链接
        associateIMModel.imOpenUrl = itemModel.imOpenUrl;
            // 跳转IM
        [FHHouseIMClueHelper jump2SessionPageWithAssociateIM:associateIMModel];
    }
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNewHouseDetailFloorpanSM *model = (FHNewHouseDetailFloorpanSM *)self.sectionModel;
    return [FHNewHouseDetailMultiFloorpanCollectionCell cellSizeWithData:model.floorpanCellModel width:width];
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailFloorpanSM *model = (FHNewHouseDetailFloorpanSM *)self.sectionModel;
    FHNewHouseDetailMultiFloorpanCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailMultiFloorpanCollectionCell class] withReuseIdentifier:NSStringFromClass([model.floorpanCellModel class]) forSectionController:self atIndex:index];
    __weak typeof(self) weakSelf = self;
    [cell setDidSelectItem:^(NSInteger atIndex) {
        [weakSelf collectionCellClick:atIndex];
    }];
    [cell setWillShowItem:^(NSIndexPath *indexPath) {
        [weakSelf collectionCellShow:indexPath];
    }];
    [cell setImItemClick:^(NSInteger atIndex) {
        [weakSelf imButtonClick:atIndex];
    }];
    [cell refreshWithData:model.floorpanCellModel];
    return cell;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    __weak typeof(self) weakSelf = self;
    [titleView setMoreActionBlock:^{
        [weakSelf moreButtonAction];
    }];
    FHNewHouseDetailMultiFloorpanCellModel *cellModel = [(FHNewHouseDetailFloorpanSM *)self.sectionModel floorpanCellModel];
    if (cellModel.floorPanList.totalNumber.length > 0) {
        titleView.titleLabel.text = [NSString stringWithFormat:@"户型介绍（%@）",cellModel.floorPanList.totalNumber];
        if (cellModel.floorPanList.totalNumber.integerValue >= 3) {
            titleView.arrowsImg.hidden = NO;
            titleView.userInteractionEnabled = YES;
        } else {
            titleView.arrowsImg.hidden = YES;
            titleView.userInteractionEnabled = NO;
        }
    } else {
        titleView.titleLabel.text = @"户型介绍";
        titleView.arrowsImg.hidden = YES;
        titleView.userInteractionEnabled = NO;
    }
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 61);
    }
    return CGSizeZero;
}

@end
