//
//  FHNewHouseDetailRGCListSC.m
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHNewHouseDetailRGCListSC.h"
#import "FHNewHouseDetailRGCListSM.h"
#import "FHDetailSectionTitleCollectionView.h"
#import "FHAssociateIMModel.h"
#import "FHNewHouseDetailViewController.h"
#import "FHNewHouseDetailViewModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHHouseIMClueHelper.h"
#import "FHNewHouseDetailRGCImageCollectionCell.h"
#import "FHNewHouseDetailRGCVideoCollectionCell.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "FHRealtorEvaluatingTracerHelper.h"

@interface FHNewHouseDetailRGCListSC () <IGListSupplementaryViewSource, IGListDisplayDelegate>

@property (nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property (nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property (nonatomic, strong) FHRealtorEvaluatingTracerHelper *tracerHelper;
@property (nonatomic, assign) BOOL canElementShow;

@end

@implementation FHNewHouseDetailRGCListSC

- (instancetype)init
{
    if (self = [super init]) {
        //        self.minimumLineSpacing = 20;
        self.supplementaryViewSource = self;
        self.displayDelegate = self;
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = 1;
        self.tracerHelper = [[FHRealtorEvaluatingTracerHelper alloc] init];
        _canElementShow = YES;
    }
    return self;
}

- (FHRealtorEvaluatingPhoneCallModel *)realtorPhoneCallModel {
    if (!_realtorPhoneCallModel) {
        FHNewHouseDetailRGCListSM *sectionModel = (FHNewHouseDetailRGCListSM *)self.sectionModel;
        _realtorPhoneCallModel = [[FHRealtorEvaluatingPhoneCallModel alloc]initWithHouseType:FHHouseTypeNewHouse houseId:self.detailViewController.viewModel.houseId];
        _realtorPhoneCallModel.tracerDict = sectionModel.detailTracerDic;
        _realtorPhoneCallModel.belongsVC = self.viewController;
    }
    return _realtorPhoneCallModel;
}

#pragma mark - Action
- (void)commentClicked:(FHFeedUGCCellModel *)cellModel {
    [self trackClickComment:cellModel];
//    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    // PM要求点富文本链接也进入详情页
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];

}

- (void)clickRealtorIm:(FHFeedUGCCellModel *)cellModel {
    FHNewHouseDetailRGCListSM *sectionModel = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    NSInteger index = [sectionModel.items indexOfObject:cellModel];
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"realtor_position"] = @"realtor_evaluate";
    imExtra[@"from_gid"] = cellModel.groupId;
//    if ([self.currentData isKindOfClass:[FHhouseDetailRGCListCellModel class]]) {
//        FHhouseDetailRGCListCellModel *cellModel = (FHhouseDetailRGCListCellModel *)self.currentData;
//       imExtra[@"bizTrace"] = cellModel.houseInfoBizTrace;
//    }
    [self.realtorPhoneCallModel imchatActionWithPhone:cellModel.realtor realtorRank:[NSString stringWithFormat:@"%ld",(long)index] extraDic:imExtra];
}

- (void)clickRealtorPhone:(FHFeedUGCCellModel *)cellModel {
    FHNewHouseDetailRGCListSM *sectionModel = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    NSDictionary *houseInfo = sectionModel.extraDic;
    NSMutableDictionary *extraDict = self.detailViewController.viewModel.detailTracerDic.mutableCopy;
    extraDict[@"realtor_id"] = cellModel.realtor.realtorId;
    extraDict[@"realtor_rank"] = @"be_null";
    extraDict[@"realtor_logpb"] = cellModel.realtor.realtorLogpb;
    extraDict[@"realtor_position"] = @"realtor_evaluate";
    extraDict[@"from_gid"] = cellModel.groupId;
    NSDictionary *associateInfoDict = cellModel.realtor.associateInfo.phoneInfo;
    extraDict[kFHAssociateInfo] = associateInfoDict;
    FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
    associatePhone.reportParams = extraDict;
    associatePhone.associateInfo = associateInfoDict;
    associatePhone.realtorId = cellModel.realtor.realtorId;
    associatePhone.searchId = houseInfo[@"searchId"];
    associatePhone.imprId = houseInfo[@"imprId"];
    associatePhone.houseType = [NSString  stringWithFormat:@"%@",houseInfo[@"houseType"]].intValue;
    associatePhone.houseId = houseInfo[@"houseId"];
    associatePhone.showLoading = NO;
//    if ([self.currentData isKindOfClass:[FHhouseDetailRGCListCellModel class]]) {
//          FHhouseDetailRGCListCellModel *cellModel = (FHhouseDetailRGCListCellModel *)self.currentData;
//        if (cellModel.houseInfoBizTrace) {
//            associatePhone.extraDict = @{@"biz_trace":cellModel.houseInfoBizTrace};
//        }
//      }
    [self.realtorPhoneCallModel phoneChatActionWithAssociateModel:associatePhone];
}

