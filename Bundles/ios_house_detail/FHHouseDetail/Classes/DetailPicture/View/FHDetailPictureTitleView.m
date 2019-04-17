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

@interface FHDetailPictureTitleView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong)   UILabel       *tempLabel;
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

- (void)setupUI {
    _selectIndex = -1;
    _tempLabel = [[UILabel alloc] init];
    _tempLabel.hidden = YES;
    _tempLabel.font = [UIFont themeFontRegular:16];
    [self addSubview:_tempLabel];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //    layout.estimatedItemSize = CGSizeMake(71, 22);
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 20);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 10;
    
    _colletionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 22) collectionViewLayout:layout];
    _colletionView.backgroundColor = [UIColor clearColor];
    _colletionView.pagingEnabled = NO;
    _colletionView.showsHorizontalScrollIndicator = NO;
    
    [_colletionView registerClass:[FHDetailPictureTitleCell class] forCellWithReuseIdentifier:@"FHDetailPictureTitleCell"];
    
    _colletionView.delegate = self;
    _colletionView.dataSource = self;
    
    [self addSubview:_colletionView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    if (_selectIndex != selectIndex) {
        [self.colletionView reloadData];
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
    if (row >=0 && row < self.titleNames.count) {
        NSString *title = self.titleNames[row];
        self.tempLabel.text = title;
        self.tempLabel.textColor = [UIColor blackColor];
        self.tempLabel.hidden = NO;
        CGSize size = [self.tempLabel sizeThatFits:CGSizeMake(200, 22)];
        self.tempLabel.hidden = YES;
        return size;
    }
    CGSize retSize = CGSizeMake(71, 22);
    return retSize;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHDetailPictureTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FHDetailPictureTitleCell" forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    if (index >= 0 && index < self.titleNames.count) {
        NSString *title = self.titleNames[index];
        cell.titleLabel.text = title;
    }
    NSInteger titleIndex = [self titleIndexBySelectIndex];
    cell.hasSelected = (titleIndex == index);
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

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
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.hidden = NO;
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray2];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        self.hasSelected = NO;
    }
    return self;
}

- (void)setHasSelected:(BOOL)hasSelected {
    _hasSelected = hasSelected;
    if (hasSelected) {
        _titleLabel.textColor = [UIColor whiteColor];
    } else {
        _titleLabel.textColor = [UIColor themeGray2];
    }
}

@end
