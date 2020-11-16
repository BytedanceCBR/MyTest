//
//  FHHomeEntranceContainerCell.m
//  FHHouseHome
//
//  Created by CYY RICH on 2020/11/9.
//

#import "FHHomeEntranceContainerCell.h"
#import "FHConfigModel.h"
#import "FHCommonDefines.h"
#import "FHHomeEntranceItemCell.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <BDWebImage/UIImageView+BDWebImage.h>
#import "FHEnvContext.h"
#import "FHHomeCellHelper.h"
#import <FHHouseBase/FHHomeEntranceItemView.h>


@interface FHHomeEntranceContainerCell()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *backdropView;

@property (nonatomic, strong) UICollectionView *entranceCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIView *bottomSlide;
@property (nonatomic, strong) UIView *slider;

//data
@property (nonatomic , strong) NSArray *items;

@property (atomic, assign) float sliderWidth;

@end

@implementation FHHomeEntranceContainerCell


+ (CGFloat)rowHeight {
    if ([[FHEnvContext sharedInstance] getConfigFromCache].mainPageBannerOpData.items.count > 0){
//        return ceil(SCREEN_WIDTH/375.f*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT)+TOP_MARGIN_PER_ROW - 15;
        return ceil(((SCREEN_WIDTH - 30) / 5) + 8);
    } else {
//        return ceil(SCREEN_WIDTH/375.f*NORMAL_ICON_WIDTH+NORMAL_NAME_HEIGHT)+TOP_MARGIN_PER_ROW + 10;
        return ceil((SCREEN_WIDTH - 30) / 5)  + 8 + 10 ;
    }
}

+ (CGFloat)cellHeightForModel:(id)model {
    if (![model isKindOfClass:[FHConfigDataOpDataModel class]]) {
        return 0;
    }
    NSInteger countPerRow = [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount;
    FHConfigDataOpDataModel *dataModel = (FHConfigDataOpDataModel *)model;
    NSInteger rows = ((dataModel.items.count+countPerRow-1)/countPerRow);
    return [self rowHeight]*rows;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUserInterface];
    }
    return self;
}

- (void)setupUserInterface {
    
    self.backgroundColor = [UIColor clearColor];
    
    _backdropView = [[UIView alloc] init];
    _backdropView.backgroundColor = [UIColor whiteColor];
    _backdropView.layer.cornerRadius = 10.f;
    _backdropView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.backdropView];
    [_backdropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(15.f);
        make.right.mas_equalTo(self).offset(- 15.f);
    }];

    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 16, 0);
    self.flowLayout.itemSize = CGSizeMake((SCREEN_WIDTH - 30)/5, (SCREEN_WIDTH - 30)/5);
    
    _entranceCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    _entranceCollectionView.backgroundColor = [UIColor clearColor];
    [self.backdropView addSubview:_entranceCollectionView];
    [_entranceCollectionView registerClass:[FHHomeEntranceItemCell class] forCellWithReuseIdentifier:NSStringFromClass([FHHomeEntranceItemCell class])];
    _entranceCollectionView.showsVerticalScrollIndicator = NO;
    _entranceCollectionView.showsHorizontalScrollIndicator = NO;
    _entranceCollectionView.alwaysBounceHorizontal = YES;
    _entranceCollectionView.delegate = self;
    _entranceCollectionView.dataSource = self;
    _entranceCollectionView.directionalLockEnabled = YES;
    [_entranceCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(self.bottomSlide.mas_top).offset(0);
    }];
    
    _bottomSlide = [[UIView alloc] init];
    _bottomSlide.backgroundColor = [UIColor themeGray5];
    _bottomSlide.layer.cornerRadius = 2.f;
    _bottomSlide.layer.masksToBounds = YES;
    [self.backdropView addSubview:self.bottomSlide];
    
    [_bottomSlide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(4);
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-9);
    }];
    
    _slider = [[UIView alloc] init];
    _slider.backgroundColor = [UIColor themeOrange4];
    _slider.layer.cornerRadius = 2.f;
    _slider.layer.masksToBounds = YES;
    [self.bottomSlide addSubview:self.slider];
    
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(4);
        make.left.bottom.mas_equalTo(0);
    }];
}

- (void)updateWithItems:(NSArray<FHConfigDataOpDataItemsModel *> *)items {
    if(items == self.items){
        return;
    }
    self.items = items;
    __block CGFloat percent = 5 / ceil((float)self.items.count / 2);
    self.sliderWidth = 32 * percent;
    [_slider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.sliderWidth);
        make.height.mas_equalTo(4);
        make.bottom.mas_equalTo(0);
    }];
    
    [self.entranceCollectionView reloadData];
    
}

- (void)dealloc {
    self.entranceCollectionView.delegate = nil;
    self.entranceCollectionView.dataSource = nil;
}

#pragma mark - UICollectionViewDataSource

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHHomeEntranceItemCell *cell = [_entranceCollectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHHomeEntranceItemCell class]) forIndexPath:indexPath];
    FHConfigDataOpDataItemsModel *model = [self.items objectAtIndex:indexPath.row];
    if (model) {
        [cell bindModel:model];
    }
    return cell;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.clickBlock) {
        FHConfigDataOpDataItemsModel *model = nil;
        if(_items.count > indexPath.row){
            model = _items[indexPath.row];
        }
        self.clickBlock(indexPath.row , model);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.5 animations:^{
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(scrollView.contentOffset.x);
            make.width.mas_equalTo(self.sliderWidth);
            make.top.bottom.mas_equalTo(self.bottomSlide);
        }];
    }];
}



@end
