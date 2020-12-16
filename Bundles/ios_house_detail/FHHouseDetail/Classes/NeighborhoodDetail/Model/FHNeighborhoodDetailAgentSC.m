//
//  FHNeighborhoodDetailAgentSC.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailAgentSC.h"
#import "FHNeighborhoodDetailReleatorCollectionCell.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHHouseDetailPhoneCallViewModel.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNeighborhoodDetailViewController.h"
#import "FHNeighborhoodDetailViewModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHAssociatePhoneModel.h"
#import "FHHousePhoneCallUtils.h"

static NSInteger  const FHNeighborhoodDetailAgentLimit = 3;

@interface FHNeighborhoodDetailAgentSC ()<IGListSupplementaryViewSource,IGListDisplayDelegate,IGListBindingSectionControllerDataSource>
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@end

@implementation FHNeighborhoodDetailAgentSC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.supplementaryViewSource = self;
        self.displayDelegate = self;
        self.dataSource = self;
    }
    return self;
}


- (FHHouseDetailPhoneCallViewModel *)phoneCallViewModel {
    if (!_phoneCallViewModel) {
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeNeighborhood houseId:self.detailViewController.viewModel.houseId];
        _phoneCallViewModel.tracerDict = self.detailViewController.viewModel.detailTracerDic.copy;
        
    }
    return _phoneCallViewModel;
}

#pragma mark - Action
// 证书点击
- (void)licenseClick:(FHDetailContactModel *)model {
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    NSUInteger index = [agentSM.recommendedRealtors indexOfObject:model];
    if (index >= 0 && agentSM.recommendedRealtors.count > 0 && index < agentSM.recommendedRealtors.count) {
        [self.phoneCallViewModel licenseActionWithPhone:model];
    }
}

// 电话点击
- (void)phoneClick:(FHDetailContactModel *)model {
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    NSUInteger index = [agentSM.recommendedRealtors indexOfObject:model];
    if (index >= 0 && agentSM.recommendedRealtors.count > 0 && index < agentSM.recommendedRealtors.count) {
        
        NSString *searchId = self.detailViewController.viewModel.listLogPB[@"search_id"];
        NSString *imprId = self.detailViewController.viewModel.listLogPB[@"impr_id"];
        
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        extraDict[@"realtor_id"] = model.realtorId;
        extraDict[@"realtor_rank"] = @(index);
        extraDict[@"realtor_position"] = @"detail_related";
        extraDict[@"realtor_logpb"] = model.realtorLogpb;
        if (self.detailViewController.viewModel.detailTracerDic) {
            [extraDict addEntriesFromDictionary:self.detailViewController.viewModel.detailTracerDic];
        }
        
        NSDictionary *associateInfoDict = agentSM.associateInfo.phoneInfo;
        extraDict[kFHAssociateInfo] = associateInfoDict;
        FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
        associatePhone.reportParams = extraDict;
        associatePhone.associateInfo = associateInfoDict;
        associatePhone.realtorId = model.realtorId;
        associatePhone.searchId = searchId;
        associatePhone.imprId = imprId;

        associatePhone.houseType = FHHouseTypeNeighborhood;
        associatePhone.houseId = self.detailViewController.viewModel.houseId;
        associatePhone.showLoading = NO;
        
        if (model.bizTrace) {
            associatePhone.extraDict = @{@"biz_trace":model.bizTrace};
        }
        __weak typeof(self) weakSelf = self;
        [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
            if(success && [weakSelf.detailViewController isKindOfClass:[FHHouseDetailViewController class]]){
                FHHouseDetailViewController *vc = (FHHouseDetailViewController *)weakSelf.detailViewController;
                vc.isPhoneCallShow = YES;
                vc.phoneCallRealtorId = model.realtorId;
                vc.phoneCallRequestId = virtualPhoneNumberModel.requestId;
            }
        }];

        FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:extraDict error:nil];
        configModel.houseType = self.detailViewController.viewModel.houseType;
        configModel.followId = self.detailViewController.viewModel.houseId;
        configModel.actionType = self.detailViewController.viewModel.houseType;
        
        // 静默关注功能
        [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
    }

}

