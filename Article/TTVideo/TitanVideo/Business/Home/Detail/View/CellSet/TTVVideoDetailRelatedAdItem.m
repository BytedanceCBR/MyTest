//
//  TTVVideoDetailRelatedAdItem.m
//  Article
//
//  Created by pei yun on 2017/5/25.
//
//

#import "TTVVideoDetailRelatedAdItem.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceUIUtils.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTLabelTextHelper.h"
#import "TTOriginalLogo.h"
#import "TTVVideoDetailRelatedAdActionService.h"
#import "TTVideoFontSizeManager.h"
#define kLeftPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kRightPadding (([TTDeviceHelper isPadDevice]) ? 20 : 15)
#define kRightImgLeftPadding (([TTDeviceHelper is736Screen]) ? 6 : 10)

#define kAlbumLogoTopPadding 8
#define kFromLabelLeftPadding 4

#define kTopPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kBottomPadding (([TTDeviceHelper isPadDevice]) ? 20 : 12)

#define kDownloadIconSize CGSizeMake([TTDeviceUIUtils tt_fontSize:12], [TTDeviceUIUtils tt_fontSize:12])

@interface TTVVideoDetailRelatedAdCell ()

@property (nonatomic, strong) TTVVideoDetailRelatedAdActionService *adActionService;

+ (CGFloat)obtainHeightForRelatedVideoItem:(TTVVideoDetailRelatedAdItem *)item cellWidth:(CGFloat)width;

@end

@implementation TTVVideoDetailRelatedAdItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    return [TTVVideoDetailRelatedAdCell obtainHeightForRelatedVideoItem:self cellWidth:width];
}

@end

@implementation TTVVideoDetailRelatedAdCell

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
        
        self.picImageView = [[TTImageView alloc] init];
        self.picImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        self.picImageView.hidden = NO;
        self.picImageView.userInteractionEnabled = NO;
        [self.contentView addSubview:self.picImageView];
        [self reloadThemeUI];
        
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
        
        [self setSubviews];
        
        _adActionService = [[TTVVideoDetailRelatedAdActionService alloc] init];
    }
    return self;
}

-(void)setSubviews
{
    self.picImageView.borderColorThemeKey = kColorLine1;
    self.imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.titleLabel.font =[UIFont systemFontOfSize:[self.class titleLabelFontSize]];
    self.titleLabel.numberOfLines = 2;
    self.albumLogo = [TTOriginalLogo originalLabelWithRect:CGRectMake(0, 0, 26, 14) text:@"" textFontSize:10 textColorKey:kColorText5 lineColorKey:kColorLine6 cornerRadius:3];    [self.contentView addSubview:self.albumLogo];
    [self.contentView addSubview:self.albumLogo];
}

- (void)setItem:(TTVVideoDetailRelatedAdItem *)item
{
    [super setItem:item];
    
    [self refreshUI];
}

- (void)reloadThemeUI
{
    [self themeChanged:nil];
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    
    _titleLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    _fromLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
}

