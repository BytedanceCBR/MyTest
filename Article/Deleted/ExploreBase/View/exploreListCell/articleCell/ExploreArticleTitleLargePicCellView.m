//
//  ExploreArticleTitleLargePicCellView.m
//  Article
//
//  Created by Chen Hong on 14-9-14.
//
//

#import "ExploreArticleTitleLargePicCellView.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"

#import "NetworkUtilities.h"
#import "Article.h"
#import "TTArticleCellHelper.h"
#import "NSString-Extension.h"
#import "TTDeviceHelper.h"
#import "ExploreOrderedData+TTAd.h"

@implementation ExploreArticleTitleLargePicCellView
{
    LargePicViewType type;
    SSThemedView *bottomSeperatorView;
    
    BOOL _isNormalChannelGallaryStyle;
}

- (SSThemedView *)adInfoBgView
{
    if (!_adInfoBgView) {
        _adInfoBgView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _adInfoBgView.backgroundColorThemeKey = kColorBackground3;
        _adInfoBgView.borderColorThemeKey = kColorLine1;
        _adInfoBgView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    }
    return _adInfoBgView;
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    bottomSeperatorView.backgroundColorThemeKey = kCellBottomLineBackgroundColor;
    bottomSeperatorView.layer.borderColor = [SSGetThemedColorWithKey(kCellBottomLineColor) CGColor];
    bottomSeperatorView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
}

- (void)refreshWithData:(id)data
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    if (self.orderedData && self.orderedData.managedObjectContext) {
        Article *article = self.orderedData.article;
        if (article && article.managedObjectContext) {
            [self updateTitleLabel];
            self.picView.style = TTArticlePicViewStyleLarge;
            [self.picView updatePics:self.orderedData];
            type = [self.class largePicTypeForArticle:article];
            
            _isNormalChannelGallaryStyle = (self.orderedData.gallaryStyle == 1);
            [self updateTypeLabel];
            [self updateAbstract];
            [self updateCommentView];
            [self updateEntityWordView];
        }
        else {
            self.typeLabel.height = 0;
            self.titleLabel.height = 0;
        }
    }
}

- (void)refreshUI
{
    CGFloat x = kCellLeftPadding;
    CGFloat y = kCellTopPadding;
    CGFloat containWidth = self.width - kCellLeftPadding - kCellRightPadding;
    
    if (self.orderedData.article.title) {
        [self.titleLabel sizeToFit:containWidth];
        self.titleLabel.origin = CGPointMake(x, y);
        y += self.titleLabel.height;
    }
    
    y += kCellGroupPicTopPadding;
    CGFloat galleryWidth = ([TTDeviceHelper isPadDevice] || _isNormalChannelGallaryStyle || type == LargePicViewTypeNormal) ? containWidth : self.width;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData adModel:nil picStyle:TTArticlePicViewStyleLarge width:galleryWidth];
    self.picView.frame = CGRectMake(x, y, picSize.width, picSize.height);
    //    [self layoutPic];
    
    if ([self.orderedData isAdButtonUnderPic]) {
        self.adInfoBgView.frame = CGRectMake(kCellLeftPadding, self.picView.bottom - [TTDeviceHelper ssOnePixel], SSWidth(self.picView), kCellADInfoBgViewHeight);
        y = self.adInfoBgView.bottom + kCellInfoBarTopPadding;
        [self addSubview:_adInfoBgView];
        self.adInfoBgView.hidden = NO;
    }
    else {
        [self.adInfoBgView removeFromSuperview];
        self.adInfoBgView.hidden = YES;
        y = self.picView.bottom + kCellInfoBarTopPadding;
    }

    self.infoBarView.frame = CGRectMake(kCellLeftPadding, ceilf(y), self.width - kCellLeftPadding - kCellRightPadding, kCellInfoBarHeight);
    
    [self layoutInfoBarSubViews];
    
    [self layoutAbstractAndCommentView:CGPointMake(self.titleLabel.left, self.infoBarView.bottom)];
    
    [self layoutEntityWordViewWithPic:YES];
    
    [self layoutForGalleryCellIfNeeded];
    if (type == LargePicViewTypeNormal || _isNormalChannelGallaryStyle) {
        [self layoutBottomLine];
    }
}

- (void)layoutBottomSeperatorView
{
    if (![TTDeviceHelper isPadDevice]) {
        if (!bottomSeperatorView) {
            bottomSeperatorView = [SSThemedView new];
            bottomSeperatorView.backgroundColorThemeKey = kColorBackground3;
            [self addSubview:bottomSeperatorView];
        }
        bottomSeperatorView.hidden = NO;
        if (![TTDeviceHelper isPadDevice] && type == LargePicViewTypeGallary && !_isNormalChannelGallaryStyle && [self.orderedData nextCellHasTopPadding]){
            bottomSeperatorView.hidden = YES;
        }
        bottomSeperatorView.frame = CGRectMake(0, self.height - kCellSeprateViewHeight(), self.width, kCellSeprateViewHeight());
    }
}

