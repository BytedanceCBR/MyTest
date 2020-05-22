//
//  FHMultiMediaCorrectingScrollView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaCorrectingScrollView.h"
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
#import "FHDetailHeaderTitleView.h"
#import "UIViewAdditions.h"
#import "FHHouseDetailHeaderMoreStateView.h"

#define k_VIDEOCELLID @"video_cell_id"
#define k_IMAGECELLID @"image_cell_id"
#define k_VRELLID @"vr_cell_id"

@interface FHMultiMediaCorrectingScrollView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *colletionView;
@property(nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *listMoreView;
@property(nonatomic, strong) UIImageView *noDataImageView;
@property(nonatomic, strong) UIImage *placeHolder;
@property(nonatomic, strong) NSArray *medias;
@property(nonatomic, strong) FHVideoAndImageItemCorrectingView *itemView;   //图片户型的标签
@property(nonatomic, strong) FHDetailHeaderTitleView *titleView;            //头图下面的标题栏
@property(nonatomic, strong) NSMutableArray *itemIndexArray;
@property(nonatomic, strong) NSMutableArray *itemArray;
@property(nonatomic, strong) UICollectionViewCell *lastCell;
@property(nonatomic, strong) FHMultiMediaVideoCell *firstVideoCell;
@property(nonatomic, weak) FHMultiMediaVRImageCell *firstVRCell;
@property(nonatomic, assign) CGFloat beginX;
@property(nonatomic, strong) UIView *bottomBannerView;
@property(nonatomic, strong) UIView *bottomGradientView;
@property (nonatomic, strong) FHHouseDetailHeaderMoreStateView *headerMoreStateView;
@end

@implementation FHMultiMediaCorrectingScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isShowenPictureVC = NO;
        [self initViews];
//        [self initVideoVC];
        [self initConstaints];
    }
    return self;
}

- (void)initViews {
    self.clipsToBounds = YES;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, self.bounds.size.height);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    _colletionView = [[FHBaseCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 281/375) collectionViewLayout:layout];
    _colletionView.backgroundColor = [UIColor whiteColor];
    _colletionView.pagingEnabled = YES;
    _colletionView.showsHorizontalScrollIndicator = NO;
    
    [_colletionView registerClass:[FHMultiMediaImageCell class] forCellWithReuseIdentifier:k_IMAGECELLID];
    [_colletionView registerClass:[FHMultiMediaVideoCell class] forCellWithReuseIdentifier:k_VIDEOCELLID];
    [_colletionView registerClass:[FHMultiMediaVRImageCell class] forCellWithReuseIdentifier:k_VRELLID];

    _colletionView.delegate = self;
    _colletionView.dataSource = self;
    
    [self addSubview:_colletionView];
    
    // 底部渐变层
    [self addSubview:self.bottomGradientView];
    // 底部banner按钮
    [self addSubview:self.bottomBannerView];
    
    _noDataImageView = [[UIImageView alloc] init];
    [self addSubview:_noDataImageView];
    _noDataImageView.hidden = YES;
        
    _titleView = [[FHDetailHeaderTitleView alloc]init];
    [self addSubview:_titleView];
    
    __weak typeof(self) wself = self;
    self.itemView = [[FHVideoAndImageItemCorrectingView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
    _itemView.hidden = YES;
    _itemView.selectedBlock = ^(NSInteger index, NSString * _Nonnull name, NSString * _Nonnull value) {
        [wself selectItem:index];
    };
    [self addSubview:_itemView];
    

    // 底部右侧序号信息标签
    _infoLabel = [[UILabel alloc] init];
    _infoLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.font = [UIFont themeFontRegular:14];
    _infoLabel.textColor = [UIColor whiteColor];
    _infoLabel.layer.cornerRadius = 10;
    _infoLabel.layer.masksToBounds = YES;
    
    [self addSubview:_infoLabel];
}

//- (void)initVideoVC {
//    self.videoVC = [[FHVideoViewController alloc] init];
//    _videoVC.view.frame = self.bounds;
//}
- (UIView *)bottomBannerView {
    if(!_bottomBannerView) {
        
        CGFloat aspect = 375.0 / 65;
        CGFloat height = self.bounds.size.width / aspect;
        CGRect frame = CGRectMake(0, self.bounds.size.height - height, self.bounds.size.width, height);

        UIImageView *bannerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_header_bottom_banner"]];
        CGFloat bannerAspect = 336.0 / 30;
        CGFloat bannerWidth = frame.size.width - 40;
        CGFloat bannerHeight = bannerWidth / bannerAspect;
        CGFloat originX = (frame.size.width - bannerWidth) / 2.0;
        CGFloat originY = (frame.size.height - 6 - bannerHeight);
        bannerImageView.frame = CGRectMake(originX, originY, bannerWidth, bannerHeight);
        
        _bottomBannerView = [[UIView alloc] initWithFrame:frame];
        [_bottomBannerView addSubview:bannerImageView];
        
        // 初始时隐藏，数据更新时跟据flag决定是否显示
        _bottomBannerView.hidden = YES;
    }
    return _bottomBannerView;
}


-(UIView *)bottomGradientView {
    if(!_bottomGradientView){
        
        CGFloat aspect = 375.0 / 25;
        CGFloat width = SCREEN_WIDTH;
        
        CGFloat height = round(width / aspect + 0.5);
//        height -= round([UIScreen mainScreen].bounds.size.width / 375.0f * 30 + 0.5);
        CGRect frame = CGRectMake(0, 0, width, height);
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = frame;
        gradientLayer.colors = @[
                                 (__bridge id)[UIColor colorWithWhite:1 alpha:0].CGColor,
                                 (__bridge id)[UIColor themeGray7].CGColor
                                 ];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 0.9);
        
        _bottomGradientView = [[UIView alloc] initWithFrame:frame];
        [_bottomGradientView.layer addSublayer:gradientLayer];
    }
    return _bottomGradientView;
}

