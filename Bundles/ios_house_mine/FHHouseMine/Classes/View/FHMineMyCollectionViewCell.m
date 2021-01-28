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
- (void) initView
{
    
}
- (void) initConstraints
{
    
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.contentView.backgroundColor = [UIColor themeGray7];
        self.items = [NSMutableArray array];
        [self initView];
        [self initConstraints];
    }
    return self;
}
- (void)initLayout{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = 65;
    CGFloat itemH = 65;
    flow.itemSize = CGSizeMake(itemW, itemH);
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.collectionView];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}
//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 15, 20, 15);
}
//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}
//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
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
