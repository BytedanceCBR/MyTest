//
//  ExploreVideoDetailUnUnifyLargePicADView.m
//  Article
//
//  Created by yin on 2017/2/22.
//
//

#import "ExploreVideoDetailUnUnifyLargePicADView.h"
#import "TTLabelTextHelper.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTAdDetailViewHelper.h"

#define ExploreDetailMixedADTitleFontSize ceil([TTDeviceUIUtils tt_newFontSize:17])
#define ExploreDetailMixedADTitleLineHeight ceil(ExploreDetailMixedADTitleFontSize * 1.2)

@implementation ExploreVideoDetailUnUnifyLargePicADView

+ (void)load
{
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_mixed_ununify_largePic" forArea:TTAdDetailViewAreaVideo];
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super initWithWidth:width];
    if (self) {
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
}

#pragma mark - refresh
- (void)setAdModel:(ArticleDetailADModel *)adModel {
    [super setAdModel:adModel];
    
    [self.imageView setImageWithURLString:adModel.imageURLString];
    
    CGFloat imageHeight = [TTAdDetailViewUtil imageFitHeight:adModel width:self.width];
    self.imageView.size = CGSizeMake(self.width, imageHeight);
    if (imageHeight > 0) {
        self.bottomLine.origin = CGPointMake(0, imageHeight);
    }
    self.bottomLine.hidden = YES;
    self.titleLabel.text = adModel.titleString;
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self layout];
}

- (void)layout
{
    //布局上方图片
    self.imageView.borderColorThemeKey = kColorLine1;
    self.imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.imageView.origin = CGPointMake(12, 12);
    const CGFloat imageHeight = [TTAdDetailViewUtil imageFitHeight:self.adModel width:self.width - 24];

    self.imageView.size = CGSizeMake(self.width - 24, imageHeight);
    self.bottomLine.hidden = NO;
    self.bottomLine.bottom = self.height;
    
    //布局标题
    self.titleLabel.origin = CGPointMake(12, self.imageView.bottom + 6 + (ExploreDetailMixedADTitleFontSize - ExploreDetailMixedADTitleLineHeight) / 2);
    self.titleLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.titleLabel.text fontSize:ExploreDetailMixedADTitleFontSize lineHeight:ExploreDetailMixedADTitleLineHeight];
    
    self.titleLabel.size = CGSizeMake(self.width - 24, [TTLabelTextHelper heightOfText:self.titleLabel.text fontSize:self.titleLabel.font.pointSize forWidth:self.width - kTitleHorizonPadding * 2 forLineHeight:ExploreDetailMixedADTitleLineHeight constraintToMaxNumberOfLines:self.titleLabel.numberOfLines]);
    //布局推广标签
    self.adLabel.origin = CGPointMake(self.imageView.right - self.adLabel.width - 6, self.imageView.bottom - self.adLabel.height - 6);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
   const CGFloat imageHeight = [TTAdDetailViewUtil imageFitHeight:adModel width:width - 24];
    CGFloat height = imageHeight + 24;
    
    if (!isEmptyString(adModel.titleString)) {
        CGFloat titleHeight = [TTLabelTextHelper heightOfText:adModel.titleString fontSize:ExploreDetailMixedADTitleFontSize forWidth:width - 24 forLineHeight:ExploreDetailMixedADTitleLineHeight constraintToMaxNumberOfLines:2];
        height += (ceil(titleHeight) - ExploreDetailMixedADTitleLineHeight + ExploreDetailMixedADTitleFontSize) + 6;
    }
    
    return height;
}

+ (void)updateADLabel:(SSThemedLabel *)adLabel withADModel:(ArticleDetailADModel *)adModel
{
    [ExploreDetailBaseADView updateADLabel:adLabel withADModel:adModel];
    adLabel.backgroundColorThemeKey = kColorBackground15;
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
    }
    return _imageView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:ExploreDetailMixedADTitleFontSize];
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
        _sourceLabel.font = [UIFont systemFontOfSize:14];
        _sourceLabel.textColorThemeKey = kColorText1;
        _sourceLabel.numberOfLines = 1;
        _sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _sourceLabel;
}

@end
