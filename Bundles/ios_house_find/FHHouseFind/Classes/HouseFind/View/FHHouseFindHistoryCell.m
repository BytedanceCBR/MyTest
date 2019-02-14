//
//  FHHouseFindHistoryCell.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/12.
//

#import "FHHouseFindHistoryCell.h"
#import "FHHouseFindHistoryItemCell.h"
#import "FHHFHistoryModel.h"

@interface FHHouseFindHistoryCell ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) NSArray *historyItems;

@end

#define CELL_ID @"cell_id"

@implementation FHHouseFindHistoryCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 13;
//        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:[FHHouseFindHistoryItemCell class] forCellWithReuseIdentifier:CELL_ID];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [self.contentView addSubview:_collectionView];
        
    }
    return self;
}

-(void)updateWithItems:(NSArray *)items
{
    self.historyItems = items;
    [self.collectionView reloadData];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.historyItems.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindHistoryItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    FHHFHistoryDataDataModel *model = _historyItems[indexPath.item];
    [cell udpateWithTitle:model.text subtitle:model.desc];
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHHFHistoryDataDataModel *model = _historyItems[indexPath.item];
    CGFloat width = [FHHouseFindHistoryItemCell widthForTitle:model.text subtitle:model.desc];
    return CGSizeMake(width, 60);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate) {
        FHHFHistoryDataDataModel *model = _historyItems[indexPath.item];
        [self.delegate selectHistory:model];
    }
}


@end

