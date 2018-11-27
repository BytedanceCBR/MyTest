//
//  TTDetailNatantRelateReadView.m
//  Article
//
//  Created by Ray on 16/4/7.
//
//

#import "TTDetailNatantRelateReadView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTImageView.h"
#import <KVOController/KVOController.h>
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTOriginalLogo.h"
#import "SSUserSettingManager.h"
#import "NetworkUtilities.h"
#import "ArticleInfoManager.h"
#import "TTUserSettings/TTUserSettingsManager+NetworkTraffic.h"
#import "TTDeviceHelper.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIImage+TTThemeExtension.h"
#import "TTLabelTextHelper.h"
#import "TTAdManager.h"
#import "TTDeviceUIUtils.h"
#import "ExploreArticleCellViewConsts.h"

#import "TTVideoFontSizeManager.h"
#import "TTAdVideoRelateAdModel.h"

#define newkTitleFontSize [TTVideoFontSizeManager settedRelatedTitleFontSize]


@interface TTDetailNatantRelateReadPureTitleView ()

@end


@implementation TTDetailNatantRelateReadPureTitleView

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
        
        self.titleLeftCircleView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
        _titleLeftCircleView.backgroundColor = [UIColor colorWithHexString:@"505050"];
        _titleLeftCircleView.layer.cornerRadius = 1.5f;
        _titleLeftCircleView.clipsToBounds = YES;
        [self addSubview:_titleLeftCircleView];
        
        [self reloadThemeUI];
        
    }
    return self;
}

- (Class)viewModelClass
{
    return [TTDetailNatantRelateReadPureTitleViewModel class];
}

- (void)hideBottomLine:(BOOL)hide
{
    self.bottomLineView.hidden = hide;
}

-(void)bgButtonClicked
{
    BOOL closeMovie = NO;
    if ([self.viewModel.article isVideoSubject]) {
        closeMovie = YES;
    }
    if (self.viewModel.didSelectVideoAlbum || self.viewModel.actions.count > 0 || self.viewModel.isVideoAlbum) {
        closeMovie = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRelatedClickedNotification" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:closeMovie],@"deallocMovie", nil]];
    [self.viewModel bgButtonClickedBaseViewController:[TTUIResponderHelper topNavigationControllerFor: self]];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self refreshTitleUI];
    
    if (self.viewModel.tags.count) {
        [self refreshTitleWithTags:self.viewModel.tags];
    }
}

- (void)refreshTitleUI
{
    if ([self.viewModel.article.hasRead boolValue] && !self.viewModel.tags.count) {
        _titleLabel.textColor = [UIColor colorWithDayColorName:@"999999" nightColorName:@"505050"];
    }
    else {
        _titleLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    }
    
    if (self.viewModel.isCurrentPlaying) {
        _titleLabel.textColor = SSGetThemedColorWithKey(kColorText5);
    }
}

- (void)refreshTitleWithTags:(NSArray *)tags {
    self.viewModel.tags = tags;
    if (self.viewModel.article.title) {
        [_titleLabel setAttributedText:[TTDetailNatantRelateReadPureTitleViewModel showTitleForTitle:self.viewModel.article.title
                                                                                                tags:tags]];
    }
}

- (void)refreshUI
{
    _titleLabel.font = [UIFont systemFontOfSize:newkTitleFontSize];
    float titleLabelHeight = [self.viewModel titleHeightForArticle:self.viewModel.article cellWidth:self.width];
    self.frame = CGRectMake(0, 0, self.width, titleLabelHeight + kTopPadding + kBottomPadding);
    _titleLeftCircleView.origin = CGPointMake(kLeftPadding, (self.height - (_titleLeftCircleView.height)) / 2);
    _titleLabel.frame = CGRectMake(_titleLeftCircleView.right + 5, kTopPadding, self.width - (kLeftPadding + kRightPadding) - _titleLeftCircleView.width - 5, titleLabelHeight);
    
    [self refreshBottomLineView];
    
    [self sendSubviewToBack:_bgButton];
}

- (void)refreshBottomLineView
{
    _bottomLineView.frame = CGRectMake(kLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - kLeftPadding - kRightPadding, [TTDeviceHelper ssOnePixel]);
}


@end

@interface TTDetailNatantRelateReadRightImgView ()

@end

@implementation TTDetailNatantRelateReadRightImgView


- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.titleLeftCircleView.hidden = YES;
        self.titleLabel.numberOfLines = 2;
        
        _fromLabel = [[UILabel alloc] init];
        _fromLabel.backgroundColor = [UIColor clearColor];
        _fromLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
        
        _commentCountLabel = [[UILabel alloc] init];
        _commentCountLabel.backgroundColor = [UIColor clearColor];
        _commentCountLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
        
        self.imageView = [[TTImageView alloc] init];
        self.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        self.imageView.hidden = NO;
        self.imageView.userInteractionEnabled = NO;
        [self.imageView addSubview:self.albumCover];
        self.albumCover.hidden = YES;
        
        [self addSubview:_fromLabel];
        [self addSubview:_commentCountLabel];
        [self addSubview:_imageView];
        [self updateVideoDurationLabel];
        [self reloadThemeUI];
        
        [self.albumCover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.imageView);
            make.width.mas_equalTo(44);
        }];
        
        self.actionButton = [[SSThemedButton alloc] init];
        self.actionButton.backgroundColor = [UIColor clearColor];
        self.actionButton.titleColorThemeKey = kColorText5;
        self.actionButton.titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        self.actionButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.actionButton addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.actionButton];
        self.downloadIcon = [[SSThemedButton alloc] init];
        self.downloadIcon.imageName = @"download_ad_detais";
        self.downloadIcon.size = kDownloadIconSize;
        [self.downloadIcon addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.downloadIcon];
        self.actionButton.hidden = YES;
        self.downloadIcon.hidden = YES;
    }
    return self;
}

