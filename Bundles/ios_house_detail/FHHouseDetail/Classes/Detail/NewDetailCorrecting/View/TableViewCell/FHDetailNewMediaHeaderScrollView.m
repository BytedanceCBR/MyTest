//
//  FHDetailNewMediaHeaderScrollView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/21.
//

#import "FHDetailNewMediaHeaderScrollView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "FHMultiMediaImageCell.h"
#import "FHMultiMediaVideoCell.h"
#import "FHVideoAndImageItemCorrectingView.h"
#import "FHVideoModel.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHMultiMediaVRImageCell.h"

#import "UIViewAdditions.h"
#import "FHHouseDetailHeaderMoreStateView.h"

#define k_VIDEOCELLID @"video_cell_id"
#define k_IMAGECELLID @"image_cell_id"
#define k_VRELLID     @"vr_cell_id"

@interface FHDetailNewMediaHeaderScrollView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *colletionView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *totalPagesLabel;
@property (nonatomic, strong) UIImageView *noDataImageView;
@property (nonatomic, strong) UIImage *placeHolder;
@property (nonatomic, strong) NSArray *medias;
@property (nonatomic, strong) FHVideoAndImageItemCorrectingView *itemView;   //图片户型的标签
@property (nonatomic, strong) NSMutableArray *itemIndexArray;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, assign) CGFloat beginX;
@property (nonatomic, strong) FHHouseDetailHeaderMoreStateView *headerMoreStateView;
@end

@implementation FHDetailNewMediaHeaderScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isShowenPictureVC = NO;
        [self initViews:frame];
//        [self initVideoVC];
        [self initConstaints];
    }
    return self;
}