- (FHVideoViewController *)videoVC {
    if(!_videoVC){
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
    [self.noDataImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];


    //CGFloat minus = round([UIScreen mainScreen].bounds.size.width / 375.0f * 30 + 0.5);
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.top.equalTo(self.colletionView.mas_bottom).offset(-41);
    }];
    [self.bottomGradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.colletionView);
        make.height.mas_equalTo(self.bottomGradientView.frame.size.height);
    }];
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.titleView.mas_top).offset(5);//
        make.width.mas_equalTo(self.bounds.size.width);
        make.height.mas_equalTo(20);
    }];
    
    [self layoutIfNeeded];
    
    self.infoLabel.width = 44;
    self.infoLabel.height = 20;
    self.infoLabel.left = self.width - self.infoLabel.width - 16;
    self.infoLabel.bottom = self.titleView.top + 5;
}

- (void)selectItem:(NSInteger)index {
    if(index < self.itemIndexArray.count){
        NSInteger item = [self.itemIndexArray[index] integerValue] + 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        NSInteger curPage = (NSInteger)(_colletionView.contentOffset.x / _colletionView.frame.size.width);
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
      
        [self setInfoLabelText:[NSString stringWithFormat:@"%ld/%ld",curPage,self.medias.count]];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(selectItem:)]){
            [self.delegate selectItem:self.itemArray[index]];
        }
        
        [self.colletionView layoutIfNeeded];
        UICollectionViewCell *currentCell = [self.colletionView cellForItemAtIndexPath:indexPath];
        if (index == 0) {
            self.currentMediaCell = (FHMultiMediaVideoCell *)currentCell;
        }
        
        if([_lastCell isKindOfClass:[FHMultiMediaVideoCell class]] && self.videoVC.playbackState == TTVPlaybackState_Playing){
            [self.videoVC pause];
        }

//        if([currentCell isKindOfClass:[FHMultiMediaVideoCell class]] && self.videoVC.playbackState == TTVPlaybackState_Paused){
//            [self.videoVC play];
//        }
        self.lastCell = currentCell;
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

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated {
    if ([self.colletionView numberOfSections] > indexPath.section && [self.colletionView numberOfItemsInSection:indexPath.section] > indexPath.row) {
        [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
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
    NSInteger index = [self indexForIndexPath:indexPath];
    if(self.delegate && [self.delegate respondsToSelector:@selector(willDisplayCellForItemAtIndex:)]){
        [self.delegate willDisplayCellForItemAtIndex:index];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHMultiMediaBaseCell *cell = nil;
    NSInteger index = [self indexForIndexPath:indexPath];
    if(index < self.medias.count){
        FHMultiMediaItemModel *model = _medias[index];
        if(model.mediaType == FHMultiMediaTypeVideo){
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_VIDEOCELLID forIndexPath:indexPath];
            model.playerView = self.videoVC.view;
            model.currentPlaybackTime = self.videoVC.currentPlaybackTime;
            if (!self.isShowenPictureVC) {
                [self updateVideo:model];
            }
        }else if(model.mediaType == FHMultiMediaTypeVRPicture){
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_VRELLID forIndexPath:indexPath];
            self.firstVRCell = (FHMultiMediaVRImageCell*)cell;
        }else{
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:k_IMAGECELLID forIndexPath:indexPath];
        }
        cell.isShowenPictureVC = self.isShowenPictureVC;
        
        [cell updateViewModel:model];
        
        if(!self.lastCell){
            self.lastCell = cell;
        }
        
        if(!self.currentMediaCell && model.mediaType == FHMultiMediaTypeVideo){
            self.currentMediaCell =  (FHMultiMediaVideoCell*)cell;
        }
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = [self indexForIndexPath:indexPath];
    if(self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)]){
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
        if (scrollView.contentOffset.x >= 52) {
            self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateRelease;
        } else {
            self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateBegin;
        }
    }
    if (scrollView == self.colletionView) {
        self.listMoreView.frame = CGRectMake(CGRectGetWidth(self.frame) - 74 - 15 - scrollView.contentOffset.x, CGRectGetMaxY(self.colletionView.frame) - 36 - 65, 74, 65);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateVideoState];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //房源详情 左滑 超过 52px，松手，进入图片列表页
    if (self.isShowTopImageTab) {
        if (scrollView.contentOffset.x >= 52) {
            if ([self.delegate respondsToSelector:@selector(goToPictureList)]) {
                [self.delegate goToPictureList];
            }
        }
    }
}

