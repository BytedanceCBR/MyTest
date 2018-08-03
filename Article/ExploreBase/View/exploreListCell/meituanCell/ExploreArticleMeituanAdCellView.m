//
//  ExploreArticleMeituanAdCellView.m
//  Article
//
//  Created by 冯靖君 on 15/5/21.
//
//

#import "ExploreArticleMeituanAdCellView.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "Article.h"
#import "SSMeituanAdsModel.h"
#import "SSImageInfosModel.h"
#import "TTThemeConst.h"
#import "TTLabelTextHelper.h"

//#define kMeituanProductPicWidth     95.0f
//#define kMeituanProductPicHeight    80.0f
#define kMeituanHorizentalPadding   4.0f    //控件水平间距
#define kMeituanVerticalPadding     6.0f    //控件垂直间距
#define kMeituanVerticalMargin      16.0f   //cell垂直边距

@interface ExploreArticleMeituanAdCellView ()

@property (nonatomic, strong) SSMeituanAdsModel *meituanAds;

@end

@implementation ExploreArticleMeituanAdCellView

#pragma mark - update
- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    //根据数据更新UI属性，调用各种update方法
    if (self.orderedData && self.orderedData.managedObjectContext) {
        Article *article = self.orderedData.article;
        if (article && article.managedObjectContext) {
            self.meituanAds = [[SSMeituanAdsModel alloc] initWithDictionary:article.meituanAds];
            [self updateProductInfo];
            [self updateShopInfo];
            [self updateSoldInfo];
            [self updateProductPicInfo];
            //父类实现
            [self updateTypeLabel];
        }
        else {
            self.productDescriptionLabel.height = 0;
            self.shopInfoLabel.height = 0;
            self.shopDistanceLabel.height = 0;
            self.productCurrentPriceLabel.height = 0;
            self.productPreviousPriceLabel.height = 0;
            self.productPicImageView.height = 0;
        }
    }
}

- (void)updateProductInfo
{
    self.productDescriptionLabel.text = self.meituanAds.productDescription;
}

- (void)updateShopInfo
{
    self.shopInfoLabel.text = [NSString stringWithFormat:@"%@ / %@", self.meituanAds.merchantArea, self.meituanAds.shop];
    self.shopDistanceLabel.text = self.meituanAds.distance;
}

- (void)updateSoldInfo
{
    self.productCurrentPriceLabel.text = self.meituanAds.price;
    
    NSString *previousPriceString = self.meituanAds.value;
    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:previousPriceString];
    id value = @(NSUnderlineStyleSingle);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        value = @(NSUnderlinePatternSolid | NSUnderlineStyleSingle);
    }
    [attText addAttribute:NSStrikethroughStyleAttributeName
                    value:value
                    range:NSMakeRange(0, previousPriceString.length)];
    //strikeColor默认为foregroundColor，无需设置
//    [attText addAttribute:NSStrikethroughColorAttributeName
//                    value:[self.productPreviousPriceLabel textColor]
//                    range:NSMakeRange(0, previousPriceString.length)];
    self.productPreviousPriceLabel.attributedText = attText;
    
    self.productSoldCountLabel.text = self.meituanAds.sales;
}

- (void)updateProductPicInfo
{
    //UIImage *placeholder = [UIImage themedImageNamed:@"small_loadpic_empty_listpage.png"];
    self.productPicImageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground2];
    
    __weak typeof(self) weakSelf = self;
    SSImageInfosModel * model = [[SSImageInfosModel alloc] initWithDictionary:self.meituanAds.imageInfo];
    model.imageType = SSImageTypeMiddle;
    [self.productPicImageView setImageWithModel:model
                               placeholderImage:nil
                                        options:0
                                        success:^(UIImage *image, BOOL cached) {
                                            if (image) {
                                                [weakSelf.productPicImageView setImage:image];
                                                weakSelf.productPicImageView.backgroundColor = [UIColor clearColor];
                                                weakSelf.productPicImageView.nightCoverConstaintToImageSize = image.size;
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [weakSelf layoutProductPicInfo];
                                                });
                                            }
                                        } failure:^(NSError *error) {
                                        }];
    
    if (!isEmptyString(self.meituanAds.appointment)) {
        self.productFeaturePlaceholderImageView.hidden = NO;
        self.productFeaturePlaceholderImageView.image = [[self class] shouldShowProductFeaturePlaceholderImage];
        self.productFeatureLabel.text = self.meituanAds.appointment;
    }
    else {
        self.productFeaturePlaceholderImageView.hidden = YES;
    }
}

