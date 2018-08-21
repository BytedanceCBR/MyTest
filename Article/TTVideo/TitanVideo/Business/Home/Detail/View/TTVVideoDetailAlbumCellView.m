//
//  TTVVideoDetailAlbumCellView.m
//  Article
//
//  Created by lishuangyang on 2017/6/21.
//
//
#import <KVOController/KVOController.h>
#import "TTVVideoDetailAlbumCellView.h"
#import "TTArticleCellHelper.h"
#import "TTLabelTextHelper.h"
#import "TTOriginalLogo.h"
#import "TTAdManager.h"
#import "TTRoute.h"
#import "ArticleDetailHeader.h"
#import "TTVVideoDetailAlbumView.h"
#import "TTUIResponderHelper.h"
#import "NewsDetailConstant.h"
#import "TTDetailContainerViewController.h"

extern float tt_ssusersettingsManager_detailRelateReadFontSize();

#define kTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kAlbumTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)
#define kAlbumBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)
#define kLeftPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kRightPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kTitleFontSize (tt_ssusersettingsManager_detailRelateReadFontSize())
#define kRightImgLeftPadding (([TTDeviceHelper is736Screen]) ? 6 : 10)
#define kFromeLabelTopPadding 6
#define kGroupImgBottomPadding 10
#define KLabelInfoHeight 20
#define kVideoIconLeftGap 6

#define kTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kAlbumTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)
#define kAlbumBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)
#define kArticleGroupFlagsDetailRelateReadShowImg 0x20
#define kDownloadIconSize CGSizeMake([TTDeviceUIUtils tt_fontSize:12], [TTDeviceUIUtils tt_fontSize:12])

/** 内容字体大小 */
inline CGFloat cellInfoLabelFontSize() {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 16.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 12.f;
    } else {
        fontSize = 10.f;
    }
    return fontSize;
}

@implementation TTVVideoDetailNatantRelateReadViewModel

- (void)bgButtonClickedBaseViewController:(nonnull UIViewController *)baseController
{
    NewsGoDetailFromSource fromSource = NewsGoDetailFromSourceRelateReading;
    if (self.isSubVideoAlbum) {
        fromSource = NewsGoDetailFromSourceVideoAlbum;
    }
    
    if ([TTVVideoAlbumHolder holder].albumView)
    {
        if ([TTVVideoAlbumHolder holder].albumView.viewModel.currentPlayingArticle != self.article) {
            [TTVVideoAlbumHolder holder].albumView.viewModel.currentPlayingArticle = self.article;
            [[TTUIResponderHelper mainWindow] addSubview:[TTVVideoAlbumHolder holder].albumView];
        } else {
            return;
        }
    }
    
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if (self.isSubVideoAlbum)
    {
        [condition setValue:@(self.fromArticle.uniqueID) forKey:kNewsDetailViewConditionRelateReadFromAlbumKey];
    }
    else
    {
        [condition setValue:@(self.fromArticle.uniqueID) forKey:kNewsDetailViewConditionRelateReadFromGID];
    }
    [condition setValue:self.logPb forKey:@"logPb"];
    TTDetailContainerViewController *detailController = [[TTDetailContainerViewController alloc] initWithArticle:[self.article ttv_convertedArticle]
                                                                                                          source:fromSource
                                                                                                       condition:condition];
    
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor: baseController];
    [nav pushViewController:detailController animated:self.pushAnimation];
    
    [self sendClickTrack];
}

- (void)sendClickTrack
{
    if (self.isSubVideoAlbum) {
        if (self.videoAlbumID) {
            wrapperTrackEventWithCustomKeys(@"video", @"click_album", [@(self.article.uniqueID) stringValue], nil, @{@"ext_value" : self.videoAlbumID});
        } else if ([self.fromArticle hasVideoSubjectID]) {
            wrapperTrackEventWithCustomKeys(@"video", @"click_album", [@(self.article.uniqueID) stringValue], nil, @{@"video_subject_id" : self.fromArticle.videoSubjectID});
        }
        return;
    }
}