- (void)updateItemAndInfoLabel {
    int diff = abs(self.colletionView.contentOffset.x - self.beginX);
    
    if(diff < self.colletionView.frame.size.width/2 && !self.isShowenPictureVC){
        return;
    }
    
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
        
        NSInteger index = indexPath ? [self indexForIndexPath:indexPath] : (curPage - 1);
        if (index >= 0 && index < self.medias.count) {
            FHMultiMediaItemModel *itemModel = self.medias[index];
            NSString *groupType = itemModel.groupType;
            [self.itemView selectedItem:groupType];
            [self setInfoLabelText:[NSString stringWithFormat:@"%ld/%ld",curPage,self.medias.count]];
        }
    }
}

- (void)setInfoLabelText:(NSString *)text {
    self.infoLabel.text = text;
    [self.infoLabel sizeToFit];
    CGSize itemSize = [self.infoLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20)];
    CGFloat width = itemSize.width;
    width += 14.0;
    if (width < 44) {
        width = 44;
    }
    
    self.infoLabel.width = width;
    self.infoLabel.left = self.width - self.infoLabel.width - 16;
}

- (void)updateVideoState {
    NSInteger curPage = (NSInteger)(self.colletionView.contentOffset.x / self.colletionView.frame.size.width);
    NSInteger originCurPage = (NSInteger)(self.colletionView.contentOffset.x / self.colletionView.frame.size.width);
    
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
            //循环滚动
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        
        NSInteger index = indexPath ? [self indexForIndexPath:indexPath] : (curPage - 1);
        
        if(!indexPath){
            indexPath = [NSIndexPath indexPathForItem:originCurPage inSection:0];
        }
        //视频控制
        [self.colletionView layoutIfNeeded];
        UICollectionViewCell *currentCell = [self.colletionView cellForItemAtIndexPath:indexPath];
        if (index == 0) {
            self.currentMediaCell = (FHMultiMediaVideoCell *)currentCell;
        }
        
        if(currentCell != _lastCell) {
            if (!self.isShowenPictureVC) {
                if(_lastCell && [_lastCell isKindOfClass:[FHMultiMediaVideoCell class]] && self.videoVC.playbackState == TTVPlaybackState_Playing){
                    [self.videoVC pause];
                }
                
//                if([currentCell isKindOfClass:[FHMultiMediaVideoCell class]] && self.videoVC.playbackState == TTVideoEnginePlaybackStatePaused){
//                    [self.videoVC play];
//                }
            }
            self.lastCell = currentCell;
        }
    }
}

- (void)setBaseViewModel:(FHHouseDetailBaseViewModel *)baseViewModel {
    _baseViewModel = baseViewModel;
    self.titleView.baseViewModel = baseViewModel;
}