- (void)initViews:(CGRect)frame {
    self.clipsToBounds = YES;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = frame.size;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;

    _colletionView = [[FHBaseCollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _colletionView.backgroundColor = [UIColor whiteColor];
    _colletionView.pagingEnabled = YES;
    _colletionView.showsHorizontalScrollIndicator = NO;

    [_colletionView registerClass:[FHMultiMediaImageCell class] forCellWithReuseIdentifier:k_IMAGECELLID];
    [_colletionView registerClass:[FHMultiMediaVideoCell class] forCellWithReuseIdentifier:k_VIDEOCELLID];
    [_colletionView registerClass:[FHMultiMediaVRImageCell class] forCellWithReuseIdentifier:k_VRELLID];

    _colletionView.delegate = self;
    _colletionView.dataSource = self;

    [self addSubview:_colletionView];

    _noDataImageView = [[UIImageView alloc] initWithFrame:frame];
    [self addSubview:_noDataImageView];
    _noDataImageView.hidden = YES;

    __weak typeof(self) wself = self;
    self.itemView = [[FHVideoAndImageItemCorrectingView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
    _itemView.hidden = YES;
    _itemView.selectedBlock = ^(NSInteger index, NSString *_Nonnull name, NSString *_Nonnull value) {
        [wself selectItem:index];
    };
    [self addSubview:_itemView];

    // 底部右侧序号信息标签
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.font = [UIFont themeFontRegular:12];
    _infoLabel.textColor = [UIColor whiteColor];
    _infoLabel.layer.cornerRadius = 11;
    _infoLabel.layer.masksToBounds = YES;

    [self addSubview:_infoLabel];

    _totalPagesLabel = [[UILabel alloc] init];
    _totalPagesLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    _totalPagesLabel.textAlignment = NSTextAlignmentCenter;
    _totalPagesLabel.font = [UIFont themeFontRegular:12];
    _totalPagesLabel.textColor = [UIColor whiteColor];
    _totalPagesLabel.layer.cornerRadius = 11;
    _totalPagesLabel.layer.masksToBounds = YES;
    [self addSubview:_totalPagesLabel];
}

//- (void)initVideoVC {
//    self.videoVC = [[FHVideoViewController alloc] init];
//    _videoVC.view.frame = self.bounds;
//}

- (FHVideoViewController *)videoVC {
    if (!_videoVC) {
        _videoVC = [[FHVideoViewController alloc] init];
        _videoVC.view.frame = self.bounds;
    }
    return _videoVC;
}

- (void)setTracerDic:(NSDictionary *)tracerDic {
    _tracerDic = tracerDic;
    self.videoVC.tracerDic = tracerDic;
}

- (void)initConstaints {

    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.colletionView.mas_bottom).offset(-35);//
        make.width.mas_equalTo(self.bounds.size.width);
        make.height.mas_equalTo(20);
    }];

    [self layoutIfNeeded];

    self.infoLabel.width = 44;
    self.infoLabel.height = 22;
    self.infoLabel.left = self.width - self.infoLabel.width - 15;
    self.infoLabel.bottom = self.bottom - 35;

    self.totalPagesLabel.width = 54;
    self.totalPagesLabel.height = 22;
    self.totalPagesLabel.left = self.width - self.totalPagesLabel.width - 15;
    self.totalPagesLabel.bottom = self.bottom - 35;

}

- (void)selectItem:(NSInteger)index {
    if (index < self.itemIndexArray.count) {
        NSInteger item = [self.itemIndexArray[index] integerValue] + 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

        NSInteger curPage = (NSInteger)(_colletionView.contentOffset.x / _colletionView.frame.size.width);
        if (_medias.count > 1) {
            if (curPage == 0) {
                curPage = _medias.count;
            } else if (curPage == _medias.count + 1) {
                curPage = 0;
            }
        }
        if (curPage == 0) {
            curPage = 1;
        }

        [self setInfoLabelText:[NSString stringWithFormat:@"%ld/%lu", (long)curPage, (unsigned long)self.medias.count]];

        if (self.delegate && [self.delegate respondsToSelector:@selector(selectItem:)]) {
            [self.delegate selectItem:self.itemArray[index]];
        }

        [self.colletionView layoutIfNeeded];
    }
}

- (UIImage *)placeHolder {
    if (!_placeHolder) {
        _placeHolder = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolder;
}

- (void)updateVideo:(FHMultiMediaItemModel *)model {
    FHVideoModel *videoModel = [[FHVideoModel alloc] init];
    videoModel.videoID = model.videoID;
    videoModel.coverImageUrl = model.imageUrl;
    videoModel.muted = NO;
    videoModel.repeated = NO;
    videoModel.isShowControl = NO;
    videoModel.isShowMiniSlider = YES;
    videoModel.isShowStartBtnWhenPause = YES;
    videoModel.vWidth = model.vWidth;
    videoModel.vHeight = model.vHeight;

    [self.videoVC updateData:videoModel];
}

- (NSInteger)indexForIndexPath:(NSIndexPath *)indexPath {
    if (_medias.count <= 1 || self.isShowTopImageTab) {
        return indexPath.item;
    }
    NSInteger index = indexPath.item - 1;
    if (index < 0) {
        //the last one
        index = _medias.count - 1;
    } else if (index >= _medias.count) {
        //the first one
        index = 0;
    }
    return index;
}

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated {
    if ([self.colletionView numberOfSections] > indexPath.section && [self.colletionView numberOfItemsInSection:indexPath.section] > indexPath.row) {
        [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_medias.count <= 1 || self.isShowTopImageTab) {
        return _medias.count;
    }
    return [_medias count] + 2;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexForIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(willDisplayCellForItemAtIndex:)]) {
        [self.delegate willDisplayCellForItemAtIndex:index];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHMultiMediaBaseCell *cell = nil;
    NSInteger index = [self indexForIndexPath:indexPath];
    if (index < self.medias.count) {
        FHMultiMediaItemModel *model = _medias[index];
        if (model.mediaType == FHMultiMediaTypeVideo) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_VIDEOCELLID forIndexPath:indexPath];
            model.playerView = self.videoVC.view;
            model.currentPlaybackTime = self.videoVC.currentPlaybackTime;
            if (!self.isShowenPictureVC) {
                [self updateVideo:model];
            }
        } else if (model.mediaType == FHMultiMediaTypeVRPicture) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_VRELLID forIndexPath:indexPath];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_IMAGECELLID forIndexPath:indexPath];
        }
        cell.isShowenPictureVC = self.isShowenPictureVC;

        [cell updateViewModel:model];
        if (!self.currentMediaCell && model.mediaType == FHMultiMediaTypeVideo) {
            self.currentMediaCell =  (FHMultiMediaVideoCell *)cell;
        }
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexForIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)]) {
        [self.delegate didSelectItemAtIndex:index];
    }
}

