//
//  FHDetailNeighborhoodHouseCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/19.
//

#import "FHDetailNeighborhoodHouseCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"
#import "FHDetailFoldViewButton.h"
#import "UILabel+House.h"
#import "FHSingleImageInfoCell.h"
#import "FHSingleImageInfoCellModel.h"
#import "FHDetailBottomOpenAllView.h"

@interface FHDetailNeighborhoodHouseCell ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIButton       *rentBtn;
@property (nonatomic, strong)   UIButton       *ershouBtn;
@property (nonatomic, strong)   UIView       *containerView;

@property (nonatomic, strong)   UITableView       *leftTableView;
@property (nonatomic, strong)   FHDetailBottomOpenAllView       *leftOpenAllView;// 查看更多
@property (nonatomic, strong)   NSMutableDictionary       *leftHouseShowCache; // 埋点缓存

@property (nonatomic, strong)   UITableView       *rightTableView;
@property (nonatomic, strong)   FHDetailBottomOpenAllView       *rightOpenAllView;// 查看更多
@property (nonatomic, strong)   NSMutableDictionary       *rightHouseShowCache; // 埋点缓存

@property (nonatomic, assign)   CGFloat       leftContentHeight;
@property (nonatomic, assign)   CGFloat       rightContentHeight;
@property (nonatomic, strong)   NSArray       *ershouItems;
@property (nonatomic, strong)   NSArray       *rentItems;

@end

@implementation FHDetailNeighborhoodHouseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNeighborhoodHouseModel class]]) {
        return;
    }
    self.currentData = data;
    [self removeSubViews];
    // 添加header btn
    [self addRightButtons];
    // 添加tableView
    FHDetailNeighborhoodHouseModel *model = (FHDetailNeighborhoodHouseModel *)data;
    CGFloat leftBottomOffset = 0;
    CGFloat rightBottomOffset = 0;
    CGFloat cellHeight = 108;
    if (model.sameNeighborhoodErshouHouseData.items.count > 0) {
        // 二手房
        BOOL hasMore = model.sameNeighborhoodErshouHouseData.hasMore;
        self.ershouItems = model.sameNeighborhoodErshouHouseData.items;
        if (hasMore) {
            leftBottomOffset = 48;
        }
        self.leftContentHeight = 20 + self.ershouItems.count * cellHeight + leftBottomOffset;
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, cellHeight * self.ershouItems.count) style:UITableViewStylePlain];
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
        self.leftTableView = tv;
        self.leftTableView.delegate = self;
        self.leftTableView.dataSource = self;
        if (hasMore) {
            // 添加查看更多
            self.leftOpenAllView = [[FHDetailBottomOpenAllView alloc] init];
            [self.containerView addSubview:self.leftOpenAllView];
            // 查看更多按钮点击
            __weak typeof(self) wSelf = self;
            self.leftOpenAllView.didClickCellBlk = ^{
                [wSelf loadMoreDataButtonClick];
            };
            // 查看更多相对tableView布局
            [self.leftOpenAllView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.leftTableView.mas_bottom);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(48);
                make.bottom.mas_equalTo(self.containerView);
            }];
        }
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.leftContentHeight);
        }];
        [self.leftTableView reloadData];
    }
    
    if (model.sameNeighborhoodRentHouseData.items.count > 0) {
        // 租房
        BOOL hasMore  = model.sameNeighborhoodRentHouseData.hasMore;
        self.rentItems = model.sameNeighborhoodRentHouseData.items;
        if (hasMore) {
            rightBottomOffset = 48;
        }
        self.rightContentHeight = 20 + self.rentItems.count * cellHeight  + rightBottomOffset;
        
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, cellHeight * self.rentItems.count) style:UITableViewStylePlain];
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
        self.rightTableView = tv;
        self.rightTableView.delegate = self;
        self.rightTableView.dataSource = self;
        if (hasMore) {
            // 添加查看更多
            self.rightOpenAllView = [[FHDetailBottomOpenAllView alloc] init];
            [self.containerView addSubview:self.rightOpenAllView];
            // 查看更多按钮点击
            __weak typeof(self) wSelf = self;
            self.rightOpenAllView.didClickCellBlk = ^{
                [wSelf loadMoreDataButtonClick_rent];
            };
            // 查看更多相对tableView布局
            [self.rightOpenAllView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.leftTableView.mas_bottom);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(48);
                make.bottom.mas_equalTo(self.containerView);
            }];
        }
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.rightContentHeight);
        }];
        self.rightTableView.hidden = YES;
        self.rightOpenAllView.hidden = YES;
        [self.rightTableView reloadData];
    }
    
    if (model.currentSelIndex == 0) {
        self.ershouBtn.selected = YES;
        self.rentBtn.selected = NO;
    } else {
        self.ershouBtn.selected = NO;
        self.rentBtn.selected = YES;
    }
    [self reloadDataByIndex:model.currentSelIndex];
    [self layoutIfNeeded];
}

- (void)reloadDataByIndex:(NSInteger)index {
    if (index != 0 && index != 1) {
        return;
    }
    FHDetailNeighborhoodHouseModel *model = (FHDetailNeighborhoodHouseModel *)self.currentData;
    BOOL hasMore = NO;
    NSString * total = @"";
    
    [model.tableView beginUpdates];
    if (index == 0) {
        hasMore = model.sameNeighborhoodErshouHouseData.hasMore;
        total = model.sameNeighborhoodErshouHouseData.total;
        self.leftTableView.hidden = NO;
        self.leftOpenAllView.hidden = NO;
        self.rightTableView.hidden = YES;
        self.rightOpenAllView.hidden = YES;
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.leftContentHeight);
        }];
    } else {
        hasMore = model.sameNeighborhoodRentHouseData.hasMore;
        total = model.sameNeighborhoodRentHouseData.total;
        self.leftTableView.hidden = YES;
        self.leftOpenAllView.hidden = YES;
        self.rightTableView.hidden = NO;
        self.rightOpenAllView.hidden = NO;
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.rightContentHeight);
        }];
    }
    [self setNeedsUpdateConstraints];
    [model.tableView endUpdates];
    // 更新标题
    if (total.length > 0) {
        self.headerView.label.text = [NSString stringWithFormat:@"小区房源(%@)",total];
    } else {
        self.headerView.label.text = @"小区房源";
    }
}

