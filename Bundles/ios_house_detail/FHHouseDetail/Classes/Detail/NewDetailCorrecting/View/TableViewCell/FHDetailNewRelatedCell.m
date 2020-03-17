//
//  FHDetailNewRelatedCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/16.
//

#import "FHDetailNewRelatedCell.h"
#import "FHDetailHeaderView.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "FHDetailRelatedCourtModel.h"
#import <FHHouseBase/FHHouseListBaseItemCell.h>

@class FHSearchHouseDataItemsModel;

@interface FHDetailNewRelatedCell ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   UITableView       *tableView;
@property (nonatomic, strong)   NSMutableDictionary       *houseShowCache; // 埋点缓存

@property (nonatomic, strong , nullable) NSArray<FHHouseListBaseItemModel *> *items;

@end

@implementation FHDetailNewRelatedCell

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewRelatedCellModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    // 添加tableView和查看更多
    FHDetailNewRelatedCellModel *model = (FHDetailNewRelatedCellModel *)data;
    
    adjustImageScopeType(model)
    
    CGFloat cellHeight = 104;
    BOOL hasMore = NO;
    CGFloat bottomOffset = 10;
    if (hasMore) {
        bottomOffset = 68;
    }
    self.items = model.relatedHouseData.items;
    if (model.relatedHouseData.items.count > 0) {
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tv.estimatedRowHeight = 104;
        tv.estimatedSectionHeaderHeight = 0;
        tv.estimatedSectionFooterHeight = 0;
        tv.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            tv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        tv.separatorStyle = UITableViewCellSeparatorStyleNone;
        tv.showsVerticalScrollIndicator = NO;
        tv.scrollEnabled = NO;
        [tv registerClass:[FHHouseListBaseItemCell class] forCellReuseIdentifier:@"FHNewHouseCell"];
        [self.containerView addSubview:tv];
        [tv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView).offset(10);
            make.height.mas_equalTo(cellHeight * model.relatedHouseData.items.count);
            make.left.right.mas_equalTo(self.containerView);
            make.bottom.mas_equalTo(self.containerView).offset(-bottomOffset);
        }];
        self.tableView = tv;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView reloadData];
    }

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
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).mas_offset(30);
        make.left.mas_equalTo(self.shadowImage).mas_offset(15);
        make.right.mas_equalTo(self.shadowImage).mas_offset(-15);
        make.bottom.mas_equalTo(self.shadowImage).mas_offset(-30);
    }];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"related";// 周边房源
}

// 单个cell点击
- (void)cellDidSeleccted:(NSInteger)index {
    if (index >= 0 && index < self.items.count) {
        FHHouseListBaseItemModel *dataItem = self.items[index];
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"rank"] = @(index);
        tracerDic[@"card_type"] = @"left_pic";
        tracerDic[@"log_pb"] = dataItem.logPb ? dataItem.logPb : @"be_null";
        tracerDic[@"house_type"] = [[FHHouseTypeManager sharedInstance] traceValueForType:self.baseViewModel.houseType];
        tracerDic[@"element_from"] = @"related";
        tracerDic[@"enter_from"] = @"old_detail";
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":tracerDic,@"house_type":@(FHHouseTypeSecondHandHouse)}];
        NSString * urlStr = [NSString stringWithFormat:@"sslocal://old_house_detail?house_id=%@",dataItem.houseid];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FHNewHouseCell"];
    FHHouseListBaseItemModel *item = self.items[indexPath.row];
    if ([item isKindOfClass:[FHHouseListBaseItemModel class]] && [cell isKindOfClass:[FHHouseListBaseItemCell class]]) {
        FHHouseListBaseItemCell *imageInfoCell = (FHHouseListBaseItemCell *)cell;
        [imageInfoCell refreshWithData:item];
    }
    return cell;
   
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
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
        // todo zjing test
//        tracerDic[@"group_id"] = dataItem.groupId.length > 0 ? dataItem.groupId : (dataItem.hid ? dataItem.hid : @"be_null");
        tracerDic[@"impr_id"] = dataItem.imprId.length > 0 ? dataItem.imprId : @"be_null";
        [tracerDic removeObjectsForKeys:@[@"element_from"]];
        [FHUserTracker writeEvent:@"house_show" params:tracerDic];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation FHDetailNewRelatedCellModel


@end
