//
//  FHMainOldTopView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHMainOldTopView.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIColor+Theme.h>
#import "FHMainOldTopCell.h"

#define kCellId @"cell_id"
#define ITEM_HOR_MARGIN  10
#define TOP_PADDING      14
#define BOTTOM_PADDING   2


@interface FHMainOldTopView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) UICollectionViewFlowLayout *layout;

@end

@implementation FHMainOldTopView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.headerReferenceSize = CGSizeMake(HOR_MARGIN, 1);
        layout.footerReferenceSize = CGSizeMake(HOR_MARGIN, 1);
        
        CGRect f = self.bounds;
        f.size.height -= BOTTOM_PADDING;
        //CGRectMake(0, 15, frame.size.width, frame.size.height - BOTTOM_PADDING - 15)
        _collectionView = [[UICollectionView alloc]initWithFrame:f collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[FHMainOldTopCell class] forCellWithReuseIdentifier:kCellId];
        
        _layout = layout;
        
        [self addSubview:_collectionView];
        
        self.backgroundColor = [UIColor themeGray7];
        _collectionView.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

-(void)setItems:(NSArray *)items
{
    if (items.count > 3) {
        _items = [items subarrayWithRange:NSMakeRange(0, 3 )];
    }else{
        _items = items;
    }
    [self.collectionView reloadData];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FHMainOldTopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    
    FHConfigDataOpData2ItemsModel *model = _items[indexPath.item];
    [cell updateWithModel:model];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(selecteOldItem:)]) {
        FHConfigDataOpData2ItemsModel *model = _items[indexPath.item];
        [self.delegate selecteOldItem:model];
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return ITEM_HOR_MARGIN;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [self widthForItem:self.items.count < 2? 2:self.items.count];
    return CGSizeMake(width, self.collectionView.frame.size.height - TOP_PADDING);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(TOP_PADDING, 0, 0, 0);
}

-(CGFloat)widthForItem:(NSInteger)totalCount
{
 
    return (CGRectGetWidth(self.bounds) - 2*HOR_MARGIN - ITEM_HOR_MARGIN*(totalCount-1))/totalCount;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
