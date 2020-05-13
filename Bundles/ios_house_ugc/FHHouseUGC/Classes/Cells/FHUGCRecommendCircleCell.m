//
//  FHUGCRecommendCircleCell.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/4/27.
//

#import "FHUGCRecommendCircleCell.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHUGCRecommendCircleSubCell.h"
#import "UIColor+Theme.h"
#import "FHCommunityList.h"
#import "UIViewAdditions.h"
#import "FHUserTracker.h"

#define cellId @"cellId"
@interface FHUGCRecommendCircleCell ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (strong, nonatomic) FHBaseCollectionView *mainCollection;
@property(nonatomic, strong) NSMutableDictionary *clientShowDict;
@property (strong, nonatomic) NSArray *dataList;
@property (strong, nonatomic) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,strong) UIView *bottomSepView;
@end

@implementation FHUGCRecommendCircleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self initmMainCollection];
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.equalTo(self.contentView);
        make.height.mas_offset(5);
    }];
}

- (void)initmMainCollection {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    flowLayout.minimumLineSpacing = 8;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _mainCollection = [[FHBaseCollectionView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, 60) collectionViewLayout:flowLayout];
    [_mainCollection registerClass:[FHUGCRecommendCircleSubCell class] forCellWithReuseIdentifier:cellId];
    _mainCollection.showsHorizontalScrollIndicator = NO;
    _mainCollection.alwaysBounceHorizontal = YES;
    _mainCollection.delegate = self;
    _mainCollection.dataSource = self;
    _mainCollection.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_mainCollection];
}

+ (CGFloat)heightForData:(id)data {
    CGFloat cellHeight = 65;
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        if (cellModel.hidelLine) {
            cellHeight -=5;
        }
        if (!isEmptyString(cellModel.upSpace) && cellModel.upSpace.integerValue >0) {
            cellHeight += cellModel.upSpace.integerValue;
        }else {
            cellHeight += 20;
        }
        if (!isEmptyString(cellModel.downSpace) && cellModel.downSpace.integerValue >0 ) {
            cellHeight += cellModel.downSpace.integerValue;
        }else {
            cellHeight += 20;
        }
    }
    return cellHeight;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    FHFeedUGCCellModel *model = (FHFeedUGCCellModel *)data;
    self.cellModel = model;
    if(self.currentData == data && !model.ischanged){
        return;
    }
    self.currentData = data;
    self.dataList = model.hotSocialList;
    self.bottomSepView.hidden = model.hidelLine;
    
    if (!isEmptyString(model.upSpace) && model.upSpace.integerValue >0) {
        [self.mainCollection setFrame:CGRectMake(0, model.upSpace.integerValue, [UIScreen mainScreen].bounds.size.width, 60)];
    }
    [self.mainCollection reloadData];
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
    NSString *reuseId = cellId;
    
    FHUGCBaseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    if (indexPath.row < self.dataList.count) {
        [cell refreshWithData:self.dataList[indexPath.row]];
        
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if(indexPath.row < self.dataList.count){
        FHUGCScialGroupDataModel *model = self.dataList[indexPath.row];
        
        TTRouteUserInfo *userInfo = nil;
        if([model.socialGroupId isEqualToString:@"-1"]){
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"action_type"] = @(FHCommunityListTypeFollow);
            dict[@"select_district_tab"] = @(FHUGCCommunityDistrictTabIdFollow);
            NSMutableDictionary *traceParam = @{}.mutableCopy;
            traceParam[@"enter_type"] = @"click";
            traceParam[@"enter_from"] = self.cellModel.tracerDic[@"page_type"] ?: @"be_null";
            traceParam[@"element_from"] = @"top_operation_position";
            dict[@"tracer"] = traceParam;
            userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        }else{
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"community_id"] = self.cellModel.community.socialGroupId;
            dict[@"tracer"] = @{
                @"origin_from":self.cellModel.tracerDic[@"origin_from"] ?: @"be_null",
                @"enter_from":self.cellModel.tracerDic[@"page_type"] ?: @"be_null",
                @"enter_type":@"click",
                @"element_from":@"top_operation_position",
                @"rank":self.cellModel.tracerDic[@"rank"] ?: @"be_null",
                @"log_pb":self.cellModel.logPb ?: @"be_null"};
            userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        }
    
        NSURL *openUrl = [NSURL URLWithString:model.schema];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(120, 60);
}

- (void)traceClientShowAtIndexPath:(NSIndexPath*)indexPath {
    FHUGCScialGroupDataModel *model = self.dataList[indexPath.row];

    if (!self.clientShowDict) {
        self.clientShowDict = [NSMutableDictionary new];
    }
    
    NSString *row = [NSString stringWithFormat:@"%i",indexPath.row];
    NSString *socialGroupId = model.socialGroupId;
    if(socialGroupId){
        if (self.clientShowDict[socialGroupId]) {
            return;
        }

        self.clientShowDict[socialGroupId] = @(indexPath.row);
        [self trackClientShow:model rank:indexPath.row];
    }
}

- (void)trackClientShow:(FHUGCScialGroupDataModel *)model rank:(NSInteger)rank {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];

    tracerDict[@"element_type"] = @"top_operation_position";
    tracerDict[@"page_type"] = self.cellModel.tracerDic[@"page_type"];
    tracerDict[@"enter_from"] = self.cellModel.tracerDic[@"enter_from"];
    tracerDict[@"origin_from"] = self.cellModel.tracerDic[@"origin_from"];
    tracerDict[@"rank"] = @(rank);
    tracerDict[@"group_id"] = model.socialGroupId;
    tracerDict[@"log_pb"] = model.logPb;
    
    TRACK_EVENT(@"community_group_show", tracerDict);
}

@end
