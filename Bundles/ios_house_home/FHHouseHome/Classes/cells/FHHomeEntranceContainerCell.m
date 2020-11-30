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

static const CGFloat sliderWidth = 16.f;

@interface FHHomeEntranceContainerCell()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *backdropView;

@property (nonatomic, strong) UICollectionView *entranceCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) UIView *bottomSlide;
@property (nonatomic, strong) UIView *slider;

//data
@property (nonatomic , strong) NSArray *items;

@end

@implementation FHHomeEntranceContainerCell

+ (CGFloat)cellHeightForModel:(id)model {
    if (![model isKindOfClass:[FHConfigDataOpDataModel class]]) {
        return 0;
    }
    FHConfigDataOpDataModel *dataModel = (FHConfigDataOpDataModel *)model;
//    return ceil((SCREEN_WIDTH - 30)/5 * 2) + dataModel.items.count > 10 ? 16 : 8;
    return dataModel.items.count > 10 ? ceil((SCREEN_WIDTH - 30)/5 * 2) + 16 : ceil((SCREEN_WIDTH - 30)/5 * 2) + 8;
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
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.minimumLineSpacing = 0;
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
    self.bottomSlide.hidden = items.count > 10 ? NO : YES;
    if(items == self.items){
        return;
    }
    self.items = items;
    [_slider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(sliderWidth);
        make.height.mas_equalTo(4);
        make.bottom.mas_equalTo(0);
    }];
    [_entranceCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(self).offset(self.bottomSlide.hidden ? -8 : -16);
    }];
    
    [self.entranceCollectionView reloadData];
}

- (void)dealloc {
    self.entranceCollectionView.delegate = nil;
    self.entranceCollectionView.dataSource = nil;
}

#pragma mark - UICollectionViewDataSource

//(index & 1)判断奇偶，改变映射关系，举个例子：
//背景：首页icon需要横着划，所以datasource只能竖着排(collectionview) 导致原先数据源x = [1,2,3,4,5,6,7,8,9,10]在界面上体现为y = [1,6,2,7,3,8,4,9,5,10]。
//所以为了使collectionview横向滑动，需要在cellforrow改变映射关系，使y变成x
- (NSUInteger)getIndexWithCount:(NSUInteger)count withIndex:(NSUInteger)index {
    return index / 2 + (index & 1) * (count + 1) / 2;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHHomeEntranceItemCell *cell = [_entranceCollectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHHomeEntranceItemCell class]) forIndexPath:indexPath];
    NSUInteger row = [self getIndexWithCount:self.items.count withIndex:indexPath.row];
    FHConfigDataOpDataItemsModel *model = [self.items objectAtIndex:row];
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
        NSUInteger row = [self getIndexWithCount:self.items.count withIndex:indexPath.row];
        if(_items.count > row){
            model = _items[row];
        }
        self.clickBlock(row , model);
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.5 animations:^{
        [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(scrollView.contentOffset.x / (scrollView.contentSize.width - self.entranceCollectionView.frame.size.width + 0.1) * 16);
            make.width.mas_equalTo(sliderWidth);
            make.top.bottom.mas_equalTo(self.bottomSlide);
        }];
    }];
}



@end
