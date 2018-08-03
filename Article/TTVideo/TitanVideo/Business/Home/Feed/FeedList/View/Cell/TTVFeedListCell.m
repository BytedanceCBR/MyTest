//
//  TTVFeedListCell.m
//  Article
//
//  Created by panxiang on 2017/3/3.
//
//

#import "TTVFeedListCell.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellEndDisplayContext.h"
#import "TTVFeedCellForRowContext.h"
#import "SSADEventTracker.h"
#import "TTAdImpressionTracker.h"
#import "TTVCellPlayMovie.h"
#import "TTVFeedListTopImageContainerView.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+ComputedProperties.h"
#import "TTVPlayerModel.h"
#import "TTUIResponderHelper.h"
#import "TTVAutoPlayManager.h"
#import "KVOController.h"
#import "TTSettingsManager.h"
#import "TTASettingConfiguration.h"

#define kBottomPaddingViewH [TTDeviceUIUtils tt_newPadding:6]

CGFloat ttv_feedContainerWidth(CGFloat contentViewWidth)
{
    CGFloat paddingForCellView = [TTUIResponderHelper paddingForViewWidth:0];
    return contentViewWidth - 2 * paddingForCellView;
}

static CGFloat kAdBottomContainerViewHeight = 0;
CGFloat adBottomContainerViewHeight(void)
{
    if (kAdBottomContainerViewHeight > 0) {
        return kAdBottomContainerViewHeight;
    }
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        kAdBottomContainerViewHeight = [TTDeviceUIUtils tt_newPadding:48];
    }else{
        kAdBottomContainerViewHeight = [TTDeviceUIUtils tt_newPadding:52];
    }
    return kAdBottomContainerViewHeight;
}

CGFloat ttv_bottomPaddingViewHeight(void)
{
    if (ttvs_isVideoFeedCellHeightAjust() < 2) {
        return kBottomPaddingViewH;
    }else{
        return 0;
    }
}

@interface TTVFeedListCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) CGFloat                prevOffset;

@end

@implementation TTVFeedListCell

@dynamic item;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        self.backgroundColor = self.contentView.backgroundColor;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _containerView = [[UIView alloc] init];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_containerView];
        
        _separatorLineView = [[UIView alloc] init];
        _separatorLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
        [self.containerView addSubview:_separatorLineView];
        
        _bottomPaddingView = [[UIView alloc] init];
        if ([TTDeviceHelper isPadDevice]) {
            _bottomPaddingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        } else {
            _bottomPaddingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
        }
        [self.containerView addSubview:_bottomPaddingView];
    }
    return self;
}

- (void)setItem:(TTVFeedListItem *)item
{
    [super setItem:item];
    
    self.separatorLineView.hidden = (item.cellSeparatorStyle == TTVFeedListCellSeparatorStyleNone);
    self.bottomPaddingView.hidden = !(item.cellSeparatorStyle == TTVFeedListCellSeparatorStyleHas) || [TTDeviceHelper isPadDevice];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat paddingForCellView = [TTUIResponderHelper paddingForViewWidth:0];
    self.containerView.frame = CGRectMake(paddingForCellView, 0, self.contentView.width - 2 * paddingForCellView, self.contentView.height);
    [self.containerView bringSubviewToFront:self.separatorLineView];
    [self.containerView bringSubviewToFront:self.bottomPaddingView];
    
    self.separatorLineView.width = self.containerView.width;
    if (ttvs_isVideoFeedCellHeightAjust() > 1) {
        self.separatorLineView.height = 0;
    }else{
        self.separatorLineView.height = [TTDeviceHelper ssOnePixel];
    }
    
    self.bottomPaddingView.width = self.containerView.width;
    self.bottomPaddingView.height = ttv_bottomPaddingViewHeight();
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.backgroundColor = self.contentView.backgroundColor;
    _separatorLineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    if ([TTDeviceHelper isPadDevice]) {
        _bottomPaddingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    } else {
        _bottomPaddingView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    }
}