@end

@interface TTVVideoDetailAlbumCellView ()

//@property (nonatomic, strong)id<TTVArticleProtocol> protoedArticle;
@property (nonatomic, strong, nullable)SSThemedLabel * titleLabel;
@property (nonatomic, strong, nullable)SSThemedView * bottomLineView;
@property (nonatomic, strong, nullable)SSThemedButton * bgButton;
//@property (nonatomic, strong, nullable)SSThemedView * titleLeftCircleView;
@property (nonatomic, strong, nullable)TTImageView * imageView;
//@property (nonatomic, strong, nullable)UILabel *fromLabel;
@property (nonatomic, strong, nullable)UILabel *commentCountLabel;
@property (nonatomic, strong, nullable)UIView * timeInfoBgView;
@property (nonatomic, strong, nullable)SSThemedImageView * videoIconView;
@property (nonatomic, strong, nullable)SSThemedLabel * videoDurationLabel;

@end

@implementation TTVVideoDetailAlbumCellView

+ (TTVVideoDetailAlbumCellView *)genViewForArticle:(id<TTVArticleProtocol> )article
                                             width:(float)width
                                          infoFlag:(nullable NSNumber *)flag
                                    forVideoDetail:(BOOL)forVideoDetail
{
    TTVVideoDetailAlbumCellView * view = nil;
    TTVVideoDetailNatantRelateReadViewModel * viewModel = nil;
    if (!SSIsEmptyDictionary(article.videoDetailInfo)) {
        //视频频道相关视频，右图模式
        view = [[TTVVideoDetailAlbumCellView alloc] initWithWidth:width];
        viewModel = [[TTVVideoDetailNatantRelateReadViewModel alloc] init];
        view.viewModel = viewModel;
    }
    
    view.viewModel.pushAnimation = YES;
    view.viewModel.useForVideoDetail = forVideoDetail;
    return view;
}

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bgButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_bgButton addTarget:self action:@selector(bgButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _bgButton.frame = self.bounds;
        _bgButton.backgroundColor = [UIColor clearColor];;
        _bgButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        _bgButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_bgButton];
        
        self.titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_titleLabel];
        
        self.bottomLineView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColorThemeKey = kColorLine1;
        _bottomLineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bottomLineView];

        self.titleLabel.numberOfLines = 2;
        _commentCountLabel = [[UILabel alloc] init];
        _commentCountLabel.backgroundColor = [UIColor clearColor];
        _commentCountLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
        
        self.imageView = [[TTImageView alloc] init];
        self.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        self.imageView.hidden = NO;
        self.imageView.userInteractionEnabled = NO;

        [self addSubview:_commentCountLabel];
        [self addSubview:_imageView];
        [self updateVideoDurationLabel];
        [self reloadThemeUI];
    }
    return self;
}

- (void)refreshArticle:(id<TTVArticleProtocol>)article
{
    @try {
        if (!self.viewModel) {
            self.viewModel = [[TTVVideoDetailNatantRelateReadViewModel alloc] init];
        }
        [self.KVOController unobserve:self.viewModel.article];
        self.viewModel.article = article;
        __weak typeof(self) wself = self;
        [self.KVOController observe:self.viewModel.article keyPath:NSStringFromSelector(@selector(hasRead)) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            __strong typeof(wself) self = wself;
            [self refreshTitleUI];
        }];
    }
    @catch (NSException *exception) {
    }
    [self refreshUI];
}

