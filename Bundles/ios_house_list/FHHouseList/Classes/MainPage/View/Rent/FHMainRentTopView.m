//
//  FHMainRentTopView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHMainRentTopView.h"
#import "FHMainRentTopCell.h"
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <BDWebImage/UIImageView+BDWebImage.h>

@interface FHMainRentTopView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) UICollectionViewFlowLayout *layout;
@property(nonatomic , strong) UIImageView *bannerView;
@end

#define kCellId @"cell_id"
#define ITEM_WIDTH  56
#define TOP_PADDING    15
#define BOTTOM_PADDING 6

#define BANNER_HEIGHT  102


@implementation FHMainRentTopView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.headerReferenceSize = CGSizeMake(HOR_MARGIN, 1);
        layout.footerReferenceSize = CGSizeMake(HOR_MARGIN, 1);
        
        CGRect f = self.bounds;
        
        BOOL needShowBanner = YES;
        
        f.size.height -= BOTTOM_PADDING;
        if (needShowBanner) {
            f.size.height -= BANNER_HEIGHT;
        }
        //CGRectMake(0, 15, frame.size.width, frame.size.height - BOTTOM_PADDING - 15)
        _collectionView = [[UICollectionView alloc]initWithFrame:f collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[FHMainRentTopCell class] forCellWithReuseIdentifier:kCellId];
        
        _layout = layout;
        
        [self addSubview:_collectionView];
        if (needShowBanner) {
            _bannerView = [[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame), f.size.width, BANNER_HEIGHT)];
            [self addSubview:_bannerView];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerClickAction)];
            [_bannerView addGestureRecognizer:tapGesture];
            _bannerView.userInteractionEnabled = YES;
        }
        
        self.backgroundColor = [UIColor themeGray7];
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        _bannerView.backgroundColor = [UIColor redColor
                                       ];
        
    }
    return self;
}

-(void)setItems:(NSArray *)items
{
    _items = items;
    
}

-(void)setBannerUrl:(NSString *)bannerUrl
{
    _bannerUrl = bannerUrl;
    [_bannerView bd_setImageWithURL:[NSURL URLWithString:bannerUrl]];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    FHMainRentTopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    
    FHConfigDataRentOpDataItemsModel *model = _items[indexPath.item];
    [cell updateWithModel:model];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(selecteRentItem:)]) {
        FHConfigDataRentOpDataItemsModel *model = _items[indexPath.item];
        [self.delegate selecteRentItem:model];
    }
    
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
//{
//    if (_items.count < 1) {
//        return 0;
//    }
//
//    return (SCREEN_WIDTH - ITEM_WIDTH*_items.count)/(_items.count - 1);
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (_items.count < 1) {
        return 0;
    }
    
    return (SCREEN_WIDTH - ITEM_WIDTH*_items.count - 2*HOR_MARGIN)/(_items.count - 1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ITEM_WIDTH, self.collectionView.frame.size.height - TOP_PADDING);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(TOP_PADDING, 0, 0, 0);
}

-(void)bannerClickAction
{
    if ([self.delegate respondsToSelector:@selector(tapRentBanner)]) {
        [self.delegate tapRentBanner];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
