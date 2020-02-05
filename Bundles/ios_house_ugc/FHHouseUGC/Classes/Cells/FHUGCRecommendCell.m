//
//  FHUGCRecommendCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHUGCRecommendCell.h"
#import "FHUGCCellHeaderView.h"
#import "FHUGCRecommendSubCell.h"
#import <TTRoute.h>
#import "FHUserTracker.h"
#import "FHCommunityList.h"

#define leftMargin 20
#define rightMargin 20
#define cellId @"cellId"

#define headerViewHeight 40
#define bottomSepViewHeight 5

@interface FHUGCRecommendCell ()<UITableViewDelegate,UITableViewDataSource,FHUGCRecommendSubCellDelegate>

@property(nonatomic ,strong) FHUGCCellHeaderView *headerView;
@property(nonatomic ,strong) UITableView *tableView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) NSMutableArray *sourceList;
@property(nonatomic ,strong) NSMutableArray *dataList;
@property(nonatomic ,assign) NSInteger currentIndex;
@property(nonatomic ,strong) FHFeedUGCCellModel *model;
@property(nonatomic ,assign) CGFloat tableViewHeight;
@property(nonatomic ,assign) BOOL isReplace;
@property(nonatomic ,strong) FHUGCRecommendSubCell *joinedCell;
@property(nonatomic ,assign) NSInteger joinedCellRow;

@property(nonatomic, strong) NSMutableDictionary *clientShowDict;

@end

@implementation FHUGCRecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _dataList = [NSMutableArray array];
        _sourceList = [NSMutableArray array];
        _tableViewHeight = 180.0f;
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.headerView = [[FHUGCCellHeaderView alloc] initWithFrame:CGRectZero];
    _headerView.titleLabel.text = @"猜你喜欢";
    _headerView.bottomLine.hidden = NO;
    [_headerView.refreshBtn addTarget:self action:@selector(changeData) forControlEvents:UIControlEventTouchUpInside];
    [_headerView.moreBtn addTarget:self action:@selector(moreData) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headerView];

    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
    
    [self initTableView];
}

- (void)initTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 60;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.insetsContentViewsToSafeArea = NO;
    }
    
    [self.contentView addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[FHUGCRecommendSubCell class] forCellReuseIdentifier:cellId];
}

- (void)initConstraints {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(headerViewHeight);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(5);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.tableViewHeight);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView.mas_bottom).offset(15);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(bottomSepViewHeight);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    self.isReplace = NO;
    self.currentIndex = 0;
    _model = (FHFeedUGCCellModel *)data;
    self.sourceList = [_model.recommendSocialGroupList mutableCopy];
    [self refreshData:YES];
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = headerViewHeight + bottomSepViewHeight + 20;
        
        if(cellModel.recommendSocialGroupList.count > 0){
            CGFloat tableViewHeight = cellModel.recommendSocialGroupList.count < 3 ? 60 * cellModel.recommendSocialGroupList.count : 180;
            height += tableViewHeight;
        }
        
        return height;
    }
    return 245;
}

- (void)refreshData:(BOOL)isFirst {
    [self generateDataList:self.sourceList];
    //刷新列表
    [self reloadNewData];
    //更新高度
    [self updateCellConstraints:isFirst];
    //刷新换一换按钮的状态
    self.headerView.refreshBtn.hidden = !(self.sourceList.count > 3);
}

- (void)reloadNewData {
    if(self.isReplace){
        if(_joinedCellRow >= 0){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_joinedCellRow inSection:0];
            _joinedCell.hidden = YES;
            
            [_model.tableView beginUpdates];
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            _joinedCell.hidden = NO;
            //如果不重置，在某些特殊情况下新出的cell并没有被系统还原正确大小
            dispatch_async(dispatch_get_main_queue(), ^{
                _joinedCell.transform = CGAffineTransformIdentity;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.tableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        obj.transform = CGAffineTransformIdentity;
                    }];
                });
            });
            
            [_model.tableView endUpdates];
        }
    }else{
        [self.tableView reloadData];
    }
}

- (void)updateCellConstraints:(BOOL)isFirst {
    CGFloat height = 0;
    if(self.dataList.count < 3){
        height = 60 * self.dataList.count;
    }else{
        height = 180;
    }
    
    //没有变化不做处理
    if(height == self.tableViewHeight){
        return;
    }
    
    self.tableViewHeight = height;
    
    if(height == 0){
        if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
            [self.delegate deleteCell:self.model];
        }
    }else{
        if(isFirst){
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.tableViewHeight);
            }];
        }else{
            [_model.tableView beginUpdates];
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.tableViewHeight);
            }];
            [self setNeedsUpdateConstraints];
            [_model.tableView endUpdates];
        }
    }
}

- (void)generateDataList:(NSMutableArray *)sourceList {
    [self.dataList removeAllObjects];
    NSInteger count = sourceList.count < 3 ? sourceList.count : 3;
    NSInteger index = self.currentIndex;
    for (NSInteger i = index; i < index + count; i++) {
        NSInteger k = 0;
        if(i < self.sourceList.count){
            k = i;
        }else{
            k = i - self.sourceList.count;
        }
        if(k < self.sourceList.count){
            [self.dataList addObject:self.sourceList[k]];
        }
    }
}