- (Class)viewModelClass
{
    return [TTDetailNatantRelateReadRightImgViewModel class];
}

- (SSThemedView *)albumCover
{
    if (!_albumCover) {
        _albumCover = [[SSThemedView alloc] init];
        _albumCover.backgroundColorThemeKey = kColorBackground15;
        
        SSThemedImageView *albumImageView = [[SSThemedImageView alloc] init];
        albumImageView.imageName = @"collect_video_details";
        [_albumCover addSubview:albumImageView];
        
        [albumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_albumCover);
            make.top.equalTo(_albumCover.mas_centerY).offset(1);
        }];
        
        self.albumCount = [[SSThemedLabel alloc] init];
        self.albumCount.textColorThemeKey = kColorText12;
        self.albumCount.font = [UIFont systemFontOfSize:14];
        
        [_albumCover addSubview:self.albumCount];
        
        [self.albumCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_albumCover);
            make.bottom.equalTo(_albumCover.mas_centerY).offset(-2);
        }];
    }
    return _albumCover;
}

- (void)setViewModel:(TTDetailNatantRelateReadViewModel *)viewModel
{
    if (self.viewModel != viewModel) {
        [self removeKVO];
        [super setViewModel:viewModel];
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

- (void)refreshBottomLineView {
    
}

- (void)removeKVO
{
    if (self.viewModel) {
        [self.KVOController unobserve:self.viewModel];
    }
}

- (void)refreshUI
{
    BOOL hasVideo = (([self.viewModel.article.groupFlags intValue] & kArticleGroupFlagsHasVideo) || [[self.viewModel.article hasVideo] boolValue]);
    
    self.titleLabel.font = [UIFont systemFontOfSize:[self titleLabelFontSize]];
    [_imageView setImageWithModel:self.viewModel.article.listMiddleImageModel placeholderImage:nil];
    
    float titleLabelHeight = [self titleHeightForArticle:self.viewModel.article cellWidth:self.width];
    
    CGFloat fromLabelMaxLen = 120;
    self.fromLabel.text = self.viewModel.article.source ?: self.viewModel.article.mediaName;
    [self.fromLabel sizeToFit];
    
    self.albumCount.text = [@(self.viewModel.article.commentCount) stringValue];
    
    NSString *countLabelText = nil;
    if (self.viewModel.useForVideoDetail) {
        countLabelText = [TTBusinessManager formatCommentCount:[[self.viewModel.article.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
        NSString *tailString = @"次播放";
        if (self.viewModel.isVideoAlbum) {
            countLabelText = [TTBusinessManager formatCommentCount:self.viewModel.article.commentCount];
            tailString = @"个视频";
        }
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
    
    CGFloat totalLabelHeight = titleLabelHeight + kFromeLabelTopPadding + (_fromLabel.height);
    float selfHeight = MAX(CGRectGetMaxY(_imageView.frame), totalLabelHeight + topPadding) + bottomPadding;
    
    self.frame = CGRectMake(0, 0, self.width, selfHeight);
    
    self.titleLabel.frame = CGRectMake(kLeftPadding, (selfHeight - totalLabelHeight) / 2, [self titleWidthForCellWidth:self.width], titleLabelHeight);
    
    if ([[self.viewModel.article.relatedVideoExtraInfo allKeys] containsObject:kArticleInfoRelatedVideoTagKey]) {
        if (!_albumLogo) {
            NSString *logoText = self.viewModel.article.relatedVideoExtraInfo[kArticleInfoRelatedVideoTagKey];
            _albumLogo = [TTOriginalLogo originalLabelWithRect:CGRectMake(0, 0, 26, 14) text:logoText textFontSize:10 textColorKey:kColorText5 lineColorKey:kColorLine6 cornerRadius:3];
            [self addSubview:_albumLogo];
        }
        self.albumCover.hidden = self.viewModel.isVideoAlbum ? NO : YES;
        self.albumLogo.hidden = NO;
        self.albumLogo.left = self.titleLabel.left;
        self.fromLabel.frame = CGRectMake(self.albumLogo.right + 5, self.titleLabel.bottom + kFromeLabelTopPadding, MIN(self.fromLabel.width, fromLabelMaxLen), self.fromLabel.height);
        
        self.albumLogo.centerY = self.fromLabel.centerY;
    } else if ([self.viewModel.article relatedVideoType] == ArticleRelatedVideoTypeAd) {
        
    } else {
        self.albumCover.hidden = YES;
        self.albumLogo.hidden = YES;
        self.fromLabel.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + kFromeLabelTopPadding, MIN(self.fromLabel.width, fromLabelMaxLen), self.fromLabel.height);
    }
    self.commentCountLabel.frame = CGRectMake(_fromLabel.right + 10, _fromLabel.top, _commentCountLabel.width, _commentCountLabel.height);
    [self refreshBottomLineView];
    [self sendSubviewToBack:self.bgButton];
    if (hasVideo) {
        [self updateVideoDurationLabel];
        [self layoutVideoDurationLabel];
    } else {
        _timeInfoBgView.hidden = YES;
    }
    if (self.viewModel.isVideoAlbum) {
        self.timeInfoBgView.hidden = YES;
    } else {
        self.timeInfoBgView.hidden = NO;
    }
    TTAdVideoRelateAdModel* videoAdExtra = self.viewModel.article.videoAdExtra;
    if (videoAdExtra&&[videoAdExtra.card_type isEqualToString:@"ad_video"]){
        [self layoutActionButton];
    }
}

- (void)layoutActionButton
{
    TTAdVideoRelateAdModel* videoAdExtra = self.viewModel.article.videoAdExtra;
    if ([videoAdExtra.ui_type integerValue]) {
        self.actionButton.titleColorThemeKey = kColorText6;
        self.downloadIcon.imageName = @"download_ad_feed";
        _albumLogo.textColorThemeKey = kColorText6;
        _albumLogo.borderColorThemeKey = kColorLine3;
        [self layoutActionButton_NewButton];
        return;
    }
    if ([videoAdExtra.creative_type isEqualToString:@"action"]) {
        self.actionButton.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = self.titleLabel.right;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width -5;
        self.commentCountLabel.hidden = YES;
    }
    else if([videoAdExtra.creative_type isEqualToString:@"app"])
    {
        self.actionButton.hidden = NO;
        self.downloadIcon.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = self.titleLabel.right;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.downloadIcon.right = self.actionButton.left - 4;
        self.downloadIcon.centerY = self.actionButton.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width - kDownloadIconSize.width - 5 - 4;
        self.commentCountLabel.hidden = YES;
    }
    else if ([videoAdExtra.creative_type isEqualToString:@"form"]) {
        self.actionButton.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = self.titleLabel.right;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width -5;
        self.commentCountLabel.hidden = YES;
    }
}

- (void)layoutActionButton_NewButton
{
    TTAdVideoRelateAdModel* videoAdExtra = self.viewModel.article.videoAdExtra;
    if (![@[@"action", @"app", @"form"] containsObject:videoAdExtra.creative_type]) {
        return;
    }
    self.actionButton.hidden = NO;
    self.downloadIcon.hidden = NO;
    self.fromLabel.hidden = YES;
    self.commentCountLabel.hidden = YES;
    [self.actionButton setTitle:[NSString stringWithFormat:@"%@: %@", videoAdExtra.button_text, videoAdExtra.source] forState:UIControlStateNormal];
    [self.actionButton sizeToFit];
    self.downloadIcon.left = self.albumLogo.right + 12;
    self.downloadIcon.centerY = self.albumLogo.centerY;
    self.actionButton.left = self.downloadIcon.right + 4;
    self.actionButton.centerY = self.albumLogo.centerY;
    
    CGFloat iconWith = [videoAdExtra.creative_type isEqualToString:@"form"] ? 0 : kDownloadIconSize.width + 4;
    CGFloat actionButton_MaxWidth = self.titleLabel.width - self.albumLogo.width - iconWith - 12;
    if (self.actionButton.width > actionButton_MaxWidth) {
        self.actionButton.width = actionButton_MaxWidth;
    }
    
    if ([videoAdExtra.creative_type isEqualToString:@"action"]) {
        self.downloadIcon.imageName = @"cellphone_ad_feed";
    } else if ([videoAdExtra.creative_type isEqualToString:@"app"]) {
        self.downloadIcon.imageName = @"download_ad_feed";
    } else if ([videoAdExtra.creative_type isEqualToString:@"form"]) {
        self.downloadIcon.hidden = YES;
        self.actionButton.left = self.albumLogo.right + 12;
    }
}

- (void)hideFromLabel:(BOOL)hide
{
    if (hide) {
        self.commentCountLabel.left = self.fromLabel.left;
        self.fromLabel.hidden = YES;
    } else {
        self.commentCountLabel.left = self.fromLabel.right + 10;
        self.fromLabel.hidden = NO;
    }
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    _fromLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    _commentCountLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
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

- (void)handleAction:(SSThemedButton*)button
{
    if (self.viewModel.article) {
        [TTAdManageInstance video_relateHandleAction:self.viewModel.article];
    }
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
    return self.viewModel.useForVideoDetail ? newkTitleFontSize : videoDetailFontSize;
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

- (float)titleHeightForArticle:(Article *)article cellWidth:(float)width{
    float titleWidth = [self titleWidthForCellWidth:width];
    if (isEmptyString(article.title)) {
        return [self titleLabelFontSize];
    }
    return [TTLabelTextHelper heightOfText:article.title fontSize:[self titleLabelFontSize] forWidth:titleWidth constraintToMaxNumberOfLines:2];
}
@end

@interface TTDetailNatantRelateReadGroupImgView : TTDetailNatantRelateReadPureTitleView
@property(nonatomic, strong)TTImageView * leftImageView;
@property(nonatomic, strong)TTImageView * centerImageView;
@property(nonatomic, strong)TTImageView * rightImageView;
@end

@implementation TTDetailNatantRelateReadGroupImgView


- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.titleLeftCircleView.hidden = YES;
        self.titleLabel.numberOfLines = 0;
        
        self.leftImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, [self imgWidth], [self imgHeight])];
        _leftImageView.backgroundColorThemeKey = kColorBackground2;
        _leftImageView.userInteractionEnabled = NO;
        [self addSubview:_leftImageView];
        
        self.centerImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, [self imgWidth], [self imgHeight])];
        _centerImageView.backgroundColorThemeKey = kColorBackground2;
        _centerImageView.userInteractionEnabled = NO;
        [self addSubview:_centerImageView];
        
        self.rightImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, [self imgWidth], [self imgHeight])];
        _rightImageView.backgroundColorThemeKey = kColorBackground2;
        _rightImageView.userInteractionEnabled = NO;
        [self addSubview:_rightImageView];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)refreshUI
{
    self.titleLabel.font = [UIFont systemFontOfSize:newkTitleFontSize];
    float titleLabelHeight = [self titleHeightForArticle:self.viewModel.article cellWidth:self.width];
    self.titleLabel.frame = CGRectMake(kLeftPadding, kTopPadding, [self titleWidthForCellWidth:self.width], titleLabelHeight);
    UIImage *placeholder = nil;
    NSArray * imgModels = self.viewModel.article.listGroupImgModels;
    if ([imgModels count] > 0) {
        TTImageInfosModel * model = [imgModels objectAtIndex:0];
        [_leftImageView setImageWithModel:model placeholderImage:placeholder];
    }
    _leftImageView.origin = CGPointMake(kLeftPadding, CGRectGetMaxY(self.titleLabel.frame) + kGroupImgBottomPadding);
    if ([imgModels count] > 1) {
        TTImageInfosModel * model = [imgModels objectAtIndex:1];
        [_centerImageView setImageWithModel:model placeholderImage:placeholder];
    }
    float originX = (self.width - kLeftPadding - kRightPadding - [self imgWidth] * 3) / 2 + CGRectGetMaxX(_leftImageView.frame);
    _centerImageView.origin = CGPointMake(originX, CGRectGetMinY(self.leftImageView.frame));
    
    if ([imgModels count] > 2) {
        TTImageInfosModel * model = [imgModels objectAtIndex:2];
        [_rightImageView setImageWithModel:model placeholderImage:placeholder];
    }
    _rightImageView.origin = CGPointMake(self.width - kRightPadding - [self imgWidth], CGRectGetMinY(self.leftImageView.frame));
    self.frame = CGRectMake(0, 0, self.width, CGRectGetMaxY(_leftImageView.frame) + kBottomPadding);
    [self refreshBottomLineView];
    [self sendSubviewToBack:self.bgButton];
}

