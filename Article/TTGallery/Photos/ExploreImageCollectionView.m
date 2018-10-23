//
//  TTImageCollectionView.m
//  Article
//
//  Created by SunJiangting on 15/7/23.
//
//

#import "ExploreImageCollectionView.h"
#import "STStringTokenizer.h"
#import "TTPhotoNativeDetailView.h"
#import "TTPhotoDetailViewController.h"
#import <objc/runtime.h>

#import "TTImageView.h"
#import "SSImpressionManager.h"
#import "NewsUserSettingManager.h"

#import "TTLabelTextHelper.h"
#import "TTURLUtils.h"
#import "TTAdManagerProtocol.h"
#import "TTRoute.h"
#import "TTDeviceHelper.h"

#import "TTStringHelper.h"
#import "TTThemeManager.h"


#import "TTPhotoSingleSearchWordCell.h"
#import "TTPhotoMultiSearchWordsView.h"
#import "TTPhotoSearchWordModel.h"

#import "TTPhotoDetailAdNewCollectionViewCell.h"

#import "TTServiceCenter.h"
#import "TTPhotoDetailCellHelper.h"
#import "SSCommonLogic.h"
#import <TTPlatformBaseLib/TTIconFontDefine.h>
#import "UIImageview+BDTSource.h"

#pragma mark - ExploreImageCollectionViewCell

@interface ExploreImageCollectionViewCell ()
@property(nonatomic, strong) TTShowImageView *imageScrollView;
@end

@implementation ExploreImageCollectionViewCell

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)prepareForReuse {
    self.imageScrollView.left = 0;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageScrollView = [[TTShowImageView alloc] initWithFrame:self.contentView.bounds];
        self.imageScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageScrollView.backgroundColor = [UIColor clearColor];
        self.imageScrollView.centerY = self.contentView.centerY;
        [self.contentView addSubview:self.imageScrollView];
        
//        // 根据UI要求，新增黑色渐变背景色
//        self.blackShadowView = [[UIView alloc] initWithFrame:self.bounds];
//        self.blackShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.blackShadowView.userInteractionEnabled = NO;
//        self.blackShadowView.backgroundColor = [UIColor blackColor];
//        self.blackShadowView.alpha = 0;
//        [self.contentView addSubview:self.blackShadowView];

    }
    return self;
}

-(void)refreshWithData:(id)data WithContainView:(UIView *)containView WithCollectionView:(UICollectionView *)collectionView WithIndexPath:(NSIndexPath *)indexPath WithImageScrollViewDelegate:(id<TTShowImageViewDelegate>)delegate WithRefreshBlock:(TTPhotoDetailCellBlock)block{
    
    if (data && [data isKindOfClass:[ExploreImageSubjectModel class]]) {
        
        [self setSubjectModel:data];
    }
    
    if (delegate && [delegate conformsToProtocol:@protocol(TTShowImageViewDelegate)]) {
        self.imageScrollView.delegate = delegate;
    }
}


- (void)ScrollViewDidScrollView:(UIScrollView *)scrollView ScrollDirection:(TTPhotoDetailCellScrollDirection)scrollDirection WithScrollPersent:(CGFloat)persent WithContainView:(UIView *)containView WithScrollBlock:(TTPhotoDetailCellBlock)block{
 
    if (scrollDirection == TTPhotoDetailCellScrollDirection_Front) {
        
        [self refreshBlackOpaqueWithPersent: - persent];
        [self refreshRightDistanceWithPersent:1- fabs(persent)];
    }
    else if (scrollDirection == TTPhotoDetailCellScrollDirection_Current){
        
        [self refreshBlackOpaqueWithPersent: 1 - fabs(persent)];
        if (persent > 0) {
            [self refreshRightDistanceWithPersent:fabs(persent)];
        }
    }
    else if (scrollDirection == TTPhotoDetailCellScrollDirection_BackFoward){
        [self refreshBlackOpaqueWithPersent: persent];
        [self refreshRightDistanceWithPersent:0];
    }
}

- (void)setSubjectModel:(ExploreImageSubjectModel *)subjectModel {
    _subjectModel = subjectModel;
    [self.imageScrollView resetZoom];
    self.imageScrollView.imageInfosModel = subjectModel.imageModel;
}


- (void)refreshBlackOpaqueWithPersent:(CGFloat)persent
{
    if (persent > 1) {
        persent = 1;
    }
    else if (persent < 0) {
        persent = 0;
    }
    self.alpha = 0.8 * persent + 0.2;
}

- (void)refreshRightDistanceWithPersent:(CGFloat)persent
{
    if (persent > 1) {
        persent = 1;
    }
    else if (persent < 0) {
        persent = 0;
    }
    
    self.imageScrollView.right = self.contentView.right - 20 * persent;
}
@end


#pragma mark -
#pragma mark - TTImageRecommendItemCell

@interface TTImageRecommendItemCell : UICollectionViewCell
@property (nonatomic, strong) Article *article;
- (void)setupDataSourceWithArticle:(Article *)article;
@end

static CGFloat const kImageSideRatio  = 0.654f;
static CGFloat const kLabelTopPadding = 6.0f;

#define _IS_iPad          ([TTDeviceHelper isPadDevice])
#define _IS_iPhone6_OR_6P_OR_X ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXDevice])

NS_INLINE CGFloat TextFontSize() {
    if (_IS_iPhone6_OR_6P_OR_X) {
        return 14.0f;
    } else if (_IS_iPad) {
        return 18.0f;
    }
    return 12.0f;
}

NS_INLINE CGFloat MaxHeightOfLabel() {
    if (_IS_iPhone6_OR_6P_OR_X) {
        return 34.0f;
    } else if (_IS_iPad) {
        return 43.0f;
    }
    return 29.0f;
}

@implementation TTImageRecommendItemCell
{
    TTImageView *_imgView;
    UILabel     *_titleLbl;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Image View
        _imgView = [[TTImageView alloc] initWithFrame:CGRectZero];
        // 根据UI要求，去掉图集夜间模式
        _imgView.enableNightCover = NO;
        _imgView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _imgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_imgView];
        
        // Title Label
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLbl.font = [UIFont systemFontOfSize:TextFontSize()];
        _titleLbl.textColor = [UIColor tt_defaultColorForKey:[TTDeviceHelper isPadDevice] ? kColorText8 : kColorText9];
        _titleLbl.numberOfLines = 2;
        _titleLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_titleLbl];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    _imgView.imageView.image = nil;
    _titleLbl.text = @"";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat imgWidth = CGRectGetWidth(self.contentView.frame);
    _imgView.frame = CGRectMake(0, 0, imgWidth, imgWidth * kImageSideRatio);
    _titleLbl.frame = CGRectMake(CGRectGetMinX(_imgView.frame) + 8, CGRectGetMaxY(_imgView.frame) + kLabelTopPadding, imgWidth - 8.0f - 3.0f, 0);
    [_titleLbl sizeToFit];
}

- (void)setupDataSourceWithArticle:(Article *)article
{
    TTImageInfosModel *imgInfoModel = [article listMiddleImageModel];
    _titleLbl.text = article.title;
    [_imgView setImageWithModel:imgInfoModel placeholderImage:nil];
    // iOS 8下调用，改变方向时文字位置会改变，需重新布局
    [self setNeedsLayout];
}

@end

#pragma mark - ExploreCollectionView


@implementation TTImageRecommendCell
{
    UICollectionView *_imageRecommendCollectionView;
    UIView           *_blackShadowView;
    UIImageView      *_bottomMaskImgView;
    NSArray          *_articleArray;
    NSArray          *_searchWordsArray;
    TTPhotoMultiSearchWordsView           *_multiSearchWordsView;
}

static NSString * const kTTImageRecommendItemCellIdentifier = @"kTTImageRecommendItemCellIdentifier";
static NSString * const kTTImageRecommendOneSearchWordCellIdentifier = @"kTTImageRecommendOneSearchWordCellIdentifier";

#define kImgPadding  ([TTDeviceHelper isPadDevice] ? 20.0f : 3.0f)
#define kLineSpace   ([TTDeviceHelper isPadDevice] ? 40.0f : 14.0f)

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Collection View
        _imageRecommendCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self flowLayout]];
        _imageRecommendCollectionView.backgroundColor = [UIColor clearColor];
        _imageRecommendCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageRecommendCollectionView.delegate = self;
        _imageRecommendCollectionView.dataSource = self;
        [_imageRecommendCollectionView registerClass:[TTImageRecommendItemCell class] forCellWithReuseIdentifier:kTTImageRecommendItemCellIdentifier];
        [_imageRecommendCollectionView registerClass:[TTPhotoSingleSearchWordCell class] forCellWithReuseIdentifier:kTTImageRecommendOneSearchWordCellIdentifier];
        [self.contentView addSubview:_imageRecommendCollectionView];
        
        // night mask View
        // 根据UI要求，去掉图集夜间模式
        /*
        _blackShadowView = [[UIView alloc] initWithFrame:self.bounds];
        _blackShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blackShadowView.userInteractionEnabled = NO;
        _blackShadowView.backgroundColor = [[[TTThemeManager sharedInstance_tt] defaultColorForKey:kColorBackground5] colorWithAlphaComponent:0.5];
        _blackShadowView.hidden = ([TTThemeManager sharedInstance_tt].currentMode == TTThemeModeDay);
        [self.contentView addSubview:_blackShadowView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_themedChangedNotification:) name:SSResourceManagerThemeModeChangedNotification object:nil];
         */
        
        ///...
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object: nil];
    }
    return self;
}

-(void)refreshWithData:(id)data WithContainView:(UIView *)containView WithCollectionView:(UICollectionView *)collectionView WithIndexPath:(NSIndexPath *)indexPath WithImageScrollViewDelegate:(id<TTShowImageViewDelegate>)delegate WithRefreshBlock:(TTPhotoDetailCellBlock)block{
    
    ExploreImageCollectionView *containImageCollectionView = nil;
    if (containView && [containView isKindOfClass:[ExploreImageCollectionView class]]) {
        containImageCollectionView = (ExploreImageCollectionView *)containView;
        [self setContentTopInset:containImageCollectionView.contentInset.top];
        [self setupImageInfo:containImageCollectionView.recommendImageInfoArray andSearchWords:containImageCollectionView.recommendSearchWordsArray];
        [self setSourceArticle:containImageCollectionView.sourceArticle];
        self.scrollDelegate = containImageCollectionView.cellScrolldelegate;
        
        if(![SSCommonLogic isNewFeedImpressionEnabled] || [TTDeviceHelper OSVersionNumber] < 8.f) {
            [self impressionStart4ImageRecommend];
        }
    }
}