#pragma mark - layout
- (void)refreshUI
{
    //初始化subView并布局,调用各种layout方法
    [self layoutProductInfo];
    [self layoutShopInfo];
    [self layoutSoldInfo];
    [self layoutProductPicInfo];
    [self layoutInfoBarSubViews];
    [self layoutBottomLine];
}

- (void)layoutProductInfo
{
//    [self.productDescriptionLabel sizeToFit];
    self.productDescriptionLabel.textColor = [self.orderedData.article.hasRead boolValue] ? SSGetThemedColorWithKey(kColorText1Disabled) : SSGetThemedColorWithKey(kColorText1);
    self.productDescriptionLabel.font = [[self class] productInfoFont];
    self.productDescriptionLabel.frame = [[self class] frameForTitleLabel:self.productDescriptionLabel.text cellWidth:self.bounds.size.width];
}

- (void)layoutShopInfo
{
    [self.shopInfoLabel sizeToFit];
    CGRect bounds = self.shopInfoLabel.bounds;
    self.shopInfoLabel.frame = CGRectMake(self.productDescriptionLabel.left, self.productDescriptionLabel.bottom + kMeituanVerticalPadding, bounds.size.width, bounds.size.height);
    
    [self.shopDistanceLabel sizeToFit];
    bounds = self.shopDistanceLabel.bounds;
    self.shopDistanceLabel.frame = CGRectMake(self.shopInfoLabel.right + kMeituanHorizentalPadding, self.shopInfoLabel.top, bounds.size.width, bounds.size.height);
}

- (void)layoutSoldInfo
{
    [self.productCurrentPriceLabel sizeToFit];
    CGRect bounds = self.productCurrentPriceLabel.bounds;
    self.productCurrentPriceLabel.frame = CGRectMake(self.productDescriptionLabel.left, self.shopInfoLabel.bottom + kMeituanVerticalPadding - 3, bounds.size.width, bounds.size.height);
    
    [self.productPreviousPriceLabel sizeToFit];
    bounds = self.productPreviousPriceLabel.bounds;
    self.productPreviousPriceLabel.frame = CGRectMake(self.productCurrentPriceLabel.right + kMeituanHorizentalPadding, 0, bounds.size.width, bounds.size.height);
    self.productPreviousPriceLabel.centerY = self.productCurrentPriceLabel.centerY;
    
    [self.productSoldCountLabel sizeToFit];
    bounds = self.productSoldCountLabel.bounds;
    self.productSoldCountLabel.frame = CGRectMake(self.productPreviousPriceLabel.right + kMeituanHorizentalPadding * 2, 0, bounds.size.width, bounds.size.height);
    self.productSoldCountLabel.centerY = self.productCurrentPriceLabel.centerY;
}

- (void)layoutProductPicInfo
{
    self.productPicImageView.frame = CGRectMake(self.productDescriptionLabel.right + kCellRightPadding, kMeituanVerticalMargin, cellRightPicWidth(self.width), meituanCellRightPicHeight(self.width));
    
    self.productFeaturePlaceholderImageView.frame = CGRectMake(_productPicImageView.width - 47, 6, 47, 20);
    
    [self.productFeatureLabel sizeToFit];
    CGRect bounds = self.productFeatureLabel.bounds;
    self.productFeatureLabel.frame = CGRectMake(cellRightPicWidth(self.width) - bounds.size.width, 6, bounds.size.width, bounds.size.height);
    self.productFeatureLabel.frame = bounds;
    self.productFeatureLabel.center = CGPointMake(self.productFeaturePlaceholderImageView.width / 2 + 2, self.productFeaturePlaceholderImageView.height / 2);
}

- (void)layoutInfoBarSubViews
{
    CGFloat oriY = MAX(kMeituanVerticalMargin + meituanCellRightPicHeight(self.width) + kMeituanVerticalPadding, self.productCurrentPriceLabel.bottom + kMeituanVerticalPadding);
    self.infoBarView.frame = CGRectMake(kCellLeftPadding, oriY, self.width - kCellLeftPadding - kCellRightPadding, cellInfoBarHeight());
    [super layoutInfoBarSubViews];
}

#pragma mark - Getter