- (float)titleWidthForCellWidth:(float)width
{
    return width - kRightPadding - kLeftPadding;
}

- (float)titleHeightForArticle:(Article *)article cellWidth:(float)width
{
    if (isEmptyString(article.title)) {
        return newkTitleFontSize;
    }
    float height = [TTLabelTextHelper heightOfText:article.title fontSize:newkTitleFontSize forWidth:[self titleWidthForCellWidth:width]];
    return height;
}

@end


@implementation TTDetailNatantRelateReadView

- (Class)viewModelClass
{
    return [TTDetailNatantRelateReadViewModel class];
}

- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(0, 0, width, 0)];
    if (self) {
        [self reloadThemeUI];
    }
    return self;
}

- (void)refreshUI
{
    
}

- (CGFloat)imgWidth
{
    return [TTDetailNatantRelateReadView imgSizeForViewWidth:self.width].width;
}

- (CGFloat)imgHeight
{
    return [TTDetailNatantRelateReadView imgSizeForViewWidth:self.width].height;
}

- (void)refreshTitleWithTags:(NSArray *)tags{}

- (void)hideFromLabel:(BOOL)hide{}

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

+ (nullable TTDetailNatantRelateReadView *)genViewForArticle:(nullable Article *)article width:(float)width infoFlag:(nullable NSNumber *)flag{
    return [self genViewForArticle:article width:width infoFlag:flag forVideoDetail:NO];
}

