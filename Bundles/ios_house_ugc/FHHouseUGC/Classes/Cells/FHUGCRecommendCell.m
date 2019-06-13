//
//  FHUGCRecommendCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import "FHUGCRecommendCell.h"
#import "FHUGCCellHeaderView.h"
#import "FHUGCRecommendSubCell.h"

#define leftMargin 20
#define rightMargin 20
#define cellId @"cellId"

@interface FHUGCRecommendCell ()<UITableViewDelegate,UITableViewDataSource,FHUGCRecommendSubCellDelegate>

@property(nonatomic ,strong) FHUGCCellHeaderView *headerView;
@property(nonatomic ,strong) UITableView *tableView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) NSMutableArray *sourceList;
@property(nonatomic ,strong) NSMutableArray *dataList;
@property(nonatomic ,assign) NSInteger currentIndex;
@property(nonatomic ,strong) FHFeedUGCCellModel *model;
@property(nonatomic ,assign) CGFloat tableViewHeight;

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
    _headerView.titleLabel.text = @"你可能感兴趣的小区";
    _headerView.bottomLine.hidden = NO;
    _headerView.refreshBtn.hidden = NO;
    [_headerView.refreshBtn addTarget:self action:@selector(changeData) forControlEvents:UIControlEventTouchUpInside];
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
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 85;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.contentView addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[FHUGCRecommendSubCell class] forCellReuseIdentifier:cellId];
}

- (void)initConstraints {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(40);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(5);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.tableViewHeight);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView.mas_bottom).offset(15);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(5);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        _model = (FHFeedUGCCellModel *)data;
        self.sourceList = _model.interestNeighbourhoodList;
        [self refreshData];
    }
}

- (void)refreshData {
    [self generateDataList:self.sourceList];
    [self.tableView reloadData];
    //更新高度
    [self updateCellConstraints];
}

- (void)updateCellConstraints {
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
        [_model.tableView beginUpdates];
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headerView.mas_bottom).offset(5);
            make.left.right.mas_equalTo(self.contentView);
            make.height.mas_equalTo(self.tableViewHeight);
        }];
        [self setNeedsUpdateConstraints];
        [_model.tableView endUpdates];
    }
}

- (void)generateDataList:(NSMutableArray *)sourceList {
    [self.dataList removeAllObjects];
    if(sourceList.count <= 3){
        [self.dataList addObjectsFromArray:self.sourceList];
    }else{
        NSInteger index = self.currentIndex;
        for (NSInteger i = index; i < index + 3; i++) {
            NSInteger k = 0;
            if(i < self.sourceList.count){
                k = i;
            }else{
                k = i - self.sourceList.count;
            }
            [self.dataList addObject:self.sourceList[k]];
        }
    }
}

- (void)changeData {
    self.currentIndex = self.currentIndex + 3;
    
    if(self.currentIndex >= self.sourceList.count){
        self.currentIndex = self.currentIndex - self.sourceList.count;
    }
    
    [self refreshData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *str = self.dataList[indexPath.row];
    FHUGCRecommendSubCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[FHUGCRecommendSubCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.delegate = self;
    
    if(indexPath.row < self.dataList.count){
        [cell refreshWithData:str];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

#pragma mark - FHUGCRecommendSubCellDelegate

- (void)joinIn:(id)model {
    //调用加入的接口
    
    //加入成功后
    if(_sourceList.count > 3){
        NSInteger current = [_sourceList indexOfObject:model];
        NSInteger next = self.currentIndex + 3;
        if(next >= _sourceList.count){
            next = next - self.sourceList.count;
        }
        
        if(next < self.currentIndex) {
            self.currentIndex = self.currentIndex - 1;
        }
        
        [_sourceList replaceObjectAtIndex:current withObject:_sourceList[next]];
        [_sourceList removeObjectAtIndex:next];
    }else{
        [_sourceList removeObject:model];
    }
    
    [self refreshData];
}

@end
