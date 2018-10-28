//
//  TTVDetailRelatedVideoItem.m
//  Article
//
//  Created by pei yun on 2017/5/10.
//
//

#import "TTVDetailRelatedVideoItem.h"
#import "ExploreArticleCellViewConsts.h"
#import "Article.h"
#import "TTArticleCellHelper.h"
#import "TTLabelTextHelper.h"
#import "TTOriginalLogo.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TTDeviceUIUtils.h"
#import "TTVDetailRelatedADInfoDataProtocol.h"
#import "TTVVideoDetailRelatedAdActionService.h"
#import "TTVideoFontSizeManager.h"
#import "TTUserSettingsManager+FontSettings.h"

#define kArticleGroupFlagsHasVideo 0x1
#define kTitleFontSize [TTVideoFontSizeManager settedRelatedTitleFontSize]
#define kLeftPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kRightPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kRightImgLeftPadding (([TTDeviceHelper is736Screen]) ? 6 : 10)

#define kFromeLabelTopPadding 6
#define kVideoIconLeftGap 6

#define kTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kAlbumTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)
#define kAlbumBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 10)

#define kDownloadIconSize CGSizeMake([TTDeviceUIUtils tt_fontSize:12], [TTDeviceUIUtils tt_fontSize:12])

static const CGFloat KLabelInfoHeight = 20;

@interface TTVDetailRelatedVideoCell ()

@property (nonatomic, strong) TTVVideoDetailRelatedAdActionService *adActionService;

+ (CGFloat)obtainHeightForRelatedVideoItem:(TTVDetailRelatedVideoItem *)item cellWidth:(CGFloat)width;

@end

@implementation TTVDetailRelatedVideoItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    return [TTVDetailRelatedVideoCell obtainHeightForRelatedVideoItem:self cellWidth:width];
}

@end

@implementation TTVDetailRelatedVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_titleLabel];
        
        _fromLabel = [[UILabel alloc] init];
        _fromLabel.backgroundColor = [UIColor clearColor];
        _fromLabel.font = [self.class fromLabelFont];
        [self.contentView addSubview:_fromLabel];
        
        _commentCountLabel = [[UILabel alloc] init];
        _commentCountLabel.backgroundColor = [UIColor clearColor];
        _commentCountLabel.font = [UIFont systemFontOfSize:cellInfoLabelFontSize()];
        [self.contentView addSubview:_commentCountLabel];
        
        self.picImageView = [[TTImageView alloc] init];
        self.picImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        self.picImageView.layer.cornerRadius = 4;
        self.picImageView.layer.masksToBounds = true;
        self.picImageView.hidden = NO;
        self.picImageView.userInteractionEnabled = NO;
        [self.picImageView addSubview:self.albumCover];
        self.albumCover.hidden = YES;
        [self.contentView addSubview:self.picImageView];
        
//        [self updateVideoDurationLabel];
        [self reloadThemeUI];
        [self.albumCover mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self.picImageView);
            make.width.mas_equalTo(44);
        }];
        
        self.actionButton = [[SSThemedButton alloc] init];
        self.actionButton.backgroundColor = [UIColor clearColor];
        self.actionButton.titleColorThemeKey = kColorText5;
        self.actionButton.titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        self.actionButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.actionButton addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.actionButton];
        self.downloadIcon = [[SSThemedButton alloc] init];
        self.downloadIcon.imageName = @"download_ad_detais";
        self.downloadIcon.size = kDownloadIconSize;
        [self.downloadIcon addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.downloadIcon];
        self.actionButton.hidden = YES;
        self.downloadIcon.hidden = YES;
        
        _adActionService = [[TTVVideoDetailRelatedAdActionService alloc] init];
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kSettingFontSizeChangedNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
            @strongify(self);
            [self refreshUI];
        }];
    }
    return self;
}

- (void)setItem:(TTVDetailRelatedVideoItem *)item
{
    super.item = item;
    [self refreshTitleWithTags:item.tags];
    
    @weakify(self);
    [[[RACObserve(item, isCurrentPlaying) skip:1] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self refreshTitleUI];
    }];
    [[[RACObserve(item, isVideoAlbum) skip:1] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self refreshUI];
    }];
    [self refreshUI];
}