- (void)refreshUI
{
    BOOL hasVideo = (([self.viewModel.article.groupFlags intValue] & kArticleGroupFlagsHasVideo) );

    self.titleLabel.font = [UIFont systemFontOfSize:[self titleLabelFontSize]];
    
    [_imageView setImageWithModel:[self listMiddleImageModelWithDict: self.viewModel.article.largeImageDict] placeholderImage:nil];

    float titleLabelHeight = [self titleHeightForArticle:self.viewModel.article cellWidth:self.width];

    NSString *countLabelText = nil;
    if (self.viewModel.useForVideoDetail) {
        countLabelText = [TTBusinessManager formatCommentCount:[[self.viewModel.article.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
        NSString *tailString = @"次播放";
        countLabelText = [countLabelText stringByAppendingString:tailString];
    } else {
        countLabelText = [NSString stringWithFormat:@"%d评论", self.viewModel.article.commentCount];
    }

    self.commentCountLabel.text = countLabelText;
    [self.commentCountLabel sizeToFit];

    CGFloat imageWidth;
    CGFloat imageheight;
    if (self.viewModel.useForVideoDetail) {
        imageWidth = [self.class videoDetailRelateVideoImageSizeWithWidth:self.width].width;
        imageheight = [self.class videoDetailRelateVideoImageSizeWithWidth:self.width].height;
    }
    else {
        imageWidth = [self imgWidth];
        imageheight = [self imgHeight];
    }

    CGFloat topPadding = self.viewModel.isSubVideoAlbum ? kAlbumTopPadding : kTopPadding;
    CGFloat bottomPadding = self.viewModel.isSubVideoAlbum ? kAlbumBottomPadding : kBottomPadding;

    _imageView.frame = CGRectMake(self.width - imageWidth - kRightPadding, topPadding, imageWidth, imageheight);
    
    CGFloat totalLabelHeight = titleLabelHeight + kFromeLabelTopPadding + (_commentCountLabel.height);
    float selfHeight = MAX(CGRectGetMaxY(_imageView.frame), totalLabelHeight + topPadding) + bottomPadding;
    
    self.frame = CGRectMake(0, 0, self.width, selfHeight);
    
    self.titleLabel.frame = CGRectMake(kLeftPadding, (selfHeight - totalLabelHeight) / 2, [self titleWidthForCellWidth:self.width], titleLabelHeight);
    self.commentCountLabel.frame = CGRectMake(_titleLabel.left,self.titleLabel.bottom + kFromeLabelTopPadding, _commentCountLabel.width, _commentCountLabel.height);

    [self refreshBottomLineView];
    [self sendSubviewToBack:self.bgButton];
    if (hasVideo) {
        [self updateVideoDurationLabel];
        [self layoutVideoDurationLabel];
    } else {
        _timeInfoBgView.hidden = YES;
    }

    self.timeInfoBgView.hidden = NO;

    [self refreshTitleWithTags:nil];
}

- (void)refreshTitleUI
{
//    //[self.viewModel.article.hasRead boolValue] &&
//    if (!self.viewModel.tags.count) {
//        _titleLabel.textColor = [UIColor colorWithDayColorName:@"999999" nightColorName:@"505050"];
//    }
//    else {
//        _titleLabel.textColor = SSGetThemedColorWithKey(kColorText1);
//    }
    
    _titleLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    if (self.viewModel.isCurrentPlaying) {
        _titleLabel.textColor = SSGetThemedColorWithKey(kColorText5);
    }
}

- (void)refreshTitleWithTags:(NSArray *)tags {
    self.viewModel.tags = tags;
    if (self.viewModel.article.title) {
        [_titleLabel setAttributedText: [self showTitleForTitle:self.viewModel.article.title tags:tags ]];
    }
}
- (NSAttributedString *)showTitleForTitle:(NSString *)title tags:(NSArray *)tags
{
    if (!tags.count) {
        return [[NSAttributedString alloc] initWithString:title];
    }
    else {
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        for (NSString * tag in tags) {
            NSRange range = [title rangeOfString:tag];
            if (range.location != NSNotFound) {
                [attrTitle addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kColorText5) range:range];
            }
        }
        return attrTitle;
    }
}

- (void)refreshBottomLineView
{
    _bottomLineView.frame = CGRectMake(kLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - kLeftPadding - kRightPadding, [TTDeviceHelper ssOnePixel]);
}

- (void)hideBottomLine:(BOOL)hide
{
    self.bottomLineView.hidden = hide;
}

-(void)bgButtonClicked
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRelatedClickedNotification" object:nil];
    [self.viewModel bgButtonClickedBaseViewController:[TTUIResponderHelper topNavigationControllerFor: self]];
}

- (void)setViewModel:(TTVVideoDetailNatantRelateReadViewModel *)viewModel
{
    if (self.viewModel != viewModel) {
        _viewModel = viewModel;
        [self removeKVO];
        [self addKVO];
    }
}

- (void)addKVO
{
    if (self.viewModel) {
        __weak typeof(self) wself = self;
        [self.KVOController observe:self.viewModel keyPath:NSStringFromSelector(@selector(isCurrentPlaying)) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            __strong typeof(wself) self = wself;
            [self refreshTitleUI];
        }];
        [self.KVOController observe:self.viewModel keyPath:NSStringFromSelector(@selector(isVideoAlbum)) options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
            __strong typeof(wself) self = wself;
            [self refreshUI];
        }];
    }
}

