//
//  FHNewHouseDetailRelatedCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/9.
//

#import "FHNewHouseDetailRelatedCollectionCell.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "FHDetailRelatedCourtModel.h"
#import <FHHouseBase/FHHouseListBaseItemCell.h>

@interface FHNewHouseDetailRelatedCollectionCell()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, weak)   UITableView       *tableView;

@property (nonatomic, strong , nullable) NSArray<FHHouseListBaseItemModel *> *items;

@end

@implementation FHNewHouseDetailRelatedCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailTRelatedCollectionCellModel class]]) {
        CGFloat height = 16;
        FHNewHouseDetailTRelatedCollectionCellModel *model = (FHNewHouseDetailTRelatedCollectionCellModel *)data;
        height += 104 * model.relatedModel.items.count;
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
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
        make.top.mas_equalTo(self.containerView).offset(6);
        make.height.mas_equalTo(0);
        make.left.right.mas_equalTo(self.containerView);
        make.bottom.mas_equalTo(self.containerView).offset(-10);
    }];
    self.tableView = tv;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailTRelatedCollectionCellModel class]]) {
        return;
    }
    self.currentData = data;
    // 添加tableView和查看更多
    FHNewHouseDetailTRelatedCollectionCellModel *model = (FHNewHouseDetailTRelatedCollectionCellModel *)data;
    CGFloat cellHeight = 104;
    self.items = model.relatedModel.items;
    if (model.relatedModel.items.count > 0) {

        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(cellHeight * model.relatedModel.items.count);
            }];
        [self.tableView reloadData];
    }
    [self layoutIfNeeded];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"related";// 周边房源
}

// 单个cell点击
- (void)cellDidSeleccted:(NSInteger)index {
    if (index >= 0 && index < self.items.count) {
        FHHouseListBaseItemModel *dataItem = self.items[index];
        if (self.clickCell) {
            self.clickCell(dataItem, index);
        }
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FHNewHouseCell"];
    FHHouseListBaseItemModel *item = self.items[indexPath.row];
    if ([item isKindOfClass:[FHHouseListBaseItemModel class]] && [cell isKindOfClass:[FHHouseListBaseItemCell class]]) {
        FHHouseListBaseItemCell *imageInfoCell = (FHHouseListBaseItemCell *)cell;
        [imageInfoCell refreshWithData:item];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
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
        NSInteger index = (UIScreen.mainScreen.bounds.size.height - point.y - 70) / 104;
        if (index >= 0 && index < self.items.count) {
            [self addHouseShowByIndex:index];
        }
    }
}

// 添加house_show 埋点
- (void)addHouseShowByIndex:(NSInteger)index {
    if (index >= 0 && index < self.items.count) {
        FHHouseListBaseItemModel *dataItem = self.items[index];
        if (self.houseShow) {
            self.houseShow(dataItem, index);
        }
    }
}

@end

@implementation FHNewHouseDetailTRelatedCollectionCellModel

@end