#pragma mark - TTVFeedPlayMovie

- (UIView *)movie
{
    if (self.topMovieContainerView == nil) {
        return nil;
    }
    return [self.topMovieContainerView.playMovie currentMovieView];
}

- (NSObject<TTVCellPlayMovieProtocol> *)playMovie
{
    if (self.topMovieContainerView == nil) {
        return nil;
    }
    return self.topMovieContainerView.playMovie;
}

- (BOOL)cell_hasMovieView
{
    if (self.topMovieContainerView == nil) {
        return NO;
    }
    return [self movie] != nil;
}

- (BOOL)cell_isPlayingMovie
{
    if (self.topMovieContainerView == nil) {
        return NO;
    }
    if ([self movie] && [self playMovie]) {
        return YES;
    }
    return NO;
}

- (BOOL)cell_isMovieFullScreen
{
    if (self.topMovieContainerView == nil) {
        return NO;
    }
    return [[self playMovie] isFullScreen];
}

- (UIView *)cell_movieView
{
    if (self.topMovieContainerView == nil) {
        return nil;
    }
    NSObject<TTVCellPlayMovieProtocol> *playMovie = [self playMovie];
    return [playMovie currentMovieView];
}

- (BOOL)cell_isPlaying
{
    return [[self playMovie] isPlaying];
}

- (BOOL)cell_isPaused
{
    return [[self playMovie] isPaused];
}

- (BOOL)cell_isPlayingFinished
{
    return [[self playMovie] isPlayingFinished];
}

- (void)cell_attachMovieView:(UIView *)movieView
{
    if (self.topMovieContainerView == nil) {
        return;
    }
    if ([movieView isKindOfClass:[TTVPlayVideo class]]) {
        UIView *logo = self.topMovieContainerView.logo;
        movieView.frame = logo.bounds;
        [logo addSubview:movieView];
        if (self.topMovieContainerView.playMovie == nil && [self.item isKindOfClass:[TTVFeedListItem class]]) {
            [self.topMovieContainerView playButtonClicked];
            TTVVideoArticle *article = self.item.article;
            [self.topMovieContainerView.playMovie setVideoTitle:article.title];
            self.topMovieContainerView.playMovie.logo = logo;
        }
        [self.topMovieContainerView.playMovie attachMovieView:(TTVPlayVideo *)movieView];
        // attatch的时候，禁用动画
        self.topMovieContainerView.ttv_movieViewWillMoveToSuperViewBlock(movieView.superview, NO);
    }
}

- (id)cell_detachMovieView
{
    if (self.topMovieContainerView == nil) {
        return nil;
    }
    return [self.topMovieContainerView.playMovie detachMovieView];
}

- (CGRect)cell_logoViewFrame
{
    if (self.topMovieContainerView == nil) {
        return CGRectZero;
    }
    return self.topMovieContainerView.logo.frame;
}

- (CGRect)cell_movieViewFrameRect {
    
    if (self.topMovieContainerView == nil) {
        
        return CGRectZero;
    }
    
    return [self convertRect:self.topMovieContainerView.bounds fromView:self.topMovieContainerView];
}

#pragma mark TTVAutoPlay
- (void)ttv_autoPlayingAttachMovieView:(UIView *)movieView
{
    [self cell_attachMovieView:movieView];
}

- (TTVPlayVideo *)ttv_movieView
{
    TTVPlayVideo *player = (TTVPlayVideo *)[self cell_movieView];
    if ([player isKindOfClass:[TTVPlayVideo class]]) {
        return player;
    }
    return nil;
}

- (CGRect)ttv_logoViewFrame
{
    return self.topMovieContainerView.logo.frame;
}

- (TTVAutoPlayModel *)ttv_autoPlayModel
{
    TTVAutoPlayModel *model = [TTVAutoPlayModel modelWithArticle:self.item.originData category:self.item.categoryId];
    return model;
}

- (BOOL)ttv_cellCouldAutoPlaying
{
    return [self.item.originData couldAutoPlay];
}