- (void)removeKVO
{
    if (self.viewModel) {
        [self.KVOController unobserve:self.viewModel];
    }
}

- (void)updateVideoDurationLabel {
    if (!_timeInfoBgView) {
        self.timeInfoBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _timeInfoBgView.layer.cornerRadius = KLabelInfoHeight/2;
        _timeInfoBgView.clipsToBounds = YES;
        self.timeInfoBgView.backgroundColor = [UIColor colorWithHexString:@"0000007f"];
        _timeInfoBgView.frame = CGRectMake(0, 0, 0, KLabelInfoHeight);
        [self.imageView addSubview:_timeInfoBgView];
    }
    
    if (!_videoIconView) {
        self.videoIconView = [[SSThemedImageView alloc] initWithImage:[UIImage themedImageNamed:@"palyicon_video_textpage.png"]];
        _videoIconView.imageName = @"palyicon_video_textpage.png";
        [self.timeInfoBgView addSubview:_videoIconView];
    }
    
    if (!_videoDurationLabel) {
        self.videoDurationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _videoDurationLabel.backgroundColor = [UIColor clearColor];
        _videoDurationLabel.textColor = SSGetThemedColorInArray(@[@"ffffff", @"cacaca"]);
        _videoDurationLabel.font = [UIFont systemFontOfSize:10];
        [self.timeInfoBgView addSubview:_videoDurationLabel];
    }
    long long duration = [self.viewModel.article.videoDuration longLongValue];
    if (duration > 0) {
        int minute = (int)duration / 60;
        int second = (int)duration % 60;
        [_videoDurationLabel setText:[NSString stringWithFormat:@"%02i:%02i", minute, second]];
    }
    else {
        [_videoDurationLabel setText:@""];
    }
    [_videoDurationLabel sizeToFit];
    
}

