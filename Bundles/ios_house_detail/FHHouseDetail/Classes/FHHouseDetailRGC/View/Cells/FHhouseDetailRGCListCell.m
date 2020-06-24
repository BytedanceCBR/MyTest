//
//  FHhouseDetailRGCListCellTableViewCell.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/15.
//

#import "FHhouseDetailRGCListCell.h"
#import "FHUGCCellManager.h"
#import "FHFeedUGCCellModel.h"
#import "TTStringHelper.h"
#import "FHUGCBaseCell.h"
#import "FHFeedUGCCellModel.h"
#import "FHDetailHeaderView.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "FHRealtorEvaluatingTracerHelper.h"
@interface  FHhouseDetailRGCListCell ()<UITableViewDelegate,UITableViewDataSource,FHUGCBaseCellDelegate>
@property (nonatomic , strong) NSMutableArray *dataList;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic , strong) UIView *titleView;
@property (nonatomic , strong) UILabel *titleLabel;
@property (nonatomic , strong) FHUGCCellManager *cellManager;
@property (nonatomic, strong) FHDetailHeaderView *headerView;
@property(nonatomic, strong) FHUGCBaseCell *currentCell;
@property(nonatomic, strong) FHFeedUGCCellModel *currentCellModel;
@property(nonatomic, strong) FHUGCFeedDetailJumpManager *detailJumpManager;
@property(nonatomic, strong) FHRealtorEvaluatingPhoneCallModel *realtorPhoneCallModel;
@property (nonatomic, strong)NSMutableDictionary *elementShowCaches;
@property (nonatomic, strong)FHRealtorEvaluatingTracerHelper *tracerHelper;
@end
@implementation FHhouseDetailRGCListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self initConstaints];
        self.detailJumpManager = [[FHUGCFeedDetailJumpManager alloc] init];
        self.detailJumpManager.refer = 1;
        self.elementShowCaches = [[NSMutableDictionary alloc]init];
        self.tracerHelper = [[FHRealtorEvaluatingTracerHelper alloc]init];
    }
    return self;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    //    self.contentView.backgroundColor = [UIColor themeGray7];
    self.tableView = [[UITableView alloc] init];
    _tableView.layer.masksToBounds = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.sectionFooterHeight = 0.0;
    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.isShowLoadMore = YES;
    [self.headerView addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:_headerView];
    [self.containerView addSubview:_tableView];
    
    self.cellManager = [[FHUGCCellManager alloc] init];
    [self.cellManager registerAllCell:_tableView];
}

- (void)initConstaints {
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(20);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.shadowImage).offset(-20);
    }];
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(10);
        make.left.mas_equalTo(self.containerView).offset(15);
        make.right.mas_equalTo(self.containerView).offset(-15);
        make.height.mas_equalTo(65);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.mas_equalTo(self.containerView).offset(15);
        make.right.mas_equalTo(self.containerView).offset(-15);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.containerView).offset(-12);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleView).offset(30);
        make.left.mas_equalTo(self.titleView).offset(16);
        make.right.mas_equalTo(self.titleView.mas_left).offset(-10);
        make.height.mas_equalTo(25);
    }];
    
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHhouseDetailRGCListCellModel class]]) {
        return;
    }
    self.currentData = data;
      
    FHhouseDetailRGCListCellModel *cellModel = (FHhouseDetailRGCListCellModel *)data;
    self.headerView.label.text = [NSString stringWithFormat:@"%@ (%@)",cellModel.title,cellModel.count];
    
    NSDictionary *houseInfo = cellModel.extraDic;
    
    self.realtorPhoneCallModel = [[FHRealtorEvaluatingPhoneCallModel alloc]initWithHouseType:[NSString stringWithFormat:@"%@",houseInfo[@"houseType"]].intValue houseId:houseInfo[@"houseId"]];
    self.realtorPhoneCallModel.tracerDict = cellModel.detailTracerDic;
    self.realtorPhoneCallModel.belongsVC = cellModel.belongsVC;
    self.tracerHelper.tracerModel = [FHTracerModel makerTracerModelWithDic:cellModel.detailTracerDic];
    self.shadowImage.image = cellModel.shadowImage;
    if(cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    FHDetailBrokerContentModel *contentModel = cellModel.contentModel;
    //    _titleView.height = cellModel.headerViewHeight;
    //    self.tableView.tableHeaderView = _titleView;
    
    //    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.top.mas_equalTo(self.titleView).offset(cellModel.topMargin);
    //    }];
    //
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(cellModel.cellHeight);
    }];
    if (cellModel.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll) {
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    _titleLabel.text = cellModel.title;
    //    [_questionBtn setTitle:cellModel.askTitle forState:UIControlStateNormal];
    
    self.dataList = [[NSMutableArray alloc] init];
    [_dataList addObjectsFromArray:contentModel.fHFeedUGCCellModelDataArr];
    [self.tableView reloadData];
    
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"realtor_evaluate";
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
        if (!self.elementShowCaches[tempKey]) {
            self.elementShowCaches[tempKey] = @(YES);
            FHhouseDetailRGCListCellModel *cellModel = (FHhouseDetailRGCListCellModel *)self.currentData;
            FHFeedUGCCellModel *cellModelItem = self.dataList[indexPath.row];
            NSDictionary *houseInfo = cellModel.extraDic;
            NSDictionary *extraDic = @{}.mutableCopy;
            [extraDic setValue:cellModel.detailTracerDic[@"page_type"] forKey:@"page_type"];
            [extraDic setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"rank"];
            [extraDic setValue:cellModelItem.groupId forKey:@"from_gid"];
            [extraDic setValue:houseInfo[@"house_id"] forKey:@"group_id"];
            [extraDic setValue:[self elementTypeString:FHHouseTypeSecondHandHouse] forKey:@"element_type"];
            [self.tracerHelper trackFeedClientShow:self.dataList[indexPath.row] withExtraDic:extraDic];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        NSString *cellIdentifier = NSStringFromClass([self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil]);
        FHUGCBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            Class cellClass = NSClassFromString(cellIdentifier);
            cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        if(indexPath.row < self.dataList.count){
            [cell refreshWithData:cellModel];
        }
        return cell;
    }
    return [[FHUGCBaseCell alloc] init];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
        Class cellClass = [self.cellManager cellClassFromCellViewType:cellModel.cellSubType data:nil];
        if([cellClass isSubclassOfClass:[FHUGCBaseCell class]]) {
            return [cellClass heightForData:cellModel];
        }
    }
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FHFeedUGCCellModel *cellModel = self.dataList[indexPath.row];
    self.currentCellModel = cellModel;
    self.currentCell = [tableView cellForRowAtIndexPath:indexPath];
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)commentClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    [self trackClickComment:cellModel];
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:YES enterType:@"feed_comment"];
}

