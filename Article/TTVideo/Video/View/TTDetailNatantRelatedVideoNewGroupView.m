//
//  TTDetailNatantRelatedVideoNewGroupView.m
//  Article
//
//  Created by lijun.thinker on 2017/6/21.
//

#import "TTDetailNatantRelatedVideoNewGroupView.h"
#import "Article.h"
#import "TTDetailNatantRelateReadView.h"
#import "ArticleInfoManager.h"
#import "TTDetailModel.h"
#import "TTDetailNatantRelateReadViewModel.h"
#import "ExploreVideoDetailImpressionHelper.h"
#import "TTDetailModel.h"
#import "ExploreDetailManager.h"
#import "ExploreVideoDetailHelper.h"
#import "TTAlphaThemedButton.h"
#import "TTAdManager.h"
#import "ExploreDetailToolbarView.h"
#import "UIButton+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"
#import "TTURLTracker.h"
#import "TTAdVideoRelateAdModel.h"

#define kLoadMoreItemHeight     44.f
#define kLoadMoreButtonTopInset ([TTDeviceHelper isPadDevice] ? 20 : 0)
#define kItemeMiddlePadding     3.f

@interface TTDetailNatantRelatedVideoNewGroupView ()

@property (nonatomic, assign) NSInteger firstPageCount;
@property (nonatomic, assign) BOOL natantDidLoadImpressionHasSended;
@property (nonatomic, assign) BOOL hasVideoAdShowSend;  //视频类型广告show是否发送
@property (nonatomic, strong) ArticleInfoManager * infoManager;
@property (nonatomic, strong) TTAlphaThemedButton *loadMoreButton;
@property(nonatomic, strong) NSMutableArray * relatedItems;
@property(nonatomic, assign) CGFloat oldPosition;
@property (nonatomic, strong) NSMutableDictionary * relatedVideoImpressionDic;
@property (nonatomic, strong) SSThemedView *bottomLine;
@end

@implementation TTDetailNatantRelatedVideoNewGroupView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hasVideoAdShowSend = NO;
    }
    return self;
}

- (NSMutableDictionary *)relatedVideoImpressionDic
{
    if (!_relatedVideoImpressionDic) {
        _relatedVideoImpressionDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _relatedVideoImpressionDic;
}

- (void)buildRelatedVideoViewsWithData:(ArticleInfoManager * _Nullable)infoManager
{
    self.infoManager = infoManager;
    
    NSInteger layoutNumber = MIN(_firstPageCount, self.relatedItems.count);
    CGFloat wrapperHeight = 0;
    wrapperHeight = [self layoutItemsWithCursorHeight:wrapperHeight from:0 to:layoutNumber];
    if ([self shouldShowLoadMoreButton]) {
        TTDetailNatantRelateReadView *view = [self.items lastObject];
        [view hideBottomLine:YES];
        [self addSubview:self.loadMoreButton];
        [self.loadMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_equalTo(wrapperHeight + kLoadMoreButtonTopInset);
            make.width.equalTo(self);
            make.height.mas_equalTo(kLoadMoreItemHeight);
        }];
        [self addSubview:self.bottomLine];
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self);
            make.centerX.equalTo(self);
            make.width.equalTo(self);
            make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
        }];
        [_loadMoreButton setNeedsLayout];
        [_loadMoreButton layoutIfNeeded];
        wrapperHeight += kLoadMoreItemHeight + kLoadMoreButtonTopInset;
    }
    self.height = wrapperHeight;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self relayoutViews];
}

- (void)dealloc
{
    
}

- (void)enableBottomLine:(BOOL)enable {
    self.bottomLine.hidden = !enable;
}

#pragma mark -- TTDetailNatantViewBase protcol implmenation
- (NSString *)eventLabel{
    return @"related_video_show";
}

- (void)trackEventIfNeeded{
    [self sendShowTrackIfNeededForGroup:self.infoManager.detailModel.article.groupModel.groupID withLabel:self.eventLabel];
}