- (void)updateVideoDurationLabel {
    if (!_timeInfoBgView) {
        self.timeInfoBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _timeInfoBgView.layer.cornerRadius = KLabelInfoHeight/2;
        _timeInfoBgView.clipsToBounds = YES;
        self.timeInfoBgView.backgroundColor = [UIColor colorWithHexString:@"0000007f"];
        _timeInfoBgView.frame = CGRectMake(0, 0, 0, KLabelInfoHeight);
        [self.picImageView addSubview:_timeInfoBgView];
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
    TTVDetailRelatedVideoItem *item = (TTVDetailRelatedVideoItem *)self.item;
    long long duration = [item.article.videoDuration longLongValue];
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
    CGFloat videoIconViewWidth = 0;
    if (!isEmptyString(_videoDurationLabel.text)) {
        _timeInfoBgView.hidden = NO;
        CGFloat gap = 2;
        
        CGFloat width = kVideoIconLeftGap*2 + (_videoDurationLabel.width) + gap + videoIconViewWidth;
        width = MAX(width, 28);
        _timeInfoBgView.frame = CGRectMake((self.picImageView.width) - width - 4, (self.picImageView.height) - KLabelInfoHeight - 4, width, KLabelInfoHeight);
        _videoDurationLabel.hidden = NO;
        
        _videoIconView.hidden = YES;
        _videoIconView.left = kVideoIconLeftGap;
        _videoIconView.centerY = (_timeInfoBgView.height) / 2;
        _videoDurationLabel.centerX = _timeInfoBgView.width / 2;
        _videoDurationLabel.centerY = (_timeInfoBgView.height) / 2;
    }
    else {
        _timeInfoBgView.hidden = NO;
        
        CGFloat width = kVideoIconLeftGap*2 + videoIconViewWidth;
        width = MAX(width, KLabelInfoHeight);
        _timeInfoBgView.frame = CGRectMake((self.picImageView.width) - width - 4, (self.picImageView.height) - KLabelInfoHeight - 4, width, KLabelInfoHeight);
        _videoDurationLabel.hidden = YES;
        _videoIconView.hidden = YES;
        _videoIconView.center = CGPointMake((_timeInfoBgView.width) / 2 + 1, (_timeInfoBgView.height) / 2);
    }
}

- (void)reloadThemeUI
{
    [self themeChanged:nil];
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    
    [self refreshTitleUI];
    TTVDetailRelatedVideoItem *item = (TTVDetailRelatedVideoItem *)self.item;
    if (item.tags.count > 0) {
        [self refreshTitleWithTags:item.tags];
    }
    _fromLabel.textColor = [UIColor tt_themedColorForKey:kFHColorCoolGrey2];
    _commentCountLabel.textColor = [UIColor tt_themedColorForKey:kFHColorCoolGrey2];
}

- (void)refreshTitleUI
{
    TTVDetailRelatedVideoItem *item = (TTVDetailRelatedVideoItem *)self.item;
    if ([item.article.hasRead boolValue] && !item.tags.count) {
        _titleLabel.textColor = [UIColor colorWithDayColorName:@"999999" nightColorName:@"505050"];
    }
    else {
        _titleLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    }
    
    if (item.isCurrentPlaying) {
        _titleLabel.textColor = SSGetThemedColorWithKey(kColorText5);
    }
}

- (void)refreshTitleWithTags:(NSArray *)tags
{
    TTVDetailRelatedVideoItem *item = (TTVDetailRelatedVideoItem *)self.item;
    if (item.article.title) {
        [_titleLabel setAttributedText:[self.class showTitleForTitle:item.article.title tags:tags]];
    }
}

- (void)refreshUI
{
    TTVDetailRelatedVideoItem *item = (TTVDetailRelatedVideoItem *)self.item;
    
    self.titleLabel.font = [UIFont systemFontOfSize:[self.class titleLabelFontSize]];
    [_picImageView setImageWithModel:item.article.listMiddleImageModel placeholderImage:nil];
    
    float titleLabelHeight = [self.class titleHeightForArticleTitle:item.article.title cellWidth:self.width];
    
    CGFloat fromLabelMaxLen = 120;
    self.fromLabel.text = item.article.source ?: item.article.mediaName;
    [self.fromLabel sizeToFit];
    
    self.albumCount.text = [item.article.commentCount stringValue];
    
    NSString *countLabelText = [TTBusinessManager formatCommentCount:[[item.article.videoDetailInfo objectForKey:VideoWatchCountKey] longLongValue]];
    NSString *tailString = @"次播放";
    if (item.isVideoAlbum) {
        countLabelText = [TTBusinessManager formatCommentCount:[item.article.commentCount longLongValue]];
        tailString = @"个视频";
    }
    countLabelText = [countLabelText stringByAppendingString:tailString];
    
    self.commentCountLabel.text = countLabelText;
    [self.commentCountLabel sizeToFit];
    
    CGFloat imageWidth = [self.class videoDetailRelateVideoImageSizeWithWidth:self.width].width;
    CGFloat imageheight = [self.class videoDetailRelateVideoImageSizeWithWidth:self.width].height;
    
    CGFloat topPadding = item.isSubVideoAlbum ? kAlbumTopPadding : kTopPadding;
    CGFloat bottomPadding = item.isSubVideoAlbum ? kAlbumBottomPadding : kBottomPadding;
    
    _picImageView.frame = CGRectMake(self.width - imageWidth - kRightPadding, topPadding, imageWidth, imageheight);
    
    CGFloat totalLabelHeight = titleLabelHeight + kFromeLabelTopPadding + (_fromLabel.height);
    float selfHeight = MAX(CGRectGetMaxY(_picImageView.frame), totalLabelHeight + topPadding) + bottomPadding;
    
//    self.frame = CGRectMake(0, 0, self.width, selfHeight);
    
    self.titleLabel.frame = CGRectMake(kLeftPadding, (selfHeight - totalLabelHeight) / 2, [self.class titleWidthForCellWidth:self.width], titleLabelHeight);
    
    if (!isEmptyString(item.article.relatedVideoExtraInfoShowTag)) {
        if (!_albumLogo) {
            NSString *logoText = item.article.relatedVideoExtraInfoShowTag;
            _albumLogo = [TTOriginalLogo originalLabelWithRect:CGRectMake(0, 0, 26, 14) text:logoText textFontSize:10 textColorKey:kColorText5 lineColorKey:kColorLine6 cornerRadius:3];
            [self.contentView addSubview:_albumLogo];
        }
        self.albumCover.hidden = item.isVideoAlbum ? NO : YES;
        self.albumLogo.hidden = NO;
        self.albumLogo.left = self.titleLabel.left;
        self.fromLabel.frame = CGRectMake(self.albumLogo.right + 5, self.titleLabel.bottom + kFromeLabelTopPadding, MIN(self.fromLabel.width, fromLabelMaxLen), self.fromLabel.height);
        
        self.albumLogo.centerY = self.fromLabel.centerY;
    } else {
        self.albumCover.hidden = YES;
        self.albumLogo.hidden = YES;
        self.fromLabel.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + kFromeLabelTopPadding, MIN(self.fromLabel.width, fromLabelMaxLen), self.fromLabel.height);
    }
    self.commentCountLabel.frame = CGRectMake(_fromLabel.right + 10, _fromLabel.top, _commentCountLabel.width, _commentCountLabel.height);
//    [self refreshBottomLineView];
//    [self sendSubviewToBack:self.bgButton];
    [self updateVideoDurationLabel];
    [self layoutVideoDurationLabel];
    
    if (item.isVideoAlbum) {
        self.timeInfoBgView.hidden = YES;
    } else {
        self.timeInfoBgView.hidden = NO;
    }
    
    self.actionButton.hidden = YES;
    self.downloadIcon.hidden = YES;
    self.commentCountLabel.hidden = NO;
    id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra = item.article.videoAdExtra;
    if (videoAdExtra&&[videoAdExtra.card_type isEqualToString:@"ad_video"]){
        if (videoAdExtra.ui_type) {
            self.actionButton.titleColorThemeKey = kColorText6;
            self.downloadIcon.imageName = @"download_ad_feed";
            _albumLogo.textColorThemeKey = kColorText6;
            _albumLogo.borderColorThemeKey = kColorLine3;
            [self layoutActionButton_NewButton];
        } else {
            [self layoutActionButton];
        }
    }
}