// 点击会话
- (void)imclick:(FHDetailContactModel *)model {
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    NSUInteger index = [agentSM.recommendedRealtors indexOfObject:model];
    if (index >= 0 && agentSM.recommendedRealtors.count > 0 && index < agentSM.recommendedRealtors.count) {
        NSMutableDictionary *imExtra = @{}.mutableCopy;
        imExtra[@"realtor_position"] = @"detail_related";
        
        if(agentSM.detailModel.data.recommendRealtorsAssociateInfo) {
            imExtra[kFHAssociateInfo] =  agentSM.detailModel.data.recommendRealtorsAssociateInfo;
        }
        [self.phoneCallViewModel imchatActionWithPhone:model realtorRank:[NSString stringWithFormat:@"%ld", (long)index] extraDic:imExtra];
    }
}

- (void)addRealtorClickMore {
    NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
    // 移除字段
    [tracerDic removeObjectsForKeys:@[@"card_type",@"element_from",@"search_id",@"enter_from"]];
    [FHUserTracker writeEvent:@"realtor_click_more" params:tracerDic];
}

- (void)pushRealtorDetail:(FHDetailContactModel *)model {
    
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    NSUInteger index = [agentSM.recommendedRealtors indexOfObject:model];
    if (index < 0 || index >= agentSM.recommendedRealtors.count) {
        return;
    }
    if ((!agentSM.isFold && agentSM.recommendedRealtors.count > FHNeighborhoodDetailAgentLimit && index == agentSM.recommendedRealtors.count) || (agentSM.isFold && agentSM.recommendedRealtors.count > FHNeighborhoodDetailAgentLimit && index == FHNeighborhoodDetailAgentLimit)) {
        return;
    } else {
        if (index < agentSM.recommendedRealtors.count) {
            FHDetailContactModel *model = (FHDetailContactModel *)agentSM.recommendedRealtors[index];
            self.phoneCallViewModel.belongsVC = self.detailViewController;
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"element_from"] = @"neighborhood_detail_related";
            dict[@"enter_from"] = @"neighborhood_detail";
            [self.phoneCallViewModel jump2RealtorDetailWithPhone:model isPreLoad:NO extra:dict];
        }
    }
    
}