- (TTAlphaThemedButton *)loadMoreButton
{
    if (!_loadMoreButton) {
        _loadMoreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _loadMoreButton.titleColorThemeKey = kColorText1;
        _loadMoreButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
        [_loadMoreButton addTarget:self action:@selector(appendMoreItems) forControlEvents:UIControlEventTouchUpInside];
        NSString *title = @"查看更多";
        UIImage *image = [UIImage imageNamed:@"seemore_all"];
        [_loadMoreButton setTitle:title forState:UIControlStateNormal];
        [_loadMoreButton setImage:[UIImage themedImageNamed:@"seemore_all"] forState:UIControlStateNormal];
        [_loadMoreButton setImage:[UIImage themedImageNamed:@"seemore_all_press"] forState:UIControlStateHighlighted];
        _loadMoreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8.f, -self.width/2, 0, -self.width/2);
        _loadMoreButton.titleLabel.font = [UIFont systemFontOfSize:[[self class] loadMoreButtonFontSize]];
        
        CGFloat imageEdgeInset = [[self class] loadMoreButtonFontSize] * [title length] + 8;
        CGFloat titleEdgeInset = image.size.width + 8;
        if ([TTDeviceHelper isPadDevice]) {
            imageEdgeInset += 8;
            titleEdgeInset += 8;
        }
        _loadMoreButton.imageEdgeInsets = UIEdgeInsetsMake(1, imageEdgeInset, -1, -imageEdgeInset);
        _loadMoreButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, titleEdgeInset);
        
    }
    return _loadMoreButton;
}

- (SSThemedView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] init];
        _bottomLine.hidden = YES;
        _bottomLine.backgroundColorThemeKey = kColorLine1;
    }
    return _bottomLine;
}

- (CGFloat)layoutItemsWithCursorHeight:(CGFloat)wrapperHeight
                                  from:(NSInteger)fromIndex
                                    to:(NSInteger)toIndex
{
    CGFloat itemWidth = (self.width - kLeftPadding - kRightPadding - kItemeMiddlePadding) / 2;
    BOOL isLeftRow = NO;
    CGFloat leftBottom, rightBottom;
    
    for (NSInteger idx = fromIndex; idx < toIndex; idx++) {
        NSDictionary * itemInfo;
        isLeftRow = !isLeftRow;
        
        if (idx<self.relatedItems.count) {
            itemInfo = [self.relatedItems objectAtIndex:idx];
        }
        Article * rArticle = [itemInfo objectForKey:@"article"];
        
        if ([TTAdManageInstance video_relateIsSmallPicAdCell:rArticle] == YES) {
            TTAdVideoRelateTopImageView* view = [TTAdManageInstance video_relateTopImageView:rArticle top:wrapperHeight width:itemWidth successBlock:^(BOOL success) {
            }];
            [view hideBottomLine:YES];
            if (!isLeftRow) {
                view.isRight = YES;
                view.left = kLeftPadding + itemWidth + kItemeMiddlePadding;
                rightBottom = view.bottom;
                wrapperHeight = MAX(leftBottom, rightBottom);
            } else {
                leftBottom = view.bottom;
                view.left = kLeftPadding;
            }
            
            [self addSubview:view];
            [self.items addObject:view];
        }
        else
        {
            TTDetailNatantRelateReadView *view = [TTDetailNatantRelateReadView genViewForArticle:rArticle width:itemWidth infoFlag:0 forVideoDetail:YES];
            view.top = wrapperHeight;
            if (!isLeftRow) {
                view.left = kLeftPadding + itemWidth + kItemeMiddlePadding;
                rightBottom = view.bottom;
                wrapperHeight = MAX(leftBottom, rightBottom);
                
                if ([view isKindOfClass:[TTDetailNatantRelateReadTopImgView class]]) {
                    
                    ((TTDetailNatantRelateReadTopImgView *)view).isRight = YES;
                }
            } else {
                leftBottom = view.bottom;
                view.left = kLeftPadding;
            }
            
            [self addSubview:view];
            [self.items addObject:view];
            view.viewModel.fromArticle = self.infoManager.detailModel.article;
            view.viewModel.actions = [itemInfo objectForKey:@"actions"];
            view.viewModel.pushAnimation = NO;
            
            ArticleRelatedVideoType type = [rArticle relatedVideoType];
            if (type == ArticleRelatedVideoTypeAlbum || type == ArticleRelatedVideoTypeSubject) {
                view.viewModel.isVideoAlbum = YES;
                WeakSelf;
                view.viewModel.didSelectVideoAlbum = ^(Article *article){
                    StrongSelf;
                    if ([self.delegate respondsToSelector:@selector(didSelectVideoAlbum:)]) {
                        [self.delegate didSelectVideoAlbum:article];
                    }
                };
                NSString *col_no = [rArticle.videoDetailInfo valueForKey:@"col_no"];
                NSString *media_id = [self.infoManager.detailModel.article.mediaInfo valueForKey:@"media_id"];
                if (col_no) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setValue:media_id forKey:@"media_id"];
                    wrapperTrackEventWithCustomKeys(@"video", @"detail_album_show", col_no, nil, dic);
                }
                else if ([rArticle hasVideoSubjectID]) {
                    wrapperTrackEventWithCustomKeys(@"video", @"detail_album_show", nil, nil, @{@"video_subject_id" : [rArticle videoSubjectID]});
                }
            }
            [view refreshTitleWithTags:[itemInfo objectForKey:@"tags"]];
            [view hideBottomLine:YES];
        }
    }
        
    return wrapperHeight;
}
    