- (void)layoutForGalleryCellIfNeeded
{
    //3图样式：图片在最上方，title在中间，不显示评论，dislike按钮位置调整
    if (type == LargePicViewTypeGallary) {
        ///...
        if ([TTDeviceHelper isPadDevice] || _isNormalChannelGallaryStyle) {
            bottomSeperatorView.hidden = YES;
        }
        else {
            self.picView.top = 0;
            self.picView.left = 0;
            self.titleLabel.top = self.picView.bottom + kCellGroupPicTopPadding;
            self.infoBarView.top = self.titleLabel.bottom + kCellTitleBottomPaddingToInfo;
            self.unInterestedButton.centerY = self.infoBarView.centerY;
            [self layoutAbstractAndCommentView:CGPointMake(self.titleLabel.left, self.infoBarView.bottom)];
            [self layoutEntityWordViewWithPic:YES];
            [self layoutBottomSeperatorView];
            if (self.orderedData.nextCellType == ExploreOrderedDataCellTypeLastRead ) {
                bottomSeperatorView.hidden = YES;
                self.bottomLineView.hidden = YES;
            }
        }
    }
    else {
        bottomSeperatorView.hidden = YES;
        if ([self.orderedData.categoryID isEqualToString:@"video"]) {
            [self layoutBottomSeperatorView];
        }
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        BOOL isNotGallaryChannel = (orderedData.gallaryStyle == 1);
        Article *article = orderedData.article;
        LargePicViewType type = [self largePicTypeForArticle:article];
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (![TTDeviceHelper isPadDevice] && type == LargePicViewTypeGallary && !isNotGallaryChannel &&
                ([orderedData nextCellHasTopPadding])) {
                cacheH -= kCellBottomViewHeight;
            }
            return cacheH;
        }
        
        CGFloat containWidth = width - kCellLeftPadding - kCellRightPadding;
        
        CGFloat titleHeight = 0;
        // 计算基本高度(titleLabel、infoBar)
        if (article.title) {
            titleHeight = [article.title tt_sizeWithMaxWidth:containWidth font:[TTDeviceHelper isPadDevice]? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] :[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine].height;
        }
        CGFloat sourceLabelHeight = kCellInfoBarHeight;
        
        TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:orderedData.listLargeImageDict];
        // 根据图片实际宽高设置其在cell中的高度
        BOOL isPad = [TTDeviceHelper isPadDevice];
        
        ///...
        CGFloat galleryWidth = (isPad || isNotGallaryChannel) ? [ExploreCellHelper largeImageWidth:width] : width;
        
        float imageHeight = ceil(type == LargePicViewTypeGallary ? galleryWidth * 9.f/16.f : [ExploreCellHelper heightForImageWidth:model.width height:model.height constraintWidth:[ExploreCellHelper largeImageWidth:width]]);
        
        CGFloat height;
        
        //标题、大图、infoBar
        if (type == LargePicViewTypeGallary && !isNotGallaryChannel && ![TTDeviceHelper isPadDevice]) {
            height = kCellBottomPaddingWithPic + kCellSeprateViewHeight() + imageHeight + kCellGroupPicTopPadding + titleHeight + kCellTitleBottomPaddingToInfo + sourceLabelHeight;
        } else {
            height = kCellTopPadding + kCellBottomPaddingWithPic + titleHeight + kCellGroupPicTopPadding + imageHeight + kCellInfoBarTopPadding + sourceLabelHeight;
            if ([orderedData isAdButtonUnderPic]){
                height += kCellADInfoBgViewHeight - [TTDeviceHelper ssOnePixel];
            }
            if ([orderedData.categoryID isEqualToString:@"video"]) {
                height += kCellSeprateViewHeight();
            }
        }
        
        //摘要
        BOOL hasAbstract = [ExploreCellHelper shouldDisplayAbstract:article listType:listType] && !isEmptyString(article.abstract);
        if (hasAbstract) {
            CGSize abstractSize = [ExploreCellHelper updateAbstractSize:article cellWidth:width];
            height += kCellAbstractVerticalPadding - kCellAbstractViewCorrect + abstractSize.height;
        }
        
        //评论
        BOOL hasCommentView = [ExploreCellHelper shouldDisplayComment:article listType:listType];
        if (hasCommentView) {
            CGSize commentSize = [ExploreCellHelper updateCommentSize:article.commentContent cellWidth:width];
            height += kCellCommentTopPadding + commentSize.height;
        }
        
        //实体词
        if (article.entityWordInfoDict) {
            height += kCellEntityWordTopPadding + kCellEntityWordViewHeight;
        }
        
        height = ceilf(height);
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        if (![TTDeviceHelper isPadDevice] && type == LargePicViewTypeGallary && !isNotGallaryChannel && [orderedData nextCellHasTopPadding]) {
            height -= kCellSeprateViewHeight();
        }
        
        return height;
    }
    
    return 0.f;
}

+ (LargePicViewType)largePicTypeForArticle:(Article *)article
{
    return [article.gallaryFlag longLongValue] == 1 ? LargePicViewTypeGallary : LargePicViewTypeNormal;
}

//- (UIView *)animationFromView
//{
//    return self.picView;
//}
//
//- (UIImage *)animationFromImage
//{
//    return [self.picView animationFromView].imageView.image;
//}

- (ExploreCellStyle)cellStyle {
    if (self.orderedData.article.isImageSubject) {
        return ExploreCellStylePhoto;
    } else {
        return ExploreCellStyleArticle;
    }
}

- (ExploreCellSubStyle)cellSubStyle {
    if (self.orderedData.article.isImageSubject) {
        return ExploreCellSubStyleGalleryLargePic;
    } else {
        return ExploreCellSubStyleLargePic;
    }
}

@end