- (void)layoutActionButton
{
    id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra = ((TTVDetailRelatedVideoItem *)self.item).article.videoAdExtra;
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
        self.actionButton.centerY = self.fromLabel.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width -5;
        self.commentCountLabel.hidden = YES;
    }
}

- (void)layoutActionButton_NewButton
{
    id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra = ((TTVDetailRelatedVideoItem *)self.item).article.videoAdExtra;
    
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

- (void)handleAction:(SSThemedButton*)button
{
    id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra = ((TTVDetailRelatedVideoItem *)self.item).article.videoAdExtra;
    if (videoAdExtra) {
        [self.adActionService video_relateHandleAction:videoAdExtra uniqueIDStr:videoAdExtra.uniqueIDStr];
    }
}

#pragma mark - Lazy properties

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

#pragma mark - Helpers

+ (NSAttributedString *)showTitleForTitle:(NSString *)title tags:(NSArray *)tags
{
    if (!tags.count) {
        return [[NSAttributedString alloc] initWithString:title];
    }
    else {
        NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:title];
        for (NSString * tag in tags) {
            NSRange range = [title rangeOfString:tag];
            if (range.location != NSNotFound) {
                [attrTitle addAttribute:NSForegroundColorAttributeName value:SSGetThemedColorWithKey(kFHColorDarkIndigo) range:range];
            }
        }
        return attrTitle;
    }
}