- (void)appendMoreItems{
    //展开前最后一个item重新显示bottomLine
    wrapperTrackEvent(@"video", @"detail_loadmore_relatedVideo");
    CGFloat wrapperHeightCursor = self.height - kLoadMoreButtonTopInset - kLoadMoreItemHeight;
    TTDetailNatantRelateReadView *view = [self.items lastObject];
    [view hideBottomLine:YES];
    wrapperHeightCursor = [self layoutItemsWithCursorHeight:wrapperHeightCursor
                                                       from:_firstPageCount
                                                         to:self.relatedItems.count];
    view = [self.items lastObject];
    [view hideBottomLine:YES];
    [_loadMoreButton removeFromSuperview];
    self.height = wrapperHeightCursor;
    if (self.relayOutBlock) {
        self.relayOutBlock(NO);
    }
}

- (void)relayoutViews
{
    __block CGFloat heightCursor = 0;
    CGFloat itemWidth = (self.width - kLeftPadding - kRightPadding - kItemeMiddlePadding) / 2;
    __block CGFloat leftBottom, rightBottom;
    
    [self.items enumerateObjectsUsingBlock:^(TTDetailNatantRelateReadView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTDetailNatantRelateReadView class]]) {
            [obj refreshWithWidth:itemWidth];
            obj.top = heightCursor;
            if (idx % 2 != 0) {
                rightBottom = obj.bottom;
                heightCursor = MAX(leftBottom, rightBottom);
                obj.left = kLeftPadding + itemWidth + kItemeMiddlePadding;
            } else {
                leftBottom = obj.bottom;
            }
        }
    }];
    
    //初次展现时候监听列表中adView广告的show事件
    UIScrollView* scrollView = (UIScrollView* )self.superview.superview;
    VideoDetailRelatedStyle style = [ExploreVideoDetailHelper currentVideoDetailRelatedStyle];
    if (style == VideoDetailRelatedStyleDistinct) {
        scrollView = (UIScrollView* )self.superview;
    }
    for (int i = 0; i<self.items.count; i++) {
        TTDetailNatantRelateReadView* view = (TTDetailNatantRelateReadView*)self.items[i];
        if (([view isKindOfClass:[TTAdVideoRelateTopImageView class]]) &&[scrollView isKindOfClass:[UIScrollView class]]) {
            if (scrollView.bottom > self.top + view.top) {
                if ([(TTAdVideoRelateTopImageView*)view respondsToSelector:@selector(adVideoRelateImageViewtrackShow)]) {
                    [(TTAdVideoRelateTopImageView*)view adVideoRelateImageViewtrackShow];
                }
            }
        }
    }
}