+ (nullable TTDetailNatantRelateReadView *)genViewForArticle:(nullable Article *)article
                                                       width:(float)width
                                                    infoFlag:(nullable NSNumber *)flag
                                              forVideoDetail:(BOOL)forVideoDetail
{
    TTDetailNatantRelateReadView * view = nil;
    TTDetailNatantRelateReadViewModel * viewModel = nil;
    if (!SSIsEmptyDictionary(article.videoDetailInfo)) {
        
        if (forVideoDetail && [SSCommonLogic videoDetailRelatedStyle] == 2 && flag.integerValue != 1) {// 合辑暂时不支持双列
            
            view = [[TTDetailNatantRelateReadTopImgView alloc] initWithWidth:width];
            
        } else if (forVideoDetail && [SSCommonLogic videoDetailRelatedStyle] == 1) {
            // 左图模式
            view = [[TTDetailNatantRelateReadLeftImgView alloc] initWithWidth:width];
        } else {
            //视频频道相关视频，右图模式
            view = [[TTDetailNatantRelateReadRightImgView alloc] initWithWidth:width];
        }
        
        viewModel = [[TTDetailNatantRelateReadRightImgViewModel alloc] init];
        view.viewModel = viewModel;
    }
    else {
        BOOL couldShowImg = [article.groupFlags intValue] & kArticleGroupFlagsDetailRelateReadShowImg;
        if ([TTDeviceHelper isPadDevice] || !couldShowImg) { //强制无图
            view = [[TTDetailNatantRelateReadPureTitleView alloc] initWithWidth:width];
            viewModel = [[TTDetailNatantRelateReadPureTitleViewModel alloc] init];
            view.viewModel = viewModel;
        }
        else {
            if ([article.listGroupImgModels count] > 0 && (TTNetworkWifiConnected() || (!TTNetworkWifiConnected() && [TTUserSettingsManager networkTrafficSetting] == TTNetworkTrafficOptimum))) {//wifi，或者非wifi并设置了较省流量情况下展示组图
                view = [[TTDetailNatantRelateReadGroupImgView alloc] initWithWidth:width];
            }
            else if (article.listMiddleImageModel && (TTNetworkWifiConnected() || (!TTNetworkWifiConnected() && [TTUserSettingsManager networkTrafficSetting] != TTNetworkTrafficSave))) {//wifi 或者非wifi并且没有设置无图模式的时候展示右图
                view = [[TTDetailNatantRelateReadRightImgView alloc] initWithWidth:width];
            }
            else {
                view = [[TTDetailNatantRelateReadPureTitleView alloc] initWithWidth:width];
            }
        }
    }
    
    view.viewModel.pushAnimation = YES;
    view.viewModel.useForVideoDetail = forVideoDetail;
    [view refreshArticle:article];
    return view;
}

