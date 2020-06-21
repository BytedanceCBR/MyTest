//
//  FHDetailPictureTitleView.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/17.
//

#import "FHDetailPictureTitleView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import "FHCommonDefines.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHDetailPictureTitleView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *indicatorView;

@end

@implementation FHDetailPictureTitleView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UIView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
        _indicatorView.frame = CGRectMake(5, CGRectGetHeight(self.colletionView.frame) - 13, 20, 4);
        _indicatorView.layer.masksToBounds = YES;
        _indicatorView.layer.cornerRadius = 2.0;
        [self.colletionView addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (void)reloadData {
    [self.colletionView reloadData];
}

- (void)setupUI {
    _selectIndex = -1;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //    layout.estimatedItemSize = CGSizeMake(71, 22);
    layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 10;
    
    _colletionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) collectionViewLayout:layout];
    _colletionView.backgroundColor = [UIColor clearColor];
    _colletionView.pagingEnabled = NO;
    _colletionView.showsHorizontalScrollIndicator = NO;
    if(@available(iOS 11.0 , *)){
        _colletionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_colletionView registerClass:[FHDetailPictureTitleCell class] forCellWithReuseIdentifier:NSStringFromClass([FHDetailPictureTitleCell class])];
    
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
        [self.colletionView reloadData];
        NSInteger titleIndex = [self titleIndexBySelectIndex];
        if (titleIndex >= 0 && titleIndex < self.titleNames.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:titleIndex inSection:0];
            if (indexPath) {
                [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            }
            if (self.usedInPictureList) {
                UICollectionViewLayoutAttributes *attributes = [self.colletionView layoutAttributesForItemAtIndexPath:indexPath];
                CGRect frame = attributes.frame;
//                NSString *title = self.titleNames[titleIndex];
//                NSRange range = [title rangeOfString:@"（"];
//                if (range.location != NSNotFound) {
//                    title = [title substringToIndex:range.location];
//                }
//                CGFloat width = [title btd_widthWithFont:[UIFont themeFontRegular:16] height:22];
//                if (frame.size.width > width) {
//                    frame.size.width = width;
//                }
                [self.colletionView bringSubviewToFront:self.indicatorView];
                [UIView animateWithDuration:0.2 animations:^{
                    self.indicatorView.frame = CGRectMake(frame.origin.x + frame.size.width/2 - 10, CGRectGetHeight(self.colletionView.frame) - 13, 20, 4);
                }];
            }
        }
    }
    _selectIndex = selectIndex; // 图片索引
}

- (NSInteger)titleIndexBySelectIndex {
    NSInteger count = 0;
    NSInteger titleIndex = 0;
    for (int i = 0; i < self.titleNums.count; i++) {
        NSNumber *num = self.titleNums[i];
        NSInteger tempCount = [num integerValue];
        count += tempCount;
        if (_selectIndex < count) {
            titleIndex = i;
            break;
        }
    }
    return titleIndex;
}

- (NSInteger)currentSelectIndexByTitleIndex:(NSInteger)titleIndex {
    NSInteger currentSelectIndex = 0;
    if (titleIndex >= 0 && titleIndex < self.titleNums.count) {
        for (int i = 0; i < titleIndex; i++) {
            NSNumber *num = self.titleNums[i];
            NSInteger tempCount = [num integerValue];
            currentSelectIndex += tempCount;
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
        CGSize size = CGSizeMake([title btd_widthWithFont:[UIFont themeFontRegular:16] height:22], CGRectGetHeight(collectionView.frame));
        return size;
    }
    CGSize retSize = CGSizeMake(71, 22);
    return retSize;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHDetailPictureTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FHDetailPictureTitleCell class]) forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    if (index >= 0 && index < self.titleNames.count) {
        NSString *title = self.titleNames[index];
        cell.titleLabel.text = title;
    }
    NSInteger titleIndex = [self titleIndexBySelectIndex];

    UIColor *selectColor = [UIColor whiteColor];
    UIColor *normalColor = [UIColor colorWithHexString:@"#ffffff" alpha:0.4];
    UIFont *selectFont = [UIFont themeFontRegular:16];
    UIFont *normalFont = [UIFont themeFontRegular:16];
    if (self.usedInPictureList) {
        selectColor = [UIColor themeGray1];
        normalColor = [UIColor colorWithHexStr:@"#6d7278"];
        selectFont = [UIFont themeFontSemibold:16];
        [cell.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(22);
            make.bottom.mas_equalTo(-15);
            make.centerX.mas_equalTo(cell.contentView);
        }];
    }
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
    if (index >= 0 && index < self.titleNums.count) {
        NSInteger currentSelectIndex = [self currentSelectIndexByTitleIndex:index];
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
@implementation FHDetailPictureTitleCell

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