- (UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = kLineSpace;
    flowLayout.minimumInteritemSpacing = kImgPadding;
    flowLayout.itemSize = [self itemSize];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 40.f, 0);
    
    return flowLayout;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self resizeUI];
    [_imageRecommendCollectionView.collectionViewLayout invalidateLayout];
}

- (void)resizeUI
{
    // resize collection view
    NSInteger itemCount = _articleArray.count;
    NSInteger rows;
    if (![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        rows = (itemCount + 2) / 3;
    }
    else {
        rows = itemCount / 2 + itemCount % 2;
    }
    
    BOOL needShowMultiSearchWordsView = [self p_needShowMultiSearchWordsView];
    
    UICollectionViewFlowLayout *flowLaout = (UICollectionViewFlowLayout *)_imageRecommendCollectionView.collectionViewLayout;
    CGFloat contentHeight = ([self itemSize].height + flowLaout.minimumLineSpacing) * rows - flowLaout.minimumLineSpacing + flowLaout.sectionInset.bottom;
    
    if (needShowMultiSearchWordsView){
        contentHeight += [_multiSearchWordsView maxHeight];
    }
    CGFloat availableHeight = CGRectGetHeight(self.contentView.frame) - _contentTopInset;
    
    CGFloat sidePadding = [TTUIResponderHelper paddingForViewWidth:CGRectGetWidth(self.contentView.frame)];
    CGFloat collectionViewWith = CGRectGetWidth(self.contentView.frame) - sidePadding * 2;
    
    if (contentHeight > availableHeight) {
        
        _imageRecommendCollectionView.frame = CGRectMake(sidePadding, 0, collectionViewWith, CGRectGetHeight(self.contentView.frame));
        if (needShowMultiSearchWordsView){
            _multiSearchWordsView.frame = CGRectMake(sidePadding, _contentTopInset, collectionViewWith, [_multiSearchWordsView maxHeight]);
            _imageRecommendCollectionView.contentInset = UIEdgeInsetsMake(_contentTopInset + _multiSearchWordsView.height, 0, 0, 0);
            _imageRecommendCollectionView.contentOffset = CGPointMake(0, -(_contentTopInset + _multiSearchWordsView.height));
        }
        else{
            _imageRecommendCollectionView.contentInset = UIEdgeInsetsMake(_contentTopInset, 0, 0, 0);
            _imageRecommendCollectionView.contentOffset = CGPointMake(0, -_contentTopInset);
        }
        
        if (!_bottomMaskImgView) {
            _bottomMaskImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"shadow_down_ablum"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch]];
        }
        [self.contentView addSubview:_bottomMaskImgView];
        
    } else {
        
        _imageRecommendCollectionView.contentInset = UIEdgeInsetsZero;
        if (needShowMultiSearchWordsView){
            _multiSearchWordsView.frame = CGRectMake(sidePadding, self.contentView.center.y + _contentTopInset / 2 - contentHeight / 2, collectionViewWith, [_multiSearchWordsView maxHeight]);
            _imageRecommendCollectionView.frame = CGRectMake(sidePadding, _multiSearchWordsView.bottom, collectionViewWith, contentHeight - _multiSearchWordsView.height);
        }
        else{
            _imageRecommendCollectionView.frame = CGRectMake(0, 0, collectionViewWith, contentHeight);
            _imageRecommendCollectionView.center = CGPointMake(self.contentView.center.x,
                                                           self.contentView.center.y + _contentTopInset / 2);
        }
        [_bottomMaskImgView removeFromSuperview];
    }
    
    _bottomMaskImgView.frame = CGRectMake(0, CGRectGetHeight(self.contentView.frame) - 120.0f,
                                          CGRectGetWidth(self.contentView.frame), 120.0f);
}

- (CGSize)itemSize
{
    CGFloat viewWidth = CGRectGetWidth(self.contentView.frame);
    CGFloat itemWidth;
    if (![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        itemWidth = ((viewWidth - [TTUIResponderHelper paddingForViewWidth:viewWidth]*2 - kImgPadding*2)/3);
    }
    else {
        itemWidth = ((viewWidth - [TTUIResponderHelper paddingForViewWidth:viewWidth]*2 - kImgPadding)/2);
    }
    CGFloat itemHeight = (kImageSideRatio * itemWidth) + kLabelTopPadding + MaxHeightOfLabel();
    
    return CGSizeMake(itemWidth, itemHeight);
}

- (void)setupImageInfo:(NSArray *)imageInfoArray
{
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:imageInfoArray.count];
    [imageInfoArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull imgInfoDic, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemArray addObject:[imgInfoDic valueForKey:@"article"]];
    }];
    
    _articleArray = itemArray;
    
}

- (void)setupSearchWordsArray:(NSArray *)searchWordsArray{
    _searchWordsArray = [searchWordsArray copy];
    // 判断是否需要加上多个的搜索词
    if([self p_needShowMultiSearchWordsView]){
        [self p_buildMultiSearchWordsView];
    }

}

- (void)setupImageInfo:(NSArray *)imageInfoArray andSearchWords:(NSArray *)searchWordsArray{
    [self setupImageInfo:imageInfoArray];
    [self setupSearchWordsArray:searchWordsArray];
    [self resizeUI];
}

/*
- (void)_themedChangedNotification:(NSNotification *)notification {
    _blackShadowView.hidden = ([TTThemeManager sharedInstance_tt].currentMode == TTThemeModeDay);
}
 */

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification
{
    [_imageRecommendCollectionView reloadData];
}

/**
 *  判断相关图集最后总共显示多少个cell
 */
- (NSInteger)numberOfItemsForCollectionView{
    if (![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && [TTDeviceHelper OSVersionNumber] >= 8.f) {
        NSString *openURLStr = [(Article *)_articleArray.lastObject openURL];
        if (![[TTURLUtils hostForURL:[TTStringHelper URLWithURLString:openURLStr]] isEqualToString:@"detail"]) {
            return _articleArray.count - 1;
        }
    }
    return _articleArray.count;
}

#pragma mark - Impression

- (void)impressionStart4ImageRecommend
{
    [self recordImpression4VisibleItemsWithStatus:SSImpressionStatusRecording];
}

- (void)impressionEnd4ImageRecommend
{
    [self recordImpression4VisibleItemsWithStatus:SSImpressionStatusEnd];
}

- (void)recordImpression4VisibleItemsWithStatus:(SSImpressionStatus)status
{
    if (_articleArray.count <= 0) {
        return;
    }
    
    [_imageRecommendCollectionView.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        /* 显示单个搜索词的时候，相当于把原有最后的那个给替换掉了*/
        if([self p_shouldShowSingleSearchWordViewAtIndexPath:indexPath]){
            return;
        }
        Article *article = _articleArray[indexPath.row];
        [self recordImpressionWithRelatedArticleGroupModel:article.groupModel
                                          impressionStatus:status];
    }];
}

- (void)recordImpressionWithRelatedArticleGroupModel:(TTGroupModel *)rGroupModel impressionStatus:(SSImpressionStatus)status
{
    NSString *groupId = rGroupModel.groupID;
    NSString *itemId  = rGroupModel.itemID;
    
    if (isEmptyString(groupId) || isEmptyString(itemId)) {
        return;
    }
    
    NSString *keyName = [NSString stringWithFormat:@"%@_%@", _sourceArticle.groupModel.groupID, _sourceArticle.groupModel.itemID];
    NSString *itemID = [NSString stringWithFormat:@"%@_%@", groupId, itemId];
    NSDictionary *extraDict = @{@"item_id":     itemId,
                                @"aggr_type":   @(rGroupModel.aggrType)
                                };
    
    [[SSImpressionManager shareInstance] recordImageRecommendImpressionWithKeyName:keyName
                                                                            status:status
                                                                            itemID:itemID
                                                                          userInfo:@{@"extra":extraDict}];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && [TTDeviceHelper OSVersionNumber] >= 8.f) {
        NSString *openURLStr = [(Article *)_articleArray.lastObject openURL];
        if (![[TTURLUtils hostForURL:[TTStringHelper URLWithURLString:openURLStr]] isEqualToString:@"detail"]) {
            return _articleArray.count - 1;
        }
    }
    return _articleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //相关图集出搜索词，并且显示单个tag的时候
    if([self p_shouldShowSingleSearchWordViewAtIndexPath:indexPath]){
        TTPhotoSingleSearchWordCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTTImageRecommendOneSearchWordCellIdentifier forIndexPath:indexPath];
        [itemCell setSearchWordItem:_searchWordsArray[0]];
        return itemCell != nil ? itemCell : [[UICollectionViewCell alloc] init];
    }
    
    TTImageRecommendItemCell *itemCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTTImageRecommendItemCellIdentifier forIndexPath:indexPath];

    Article *currArticle = _articleArray[indexPath.row];
    
    if(![SSCommonLogic isNewFeedImpressionEnabled] || [TTDeviceHelper OSVersionNumber] < 8.f) {
        // impression
        [self recordImpressionWithRelatedArticleGroupModel:currArticle.groupModel
                                          impressionStatus:SSImpressionStatusRecording];
    }
    if (![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        NSString *openURLStr = [(Article *)_articleArray[indexPath.row] openURL];
        //针对iOS7下非文章相关图集转屏产生crash的适配：不给cell设置数据源
        //https://www.fabric.io/news/ios/apps/com.ss.iphone.article.news/issues/56ff17a4ffcdc0425057db85
        if ([[TTURLUtils hostForURL:[TTStringHelper URLWithURLString:openURLStr]] isEqualToString:@"detail"]) {
            [itemCell setupDataSourceWithArticle:currArticle];
        }
    }
    else {
        [itemCell setupDataSourceWithArticle:currArticle];
    }
    return itemCell!=nil ? itemCell : [[UICollectionViewCell alloc] init];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
     //相关图集出搜索词，并且显示单个tag的时候
    if([self p_shouldShowSingleSearchWordViewAtIndexPath:indexPath]){
        return;
    }
    if ([SSCommonLogic isNewFeedImpressionEnabled] && [TTDeviceHelper OSVersionNumber] >= 8.f) {
        Article *currArticle = _articleArray[indexPath.row];
        // impression
        [self recordImpressionWithRelatedArticleGroupModel:currArticle.groupModel
                                              impressionStatus:SSImpressionStatusRecording];
    }
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //相关图集出搜索词，并且显示单个tag的时候
    if([self p_shouldShowSingleSearchWordViewAtIndexPath:indexPath]){
        NSString *openURLStr = ((TTPhotoSearchWordModel *)_searchWordsArray[0]).link;
        NSURL *openURL = [TTStringHelper URLWithURLString:openURLStr];
        if([[TTRoute sharedRoute] canOpenURL:openURL]){
            [[TTRoute sharedRoute] openURLByPushViewController:openURL];
        }
        wrapperTrackEvent(@"gallery1", @"click");
        return;
    }
    
    NSString *openURLStr = [(Article *)_articleArray[indexPath.row] openURL];
    NSURL *openURL = [TTStringHelper URLWithURLString:openURLStr];
    
    if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
        // 跳转
        BOOL goDetail = [[TTURLUtils hostForURL:[TTStringHelper URLWithURLString:openURLStr]] isEqualToString:@"detail"];
        //iPhone横屏相关图集页进入频道等非图集详情页时，强制转为竖屏
        if (![TTDeviceHelper isPadDevice] && !goDetail &&
            UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            return;
        }
        
        // 统计
        NSDictionary *queryItems = [TTURLUtils queryItemsForURL:openURL];
        TTPhotoNativeDetailView *detailView = (TTPhotoNativeDetailView *)[self ss_nextResponderWithClass:[TTPhotoNativeDetailView class]];
        if (detailView) {
             [self sendEvent4ImageRecommendClick:queryItems];
        }
             
        
        // impression
        [self impressionEnd4ImageRecommend];
        
        NSMutableDictionary *pageCondition = [NSMutableDictionary new];
        
        if (![SSCommonLogic appGalleryTileSwitchOn]  && [SSCommonLogic appGallerySlideOutSwitchOn]) {
            [pageCondition setValue:@(0) forKey:@"animated"];
        }
        
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openURLStr] userInfo:TTRouteUserInfoWithDict(pageCondition)];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self itemSize];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //相关图集出搜索词，并且显示单个tag的时候
    if([self p_shouldShowSingleSearchWordViewAtIndexPath:indexPath]){
        return;
    }
    // impression
    [self recordImpressionWithRelatedArticleGroupModel:[(Article *)_articleArray[indexPath.row] groupModel] impressionStatus:SSImpressionStatusEnd];
}