- (void)ttv_autoPlayVideo
{
    [self.topMovieContainerView playButtonClicked];
}


- (void)tableviewScroll:(UIScrollView *)scrollView
{
    if (!ttas_isVideoScrollPlayEnable()) {
        return;
    }
    if (![scrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    CGRect videoRect = [self convertRect:[self ttv_logoViewFrame] toView:scrollView];
    CGFloat offset = scrollView.contentOffset.y;
    
    BOOL halfAutoPlay = [TTDeviceHelper isPadDevice] ? NO : [[[TTSettingsManager sharedManager] settingForKey:@"tt_video_autoplayad_halfshow" defaultValue:@NO freeze:NO] boolValue];
    CGFloat visibleHeight = videoRect.size.height;
    if (halfAutoPlay == YES) {
        visibleHeight = videoRect.size.height/2;
    }
    if (offset > self.prevOffset) { //向上滑动
        if (scrollView.bottom - (CGRectGetMinY(videoRect) - offset)> visibleHeight) {
            [self autoPlayMovie];
        }
    }
    else if (offset < self.prevOffset){//向下滑动
        if (CGRectGetMaxY(videoRect) - offset - scrollView.top > visibleHeight) {
            [self autoPlayMovie];
        }
    }
    self.prevOffset = scrollView.contentOffset.y;
}

- (void)autoPlayMovie
{
    TTVPlayVideo *movieView = [self ttv_movieView];
    TTVPlayVideo *currentPlayVideo = [TTVPlayVideo currentPlayingPlayVideo];
    BOOL canAutoPlay = [self ttv_cellCouldAutoPlaying] && (self.item.originData.adIDStr.longLongValue>0);
    BOOL properStatus = YES;
    BOOL hasVideoPlaying = NO;
    if (movieView.player.context.playbackState == TTVVideoPlaybackStatePlaying ||
        movieView.player.context.playbackState == TTVVideoPlaybackStateFinished) {
        properStatus = NO;
    }
    if (currentPlayVideo && currentPlayVideo.player.context.playbackState == TTVVideoPlaybackStatePlaying) {
        hasVideoPlaying = YES;
    }
    if (canAutoPlay && properStatus && !hasVideoPlaying) {
        [[TTVAutoPlayManager sharedManager] ttv_cellTriggerPlayVideoIfCould:self];
    }
}

#pragma mark - TTVFeedCellAppear

- (void)viewWillAppear
{
    if ([self.topMovieContainerView.playMovie respondsToSelector:@selector(viewWillAppear)]) {
        [self.topMovieContainerView.playMovie viewWillAppear];
    }
}

- (void)viewWillDisappear
{
    if ([self.topMovieContainerView.playMovie respondsToSelector:@selector(viewWillDisappear)]) {
        [self.topMovieContainerView.playMovie viewWillDisappear];
    }
}

- (void)cellInListWillDisappear:(TTCellDisappearType)context
{
    [self viewWillDisappear];
    if ([self.topMovieContainerView.playMovie respondsToSelector:@selector(cellInListWillDisappear:)]) {
        [self.topMovieContainerView.playMovie cellInListWillDisappear:context];
    }
}

// 首页列表cell点击处理
- (void)didSelectWithContext:(TTVFeedCellSelectContext *)context
{
    [self.topMovieContainerView.playMovie removeCommodityView];
}

- (void)willDisplayWithContext:(TTVFeedCellWillDisplayContext *)context
{
    if (!self.tableView || ![self.tableView isKindOfClass:[UITableView class]]) {
        return;
    }
    WeakSelf;
    [self.KVOController observe:self.tableView keyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self tableviewScroll:self.tableView];
    }];
}

- (void)endDisplayWithContext:(TTVFeedCellEndDisplayContext *)context
{
    [self.KVOController unobserveAll];
}

- (void)cellForRowContext:(TTVFeedCellForRowContext *)context
{
}

- (UIView *)ttv_playerSuperView
{
    return [self.topMovieContainerView ttv_playerSuperView];
}
@end
