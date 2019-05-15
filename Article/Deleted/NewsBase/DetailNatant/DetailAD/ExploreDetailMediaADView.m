//
//  ExploreDetailMediaADView.m
//  Article
//
//  Created by admin on 16/5/31.
//
//

#import "ExploreDetailMediaADView.h"
#import "TTDeviceHelper.h"
#import "TTAdDetailViewHelper.h"

#define kPaddingLeft 12
#define kPaddingRight 12
#define kPaddingBottom 12
#define kPaddingTop 12
#define kPaddingTitleToPic 10  //标题与图片(视频)间距(横向)
#define kPaddingTitleBottom 7  //标题与描述文字间距(纵向)
#define kPaddingTitleToAD 8  //标题与推广文字间距(横向)
#define kMediaPicSize 66 //头条号头像大宽高

@implementation ExploreDetailMediaADView


//+ (void)fakeData:(ArticleDetailADModel *)adModel
//{
//    if (!adModel) {
//        adModel = [[ArticleDetailADModel alloc] init];
//    }
//
//    adModel.titleString = @"头条号：图说军事";
//    adModel.descString = @"图说军事为大家提供最新全球军事动态，中国武器装备资讯";
//    adModel.imageURLString = @"http://p3.pstatp.com/large/11763/2930562151";
//    adModel.webURL = @"http://www.toutiao.com/m5878419946/";
//}

+ (void)load
{
    [TTAdDetailViewHelper registerViewClass:self withKey:@"media" forArea:TTAdDetailViewAreaGloabl];
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
    [self addSubview:self.descLabel];
}

#pragma mark - refresh
- (void)setAdModel:(ArticleDetailADModel *)adModel
{
    [super setAdModel:adModel];
    
    CGFloat containWidth = self.width - kPaddingLeft - kPaddingRight;
    self.imageView.size = CGSizeMake(kMediaPicSize, kMediaPicSize);
    [self.imageView setImageWithURLString:adModel.imageURLString];
    
    CGFloat rightWidth = containWidth - self.imageView.width - kPaddingTitleToPic;
    self.titleLabel.text = adModel.titleString;
    self.descLabel.text = adModel.descString;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.width = MIN(self.titleLabel.width, rightWidth - self.adLabel.width - kPaddingTitleToAD);
    
    [self.descLabel sizeToFit: rightWidth];
    
    [self layout];
}

- (void)layout
{
    //布局左侧图片
    self.imageView.origin = CGPointMake(kPaddingLeft, kPaddingTop);
    
    CGFloat rightHeight = self.titleLabel.height + kPaddingTitleBottom + self.descLabel.height;
    
    CGFloat x = self.imageView.right + kPaddingTitleToPic;
    CGFloat y = kPaddingTop + floor( (self.imageView.height - rightHeight) / 2.0 );
    y = MAX(y, 0.0);
    
    //布局标题
    self.titleLabel.origin = CGPointMake(x, y);
    //布局推广标签
    self.adLabel.origin = CGPointMake(self.titleLabel.right + kPaddingTitleToAD, y);
    self.adLabel.centerY = self.titleLabel.centerY;
    y += self.titleLabel.height;
    y += kPaddingTitleBottom;
    
    //布局描述文字（描述文字最多两行，标题+描述与图片垂直居中）
    self.descLabel.origin = CGPointMake(x, y);
}

+ (CGFloat)heightForADModel:(ArticleDetailADModel *)adModel constrainedToWidth:(CGFloat)width
{
    CGFloat height = kPaddingTop + kMediaPicSize + kPaddingBottom;
    return height;
}


#pragma mark - getter

- (TTImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, kMediaPicSize, kMediaPicSize)];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = kMediaPicSize / 2;
        _imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _imageView.borderColorThemeKey = kColorLine1;
        _imageView.layer.masksToBounds = YES;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _imageView;
}

- (TTLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[TTLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColorKey = kColorText1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (TTLabel *)descLabel
{
    if (!_descLabel) {
        _descLabel = [[TTLabel alloc] initWithFrame:CGRectZero];
        _descLabel.textAlignment = NSTextAlignmentLeft;
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.textColorKey = kColorText3;
        _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _descLabel.numberOfLines = 2;
        _descLabel.lineHeight = [UIFont systemFontOfSize:12].pointSize * 1.2; //1.2倍行高，字体的1.2倍
    }
    return _descLabel;
}

- (SSThemedLabel *)adLabel
{
    if (!_adLabel) {
        _adLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _adLabel.font = [UIFont systemFontOfSize:10];
        _adLabel.layer.masksToBounds = YES;
        _adLabel.layer.cornerRadius = 3;
        _adLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _adLabel.textAlignment = NSTextAlignmentCenter;
        _adLabel.text = @"广告";
//        [_adLabel sizeToFit];
        _adLabel.size = CGSizeMake(26, 14);
        _adLabel.textColorThemeKey = kColorBlueTextColor;
        _adLabel.borderColorThemeKey = kColorBlueBorderColor;
    }
    return _adLabel;
}

@end