//copy from -[ExploreDetailManager sendEvent4ImageRecommendClick]
- (void)sendEvent4ImageRecommendClick:(NSDictionary *)queryItems {
    NSDictionary *base = @{@"category": @"umeng",
                           @"tag":      @"slide_detail",
                           @"label":    kEventLabel4ImageRecommendClicked,
                           //                           @"value":    [self currentArticle].uniqueID ? : @"",
                           //                           @"item_id":  [self currentArticle].groupModel.itemID ? : @""
                           };
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:base];
    
    if ([queryItems isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        // 当前文章的gid
        [extra setValue:@(self.sourceArticle.uniqueID) forKey:@"from_gid"];
        
        // 跳转目标的groupid
        NSString *gid = [queryItems tt_stringValueForKey:@"groupid"];
        [extra setValue:gid forKey:@"value"];
        
        // 跳转目标的item_id
        NSString *itemID = [queryItems tt_stringValueForKey:@"item_id"];
        [extra setValue:itemID forKey:@"item_id"];
        
        [data addEntriesFromDictionary:extra];
    }
    
    [TTTrackerWrapper eventData:data];
}
#pragma mark - 搜索词

- (BOOL)p_needShowMultiSearchWordsView{
    if([_searchWordsArray count] > 1){
        return YES;
    }
    return NO;
}

- (BOOL)p_needShowSingleSearchWordView{
//    if([_searchWordsArray count] == 1 && [(TTPhotoSearchWordModel *)_searchWordsArray[0] isValidSingleSearchWord]){
//        return YES;
//    }
    return NO;
}

- (BOOL)p_shouldShowSingleSearchWordViewAtIndexPath:(NSIndexPath *)indexPath{
    if([self p_needShowSingleSearchWordView] && indexPath.row == [self numberOfItemsForCollectionView] - 1){
        return YES;
    }
    return NO;
}

- (void)p_buildMultiSearchWordsView{
    if(!_multiSearchWordsView){
        _multiSearchWordsView = [[TTPhotoMultiSearchWordsView alloc] initWithFrame:CGRectZero];
        _multiSearchWordsView.searchWordsItems = _searchWordsArray;
        [self.contentView addSubview:_multiSearchWordsView];
    }
}

#pragma mark - UIScrollviewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([self p_needShowMultiSearchWordsView]){
        if(scrollView.contentOffset.y <= - scrollView.contentInset.top){
            _multiSearchWordsView.hidden = NO;
        }
        else{
            _multiSearchWordsView.hidden = YES;
        }
    }
 
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.scrollDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.scrollDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.scrollDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

@end

#pragma mark -
#pragma mark - ExploreCollectionView

@interface ExploreCollectionView : UICollectionView
@end

@implementation ExploreCollectionView

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        CGPoint velocity = [self.panGestureRecognizer velocityInView:self];
        CGFloat threshold = CGRectGetWidth(self.frame);
        if (velocity.x > 0 && self.contentOffset.x == 0 && [gestureRecognizer locationInView:self].x < threshold) {
            return NO;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

@end


#pragma mark -
#pragma mark - ExploreImageCollectionView

#define kImageCollectionTopPadding  ([TTDeviceHelper isPadDevice] ? 20.f : 10.f)
#define kSidePadding ([TTDeviceHelper isPadDevice] ? [TTUIResponderHelper paddingForViewWidth:CGRectGetWidth(self.collectionView.frame)] : 15.f)
#define kLabelPadding 4
#define kNextViewAlphaTime 0.1f
#define kNextViewFrameChangeTime 0.3f
#define kNextViewAlpha 1.f
#define kNextViewLayerAlpha 0.6f

const char kCornerShapLayerKey;

@interface ExploreImageCollectionView () <UIGestureRecognizerDelegate, TTAdManagerDelegate, UIScrollViewDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;


@property(nonatomic, strong) SSThemedLabel     *sequenceLabel;
@property(nonatomic, strong) SSThemedLabel      *originalLabel;
@property(nonatomic, strong) SSThemedLabel *carInfoLabel;
@property(nonatomic, strong) SSThemedLabel *carDetailLabel;
@property(nonatomic, strong) SSThemedView *carSection; //汽车区域
@property(nonatomic, strong) ExploreImageSubjectModel *currSubjectModel;
@property(nullable, nonatomic, copy) NSArray/*ExploreImageSubjectModel*/ *subjectModels;

@property (nonatomic, assign) BOOL natantVisible;
@property (nonatomic, assign) TTPhotoDetailImagePositon imagePostionType;
@property (nonatomic, assign) NSInteger currentPage;

//内容拖动展开的手势
@property (nonatomic, strong) UIPanGestureRecognizer *natantViewPanGesture;
@property (nonatomic, strong) UIView *natantContaintView;
@property (nonatomic, assign) CGRect natantViewOriginFrame;//natantView原本正确的位置
@property (nonatomic, assign) BOOL changeOrientation;//是否是因为转屏引起的layoutsubView，没办法识别第一次，但不影响使用

/// 这里用attributedString的原因 是因为 需要修改行间距
//@property(nonatomic, strong) NSDictionary      *abstractAttributes;

@end

static CGFloat toolbarHeight = 44.5f;

@implementation ExploreImageCollectionView
{
    BOOL _imageRecommendCellHadAppeared;
    BOOL _hasRefreshBarAppearanceWhenLoad;
    BOOL _isFirstShowAd;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        self.collectionView = [[ExploreCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        self.collectionView.pagingEnabled = YES;
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundView = nil;
        /// 对pad返回手势做单独处理
        self.collectionView.bounces = !([TTDeviceHelper isPadDevice]);
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.collectionView];
        self.collectionView.scrollsToTop = NO;
        
        if ([SSCommonLogic refectorPhotoAlbumControlEnable]) {
            [[TTPhotoDetailCellHelper shareManager] registerPhotoDetailCellWithCollectionView:self.collectionView];
            [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        }
        else {
             [self.collectionView registerClass:[ExploreImageCollectionViewCell class] forCellWithReuseIdentifier:@"Identifier"];
             [self.collectionView registerClass:[TTImageRecommendCell class] forCellWithReuseIdentifier:@"TTImageRecommendCellIdentifier"];
             [self.collectionView registerClass:[TTPhotoDetailAdCollectionCell class] forCellWithReuseIdentifier:@"TTPhotoDetailAdCollectionCell"];
             [self.collectionView registerClass:[TTPhotoDetailAdNewCollectionViewCell class] forCellWithReuseIdentifier:@"TTPhotoDetailAdNewCollectionViewCell"];
            [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        }
        
        
        
        self.natantView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
        _natantView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:.5f];
        _natantView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        self.natantContaintView = [UIView new];
        self.natantContaintView.backgroundColor = [UIColor clearColor];
        self.natantContaintView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - toolbarHeight);
        [self.natantContaintView addSubview:self.natantView];
        self.natantContaintView.clipsToBounds = YES;
        [self addSubview:self.natantContaintView];
        
        self.abstractView = [[SSThemedTextView alloc] initWithFrame:CGRectZero];
        self.abstractView.backgroundColor = [UIColor clearColor];
        self.abstractView.editable = NO;
        self.abstractView.selectable = NO;
        [self.natantView addSubview:self.abstractView];
        
        self.abstractView.scrollsToTop = NO;
        self.abstractView.clipsToBounds = YES;
        self.abstractView.contentInset = UIEdgeInsetsZero;
        self.abstractView.textContainerInset = UIEdgeInsetsZero;
        self.abstractView.textContainer.lineFragmentPadding = 0.0;
        self.abstractView.layoutManager.allowsNonContiguousLayout = NO;
        self.abstractView.userInteractionEnabled = NO;
        
        self.abstractView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.abstractView.textContainerInset = UIEdgeInsetsMake(0, kSidePadding, 0, kSidePadding);
        CGFloat indicatorSideInset = _IS_iPad ? (kSidePadding - 10) : 6;
        self.abstractView.scrollIndicatorInsets = UIEdgeInsetsMake(0, indicatorSideInset, 0, indicatorSideInset);
        self.abstractView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        self.sequenceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kSidePadding, 0, 36, 17)];
        self.sequenceLabel.autoresizingMask = UIViewAutoresizingNone;
        self.sequenceLabel.textAlignment = NSTextAlignmentLeft;
        self.sequenceLabel.shadowOffset = CGSizeMake(0, 1);
        [self.abstractView addSubview:self.sequenceLabel];
        
        self.originalLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 30, 16)];
        self.originalLabel.shadowOffset = CGSizeMake(0, 1);
        self.originalLabel.font = [UIFont systemFontOfSize:10];
        self.originalLabel.text = @"原创";
        self.originalLabel.textAlignment = NSTextAlignmentCenter;
        self.originalLabel.textColor = [UIColor tt_defaultColorForKey:kColorLine1];
        self.originalLabel.layer.cornerRadius = 4;
        self.originalLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel] * 2;
        self.originalLabel.layer.borderColor = [UIColor tt_defaultColorForKey:kColorLine1].CGColor;
        [self.originalLabel.layer setMasksToBounds:YES];
        [self.abstractView addSubview:self.originalLabel];
        
        CGFloat carSectionMargin = kSidePadding;
        self.carSection = [[SSThemedView alloc] initWithFrame:CGRectMake(carSectionMargin, 0, self.width - carSectionMargin - carSectionMargin, 40.f)];
        self.carSection.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.carSection addSubview:({
            SSThemedView *bottomSeparator = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.carSection.height, self.carSection.width, [TTDeviceHelper ssOnePixel])];
            bottomSeparator.alpha = 0.8;
            bottomSeparator.backgroundColorThemeKey = kColorLine8;
            bottomSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            bottomSeparator;
        })];
        self.carDetailLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 100, self.carSection.height)];
        self.carDetailLabel.textAlignment = NSTextAlignmentRight;
        self.carDetailLabel.textColorThemeKey = kColorText8;
        self.carDetailLabel.attributedText = ({
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"查看详情 " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]],
                                                                                                                     NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText8)}];
            [attr appendAttributedString:[[NSAttributedString alloc] initWithString:iconfont_right_arrow attributes:@{NSFontAttributeName: [UIFont fontWithName:@"iconfont" size:10.f], NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText8), NSBaselineOffsetAttributeName : @(2.f)}]];
            attr;
        });
        self.carDetailLabel.width = ceil([self.carDetailLabel.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 context:nil].size.width);
        self.carDetailLabel.right = self.carSection.width;
