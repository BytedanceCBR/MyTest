//
//  FHNewHouseDetailMultiFloorpanCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/7.
//

#import "FHNewHouseDetailMultiFloorpanCollectionCell.h"
#import "FHDetailHeaderView.h"
#import <FHHouseBase/FHHouseIMClueHelper.h>

@interface FHNewHouseDetailMultiFloorpanCollectionCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) FHDetailHeaderView *headerView;
@property (nonatomic, strong) NSMutableDictionary *houseShowCache;
@property (nonatomic, strong) NSMutableDictionary *subHouseShowCache;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@end

@implementation FHNewHouseDetailMultiFloorpanCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailMultiFloorpanCellModel class]]) {
        CGFloat height = 46;
        height += 190;
        FHNewHouseDetailMultiFloorpanCellModel *model = (FHNewHouseDetailMultiFloorpanCellModel *)data;
        BOOL hasIM = NO;
        for (NSInteger i = 0; i < model.floorPanList.list.count; i++) {
            FHDetailNewDataFloorpanListListModel *listItemModel = model.floorPanList.list[i];
            listItemModel.index = i;
            if (listItemModel.imOpenUrl.length > 0) {
                hasIM = YES;
                break;
            }
        }
        if (hasIM) {
            height += 30;
        }
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_model";
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.houseShowCache = [NSMutableDictionary new];
        self.subHouseShowCache = [NSMutableDictionary new];
        
        _headerView = [[FHDetailHeaderView alloc] init];
        _headerView.label.text = @"楼盘户型";
        _headerView.backgroundColor = [UIColor clearColor];
        [self.headerView addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_headerView];
        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(46);
        }];
        
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        self.flowLayout.itemSize = CGSizeMake(120, 190);
        self.flowLayout.minimumLineSpacing = 16;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)) collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self.contentView addSubview:self.collectionView];
        [self.collectionView registerClass:[FHDetailNewMutiFloorPanCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class])];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headerView.mas_bottom);
            make.left.right.mas_equalTo(self.contentView);
            make.bottom.mas_equalTo(self.contentView).mas_offset(-9);
        }];
        
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailMultiFloorpanCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHNewHouseDetailMultiFloorpanCellModel *currentModel = (FHNewHouseDetailMultiFloorpanCellModel *)data;

    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if (model.list) {
        BOOL hasIM = NO;
        for (NSInteger i = 0; i < model.list.count; i++) {
            FHDetailNewDataFloorpanListListModel *listItemModel = model.list[i];
            listItemModel.index = i;
            if (listItemModel.imOpenUrl.length > 0) {
                hasIM = YES;
            }
        }
        if (model.totalNumber.length > 0) {
            self.headerView.label.text = [NSString stringWithFormat:@"户型介绍（%@）",model.totalNumber];
            if (model.totalNumber.integerValue >= 3) {
                self.headerView.isShowLoadMore = YES;
                self.headerView.userInteractionEnabled = YES;
            } else {
                self.headerView.isShowLoadMore = NO;
                self.headerView.userInteractionEnabled = NO;
            }
        } else {
            self.headerView.label.text = @"户型介绍";
            self.headerView.isShowLoadMore = NO;
            self.headerView.userInteractionEnabled = NO;
        }
        CGFloat itemHeight = 190;
        if (hasIM) {
            itemHeight = 190 + 30;
        }
        self.flowLayout.itemSize = CGSizeMake(120, itemHeight);
        
        [self.collectionView reloadData];
    }
    
    [self layoutIfNeeded];
}

