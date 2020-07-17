//
//  FHHouseRealtorDetailitemCollectionView.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/14.
//

#import "FHHouseRealtorDetailitemCollectionView.h"
#import "FHHouseRealtorDetailBaseCellModel.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "UILabel+House.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHHouseRealtorDetailBaseCell.h"
#import "FHHouseRealtorDetailHouseCollectionCell.h"
@interface FHHouseRealtorDetailitemCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy)     NSString       *cellIdentifier;
@property (nonatomic, strong)   NSMutableDictionary       *houseShowCache;
@property (nonatomic, strong)   NSArray       *datas;// 数据数组
@property(nonatomic, assign) CGFloat currentCelleHeight;

@end
@implementation FHHouseRealtorDetailitemCollectionView

- (instancetype)initWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout viewHeight:(CGFloat)collectionViewHeight datas:(NSArray *)datas
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self setupUIWithFlowLayout:flowLayout viewHeight:collectionViewHeight];
        self.datas = datas;
        self.houseShowCache = [NSMutableDictionary new];
        _collectionContainer.delegate = self;
        _collectionContainer.dataSource = self;
    }
    return self;
}
- (void)registerCell:(Class)cell forIdentifier:(NSString *)cellIdentifier {
    [self registerCls:cell forIdentifier:cellIdentifier];
}

- (void)setupUIWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout viewHeight:(CGFloat)collectionViewHeight {
    if (flowLayout) {
        _collectionContainer = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionContainer.showsHorizontalScrollIndicator = NO;
        _collectionContainer.backgroundColor = UIColor.clearColor;
        _collectionContainer.pagingEnabled = YES;
        [self addSubview:_collectionContainer];
        [_collectionContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
            make.height.mas_equalTo(collectionViewHeight);
        }];
    }
}

- (void)registerCls:(Class)cls forIdentifier:(NSString *)cellIdentifier {
    [_collectionContainer registerClass:cls forCellWithReuseIdentifier:cellIdentifier];
    self.cellIdentifier = cellIdentifier;
}

- (void)reloadData {
    [self.collectionContainer reloadData];
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id data = self.datas[indexPath.row];
    FHHouseRealtorDetailCollectionCell *cell;
    NSString *identifier=[NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    if ([data isKindOfClass:[FHHouseRealtorDetailHouseCollectionModel class]]) {
        [collectionView registerClass:[FHHouseRealtorDetailHouseCollectionCell class] forCellWithReuseIdentifier:identifier];
    }
    if (identifier.length > 0) {
        __weak typeof(self)WS = self;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.selfIndex = indexPath.row;
        cell.cellRefreshComplete = ^{
            if (WS.cellRefreshComplete) {
                WS.cellRefreshComplete();
                [WS reloadRowHeight];
            }
        };
        if (indexPath.row < self.datas.count) {
            [cell refreshWithData:self.datas[indexPath.row]];
        }
    }
    return cell;
}
- (void)reloadRowHeight {
  dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
            [self reloadData];
    });
}

- (void)requestData:(BOOL)isHead first:(BOOL)isFirst {
//    NSIndexPath *index = [NSIndexPath indexPathForRow:[FHHouseRealtorDetailStatusModel sharedInstance].currentIndex inSection:0];
//    FHHouseRealtorDetailCollectionCell *cell = (FHHouseRealtorDetailCollectionCell*)[self.collectionContainer cellForItemAtIndexPath:index];
//    [cell requestData:isHead first:isFirst];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (self.clickBlk) {
        self.clickBlk(indexPath.row);
    }
}

// house_show埋点
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tempKey = [NSString stringWithFormat:@"%ld_%ld",indexPath.section,indexPath.row];
    if ([self.houseShowCache valueForKey:tempKey]) {
        return;
    }
    [self.houseShowCache setValue:@(YES) forKey:tempKey];
    // 添加埋点
    if (self.displayCellBlk) {
        self.displayCellBlk(indexPath.row);
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width,  500);
}
@end