//        self.carDetailLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
        self.carDetailLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.carSection addSubview:self.carDetailLabel];
        
        self.carInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.carSection.height)];
        self.carInfoLabel.width = self.carDetailLabel.left - self.carInfoLabel.left - 30.f;
        self.carInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.carInfoLabel.textColorThemeKey = kColorText8;
        if ([[UIFont class] respondsToSelector:@selector(systemFontOfSize:weight:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            self.carInfoLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f] weight:UIFontWeightMedium];
#pragma clang diagnostic pop
        } else {
            self.carInfoLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
        }
        
        self.carInfoLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.carSection addGestureRecognizer:({
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(carLabelOnClicked:)];
            gesture;
        })];
        [self.natantView addSubview:self.carSection];
        [self.carSection addSubview:self.carInfoLabel];
        [self.carSection addSubview:self.carDetailLabel];
        //内容拖动初始化手势
        self.natantViewPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(natantViewPanGestureAction:)];
        [self.natantView addGestureRecognizer:self.natantViewPanGesture];
        //浏览推荐图集浮层
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        WeakSelf;
        if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbumAdNextViewWithFrame:WithClickBlock:)]) {
            self.nextView = [adManagerInstance photoAlbumAdNextViewWithFrame:CGRectMake(self.right-tt(122) , self.height-tt(131) , tt(122), tt(32)) WithClickBlock:^{
                [UIView animateWithDuration:kNextViewAlphaTime animations:^{
                    wself.nextView.alpha = 0;
                }];
                NSInteger count = [wself.collectionView numberOfItemsInSection:0];
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
                
                [wself.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            }];
        }
        
//        self.nextView = [[TTPhotoDetailAdCellNextView alloc] initWithFrame:CGRectMake(self.right-tt(122) , self.height-tt(131) , tt(122), tt(32)) clickBlock:^{
//            [UIView animateWithDuration:kNextViewAlphaTime animations:^{
//                wself.nextView.alpha = 0;
//            }];
//            NSInteger count = [wself.collectionView numberOfItemsInSection:0];
//            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:count-1 inSection:0];
//            
//            [wself.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
//            //-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView 结束滚动时候回调此方法
//        }];
        _isFirstShowAd = YES;
        self.nextView.alpha = kNextViewAlpha;
        [self setView:self.nextView corner:UIRectCornerTopLeft|UIRectCornerBottomLeft triangle:CGSizeMake(6, 6) withFillColor:nil withAlpha:kNextViewLayerAlpha];
        self.nextView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        if (self.nextView) {
            [self addSubview:self.nextView];
        }
        self.nextView.alpha = 0;
        self.nextView.userInteractionEnabled = NO;
        
        self.currentPage = 0;
        _natantVisible = YES;
        _imageRecommendCellHadAppeared = NO;
        _hasRefreshBarAppearanceWhenLoad = NO;
        [self setAdImageDelegate];
        [self addObservers];
    }
    return self;
}

//pan手势回调
static CGFloat preoffsety = 0;
static CGFloat maxUpLen = 50; //最大能够上升的值
static CGFloat maxDownLen = 30;
static CGFloat maxAnimationHeight = 154;//超过这个高度才做动画
- (void)natantViewPanGestureAction:(UIPanGestureRecognizer*)gesture{
    if (self.natantViewOriginFrame.size.height < maxAnimationHeight){
        //如果摘要的高度不够的话，那么直接返回
        //这里没有将手势禁用的目的是，为了让手指在摘要区域的时候，禁用原来的退出手势
        return;
    }
    UIGestureRecognizerState state = gesture.state;
    CGFloat offsety = [gesture translationInView:self.natantView].y;
    CGFloat velocityY = [gesture velocityInView:gesture.view].y / 2000;
    CGFloat offsetDis = offsety - preoffsety;
    preoffsety = offsety;
    if (offsety > 0){
        
        CGFloat downLine = self.natantViewOriginFrame.origin.y;
        CGFloat currPosY = self.natantView.frame.origin.y;
        CGFloat dis = currPosY - downLine;
        if (dis > 0){
            if (dis > maxDownLen){
                dis = maxDownLen;
            }
            offsetDis = offsetDis * (1 - (dis/maxDownLen)*0.99);
        }
    }else{
        
        CGFloat upLine = self.natantContaintView.height - self.natantViewOriginFrame.size.height;
        CGFloat currPosY = self.natantView.frame.origin.y;
        CGFloat dis = currPosY - upLine;
        if (dis < 0){
            dis = -dis;
            if (dis > maxUpLen){
                dis = maxUpLen;
            }
            offsetDis = offsetDis * (1 - (dis/maxUpLen)*0.99);
        }
    }
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            self.natantContaintView.top = 0;
            self.natantContaintView.height = CGRectGetHeight(self.bounds) - toolbarHeight;
            preoffsety = offsety;
            break;
        case UIGestureRecognizerStateChanged:
            self.natantView.center = CGPointMake(self.natantView.center.x, self.natantView.center.y + offsetDis);
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            if (offsety >= 0){
                [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:velocityY options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.natantView.top = self.natantViewOriginFrame.origin.y;
                } completion:^(BOOL finished) {
                    if (finished){
                        self.textViewOpen = NO;
                    }
                }];
            }else{
                [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:-velocityY options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.natantView.top = self.natantContaintView.height - self.natantViewOriginFrame.size.height;
                } completion:^(BOOL finished) {
                    if (finished){
                        self.textViewOpen = YES;
                    }
                }];
            }
        default:
            break;
    }
}

//设置代理，当adImage下载完成，回调
-(void)setAdImageDelegate
{
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_setDelegate:)]) {
         [adManagerInstance photoAlbum_setDelegate:self];
    }
   
}

//adImage下载完成，回调此方法
-(void)photoAlbum_downloadAdImageFinished
{
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_hasAd)]) {
        if ([adManagerInstance photoAlbum_hasAd]) {
            [self.collectionView reloadData];
        }
    }
}

- (void)carLabelOnClicked:(id)sender {
    if (isEmptyString(_currSubjectModel.carOpenURL)) {
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.sourceArticle.groupModel.groupID forKey:@"group_id"];
    [params setValue:@"page_detail_gallery_pic" forKey:@"obj_id"];
    [TTTracker eventV3:@"clk_event" params:params];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:_currSubjectModel.carOpenURL]];
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object: nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self removeObservers];
}

- (void)didMoveToWindow {
    BOOL isPhoneLandScape = ![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    BOOL toolBarVisible = _natantVisible && !isPhoneLandScape;
    [self adjustContenInsetWithToolBarVisible:toolBarVisible detailVC:self.viewController];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.natantView.width = self.width;
    // 处理横竖屏旋转时距左右间距的变化
    self.changeOrientation = !self.changeOrientation;
    [self updateNatantViewWithSubjectModel:_currSubjectModel];
    
    //始终self.nextView保持上下居中
    
    CGFloat nextViewOrignX;
    
    if (_isFirstShowAd) {
        nextViewOrignX = self.right;
    }
    else {
        nextViewOrignX = self.right - tt(122);
    }
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        self.nextView.frame = CGRectMake(nextViewOrignX, self.height - tt(62), tt(122), tt(32));
    }
    
    else {
        self.nextView.frame = CGRectMake(nextViewOrignX , self.height-tt(131) , tt(122), tt(32));
    }
    
    
    // 处理横竖屏旋转时Cell错位的问题
    NSArray *visibleItems = [_collectionView indexPathsForVisibleItems];
    if (visibleItems.count > 0) {
        [_collectionView.collectionViewLayout invalidateLayout];
        if (@available(iOS 11.0, *)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_collectionView reloadData];
                [self scrollToCurrentPageIfNeed];
            });
        } else {
            [self scrollToCurrentPageIfNeed];
        }
    }
    
    if (!_hasRefreshBarAppearanceWhenLoad) {
        [self doShowOrHideBarsAnimationWithOrientationChanged:YES];
        _hasRefreshBarAppearanceWhenLoad = YES;
    }
}

- (void)scrollToCurrentPageIfNeed
{
    if (self.currentPage >= 0 && self.currentPage < [self collectionView:self.collectionView numberOfItemsInSection:0]) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    }
}

- (void)setTextViewOpen:(BOOL)textViewOpen{
    _textViewOpen = textViewOpen;
    if(textViewOpen){
        CGFloat viewSizeHeight = self.natantViewOriginFrame.size.height;
        self.natantContaintView.top = CGRectGetHeight(self.bounds) - toolbarHeight - viewSizeHeight;
        self.natantContaintView.height = viewSizeHeight;
    }else{
        self.natantContaintView.top = self.natantViewOriginFrame.origin.y;
        self.natantContaintView.height = ceil(CGRectGetHeight(self.bounds) - toolbarHeight - self.natantContaintView.top) ;
    }
}

- (NSArray *)imageSubjectsFromArticle:(Article *)article {
    
    NSMutableArray *imageSubjects = [NSMutableArray arrayWithCapacity:2];
    [article.galleries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!SSIsEmptyDictionary(obj)) {
            ExploreImageSubjectModel *subjectModel = [[ExploreImageSubjectModel alloc] initWithDictionary:obj];
            subjectModel.isOriginal = [article.isOriginal boolValue];
            [imageSubjects addObject:subjectModel];
            
            if (article.galleryAdditional.count <= idx) {
                return;
            }
            
            NSDictionary *additional = article.galleryAdditional[idx];
            [self updateimageSubject:subjectModel withAdditional:additional];
        }
    }];
    
    return [NSArray arrayWithArray:imageSubjects];
}

