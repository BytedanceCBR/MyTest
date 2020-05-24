//
//  FHUGCHotCommunityCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/1/8.
//

#import "FHUGCHotCommunityCell.h"
#import "FHBaseCollectionView.h"
#import "FHUGCHotCommunitySubCell.h"
#import "TTRoute.h"
#import "FHUserTracker.h"
#import "FHUGCHotCommunityLayout.h"
#import "FHCommunityList.h"
#import "UIViewAdditions.h"

#define leftMargin 20
#define rightMargin 20
#define cellId @"cellId"

#define headerViewHeight 40
#define bottomSepViewHeight 5

@interface FHUGCHotCommunityCell()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic ,strong) FHBaseCollectionView *collectionView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) NSMutableArray *dataList;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property(nonatomic, strong) FHUGCHotCommunityLayout *flowLayout;
@property(nonatomic, strong) FHFeedUGCCellModel *cellModel;

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
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
    
    [self initCollectionView];
}

- (void)initCollectionView {
    self.flowLayout = [[FHUGCHotCommunityLayout alloc] init];
    _flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    _flowLayout.minimumLineSpacing = 8;
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self.contentView addSubview:_collectionView];
    
    [_collectionView registerClass:[FHUGCHotCommunitySubCell class] forCellWithReuseIdentifier:cellId];
}

- (void)initConstraints {
    self.collectionView.top = 15;
    self.collectionView.left = 0;
    self.collectionView.width = [UIScreen mainScreen].bounds.size.width;
    self.collectionView.height = 188;
    
    self.bottomSepView.top = 223 - bottomSepViewHeight;
    self.bottomSepView.left = 0;
    self.bottomSepView.width = [UIScreen mainScreen].bounds.size.width;
    self.bottomSepView.height = bottomSepViewHeight;
//    223
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.contentView).offset(15);
//        make.left.right.mas_equalTo(self.contentView);
//        make.height.mas_equalTo(188);
//    }];
    
//    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.left.right.mas_equalTo(self.contentView);
//        make.height.mas_equalTo(bottomSepViewHeight);
//    }];
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
    
    FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)data;
    self.cellModel = model;
    self.dataList = model.hotCellList;
    self.flowLayout.dataList = _dataList;
    
    [self.collectionView reloadData];
}

+ (CGFloat)heightForData:(id)data {
    return 223;
}

- (void)moreData {
    // 点击埋点
    [self trackClickMore];
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *traceParam = @{}.mutableCopy;
    traceParam[UT_ENTER_TYPE] = @"click";
    traceParam[UT_ELEMENT_FROM] = @"hot_topic";
    traceParam[UT_ENTER_FROM] = self.cellModel.tracerDic[UT_PAGE_TYPE] ?: @"be_null";

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
        param[@"page_type"] = self.cellModel.tracerDic[UT_PAGE_TYPE] ?: @"be_null";
        param[@"enter_from"] = self.cellModel.tracerDic[UT_ENTER_FROM] ?: @"be_null";
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
        [self traceClientShowAtIndexPath:indexPath];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCHotCommunitySubCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if(indexPath.row < self.dataList.count){
        NSMutableDictionary *dict = @{}.mutableCopy;
        FHFeedContentRawDataHotCellListModel *model = self.dataList[indexPath.row];
        if([model.hotCellType isEqualToString:youwenbida]){
            [self trackClickOptions:model];
        }else if([model.hotCellType isEqualToString:more]){
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"action_type"] = @(FHCommunityListTypeFollow);
            dict[@"select_district_tab"] = @(FHUGCCommunityDistrictTabIdRecommend);
            NSMutableDictionary *traceParam = @{}.mutableCopy;
            traceParam[@"enter_type"] = @"click";
            traceParam[@"enter_from"] = self.cellModel.tracerDic[UT_PAGE_TYPE] ?: @"be_null";
            traceParam[@"element_from"] = @"top_operation_position";
            dict[@"tracer"] = traceParam;
        }else{
            NSMutableDictionary *traceParam = @{}.mutableCopy;
            traceParam[@"origin_from"] = self.cellModel.tracerDic[UT_ORIGIN_FROM] ?: @"be_null";
            traceParam[@"enter_from"] = self.cellModel.tracerDic[UT_PAGE_TYPE] ?: @"be_null";
            traceParam[@"element_from"] = @"top_operation_position";
            traceParam[@"rank"] = @(indexPath.row);
            if(model.logPb){
                traceParam[@"log_pb"] = model.logPb;
            }
            dict[@"tracer"] = traceParam;
        }

        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        if(model.url.length > 0){
            NSURL *openUrl = [NSURL URLWithString:model.url];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
        }
    }
}

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row >= self.dataList.count) {
        return;
    }
    
    FHFeedContentRawDataHotCellListModel *model = self.dataList[indexPath.row];
    
    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *itemId = model.id;
    if(itemId){
        if (self.clientShowDict[itemId]) {
            return;
        }
        
        self.clientShowDict[itemId] = @(indexPath.row);
        [self trackClientShow:model rank:indexPath.row];
    }
}

- (void)trackClientShow:(FHFeedContentRawDataHotCellListModel *)model rank:(NSInteger)rank {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    NSString *eventName = nil;
    if([model.hotCellType isEqualToString:youwenbida]){
        eventName = @"element_show";
        tracerDict[@"element_type"] = @"buyer_experts_group";
        tracerDict[@"page_type"] = self.cellModel.tracerDic[UT_PAGE_TYPE] ?: @"be_null";
        tracerDict[@"enter_from"] = self.cellModel.tracerDic[UT_ENTER_FROM] ?: @"be_null";
        tracerDict[@"origin_from"] = self.cellModel.tracerDic[UT_ORIGIN_FROM] ?: @"be_null";
        if(model.logPb){
            tracerDict[@"log_pb"] = model.logPb;
        }
    }else if([model.hotCellType isEqualToString:social]){
        eventName = @"community_group_show";
        tracerDict[@"element_type"] = @"top_operation_position";
        tracerDict[@"page_type"] = self.cellModel.tracerDic[UT_PAGE_TYPE] ?: @"be_null";
        tracerDict[@"enter_from"] = self.cellModel.tracerDic[UT_ENTER_FROM] ?: @"be_null";
        tracerDict[@"origin_from"] = self.cellModel.tracerDic[UT_ORIGIN_FROM] ?: @"be_null";
        tracerDict[@"rank"] = @(rank);
        if(model.id){
            tracerDict[@"group_id"] = model.id;
        }
        if(model.logPb){
            tracerDict[@"log_pb"] = model.logPb;
        }
    }
    
    if(eventName){
        TRACK_EVENT(eventName, tracerDict);
    }
}

- (void)trackClickOptions:(FHFeedContentRawDataHotCellListModel *)model {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    if([model.hotCellType isEqualToString:youwenbida]){
        tracerDict[@"element_type"] = @"buyer_experts_group";
        tracerDict[@"page_type"] = self.cellModel.tracerDic[UT_PAGE_TYPE] ?: @"be_null";
        tracerDict[@"enter_from"] = self.cellModel.tracerDic[UT_ENTER_FROM] ?: @"be_null";
    }
    TRACK_EVENT(@"click_options", tracerDict);
}

@end