-(void)refreshUI
{
    id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra = ((TTVVideoDetailRelatedAdItem *)self.item).relatedADInfo;
    CGFloat imageWidth = [self.class videoDetailRelateVideoImageSizeWithWidth:self.width].width;
    
    CGFloat imageHeight = (imageWidth * 124)/190;
//    self.frame = CGRectMake(0, 0, self.width, imageHeight + kTopPadding + kBottomPadding);
    
    self.picImageView.frame = CGRectMake(self.right - kRightPadding - imageWidth, kTopPadding, imageWidth, imageHeight);
    
    CGFloat titleWidth = [self.class titleWidthForCellWidth:self.width];
    CGFloat titleHeight = [self.class titleHeightForArticleTitle:videoAdExtra.title cellWidth:self.width];
    CGFloat albumLogoHeight = 14;
    CGFloat totalHeight = titleHeight + kAlbumLogoTopPadding + albumLogoHeight;
    CGFloat cellHeight = [self.class obtainHeightForRelatedVideoItem:(TTVVideoDetailRelatedAdItem *)self.item cellWidth:self.width];
    CGFloat titleTop = (cellHeight - totalHeight)/2;
    self.titleLabel.frame = CGRectMake(kLeftPadding, titleTop, titleWidth , titleHeight);
    
    //兼容标签的文字长度
    if (videoAdExtra.show_tag.length == 2) {
        self.albumLogo.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + kAlbumLogoTopPadding, 26, 14);
    }
    else
    {
        NSInteger length = videoAdExtra.show_tag.length > 10? 10:videoAdExtra.show_tag.length;
        NSString* show_tag = [videoAdExtra.show_tag substringWithRange:NSMakeRange(0, length)];
        CGFloat width = [show_tag boundingRectWithSize:CGSizeMake(self.width, 14) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.albumLogo.font} context:nil].size.width;
        self.albumLogo.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + kAlbumLogoTopPadding, width, 14);
    }
    if (videoAdExtra && ([videoAdExtra.card_type isEqualToString:@"ad_textlink"])){
        if (videoAdExtra.ui_type) {
            self.actionButton.titleColorThemeKey = kColorText6;
            self.downloadIcon.imageName = @"download_ad_feed";
            self.albumLogo.textColorThemeKey = kColorText6;
            self.albumLogo.borderColorThemeKey = kColorLine3;
            [self layoutActionButton_NewButton];
        } else {
            [self layoutActionButton];
        }
    }
    CGFloat containWidth = self.titleLabel.width - self.albumLogo.width - kFromLabelLeftPadding;
    if (videoAdExtra.creative_type&&[videoAdExtra.creative_type isEqualToString:@"action"]) {
        containWidth = containWidth - self.actionButton.width;
    }
    else if(videoAdExtra.creative_type&&[videoAdExtra.creative_type isEqualToString:@"app"])
    {
        containWidth = containWidth - self.actionButton.width - kDownloadIconSize.width - kDownloadIconSize.width;
    }
    
    self.fromLabel.frame = CGRectMake(self.albumLogo.right + kFromLabelLeftPadding, self.albumLogo.top, containWidth, 30);
    self.fromLabel.centerY = self.albumLogo.centerY;
    self.titleLabel.text = videoAdExtra.title;
    self.albumLogo.text = videoAdExtra.show_tag;
    self.fromLabel.text = videoAdExtra.source;
    
    TTImageInfosModel* imageModel = videoAdExtra.middleImageInfosModel;
    [self.picImageView setImageWithModel:imageModel placeholderImage:nil options:SDWebImageRetryFailed success:^(UIImage *image, BOOL cached) {
        
    } failure:^(NSError *error) {
    }];
}

- (void)layoutActionButton
{
    id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra = ((TTVVideoDetailRelatedAdItem *)self.item).relatedADInfo;
    self.fromLabel.hidden = NO;
    if ([videoAdExtra.creative_type isEqualToString:@"action"]) {
        self.actionButton.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = self.titleLabel.right;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width -5;
    }
    else if([videoAdExtra.creative_type isEqualToString:@"app"])
    {
        self.actionButton.hidden = NO;
        self.downloadIcon.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = self.titleLabel.right;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.downloadIcon.left = self.actionButton.left - 4;
        self.downloadIcon.right = self.actionButton.left - 4;
        self.downloadIcon.centerY = self.actionButton.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width - kDownloadIconSize.width - 5 - 4;
    }
    else if ([videoAdExtra.creative_type isEqualToString:@"form"]) {
        self.actionButton.hidden = NO;
        [self.actionButton setTitle:videoAdExtra.button_text forState:UIControlStateNormal];
        [self.actionButton sizeToFit];
        self.actionButton.right = self.titleLabel.right;
        self.actionButton.centerY = self.albumLogo.centerY;
        self.fromLabel.width = self.titleLabel.width - self.albumLogo.width - self.actionButton.width -5;
    }
}

- (void)layoutActionButton_NewButton
{
    id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra = ((TTVVideoDetailRelatedAdItem *)self.item).relatedADInfo;

    if (![@[@"action", @"app", @"form"] containsObject:videoAdExtra.creative_type]) {
        return;
    }

    self.actionButton.hidden = NO;
    self.downloadIcon.hidden = NO;
    self.fromLabel.hidden = YES;
    [self.actionButton setTitle:[NSString stringWithFormat:@"%@: %@", videoAdExtra.button_text, videoAdExtra.source] forState:UIControlStateNormal];
    [self.actionButton sizeToFit];
    self.downloadIcon.left = self.albumLogo.right + 12;
    self.downloadIcon.centerY = self
    .albumLogo.centerY;
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
    id<TTVDetailRelatedADInfoDataProtocol> videoAdExtra = ((TTVVideoDetailRelatedAdItem *)self.item).relatedADInfo;
    if (videoAdExtra) {
        [self.adActionService video_relateHandleAction:videoAdExtra uniqueIDStr:videoAdExtra.uniqueIDStr];
    }
}

#pragma mark - Helpers

+ (CGFloat)obtainHeightForRelatedVideoItem:(TTVVideoDetailRelatedAdItem *)item cellWidth:(CGFloat)width
{
    CGFloat imageWidth = [self.class videoDetailRelateVideoImageSizeWithWidth:width].width;
    
    CGFloat imageHeight = (imageWidth * 124)/190;
    return imageHeight + kTopPadding + kBottomPadding;
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
    return [TTVideoFontSizeManager settedTitleFontSize];
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
