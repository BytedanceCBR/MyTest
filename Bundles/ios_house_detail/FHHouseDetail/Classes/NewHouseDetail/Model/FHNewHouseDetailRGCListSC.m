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

@interface FHNewHouseDetailRGCListSC () <IGListSupplementaryViewSource>

@property (nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property (nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property (nonatomic, strong) FHRealtorEvaluatingTracerHelper *tracerHelper;

@end

@implementation FHNewHouseDetailRGCListSC

- (instancetype)init
{
    if (self = [super init]) {
        //        self.minimumLineSpacing = 20;
        self.supplementaryViewSource = self;

        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = 1;
        self.tracerHelper = [[FHRealtorEvaluatingTracerHelper alloc] init];
    }
    return self;
}

#pragma mark - Action
- (void)commentClicked:(FHFeedUGCCellModel *)cellModel {
    [self trackClickComment:cellModel];
//    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)gotoLinkUrl:(FHFeedUGCCellModel *)cellModel url:(NSURL *)url {
    // PM要求点富文本链接也进入详情页
    [self lookAllLinkClicked:cellModel cell:nil];
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

- (void)clickRealtorHeader:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
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
    NSDictionary *dict = @{@"tracer":tracer};
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openURL = [NSURL URLWithString:sectionModel.contentModel.schema];
    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:userInfo];
    }
}

- (void)goToCommunityDetail:(FHFeedUGCCellModel *)cellModel {
    [self.detailJumpManager goToCommunityDetail:cellModel];
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
//    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    TRACK_EVENT(@"click_comment", dict);
}

- (NSInteger)numberOfItems {
    FHNewHouseDetailRGCListSM *model = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    return model.items.count;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index
{
    CGFloat width = self.collectionContext.containerSize.width - 15 * 2;
    FHNewHouseDetailRGCListSM *model = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    FHFeedUGCCellModel *cellModel = model.items[index];
    if (cellModel.cellType == FHUGCFeedListCellTypeUGC) {
        return [FHNewHouseDetailRGCImageCollectionCell cellSizeWithData:cellModel width:width];
    } else if (cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo) {
        return [FHNewHouseDetailRGCVideoCollectionCell cellSizeWithData:cellModel width:width];
    }
    return CGSizeZero;
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index
{
    FHNewHouseDetailRGCListSM *model = (FHNewHouseDetailRGCListSM *)self.sectionModel;
    FHFeedUGCCellModel *cellModel = model.items[index];
    if (cellModel.cellType == FHUGCFeedListCellTypeUGC) {
        FHNewHouseDetailRGCImageCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailRGCImageCollectionCell class] withReuseIdentifier:@"FHUGCFeedListCellTypeUGC" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    } else if (cellModel.cellType == FHUGCFeedListCellTypeUGCSmallVideo) {
        FHNewHouseDetailRGCVideoCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[FHNewHouseDetailRGCVideoCollectionCell class] withReuseIdentifier:@"FHUGCFeedListCellTypeUGCSmallVideo" forSectionController:self atIndex:index];
        [cell refreshWithData:cellModel];
        return cell;
    }
    return nil;
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
    titleView.titleLabel.font = [UIFont themeFontMedium:20];
    titleView.titleLabel.textColor = [UIColor themeGray1];
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
        return CGSizeMake(self.collectionContext.containerSize.width - 15 * 2, 46);
    }
    return CGSizeZero;
}
@end
