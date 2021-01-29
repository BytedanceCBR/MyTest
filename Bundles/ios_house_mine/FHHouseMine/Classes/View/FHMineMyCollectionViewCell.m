//
//  FHMineMyCollectionViewCell.m
//  FHHouseMine
//
//  Created by bytedance on 2021/1/28.
//

#import "FHMineMyCollectionViewCell.h"
#import "MyUICollectionViewCell.h"
@interface FHMineMyCollectionViewCell()
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSMutableArray<MyUICollectionViewCell*> *items;

@end

@implementation FHMineMyCollectionViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.contentView.backgroundColor = [UIColor themeGray7];
        self.items = [NSMutableArray array];
    }
    return self;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyUICollectionViewCell *cell = [[MyUICollectionViewCell alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

@end