- (void)removeSubViews {
    if (self.ershouBtn) {
        [self.ershouBtn removeFromSuperview];
        self.ershouBtn = nil;
    }
    if (self.rentBtn) {
        [self.rentBtn removeFromSuperview];
        self.rentBtn = nil;
    }
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
}

- (void)buttonClick:(UIButton *)btn {
    NSInteger tag = btn.tag;
    FHDetailNeighborhoodHouseModel *model = (FHDetailNeighborhoodHouseModel *)self.currentData;
    if (model.currentSelIndex == tag) {
        // 相同按钮点击
        return;
    }
    model.currentSelIndex = tag;
    if (tag == 0) {
        self.ershouBtn.selected = YES;
        self.rentBtn.selected = NO;
    } else {
        self.ershouBtn.selected = NO;
        self.rentBtn.selected = YES;
    }
    [self reloadDataByIndex:tag];
}

- (void)addRightButtons {
    FHDetailNeighborhoodHouseModel *model = (FHDetailNeighborhoodHouseModel *)self.currentData;
    // 添加租房
    BOOL hasRentData = NO;
    if (model.sameNeighborhoodRentHouseData.items.count > 0) {
        _rentBtn = [[UIButton alloc] init];
        [_rentBtn setTitle:@"租房" forState:UIControlStateNormal];
        [_rentBtn setTitle:@"租房" forState:UIControlStateHighlighted];
        _rentBtn.titleLabel.font = [UIFont themeFontRegular:14];
        [_rentBtn setTitleColor:[UIColor colorWithHexString:@"#8a9299"] forState:UIControlStateNormal];
        [_rentBtn setTitleColor:[UIColor colorWithHexString:@"#299cff"] forState:UIControlStateSelected];
        [self.headerView addSubview:_rentBtn];
        [_rentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headerView).offset(23);
            make.right.mas_equalTo(-20);
            make.height.mas_equalTo(20);
        }];
        _rentBtn.tag = 1;
        [_rentBtn addTarget:self  action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        hasRentData = YES;
    }
    // 添加二手房
    if (model.sameNeighborhoodErshouHouseData.items.count > 0) {
        _ershouBtn = [[UIButton alloc] init];
        [_ershouBtn setTitle:@"二手房" forState:UIControlStateNormal];
        [_ershouBtn setTitle:@"二手房" forState:UIControlStateHighlighted];
        _ershouBtn.titleLabel.font = [UIFont themeFontRegular:14];
        [_ershouBtn setTitleColor:[UIColor colorWithHexString:@"#8a9299"] forState:UIControlStateNormal];
        [_ershouBtn setTitleColor:[UIColor colorWithHexString:@"#299cff"] forState:UIControlStateSelected];
        [self.headerView addSubview:_ershouBtn];
        [_ershouBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headerView).offset(23);
            if(hasRentData) {
                make.right.mas_equalTo(self.rentBtn.mas_left).offset(-20);
            } else {
                make.right.mas_equalTo(-20);
            }
            make.height.mas_equalTo(20);
        }];
        _ershouBtn.tag = 0;
        [_ershouBtn addTarget:self  action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        model.currentSelIndex = 0;
    } else {
        // 默认选中
        model.currentSelIndex = 1;
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

- (void)setupUI {
    _leftHouseShowCache = [NSMutableDictionary new];
    _rightHouseShowCache = [NSMutableDictionary new];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"小区房源";
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
        make.top.mas_equalTo(46);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

// 查看更多按钮点击(二手房)
- (void)loadMoreDataButtonClick {
    
}
// 租房
- (void)loadMoreDataButtonClick_rent {
    
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   if (self.leftTableView == tableView) {
        return self.ershouItems.count;
    }
    if (self.rightTableView == tableView) {
        return self.rentItems.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.leftTableView == tableView) {
        if (indexPath.row >= 0 && indexPath.row < self.ershouItems.count) {
            FHSearchHouseDataItemsModel *item = self.ershouItems[indexPath.row];
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
    }
    if (self.rightTableView == tableView) {
        if (indexPath.row >= 0 && indexPath.row < self.rentItems.count) {
            FHSearchHouseDataItemsModel *item = self.rentItems[indexPath.row];
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
//        if (index >= 0 && index < self.items.count) {
//            [self addHouseShowByIndex:index];
//        }
    }
}

// 添加house_show 埋点：这种方式效率不高，后续可以考虑优化
- (void)addHouseShowByIndex:(NSInteger)index {
//    if (index >= 0 && index < self.items.count) {
//        NSString *tempKey = [NSString stringWithFormat:@"%ld", index];
//        if ([self.leftHouseShowCache valueForKey:tempKey]) {
//            return;
//        }
//        [self.leftHouseShowCache setValue:@(YES) forKey:tempKey];
//        // 添加house_show埋点 add by zyk
//        NSLog(@"------添加house_show 埋点: %ld",index);
//    }
}

@end


@implementation FHDetailNeighborhoodHouseModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentSelIndex = 0;
    }
    return self;
}

@end