- (void)updateimageSubject:(ExploreImageSubjectModel *)subjectModel withAdditional:(NSDictionary *)additional {
    if (![additional tt_boolValueForKey:@"has_info"]) {
        return;
    }
    
    NSArray *infos = [additional tt_arrayValueForKey:@"infos"];
    if (infos.count <= 0) {
        return;
    }
    
    NSDictionary *carInfo = infos[0];
    NSString *series_name = [carInfo tt_stringValueForKey:@"series_name"];
    NSString *price = [carInfo tt_stringValueForKey:@"price"];
    NSString *open_url = [carInfo tt_stringValueForKey:@"open_url"];
    
    if (isEmptyString(series_name) || isEmptyString(price) || isEmptyString(open_url)) {
        return;
    }
    
    subjectModel.carInfo = [NSString stringWithFormat:@"%@  %@", series_name, price];
    subjectModel.carOpenURL = open_url;
}

- (void)updateimageSubjectsFromArticle:(Article *)article {
    if (!self.subjectModels.count) {
        return;
    }
    
    [self.subjectModels enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (article.galleryAdditional.count <= idx) {
            return;
        }
        
        NSDictionary *additional = article.galleryAdditional[idx];
        [self updateimageSubject:obj withAdditional:additional];
    }];
    
    [self updateNatantViewWithSubjectModel:_currSubjectModel];
}

- (void)setSourceArticle:(Article *)sourceArticle {
    _sourceArticle = sourceArticle;
    NSArray *subjectModels = [self imageSubjectsFromArticle:sourceArticle];
    NSInteger total = subjectModels.count;
    [subjectModels enumerateObjectsUsingBlock:^(ExploreImageSubjectModel *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ExploreImageSubjectModel class]]) {
            obj.index = (idx + 1);
            obj.total = total;
        }
    }];
    _subjectModels = [subjectModels copy];
    [self.collectionView reloadData];
    self.currSubjectModel = _subjectModels.firstObject;
    [self updateNatantViewWithSubjectModel:_currSubjectModel];
}

-(void)setView:(UIView *)view corner:(UIRectCorner)cornerStyle triangle:(CGSize)size withFillColor:(UIColor *)fillColor withAlpha:(CGFloat)alpha
{
    CAShapeLayer *cornerImageLayer = objc_getAssociatedObject(view, &kCornerShapLayerKey);
    
    if (!cornerImageLayer) {
        //这种方式不会触发离屏渲染，其他加圆角方式会触发离屏渲染，严重影响帧率
        UIBezierPath *cornerImagePath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:cornerStyle cornerRadii:size];
        cornerImageLayer = [[CAShapeLayer alloc] init];
        cornerImageLayer.frame = view.bounds;
        cornerImageLayer.path = cornerImagePath.CGPath;
        objc_setAssociatedObject(view, &kCornerShapLayerKey, cornerImageLayer, OBJC_ASSOCIATION_ASSIGN);
        [view.layer insertSublayer:cornerImageLayer atIndex:0];
        view.backgroundColor = [UIColor clearColor];
        if (fillColor) {
            cornerImageLayer.fillColor = fillColor.CGColor;
        }
        cornerImageLayer.opacity = alpha;
        
    }else{
        cornerImageLayer.path = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:cornerStyle cornerRadii:size].CGPath;
        if (fillColor) {
            cornerImageLayer.fillColor = fillColor.CGColor;
        }
        cornerImageLayer.opacity = alpha;
    }
}

- (void)updateNatantViewWithSubjectModel:(ExploreImageSubjectModel *)subjectModel {
    
    CGFloat abstractFontSize = [NewsUserSettingManager fontSizeFromNormalSize:(_IS_iPad ? 18.f : 16.f) isWidescreen:NO];
    CGFloat lineHeight = _IS_iPad ? [NewsUserSettingManager fontSizeFromNormalSize:28.f isWidescreen:NO] : [NewsUserSettingManager fontSizeFromNormalSize:22.f isWidescreen:NO];
    
    CGFloat left = kSidePadding + self.tt_safeAreaInsets.left;
    NSInteger index, total;
    
    if (subjectModel.total > 1) {
        index = subjectModel.index;
        total = subjectModel.total;
        self.sequenceLabel.hidden = NO;
    } else {
        index = 0;
        total = 0;
        self.sequenceLabel.hidden = YES;
    }
    
    NSString *color = [[TTThemeManager sharedInstance_tt] rgbaDefalutThemeValueForKey:kColorLine1];
    if (!color) {
        color = @"e8e8e8";
    }
    
    NSString *sequence = [NSString stringWithFormat:@"<mark size=\"%@\" color=\"%@\">%@</mark><mark size=\"%@\" color=\"%@\">/%@</mark>", @(abstractFontSize), color, @(index).stringValue, @(12), color, @(total).stringValue];
    self.sequenceLabel.attributedText = [STStringTokenizer attributedStringWithMarkedString:sequence textAlignment:NSTextAlignmentLeft];
    self.carInfoLabel.text = subjectModel.carInfo;
    
    // resize labels
    [self.sequenceLabel sizeToFit];
    
    CGFloat sequenceLblWidth = CGRectGetWidth(self.sequenceLabel.frame);
    CGFloat sequenceLblHeight = lineHeight;
    
    self.sequenceLabel.frame = CGRectMake(left,
                                          [TTDeviceHelper isPadDevice]?4:2,
                                          sequenceLblWidth,
                                          sequenceLblHeight);

    if (!self.sequenceLabel.hidden) {
        left += sequenceLblWidth + kLabelPadding;
    }

    
    if (![TTDeviceHelper isPadDevice] && subjectModel.isOriginal) {
        self.originalLabel.frame = CGRectMake(left, kImageCollectionTopPadding, self.originalLabel.width, self.originalLabel.height);
        self.originalLabel.centerY = self.sequenceLabel.centerY;
        left = self.originalLabel.right + kLabelPadding;
        self.originalLabel.hidden = NO;
    } else {
        self.originalLabel.hidden = YES;
    }
    
    // 由于设置了首行缩进，如果文本中含有换行符，换行符之后的文本也会缩进，所以需要过滤掉文本中的换行符
    NSString *abstract = [[subjectModel.abstract componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    
    CGSize size = CGSizeZero;
    
    if (isEmptyString([abstract stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]])) {
    
        self.abstractView.attributedText = nil;
    } else {
        CGFloat firstLineIndent = left - kSidePadding - self.tt_safeAreaInsets.left;
        _abstractView.attributedText = [TTLabelTextHelper attributedStringWithString:abstract
                                                                            fontSize:abstractFontSize
                                                                          lineHeight:lineHeight
                                                                       lineBreakMode:NSLineBreakByWordWrapping isBoldFontStyle:NO
                                                                     firstLineIndent:firstLineIndent];
        if ([TTDeviceHelper OSVersionNumber] < 9.f){
            //fix 文本在iOS9 以下计算高度不准
            //其中一个case是 iPhone6P，字号为大的情况下显示一行多一个字，由于计算高度不准而被盖住的问题
            UIFont *font = [UIFont systemFontOfSize:abstractFontSize];
            CGFloat lineHeightMultiple = lineHeight / font.lineHeight;

            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentLeft;
            style.lineHeightMultiple = lineHeightMultiple;
            style.minimumLineHeight = lineHeight;
            style.maximumLineHeight = lineHeight;
            style.firstLineHeadIndent = firstLineIndent;

            NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:abstract];
            [textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [textStorage length])];
            [textStorage addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [textStorage length])];
            NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGRectGetWidth(self.frame) - kSidePadding * 2, CGFLOAT_MAX)];
            textContainer.lineFragmentPadding = 0.f;
            [layoutManager addTextContainer:textContainer];
            [textStorage addLayoutManager:layoutManager];
            size.height = [layoutManager usedRectForTextContainer:textContainer].size.height;
        }
        else{
            size.height = [TTLabelTextHelper heightOfText:abstract
                                             fontSize:abstractFontSize
                                             forWidth:(CGRectGetWidth(self.frame) - kSidePadding * 2 - self.tt_safeAreaInsets.left - self.tt_safeAreaInsets.right)
                                        forLineHeight:lineHeight
                         constraintToMaxNumberOfLines:7
                       firstLineIndent:firstLineIndent textAlignment:NSTextAlignmentLeft];
        }
    }
    
    CGFloat bottomPadding = [TTDeviceHelper isPadDevice] ? 20.f : 10.f;
    
    CGFloat abstractViewHeight = MAX(size.height, sequenceLblHeight);
    CGFloat heightExceptAbstract = kImageCollectionTopPadding + bottomPadding;
    CGFloat carSectionHeight = isEmptyString(self.carInfoLabel.text)? 0: self.carSection.height - 3.f;
    
    self.carSection.hidden = carSectionHeight == 0;
    if (!self.carSection.hidden) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:self.sourceArticle.groupModel.groupID forKey:@"group_id"];
        [params setValue:@"page_detail_gallery_pic" forKey:@"obj_id"];
        [TTTracker eventV3:@"show_event" params:params];
    }
    CGFloat maxNatantHeight = lineHeight * 7;
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        maxNatantHeight = lineHeight * 4;
    }
    CGFloat totalNatantHeight = heightExceptAbstract + size.height;
    
    if (totalNatantHeight > maxNatantHeight) {
        abstractViewHeight = maxNatantHeight - heightExceptAbstract;
    }
    
    if ([TTDeviceHelper isPadDevice]) {
        self.abstractView.textContainerInset = UIEdgeInsetsMake(0, kSidePadding, 0, kSidePadding);
        CGFloat indicatorSideInset = kSidePadding - 10;
        self.abstractView.scrollIndicatorInsets = UIEdgeInsetsMake(0, indicatorSideInset, 0, indicatorSideInset);
    }else{
        self.abstractView.textContainerInset = UIEdgeInsetsMake(0, kSidePadding + self.tt_safeAreaInsets.left, 0, kSidePadding + self.tt_safeAreaInsets.right);
        CGFloat indicatorSideInset = 6;
        self.abstractView.scrollIndicatorInsets = UIEdgeInsetsMake(0, indicatorSideInset, 0, indicatorSideInset);
    }
    
    CGFloat bottomInset = 0;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && self.tt_safeAreaInsets.bottom > 0){
        bottomInset = self.tt_safeAreaInsets.bottom - bottomPadding;
    }
    
    _abstractView.frame = CGRectMake(0, kImageCollectionTopPadding + carSectionHeight , CGRectGetWidth(_collectionView.frame), MAX(size.height, sequenceLblHeight) + bottomInset);
    
    CGFloat natantViewHeight = heightExceptAbstract + abstractViewHeight + carSectionHeight + bottomInset;
    TTPhotoDetailViewController *detailViewVC = (TTPhotoDetailViewController *)[self ss_nextResponderWithClass:[TTPhotoDetailViewController class]];

    [self setNatantViewFrameWithFrame:CGRectMake(0,
                                                 CGRectGetHeight(self.frame) - natantViewHeight - self.contentInset.bottom,
                                                 CGRectGetWidth(self.frame),
                                                 heightExceptAbstract + _abstractView.frame.size.height + carSectionHeight)
                            Animation:_textViewOpen];
    
    
    //横屏时候会造成摘要偏下，先注释掉
