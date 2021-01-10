//
//  FHDetailNewMediaHeaderScrollView.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/8/21.
//

#import "FHDetailNewMediaHeaderScrollView.h"
#import <Masonry/Masonry.h>
#import "FHCommonDefines.h"
#import "FHMultiMediaImageCell.h"
#import "FHMultiMediaPanoramaCell.h"
#import "FHVideoModel.h"
#import <FHHouseBase/FHBaseCollectionView.h>
#import "FHMultiMediaVRImageCell.h"
#import "FHHouseDetailHeaderMoreStateView.h"

static NSString * const k_VIDEOCELLID =       @"video_cell_id";
static NSString * const k_IMAGECELLID =       @"image_cell_id";
static NSString * const k_VRELLID =           @"vr_cell_id";
static NSString * const k_PANORAMACELLID =    @"panorama_cell_id";

@interface FHDetailNewMediaHeaderScrollView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *colletionView;
@property (nonatomic, strong) UIImageView *noDataImageView;
@property (nonatomic, strong) UIImage *placeHolder;
@property(nonatomic, copy) NSArray<FHMultiMediaItemModel *> *medias;

@property (nonatomic, assign) CGFloat beginX;
@property (nonatomic, strong) FHHouseDetailHeaderMoreStateView *headerMoreStateView;
@property (nonatomic, weak) FHMultiMediaVRImageCell *vrImageCell;
@end

@implementation FHDetailNewMediaHeaderScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = frame.size;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;

        self.colletionView = [[FHBaseCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        self.colletionView.backgroundColor = [UIColor whiteColor];
        self.colletionView.pagingEnabled = YES;
        self.colletionView.showsHorizontalScrollIndicator = NO;

        [self.colletionView registerClass:[FHMultiMediaImageCell class] forCellWithReuseIdentifier:k_IMAGECELLID];
        [self.colletionView registerClass:[FHMultiMediaVideoCell class] forCellWithReuseIdentifier:k_VIDEOCELLID];
        [self.colletionView registerClass:[FHMultiMediaVRImageCell class] forCellWithReuseIdentifier:k_VRELLID];
        [self.colletionView registerClass:[FHMultiMediaPanoramaCell class] forCellWithReuseIdentifier:k_PANORAMACELLID];

        self.colletionView.delegate = self;
        self.colletionView.dataSource = self;

        [self addSubview:self.colletionView];
        [self.colletionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];

        self.noDataImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.noDataImageView];
        self.noDataImageView.hidden = YES;
        [self.noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return self;
}

- (UIImage *)placeHolder {
    if (!_placeHolder) {
        _placeHolder = [UIImage imageNamed:@"default_image"];
    }
    return _placeHolder;
}

- (NSInteger)indexForIndexPath:(NSIndexPath *)indexPath {
    if (_medias.count <= 1 || self.closeInfinite) {
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

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if ([self.colletionView numberOfSections] > indexPath.section && [self.colletionView numberOfItemsInSection:indexPath.section] > indexPath.row) {
        UICollectionViewLayoutAttributes *cellAttributes = [self.colletionView layoutAttributesForItemAtIndexPath:indexPath];
        [self.colletionView setContentOffset:CGPointMake(cellAttributes.frame.origin.x, 0) animated:animated];
//        [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_medias.count <= 1 || self.closeInfinite) {
        return _medias.count;
    }
    return [_medias count] + 2;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexForIndexPath:indexPath];
    if (self.willDisplayCellForItemAtIndex) {
        self.willDisplayCellForItemAtIndex(index);
    }
    if ([cell isKindOfClass:[FHMultiMediaVRImageCell class]]) {
        if (self.vrImageCell != cell) {
            [((FHMultiMediaVRImageCell *)cell) resetVRLoadingAnimate];
        }
        self.vrImageCell = (FHMultiMediaVRImageCell *)cell;
    } else {
        self.vrImageCell = nil;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateState];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHMultiMediaBaseCell *cell = nil;
    NSInteger index = [self indexForIndexPath:indexPath];
    if (index < self.medias.count) {
        FHMultiMediaItemModel *model = _medias[index];
        if (model.mediaType == FHMultiMediaTypeVRPicture) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_VRELLID forIndexPath:indexPath];
        } else if (model.mediaType == FHMultiMediaTypeVideo) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_VIDEOCELLID forIndexPath:indexPath];
        } else if (model.mediaType == FHMultiMediaTypeBaiduPanorama) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_PANORAMACELLID forIndexPath:indexPath];
        } else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_IMAGECELLID forIndexPath:indexPath];
        }
        [cell updateViewModel:model];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.colletionView.frame.size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexForIndexPath:indexPath];
    if (self.didSelectiItemAtIndex) {
        self.didSelectiItemAtIndex(index);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateItemAndInfoLabel];
    //新房详情新增查看更多样式
    if (self.closeInfinite) {
        //调用更多样式state变化
        if (scrollView.contentOffset.x >= 52 + self.colletionView.frame.size.width * (self.medias.count - 1)) {
            self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateRelease;
        } else {
            self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateBegin;
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //房源详情 左滑 超过 52px，松手，进入图片列表页
    if (self.closeInfinite) {
        CGFloat xDeltaValue = scrollView.contentOffset.x - self.colletionView.frame.size.width * (self.medias.count - 1);
        if (xDeltaValue >= 52 || (xDeltaValue > 0 && velocity.x > 0.5) ) {
            if (self.goToPictureListFrom) {
                self.goToPictureListFrom(@"view_more_slide");
            }
        }
    }
}

- (void)updateState {
    NSInteger curPage = (NSInteger)(self.colletionView.contentOffset.x / self.colletionView.frame.size.width);
    
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
        if (indexPath && !_closeInfinite) {
            //循环滚动
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        [self.colletionView layoutIfNeeded];
    }
}

- (void)updateModel:(FHMultiMediaModel *)model {
    self.medias = model.medias;
    //如果新房详情 并且 isShowTopImageTab = true 取第一张图

    self.colletionView.alwaysBounceHorizontal = NO;
    self.colletionView.hidden = NO;
    self.noDataImageView.hidden = YES;
    if (self.closeInfinite) {
        self.colletionView.alwaysBounceHorizontal = YES;
        if (model.medias.count) {
            if (!self.headerMoreStateView) {
                self.headerMoreStateView = [[FHHouseDetailHeaderMoreStateView alloc] init];
                self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateBegin;
                [self.colletionView addSubview:self.headerMoreStateView];
            }
            self.headerMoreStateView.frame = CGRectMake(CGRectGetMaxX(self.colletionView.frame) * self.medias.count, 0, 52, CGRectGetHeight(self.colletionView.frame));
        } else {
            self.headerMoreStateView.hidden = YES;
        }
    }

    [self.colletionView reloadData];
    if (_medias.count > 0) {
        if (_medias.count > 1 && !self.closeInfinite) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    } else {
        self.colletionView.hidden = YES;
        self.noDataImageView.hidden = NO;
        if (!_noDataImageView.image) {
            _noDataImageView.image = self.placeHolder;
        }
    }
}


- (void)updateItemAndInfoLabel {
    CGFloat diff = ABS(self.colletionView.contentOffset.x - self.beginX);
    if (diff < self.colletionView.frame.size.width / 2) {
        return;
    }
    NSInteger curPage = (NSInteger)(self.colletionView.contentOffset.x / self.colletionView.frame.size.width);
    if (_medias.count > 1) {
        NSIndexPath *indexPath = nil;
        if (self.closeInfinite) {
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
            if (self.scrollToIndex) {
                self.scrollToIndex(index);
            }
        }
    }
}

- (NSInteger)getCurPagae {
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
    return curPage;
}

@end