- (UILabel *)productDescriptionLabel
{
    //团品名称
    if (!_productDescriptionLabel) {
        _productDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productDescriptionLabel.backgroundColor = [UIColor clearColor];
        _productDescriptionLabel.numberOfLines = kCellTitleLabelMaxLine;
        _productDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _productDescriptionLabel.font = [[self class] productInfoFont];
        _productDescriptionLabel.textColor = SSGetThemedColorWithKey(kColorText1);
        [self addSubview:_productDescriptionLabel];
    }
    return _productDescriptionLabel;
}

- (UILabel *)shopInfoLabel
{
    //商圈名称/店铺名称
    if (!_shopInfoLabel) {
        _shopInfoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopInfoLabel.backgroundColor = [UIColor clearColor];
        _shopInfoLabel.numberOfLines = 1;
        _shopInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _shopInfoLabel.font = [[self class] shopInfoLabelFont];
        _shopInfoLabel.textColor = SSGetThemedColorWithKey(kColorText3);

        [self addSubview:_shopInfoLabel];
    }
    return _shopInfoLabel;
}

- (UILabel *)shopDistanceLabel
{
    if (!_shopDistanceLabel) {
        _shopDistanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopDistanceLabel.backgroundColor = [UIColor clearColor];
        _shopDistanceLabel.numberOfLines = 1;
        _shopDistanceLabel.font = [[self class] shopInfoLabelFont];
        _shopDistanceLabel.textColor = SSGetThemedColorWithKey(kColorText3);
        [self addSubview:_shopDistanceLabel];
    }
    return _shopDistanceLabel;
}

- (UILabel *)productCurrentPriceLabel
{
    if (!_productCurrentPriceLabel) {
        _productCurrentPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productCurrentPriceLabel.backgroundColor = [UIColor clearColor];
        _productCurrentPriceLabel.numberOfLines = 1;
        _productCurrentPriceLabel.font = [[self class] priceInfoLabelFont];
        _productCurrentPriceLabel.textColor = SSGetThemedColorWithKey(kColorText4);
        [self addSubview:_productCurrentPriceLabel];
    }
    return _productCurrentPriceLabel;
}

- (UILabel *)productPreviousPriceLabel
{
    if (!_productPreviousPriceLabel) {
        _productPreviousPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productPreviousPriceLabel.backgroundColor = [UIColor clearColor];
        _productPreviousPriceLabel.numberOfLines = 1;
        _productPreviousPriceLabel.font = [[self class] priceInfoLabelFont];
        _productPreviousPriceLabel.textColor = SSGetThemedColorWithKey(kColorText3);
        
        [self addSubview:_productPreviousPriceLabel];
    }
    return _productPreviousPriceLabel;
}

- (UILabel *)productSoldCountLabel
{
    if (!_productSoldCountLabel) {
        _productSoldCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productSoldCountLabel.backgroundColor = [UIColor clearColor];
        _productSoldCountLabel.numberOfLines = 1;
        _productSoldCountLabel.font = [[self class] soldInfoLabelFont];
        _productSoldCountLabel.textColor = SSGetThemedColorWithKey(kColorText3);
        
        [self addSubview:_productSoldCountLabel];
    }
    return _productSoldCountLabel;
}

- (SSImageView *)productPicImageView
{
    if (!_productPicImageView) {
        _productPicImageView = [[SSImageView alloc] initWithFrame:CGRectZero];
        _productPicImageView.imageContentMode = SSImageViewContentModeScaleAspectFit;
        [self addSubview:_productPicImageView];
    }
    return _productPicImageView;
}

- (UIImageView *)productFeaturePlaceholderImageView
{
    if (!_productFeaturePlaceholderImageView) {
        _productFeaturePlaceholderImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_productPicImageView addSubview:_productFeaturePlaceholderImageView];
    }
    return _productFeaturePlaceholderImageView;
}

- (UILabel *)productFeatureLabel
{
    if (!_productFeatureLabel) {
        _productFeatureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productFeatureLabel.backgroundColor = [UIColor clearColor];
        _productFeatureLabel.numberOfLines = 1;
        _productFeatureLabel.font = [[self class] fetureLabelFont];
        _productFeatureLabel.textColor = SSGetThemedColorWithKey(kColorText7);
        [_productFeaturePlaceholderImageView addSubview:_productFeatureLabel];
    }
    return _productFeatureLabel;
}

#pragma mark - ThemedChange

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self reloadThemeUI];
}

- (void)reloadThemeUI
{
    _productDescriptionLabel.textColor = SSGetThemedColorWithKey(kColorText1);
    _shopInfoLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    _shopDistanceLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    _productCurrentPriceLabel.textColor = SSGetThemedColorWithKey(kColorText4);
    _productPreviousPriceLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    _productSoldCountLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    _productFeatureLabel.textColor = SSGetThemedColorWithKey(kColorText7);
    _productFeaturePlaceholderImageView.image = [[self class] shouldShowProductFeaturePlaceholderImage];
}

