//
// Created by zhulijun on 2019-07-17.
//

#import "FHUGCCommunityDistrictTabView.h"
#import <FHHouseBase/FHBaseCollectionView.h>

@interface FHUGCCommunityCategoryView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic, strong) UICollectionView *categoryView;
@property(nonatomic, strong) UIView *separatorLine;
@property(nonatomic, strong) NSArray<FHUGCCommunityDistrictTabModel *> *categories;
@end

@implementation FHUGCCommunityCategoryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.categories = [NSArray array];
        [self initConstraints];
    }
    return self;
}

- (void)initConstraints {
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.bottom.right.mas_equalTo(self);
       make.width.mas_equalTo(0.5);
    }];
}

-(void)setContentInset:(UIEdgeInsets)contentInset {
    self.categoryView.contentInset = contentInset;
}

- (void)refreshWithCategories:(NSArray<FHUGCCommunityDistrictTabModel *> *)categories{
    if (!categories) {
        return;
    }
    self.categories = [categories copy];
    for (FHUGCCommunityDistrictTabModel *item in self.categories) {
        item.selected = NO;
    }
    [self.categoryView reloadData];
}

- (void)select:(NSInteger)categoryId selectType:(FHUGCCommunityDistrictTabSelectType)selectType;{
    if (self.categories.count <= 0) {
        return;
    }
    NSInteger before = -1;
    NSInteger current = -1;
    FHUGCCommunityDistrictTabModel *item;
    for (int i = 0; i < self.categories.count; i++) {
        item = self.categories[i];
        if ([item isSelected]) {
            item.selected = NO;
            before = i;
        }
        if (categoryId ==item.categoryId) {
            item.selected = YES;
            current = i;
        }
    }
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    if (before >= 0) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:before inSection:0]];
    }
    if (current >= 0 && current != before) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:current inSection:0]];
    }
    
    if(indexPaths.count <= 0){
        return;
    }

    [UIView performWithoutAnimation:^{
        [self.categoryView reloadItemsAtIndexPaths:indexPaths];
    }];

    if (self.delegate && [self.delegate respondsToSelector:@selector(onCategorySelect:before:selectType:)]) {
        FHUGCCommunityDistrictTabModel *beforeItem = before < 0 ? nil : self.categories[before];
        FHUGCCommunityDistrictTabModel *curItem = current < 0 ? nil : self.categories[current];
        [self.delegate onCategorySelect:curItem before:beforeItem selectType:selectType];
    }
}

- (UICollectionView *)categoryView {
    if (!_categoryView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _categoryView = [[FHBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _categoryView.backgroundColor = [UIColor clearColor];
        _categoryView.alwaysBounceVertical = YES;
        [_categoryView setShowsVerticalScrollIndicator:NO];
        _categoryView.dataSource = self;
        _categoryView.delegate = self;
        [_categoryView registerClass:[FHUGCCommunityDistrictTabCell class] forCellWithReuseIdentifier:@"FHUGCCommunityCategoryCell"];
        [self addSubview:_categoryView];
    }
    return _categoryView;
}

-(UIView *)separatorLine {
    if(!_separatorLine){
        _separatorLine = [[UIView alloc] initWithFrame:CGRectZero];
        _separatorLine.backgroundColor = [UIColor themeGray6];
        [self addSubview:_separatorLine];
    }
    return _separatorLine;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categories.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCCommunityDistrictTabModel *cellModel = self.categories[indexPath.row];
    FHUGCCommunityDistrictTabCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FHUGCCommunityCategoryCell" forIndexPath:indexPath];
    [cell refreshWithData:cellModel];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FHUGCCommunityDistrictTabModel *cellModel = self.categories[indexPath.row];
    [self select:cellModel.categoryId selectType:FHUGCCommunityDistrictTabSelectTypeClick];
}

@end