- (void)clickRealtorHeader:(FHFeedUGCCellModel *)cellModel {
    FHNewHouseDetailRGCListSM *sectionModel = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    NSDictionary *houseInfo = sectionModel.extraDic;
    if ([houseInfo[@"houseType"] integerValue] == FHHouseTypeSecondHandHouse) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         dict[@"element_from"] = @"old_detail_related";
        dict[@"enter_from"] = [self.detailViewController.viewModel pageTypeString];
        [self.realtorPhoneCallModel jump2RealtorDetailWithPhone:cellModel.realtor isPreLoad:NO extra:dict];
    }
}

- (void)moreButtonClick {
    FHNewHouseDetailRGCListSM *sectionModel = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    NSDictionary *houseInfo = sectionModel.extraDic;
    NSMutableDictionary *tracer = @{}.mutableCopy;
    [tracer addEntriesFromDictionary:sectionModel.detailTracerDic];
    [tracer setValue:houseInfo[@"houseId"] forKey:@"from_gid"];
    [tracer setValue:tracer[@"page_type"] forKey:@"enter_from"];
    [tracer setValue:@"realtor_evaluate" forKey:@"element_from"];
    NSDictionary *dict = @{@"tracer":tracer};
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openURL = [NSURL URLWithString:sectionModel.contentModel.schema];
    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:userInfo];
    }
}

- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    TRACK_EVENT(@"click_comment", dict);
}

#pragma mark -
- (NSInteger)numberOfItems {
    FHNewHouseDetailRGCListSM *model = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index
{
    CGFloat width = self.collectionContext.containerSize.width - FHNewHouseDetailSectionLeftMargin * 2;
    FHNewHouseDetailRGCListSM *model = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    FHFeedUGCCellModel *cellModel = model.items[index];
    CGSize size = CGSizeZero;
    if (cellModel.cellType == FHUGCFeedListCellTypeUGC) {
        size = [FHNewHouseDetailRGCImageCollectionCell cellSizeWithData:cellModel width:width];
    } else if (cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo) {
        size = [FHNewHouseDetailRGCVideoCollectionCell cellSizeWithData:cellModel width:width];
    }
    if (index < model.items.count - 1) {
        size.height += 12;
    }
    return size;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
{
    FHNewHouseDetailRGCListSM *model = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    FHFeedUGCCellModel *cellModel = model.items[index];
    __weak typeof(self) weakSelf = self;
    if (cellModel.cellType == FHUGCFeedListCellTypeUGC) {
        FHNewHouseDetailRGCImageCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailRGCImageCollectionCell class] withReuseIdentifier:@"FHUGCFeedListCellTypeUGC" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        [cell setClickIMBlock:^(FHFeedUGCCellModel * _Nonnull model) {
            [weakSelf clickRealtorIm:model];
        }];
        [cell setClickPhoneBlock:^(FHFeedUGCCellModel * _Nonnull model) {
            [weakSelf clickRealtorPhone:model];
        }];
        [cell setClickRealtorHeaderBlock:^(FHFeedUGCCellModel * _Nonnull model) {
            [weakSelf clickRealtorHeader:model];
        }];
        [cell setClickLinkBlock:^(FHFeedUGCCellModel * _Nonnull model, NSURL * _Nonnull url) {
            [weakSelf gotoLinkUrl:model url:url];
        }];
        return cell;
    } else if (cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo) {
        FHNewHouseDetailRGCVideoCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailRGCVideoCollectionCell class] withReuseIdentifier:@"FHUGCFeedListCellTypeUGCSmallVideo" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        [cell setClickIMBlock:^(FHFeedUGCCellModel * _Nonnull model) {
            [weakSelf clickRealtorIm:model];
        }];
        [cell setClickPhoneBlock:^(FHFeedUGCCellModel * _Nonnull model) {
            [weakSelf clickRealtorPhone:model];
        }];
        [cell setClickRealtorHeaderBlock:^(FHFeedUGCCellModel * _Nonnull model) {
            [weakSelf clickRealtorHeader:model];
        }];
        [cell setClickLinkBlock:^(FHFeedUGCCellModel * _Nonnull model, NSURL * _Nonnull url) {
            [weakSelf gotoLinkUrl:model url:url];
        }];
        return cell;
    }
    return [super defaultCellAtIndex:index];
}