+ (CGFloat)obtainHeightForRelatedVideoItem:(TTVDetailRelatedVideoItem *)item cellWidth:(CGFloat)width
{
    float titleLabelHeight = [self.class titleHeightForArticleTitle:item.article.title cellWidth:width];
    
    CGFloat fromLabelMaxLen = 120;
    NSString *fromLabelText = item.article.source ?: item.article.mediaName;
    
    CGFloat imageheight = [self.class videoDetailRelateVideoImageSizeWithWidth:width].height;
    
    CGFloat topPadding = item.isSubVideoAlbum ? kAlbumTopPadding : kTopPadding;
    CGFloat bottomPadding = item.isSubVideoAlbum ? kAlbumBottomPadding : kBottomPadding;
    
    CGSize boundingSize = CGSizeMake(fromLabelMaxLen, ceilf([self fromLabelFont].lineHeight));
    CGFloat fromLabelHeight = ceilf(MIN([fromLabelText boundingRectWithSize:boundingSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [self fromLabelFont]} context:nil].size.height, boundingSize.height));
    
    CGFloat totalLabelHeight = titleLabelHeight + kFromeLabelTopPadding + fromLabelHeight;
    return MAX(topPadding + imageheight, totalLabelHeight + topPadding) + bottomPadding;
}

+ (UIFont *)fromLabelFont
{
    return [UIFont systemFontOfSize:cellInfoLabelFontSize()];
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

+ (CGFloat)titleLabelFontSize
{
    return kTitleFontSize;
}

+ (float)titleWidthForCellWidth:(float)width{
    CGSize imgWidth = [self videoDetailRelateVideoImageSizeWithWidth:width];
    CGFloat titleWidth = width - imgWidth.width - kRightPadding - kRightImgLeftPadding - kLeftPadding;
    if ([TTDeviceHelper is736Screen]) {
        titleWidth -= 2.f;
    }
    return titleWidth;
}

+ (CGFloat)titleHeightForArticleTitle:(NSString *)title cellWidth:(float)width
{
    float titleWidth = [self titleWidthForCellWidth:width];
    if (isEmptyString(title)) {
        return [self titleLabelFontSize];
    }
    return [TTLabelTextHelper heightOfText:title fontSize:[self titleLabelFontSize] forWidth:titleWidth constraintToMaxNumberOfLines:2];
}

@end
