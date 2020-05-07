//
//  FHUGCHotTopicCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/8/25.
//

#import "FHUGCHotTopicCell.h"
#import "FHUGCCellHeaderView.h"
#import "FHBaseCollectionView.h"
#import "FHUGCHotTopicSubCell.h"
#import "TTRoute.h"
#import "FHUserTracker.h"

#define leftMargin 20
#define rightMargin 20
#define cellId @"cellId"

#define headerViewHeight 44
#define bottomSepViewHeight 5

@interface FHUGCHotTopicCell()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic ,strong) FHUGCCellHeaderView *headerView;
@property(nonatomic ,strong) FHBaseCollectionView *collectionView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) NSMutableArray *sourceList;
@property(nonatomic ,strong) NSArray *dataList;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic ,strong) UIView *seprateLine;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHUGCHotTopicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _dataList = [NSMutableArray array];
        _sourceList = [NSMutableArray array];
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
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.headerView = [[FHUGCCellHeaderView alloc] initWithFrame:CGRectZero];
    _headerView.titleLabel.text = @"话题榜";
    _headerView.bottomLine.hidden = YES;
    _headerView.refreshBtn.hidden = YES;
    [_headerView.moreBtn setTitle:@"查看全部" forState:UIControlStateNormal];
    [_headerView setMoreBtnLayout];
    [_headerView.moreBtn addTarget:self action:@selector(moreData) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headerView];
    
    self.seprateLine = [[UIView alloc] init];
    _seprateLine.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_seprateLine];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
    
    [self initCollectionView];
}

- (void)initCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 4, 0, 4);
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
//    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self.contentView addSubview:_collectionView];
    
    [_collectionView registerClass:[FHUGCHotTopicSubCell class] forCellWithReuseIdentifier:cellId];
}

- (void)initConstraints {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(headerViewHeight);
    }];
    
    [self.headerView.moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(65);
    }];
    
    [self.seprateLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.headerView);
        make.height.mas_equalTo(1);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.seprateLine.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.bottomSepView.mas_top).offset(-3);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
    
    if(self.currentData == data && !cellModel.ischanged){
        return;
    }
    
    [self.clientShowDict removeAllObjects];
    self.currentData = data;
    
    self.cellModel = cellModel;
    self.dataList = cellModel.hotTopicList;
    [self.collectionView reloadData];
}

+ (CGFloat)heightForData:(id)data {
    CGFloat height = headerViewHeight + 1 + 10 + bottomSepViewHeight + 3;
    if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
        FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)data;
        NSArray *dataList = model.hotTopicList;
        NSInteger row = ceil(model.hotTopicList.count / 2.0);
        height += (46 * row);
    }
    return height;
}

- (void)moreData {
    // 点击埋点
    [self trackClickMore];

    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[UT_ENTER_TYPE] = @"click";
    traceParam[UT_ELEMENT_FROM] = @"hot_topic";
    traceParam[UT_ENTER_FROM] = @"nearby_list";
    dict[@"tracer"] = traceParam;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_post_topic_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)trackClickMore {
    if([self.currentData isKindOfClass:[FHFeedUGCCellModel class]]) {
        FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)self.currentData;
        NSMutableDictionary *tracerDict = [NSMutableDictionary new];
        tracerDict[@"element_type"] = @"hot_topic";
        tracerDict[@"page_type"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
        tracerDict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
        tracerDict[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"] ?: @"be_null";
        TRACK_EVENT(@"click_more", tracerDict);
    }
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row < self.dataList.count){
        [self traceClientShowAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCHotTopicSubCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row] index:indexPath.row];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)self.currentData;
    if(indexPath.row < self.dataList.count){
        FHFeedContentRawDataHotTopicListModel *model = self.dataList[indexPath.row];
        NSMutableDictionary *dict = @{}.mutableCopy;
        // 埋点
        NSMutableDictionary *traceParam = @{}.mutableCopy;
        traceParam[@"enter_type"] = @"click";
        traceParam[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
        traceParam[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"] ?: @"be_null";
        traceParam[@"element_from"] = @"hot_topic";
        traceParam[@"enter_type"] = @"click";
        traceParam[@"rank"] = @(indexPath.row);
        traceParam[@"log_pb"] = model.logPb;
        dict[@"tracer"] = traceParam;
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        //跳转到话题详情页
        if(model.schema.length > 0){
            NSURL *openUrl = [NSURL URLWithString:model.schema];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width/2 - 4 , 46);
}

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }

    FHFeedContentRawDataHotTopicListModel *model = self.dataList[indexPath.row];

    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *forumId = model.forumId;
    if(forumId){
        if (self.clientShowDict[forumId]) {
            return;
        }

        self.clientShowDict[forumId] = @(indexPath.row);
        [self trackClientShow:model rank:indexPath.row];
    }
}

- (void)trackClientShow:(FHFeedContentRawDataHotTopicListModel *)model rank:(NSInteger)rank {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];

    tracerDict[@"element_type"] = @"hot_topic";
    tracerDict[@"page_type"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
    tracerDict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"] ?: @"be_null";
    tracerDict[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"] ?: @"be_null";
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"concern_id"] = model.forumId;
    tracerDict[@"log_pb"] = model.logPb;
    
    TRACK_EVENT(@"topic_show", tracerDict);
}

@end