// 不重复调用
- (void)collectionDisplayCell:(NSInteger)index
{
//    FHDetailNewMutiFloorPanCellModel *currentModel = (FHDetailNewMutiFloorPanCellModel *)self.currentData;
//    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
//    if (model.list && model.list.count > 0 && index >= 0 && index < model.list.count) {
//        // 点击cell处理
//        FHDetailNewDataFloorpanListListModel *itemModel = model.list[index];
//        // house_show
//        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
//        tracerDic[@"rank"] = @(index);
//        tracerDic[@"card_type"] = @"slide";
//        tracerDic[@"log_pb"] = itemModel.logPb ? itemModel.logPb : @"be_null";
//        tracerDic[@"house_type"] = @"house_model";
//        tracerDic[@"element_type"] = @"house_model";
//        if (itemModel.logPb) {
//            [tracerDic addEntriesFromDictionary:itemModel.logPb];
//        }
//        if (itemModel.searchId) {
//            [tracerDic setValue:itemModel.searchId forKey:@"search_id"];
//        }
//        if ([itemModel.groupId isKindOfClass:[NSString class]] && itemModel.groupId.length > 0) {
//            [tracerDic setValue:itemModel.groupId forKey:@"group_id"];
//        }else
//        {
//            [tracerDic setValue:itemModel.id forKey:@"group_id"];
//        }
//        if (itemModel.imprId) {
//            [tracerDic setValue:itemModel.imprId forKey:@"impr_id"];
//        }
//        [tracerDic removeObjectForKey:@"enter_from"];
//        [tracerDic removeObjectForKey:@"element_from"];
//        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
//    }
}