- (void)foldAction {
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    agentSM.isFold = !agentSM.isFold;
    if (!agentSM.isFold) {
        [self addRealtorClickMore];
    }
    agentSM.moreModel = [FHNeighborhoodDetailReleatorMoreCellModel modelWithFold:agentSM.isFold];
    [self updateAnimated:YES completion:^(BOOL updated) {

    }];
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    if (agentSM.isFold) {
        if (index < FHNeighborhoodDetailAgentLimit && index < agentSM.recommendedRealtors.count) {
            [self pushRealtorDetail:agentSM.recommendedRealtors[index]];
        }
    } else {
        if (index < agentSM.recommendedRealtors.count) {
            [self pushRealtorDetail:agentSM.recommendedRealtors[index]];
        }
    }
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    titleView.titleLabel.font = [UIFont themeFontMedium:18];
    titleView.titleLabel.textColor = [UIColor themeGray1];
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;

    // 设置下发标题
    if(agentSM.recommendedRealtorsTitle.length > 0) {
        titleView.titleLabel.text = agentSM.recommendedRealtorsTitle;
    }else {
        titleView.titleLabel.text = @"推荐经纪人";
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


- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didEndDisplayingSectionController:(nonnull IGListSectionController *)sectionController {
    
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didEndDisplayingSectionController:(nonnull IGListSectionController *)sectionController cell:(nonnull UICollectionViewCell *)cell atIndex:(NSInteger)index {
    
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter willDisplaySectionController:(nonnull IGListSectionController *)sectionController {
    
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter willDisplaySectionController:(nonnull IGListSectionController *)sectionController cell:(nonnull UICollectionViewCell *)cell atIndex:(NSInteger)index {
    if ([cell isKindOfClass:[FHNeighborhoodDetailReleatorCollectionCell class]]) {
        NSString *cahceKey = [NSString stringWithFormat:@"%@_%ld",NSStringFromClass([self class]), (long)index];
        if (self.elementShowCaches[cahceKey]) {
            return;
        }
        self.elementShowCaches[cahceKey] = @(YES);
        FHNeighborhoodDetailAgentSM *sectionModel = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
        FHDetailContactModel *contact = sectionModel.recommendedRealtors[index];
        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
        tracerDic[@"element_type"] = @"neighborhood_detail_related";
        tracerDic[@"realtor_id"] = contact.realtorId ?: @"be_null";
        tracerDic[@"realtor_rank"] = @(index);
        tracerDic[@"realtor_position"] = @"detail_related";
        tracerDic[@"realtor_logpb"] = contact.realtorLogpb;
        tracerDic[@"biz_trace"] = contact.bizTrace;
        [tracerDic setValue:contact.enablePhone ? @"1" : @"0" forKey:@"phone_show"];
        if (![@"" isEqualToString:contact.imOpenUrl] && contact.imOpenUrl != nil) {
            [tracerDic setValue:@"1" forKey:@"im_show"];
        } else {
            [tracerDic setValue:@"0" forKey:@"im_show"];
        }
        // 移除字段
        [tracerDic removeObjectsForKeys:@[@"card_type",@"element_from",@"search_id"]];
        [FHUserTracker writeEvent:@"realtor_show" params:tracerDic];
    }
    
}

#pragma mark - IGListBindingSectionControllerDataSource

- (NSArray<id<IGListDiffable>> *)sectionController:(IGListBindingSectionController *)sectionController viewModelsForObject:(id)object {
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    NSMutableArray *viewModels = [NSMutableArray array];
    if (agentSM.recommendedRealtors.count <= FHNeighborhoodDetailAgentLimit) {
        return agentSM.recommendedRealtors;
    }
    if (agentSM.isFold) {
        [viewModels addObjectsFromArray:[agentSM.recommendedRealtors subarrayWithRange:NSMakeRange(0, FHNeighborhoodDetailAgentLimit)]];
    } else {
        [viewModels addObjectsFromArray:agentSM.recommendedRealtors];
    }
    [viewModels addObject:agentSM.moreModel];
    return viewModels.copy;
}

- (nonnull UICollectionViewCell<IGListBindable> *)sectionController:(nonnull IGListBindingSectionController *)sectionController cellForViewModel:(nonnull id)viewModel atIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    if ((!agentSM.isFold && agentSM.recommendedRealtors.count > FHNeighborhoodDetailAgentLimit && index == agentSM.recommendedRealtors.count) || (agentSM.isFold && agentSM.recommendedRealtors.count > FHNeighborhoodDetailAgentLimit && index == FHNeighborhoodDetailAgentLimit)) {
        //展开，收起
        FHNeighborhoodDetailReleatorMoreCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailReleatorMoreCell class] forSectionController:self atIndex:index];
        [cell setFoldButtonActionBlock:^{
            [weakSelf foldAction];
        }];
        cell.foldButton.isFold = agentSM.isFold;
        return cell;
    } else {
        FHDetailContactModel *model = agentSM.recommendedRealtors[index];
        FHNeighborhoodDetailReleatorCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNeighborhoodDetailReleatorCollectionCell class] forSectionController:self atIndex:index];
        [cell refreshWithData:model];
        [cell setImClickBlock:^(FHDetailContactModel * _Nonnull model) {
            [weakSelf imclick:model];
        }];
        [cell setPhoneClickBlock:^(FHDetailContactModel * _Nonnull model) {
            [weakSelf phoneClick:model];
        }];
        [cell setLicenseClickBlock:^(FHDetailContactModel * _Nonnull model) {
            [weakSelf licenseClick:model];
        }];
        [cell setReleatorClickBlock:^(FHDetailContactModel * _Nonnull model) {
            [weakSelf pushRealtorDetail:model];
        }];
        return cell;
    }
}

- (CGSize)sectionController:(nonnull IGListBindingSectionController *)sectionController sizeForViewModel:(nonnull id)viewModel atIndex:(NSInteger)index {
    FHNeighborhoodDetailAgentSM *agentSM = (FHNeighborhoodDetailAgentSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;

    
    CGFloat vHeight = 65;
    if ((!agentSM.isFold && agentSM.recommendedRealtors.count > FHNeighborhoodDetailAgentLimit && index == agentSM.recommendedRealtors.count) || (agentSM.isFold && agentSM.recommendedRealtors.count > FHNeighborhoodDetailAgentLimit && index == FHNeighborhoodDetailAgentLimit)) {
        vHeight = 44;
    } else {
        if (index < agentSM.recommendedRealtors.count) {
            FHDetailContactModel *obj = (FHDetailContactModel *)agentSM.recommendedRealtors[index];
            return [FHNeighborhoodDetailReleatorCollectionCell cellSizeWithData:obj width:width];
        }
    }
    
    return CGSizeMake(width, vHeight);
}
@end