- (void)updateModel:(FHMultiMediaModel *)model withTitleModel:(FHDetailHouseTitleModel *)titleModel{
    self.medias = model.medias;
    
    self.titleView.model = titleModel;
    if (_medias.count > 0) {
        [self setInfoLabelText:[NSString stringWithFormat:@"%d/%ld",1,_medias.count]];
        self.infoLabel.hidden = NO;
        self.colletionView.hidden = NO;
        self.noDataImageView.hidden = YES;
        if (_medias.count > 1) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            [self.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        //        [self.infoLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        //            make.bottom.equalTo(self).offset(-10 + yOffset);
        //        }];
    }else{
        self.infoLabel.hidden = YES;
        self.colletionView.hidden = YES;
        self.noDataImageView.hidden = NO;
        if (!_noDataImageView.image) {
            _noDataImageView.image = [UIImage imageNamed:@"default_image"];
        }
    }
    //如果新房详情 并且 isShowTopImageTab = true 取第一张图
    self.colletionView.alwaysBounceHorizontal = NO;
    if (titleModel.housetype == FHHouseTypeNewHouse && self.isShowTopImageTab) {
        self.infoLabel.hidden = YES;
        self.colletionView.alwaysBounceHorizontal = YES;
        if (model.medias.count) {
            self.medias = @[model.medias.firstObject];
        }
        if (!self.headerMoreStateView) {
            self.headerMoreStateView = [[FHHouseDetailHeaderMoreStateView alloc] init];
            self.headerMoreStateView.moreState = FHHouseDetailHeaderMoreStateBegin;
            [self.colletionView addSubview:self.headerMoreStateView];
            self.headerMoreStateView.frame = CGRectMake(CGRectGetMaxX(self.colletionView.frame), 0, 52, CGRectGetHeight(self.colletionView.frame));
        }
        if (!self.listMoreView) {
            self.listMoreView = [[UIView alloc] init];
            self.listMoreView.frame = CGRectMake(CGRectGetWidth(self.frame) - 74 - 15, CGRectGetMaxY(self.colletionView.frame) - 36 - 65, 74, 65);
            self.listMoreView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
            self.listMoreView.layer.masksToBounds = YES;
            self.listMoreView.layer.cornerRadius = 10;
            [self addSubview:self.listMoreView];
            
            UILabel *countLabel = [[UILabel alloc] init];
            countLabel.font = [UIFont themeFontMedium:16];
            countLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
            countLabel.textAlignment = NSTextAlignmentCenter;
            countLabel.text = [NSString stringWithFormat:@"+%d",model.medias.count];
            [self.listMoreView addSubview:countLabel];
            [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.listMoreView);
                make.top.mas_equalTo(12);
            }];
            
            UILabel *moreLabel = [[UILabel alloc] init];
            moreLabel.font = [UIFont themeFontRegular:12];
            moreLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
            moreLabel.textAlignment = NSTextAlignmentCenter;
            moreLabel.text = @"查看更多";
            [self.listMoreView addSubview:moreLabel];
            [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.listMoreView);
                make.bottom.mas_equalTo(-12);
            }];
            [self.listMoreView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleListMoreGesture:)]];
        }
    }
    [self.colletionView reloadData];
    
//    BOOL isShowBottomBannerView = model.isShowSkyEyeLogo;
//    self.bottomBannerView.hidden = !isShowBottomBannerView;
//    if(isShowBottomBannerView && [self.delegate respondsToSelector:@selector(bottomBannerViewDidShow)]) {
//        [self.delegate bottomBannerViewDidShow];
//    }
//    CGFloat topOffset = 82;
//    if (titleModel.advantage.length > 0 && titleModel.businessTag.length > 0) {
//        topOffset -= 40;
//    }
//    [self.titleView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self);
//        make.top.equalTo(self.colletionView.mas_bottom).offset(-topOffset);
//    }];
    
    self.itemArray = [NSMutableArray array];
    self.itemIndexArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.medias.count; i++) {
        FHMultiMediaItemModel *itemModel = self.medias[i];
        if(![_itemArray containsObject:itemModel.groupType]){
            [_itemArray addObject:itemModel.groupType];
            [self.itemIndexArray addObject:@(i)];
        }
    }
    
    if(_itemArray.count > 1){
        self.itemView.hidden = NO;
        self.itemView.titleArray = _itemArray;
        [self.itemView selectedItem:_itemArray[0]];
        
        CGFloat itemViewWidth = 0;
        if(_itemArray.count > 0){
            itemViewWidth = 10 + 44 * _itemArray.count;
        }
        
//        [self.itemView mas_updateConstraints:^(MASConstraintMaker *make) {
////            make.width.mas_equalTo(itemViewWidth);
//            make.bottom.equalTo(self).offset(yOffset);
//        }];
    }else{
        self.itemView.hidden = YES;
    }
    
    
}

- (void)checkVRLoadingAnimate
{
    if (self.firstVRCell) {
        [self.firstVRCell checkVRLoadingAnimate];
    }
}

- (void)handleListMoreGesture:(UITapGestureRecognizer *)gensture {
    if ([self.delegate respondsToSelector:@selector(goToPictureList)]) {
        [self.delegate goToPictureList];
    }
}

@end


