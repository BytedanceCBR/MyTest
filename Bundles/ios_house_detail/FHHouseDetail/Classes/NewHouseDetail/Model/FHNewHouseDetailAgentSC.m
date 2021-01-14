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
#import "NSDictionary+BTDAdditions.h"
#import "NSArray+BTDAdditions.h"
#import "JSONModel+FHOriginDictData.h"

@interface FHNewHouseDetailAgentSC ()<IGListSupplementaryViewSource,IGListDisplayDelegate>

@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;

@end

@implementation FHNewHouseDetailAgentSC

- (instancetype)init {
    if (self = [super init]) {
//        self.minimumLineSpacing = 20;
        self.supplementaryViewSource = self;
        self.displayDelegate = self;
//        self.dataSource = self;
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
    return 3;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    CGFloat width = self.collectionContext.containerSize.width - FHNewHouseDetailSectionLeftMargin * 2;
    if (index < agentSM.recommendedRealtors.count) {
        FHDetailContactModel *model = agentSM.recommendedRealtors[index];
        return [FHNewHouseDetailReleatorCollectionCell cellSizeWithData:model width:width];
    }
    return CGSizeZero;
}


- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
    if (index < agentSM.recommendedRealtors.count) {
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
    return [super defaultCellAtIndex:index];
}

- (void)didSelectItemAtIndex:(NSInteger)index {
    //新房暂时不需要跳转
//    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
}

//- (void)foldAction {
//    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;
//    agentSM.isFold = !agentSM.isFold;
//    if (!agentSM.isFold) {
//        [self addRealtorClickMore];
//    }
//    agentSM.moreModel = [FHNewHouseDetailReleatorMoreCellModel modelWithFold:agentSM.isFold];
//    [self updateAnimated:YES completion:^(BOOL updated) {
//
//    }];
////            [weakSelf.detailViewController refreshSectionModel:weakAgentSM animated:YES];
//}

- (void)pushMoreReleator{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSMutableDictionary *userInfo = @{}.mutableCopy;
    userInfo[@"route"] = @"/recommended_realtors_list";
    

    NSMutableDictionary *tracerDict = self.detailTracerDict.mutableCopy;
    tracerDict[@"event_type"] = @"house_app2c_v2";
    tracerDict[@"element_from"] = @"new_detail_related";
    tracerDict[@"enter_from"] = @"new_detail";
    tracerDict[@"page_type"] =  @"realtor_list";
    tracerDict[@"element_type"] =  @"realtor_list";
    [tracerDict removeObjectsForKeys:@[@"card_type",@"rank",@"log_pb"]];


    NSMutableDictionary *DataInfo = @{}.mutableCopy;
    DataInfo[@"house_type"] = @(FHHouseTypeNewHouse);
    DataInfo[@"group_id"] = self.detailViewController.viewModel.houseId;
//    [self.sectionModel.detailModel.data.logPb btd_stringValueForKey:@"group_id"];
    DataInfo[@"biz_trace"] = @"be_null";
    DataInfo[@"recommended_realtors_title"] = self.sectionModel.detailModel.data.recommendedRealtorsTitle;
    if(self.sectionModel.detailModel.fhOriginDictData){
        NSDictionary *dataInfo = self.sectionModel.detailModel.fhOriginDictData;
        if([dataInfo isKindOfClass:[NSDictionary class]]){
            NSDictionary *dic = dataInfo[@"data"];
            BOOL dicIsDictionary = [dic isKindOfClass:[NSDictionary class]];
            if(self.sectionModel.detailModel.data.recommendedRealtors && dicIsDictionary){
                DataInfo[@"recommended_realtors"] = dic[@"recommended_realtors"] ;
            }
            if(self.sectionModel.detailModel.data.recommendRealtorsAssociateInfo && dicIsDictionary ){
                DataInfo[@"recommended_realtors_associate_info"] = dic[@"recommend_realtors_associate_info"];
            }
            if(self.sectionModel.detailModel.data.logPb && dicIsDictionary){
                DataInfo[@"log_pb"] = dic[@"log_pb"];
            }
        }
    }

    params[@"recommended_realtors_info"] = [DataInfo btd_jsonStringEncoded];
    params[@"report_params"] = [tracerDict btd_jsonStringEncoded];


    userInfo[@"params"] = [params btd_jsonStringEncoded];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://flutter"]] userInfo:TTRouteUserInfoWithDict(userInfo)];
    
    
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader];
}


- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index {
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    [titleView setupNewHouseDetailStyle];
    FHNewHouseDetailAgentSM *agentSM = (FHNewHouseDetailAgentSM *)self.sectionModel;

    // 设置下发标题
    if(agentSM.recommendedRealtorsTitle.length > 0) {
        titleView.titleLabel.text = agentSM.recommendedRealtorsTitle;
    }else {
        titleView.titleLabel.text = @"优选顾问";
    }
    [titleView setSubTitleWithTitle:agentSM.recommendedRealtorsSubTitle];
    [titleView setSubTagView];
    [titleView.arrowsImg setHidden:NO];
    __weak typeof(self) weakSelf = self;
    if(self.sectionModel.detailModel.data.recommendedRealtors.count > 3){
        [titleView setMoreActionBlock:^{
            [weakSelf pushMoreReleator];
        }];
    }else {
        [titleView.arrowsImg setHidden:YES];
    }
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - FHNewHouseDetailSectionLeftMargin * 2, 66);
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
        NSString *cahceKey = [NSString stringWithFormat:@"%@_%ld",NSStringFromClass([self class]), (long)index];
        if (self.elementShowCaches[cahceKey]) {
            return;
        }
        self.elementShowCaches[cahceKey] = @(YES);
        FHNewHouseDetailAgentSM *sectionModel = (FHNewHouseDetailAgentSM *)self.sectionModel;
        FHDetailContactModel *contact = sectionModel.recommendedRealtors[index];
        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
        tracerDic[@"element_type"] = @"realtor_list";
        tracerDic[@"realtor_id"] = contact.realtorId ?: @"be_null";
        tracerDic[@"realtor_rank"] = @(index);
        tracerDic[@"realtor_logpb"] = contact.realtorLogpb ?: @"be_null";
        tracerDic[@"enter_from"] = @"new_detail";
        tracerDic[@"page_type"] = @"realtor_list";
        tracerDic[@"element_from"] = @"new_detail_related";
        tracerDic[@"group_id"] = self.detailViewController.viewModel.houseId ?: @"be_null";
        [tracerDic removeObjectsForKeys:@[@"card_type",@"rank",@"origin_search_id",@"app_house_tags",@"log_pb"]];
        [FHUserTracker writeEvent:@"realtor_show" params:tracerDic];
    }
    
}

- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    
}

@end
