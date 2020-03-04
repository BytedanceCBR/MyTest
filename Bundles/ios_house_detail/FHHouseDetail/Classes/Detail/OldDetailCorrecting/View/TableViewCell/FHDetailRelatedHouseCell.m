//
//  FHDetailRelatedHouseCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailRelatedHouseCell.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHDetailBottomOpenAllView.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
@interface FHDetailRelatedHouseCell ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   FHDetailBottomOpenAllView       *openAllView;// 查看更多
@property (nonatomic, strong)   NSMutableDictionary       *houseShowCache; // 埋点缓存

@property (nonatomic, strong , nullable) NSArray<FHSearchHouseDataItemsModel> *items;

@end

@implementation FHDetailRelatedHouseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailRelatedHouseModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    // 添加tableView和查看更多
    FHDetailRelatedHouseModel *model = (FHDetailRelatedHouseModel *)data;
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    CGFloat cellHeight = 96;
    BOOL hasMore = model.relatedHouseData.hasMore;
    CGFloat bottomOffset = 20;
    if (hasMore) {
        bottomOffset = 68;
    }
    self.items = model.relatedHouseData.items;
    NSString *title = @"周边房源";
    FHDetailOldModel *oldDetail = self.baseViewModel.detailData;
    if (oldDetail) {
        title = oldDetail.data.recommendedHouseTitle.length > 0 ? oldDetail.data.recommendedHouseTitle : @"周边房源";
    }
    _headerView.label.text = title;
    if (model.relatedHouseData.items.count > 0) {
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tv.estimatedRowHeight = 96;
        tv.estimatedSectionHeaderHeight = 0;
        tv.estimatedSectionFooterHeight = 0;
        tv.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            tv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        tv.separatorStyle = UITableViewCellSeparatorStyleNone;
        tv.showsVerticalScrollIndicator = NO;
        tv.scrollEnabled = NO;
        [tv registerClass:[FHHouseBaseItemCell  class] forCellReuseIdentifier:@"FHHomeSmallImageItemCell"];
        [self.containerView addSubview:tv];
        [tv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView).offset(5);
            make.height.mas_equalTo(cellHeight * model.relatedHouseData.items.count);
            make.left.right.mas_equalTo(self.containerView);
            make.bottom.mas_equalTo(self.containerView).offset(-bottomOffset);
        }];
        self.tableView = tv;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView reloadData];
    }
    if (model.relatedHouseData.hasMore) {
        // 添加查看更多
        self.openAllView = [[FHDetailBottomOpenAllView alloc] init];
        self.openAllView.title.font = [UIFont themeFontRegular:16];
        self.openAllView.title.textColor = [UIColor themeGray3];
        self.openAllView.topBorderView.hidden = YES;
        self.openAllView.settingArrowImageView.image = [UIImage imageNamed:@"arrowicon-feed-4"];
        [self.containerView addSubview:self.openAllView];
        // 查看更多按钮点击
        __weak typeof(self) wSelf = self;
        self.openAllView.didClickCellBlk = ^{
            [wSelf loadMoreDataButtonClick];
        };
        if (self.tableView) {
            // 查看更多相对tableView布局
            [self.openAllView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tableView.mas_bottom);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(48);
                make.bottom.mas_equalTo(self.containerView).offset(-20);
            }];
        } else {
            // 查看更多自己布局
            [self.openAllView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.containerView).offset(20);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(48);
                make.bottom.mas_equalTo(self.containerView).offset(-20);
            }];
        }
    }
    [self layoutIfNeeded];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _houseShowCache = [NSMutableDictionary new];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"周边房源";
    _headerView.label.font = [UIFont themeFontMedium:20];
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(11);
        make.right.mas_equalTo(self.contentView).offset(-11);
        make.top.equalTo(self.shadowImage).offset(22);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.shadowImage).offset(-12);
    }];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"related";// 周边房源
}