- (void)clickRealtorIm:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    NSInteger index = [self.dataList indexOfObject:cellModel];
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"realtor_position"] = @"realtor_evaluate";
    imExtra[@"from_gid"] = cellModel.groupId;
    [self.realtorPhoneCallModel imchatActionWithPhone:cellModel.realtor realtorRank:[NSString stringWithFormat:@"%ld",(long)index] extraDic:imExtra];
}

- (void)clickRealtorPhone:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    FHhouseDetailRGCListCellModel *dataModel = (FHhouseDetailRGCListCellModel *)self.currentData;
    NSDictionary *houseInfo = dataModel.extraDic;
    NSMutableDictionary *extraDict = dataModel.detailTracerDic.mutableCopy;
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
    [self.realtorPhoneCallModel phoneChatActionWithAssociateModel:associatePhone];
}

- (void)clickRealtorHeader:(FHFeedUGCCellModel *)cellModel cell:(FHUGCBaseCell *)cell {
    FHhouseDetailRGCListCellModel *dataModel = (FHhouseDetailRGCListCellModel *)self.currentData;
    NSDictionary *houseInfo = dataModel.extraDic;
    if ([houseInfo[@"houseType"] integerValue] == FHHouseTypeSecondHandHouse) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         dict[@"element_from"] = @"old_detail_related";
         dict[@"enter_from"] = [self.baseViewModel pageTypeString];
        [self.realtorPhoneCallModel jump2RealtorDetailWithPhone:cellModel.realtor isPreLoad:NO extra:dict];
    }
}

- (void)moreButtonClick {
    FHhouseDetailRGCListCellModel *dataModel = (FHhouseDetailRGCListCellModel *)self.currentData;
    NSDictionary *houseInfo = dataModel.extraDic;
    NSMutableDictionary *tracer = @{}.mutableCopy;
    [tracer addEntriesFromDictionary:dataModel.detailTracerDic];
    [tracer setValue:houseInfo[@"houseId"] forKey:@"from_gid"];
    [tracer setValue:tracer[@"page_type"] forKey:@"enter_from"];
    NSDictionary *dict = @{@"tracer":tracer};
    TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openURL = [NSURL URLWithString:dataModel.contentModel.schema];
    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:userInfo];
    }
}

- (void)lookAllLinkClicked:(FHFeedUGCCellModel *)cellModel cell:(nonnull FHUGCBaseCell *)cell {
    self.currentCellModel = cellModel;
    self.currentCell = cell;
    self.detailJumpManager.currentCell = self.currentCell;
    [self.detailJumpManager jumpToDetail:cellModel showComment:NO enterType:@"feed_content_blank"];
}

- (void)trackClickComment:(FHFeedUGCCellModel *)cellModel {
    NSMutableDictionary *dict = [cellModel.tracerDic mutableCopy];
    dict[@"click_position"] = @"feed_comment";
    TRACK_EVENT(@"click_comment", dict);
}

@end

@implementation FHhouseDetailRGCListCellModel

- (void)setContentModel:(FHDetailBrokerContentModel *)contentModel {
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    CGFloat contentHeight = 0;
    for (int m = 0; m < contentModel.data.count;  m++) {
        NSString *content = contentModel.data[m];
        FHFeedUGCCellModel *model = [FHFeedUGCCellModel modelFromFeed:content];
        model.realtorIndex = m;
        switch (model.cellType) {
            case FHUGCFeedListCellTypeUGC:
                model.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerImage;
                contentHeight = model.contentHeight  +75 + 30 + 50 +contentHeight + 40;
                break;
            case FHUGCFeedListCellTypeUGCSmallVideo:
                model.cellSubType = FHUGCFeedListCellSubTypeUGCBrokerVideo;
                contentHeight = model.contentHeight  +150 + 30 + 50 +contentHeight + 90;
                break;
            default:
                break;
        }
        [dataArr addObject:model];
    }
    contentModel.fHFeedUGCCellModelDataArr = dataArr;
    self.cellHeight = contentHeight;
    _contentModel = contentModel;
}



@end