-(void)reloadData:(id)object{
    if (![object isKindOfClass:[ArticleInfoManager class]]) {
        return;
    }
    if (!self.items) {
        self.items = [[NSMutableArray alloc] init];
    }
    ArticleInfoManager * articleInfo = (ArticleInfoManager *)object;
    _firstPageCount = [articleInfo.relateVideoSection integerValue] ?: 8;
    self.relatedItems = [[NSMutableArray alloc] init];
    if (articleInfo.relateVideoArticles) {
        
        for (int i = 0; i<articleInfo.relateVideoArticles.count; i++) {
            Article* article = articleInfo.relateVideoArticles[i][@"article"];
            
            if ([TTAdManageInstance video_relateIsSmallPicAdCell:article]) {
                //广告cell下必须是有效数据
                if ([TTAdManageInstance video_relateIsSmallPicAdValid:article]) {
                    [self.relatedItems addObject:articleInfo.relateVideoArticles[i]];
                }
            }
            else
            {
                [self.relatedItems addObject:articleInfo.relateVideoArticles[i]];
            }
        }
    }
    // if odd num to remove the last one
    (self.relatedItems.count % 2 == 0) ?: [self.relatedItems removeLastObject];
    
    [self buildRelatedVideoViewsWithData:articleInfo];
}

#pragma mark impression

#pragma mark - SSImpression

/*
 *  由于相关视频没有使用tableView实现，以下逻辑，模仿在tableView的cellForRow方法添加impression的机制(太复杂了*_*)
 */

- (void)sendRelatedItemImpressionAtIndex:(NSInteger)index
{
    //item显示在屏幕上时添加impression并设置flag
    if (index < 0 || index >= _infoManager.relateVideoArticles.count) {
        return;
    }
    NSDictionary *itemInfo = _infoManager.relateVideoArticles[index];
    Article * rArticle = [itemInfo objectForKey:@"article"];
    NSString *videoID = rArticle.videoDetailInfo[VideoInfoIDKey];
    if (![self impressionStateForRelatedVideo:videoID]) {
        //发送广告事件
        [self sendAdImpressionForArticle:self.infoManager.detailModel.article rArticle:rArticle status:SSImpressionStatusRecording];
        
        [ExploreVideoDetailImpressionHelper recordVideoDetailForArticle:self.infoManager.detailModel.article rArticle:rArticle status:SSImpressionStatusRecording];
        [self updateImpressionState:YES forRelatedVideo:videoID];
        //        NSLog(@"[start]%@", rArticle.title);
    }
}

- (void)endRelatedItemImpressionAtIndex:(NSInteger)index
{
    //item离开屏幕时重置flag
    if (index >= _infoManager.relateVideoArticles.count || index < 0) {
        return;
    }
    NSDictionary *itemInfo = _infoManager.relateVideoArticles[index];
    Article *rArticle = [itemInfo objectForKey:@"article"];
    NSString *videoID = rArticle.videoDetailInfo[VideoInfoIDKey];
    if ([self impressionStateForRelatedVideo:videoID]) {
        [ExploreVideoDetailImpressionHelper recordVideoDetailForArticle:self.infoManager.detailModel.article rArticle:rArticle status:SSImpressionStatusEnd];
        [self updateImpressionState:NO forRelatedVideo:videoID];
        //        NSLog(@"[end]%@", rArticle.title);
    }
}

//单独发送广告的show、track_url_list 且只发一次
- (void)sendAdImpressionForArticle:(Article *)article rArticle:(Article *)rArticle status:(SSImpressionStatus)status
{
    NSString *rVideoID = rArticle.videoDetailInfo[VideoInfoIDKey];
    if (isEmptyString(rVideoID) || isEmptyString(rArticle.groupModel.groupID)) {
        return;
    }
    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
    [extra setValue:article.groupModel.itemID forKey:@"item_id"];
    [extra setValue:@(article.groupModel.aggrType) forKey:@"aggr_type"];
    
    if ([article hasVideoSubjectID]) {
        [extra setValue:[article videoSubjectID] forKey:@"video_subject_id"];
    }
    
    if ([rArticle relatedVideoType] == ArticleRelatedVideoTypeAd && status == SSImpressionStatusRecording) {
        //只允许广告事件发一次
        if (self.hasVideoAdShowSend == YES) {
            return;
        }
        if ([rArticle relatedLogExtra]) {
            extra[@"log_extra"] = [rArticle relatedLogExtra];
        }
        NSString *value = nil;
        if ([rArticle relatedAdId]) {
            value = [[rArticle relatedAdId] stringValue];
        }
        NSMutableDictionary * adDict = [NSMutableDictionary dictionaryWithDictionary:extra];
        [adDict setValue:@"1" forKey:@"is_ad_event"];
        NSString* creativeType = rArticle.videoAdExtra.creative_type;
        if (!isEmptyString(creativeType)) {
            wrapperTrackEventWithCustomKeys(@"detail_ad_list", @"show", value, nil, adDict);
        }
        else
        {
            wrapperTrackEventWithCustomKeys(@"embeded_ad", @"show", value, nil, adDict);
        }
        TTURLTrackerModel* trackModel = [[TTURLTrackerModel alloc] initWithAdId:[[rArticle relatedAdId] stringValue] logExtra:[rArticle relatedLogExtra]];
        ttTrackURLsModel(rArticle.videoAdExtra.track_url_list, trackModel);
        //        ssTrackURLs(rArticle.videoAdExtra.track_url_list);
        
        self.hasVideoAdShowSend = YES;
    }
}

