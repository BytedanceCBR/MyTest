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
#import <TTRoute.h>
#import "FHUserTracker.h"

#define leftMargin 20
#define rightMargin 20
#define cellId @"cellId"

#define headerViewHeight 40
#define bottomSepViewHeight 5

@interface FHUGCHotTopicCell()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic ,strong) FHUGCCellHeaderView *headerView;
@property(nonatomic ,strong) FHBaseCollectionView *collectionView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(nonatomic ,strong) NSMutableArray *sourceList;
@property(nonatomic ,strong) NSArray *dataList;

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
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
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
        make.height.mas_equalTo(90);
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
    self.currentData = data;
    
    FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)data;
    self.dataList = model.hotTopicList;
}

+ (CGFloat)heightForData:(id)data {
    return 160;
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

//    if([self.currentData isKindOfClass:[FHFeedUGCCellModel class]]) {
//
//        FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)self.currentData;
//
//        NSMutableDictionary *tracerDict = model.tracerDic;
//        NSMutableDictionary *param = [NSMutableDictionary new];
//        param[UT_CATEGORY_NAME] = @"topic_list";
//        param[UT_ENTER_TYPE] = @"click";
//        param[UT_ELEMENT_FROM] = @"hot_topic";
//        param[UT_ENTER_FROM] = tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
//        TRACK_EVENT(UT_ENTER_CATEOGRY, param);
//    }
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
    
//    FHUGCScialGroupDataModel *model = self.dataList[indexPath.row];
    NSMutableDictionary *dict = @{}.mutableCopy;
//    dict[@"community_id"] = model.socialGroupId;
//    dict[@"tracer"] = @{@"enter_from":@"my_joined_neighborhood",
//                        @"enter_type":@"click",
//                        @"rank":@(indexPath.row),
//                        @"log_pb":model.logPb ?: @"be_null"};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    //跳转到话题详情页
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://concern"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(90, 90);
}

@end