#pragma mark - Helper
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        CGFloat cacheH = [orderedData cacheHeightForListType:listType];
        if (cacheH > 0) {
            return cacheH;
        }
        
        Article *article = orderedData.article;
        SSMeituanAdsModel *meituanModel = [[SSMeituanAdsModel alloc] initWithDictionary:article.meituanAds];
        CGRect titleLabelRect = [[self class] frameForTitleLabel:meituanModel.productDescription cellWidth:width];
        CGFloat shopLabelHeight = [[self class] labelSizeWithFont:[[self class] shopInfoLabelFont]];
        CGFloat priceLabelHeight = [[self class] labelSizeWithFont:[[self class] priceInfoLabelFont]];
        
        CGFloat sourceLabelHeight = cellInfoBarHeight();
        
        //取文字和图片高度叠加较高的
        CGFloat height = MAX(cellTopPadding() + titleLabelRect.size.height + cellTitleBottomPaddingToInfo() + shopLabelHeight + kMeituanVerticalPadding + priceLabelHeight, kMeituanVerticalMargin + meituanCellRightPicHeight(width));
        height += cellPaddingY() + sourceLabelHeight + kMeituanVerticalMargin;
        
        height = ceilf(height);
        [orderedData saveCacheHeight:height forListType:listType];
        
        return height;
    }
    
    return 0.f;
}

+ (CGRect)frameForTitleLabel:(NSString *)title cellWidth:(CGFloat)width
{
    UIFont *font = [[self class] productInfoFont];
    CGFloat titleWidth = width - kCellLeftPadding - kCellRightPadding * 2 - cellRightPicWidth(width);
    CGFloat titleHeight = [TTLabelTextHelper heightOfText:title fontSize:kCellTitleLabelFontSize forWidth:titleWidth];
    
    if (titleHeight > ceilf(font.lineHeight)*kCellTitleLabelMaxLine) {
        titleHeight = ceilf(font.lineHeight)*kCellTitleLabelMaxLine;
    }
    
    CGRect frame = CGRectZero;
    frame.origin.x = kCellLeftPadding;
    frame.origin.y = [[self class] topPaddingForTitleLabelTitle:title cellWidth:width];
    frame.size.width = titleWidth;
    frame.size.height = titleHeight;
    
    return frame;
}

+ (CGFloat)topPaddingForTitleLabelTitle:(NSString *)title cellWidth:(CGFloat)width
{
    CGFloat contentWidth = [TTLabelTextHelper sizeOfText:title fontSize:kCellTitleLabelFontSize forWidth:9999.0 forLineHeight:[[self class] productInfoFont].lineHeight constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:NSTextAlignmentLeft].width;
//    CGFloat contentWidth = widthOfContent(title, [[self class] productInfoFont].pointSize);
    CGFloat titleWidth = width - kCellLeftPadding - kCellRightPadding * 2 - cellRightPicWidth(width);
    CGFloat topPadding = cellTopPadding() + 4;
    if (contentWidth <= titleWidth) {
        topPadding += 10;
    }
    return topPadding;
}

+ (UIFont *)productInfoFont
{
    return [UIFont systemFontOfSize:kCellTitleLabelFontSize];
}

+ (UIFont *)shopInfoLabelFont
{
    return [UIFont systemFontOfSize:12.0f];
}

+ (UIFont *)priceInfoLabelFont
{
    return [UIFont systemFontOfSize:17.0f];
}

+ (UIFont *)soldInfoLabelFont
{
    return [UIFont systemFontOfSize:10.0f];
}

+(UIFont *)fetureLabelFont
{
    return [UIFont systemFontOfSize:12.0f];
}

+ (CGFloat)labelSizeWithFont:(UIFont *)font
{
    return font.lineHeight;
}

+ (UIImage *)shouldShowProductFeaturePlaceholderImage
{
    return [UIImage themedImageNamed:@"appointment_ad_textpage.png"];
}

static inline CGFloat meituanCellRightPicHeight(CGFloat cellWidth) {
    if ([TTDeviceHelper isPadDevice] && cellWidth > 640) {
        return 160.f;
    } else if ([TTDeviceHelper isScreenWidthLarge320]) {
        return 96.f;
    } else {
        return 80.f;
    }
}

@end