- (void)refreshTitleUI{
}

- (void)refreshWithWidth:(CGFloat)width{
    [super refreshWithWidth:width];
    [self refreshUI];
}

- (void)hideBottomLine:(BOOL)hide{
    // do nothing...
}

- (void)refreshArticle:(Article *)article{
    @try {
        if (!self.viewModel) {
            self.viewModel = [[[self viewModelClass] alloc] init];
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

- (float)titleHeightForArticle:(Article *)article cellWidth:(float)width{
    return 0;
}


@end

@interface TTDetailNatantRelateReadLeftImgView ()

@end

@implementation TTDetailNatantRelateReadLeftImgView
- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.titleLeftCircleView.hidden = YES;
        self.titleLabel.numberOfLines = 2;
        
        _fromLabel = [[UILabel alloc] init];
        _fromLabel.backgroundColor = [UIColor clearColor];
        _fromLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
        
        _commentCountLabel = [[UILabel alloc] init];
        _commentCountLabel.backgroundColor = [UIColor clearColor];
        _commentCountLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
        
        self.imageView = [[TTImageView alloc] init];
        self.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        self.imageView.hidden = NO;
        self.imageView.userInteractionEnabled = NO;
        [self.imageView addSubview:self.albumCover];
        self.albumCover.hidden = YES;
        
        [self addSubview:_fromLabel];
        [self addSubview:_commentCountLabel];
        [self addSubview:_imageView];
        [self updateVideoDurationLabel];
        [self reloadThemeUI];
        
        [self.albumCover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.imageView);
            make.width.mas_equalTo(44);
        }];
        
        self.actionButton = [[SSThemedButton alloc] init];
        self.actionButton.backgroundColor = [UIColor clearColor];
        self.actionButton.titleColorThemeKey = kColorText5;
        self.actionButton.titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        [self.actionButton addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.actionButton];
        self.downloadIcon = [[SSThemedButton alloc] init];
        self.downloadIcon.imageName = @"download_ad_detais";
        self.downloadIcon.size = kDownloadIconSize;
        [self.downloadIcon addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.downloadIcon];
        self.actionButton.hidden = YES;
        self.downloadIcon.hidden = YES;
    }
    return self;
}

- (Class)viewModelClass
{
    return [TTDetailNatantRelateReadRightImgViewModel class];
}

- (SSThemedView *)albumCover
{
    if (!_albumCover) {
        _albumCover = [[SSThemedView alloc] init];
        _albumCover.backgroundColorThemeKey = kColorBackground15;
        
        SSThemedImageView *albumImageView = [[SSThemedImageView alloc] init];
        albumImageView.imageName = @"collect_video_details";
        [_albumCover addSubview:albumImageView];
        
        [albumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_albumCover);
            make.top.equalTo(_albumCover.mas_centerY).offset(1);
        }];
        
        self.albumCount = [[SSThemedLabel alloc] init];
        self.albumCount.textColorThemeKey = kColorText12;
        self.albumCount.font = [UIFont systemFontOfSize:14];
        
        [_albumCover addSubview:self.albumCount];
        
        [self.albumCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_albumCover);
            make.bottom.equalTo(_albumCover.mas_centerY).offset(-2);
        }];
    }
    return _albumCover;
}

