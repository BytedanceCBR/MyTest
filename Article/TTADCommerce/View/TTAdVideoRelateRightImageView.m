//
//  TTAdVideoRelateRightImageView.m
//  Article
//
//  Created by yin on 16/8/17.
//
//

#import "TTAdVideoRelateRightImageView.h"
#import "TTOriginalLogo.h"
#import "TTAdManager.h"
#import "TTVideoFontSizeManager.h"
#import "TTAdVideoRelateAdModel.h"

#define kAlbumLogoTopPadding 8
#define kFromLabelLeftPadding 4
#define kTitleFontSize [SSUserSettingManager detailRelateReadFontSize]
#define NewkTitleFontSize [TTVideoFontSizeManager settedRelatedTitleFontSize]


@interface TTAdVideoRelateRightImageView ()

@property (nonatomic, assign) BOOL hasShow;

@property (nonatomic, copy) TTRelateVideoImageViewBlock successBlock;

@end

@implementation TTAdVideoRelateRightImageView

@dynamic hasShow;

- (instancetype)initWithWidth:(CGFloat)width successBlock:(TTRelateVideoImageViewBlock)block
{
    self = [super initWithWidth:width];
    if (self) {
        self.hasShow = NO;
        self.width = width;
        self.successBlock = block;
        
        [self  setSubviews];
    }
    return self;
}


-(void)adVideoRelateImageViewtrackShow
{
    if (self.hasShow == NO) {
        [TTAdManageInstance video_relateTrackAdShow:self.viewModel.article];
        self.hasShow = YES;
    }
}

-(void)setSubviews
{
    self.imageView.borderColorThemeKey = kColorLine1;
    self.imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceHelper isScreenWidthLarge320]? 17.f:15.f];
    self.titleLabel.numberOfLines = 2;
    self.albumLogo = [TTOriginalLogo originalLabelWithRect:CGRectMake(0, 0, 26, 14) text:@"" textFontSize:10 textColorKey:kColorText5 lineColorKey:kColorLine6 cornerRadius:3];
    [self addSubview:self.albumLogo];
    
}

-(void)refreshUI
{
    TTAdVideoRelateAdModel* videoAdExtra = self.viewModel.article.videoAdExtra;
    if ([videoAdExtra.ui_type integerValue]) {
        self.albumLogo.textColorThemeKey = kColorText6;
        self.albumLogo.borderColorThemeKey = kColorLine3;
    }

    CGFloat imageWidth = [self imgWidth];
    
    if (self.viewModel.useForVideoDetail) {
        imageWidth = [self.class videoDetailRelateVideoImageSizeWithWidth:self.width].width;
    }
    CGFloat imageHeight = (imageWidth * 124)/190;
    self.frame = CGRectMake(0, 0, self.width, imageHeight + kTopPadding + kBottomPadding);
    
    self.imageView.frame = CGRectMake(self.right - kRightPadding - imageWidth, kTopPadding, imageWidth, imageHeight);
    
    CGFloat titleWidth = [self titleWidthForCellWidth:SSWidth(self)];
    self.titleLabel.font = [UIFont systemFontOfSize:NewkTitleFontSize];
    CGFloat titleHeight = [self titleHeightForArticle:self.viewModel.article cellWidth:SSWidth(self)];
    CGFloat albumLogoHeight = 14;
    CGFloat totalHeight = titleHeight + kAlbumLogoTopPadding + albumLogoHeight;
    CGFloat titleTop = (self.height - totalHeight)/2;
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
    if (videoAdExtra&&[videoAdExtra.card_type isEqualToString:@"ad_textlink"]){
        [self layoutActionButton];
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

    TTImageInfosModel* imageModel = [[TTImageInfosModel alloc] initWithDictionary:[videoAdExtra.middle_image toDictionary]];
    [self.imageView setImageWithModel:imageModel placeholderView:nil];
    WeakSelf;
    [self.imageView setImageWithModel:imageModel placeholderImage:nil options:SDWebImageRetryFailed success:^(UIImage *image, BOOL cached) {
        
    } failure:^(NSError *error) {
        StrongSelf;
        [self adItemLoadSuccess:NO];
    }];
    [self refreshBottomLineView];
}

- (void)adItemLoadSuccess:(BOOL)success
{
    if (success == NO) {
        self.successBlock(NO);
    }
}

@end