// 查看更多按钮点击
- (void)loadMoreDataButtonClick {
    FHDetailRelatedHouseModel *model = (FHDetailRelatedHouseModel *)self.currentData;
    if (model.relatedHouseData.hasMore)
    {
        FHDetailOldModel *oldDetail = self.baseViewModel.detailData;
        NSString *group_id = @"be_null";
        if (oldDetail && oldDetail.data.neighborhoodInfo.id.length > 0) {
            group_id = oldDetail.data.neighborhoodInfo.id;
        }
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"group_id"] = group_id;
        tracerDic[@"enter_type"] = @"click";
        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
        tracerDic[@"category_name"] = @"related_list";
        tracerDic[@"element_from"] = @"related";
        tracerDic[@"enter_from"] = @"old_detail";
        [tracerDic removeObjectsForKeys:@[@"page_type",@"card_type"]];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        userInfo[@"tracer"] = tracerDic;
        userInfo[@"house_type"] = @(FHHouseTypeSecondHandHouse);
        userInfo[@"title"] = oldDetail.data.recommendedHouseTitle.length > 0 ? oldDetail.data.recommendedHouseTitle : @"周边房源";
        if (oldDetail.data.neighborhoodInfo.id.length > 0) {
            userInfo[@"neighborhood_id"] = oldDetail.data.neighborhoodInfo.id;
        }
        if (self.baseViewModel.houseId.length > 0) {
            userInfo[@"house_id"] = self.baseViewModel.houseId;
        }
        userInfo[@"list_vc_type"] = @(2);
        
        TTRouteUserInfo *userInf = [[TTRouteUserInfo alloc] initWithInfo:userInfo];
        NSString * urlStr = [NSString stringWithFormat:@"snssdk1370://house_list_in_neighborhood"];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInf];
        }
    }
}

// 单个cell点击
- (void)cellDidSeleccted:(NSInteger)index {
    if (index >= 0 && index < self.items.count) {
        FHSearchHouseDataItemsModel *dataItem = self.items[index];
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"left_pic";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_from"] = @"related";
        tracerDic[@"enter_from"] = @"old_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeSecondHandHouse)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",dataItem.hid];
        if (urlStr.length > 0) {
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
        }
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= 0 && indexPath.row < self.items.count) {
        FHSearchHouseItemModel *item = self.items[indexPath.row];
        FHSingleImageInfoCellModel *cellModel = [FHSingleImageInfoCellModel houseItemByModel:item];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FHHomeSmallImageItemCell"];
        if ([cell isKindOfClass:[FHHouseBaseItemCell  class]]) {
            FHHouseBaseItemCell  *imageInfoCell = (FHHouseBaseItemCell  *)cell;
            CGFloat reasonHeight = [cellModel.secondModel showRecommendReason] ? [FHHouseBaseItemCell  recommendReasonHeight] : 0;
            [imageInfoCell refreshTopMargin:0];
            [imageInfoCell updateWithOldHouseDetailCellModel:cellModel];
        }
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    return 96;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self cellDidSeleccted:indexPath.row];
}

#pragma mark - FHDetailScrollViewDidScrollProtocol

- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
    if (vcParentView) {
        CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
        NSInteger index = (UIScreen.mainScreen.bounds.size.height - point.y - 70) / 108;
        if (index >= 0 && index < self.items.count) {
            [self addHouseShowByIndex:index];
        }
    }
}

// 添加house_show 埋点
- (void)addHouseShowByIndex:(NSInteger)index {
    if (index >= 0 && index < self.items.count) {
        NSString *tempKey = [NSString stringWithFormat:@"%ld", index];
        if ([self.houseShowCache valueForKey:tempKey]) {
            return;
        }
        [self.houseShowCache setValue:@(YES) forKey:tempKey];
        FHSearchHouseDataItemsModel *dataItem = self.items[index];
        // house_show
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"left_pic";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_type"] = @"related";
        tracerDic[@"search_id"] = dataItem.searchId.length > 0 ? dataItem.searchId : @"be_null";
        tracerDic[@"group_id"] = dataItem.groupId.length > 0 ? dataItem.groupId : (dataItem.hid ? dataItem.hid : @"be_null");
        tracerDic[@"impr_id"] = dataItem.imprId.length > 0 ? dataItem.imprId : @"be_null";
        [tracerDic removeObjectsForKeys:@[@"element_from"]];
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}

@end


// FHDetailRelatedHouseModel
@implementation FHDetailRelatedHouseModel


@end