//
//  ExploreVideoDetailMixedLargePicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailMixedLargePicADView.h"
#import "TTLabelTextHelper.h"
#import "TTDeviceHelper.h"
#import "TTAdDetailViewHelper.h"

#define kAppDislikeImageLeftPadding 0


@implementation ExploreVideoDetailMixedLargePicADView

+ (void)load
{
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_mixed_largePic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
        //在ipad的视频详情页不加边框
        self.layer.borderWidth = 0;
        [self buildView];
    }
    return self;
}

- (void)buildView
{
    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.adLabel];
    [self addSubview:self.bottomLine];
    [self addSubview:self.sourceLabel];
    [self addSubview:self.dislikeView];
}

#pragma mark - refresh
- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    
    self.titleLabel.text = adModel.titleString;
    
    [self.imageView setImageWithURLString:adModel.imageURLString];
    self.sourceLabel.text = adModel.sourceString;
    [self.sourceLabel sizeToFit];
    [self layoutVideo:adModel];
}


- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    const CGFloat contentMaxWidth = self.width - kVideoTitleLeftPadding - kVideoTitleRightPadding;
   
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:17] lineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]].pointSize * 1.2];
    const CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize] forWidth:contentMaxWidth forLineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize]].pointSize * 1.2 constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
    self.titleLabel.frame = CGRectMake(kVideoTitleLeftPadding, kVideoTitleTopPadding, contentMaxWidth, titleHeight);
    
    CGFloat imageHeight = [TTAdDetailViewUtil imageFitHeight:adModel width:contentMaxWidth];
    self.imageView.size = CGSizeMake(contentMaxWidth, imageHeight);
    self.imageView.origin = CGPointMake(self.titleLabel.left, self.titleLabel.bottom + kVideoTitleBottomPadding);
    
    const CGFloat dislikePadding = self.adModel.showDislike ? (kVideoDislikeImageWidth + kAppDislikeImageLeftPadding) : 0;
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    self.adLabel.origin = CGPointMake(self.titleLabel.left, self.imageView.bottom + kVideoTitleBottomPadding);
    self.sourceLabel.origin = CGPointMake(self.adLabel.right + kVideoAdLabelRitghtPadding, self.imageView.bottom + kVideoTitleBottomPadding);
    self.sourceLabel.width = contentMaxWidth - self.sourceLabel.left - dislikePadding;
    self.adLabel.centerY = self.sourceLabel.centerY;
    
    self.dislikeView.center = CGPointMake(self.imageView.right - kVideoDislikeImageWidth/2, self.sourceLabel.centerY);
    self.dislikeView.hidden = !self.adModel.showDislike;
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    const CGFloat contentMaxWidth = width - kVideoTitleLeftPadding - kVideoTitleRightPadding;

    CGFloat height = [TTAdDetailViewUtil imageFitHeight:adModel width:contentMaxWidth];
    if (!isEmptyString(adModel.titleString)) {
        CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize] forWidth:contentMaxWidth forLineHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kVideoTitleLabelFontSize]].pointSize * 1.2 constraintToMaxNumberOfLines:2 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        height += kVideoTitleTopPadding + titleHeight + kVideoTitleBottomPadding + kVideoLargeSouceTopPadding + kAdLabelHeight + kVideoLargeSouceBottomPadding;
    }
    
    return height;
}

+ (void)updateADLabel:(SSThemedLabel *)adLabel withADModel:(ArticleDetailADModel *)adModel
{
    [ExploreDetailBaseADView updateADLabel:adLabel withADModel:adModel];
    adLabel.textColorThemeKey = kColorText5;
    adLabel.borderColorThemeKey = kColorLine6;
    adLabel.backgroundColorThemeKey = kColorBackground4;
    adLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
}


#pragma mark - getter

- (SSThemedView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] init];
        _bottomLine.frame = CGRectMake(0, 0, self.width, [TTDeviceHelper ssOnePixel]);
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        _bottomLine.hidden = YES;
    }
    return _bottomLine;
}

- (TTImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _imageView.userInteractionEnabled = NO;
        _imageView.borderColorThemeKey = kColorLine1;
        _imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    }
    return _imageView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        
    }
    return _titleLabel;
}

- (SSThemedLabel *)adLabel
{
    if (!_adLabel) {
        _adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    }
    return _adLabel;
}

- (SSThemedLabel *)sourceLabel
{
    if (!_sourceLabel) {
        _sourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.textAlignment = NSTextAlignmentLeft;
        _sourceLabel.font = [UIFont systemFontOfSize:12];
        _sourceLabel.textColorThemeKey = kColorText3;
        _sourceLabel.numberOfLines = 1;
        _sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _sourceLabel;
}

- (SSThemedLabel*)bottomContainerView
{
    if (!_bottomContainerView) {
        _bottomContainerView = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _bottomContainerView.backgroundColorThemeKey = kColorBackground3;
        _bottomContainerView.borderColorThemeKey = kColorLine1;
        _bottomContainerView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    }
    return _bottomContainerView;
}

- (NSString*)dislikeImageName
{
    return @"add_textpage";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