//    if (![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
//        _natantView.top += detailViewVC.toolbarView.height;
//    }
    
    if (![TTDeviceHelper isPadDevice] && [TTDeviceHelper OSVersionNumber] < 8.f) {
        detailViewVC.toolbarView.top = self.height - detailViewVC.toolbarView.height;
        detailViewVC.toolbarView.width = self.width;
    }
    
    self.abstractView.contentOffset = CGPointZero;
    _abstractView.textColor = [UIColor tt_defaultColorForKey:kColorLine1];
}

- (void)setNatantViewFrameWithFrame:(CGRect)frame Animation:(BOOL)animation{
    self.natantViewOriginFrame = frame;
    self.natantContaintView.width = CGRectGetWidth(frame);
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)){
        toolbarHeight = self.contentInset.bottom;
        maxAnimationHeight = 154;
    }else{
        toolbarHeight = 0;
        maxAnimationHeight = 88;
    }
    if (animation&&!self.changeOrientation){
        CGFloat dis = frame.origin.y - self.natantContaintView.frame.origin.y;
        if ([NSThread isMainThread]){
            [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.natantView.top += dis;
            } completion:^(BOOL finished) {
                if (finished){
                    self.textViewOpen = NO;
                }
            }];

        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.natantView.top += dis;
                } completion:^(BOOL finished) {
                    if (finished){
                        self.textViewOpen = NO;
                    }
                }];
            });
        }
    }else{
        self.changeOrientation = NO;
        self.natantContaintView.top = CGRectGetMinY(frame);
        self.natantContaintView.height = ceil(CGRectGetHeight(self.bounds) - toolbarHeight - self.natantContaintView.top);
        _natantView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height + 500);
        self.textViewOpen = NO;
    }
}

- (void)saveCurrentImage
{
    ExploreImageCollectionViewCell * cell = (ExploreImageCollectionViewCell *)[self.collectionView visibleCells].firstObject;
    [cell.imageScrollView saveImage];
}

#pragma mark - Notification

- (void)interfaceOrientationDidChange:(NSNotification *)notification
{
    //防止转屏通知广播影响之前层级的VC
    if (self.viewController.navigationController.topViewController != self.viewController) {
        return;
    }
    
    [self doShowOrHideBarsAnimationWithOrientationChanged:YES];
}

- (void)doShowOrHideBarsAnimationWithOrientationChanged:(BOOL)orientationChanged
{
    TTPhotoDetailViewController *detailViewVC = (TTPhotoDetailViewController *)[self ss_nextResponderWithClass:[TTPhotoDetailViewController class]];
    [self doAnimationForDetailViewController:detailViewVC withOrientationChanged:orientationChanged];
}

/**
 *  横屏时隐藏statusBar、toolBar和PGC按钮；点击时正常隐藏
 *
 *  @param detailView         图集详情页
 *  @param orientationChanged 是否是转屏
 */
- (void)doAnimationForDetailViewController:(TTPhotoDetailViewController *)detailViewVC withOrientationChanged:(BOOL)orientationChanged
{
    if (!orientationChanged) {
        _natantVisible = !_natantVisible;
        detailViewVC.topView.recomLabel.alpha = 0.f;
    }
    
    BOOL isPhoneLandScape = ![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    BOOL toolBarVisible = _natantVisible && !isPhoneLandScape;
    BOOL functionVisible = _natantVisible && !(self.imagePostionType == TTPhotoDetailImagePositon_Recom);
    BOOL topViewVisible = (_imagePostionType == TTPhotoDetailImagePositon_Recom) || _natantVisible;
    BOOL hasRefreshBarAppearanceWhenLoad = _hasRefreshBarAppearanceWhenLoad;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!_natantVisible withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    if (orientationChanged) {
        [self adjustContenInsetWithToolBarVisible:toolBarVisible detailVC:detailViewVC];
        //inset变化需要调整abstractview的位置
        [self updateNatantViewWithSubjectModel:_currSubjectModel];
    }
    
    CGFloat nextViewOrignX;
    if (_isFirstShowAd) {
        nextViewOrignX = self.right;
    }
    else {
        nextViewOrignX = self.right - tt(122);
    }
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        self.nextView.frame = CGRectMake(nextViewOrignX, self.height - tt(62), tt(122), tt(32));
    }
    
    else {
        self.nextView.frame = CGRectMake(nextViewOrignX , self.height-tt(131) , tt(122), tt(32));
    }
    
    void(^animations)(void) = ^{
        self.natantView.alpha = _natantVisible ? 1.f : 0.f;
        self.natantContaintView.alpha = _natantVisible ? 1.f : 0.f;
        detailViewVC.topView.alpha = topViewVisible ? 1.f : 0.f;
        detailViewVC.topView.functionView.alpha = functionVisible ? 1.f : 0.f;
        detailViewVC.toolbarView.alpha = toolBarVisible ? 1.f : 0.f;
        
    };
    
    void(^completion)(BOOL) = ^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        if (hasRefreshBarAppearanceWhenLoad && [self.delegate respondsToSelector:@selector(imageCollectionView:didChangeNatantVisible:)]) {
            [self.delegate imageCollectionView:self didChangeNatantVisible:_natantVisible];
        }
    };
    [UIView animateWithDuration:0.45 animations:animations completion:completion];
}

#pragma mark - Image Recommend

- (void)setupRecommendImageInfoArray:(NSArray *)recommendImageInfoArray
          andRecommendSearchWordsArray:(NSArray *)recommendSearchWordsArray{
    _recommendImageInfoArray = recommendImageInfoArray;
    _recommendSearchWordsArray = recommendSearchWordsArray;
    [self.collectionView reloadData];
}

- (void)adjustUIWhenScrollIntoImageRecommendCell
{
    TTPhotoDetailViewController *detailViewVC = (TTPhotoDetailViewController *)[self ss_nextResponderWithClass:[TTPhotoDetailViewController class]];
    
    if (self.imagePostionType == TTPhotoDetailImagePositon_Recom) {
        [self hideRelatedViewsOfImgDetailView:detailViewVC];
        if (!_natantVisible) {
            detailViewVC.topView.alpha = 1;
        }
    } else {
        if (_natantVisible) {
            [self hideRelatedViewsOfImgDetailView:detailViewVC];
        } else {
            detailViewVC.topView.alpha = 0;
        }
    }
}

- (void)hideRelatedViewsOfImgDetailView:(TTPhotoDetailViewController *)detailView
{
    CGFloat alpha = (self.imagePostionType == TTPhotoDetailImagePositon_NormalImage) ? 1.0f : 0.f;
    self.natantView.alpha = alpha;
    self.natantContaintView.alpha = alpha;
    BOOL functionViewVisable = _natantVisible && !(self.imagePostionType == TTPhotoDetailImagePositon_Recom);
    detailView.topView.functionView.alpha = functionViewVisable;
    if (self.imagePostionType == TTPhotoDetailImagePositon_Ad) {
        detailView.topView.functionView.alpha = 0;
    }
    [UIView animateWithDuration:.25f animations:^{
        detailView.topView.recomLabel.alpha = 0;
        detailView.topView.recomLabel.alpha = (self.imagePostionType == TTPhotoDetailImagePositon_Recom) ? 1 : 0;
    }];
}

- (void)sendEvent4ImageRecommendCellHadAppearedIfNeeded
{
    if (_imageRecommendCellHadAppeared) {
        return;
    }
    _imageRecommendCellHadAppeared = YES;
    
    TTPhotoNativeDetailView *detailView = (TTPhotoNativeDetailView *)[self ss_nextResponderWithClass:[TTPhotoNativeDetailView class]];
    if (detailView) {
        [self sendEvent4ImageRecommendShow];
    }
    
    
    if([_recommendSearchWordsArray count] > 1){
        wrapperTrackEvent(@"gallery2", @"show");
    }
    else if([_recommendSearchWordsArray count] == 1 && [(TTPhotoSearchWordModel *)_recommendSearchWordsArray[0] isValidSingleSearchWord]){
        wrapperTrackEvent(@"gallery1", @"show");
    }
}

//copy from: -[ExploreDetailManager sendEvent4ImageRecommendShow]
- (void)sendEvent4ImageRecommendShow {
    NSDictionary *data = @{@"category": @"umeng",
                           @"tag":      @"slide_detail",
                           @"label":    kEventLabel4ImageRecommendShow,
                           @"value":    @(self.sourceArticle.uniqueID) ? : @"",
                           @"item_id":  self.sourceArticle.groupModel.itemID ? : @""
                           };
    [TTTrackerWrapper eventData:data];
}
#pragma mark - Helper

- (void)adjustContenInsetWithToolBarVisible:(BOOL)toolBarVisible detailVC:(UIViewController *)detailVC{
    if (![detailVC isKindOfClass:[TTPhotoDetailViewController class]]) {
        return;
    }
    UIEdgeInsets inset = self.contentInset;
    inset.bottom = toolBarVisible ? ((TTPhotoDetailViewController *)detailVC).toolbarView.height : 0;
    self.contentInset = inset;
}

@end

#pragma mark - ExploreImageCollectionViewDelegate