- (void)sendRelatedVideoImpressionWhenNatantDidLoadIfNeeded
{
    //刚进入视频详情页时给已经显示出来的relatedItems添加impression
    if (_natantDidLoadImpressionHasSended || [self shouldBeginShowComment]) {
        return;
    }
    CGFloat singleRelatedHeight = [ExploreVideoDetailHelper currentVideoDetailRelatedStyle] == VideoDetailRelatedStyleNatant ? [self natantItemHeight] : [self distinctItemHeight];
    
    //此时可能还获取不到item高度
    if (!singleRelatedHeight) {
        return;
    }
    CGFloat visableRelatedHeight = self.referHeight - self.top;
    
    NSInteger maxIdx = [self curShowRelatedItemIndex:(NSInteger)(visableRelatedHeight / singleRelatedHeight)];
    for (int idx = 0; idx <= maxIdx; idx++) {
        [self sendRelatedItemImpressionAtIndex:idx];
    }
    _natantDidLoadImpressionHasSended = YES;
}

- (void)endRelatedVideoImpressionWhenDisappear
{
    for (int idx = 0; idx < _infoManager.relateVideoArticles.count; idx++) {
        [self endRelatedItemImpressionAtIndex:idx];
    }
}

- (void)sendRelatedVideoImpressionForContentOffset:(CGFloat)contentOffset
{
    //记录相关视频impression记录情况：
    //出现在屏幕时记录并disable，同时check高度相差_commentView.height的即将离开屏幕的cell进行enable
    BOOL isScrollingUp;
    if (contentOffset > _oldPosition) {
        isScrollingUp = YES;
    }
    else {
        isScrollingUp = NO;
    }
    _oldPosition = contentOffset;
    
    CGFloat singleRelatedHeight = [self natantItemHeight];
    CGFloat shouldExcludeHeight = self.top;
    NSInteger maxIndex = [self currentShowNumberOfItems] - 1;
    CGFloat visableRelatedHeight = self.referHeight - shouldExcludeHeight;
    CGFloat visableRelatedOffsetWhenScrollUp = visableRelatedHeight + contentOffset;
    CGFloat visableRelatedOffsetWhenScrollDown = contentOffset - shouldExcludeHeight;
    NSInteger currentScrollIndex;
    if (isScrollingUp) {
        currentScrollIndex = [self curShowRelatedItemIndex:visableRelatedOffsetWhenScrollUp / singleRelatedHeight];
    }
    else {
        currentScrollIndex = [self curShowRelatedItemIndex:visableRelatedOffsetWhenScrollDown / singleRelatedHeight];
    }
    
    //超过相关视频区域直接ignore
    NSInteger shouldCheckEnterIndex = 0;
    if (currentScrollIndex <= maxIndex) {
        shouldCheckEnterIndex = MAX(MIN(currentScrollIndex, maxIndex), 0);
        [self sendRelatedItemImpressionAtIndex:shouldCheckEnterIndex];
        [self sendRelatedItemImpressionAtIndex:shouldCheckEnterIndex - 1];
    }
    
    
    //根据滚动方向，重置将要移除屏幕item的flag
    if (isScrollingUp) {
        CGFloat topOffset = contentOffset - shouldExcludeHeight - singleRelatedHeight;
        if (topOffset > 0) {
            NSInteger shouldCheckTopLeaveIndex = [self curShowRelatedItemIndex:topOffset / singleRelatedHeight];
            [self endRelatedItemImpressionAtIndex:MIN(shouldCheckTopLeaveIndex, maxIndex)];
            [self endRelatedItemImpressionAtIndex:MIN(shouldCheckTopLeaveIndex - 1, maxIndex)];
        }
    }
    else {
        if (currentScrollIndex <= maxIndex) {
            CGFloat includeHeight = [ExploreVideoDetailHelper currentVideoDetailRelatedStyle] == VideoDetailRelatedStyleNatant ? self.referHeight : self.height;//_wrapperScroller.height;
            CGFloat bottomOffset = visableRelatedOffsetWhenScrollDown + includeHeight + singleRelatedHeight;
            NSInteger bottomIndex = [self curShowRelatedItemIndex:bottomOffset / singleRelatedHeight];
            if (bottomIndex <= maxIndex) {
                [self endRelatedItemImpressionAtIndex:bottomIndex];
                [self endRelatedItemImpressionAtIndex:bottomIndex - 1];
            }
        }
    }
}

