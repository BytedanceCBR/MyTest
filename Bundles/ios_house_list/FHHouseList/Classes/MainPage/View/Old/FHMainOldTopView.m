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
#import <FHHouseBase/FHBaseCollectionView.h>
#import <FHHouseBase/FHHomeScrollBannerView.h>
#import <FHHouseBase/FHHomeEntranceItemView.h>
#import <Masonry.h>
#import <FHCommonUI/FHFakeInputNavbar.h>
#import <FHHouseBase/FHConfigModel.h>
#import <TTBaseLib/UIViewAdditions.h>
#import "FHListEntrancesView.h"
#import "FHMainTopViewHelper.h"

#define kCellId @"cell_id"
#define ITEM_HOR_MARGIN  10
#define TOP_PADDING      14
#define BOTTOM_PADDING   4


@interface FHMainOldTopView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic , strong) UIView *topBgView;//64 + 140 + 10
@property(nonatomic , strong) UICollectionView *collectionView;
@property(nonatomic , strong) UICollectionViewFlowLayout *layout;
@property(nonatomic , strong) FHHomeScrollBannerView *bannerView;
@property(nonatomic , strong) UIView *bottomBgView;
@property(nonatomic , strong) FHListEntrancesView *bottomContainerView;

@end





@implementation FHMainOldTopView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
        [self initConstraints];
    }
    return self;
}

+ (CGFloat)bannerHeight
{
    return 140;
}

+ (CGFloat)entranceHeight
{
    return ceil(SCREEN_WIDTH/375.f*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT)+TOP_MARGIN_PER_ROW;
}

+ (CGFloat)totalHeight
{
    return [FHFakeInputNavbar perferredHeight] + [FHMainOldTopView bannerHeight] + 10 + [FHMainOldTopView entranceHeight];
}

- (void)setupUI
{
    [self addSubview:self.topBgView];
    [self addSubview:self.bottomBgView];
    [self addSubview:self.bannerView];
    [self addSubview:self.bottomContainerView];

    self.topBgView.backgroundColor = [UIColor colorWithHexString:@"#c5b8aej" alpha:1];
    self.bannerView.backgroundColor = [UIColor redColor];

    self.bottomContainerView.backgroundColor = [UIColor themeBlue1];

}

- (void)initConstraints
{
    [self.topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo([FHMainOldTopView bannerHeight] + 10 + [FHFakeInputNavbar perferredHeight]);
    }];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo([FHFakeInputNavbar perferredHeight] + 10);
        make.height.mas_equalTo([FHMainOldTopView bannerHeight]);
    }];
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.bannerView.mas_bottom);
        make.height.mas_equalTo([FHMainOldTopView entranceHeight]);
    }];
    [self.bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.bannerView.mas_bottom).mas_offset(-40);
        make.bottom.mas_equalTo(self.bottomContainerView);// todo zjing height
    }];
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
    return CGSizeMake(width, self.collectionView.frame.size.height - TOP_PADDING );
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(TOP_PADDING, 0, 0, 0);
}

-(CGFloat)widthForItem:(NSInteger)totalCount
{
    return floor((CGRectGetWidth(self.bounds) - 2*HOR_MARGIN - ITEM_HOR_MARGIN*(totalCount-1))/totalCount*2)/2;
    
}

#pragma mark - UI

- (UIView *)topBgView
{
    if (!_topBgView) {
        _topBgView = [[UIView alloc]init];
    }
    return _topBgView;
}

- (FHHomeScrollBannerView *)bannerView
{
    if (!_bannerView) {
        _bannerView = [[FHHomeScrollBannerView alloc] init];
        _bannerView.backgroundColor = [UIColor themeHomeColor];
        _bannerView.layer.masksToBounds = YES;
        _bannerView.layer.cornerRadius = 12;
    }
    return _bannerView;
}

- (UIView *)bottomBgView
{
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]init];
        _bottomBgView.backgroundColor = [UIColor themeGray8];
        _bottomBgView.layer.masksToBounds = YES;
        _bottomBgView.layer.cornerRadius = 10;
    }
    return _bottomBgView;
}

- (UIView *)bottomContainerView
{
    if (!_bottomContainerView) {
        _bottomContainerView = [[UIView alloc]init];
        _bottomContainerView.backgroundColor = [UIColor themeGray8];
    }
    return _bottomContainerView;
}

@end