@implementation ExploreImageCollectionView (ExploreImageCollectionViewDelegate)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.subjectModels.count == 0) {
        return 0;
    }
    
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_hasAd)]) {
        return self.subjectModels.count + [adManagerInstance photoAlbum_hasAd] + (self.recommendImageInfoArray?1:0);
    }
    else {
        return self.subjectModels.count + (self.recommendImageInfoArray?1:0);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     
    UICollectionViewCell *cell;
    NSInteger subjectCount = self.subjectModels.count;
    BOOL hasRecomImage = self.recommendImageInfoArray? YES:NO;
    
    BOOL hasPhotoDetailAd = NO;
    
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_hasAd)]) {
        hasPhotoDetailAd = [adManagerInstance photoAlbum_hasAd];
    }
    
    NSInteger ADIndex = hasPhotoDetailAd ? subjectCount : subjectCount - 1;
    NSInteger recommendIndex = hasRecomImage ? ADIndex + 1 : ADIndex;
    
    
    if ([SSCommonLogic refectorPhotoAlbumControlEnable]) {
        id collectionCell = nil;
        id data = nil;
        
        TTPhotDetailCellType cellType = TTPhotDetailCellType_None;
        
        if (indexPath.row < subjectCount) {
            
            cellType = TTPhotDetailCellType_Photo;
            data = [self.subjectModels objectAtIndex:indexPath.row];
        }
        else if (indexPath.row == ADIndex){
            
            if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_getCellDisplayType)]) {
                cellType = [adManagerInstance photoAlbum_getCellDisplayType];
            }
            data = nil;
        }
        
        else if (indexPath.row == recommendIndex){
            data = nil;
            cellType = TTPhotDetailCellType_Recommend;
        }
        
        collectionCell = [[TTPhotoDetailCellHelper shareManager] dequeueTableCellForcollectionView:collectionView ForCellType:cellType atIndexPath:indexPath];
        
        if (collectionCell && [collectionCell isKindOfClass:[UICollectionViewCell class]] && [collectionCell conformsToProtocol:@protocol(TTPhotoDetailCellProtocol)]) {
            
            [collectionCell refreshWithData:data WithContainView:self WithCollectionView:collectionView WithIndexPath:indexPath WithImageScrollViewDelegate:self WithRefreshBlock:nil];
            
            if (indexPath.row == recommendIndex) {
                if(![SSCommonLogic isNewFeedImpressionEnabled] || [TTDeviceHelper OSVersionNumber] < 8.f) {
                    [self sendEvent4ImageRecommendCellHadAppearedIfNeeded];
                }
            }
        }
        
        return collectionCell!=nil ? collectionCell : [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    }
    
    else {
        if (indexPath.row < subjectCount) {
            //普通cell
            ExploreImageCollectionViewCell *currentCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Identifier" forIndexPath:indexPath];
            ExploreImageSubjectModel *subjectModel =  [self.subjectModels objectAtIndex:indexPath.row];
            currentCell.subjectModel = subjectModel;
            currentCell.imageScrollView.delegate = self;
            cell = currentCell;
        }
        else if (indexPath.row == ADIndex) {
            //adCell
    
            if ([adManagerInstance photoAlbum_getAdDisplayType] == TTPhotoDetailAdDisplayType_Default) {
    
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTPhotoDetailAdCollectionCell" forIndexPath:indexPath];
    
                [(TTPhotoDetailAdCollectionCell*)cell configurePhotoAdView];
                ((TTPhotoDetailAdCollectionCell*)cell).imageScrollView.delegate = self;
    
            }
            else {
                cell =  [collectionView dequeueReusableCellWithReuseIdentifier:@"TTPhotoDetailAdNewCollectionViewCell" forIndexPath:indexPath];
    
                 [(TTPhotoDetailAdNewCollectionViewCell *)cell configureAdPhotoView];
    
                [(TTPhotoDetailAdNewCollectionViewCell *)cell setImageScrollViewDelegate:self];
            }
        }
        else if (indexPath.row == recommendIndex) {
            //图集推荐cell
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTImageRecommendCellIdentifier" forIndexPath:indexPath];
            [(TTImageRecommendCell *)cell setContentTopInset:self.contentInset.top];
    
            [(TTImageRecommendCell *)cell setupImageInfo:self.recommendImageInfoArray andSearchWords:self.recommendSearchWordsArray];
            [(TTImageRecommendCell *)cell setSourceArticle:self.sourceArticle];
    
            ((TTImageRecommendCell *)cell).scrollDelegate = self.cellScrolldelegate;
            if(![SSCommonLogic isNewFeedImpressionEnabled] || [TTDeviceHelper OSVersionNumber] < 8.f) {
                [self sendEvent4ImageRecommendCellHadAppearedIfNeeded];
                // impression
                [(TTImageRecommendCell *)cell impressionStart4ImageRecommend];
            }
        }
        NSAssert(cell, @"UICollectionCell must not be nil");
        return cell!=nil ? cell : [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([SSCommonLogic isNewFeedImpressionEnabled] && [TTDeviceHelper OSVersionNumber] >= 8.f) {
        
        if ([cell isKindOfClass:[TTImageRecommendCell class]]) {
            [self sendEvent4ImageRecommendCellHadAppearedIfNeeded];
            // impression
            [(TTImageRecommendCell *)cell impressionStart4ImageRecommend];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (CGRectGetHeight(_abstractView.frame) < _abstractView.contentSize.height) {
        [_abstractView flashScrollIndicators];
    }
    
    // impression
    if ([cell isKindOfClass:[TTImageRecommendCell class]]) {
        [(TTImageRecommendCell *)cell impressionEnd4ImageRecommend];
    }
}

- (void)showImageViewOnceTap:(TTShowImageView *)imageView {
    //如果在ad图片上单击、并不隐藏上下视图
    if (self.imagePostionType == TTPhotoDetailImagePositon_Ad) {
        if ([self.delegate respondsToSelector:@selector(imageCollectionView:imagePositionType:tapOn:)]) {
            [self.delegate imageCollectionView:self imagePositionType:self.imagePostionType tapOn:YES];
        }
    }
    else
    {
        /// 也懒得一层一层传下去了，直接在这里隐藏了
        [self doShowOrHideBarsAnimationWithOrientationChanged:NO];
        if ([self.delegate respondsToSelector:@selector(imageCollectionView:imagePositionType:tapOn:)]) {
            [self.delegate imageCollectionView:self imagePositionType:self.imagePostionType tapOn:YES];
        }
    }
    
}


//在广告页手动滚动即隐藏nextView
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.imagePostionType == TTPhotoDetailImagePositon_Ad) {
        
        [UIView animateWithDuration:kNextViewAlphaTime animations:^{
            self.nextView.alpha = 0;
        }];
    }
}

//代码强制滚动回调此方法
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSUInteger page = 0;
    if (scrollView.width > 0) {
        page = floor(scrollView.contentOffset.x / scrollView.width);
    }
    
    
    BOOL hasPhotoDetailAd = NO;
    
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_hasAd)]) {
        hasPhotoDetailAd = [adManagerInstance photoAlbum_hasAd];
    }
    BOOL hasRecomImage = self.recommendImageInfoArray? YES:NO;
    NSInteger modelCount = self.subjectModels.count;
    
    if (scrollView == self.collectionView&&hasPhotoDetailAd == YES && hasRecomImage == YES && page == modelCount+1) {
        self.imagePostionType = TTPhotoDetailImagePositon_Recom;
        self.currSubjectModel = nil;
        [self adjustUIWhenScrollIntoImageRecommendCell];
        if (self.currentPage != page) {
            self.currentPage = page;
            if ([self.delegate respondsToSelector:@selector(imageCollectionView:didScrollImagePositionType:)]) {
                [self.delegate imageCollectionView:self didScrollImagePositionType:self.imagePostionType];
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // ExploreImageCollectionViewDelegate的回调需要在手势完成后触发，而不是Cell重用时
    if ([self.delegate respondsToSelector:@selector(imageCollectionView:didScrollToIndex:)]) {
        NSUInteger currentCellIndex = round(self.collectionView.contentOffset.x/self.size.width);
        if (!currentCellIndex) {
            currentCellIndex = 0;
        }
        [self.delegate imageCollectionView:self didScrollToIndex:currentCellIndex];
    }
    
    if (scrollView == self.collectionView) {
        CGFloat width = scrollView.width;
        NSUInteger page = 0;
        if (width > 0) {
            page = floor(scrollView.contentOffset.x / width);
        }
        
        BOOL hasRecomImage = self.recommendImageInfoArray? YES:NO;
        BOOL hasPhotoDetailAd = NO;
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_hasAd)]) {
            hasPhotoDetailAd = [adManagerInstance photoAlbum_hasAd];
        }
        
        NSInteger modelCount = self.subjectModels.count;
        //根据scroll滑动，修改Image的滑动位置
        if (hasPhotoDetailAd == YES && hasRecomImage == YES) {
            
            if (page < modelCount) {
                self.imagePostionType = TTPhotoDetailImagePositon_NormalImage;
            }
            else if (page == modelCount)
            {
                self.imagePostionType = TTPhotoDetailImagePositon_Ad;
            }
            else if (page == modelCount + 1)
            {
                self.imagePostionType = TTPhotoDetailImagePositon_Recom;
            }
        }
        else if (hasRecomImage == YES && hasPhotoDetailAd == NO)
        {
            if (page < modelCount) {
                self.imagePostionType = TTPhotoDetailImagePositon_NormalImage;
            }
            else
            {
                self.imagePostionType = TTPhotoDetailImagePositon_Recom;
            }
        }
        else if (hasRecomImage == NO && hasPhotoDetailAd == YES)
        {
            if (page < modelCount)
            {
                self.imagePostionType = TTPhotoDetailImagePositon_NormalImage;
            }
            else if (page == modelCount) {
                self.imagePostionType = TTPhotoDetailImagePositon_Ad;
            }
        }
        else
        {
            self.imagePostionType = TTPhotoDetailImagePositon_NormalImage;
        }
        
        //根据image的postion调整UI
        if (self.imagePostionType == TTPhotoDetailImagePositon_NormalImage) {
            if (page < self.subjectModels.count) {
                self.currSubjectModel = [self.subjectModels objectAtIndex:page];
                [self updateNatantViewWithSubjectModel:_currSubjectModel];
            }
            [UIView animateWithDuration:kNextViewAlphaTime animations:^{
                self.nextView.alpha = 0;
            }];
            [self adjustUIWhenScrollIntoImageRecommendCell];
        }
        else if (self.imagePostionType == TTPhotoDetailImagePositon_Ad)
        {
            self.currSubjectModel = nil;
            //有推荐图集，才显示nextView
            if (self.recommendImageInfoArray) {
                
                if (_isFirstShowAd) {
                    self.nextView.alpha = kNextViewAlpha;
                    
                    [UIView animateWithDuration:kNextViewFrameChangeTime animations:^{
                        
                        self.nextView.frame = CGRectMake(self.right - tt(122), CGRectGetMinY(self.nextView.frame), CGRectGetWidth(self.nextView.frame), CGRectGetHeight(self.nextView.frame));
                        
                    }];
                    _isFirstShowAd = NO;
                }
                
                else {
                    [UIView animateWithDuration:kNextViewAlphaTime animations:^{
                        
                        self.nextView.alpha = kNextViewAlpha;
                    }];
                }
                
            }
            [self adjustUIWhenScrollIntoImageRecommendCell];
        }
        else
        {
            self.currSubjectModel = nil;
            [UIView animateWithDuration:kNextViewAlphaTime animations:^{
                self.nextView.alpha = 0;
            }];
            [self adjustUIWhenScrollIntoImageRecommendCell];
        }
        
        //根据imagePostion，通过代理修改TTPhotoNativeDetailView中UI
        if (self.currentPage != page) {
            self.currentPage = page;
            if ([self.delegate respondsToSelector:@selector(imageCollectionView:didScrollImagePositionType:)]) {
                [self.delegate imageCollectionView:self didScrollImagePositionType:self.imagePostionType];
            }
        }
        
        if (self.currentPage == modelCount - 1) {
            if ([self.delegate respondsToSelector:@selector(imageCollectionView:didScrollToIndex:isLastPic:)]) {
                [self.delegate imageCollectionView:self didScrollToIndex:page isLastPic:YES];
            }
        }
        
    } else if ([scrollView isKindOfClass:[UITextView class]]) {
        if ([self.delegate respondsToSelector:@selector(imageCollectionView:didScrollTextView:)]) {
            [self.delegate imageCollectionView:self didScrollTextView:(UITextView *)scrollView];
        }
    }
}

