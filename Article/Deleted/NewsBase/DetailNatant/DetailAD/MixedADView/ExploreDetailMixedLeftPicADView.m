//
//  ExploreDetailMixedLeftPicADView.m
//  Article
//
//  Created by huic on 16/4/29.
//
//

#import "ExploreDetailMixedLeftPicADView.h"
#import "TTAdDetailViewHelper.h"
#import "TTDeviceHelper.h"
#import "TTLabelTextHelper.h"


#define kPaddingLeft 10
#define kPaddingRight 10
#define kPaddingBottom 10
#define kPaddingTop 10
#define kPaddingTitleToPic 10  //标题与图片(视频)间距(横向)
#define kPaddingTitleBottom 7  //标题与来源文字间距(纵向)


@implementation ExploreDetailMixedLeftPicADView

+ (void)load
{
    [TTAdDetailViewHelper registerViewClass:self withKey:@"mixed_leftPic" forArea:TTAdDetailViewAreaGloabl];
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
    [self addSubview:self.sourceLabel];
    [self addSubview:self.adLabel];
    [self addSubview:self.dislikeView];
}

#pragma mark - refresh
- (void)setAdModel:(ArticleDetailADModel *)adModel
{
    [super setAdModel:adModel];
    [self.imageView setImageWithURLString:adModel.imageURLString];
    self.titleLabel.text = adModel.titleString;
    self.sourceLabel.text = adModel.sourceString;
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self layout];
}

- (void)layout
{
    //布局左侧图片
    CGFloat containWidth = self.width - kPaddingLeft - kPaddingRight;
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:containWidth];
    self.imageView.frame = CGRectMake(kPaddingLeft, kPaddingTop, picSize.width, picSize.height);
   
    CGFloat rightWidth = containWidth - self.imageView.width - kPaddingTitleToPic;
    CGFloat dislikePadding = self.adModel.showDislike ? (kDislikeImageWidth + kDilikeToTitleRightPadding) : 0;
    CGFloat titleMaxWidth = rightWidth - dislikePadding;
    
    CGFloat titleHeight = [TTLabelTextHelper heightOfText:self.adModel.titleString
                                                 fontSize:kDetailAdTitleFontSize
                                                 forWidth:titleMaxWidth
                                            forLineHeight:kDetailAdTitleLineHeight
                             constraintToMaxNumberOfLines:2];
    
    const CGFloat sourceHeight = kDetailAdLeftSourceLineHeight;
    CGFloat rightHeight = titleHeight + kPaddingTitleBottom + sourceHeight;
    
    CGFloat x = self.imageView.right + kPaddingTitleToPic;
    CGFloat y = kPaddingTop + floor( (self.imageView.height - rightHeight) / 2.0 );
    y = MAX(y, 0.0);
    
    //布局标题（最多两行）
    self.titleLabel.frame = CGRectMake(x, y, titleMaxWidth, titleHeight);
    
    self.dislikeView.center = CGPointMake(self.width - kDislikeImageRightPadding - kDislikeImageWidth/2, self.titleLabel.top + kDislikeToTitleTopPadding + kDislikeImageWidth/2);
    
    y += titleHeight;
    y += kPaddingTitleBottom;
    
    //布局来源文字（标题+来源与图片垂直居中）
    self.sourceLabel.origin = CGPointMake(x, y);
    self.sourceLabel.height = sourceHeight;
    self.sourceLabel.width = self.width - kPaddingRight - kDislikeImageWidth - kDislikeMarginPadding - self.sourceLabel.left;
    
    //布局推广标签
    self.adLabel.origin = CGPointMake(self.imageView.right - kAdLabelWidth - 6, self.imageView.bottom - kAdLabelHeight - 6);
    self.dislikeView.hidden = !(self.adModel.showDislike);
}


+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:(width - kPaddingLeft - kPaddingRight)];
    CGFloat height = kPaddingTop + picSize.height + kPaddingBottom;
    return height;
}


+ (void)updateADLabel:(SSThemedLabel *)adLabel withADModel:(ArticleDetailADModel *)adModel
{
    [ExploreDetailBaseADView updateADLabel:adLabel withADModel:adModel];
    adLabel.backgroundColorThemeKey = kColorBackground15;
}
#pragma mark - getter

- (TTImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[TTImageView alloc] initWithFrame:self.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _imageView.borderColorThemeKey = kColorLine1;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _imageView.userInteractionEnabled = NO;
    }
    return _imageView;
}

- (TTLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[TTLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:kDetailAdTitleFontSize];
        _titleLabel.textColorKey = kColorText1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineHeight = kDetailAdTitleLineHeight; //1.2倍行高，字体的1.2倍
    }
    return _titleLabel;
}

- (SSThemedLabel *)sourceLabel
{
    if (!_sourceLabel) {
        _sourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.textAlignment = NSTextAlignmentLeft;
        _sourceLabel.font = [UIFont systemFontOfSize:kDetailAdLeftSourceFontSize];
        _sourceLabel.textColorThemeKey = kColorText3;
        _sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _sourceLabel.numberOfLines = 1;
    }
    return _sourceLabel;
}

- (SSThemedLabel *)adLabel
{
    if (!_adLabel) {
        _adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    }
    return _adLabel;
}

- (NSString*)dislikeImageName
{
    return @"dislikeicon_details";
}

@end