- (void)updateImpressionState:(BOOL)state forRelatedVideo:(NSString *)videoID
{
    if (isEmptyString(videoID)) {
        return;
    }
    self.relatedVideoImpressionDic[videoID] = @(state);
}

- (BOOL)impressionStateForRelatedVideo:(NSString *)videoID
{
    if ([[self.relatedVideoImpressionDic allKeys] containsObject:videoID]) {
        return [self.relatedVideoImpressionDic[videoID] boolValue];
    }
    else {
        return NO;
    }
}

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight{
    self.referHeight = referHeight;
    [self sendRelatedVideoImpressionForContentOffset:offsetY];
    //滚动时候监听列表中adView广告的show事件
    for (int i = 0; i<self.items.count; i++) {
        TTDetailNatantRelateReadView* view = (TTDetailNatantRelateReadView*)self.items[i];
        if ([view isKindOfClass:[TTAdVideoRelateTopImageView class]]) {
            VideoDetailRelatedStyle style = [ExploreVideoDetailHelper currentVideoDetailRelatedStyle];
            CGFloat scrollViewHeight = referHeight;
            if (style == VideoDetailRelatedStyleDistinct&&[self.superview isKindOfClass:[UIScrollView class]])
            {
                scrollViewHeight = self.superview.height;
            }
            CGFloat off1 = scrollViewHeight + offsetY;
            CGFloat off2 = self.top + view.top;
            if (off1 > off2) {
                [(TTAdVideoRelateTopImageView*)view adVideoRelateImageViewtrackShow];
            }
        }
    }
}

#pragma mark - Helper
//来源-[TTDetailModel shouldBeginShowComment]
- (BOOL)shouldBeginShowComment {
    NSDictionary *params = self.infoManager.detailModel.baseCondition;
    
    BOOL beginShowComment = [params tt_boolValueForKey:@"showcomment"];
    BOOL beginShowCommentUGC = [params tt_boolValueForKey:@"showCommentUGC"];
    return beginShowComment || beginShowCommentUGC;
}

- (BOOL)shouldShowLoadMoreButton{
    return [self.infoManager.relateVideoArticles count] > _firstPageCount;
}

+ (CGFloat)loadMoreButtonFontSize
{
    if ([TTDeviceHelper isPadDevice]) {
        return 18.f;
    }
    return 14.f;
}

- (NSInteger)currentShowNumberOfItems
{
    if (_loadMoreButton.superview) {
        return _firstPageCount;
    }
    else {
        return [self.infoManager.relateVideoArticles count];
    }
}

- (CGFloat)natantItemHeight
{
    if (self.items.count < 2) {
        return 0;
    }
    return [self.items objectAtIndex:1].bounds.size.height;
}

- (CGFloat)distinctItemHeight
{
    return self.items.count ? ((UIView *)[self.items firstObject]).height : 88.f;
}

- (NSUInteger)curShowRelatedItemIndex:(NSUInteger)originNum {
    // double row
    return ((NSInteger)originNum + 1) * 2 - 1;
}

@end