- (void)didSelectItemAtIndex:(NSInteger)index {
    FHNewHouseDetailRGCListSM *model = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    FHFeedUGCCellModel *cellModel = model.items[index];
//    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

#pragma mark - IGListSupplementaryViewSource
- (NSArray<NSString *> *)supportedElementKinds
{
    return @[ UICollectionElementKindSectionHeader ];
}

- (__kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(NSString *)elementKind
                                                                 atIndex:(NSInteger)index
{
    FHDetailSectionTitleCollectionView *titleView = [self.collectionContext dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader forSectionController:self class:[FHDetailSectionTitleCollectionView class] atIndex:index];
    [titleView setupNewHouseDetailStyle];
    __weak typeof(self) weakSelf = self;
    titleView.arrowsImg.hidden = NO;
    titleView.userInteractionEnabled = YES;
    [titleView setMoreActionBlock:^{
        [weakSelf moreButtonClick];
    }];

    FHNewHouseDetailRGCListSM *sectionModel = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    titleView.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)",sectionModel.title,sectionModel.count];
    return titleView;
}

- (CGSize)sizeForSupplementaryViewOfKind:(NSString *)elementKind
                                 atIndex:(NSInteger)index
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return CGSizeMake(self.collectionContext.containerSize.width - FHNewHouseDetailSectionLeftMargin * 2, 46);
    }
    return CGSizeZero;
}

#pragma mark - IGListDisplayDelegate

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController {
    
}

/**
 Tells the delegate that the specified section controller is no longer being displayed.

 @param listAdapter       The list adapter for the section controller.
 @param sectionController The section controller that is no longer displayed.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController {
    
}

/**
 Tells the delegate that a cell in the specified list is about to be displayed.

 @param listAdapter The list adapter in which the cell will display.
 @param sectionController The section controller that is displaying the cell.
 @param cell The cell about to be displayed.
 @param index The index of the cell in the section.
 */

- (void)listAdapter:(IGListAdapter *)listAdapter willDisplaySectionController:(IGListSectionController *)sectionController cell:(UICollectionViewCell *)cell atIndex:(NSInteger)index {
    FHNewHouseDetailRGCListSM *model = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    FHFeedUGCCellModel *cellModel = model.items[index];
    NSString *tempKey = [NSString stringWithFormat:@"%@_%ld", NSStringFromClass([self class]), index];
    if ([self.elementShowCaches valueForKey:tempKey]) {
        return;
    }
    [self.elementShowCaches setValue:@(YES) forKey:tempKey];
    NSDictionary *houseInfo = model.extraDic;
    NSDictionary *extraDic = @{}.mutableCopy;
    [extraDic setValue:self.detailTracerDict[@"page_type"] forKey:@"page_type"];
    [extraDic setValue:[NSString stringWithFormat:@"%ld",(long)index] forKey:@"rank"];
    [extraDic setValue:houseInfo[@"houseId"] forKey:@"from_gid"];
    [extraDic setValue:cellModel.groupId forKey:@"group_id"];
    [extraDic setValue:@"realtor_evaluate" forKey:@"element_type"];
    [self.tracerHelper trackFeedClientShow:cellModel withExtraDic:extraDic];
    
    if (self.canElementShow) {
        self.canElementShow = NO;
        NSMutableDictionary *tracerDic = self.detailTracerDict.mutableCopy;
        tracerDic[@"element_type"] = @"realtor_evaluate";
        [tracerDic removeObjectForKey:@"element_from"];
        tracerDic[@"page_type"] = @"new_detail";
        [FHUserTracker writeEvent:@"element_show" params:tracerDic];
    }
}

/**
 Tells the delegate that a cell in the specified list is no longer being displayed.

 @param listAdapter The list adapter in which the cell was displayed.
 @param sectionController The section controller that is no longer displaying the cell.
 @param cell The cell that is no longer displayed.
 @param index The index of the cell in the section.
 */
- (void)listAdapter:(IGListAdapter *)listAdapter didEndDisplayingSectionController:(IGListSectionController *)sectionController
               cell:(UICollectionViewCell *)cell
            atIndex:(NSInteger)index {
    
}

@end
