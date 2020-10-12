//
//  FHNeighborhoodDetailHouseSaleCollectionCell.m
//  FHHouseDetail
//
//  Created by bytedance on 2020/10/12.
//

#import "FHNeighborhoodDetailHouseSaleCollectionCell.h"
#import "FHDetailNeighborhoodHouseSaleCell.h"
#import "FHDetailSurroundingAreaCell.h"

@interface FHNeighborhoodDetailHouseSaleCollectionCell () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@end

@implementation FHNeighborhoodDetailHouseSaleCollectionCell

+(CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 210);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
    }
    return self;
}

-(void)refreshWithData:(id)data {
    if(self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailHouseSaleCellModel class]]){
        return;
    }
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
    self.flowLayout.itemSize = CGSizeMake(120, 190);
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds)) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[FHDetailNeighborhoodHouseSaleCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailNeighborhoodHouseSaleCollectionCell class])];
    [self.collectionView registerClass:[FHDetailMoreItemCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailMoreItemCollectionCell class])];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}


@end

@implementation FHNeighborhoodDetailHouseSaleCellModel

@end