// 查看更多
- (void)moreButtonClick:(UIButton *)button {
    FHNewHouseDetailMultiFloorpanCellModel *currentModel = (FHNewHouseDetailMultiFloorpanCellModel *)self.currentData;
    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;

//    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
//        NSMutableDictionary *infoDict = [NSMutableDictionary new];
//        [infoDict setValue:model.list forKey:@"court_id"];
//        [infoDict addEntriesFromDictionary:[self.baseViewModel subPageParams]];
//        infoDict[@"house_type"] = @(1);
//        TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
//        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_pan_list"] userInfo:info];
//    }

}
// cell 点击
- (void)collectionCellClick:(NSInteger)index {
    FHNewHouseDetailMultiFloorpanCellModel *currentModel = (FHNewHouseDetailMultiFloorpanCellModel *)self.currentData;
    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if ([model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        if (model.list.count > index) {
            FHDetailNewDataFloorpanListListModel *floorPanInfoModel = model.list[index];
            if ([floorPanInfoModel isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
                NSMutableDictionary *traceParam = [NSMutableDictionary new];
                traceParam[@"enter_from"] = @"new_detail";
                traceParam[@"log_pb"] = floorPanInfoModel.logPb;
//                traceParam[@"origin_from"] = self.baseViewModel.detailTracerDic[@"origin_from"];
                traceParam[@"card_type"] = @"left_pic";
                traceParam[@"rank"] = @(floorPanInfoModel.index);
//                traceParam[@"origin_search_id"] = self.baseViewModel.detailTracerDic[@"origin_search_id"];
                traceParam[@"element_from"] = @"house_model";
                NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
                infoDict[@"house_type"] = @(1);
                [infoDict setValue:floorPanInfoModel.id forKey:@"floor_plan_id"];
//                NSMutableDictionary *subPageParams = [self.baseViewModel subPageParams].mutableCopy;
//                subPageParams[@"contact_phone"] = nil;
//                [infoDict addEntriesFromDictionary:subPageParams];
                infoDict[@"tracer"] = traceParam;
                TTRouteUserInfo *info = [[TTRouteUserInfo alloc] initWithInfo:infoDict];

                [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://floor_plan_detail"] userInfo:info];
            }
        }
    }
}

- (void)collectionCellItemClick:(NSInteger)index item:(UIView *)itemView cell:(FHDetailBaseCollectionCell *)cell
{
    FHDetailNewMutiFloorPanCollectionCell *collectionCell = (FHDetailNewMutiFloorPanCollectionCell *)cell;
    if (![collectionCell isKindOfClass:[FHDetailNewMutiFloorPanCollectionCell class]]) {
        return;
    }
    // 一键咨询户型按钮点击
    FHNewHouseDetailMultiFloorpanCellModel *currentModel = (FHNewHouseDetailMultiFloorpanCellModel *)self.currentData;
    FHDetailNewDataFloorpanListModel *model = currentModel.floorPanList;
    if(collectionCell.consultDetailButton != itemView || ![model isKindOfClass:[FHDetailNewDataFloorpanListModel class]]) {
        return;
    }
    if (index < 0 || index >= model.list.count ) {
        return;
    }
    FHDetailNewDataFloorpanListListModel *floorPanInfoModel = model.list[index];
    if (![floorPanInfoModel isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
        return;
    }
    
    // IM 透传数据模型
//    FHAssociateIMModel *associateIMModel = [FHAssociateIMModel new];
//    associateIMModel.houseId = self.baseViewModel.houseId;
//    associateIMModel.houseType = self.baseViewModel.houseType;
//    associateIMModel.associateInfo = floorPanInfoModel.associateInfo;

    // IM 相关埋点上报参数
//    FHAssociateReportParams *reportParams = [FHAssociateReportParams new];
//    reportParams.enterFrom = self.baseViewModel.detailTracerDic[@"enter_from"];
//    reportParams.elementFrom = @"house_model";
//    reportParams.logPb = floorPanInfoModel.logPb;
//    reportParams.originFrom = self.baseViewModel.detailTracerDic[@"origin_from"];
//    reportParams.rank = self.baseViewModel.detailTracerDic[@"rank"];
//    reportParams.originSearchId = self.baseViewModel.detailTracerDic[@"origin_search_id"];
//    reportParams.searchId = self.baseViewModel.detailTracerDic[@"search_id"];
//    reportParams.pageType = [self.baseViewModel pageTypeString];
//    FHDetailContactModel *contactPhone = self.baseViewModel.contactViewModel.contactPhone;
//    reportParams.realtorId = contactPhone.realtorId;
//    reportParams.realtorRank = @(0);
//    reportParams.conversationId = @"be_null";
//    reportParams.realtorLogpb = contactPhone.realtorLogpb;
//    reportParams.realtorPosition = @"house_model";
//    reportParams.sourceFrom = @"house_model";
//    reportParams.extra = @{@"house_model_rank":@(index)};
//    associateIMModel.reportParams = reportParams;
    
    // IM跳转链接
//    associateIMModel.imOpenUrl = floorPanInfoModel.imOpenUrl;
    // 跳转IM
//    [FHHouseIMClueHelper jump2SessionPageWithAssociateIM:associateIMModel];
}

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
    if (vcParentView) {
        //            UIWindow* window = [UIApplication sharedApplication].keyWindow;
        CGFloat SH = [UIScreen mainScreen].bounds.size.height;
        CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
        CGFloat bottombarHight = 80;
        if (SH - bottombarHight > point.y) {
            if ([self.houseShowCache valueForKey:@"isShowFloorPan"]) {
                return;
            }else {
                NSArray * visibles = self.collectionView.indexPathsForVisibleItems;
                [self.houseShowCache setValue:@(YES) forKey:@"isShowFloorPan"];
                [visibles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSIndexPath *indexPath = (NSIndexPath *)obj;
                    [self collectionDisplayCell:indexPath.row];
                    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
                    [self.subHouseShowCache setValue:@(YES) forKey:tempKey];
                }];
            }
        }
    }
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [(FHNewHouseDetailMultiFloorpanCellModel *)self.currentData floorPanList].list.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHNewHouseDetailMultiFloorpanCellModel *model = (FHNewHouseDetailMultiFloorpanCellModel *)self.currentData;
    FHDetailNewMutiFloorPanCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHDetailNewMutiFloorPanCollectionCell class]) forIndexPath:indexPath];
    if (indexPath.row < model.floorPanList.list.count) {
        [cell refreshWithData:model.floorPanList.list[indexPath.row]];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];

}

@end

@implementation FHNewHouseDetailMultiFloorpanCellModel

@end
