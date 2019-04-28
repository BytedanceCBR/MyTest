//
//  ExploreVideoDetailMixedLeftPicADView.m
//  Article
//
//  Created by yin on 16/9/6.
//
//

#import "ExploreVideoDetailMixedLeftPicADView.h"
#import "TTDeviceHelper.h"
#import "TTLabelTextHelper.h"
#import "NSString-Extension.h"
#import "TTAdDetailViewHelper.h"

#define kPaddingLeft 10
#define kPaddingRight 10
#define kPaddingBottom 10
#define kPaddingTop 10
#define kPaddingTitleToPic 10  //标题与图片(视频)间距(横向)
#define kPaddingTitleBottom 7  //标题与来源文字间距(纵向)


@implementation ExploreVideoDetailMixedLeftPicADView

+ (void)load
{
    [TTAdDetailViewHelper registerViewClass:self withKey:@"video_mixed_leftPic" forArea:TTAdDetailViewAreaVideo];
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
    
    CGSize imageSize = [TTAdDetailViewUtil imgSizeForViewWidth:self.width+30];
    CGFloat containWidth = self.width - imageSize.width - kVideoLeftPadding - kVideoRightPadding - kVideoRightImgLeftPadding;
    [self.titleLabel sizeToFit: containWidth];
    [self.sourceLabel sizeToFit];
    [[self class] updateADLabel:self.adLabel withADModel:adModel];
    [self layoutVideo:adModel];
    
}


#pragma mark -  视频详情页banner广告布局
- (void)layoutVideo:(ArticleDetailADModel *)adModel
{
    //30 = 15 + 15 左右padding 计算方法类似TTAdVideoRelateRightImageView中Imageview大小
    CGSize imageSize = [TTAdDetailViewUtil imgSizeForViewWidth:self.width+30];
    self.imageView.frame = CGRectMake(self.right - kVideoRightPadding - imageSize.width, (self.height-imageSize.height)/2, imageSize.width, imageSize.height);
    //title只有一行padding增加8
    CGFloat containWidth = self.width - imageSize.width - kVideoLeftPadding - kVideoRightPadding - kVideoRightImgLeftPadding;
    NSInteger labelLines = [self.titleLabel.text tt_lineNumberWithMaxWidth:containWidth font:self.titleLabel.font lineHeight:self.titleLabel.font.lineHeight numberOfLines:2 firstLineIndent:0 alignment:NSTextAlignmentLeft];
    CGFloat titleAddPadding = labelLines>1 ? .0f: 8.0f;
    CGFloat topPadding = (self.height - self.titleLabel.height - kAdLabelHeight - kVideoTitleBottomPadding - titleAddPadding)/2;
    self.titleLabel.origin = CGPointMake(kVideoLeftPadding, topPadding);
    self.adLabel.origin = CGPointMake(self.titleLabel.left, self.titleLabel.bottom + kVideoTitleBottomPadding + titleAddPadding);
    
    self.sourceLabel.left = self.adLabel.right + kVideoAdLabelRitghtPadding;
    self.sourceLabel.width = containWidth - self.adLabel.width - kVideoAdLabelRitghtPadding -kVideoDislikeImageWidth;
    self.sourceLabel.centerY = self.adLabel.centerY;
    
    self.dislikeView.center = CGPointMake(self.imageView.left - kVideoRightImgLeftPadding - kVideoDislikeImageWidth/2, self.sourceLabel.centerY) ;
    self.dislikeView.hidden = !(self.adModel.showDislike);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGSize picSize = [TTAdDetailViewUtil imgSizeForViewWidth:width];
    CGFloat height = kVideoTopPadding + picSize.height + kVideoBottomPadding;

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
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColorKey = kColorText1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineHeight = [UIFont systemFontOfSize:16].pointSize * 1.2; //1.2倍行高，字体的1.2倍
    }
    return _titleLabel;
}

- (SSThemedLabel *)sourceLabel
{
    if (!_sourceLabel) {
        _sourceLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _sourceLabel.textAlignment = NSTextAlignmentLeft;
        _sourceLabel.font = [UIFont systemFontOfSize:12];
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


- (float)titleWidthForCellWidth:(float)width{
    CGFloat titleWidth = width - [TTAdDetailViewUtil imgSizeForViewWidth:self.width].width - kVideoRightPadding - kVideoRightImgLeftPadding - kVideoLeftPadding;
    if ([TTDeviceHelper is736Screen]) {
        titleWidth -= 2.f;
    }
    return titleWidth;
}




- (float)titleHeight:(NSString *)title cellWidth:(float)width{
    float titleWidth = [self titleWidthForCellWidth:width];
    if (isEmptyString(title)) {
        return [self titleLabelFontSize];
    }
    return [TTLabelTextHelper heightOfText:title fontSize:[self titleLabelFontSize] forWidth:titleWidth constraintToMaxNumberOfLines:2];
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
    return videoDetailFontSize;
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
