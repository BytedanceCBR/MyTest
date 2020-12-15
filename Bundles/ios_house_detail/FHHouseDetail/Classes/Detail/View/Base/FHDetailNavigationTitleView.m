//
//  FHDetailNavigationTitleView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/19.
//

#import "FHDetailNavigationTitleView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "FHCommonDefines.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHDetailNavigationTitleView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

//@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, copy) NSArray <NSNumber *>* preTitleSums;
@property (nonatomic, assign) NSInteger titleIndex;
@end

@implementation FHDetailNavigationTitleView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setTitleNums:(NSArray *)titleNums {
    _titleNums = titleNums;
    NSMutableArray *preTitleSums = [NSMutableArray arrayWithCapacity:titleNums.count];
    
    for (NSNumber *preNum in titleNums) {
        NSNumber *lastSum = preTitleSums.lastObject;
        [preTitleSums addObject:[NSNumber numberWithUnsignedInteger:lastSum.unsignedIntegerValue + preNum.unsignedIntegerValue]];
    }
    self.preTitleSums = preTitleSums.copy;
}

//- (UIView *)indicatorView {
//    if (!_indicatorView) {
//        _indicatorView = [[UIView alloc] init];
//        _indicatorView.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
//        _indicatorView.frame = CGRectMake(5, CGRectGetHeight(self.colletionView.frame) - 13, 20, 4);
//        _indicatorView.layer.masksToBounds = YES;
//        _indicatorView.layer.cornerRadius = 2.0;
//        [self.colletionView addSubview:_indicatorView];
//    }
//    return _indicatorView;
//}

- (void)reloadData {
    [self.colletionView reloadData];
}

- (void)setupUI {
    _selectIndex = -1;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //    layout.estimatedItemSize = CGSizeMake(71, 22);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0.01f;
    
    _colletionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) collectionViewLayout:layout];
    _colletionView.backgroundColor = [UIColor clearColor];
    _colletionView.pagingEnabled = NO;
    _colletionView.showsHorizontalScrollIndicator = NO;
    if(@available(iOS 11.0 , *)){
        _colletionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_colletionView registerClass:[FHDetailNavigationTitleCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailNavigationTitleCell class])];
    
    _colletionView.delegate = self;
    _colletionView.dataSource = self;
    
    [self addSubview:_colletionView];
    [self.colletionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    _seperatorLine = [[UIView alloc] init];
    _seperatorLine.backgroundColor = [UIColor themeGray6];
    _seperatorLine.hidden = YES;
    [self addSubview:_seperatorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.right.bottom.mas_equalTo(self);
    }];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex != selectIndex || selectIndex == 0) {
        _selectIndex = selectIndex; // 图片索引
        NSInteger titleIndex = [self titleIndexBySelectIndex];
        titleIndex = self.selectIndex;
        
        _titleIndex = titleIndex;
        [self.colletionView reloadData];
        if (titleIndex >= 0 && titleIndex < self.titleNames.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:titleIndex inSection:0];
            if (indexPath) {
                [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
//            UICollectionViewLayoutAttributes *attributes = [self.colletionView layoutAttributesForItemAtIndexPath:indexPath];
//            CGRect frame = attributes.frame;
//
//            CGFloat bottomSpace = 9;
//
//            [self.colletionView bringSubviewToFront:self.indicatorView];
//            [UIView animateWithDuration:0.2 animations:^{
//                self.indicatorView.frame = CGRectMake(frame.origin.x + frame.size.width/2 - 10, CGRectGetHeight(self.colletionView.frame) - bottomSpace, 20, 4);
//            }];
//
        }
    }
    _selectIndex = selectIndex; // 图片索引
}

- (NSInteger)titleIndexBySelectIndex {
    NSInteger titleIndex = 0;
    NSInteger left = 0 , right = self.titleNums.count - 1;
    while (left <= right) {
        NSInteger mid = (left + right) / 2;
        NSNumber *midSum = self.preTitleSums[mid];
        if (_selectIndex < midSum.unsignedIntegerValue) {
            titleIndex = mid;
            right = mid -1;
        } else {
            left = mid + 1;
        }
    }
    return titleIndex;
}

- (NSInteger)currentSelectIndexByTitleIndex:(NSInteger)titleIndex {
    NSInteger currentSelectIndex = 0;
    if (titleIndex >= 0 && titleIndex < self.titleNums.count) {
        if (titleIndex > 0) {
            NSNumber *number = self.preTitleSums[titleIndex - 1];
            currentSelectIndex = number.unsignedIntegerValue;
        }
    }
    return currentSelectIndex;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titleNames.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.titleNames.count) {
        NSString *title = self.titleNames[row];
        CGSize size = CGSizeMake([title btd_widthWithFont:[UIFont themeFontRegular:14] height:22], CGRectGetHeight(collectionView.frame));
        size.width += 12 * 2;
        
        return size;
    }
    CGSize retSize = CGSizeMake(72, 22);
    return retSize;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHDetailNavigationTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHDetailNavigationTitleCell class]) forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    if (index >= 0 && index < self.titleNames.count) {
        NSString *title = self.titleNames[index];
        cell.titleLabel.text = title;
    }
    NSInteger titleIndex = self.titleIndex;
    titleIndex = self.selectIndex;
    
    UIColor *selectColor = [UIColor themeOrange1];
    UIColor *normalColor = [UIColor themeGray1];
    UIFont *selectFont = [UIFont themeFontRegular:14];
    UIFont *normalFont = [UIFont themeFontRegular:14];
    [cell.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(cell.contentView);
        make.centerX.mas_equalTo(cell.contentView);
    }];

    if (titleIndex == index) {
        cell.titleLabel.textColor = selectColor;
        cell.titleLabel.font = selectFont;
    } else {
        cell.titleLabel.textColor = normalColor;
        cell.titleLabel.font = normalFont;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    if (index >= 0 && index < self.titleNames.count) {
        NSInteger currentSelectIndex = [self currentSelectIndexByTitleIndex:index];
        currentSelectIndex = index;
        
        self.selectIndex = currentSelectIndex;
        // 回传给VC
        if (self.currentIndexBlock) {
            self.currentIndexBlock(currentSelectIndex);
        }
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

@end


// FHDetailPictureTitleCell
@implementation FHDetailNavigationTitleCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.hidden = NO;
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.4];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(22);
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(20);
        }];
    }
    return self;
}
@end

