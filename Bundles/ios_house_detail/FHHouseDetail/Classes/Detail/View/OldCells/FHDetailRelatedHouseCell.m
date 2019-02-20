//
//  FHDetailRelatedHouseCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/15.
//

#import "FHDetailRelatedHouseCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import "FHDetailHeaderView.h"
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHDetailBottomOpenAllView.h"

@interface FHDetailRelatedHouseCell ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
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
    CGFloat cellHeight = 108;
    BOOL hasMore = model.relatedHouseData.hasMore;
    CGFloat bottomOffset = 0;
    if (hasMore) {
        bottomOffset = 48;
    }
    self.items = model.relatedHouseData.items;
    if (model.relatedHouseData.items.count > 0) {
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tv.estimatedRowHeight = 108;
        tv.estimatedSectionHeaderHeight = 0;
        tv.estimatedSectionFooterHeight = 0;
        if (@available(iOS 11.0, *)) {
            tv.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        tv.separatorStyle = UITableViewCellSeparatorStyleNone;
        tv.showsVerticalScrollIndicator = NO;
        tv.scrollEnabled = NO;
        [tv registerClass:[FHSingleImageInfoCell class] forCellReuseIdentifier:@"FHSingleImageInfoCell"];
        [self.containerView addSubview:tv];
        [tv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(20);
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
                make.bottom.mas_equalTo(self.containerView);
            }];
        } else {
            // 查看更多自己布局
            [self.openAllView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.containerView).offset(20);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(48);
                make.bottom.mas_equalTo(self.containerView);
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

- (void)setupUI {
    _houseShowCache = [NSMutableDictionary new];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"周边房源";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"related";// 周边房源
}

// 查看更多按钮点击
- (void)loadMoreDataButtonClick {
    
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
        FHSearchHouseDataItemsModel *item = self.items[indexPath.row];
        FHSingleImageInfoCellModel *cellModel = [FHSingleImageInfoCellModel houseItemByModel:item];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FHSingleImageInfoCell"];
        if ([cell isKindOfClass:[FHSingleImageInfoCell class]]) {
            FHSingleImageInfoCell *imageInfoCell = (FHSingleImageInfoCell *)cell;
            [imageInfoCell updateWithHouseCellModel:cellModel];
            [imageInfoCell refreshTopMargin:0];
            [imageInfoCell refreshBottomMargin:20];
        }
        return cell;
    }
    
    return [[UITableViewCell alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
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

// 添加house_show 埋点：这种方式效率不高，后续可以考虑优化
- (void)addHouseShowByIndex:(NSInteger)index {
    if (index >= 0 && index < self.items.count) {
        NSString *tempKey = [NSString stringWithFormat:@"%ld", index];
        if ([self.houseShowCache valueForKey:tempKey]) {
            return;
        }
        [self.houseShowCache setValue:@(YES) forKey:tempKey];
        // 添加house_show埋点 add by zyk
        NSLog(@"------添加house_show 埋点: %ld",index);
    }
}

@end


// FHDetailRelatedHouseModel
@implementation FHDetailRelatedHouseModel


@end
