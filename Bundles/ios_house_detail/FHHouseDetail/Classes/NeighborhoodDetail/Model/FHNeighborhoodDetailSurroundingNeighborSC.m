//
//  FHNeighborhoodDetailSurroundingNeighborSC.m
//  FHHouseDetail
//
//  Created by 谢雷 on 2020/12/11.
//

#import "FHNeighborhoodDetailSurroundingNeighborSC.h"
#import "FHNeighborhoodDetailSurroundingNeighborSM.h"
#import "FHNeighborhoodDetailSurroundingNeighborCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHDetailRelatedNeighborhoodResponseModel.h"

@interface FHNeighborhoodDetailSurroundingNeighborSC ()<IGListSupplementaryViewSource, IGListDisplayDelegate>

@end

@implementation FHNeighborhoodDetailSurroundingNeighborSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
    }
    return self;
}

// 查看更多
- (void)moreButtonClick {
    FHNeighborhoodDetailSurroundingNeighborSM *sectionModel = (FHNeighborhoodDetailSurroundingNeighborSM *)self.sectionModel;
    
    if (sectionModel.model && sectionModel.model.hasMore) {
        
//        NSString *searchId = model.relatedNeighborhoodData.searchId;
        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
        tracerDic[UT_ENTER_TYPE] = @"click";
        tracerDic[UT_LOG_PB] = self.detailViewController.viewModel.listLogPB ? self.detailViewController.viewModel.listLogPB : @"be_null";
        tracerDic[UT_ELEMENT_FROM] = @"related_neighborhood";
        tracerDic[UT_ENTER_FROM] = @"neighborhood_detail";
        
        NSMutableDictionary *infoDict = [NSMutableDictionary new];
        infoDict[@"tracer"] = tracerDic;
        infoDict[@"house_type"] = @(FHHouseTypeNeighborhood);
        infoDict[@"title"] = @"周边小区";
        // 周边小区跳转
        if (self.detailViewController.viewModel.detailData) {
            infoDict[@"neighborhood_id"] = self.detailViewController.viewModel.detailData.data.id;
        }

        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        NSString * urlStr = [NSString stringWithFormat:@"snssdk1370://related_neighborhood_list"];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHNeighborhoodDetailSurroundingNeighborSM *sectionModel = (FHNeighborhoodDetailSurroundingNeighborSM *)self.sectionModel;
    if (sectionModel.model && sectionModel.model.items.count > 0 && index >= 0 && index < sectionModel.model.items.count) {
        // 点击cell处理
        FHDetailRelatedNeighborhoodResponseDataItemsModel *dataItem = sectionModel.model.items[index];
        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"slide";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:FHHouseTypeNeighborhood];
        tracerDic[UT_ELEMENT_FROM] = @"related_neighborhood";
        tracerDic[UT_ENTER_FROM] = @"neighborhood_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeNeighborhood)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://neighborhood_detail?neighborhood_id=%@",dataItem.id];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

- (void)houseShowIndex:(NSInteger )index {
    FHNeighborhoodDetailSurroundingNeighborSM *sectionModel = (FHNeighborhoodDetailSurroundingNeighborSM *)self.sectionModel;
    if (index >= 0 && index < sectionModel.model.items.count) {
        FHDetailRelatedNeighborhoodResponseDataItemsModel *item = sectionModel.model.items[index];
        if (![item isKindOfClass:[FHDetailRelatedNeighborhoodResponseDataItemsModel class]]) {
            return;
        }
        NSString *tempKey = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self class]), (long)index];
        if ([self.elementShowCaches valueForKey:tempKey]) {
            return;
        }
        [self.elementShowCaches setValue:@(YES) forKey:tempKey];
        NSMutableDictionary *traceParam = self.detailTracerDict.mutableCopy;
        traceParam[UT_LOG_PB] = [item logPb] ? : UT_BE_NULL;;
        traceParam[UT_ELEMENT_TYPE] = @"related_neighborhood";
        traceParam[UT_PAGE_TYPE] = @"neighborhood_detail";
        traceParam[UT_HOUSE_TYPE] = @"old";
        traceParam[UT_RANK] = @(index);
        [FHUserTracker writeEvent:@"house_show" params:traceParam];
    }
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat width = self.collectionContext.containerSize.width - 18;
    return CGSizeMake(width, 208);
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailSurroundingNeighborSM *sectionModel = (FHNeighborhoodDetailSurroundingNeighborSM *)self.sectionModel;
    FHNeighborhoodDetailSurroundingNeighborCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailSurroundingNeighborCollectionCell class] withReuseIdentifier:NSStringFromClass([sectionModel class]) forSectionController:self atIndex:index];
    [cell refreshWithData:sectionModel.model];
    __weak typeof(self) weakSelf = self;
    [cell setHouseShowBlock:^(NSUInteger index) {
        [weakSelf houseShowIndex:index];
    }];
    [cell setSelectIndexBlock:^(NSInteger index) {
        [weakSelf collectionCellClick:index];
    }];
    return cell;
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    [titleView setupNeighborhoodDetailStyle];
    FHNeighborhoodDetailSurroundingNeighborSM *sectionModel = (FHNeighborhoodDetailSurroundingNeighborSM *)self.sectionModel;
    titleView.titleLabel.text = sectionModel.titleName;
    titleView.subTitleLabel.text = sectionModel.moreTitle;
    titleView.arrowsImg.hidden = NO;
    titleView.subTitleLabel.hidden = NO;
    [titleView.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(titleView.arrowsImg.mas_left).mas_offset(-2);
        make.centerY.mas_equalTo(titleView.titleLabel);
    }];
    __weak typeof(self) weakSelf = self;
    [titleView setMoreActionBlock:^{
        //小区列表
        [weakSelf moreButtonClick];
    }];
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 30, 46);
    }
    return CGSizeZero;
}

@end