- (void)layoutVideoDurationLabel
{
    CGFloat videoIconViewWidth = self.viewModel.useForVideoDetail ? 0 : (_videoIconView.width);
    if (!isEmptyString(_videoDurationLabel.text)) {
        _timeInfoBgView.hidden = NO;
        CGFloat gap = 2;
        
        CGFloat width = kVideoIconLeftGap*2 + (_videoDurationLabel.width) + gap + videoIconViewWidth;
        width = MAX(width, 28);
        _timeInfoBgView.frame = CGRectMake((self.imageView.width) - width - 4, (self.imageView.height) - KLabelInfoHeight - 4, width, KLabelInfoHeight);
        _videoDurationLabel.hidden = NO;
        
        _videoIconView.hidden = self.viewModel.useForVideoDetail ? YES : NO;
        _videoIconView.left = kVideoIconLeftGap;
        _videoIconView.centerY = (_timeInfoBgView.height) / 2;
        if (self.viewModel.useForVideoDetail) {
            _videoDurationLabel.centerX = _timeInfoBgView.width / 2;
        }
        else {
            _videoDurationLabel.left = _videoIconView.right + gap;
        }
        _videoDurationLabel.centerY = (_timeInfoBgView.height) / 2;
    }
    else {
        _timeInfoBgView.hidden = NO;
        
        CGFloat width = kVideoIconLeftGap*2 + videoIconViewWidth;
        width = MAX(width, KLabelInfoHeight);
        _timeInfoBgView.frame = CGRectMake((self.imageView.width) - width - 4, (self.imageView.height) - KLabelInfoHeight - 4, width, KLabelInfoHeight);
        _videoDurationLabel.hidden = YES;
        _videoIconView.hidden = self.viewModel.useForVideoDetail ? YES : NO;
        _videoIconView.center = CGPointMake((_timeInfoBgView.width) / 2 + 1, (_timeInfoBgView.height) / 2);
    }
}

- (void)themeChanged:(NSNotification *)notification{
    
    [super themeChanged:notification];
    [self refreshTitleUI];
    if (self.viewModel.tags.count) {
        [self refreshTitleWithTags:self.viewModel.tags];
    }
    _commentCountLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
}

- (CGFloat)titleLabelFontSize
{
    CGFloat videoDetailFontSize;
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        videoDetailFontSize = 17.f;
    }
    else {
        videoDetailFontSize = 15.f;
    }
    return self.viewModel.useForVideoDetail ? videoDetailFontSize : kTitleFontSize;
}

+ (CGSize)videoDetailRelateVideoImageSizeWithWidth:(CGFloat)width{
    CGFloat iPhone6ScreenWidth = 375.f;
    CGFloat cellW = MIN(width, iPhone6ScreenWidth);
    float picOffsetX = 4.f;
    CGFloat w = (cellW - kLeftPadding - kRightPadding - picOffsetX * 2)/3;
    CGFloat h = w * (9.f / 16.f);
    w = ceilf(w);
    h = ceilf(h);
    return CGSizeMake(w, h);
}


- (float)titleWidthForCellWidth:(float)width{
    CGFloat titleWidth = width - [self imgWidth] - kRightPadding - kRightImgLeftPadding - kLeftPadding;
    if ([TTDeviceHelper is736Screen]) {
        titleWidth -= 2.f;
    }
    return titleWidth;
}

- (float)titleHeightForArticle:(id<TTVArticleProtocol>)article cellWidth:(float)width{
    float titleWidth = [self titleWidthForCellWidth:width];
    if (isEmptyString(article.title)) {
        return [self titleLabelFontSize];
    }
    return [TTLabelTextHelper heightOfText:article.title fontSize:[self titleLabelFontSize] forWidth:titleWidth constraintToMaxNumberOfLines:2];
}

- (CGFloat)imgWidth
{
    return [self.class imgSizeForViewWidth:self.width].width;
}

- (CGFloat)imgHeight
{
    return [self.class imgSizeForViewWidth:self.width].height;
}

+ (CGSize)imgSizeForViewWidth:(CGFloat)width{
    static float w = 0;
    static float h = 0;
    static float cellW = 0;
    if (h < 1 || cellW != width) {
        cellW = width;
        float picOffsetX = 4.f;
        w = (width - kLeftPadding - kRightPadding - picOffsetX * 2)/3;
        h = w * (9.f / 16.f);
        w = ceilf(w);
        h = ceilf(h);
    }
    return CGSizeMake(w, h);
}

- (TTImageInfosModel *)listMiddleImageModelWithDict: (NSDictionary *)imageDict
{
    if (![imageDict isKindOfClass:[NSDictionary class]] || [imageDict count] == 0) {
        return nil;
    }
    TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:imageDict];
    model.imageType = TTImageTypeMiddle;
    return model;
}

@end
