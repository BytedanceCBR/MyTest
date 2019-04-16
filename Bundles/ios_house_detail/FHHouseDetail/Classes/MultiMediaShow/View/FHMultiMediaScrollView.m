//
//  FHMultiMediaScrollView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaScrollView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHMultiMediaImageCell.h"
#import "FHMultiMediaVideoCell.h"
#import "FHVideoAndImageItemView.h"

#define k_VIDEOCELLID @"video_cell_id"
#define k_IMAGECELLID @"image_cell_id"

@interface FHMultiMediaScrollView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *colletionView;
@property(nonatomic, strong) UILabel *infoLabel;
@property(nonatomic, strong) UIImageView *noDataImageView;
@property(nonatomic, strong) UIImage *placeHolder;
@property(nonatomic, strong) NSArray *medias;
@property(nonatomic, strong) FHVideoAndImageItemView *itemView;
@property(nonatomic, strong) NSMutableArray *itemIndexArray;

@end

@implementation FHMultiMediaScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstaints];
    }
    return self;
}

- (void)initViews {
    //    _pictureShowDict = [NSMutableDictionary dictionary];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, self.bounds.size.height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _colletionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.bounds.size.height) collectionViewLayout:layout];
    _colletionView.backgroundColor = [UIColor whiteColor];
    _colletionView.pagingEnabled = YES;
    _colletionView.showsHorizontalScrollIndicator = NO;
    
    [_colletionView registerClass:[FHMultiMediaImageCell class] forCellWithReuseIdentifier:k_IMAGECELLID];
    [_colletionView registerClass:[FHMultiMediaVideoCell class] forCellWithReuseIdentifier:k_VIDEOCELLID];
    
    _colletionView.delegate = self;
    _colletionView.dataSource = self;
    
    [self addSubview:_colletionView];
    
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.font = [UIFont themeFontRegular:12];
    _infoLabel.textColor = [UIColor whiteColor];
    _infoLabel.layer.cornerRadius = 10;
    _infoLabel.layer.masksToBounds = YES;
    
    [self addSubview:_infoLabel];
    
    __weak typeof(self) wself = self;
    self.itemView = [[FHVideoAndImageItemView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
    _itemView.hidden = YES;
    _itemView.selectedBlock = ^(NSInteger index, NSString * _Nonnull name, NSString * _Nonnull value) {
        [wself selectItem:index];
    };
    [self addSubview:_itemView];
    
    _noDataImageView = [[UIImageView alloc] init];
    [self addSubview:_noDataImageView];
    _noDataImageView.hidden = YES;
}

- (void)initConstaints {
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self).offset(-10);
    }];
    
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-10);
        make.width.mas_equalTo(self.bounds.size.width);
        make.height.mas_equalTo(20);
    }];
    
    [self.noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

- (void)selectItem:(NSInteger)index {
    if(index < self.itemIndexArray.count){
        NSInteger item = [self.itemIndexArray[index] integerValue] + 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

- (UIImage *)placeHolder {
    if (!_placeHolder) {
        _placeHolder = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolder;
}

- (NSInteger)indexForIndexPath:(NSIndexPath *)indexPath {
    if (_medias.count <= 1) {
        return indexPath.item;
    }
    NSInteger index = indexPath.item - 1;
    if (index < 0) {
        //the last one
        index = _medias.count - 1;
    }else if (index >= _medias.count){
        //the first one
        index = 0;
    }
    return index;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_medias.count <= 1) {
        return _medias.count;
    }
    return [_medias count]+2;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    //    NSInteger index = [self indexForIndexPath:indexPath];
    //    [self trackPictureShowWithIndex:index];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHMultiMediaBaseCell *cell = nil;
    NSInteger index = [self indexForIndexPath:indexPath];
    if(index < self.medias.count){
        FHMultiMediaItemModel *model = _medias[index];
        if(model.mediaType == FHMultiMediaTypeVideo){
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_VIDEOCELLID forIndexPath:indexPath];
        }else{
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_IMAGECELLID forIndexPath:indexPath];
        }
        [cell updateViewModel:model];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexForIndexPath:indexPath];
    if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)]){
        [self.delegate didSelectItemAtIndex:index];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger curPage = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (_medias.count > 1) {
        if (curPage == 0) {
            curPage = _medias.count;
        }else if (curPage == _medias.count + 1){
            curPage = 0;
        }
    }
    if (curPage == 0 ){
        curPage = 1;
    }
    self.infoLabel.text = [NSString stringWithFormat:@"%ld/%ld",curPage,self.medias.count];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger curPage = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (_medias.count > 1) {
        NSIndexPath *indexPath = nil;
        if (curPage == 0) {
            //show last page
            curPage = _medias.count;
            indexPath = [NSIndexPath indexPathForItem:_medias.count inSection:0];
        }else if (curPage == _medias.count + 1) {
            //show first page
            curPage = 1;
            indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        }
        if (indexPath) {
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        
        NSInteger index = indexPath ? [self indexForIndexPath:indexPath] : (curPage - 1);
        FHMultiMediaItemModel *itemModel = self.medias[index];
        NSString *groupType = itemModel.groupType;
        [self.itemView selectedItem:groupType];
        
        self.infoLabel.text = [NSString stringWithFormat:@"%ld/%ld",curPage,self.medias.count];
    }
}


- (void)updateWithModel:(FHMultiMediaModel *)model {
    self.medias = model.medias;
    [self.colletionView reloadData];
    
    if (_medias.count > 0) {
        self.infoLabel.text = [NSString stringWithFormat:@"%d/%ld",1,_medias.count];
        self.infoLabel.hidden = NO;
        self.colletionView.hidden = NO;
        self.noDataImageView.hidden = YES;
        if (_medias.count > 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    }else{
        self.infoLabel.hidden = YES;
        self.colletionView.hidden = YES;
        self.noDataImageView.hidden = NO;
        if (!_noDataImageView.image) {
            _noDataImageView.image = [UIImage imageNamed:@"default_image"];
        }
    }
    
    NSMutableArray *itemArray = [NSMutableArray array];
    self.itemIndexArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.medias.count; i++) {
        FHMultiMediaItemModel *itemModel = self.medias[i];
        if(![itemArray containsObject:itemModel.groupType]){
            [itemArray addObject:itemModel.groupType];
            [self.itemIndexArray addObject:@(i)];
        }
    }
    
    if(itemArray.count > 1){
        self.itemView.hidden = NO;
        self.itemView.titleArray = itemArray;
        [self.itemView selectedItem:itemArray[0]];
        
        CGFloat itemViewWidth = 0;
        if(itemArray.count > 0){
            itemViewWidth = 44 * itemArray.count + 10 * (itemArray.count - 1);
        }
        
        [self.itemView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(itemViewWidth);
        }];
    }else{
        self.itemView.hidden = YES;
    }
}

@end