- (void)setViewModel:(TTDetailNatantRelateReadViewModel *)viewModel
{
    if (self.viewModel != viewModel) {
        [self removeKVO];
        [super setViewModel:viewModel];
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

- (void)refreshBottomLineView {
    
}

- (void)removeKVO
{
    if (self.viewModel) {
        [self.KVOController unobserve:self.viewModel];
    }
}

- (void)refreshUI
{
    BOOL hasVideo = (([self.viewModel.article.groupFlags intValue] & kArticleGroupFlagsHasVideo) || [[self.viewModel.article hasVideo] boolValue]);
    
    self.titleLabel.font = [UIFont systemFontOfSize:[self titleLabelFontSize]];
    [_imageView setImageWithModel:self.viewModel.article.listMiddleImageModel placeholderImage:nil];
    
    float titleLabelHeight = [self titleHeightForArticle:self.viewModel.article cellWidth:self.width];
    
    CGFloat fromLabelMaxLen = 120;
    self.fromLabel.text = self.viewModel.article.source ?: self.viewModel.article.mediaName;
    [self.fromLabel sizeToFit];
    
    self.albumCount.text = [@(self.viewModel.article.commentCount) stringValue];
    
    NSString *countLabelText = nil;
    if (self.viewModel.useForVideoDetail) {
        countLabelText = [TTBusinessManager formatCommentCount:[[self.viewModel.article.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
        NSString *tailString = @"次播放";
        if (self.viewModel.isVideoAlbum) {
            countLabelText = [TTBusinessManager formatCommentCount:self.viewModel.article.commentCount];
            tailString = @"个视频";
        }
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
    
    _imageView.frame = CGRectMake(kLeftPadding, topPadding, imageWidth, imageheight);
    
    CGFloat totalLabelHeight = titleLabelHeight + kFromeLabelTopPadding + (_fromLabel.height);
    float selfHeight = MAX(CGRectGetMaxY(_imageView.frame), totalLabelHeight + topPadding) + bottomPadding;
    
    self.frame = CGRectMake(0, 0, self.width, selfHeight);
    
    CGFloat titleLabelWidth = [self titleWidthForCellWidth:self.width];
    self.titleLabel.frame = CGRectMake(self.width - kRightPadding - titleLabelWidth, (selfHeight - totalLabelHeight) / 2, titleLabelWidth, titleLabelHeight);
    
    if ([[self.viewModel.article.relatedVideoExtraInfo allKeys] containsObject:kArticleInfoRelatedVideoTagKey]) {
        if (!_albumLogo) {
            NSString *logoText = self.viewModel.article.relatedVideoExtraInfo[kArticleInfoRelatedVideoTagKey];
            _albumLogo = [TTOriginalLogo originalLabelWithRect:CGRectMake(0, 0, 26, 14) text:logoText textFontSize:10 textColorKey:kColorText5 lineColorKey:kColorLine6 cornerRadius:3];
            [self addSubview:_albumLogo];
        }
        self.albumCover.hidden = self.viewModel.isVideoAlbum ? NO : YES;
        self.albumLogo.hidden = NO;
        self.albumLogo.left = self.titleLabel.left;
        self.fromLabel.frame = CGRectMake(self.albumLogo.right + 5, self.titleLabel.bottom + kFromeLabelTopPadding, MIN(self.fromLabel.width, fromLabelMaxLen), self.fromLabel.height);
        
        self.albumLogo.centerY = self.fromLabel.centerY;
    } else if ([self.viewModel.article relatedVideoType] == ArticleRelatedVideoTypeAd) {
        
    } else {
        self.albumCover.hidden = YES;
        self.albumLogo.hidden = YES;
        self.fromLabel.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + kFromeLabelTopPadding, MIN(self.fromLabel.width, fromLabelMaxLen), self.fromLabel.height);
    }
    self.commentCountLabel.frame = CGRectMake(_fromLabel.right + 10, _fromLabel.top, _commentCountLabel.width, _commentCountLabel.height);
    [self refreshBottomLineView];
    [self sendSubviewToBack:self.bgButton];
    if (hasVideo) {
        [self updateVideoDurationLabel];
        [self layoutVideoDurationLabel];
    } else {
        _timeInfoBgView.hidden = YES;
    }
    if (self.viewModel.isVideoAlbum) {
        self.timeInfoBgView.hidden = YES;
    } else {
        self.timeInfoBgView.hidden = NO;
    }
    TTAdVideoRelateAdModel* videoAdExtra = self.viewModel.article.videoAdExtra;
    if (videoAdExtra&&[videoAdExtra.card_type isEqualToString:@"ad_video"]){
        [self layoutActionButton];
    }
}

- (void)layoutActionButton
{
    TTAdVideoRelateAdModel* videoAdExtra = self.viewModel.article.videoAdExtra;
    if ([videoAdExtra.creative_type isEqualToString:@"action"]) {
        self.actionButton.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = self.titleLabel.right;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width -5;
        self.commentCountLabel.hidden = YES;
    }
    else if([videoAdExtra.creative_type isEqualToString:@"app"])
    {
        self.actionButton.hidden = NO;
        self.downloadIcon.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = self.titleLabel.right;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.downloadIcon.right = self.actionButton.left - 4;
        self.downloadIcon.centerY = self.actionButton.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width - kDownloadIconSize.width - 5 - 4;
        self.commentCountLabel.hidden = YES;
    }
    
    
}

- (void)hideFromLabel:(BOOL)hide
{
    if (hide) {
        self.commentCountLabel.left = self.fromLabel.left;
        self.fromLabel.hidden = YES;
    } else {
        self.commentCountLabel.left = self.fromLabel.right + 10;
        self.fromLabel.hidden = NO;
    }
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    _fromLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    _commentCountLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
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

- (void)handleAction:(SSThemedButton*)button
{
    if (self.viewModel.article) {
        [TTAdManageInstance video_relateHandleAction:self.viewModel.article];
    }
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

- (float)titleHeightForArticle:(Article *)article cellWidth:(float)width{
    float titleWidth = [self titleWidthForCellWidth:width];
    if (isEmptyString(article.title)) {
        return [self titleLabelFontSize];
    }
    return [TTLabelTextHelper heightOfText:article.title fontSize:[self titleLabelFontSize] forWidth:titleWidth constraintToMaxNumberOfLines:2];
}
@end

@implementation TTDetailNatantRelateReadTopImgView
- (id)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        self.titleLeftCircleView.hidden = YES;
        self.titleLabel.numberOfLines = 2;
        
        _fromLabel = [[UILabel alloc] init];
        _fromLabel.backgroundColor = [UIColor clearColor];
        _fromLabel.font = [UIFont systemFontOfSize:[self cellInfoLabelFontSize]];
        
        _commentCountLabel = [[UILabel alloc] init];
        _commentCountLabel.backgroundColor = [UIColor clearColor];
        _commentCountLabel.font = [UIFont systemFontOfSize:[self cellInfoLabelFontSize]];
        
        self.imageView = [[TTImageView alloc] init];
        self.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        self.imageView.hidden = NO;
        self.imageView.userInteractionEnabled = NO;
        [self.imageView addSubview:self.albumCover];
        self.albumCover.hidden = YES;
        
        [self addSubview:_fromLabel];
        [self addSubview:_commentCountLabel];
        [self addSubview:_imageView];
        [self updateVideoDurationLabel];
        [self reloadThemeUI];
        
        [self.albumCover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.imageView);
            make.width.mas_equalTo(44);
        }];
        
        self.actionButton = [[SSThemedButton alloc] init];
        self.actionButton.backgroundColor = [UIColor clearColor];
        self.actionButton.titleColorThemeKey = kColorText5;
        self.actionButton.titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        [self.actionButton addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.actionButton];
        self.downloadIcon = [[SSThemedButton alloc] init];
        self.downloadIcon.imageName = @"download_ad_detais";
        self.downloadIcon.size = kDownloadIconSize;
        [self.downloadIcon addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.downloadIcon];
        self.actionButton.hidden = YES;
        self.downloadIcon.hidden = YES;
    }
    return self;
}

- (Class)viewModelClass
{
    return [TTDetailNatantRelateReadRightImgViewModel class];
}

- (SSThemedView *)albumCover
{
    if (!_albumCover) {
        _albumCover = [[SSThemedView alloc] init];
        _albumCover.backgroundColorThemeKey = kColorBackground15;
        
        SSThemedImageView *albumImageView = [[SSThemedImageView alloc] init];
        albumImageView.imageName = @"collect_video_details";
        [_albumCover addSubview:albumImageView];
        
        [albumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_albumCover);
            make.top.equalTo(_albumCover.mas_centerY).offset(1);
        }];
        
        self.albumCount = [[SSThemedLabel alloc] init];
        self.albumCount.textColorThemeKey = kColorText12;
        self.albumCount.font = [UIFont systemFontOfSize:14];
        
        [_albumCover addSubview:self.albumCount];
        
        [self.albumCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_albumCover);
            make.bottom.equalTo(_albumCover.mas_centerY).offset(-2);
        }];
    }
    return _albumCover;
}

