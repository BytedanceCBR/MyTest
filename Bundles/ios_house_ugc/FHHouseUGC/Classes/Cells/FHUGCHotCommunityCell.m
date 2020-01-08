//
//  FHUGCHotCommunityCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/8.
//

#import "FHUGCHotCommunityCell.h"
#import "FHUGCCellHeaderView.h"
#import "FHBaseCollectionView.h"
#import "FHUGCHotTopicSubCell.h"
#import <TTRoute.h>
#import "FHUserTracker.h"
#import "FHUGCHotCommunityLayout.h"

#define leftMargin 20
#define rightMargin 20
#define cellId @"cellId"

#define headerViewHeight 40
#define bottomSepViewHeight 5

@interface FHUGCHotCommunityCell()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic ,strong) FHUGCCellHeaderView *headerView;
@property(nonatomic ,strong) FHBaseCollectionView *collectionView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) NSMutableArray *dataList;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;

@end

@implementation FHUGCHotCommunityCell

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
    _headerView.titleLabel.text = @"热门话题";
    _headerView.bottomLine.hidden = YES;
    _headerView.refreshBtn.hidden = YES;
    [_headerView.moreBtn addTarget:self action:@selector(moreData) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headerView];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
    
    [self initCollectionView];
}

- (void)initCollectionView {
    FHUGCHotCommunityLayout *flowLayout = [[FHUGCHotCommunityLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    flowLayout.minimumLineSpacing = 8;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self.contentView addSubview:_collectionView];
    
    [_collectionView registerClass:[FHUGCHotTopicSubCell class] forCellWithReuseIdentifier:cellId];
}

- (void)initConstraints {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(5);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(headerViewHeight);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(4);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(180);
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
    [self.clientShowDict removeAllObjects];
    self.currentData = data;
    
//    FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)data;
//    self.dataList = model.hotTopicList;
    [_dataList removeAllObjects];
    for (NSInteger i = 0; i < 10; i++) {
        [_dataList addObject:@(i)];
    }
    
    [self.collectionView reloadData];
}

+ (CGFloat)heightForData:(id)data {
    return 320;
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
        NSMutableDictionary *param = [NSMutableDictionary new];
        param[@"element_type"] = @"hot_topic";
        param[@"page_type"] = @"nearby_list";
        param[@"enter_from"] = @"neighborhood_tab";
        param[@"rank"] = model.tracerDic[@"rank"];
        TRACK_EVENT(@"click_more", param);
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
//        [self traceClientShowAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCBaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
//    if(indexPath.row < self.dataList.count){
//        FHFeedContentRawDataHotTopicListModel *model = self.dataList[indexPath.row];
//        NSMutableDictionary *dict = @{}.mutableCopy;
//        // 埋点
//        NSMutableDictionary *traceParam = @{}.mutableCopy;
//        traceParam[@"enter_from"] = @"nearby_list";
//        traceParam[@"element_from"] = @"hot_topic";
//        traceParam[@"enter_type"] = @"click";
//        traceParam[@"rank"] = @(indexPath.row);
//        traceParam[@"log_pb"] = model.logPb;
//        dict[@"tracer"] = traceParam;
//
//        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
//        //跳转到话题详情页
//        if(model.schema.length > 0){
//            NSURL *openUrl = [NSURL URLWithString:model.schema];
//            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
//        }
//    }
}

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHFeedContentRawDataHotTopicListModel *model = self.dataList[indexPath.row];
    
    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
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
    
    tracerDict[@"element_from"] = @"hot_topic";
    tracerDict[@"page_type"] = @"nearby_list";
    tracerDict[@"enter_from"] = @"neighborhood_tab";
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"concern_id"] = model.forumId;
    tracerDict[@"log_pb"] = model.logPb;
    
    TRACK_EVENT(@"topic_show", tracerDict);
}

@end