//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSInteger curPage = (NSInteger)(scrollView.contentOffset.x / scrollView.frame.size.width);
//    if (_medias.count > 1) {
//        if (curPage == 0) {
//            curPage = _medias.count;
//        }else if (curPage == _medias.count + 1){
//            curPage = 0;
//        }
//    }
//    if (curPage == 0 ){
//        curPage = 1;
//    }
//    self.infoLabel.text = [NSString stringWithFormat:@"%ld/%ld",curPage,self.medias.count];
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateItemAndInfoLabel];
    //新房详情新增查看更多样式
    if (self.isShowTopImageTab) {
        //调用更多样式state变化
        if (scrollView.contentOffset.x >= 52 + self.colletionView.frame.size.width * (self.medias.count - 1)) {
            self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateRelease;
        } else {
            self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateBegin;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateVideoState];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //房源详情 左滑 超过 52px，松手，进入图片列表页
    if (self.isShowTopImageTab) {
        if (scrollView.contentOffset.x >= 52 + self.colletionView.frame.size.width * (self.medias.count - 1)) {
            if ([self.delegate respondsToSelector:@selector(goToPictureListFrom:)]) {
                [self.delegate goToPictureListFrom:@"view_more_slide"];
            }
        }
    }
}

- (void)updateItemAndInfoLabel {
    CGFloat diff = ABS(self.colletionView.contentOffset.x - self.beginX);

    if (diff < self.colletionView.frame.size.width / 2 && !self.isShowenPictureVC) {
        return;
    }

    NSInteger curPage = (NSInteger)(self.colletionView.contentOffset.x / self.colletionView.frame.size.width);

    if (_medias.count > 1) {
        NSIndexPath *indexPath = nil;
        if (self.isShowTopImageTab) {
            curPage = curPage + 1;
        } else if (curPage == 0) {
            //show last page
            curPage = _medias.count;
            indexPath = [NSIndexPath indexPathForItem:_medias.count inSection:0];
        } else if (curPage == _medias.count + 1) {
            //show first page
            curPage = 1;
            indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        }

        NSInteger index = indexPath ? [self indexForIndexPath:indexPath] : (curPage - 1);
        if (index >= 0 && index < self.medias.count) {
            FHMultiMediaItemModel *itemModel = self.medias[index];
            NSString *groupType = itemModel.groupType;
            [self.itemView selectedItem:groupType];
            [self setInfoLabelText:[NSString stringWithFormat:@"%ld/%lu", (long)curPage, (unsigned long)self.medias.count]];
        }
    }
}

- (void)setInfoLabelText:(NSString *)text {
    self.infoLabel.text = text;
    [self.infoLabel sizeToFit];
    CGSize itemSize = [self.infoLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20)];
    CGFloat width = itemSize.width;
    width += 14.0;
    if (width < 43) {
        width = 43;
    }

    self.infoLabel.width = width;
    self.infoLabel.height = 22;
    self.infoLabel.left = self.width - self.infoLabel.width - 15;
}