- (void)setViewModel:(TTDetailNatantRelateReadViewModel *)viewModel
{
    if (self.viewModel != viewModel) {
        [self removeKVO];
        [super setViewModel:viewModel];
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

- (void)refreshBottomLineView {
    
}

- (void)removeKVO
{
    if (self.viewModel) {
        [self.KVOController unobserve:self.viewModel];
    }
}

- (void)refreshUI
{
    // 简直了 真特么想重写
    BOOL hasVideo = (([self.viewModel.article.groupFlags intValue] & kArticleGroupFlagsHasVideo) || [[self.viewModel.article hasVideo] boolValue]);
    
    self.titleLabel.font = [UIFont systemFontOfSize:[self titleLabelFontSize]];
    [_imageView setImageWithModel:self.viewModel.article.listMiddleImageModel placeholderImage:nil];
    
    float titleLabelHeight = [self titleHeightForArticle:self.viewModel.article cellWidth:self.width];
    
    CGFloat fromLabelMaxLen = 80;
    self.fromLabel.text = self.viewModel.article.source ?: self.viewModel.article.mediaName;
    [self.fromLabel sizeToFit];
    
    self.albumCount.text = [@(self.viewModel.article.commentCount) stringValue];
    
    NSString *countLabelText = nil;
    if (self.viewModel.useForVideoDetail) {
        countLabelText = [TTBusinessManager formatCommentCount:[[self.viewModel.article.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
        NSString *tailString = @"次播放";
        countLabelText = [countLabelText stringByAppendingString:tailString];
        if (self.viewModel.isVideoAlbum) {
            countLabelText = @"";//[TTBusinessManager formatCommentCount:self.viewModel.article.commentCount];
        }
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
    
    _imageView.frame = CGRectMake(0, topPadding, imageWidth, imageheight);
    
    CGFloat totalLabelHeight = titleLabelHeight + kFromeLabelTopPadding + (_fromLabel.height);
    self.height = CGRectGetMaxY(_imageView.frame) + kTitleTopPaddingForTopType + totalLabelHeight + bottomPadding;
    
    
    CGFloat titleLabelWidth = [self titleWidthForCellWidth:self.width];
    self.titleLabel.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame) + kTitleTopPaddingForTopType, titleLabelWidth, titleLabelHeight);
    
    if ([[self.viewModel.article.relatedVideoExtraInfo allKeys] containsObject:kArticleInfoRelatedVideoTagKey]) {
        if (!_albumLogo) {
            NSString *logoText = self.viewModel.article.relatedVideoExtraInfo[kArticleInfoRelatedVideoTagKey];
            _albumLogo = [TTOriginalLogo originalLabelWithRect:CGRectMake(0, 0, 26, 14) text:logoText textFontSize:10 textColorKey:kColorText6 lineColorKey:kColorLine3 cornerRadius:3];
            [self addSubview:_albumLogo];
        }
        self.albumCover.hidden = self.viewModel.isVideoAlbum ? NO : YES;
        self.albumLogo.hidden = NO;
        self.albumLogo.left = self.titleLabel.left;
        self.fromLabel.frame = CGRectMake(self.albumLogo.right + 5, self.titleLabel.bottom + kFromeLabelTopPadding, MIN(self.fromLabel.width, fromLabelMaxLen), self.fromLabel.height);
        
        self.albumLogo.centerY = self.fromLabel.centerY;
    } else if ([self.viewModel.article relatedVideoType] == ArticleRelatedVideoTypeAd) {
        
    } else {
        self.albumCover.hidden = YES;
        self.albumLogo.hidden = YES;
        self.fromLabel.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + kFromeLabelTopPadding, MIN(self.fromLabel.width, fromLabelMaxLen), self.fromLabel.height);
    }
    if (!isEmptyString(self.commentCountLabel.text)) {
        self.commentCountLabel.frame = CGRectMake(_fromLabel.right + 10, _fromLabel.top, _commentCountLabel.width, _commentCountLabel.height);
        if (self.commentCountLabel.right > self.titleLabel.right) {
            
            self.commentCountLabel.right = self.titleLabel.right - 3;
            self.fromLabel.right = self.commentCountLabel.left - 3;
            
            if (self.albumLogo.hidden) {
                
                self.fromLabel.left = self.titleLabel.left;
            } else {
                self.fromLabel.left = self.albumLogo.right + 2;
            }
        }
    } else {
        
        self.commentCountLabel.hidden = YES;
        self.fromLabel.width = self.titleLabel.right - self.albumLogo.right - 10;
    }
    
    [self refreshBottomLineView];
    [self sendSubviewToBack:self.bgButton];
    if (hasVideo) {
        [self updateVideoDurationLabel];
        [self layoutVideoDurationLabel];
    } else {
        _timeInfoBgView.hidden = YES;
    }
    if (self.viewModel.isVideoAlbum) {
        self.timeInfoBgView.hidden = YES;
    } else {
        self.timeInfoBgView.hidden = NO;
    }
    TTAdVideoRelateAdModel* videoAdExtra = self.viewModel.article.videoAdExtra;
    if (videoAdExtra&&[videoAdExtra.card_type isEqualToString:@"ad_video"]){
        [self layoutActionButton];
    }
}

- (void)layoutActionButton
{
    TTAdVideoRelateAdModel* videoAdExtra = self.viewModel.article.videoAdExtra;
    if ([videoAdExtra.creative_type isEqualToString:@"action"]) {
        self.actionButton.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = (self.isRight) ? self.imageView.right : self.imageView.right - 11.f;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width - 5;
        self.commentCountLabel.hidden = YES;
    }
    else if([videoAdExtra.creative_type isEqualToString:@"app"])
    {
        self.actionButton.hidden = NO;
        self.downloadIcon.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = (self.isRight) ? self.imageView.right : self.imageView.right - 11.f;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.downloadIcon.right = self.actionButton.left - 3.f;
        self.downloadIcon.centerY = self.actionButton.centerY;
        self.fromLabel.width = self.downloadIcon.left - 12 - self.albumLogo.right - 5;
        self.commentCountLabel.hidden = YES;
    }
}

- (void)hideFromLabel:(BOOL)hide
{
    if (hide) {
        self.commentCountLabel.left = self.fromLabel.left;
        self.fromLabel.hidden = YES;
    } else {
        self.commentCountLabel.left = self.fromLabel.right + 10;
        self.fromLabel.hidden = NO;
    }
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    _fromLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
    _commentCountLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
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

- (void)handleAction:(SSThemedButton*)button
{
    if (self.viewModel.article) {
        [TTAdManageInstance video_relateHandleAction:self.viewModel.article];
    }
}

- (CGFloat)titleLabelFontSize
{
    CGFloat videoDetailFontSize;
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        videoDetailFontSize = 16.f;
    }
    else {
        videoDetailFontSize = 14.f;
    }
    return self.viewModel.useForVideoDetail ? videoDetailFontSize : kTitleFontSize;
}

+ (CGSize)videoDetailRelateVideoImageSizeWithWidth:(CGFloat)width{
    CGFloat iPhone6ScreenWidth = 375.f;
    CGFloat cellW = MIN(width, iPhone6ScreenWidth);
    CGFloat w = cellW;
    CGFloat h = w * (9.f / 16.f);
    w = ceilf(w);
    h = ceilf(h);
    return CGSizeMake(w, h);
}

- (float)titleWidthForCellWidth:(float)width{
    
    if (_isRight) {
        
        return width;
    }
    
    CGFloat titleWidth = width - 6.f;
    if ([TTDeviceHelper is736Screen]) {
        titleWidth -= 2.f;
    }
    return titleWidth;
}

- (CGFloat)cellInfoLabelFontSize {
    CGFloat fontSize;
    if ([TTDeviceHelper isPadDevice]) {
        fontSize = 12.f;
    } else if ([TTDeviceHelper is736Screen]) {
        fontSize = 12.f;
    } else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
        fontSize = 12.f;
    } else {
        fontSize = 12.f;
    }
    return fontSize;
}

- (float)titleHeightForArticle:(Article *)article cellWidth:(float)width{
    float titleWidth = [self titleWidthForCellWidth:width];
    if (isEmptyString(article.title)) {
        return [self titleLabelFontSize];
    }
    return [TTLabelTextHelper heightOfText:article.title fontSize:[self titleLabelFontSize] forWidth:titleWidth constraintToMaxNumberOfLines:2];
}
@end