//图片覆盖的阴影显示、过程中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.subjectModels.count > 0) {
        //包括广告在内的所有图片数量
        NSInteger imageCount = self.subjectModels.count;
//        if ([TTAdManageInstance photoAlbum_hasAd] == YES) {
//            imageCount = imageCount + 1;
//        }
        NSUInteger currentCellIndex = round(scrollView.contentOffset.x/self.size.width);
        CGFloat scrollPercent = (scrollView.contentOffset.x - currentCellIndex * self.size.width)/self.size.width;
        if (!currentCellIndex) {
            currentCellIndex = 0;
        }
        
        if ((currentCellIndex == imageCount - 1 && scrollPercent < 0) || (currentCellIndex == imageCount -2 && scrollPercent > 0)) {
            [self.delegate imageCollectionView:self scrollPercent:scrollPercent];
        }
        
        BOOL hasAd = NO;
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        if (adManagerInstance && [adManagerInstance respondsToSelector:@selector(photoAlbum_hasAd)]) {
            hasAd = [adManagerInstance photoAlbum_hasAd];
        }
        
        if ([SSCommonLogic refectorPhotoAlbumControlEnable]) {
            
            TTPhotoDetailCellScrollDirection scrollDirection = TTPhotoDetailCellScrollDirection_None;
            id cell = nil;
            if (currentCellIndex > 0) {
                NSIndexPath *lastPath = [NSIndexPath indexPathForItem:currentCellIndex - 1 inSection:0];
                cell = [self.collectionView cellForItemAtIndexPath:lastPath];
                scrollDirection = TTPhotoDetailCellScrollDirection_Front;
                
                if (cell && [cell isKindOfClass:[UICollectionViewCell class]] && [cell conformsToProtocol:@protocol(TTPhotoDetailCellProtocol)] && [cell respondsToSelector:@selector(ScrollViewDidScrollView:ScrollDirection:WithScrollPersent:WithContainView:WithScrollBlock:)]) {
                    
                    [cell ScrollViewDidScrollView:scrollView ScrollDirection:scrollDirection WithScrollPersent:scrollPercent WithContainView:self WithScrollBlock:nil];
                }
            }
            
            
            if (hasAd == YES) {
                imageCount = imageCount + 1;
            }
            
            if (currentCellIndex < imageCount) {
                NSIndexPath *currentPath = [NSIndexPath indexPathForItem:currentCellIndex inSection:0];
                cell = [self.collectionView cellForItemAtIndexPath:currentPath];
                scrollDirection = TTPhotoDetailCellScrollDirection_Current;
                
                if (cell && [cell isKindOfClass:[UICollectionViewCell class]] && [cell conformsToProtocol:@protocol(TTPhotoDetailCellProtocol)] && [cell respondsToSelector:@selector(ScrollViewDidScrollView:ScrollDirection:WithScrollPersent:WithContainView:WithScrollBlock:)]) {
                    
                    [cell ScrollViewDidScrollView:scrollView ScrollDirection:scrollDirection WithScrollPersent:scrollPercent WithContainView:self WithScrollBlock:nil];
                }
            }
            
            if (currentCellIndex  < imageCount - 1) {
                NSIndexPath *nextPath = [NSIndexPath indexPathForItem:currentCellIndex + 1 inSection:0];
                cell = [self.collectionView cellForItemAtIndexPath:nextPath];
                scrollDirection = TTPhotoDetailCellScrollDirection_BackFoward;
                
                if (cell && [cell isKindOfClass:[UICollectionViewCell class]] && [cell conformsToProtocol:@protocol(TTPhotoDetailCellProtocol)] && [cell respondsToSelector:@selector(ScrollViewDidScrollView:ScrollDirection:WithScrollPersent:WithContainView:WithScrollBlock:)]) {
                    
                    [cell ScrollViewDidScrollView:scrollView ScrollDirection:scrollDirection WithScrollPersent:scrollPercent WithContainView:self WithScrollBlock:nil];
                }
            }
            
        }
        else {
            //前一个
            if (currentCellIndex > 0) {
                NSIndexPath *lastPath = [NSIndexPath indexPathForItem:currentCellIndex - 1 inSection:0];
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:lastPath];
                if ([cell isKindOfClass:[ExploreImageCollectionViewCell class]]) {
                    ExploreImageCollectionViewCell *lastCell = (ExploreImageCollectionViewCell *)cell;
                    [lastCell refreshBlackOpaqueWithPersent: - scrollPercent];
                    [lastCell refreshRightDistanceWithPersent:1- fabs(scrollPercent)];
    
                }
                else if ([cell isKindOfClass:[TTPhotoDetailAdCollectionCell class]]) {
                    TTPhotoDetailAdCollectionCell *lastCell = (TTPhotoDetailAdCollectionCell *)cell;
                    [lastCell refreshBlackOpaqueWithPersent: - scrollPercent];
                    [lastCell refreshRightDistanceWithPersent:1- fabs(scrollPercent)];
    
                }
    
                else if ([cell isKindOfClass:[TTPhotoDetailAdNewCollectionViewCell class]]) {
                    TTPhotoDetailAdNewCollectionViewCell *lastCell = (TTPhotoDetailAdNewCollectionViewCell *)cell;
                    [lastCell refreshBlackOpaqueWithPersent: - scrollPercent];
                }
            }
    
            if (hasAd == YES) {
                imageCount = imageCount + 1;
            }
    
            //当前
            if (currentCellIndex < imageCount) {
                NSIndexPath *currentPath = [NSIndexPath indexPathForItem:currentCellIndex inSection:0];
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:currentPath];
                if ([cell isKindOfClass:[ExploreImageCollectionViewCell class]]) {
                    ExploreImageCollectionViewCell *currentCell = (ExploreImageCollectionViewCell *)cell;
                    [currentCell refreshBlackOpaqueWithPersent: 1 - fabs(scrollPercent)];
                    if (scrollPercent > 0) {
                        [currentCell refreshRightDistanceWithPersent:fabs(scrollPercent)];
                    }
                }
                else if ([cell isKindOfClass:[TTPhotoDetailAdCollectionCell class]]) {
                    TTPhotoDetailAdCollectionCell *currentCell = (TTPhotoDetailAdCollectionCell *)cell;
                    [currentCell refreshBlackOpaqueWithPersent: 1 - fabs(scrollPercent)];
                    if (scrollPercent > 0) {
                        [currentCell refreshRightDistanceWithPersent:fabs(scrollPercent)];
                    }
                }
    
                else if ([cell isKindOfClass:[TTPhotoDetailAdNewCollectionViewCell class]]){
                    TTPhotoDetailAdNewCollectionViewCell *currentCell = (TTPhotoDetailAdNewCollectionViewCell *)cell;
                    [currentCell refreshBlackOpaqueWithPersent: 1 - fabs(scrollPercent)];
    
                }
    
            }
    
            //后一个
            if (currentCellIndex  < imageCount - 1) {
                NSIndexPath *nextPath = [NSIndexPath indexPathForItem:currentCellIndex + 1 inSection:0];
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:nextPath];
                if ([cell isKindOfClass:[ExploreImageCollectionViewCell class]]) {
                    ExploreImageCollectionViewCell *nextCell = (ExploreImageCollectionViewCell *)cell;
                    [nextCell refreshBlackOpaqueWithPersent: scrollPercent];
                    [nextCell refreshRightDistanceWithPersent:0];
                }
                else if ([cell isKindOfClass:[TTPhotoDetailAdCollectionCell class]]) {
                    TTPhotoDetailAdCollectionCell *nextCell = (TTPhotoDetailAdCollectionCell *)cell;
                    [nextCell refreshBlackOpaqueWithPersent: scrollPercent];
                    [nextCell refreshRightDistanceWithPersent:0];
                }
                
                else if ([cell isKindOfClass:[TTPhotoDetailAdNewCollectionViewCell class]]) {
                    TTPhotoDetailAdNewCollectionViewCell *nextCell = (TTPhotoDetailAdNewCollectionViewCell *)cell;
                    [nextCell refreshBlackOpaqueWithPersent: scrollPercent];
                }
            }
            
        }
    }
}

#pragma safeInset

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    BOOL isPhoneLandScape = ![TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    BOOL toolBarVisible = !isPhoneLandScape;
    [self adjustContenInsetWithToolBarVisible:toolBarVisible detailVC:self.viewController];
}

@end

#pragma mark - ExploreImageSubjectModel (ExploreSequence)

@implementation ExploreImageSubjectModel (ExploreSequence)

static NSString *const ExploreImageModelIndexKey = @"ExploreImageModelIndexKey";
- (void)setIndex:(NSInteger)index {
    objc_setAssociatedObject(self, (__bridge const void *)(ExploreImageModelIndexKey), @(index), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)index {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(ExploreImageModelIndexKey));
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }
    return 0;
}

static NSString *const ExploreImageModelTotalKey = @"ExploreImageModelTotalKey";
- (void)setTotal:(NSInteger)total {
    objc_setAssociatedObject(self, (__bridge const void *)(ExploreImageModelTotalKey), @(total), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)total {
    id value = objc_getAssociatedObject(self, (__bridge const void *)(ExploreImageModelTotalKey));
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }
    return 0;
}


@end

@implementation UIView (GrowAlphaView)

//在这个图层上创建一个垂直的黑色透明度渐变的layer。
//并且会把原本的背景颜色设置为透明
- (CAGradientLayer *)insertVerticalGrowAlphaLayerWithStartAlpha:(CGFloat)startAlpha endAlpha:(CGFloat)endAlpha {
    
    UIColor *colorOne = [UIColor colorWithRed:(33/255.0)  green:(33/255.0)  blue:(33/255.0)  alpha:startAlpha];
    UIColor *colorTwo = [UIColor colorWithRed:(33/255.0)  green:(33/255.0)  blue:(33/255.0)  alpha:endAlpha];
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil,nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1];
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil,nil];
    
    //crate gradient layer
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = self.bounds;
    self.backgroundColor = [UIColor clearColor];
    [self.layer insertSublayer:headerLayer atIndex:0];
    return headerLayer;
}
@end