- (void)updateVideoState {
    NSInteger curPage = (NSInteger)(self.colletionView.contentOffset.x / self.colletionView.frame.size.width);
//    NSInteger originCurPage = (NSInteger)(self.colletionView.contentOffset.x / self.colletionView.frame.size.width);

    if (_medias.count > 1) {
        NSIndexPath *indexPath = nil;
        if (curPage == 0) {
            //show last page
            curPage = _medias.count;
            indexPath = [NSIndexPath indexPathForItem:_medias.count inSection:0];
        } else if (curPage == _medias.count + 1) {
            //show first page
            curPage = 1;
            indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        }
        if (indexPath) {
            //循环滚动
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    }
}

- (void)updateModel:(FHMultiMediaModel *)model {
    self.medias = model.medias;
    //如果新房详情 并且 isShowTopImageTab = true 取第一张图
    self.colletionView.alwaysBounceHorizontal = NO;
    self.totalPagesLabel.hidden = YES;
    if (self.isShowTopImageTab) {
        self.infoLabel.hidden = YES;
        self.colletionView.alwaysBounceHorizontal = YES;
        if (model.medias.count) {
            NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:self.exposeImageNum];
            for (NSInteger i = 0; i < MIN(model.medias.count, self.exposeImageNum); i++) {
                [mArr addObject:model.medias[i]];
            }
            self.medias = mArr.copy;
            self.colletionView.hidden = NO;
            self.noDataImageView.hidden = YES;
            self.totalPagesLabel.hidden = NO;
            self.totalPagesLabel.text = [NSString stringWithFormat:@"共%lu张", (unsigned long)model.medias.count];
            if (!self.headerMoreStateView) {
                self.headerMoreStateView = [[FHHouseDetailHeaderMoreStateView alloc] init];
                self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateBegin;
                [self.colletionView addSubview:self.headerMoreStateView];
                self.headerMoreStateView.frame = CGRectMake(CGRectGetMaxX(self.colletionView.frame) * self.medias.count, 0, 52, CGRectGetHeight(self.colletionView.frame));
            }
        } else {
            self.infoLabel.hidden = YES;
            self.colletionView.hidden = YES;
            self.noDataImageView.hidden = NO;
            if (!_noDataImageView.image) {
                _noDataImageView.image = self.placeHolder;
            }
        }

        [self.colletionView reloadData];
    } else if (_medias.count > 0) {
        [self.colletionView reloadData];
        [self setInfoLabelText:[NSString stringWithFormat:@"%d/%lu", 1, (unsigned long)_medias.count]];
        self.infoLabel.hidden = NO;
        self.colletionView.hidden = NO;
        self.noDataImageView.hidden = YES;
        if (_medias.count > 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    } else {
        [self.colletionView reloadData];
        self.infoLabel.hidden = YES;
        self.colletionView.hidden = YES;
        self.noDataImageView.hidden = NO;
        if (!_noDataImageView.image) {
            _noDataImageView.image = self.placeHolder;
        }
    }

    self.itemArray = [NSMutableArray array];
    self.itemIndexArray = [NSMutableArray array];

    for (NSInteger i = 0; i < self.medias.count; i++) {
        FHMultiMediaItemModel *itemModel = self.medias[i];
        if (![_itemArray containsObject:itemModel.groupType]) {
            [_itemArray addObject:itemModel.groupType];
            [self.itemIndexArray addObject:@(i)];
        }
    }

    if (_itemArray.count > 1) {
        self.itemView.hidden = NO;
        self.itemView.titleArray = _itemArray;
        [self.itemView selectedItem:_itemArray[0]];

        CGFloat itemViewWidth = 0;
        if (_itemArray.count > 0) {
            itemViewWidth = 10 + 44 * _itemArray.count;
        }
    } else {
        self.itemView.hidden = YES;
    }
}



- (void)handleListMoreGesture:(UITapGestureRecognizer *)gensture {
    if ([self.delegate respondsToSelector:@selector(goToPictureListFrom:)]) {
        [self.delegate goToPictureListFrom:@"view_more"];
    }
}

@end
