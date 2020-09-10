//
//  FHNewHouseDetailAgentSC.m
//  Pods
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailAgentSC.h"
#import "FHNewHouseDetailAgentSM.h"
#import "FHNewHouseDetailReleatorMoreCell.h"
#import "FHNewHouseDetailReleatorCollectionCell.h"
#import "FHHouseDetailPhoneCallViewModel.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHNewHouseDetailViewController.h"
#import "FHNewHouseDetailViewModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHAssociatePhoneModel.h"
#import "FHHousePhoneCallUtils.h"

@interface FHNewHouseDetailAgentSC ()<IGListSupplementaryViewSource,IGListDisplayDelegate>

@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;

@end

@implementation FHNewHouseDetailAgentSC

- (instancetype)init {
    if (self = [super init]) {
//        self.minimumLineSpacing = 20;
        self.supplementaryViewSource = self;
        self.displayDelegate = self;
    }
    return self;
}

- (FHHouseDetailPhoneCallViewModel *)phoneCallViewModel {
    if (!_phoneCallViewModel) {
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc] initWithHouseType:FHHouseTypeNewHouse houseId:self.detailViewController.viewModel.houseId];
        _phoneCallViewModel.tracerDict = self.detailViewController.viewModel.detailTracerDic.copy;
        
    }
    return _phoneCallViewModel;
}

#pragma mark - Action
// 证书点击
- (void)licenseClick:(FHDetailContactModel *)model {
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    NSUInteger index = [agentSM.recommendedRealtors indexOfObject:model];
    if (index >= 0 && agentSM.recommendedRealtors.count > 0 && index < agentSM.recommendedRealtors.count) {
        [self.phoneCallViewModel licenseActionWithPhone:model];
    }
}

// 电话点击
- (void)phoneClick:(FHDetailContactModel *)model {
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
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

        associatePhone.houseType = FHHouseTypeNewHouse;
        associatePhone.houseId = self.detailViewController.viewModel.houseId;
        associatePhone.showLoading = NO;
        
        if (model.bizTrace) {
            associatePhone.extraDict = @{@"biz_trace":model.bizTrace};
        }
        
        [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
//            if(success && [model.belongsVC isKindOfClass:[FHHouseDetailViewController class]]){
//                FHHouseDetailViewController *vc = (FHHouseDetailViewController *)model.belongsVC;
//                vc.isPhoneCallShow = YES;
//                vc.phoneCallRealtorId = contact.realtorId;
//                vc.phoneCallRequestId = virtualPhoneNumberModel.requestId;
//            }
        }];

        FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:extraDict error:nil];
        configModel.houseType = FHHouseTypeNewHouse;
        configModel.followId = self.detailViewController.viewModel.houseId;
        configModel.actionType = FHHouseTypeNewHouse;
        
        // 静默关注功能
        [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
    }

}

// 点击会话
- (void)imclick:(FHDetailContactModel *)model {
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
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

- (NSInteger)numberOfItems {
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    if (agentSM.recommendedRealtors.count <= 3) {
        return agentSM.recommendedRealtors.count;
    }
    if (agentSM.isFold) {
        return 4;
    } else {
        return agentSM.recommendedRealtors.count + 1;
    }
    return 0;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    CGFloat height = 65;
    if (index == agentSM.recommendedRealtors.count) {
        height = 55;
    }
    return CGSizeMake(width, height);
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    if ((!agentSM.isFold && agentSM.recommendedRealtors.count > 3 && index == agentSM.recommendedRealtors.count) || (agentSM.isFold && agentSM.recommendedRealtors.count > 3 && index == 3)) {
        //展开，收起
        FHNewHouseDetailReleatorMoreCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailReleatorMoreCell class] forSectionController:self atIndex:index];
        __weak FHNewHouseDetailAgentSM *weakAgentSM = agentSM;
        [cell setFoldButtonActionBlock:^{
            weakAgentSM.isFold = !weakAgentSM.isFold;
            if (!weakAgentSM.isFold) {
                [weakSelf addRealtorClickMore];
            }
            [weakSelf.detailViewController reloadData];
//            [weakSelf.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext>  _Nonnull batchContext) {
//                [batchContext reloadInSectionController:weakSelf atIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(3, weakAgentSM.recommendedRealtors.count - 3 + 1)]];
////                [batchContext reloadSectionController:weakSelf];
//            } completion:^(BOOL finished) {
//
//            }];
//            weakSelf.collectionContext relo
        }];
        cell.foldButton.isFold = agentSM.isFold;
        return cell;
    } else {
        FHDetailContactModel *model = agentSM.recommendedRealtors[index];
        FHNewHouseDetailReleatorCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailReleatorCollectionCell class] forSectionController:self atIndex:index];
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
        return cell;
    }
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    //新房暂时不需要跳转
//    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
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
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;

    // 设置下发标题
    if(agentSM.recommendedRealtorsTitle.length > 0) {
        titleView.titleLabel.text = agentSM.recommendedRealtorsTitle;
    }else {
        titleView.titleLabel.text = @"优选顾问";
    }
    [titleView setSubTitleWithTitle:agentSM.recommendedRealtorsSubTitle];

    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 46);
    }
    return CGSizeZero;
}

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController {
    
}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController {
    
}

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    if ([cell isKindOfClass:[FHNewHouseDetailReleatorCollectionCell class]]) {
        NSString *cahceKey = [NSString stringWithFormat:@"%@_%d",NSStringFromClass([self class]), index];
        if (self.elementShowCaches[cahceKey]) {
            return;
        }
        self.elementShowCaches[cahceKey] = @(YES);
        FHNewHouseDetailAgentSM *sectionModel = (FHNewHouseDetailAgentSM *)self.sectionModel;
        FHDetailContactModel *contact = sectionModel.recommendedRealtors[index];
        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
        tracerDic[@"element_type"] = @"new_detail_related";
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

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    
}

@end