- (void)changeData {
    [self traceChangeData];
    
    if(self.sourceList.count > 3){
        self.currentIndex = self.currentIndex + 3;

        if(self.currentIndex >= self.sourceList.count){
            self.currentIndex = self.currentIndex - self.sourceList.count;
        }
        
        self.isReplace = NO;
        
        [self refreshData:NO];
    }
}

- (void)traceChangeData {
    NSMutableDictionary *dict = [self tracerDic];
    dict[@"click_position"] = @"change_list";
    TRACK_EVENT(@"click_change", dict);
}

- (NSMutableDictionary *)tracerDic {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"card_type"] = @"left_pic";
    dict[@"house_type"] = @"community";
    dict[@"element_from"] = @"like_neighborhood";
    dict[@"page_type"] = @"nearby_list";
    dict[@"enter_from"] = @"neighborhood_tab";
    return dict;
}

- (void)moreData {
    [self trackClickMore];
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"action_type"] = @(FHCommunityListTypeFollow);
    dict[@"select_district_tab"] = @(FHUGCCommunityDistrictTabIdRecommend);
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[@"enter_type"] = @"click";
    traceParam[@"enter_from"] = @"nearby_list";
    traceParam[@"element_from"] = @"like_neighborhood";
    dict[@"tracer"] = traceParam;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)traceGroupAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHFeedContentRecommendSocialGroupListModel *model = self.dataList[indexPath.row];
    
    if (!_clientShowDict) {
        _clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *socialGroupId = model.socialGroupId;
    if(socialGroupId){
        if (_clientShowDict[socialGroupId]) {
            return;
        }
        
        _clientShowDict[socialGroupId] = @(indexPath.row);
        [self trackGroupShow:model rank:indexPath.row];
    }
}

- (void)trackGroupShow:(FHFeedContentRecommendSocialGroupListModel *)model rank:(NSInteger)rank {
    NSMutableDictionary *dict = [self tracerDic];
    dict[@"log_pb"] = model.logPb;
    dict[@"rank"] = @(rank);
    TRACK_EVENT(@"community_group_show", dict);
}

- (void)trackClickMore {
    NSMutableDictionary *dict = [self tracerDic];
    dict[@"element_type"] = @"like_neighborhood";
    [dict removeObjectsForKeys:@[@"card_type"]];
    TRACK_EVENT(@"click_more", dict);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCRecommendSubCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[FHUGCRecommendSubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.delegate = self;
    
    if(indexPath.row < self.dataList.count){
        FHFeedContentRecommendSocialGroupListModel *model = self.dataList[indexPath.row];
        [cell refreshWithData:model rank:indexPath.row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.isReplace){
        //缩放
        cell.layer.transform = CATransform3DMakeScale(0.2, 0.2, 1);
        [UIView animateWithDuration:0.5 animations:^{
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1);
        }];
    }
    
    if(indexPath.row < self.dataList.count){
        [self traceGroupAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        FHFeedContentRecommendSocialGroupListModel *model = self.dataList[indexPath.row];
        
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"community_id"] = model.socialGroupId;
        dict[@"tracer"] = @{@"enter_from":@"like_neighborhood",
                            @"enter_type":@"click",
                            @"rank":@(indexPath.row),
                            @"log_pb":model.logPb ?: @"be_null"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        //跳转到圈子详情页
        NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];

    }
}
    

#pragma mark - FHUGCRecommendSubCellDelegate

- (void)joinIn:(id)model cell:(nonnull FHUGCRecommendSubCell *)cell {
    //调用加入的接口
    _joinedCell = cell;
    _joinedCellRow = [self getCellIndex:model sourceList:self.dataList];
    //加入成功后
    if(_sourceList.count > 3){
        NSInteger current1 = [_sourceList indexOfObject:model];
        NSInteger current = [self getCellIndex:model sourceList:self.sourceList];
        if(current >= 0){
            NSInteger next = self.currentIndex + 3;
            if(next >= _sourceList.count){
                next = next - self.sourceList.count;
            }
            
            if(next < self.currentIndex) {
                self.currentIndex = self.currentIndex - 1;
            }
            
            [_sourceList replaceObjectAtIndex:current withObject:_sourceList[next]];
            [_sourceList removeObjectAtIndex:next];
            self.isReplace = YES;
        }
    }else{
        [_sourceList removeObject:model];
        self.isReplace = NO;
    }
    
    //重新赋值
    self.model.recommendSocialGroupList = [self.sourceList copy];
    
    [self refreshData:NO];
}

- (NSInteger)getCellIndex:(FHFeedContentRecommendSocialGroupListModel *)model sourceList:(NSArray *)souceList {
    for (NSInteger i = 0; i < souceList.count; i++) {
        FHFeedContentRecommendSocialGroupListModel *sourceModel = souceList[i];
        if([model.socialGroupId isEqualToString:sourceModel.socialGroupId]){
            return i;
        }
    }
    return -1;
}

@end
