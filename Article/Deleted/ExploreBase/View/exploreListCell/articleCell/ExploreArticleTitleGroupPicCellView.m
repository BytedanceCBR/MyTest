//
//  ExploreArticleTitleGroupPicCellView.m
//  Article
//
//  Created by Chen Hong on 14-9-14.
//
//

#import "ExploreArticleTitleGroupPicCellView.h"
#import "ExploreArticleCellViewConsts.h"
#import "Article.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "NewsUserSettingManager.h"
#import "ExploreCellHelper.h"

#import "NetworkUtilities.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTCategoryDefine.h"
#import "SSUserSettingManager.h"
#import "TTArticleCellHelper.h"
#import "NSString-Extension.h"
#import "TTDeviceHelper.h"

typedef NS_ENUM(NSInteger, GroupPicViewType)
{
    GroupPicViewTypeStream,             //主feed
    GroupPicViewTypeGallary122,         //顺时针中图-小图-小图布局
    GroupPicViewTypeGallary121,         //顺时针小图-中图-小图布局
    GroupPicViewTypeCommentMoment,      //评论列表嵌入话题帖子
};

@implementation ExploreArticleTitleGroupPicCellView
{
    SSThemedView *bottomSeperatorView;
    TTArticlePicViewStyle type;
    
    BOOL _isNormalChannelGallaryStyle; // 非图集频道样式
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
            type = [self.class picViewTypeWithOrderedData:self.orderedData];
            _isNormalChannelGallaryStyle = (self.orderedData.gallaryStyle == 1);
            [self updateTitleLabel];
            self.picView.style = type;
            [self.picView updatePics:self.orderedData];
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
        y += self.titleLabel.height + kCellGroupPicTopPadding;
    }
    
    CGFloat galleryWidth = (type == TTArticlePicViewStyleTriple || [TTDeviceHelper isPadDevice] || _isNormalChannelGallaryStyle) ? containWidth : self.width;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData adModel:nil picStyle:type width:galleryWidth];
    self.picView.frame = CGRectMake(x, y, picSize.width, picSize.height);
    
    self.infoBarView.frame = CGRectMake(kCellLeftPadding, self.picView.bottom + kCellInfoBarTopPadding, self.width - kCellLeftPadding - kCellRightPadding, kCellInfoBarHeight);
    
    [self layoutInfoBarSubViews];
    
    [self layoutAbstractAndCommentView:CGPointMake(self.titleLabel.left, self.infoBarView.bottom)];
    [self layoutEntityWordViewWithPic:YES];
    [self layoutForGalleryCellIfNeeded];
    if (type == GroupPicViewTypeStream || type == GroupPicViewTypeCommentMoment) {
        [self layoutBottomLine];
    }
}

- (void)layoutBottomSeperatorView
{
    if (![TTDeviceHelper isPadDevice]) {
        if (!bottomSeperatorView) {
            bottomSeperatorView = [SSThemedView new];
            bottomSeperatorView.backgroundColorThemeKey = kCellBottomLineBackgroundColor;
            bottomSeperatorView.layer.borderColor = [SSGetThemedColorWithKey(kCellBottomLineColor) CGColor];
            bottomSeperatorView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
            [self addSubview:bottomSeperatorView];
        }
        bottomSeperatorView.hidden = NO;
        bottomSeperatorView.frame = CGRectMake(0, self.height - kCellBottomLineHeight, self.width, kCellBottomLineHeight);
    }
}

- (void)layoutForGalleryCellIfNeeded
{
    //3图样式：图片在最上方，title在中间，不显示评论，dislike按钮位置调整
    if (type == GroupPicViewTypeGallary121 || type == GroupPicViewTypeGallary122) {
        if ([TTDeviceHelper isPadDevice] || _isNormalChannelGallaryStyle) {
            bottomSeperatorView.hidden = YES;
        } else {
            self.picView.top = 0;
            self.picView.left = 0;
            self.titleLabel.top = self.picView.bottom + kCellTopPadding;
            self.infoBarView.top = self.titleLabel.bottom + kCellTitleBottomPaddingToInfo;
            self.unInterestedButton.centerY = self.infoBarView.centerY;
            [self layoutAbstractAndCommentView:CGPointMake(self.titleLabel.left, self.infoBarView.bottom)];
            [self layoutEntityWordViewWithPic:YES];
            [self layoutBottomSeperatorView];
            if (self.orderedData.nextCellType == ExploreOrderedDataCellTypeLastRead) {
                bottomSeperatorView.hidden = YES;
                self.bottomLineView.hidden = YES;
            }
        }
    }
    else {
        bottomSeperatorView.hidden = YES;
    }
}

#pragma mark - Helper

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        TTArticlePicViewStyle type = [self picViewTypeWithOrderedData:orderedData];
        BOOL isGallery = (type == TTArticlePicViewStyleLeftLarge) || (type == TTArticlePicViewStyleRightLarge);
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (![TTDeviceHelper isPadDevice]  && isGallery
                && ([orderedData preCellHasBottomPadding])) {
                cacheH -= kCellBottomLineHeight;
            }
            return cacheH;
        }
        
        Article *article = orderedData.article;
        
        CGFloat containWidth = width - kCellLeftPadding - kCellRightPadding;
        CGFloat titleHeight = 0;
        if (article.title) {
            titleHeight = [article.title tt_sizeWithMaxWidth:containWidth font:([TTDeviceHelper isPadDevice] ? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] :[UIFont tt_fontOfSize:kCellTitleLabelFontSize]) lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine].height;
        }
        
        CGFloat sourceLabelHeight = kCellInfoBarHeight;
        
        CGSize picSize;
        CGFloat constaintWidth = [TTDeviceHelper isPadDevice] ? width - kCellLeftPadding - kCellRightPadding : width;
        
        if (type == TTArticlePicViewStyleLeftLarge || type == TTArticlePicViewStyleRightLarge) {
            if (orderedData.gallaryStyle == 1) {
                picSize = CGSizeMake(0, [ExploreCellHelper resizablePicSizeByWidth:width].height * 2 + kCellGroupPicPadding);
            } else {
                float aspect = 9.f / 16.f;
                picSize = CGSizeMake(constaintWidth, constaintWidth * aspect);
            }
        } else {
            picSize = [ExploreCellHelper resizablePicSizeByWidth:width];
        }
        
        CGFloat height;
        BOOL isNotGallaryChannel = orderedData.gallaryStyle == 1;
        
        if (!isNotGallaryChannel && type != TTArticlePicViewStyleTriple && ![TTDeviceHelper isPadDevice]) {
            height = kCellBottomPaddingWithPic + kCellBottomLineHeight + picSize.height + kCellTopPadding + titleHeight + kCellTitleBottomPaddingToInfo + sourceLabelHeight;
        } else {
            height = kCellTopPadding + kCellBottomPaddingWithPic + titleHeight + kCellGroupPicTopPadding + picSize.height + kCellInfoBarTopPadding + sourceLabelHeight;
        }
        
        BOOL hasAbstract = [ExploreCellHelper shouldDisplayAbstract:article listType:listType] && !isEmptyString(article.abstract);
        
        if (hasAbstract) {
            CGSize abstractSize = [ExploreCellHelper updateAbstractSize:article cellWidth:width];
            height += kCellAbstractVerticalPadding - kCellAbstractViewCorrect + abstractSize.height;
        }
        
        BOOL hasCommentView = [ExploreCellHelper shouldDisplayComment:article listType:listType];
        
        if (hasCommentView) {
            CGSize commentSize = [ExploreCellHelper updateCommentSize:article.commentContent cellWidth:width];
            height += commentSize.height + kCellCommentTopPadding;
        }
        
        if (article.entityWordInfoDict) {
            height += kCellEntityWordViewHeight + kCellEntityWordTopPadding;
        }
        
        height = ceilf(height);
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        if (![TTDeviceHelper isPadDevice] && isGallery
            && ([orderedData nextCellHasTopPadding])) {
            height -= kCellBottomLineHeight;
        }
        
        return height;
    }
    
    return 0.f;
}

+ (TTArticlePicViewStyle)picViewTypeWithOrderedData:(ExploreOrderedData *)orderedData
{
    //TODO:需增加orderedData的galleryCategoryType判断类型，普通列表的多图文章依然采用旧的样式
    //暂时先对主feed做过滤
    
    switch ([orderedData.article.gallaryFlag integerValue]) {
        case 0:
        case 1:
            return TTArticlePicViewStyleTriple;
        case 2:
            return TTArticlePicViewStyleLeftLarge;
        case 3:
            return TTArticlePicViewStyleRightLarge;
        default:
            return TTArticlePicViewStyleTriple;
    }
}

- (ExploreCellStyle)cellStyle {
    if (self.orderedData.article.isImageSubject) {
        return ExploreCellStylePhoto;
    } else {
        return ExploreCellStyleArticle;
    }
}

- (ExploreCellSubStyle)cellSubStyle {
    if (self.orderedData.article.isImageSubject) {
        if (type == GroupPicViewTypeGallary121) {
            return ExploreCellSubStyleGallery21;
        }
        else if (type == GroupPicViewTypeGallary122) {
            return ExploreCellSubStyleGallery12;
        }
        else {
            return ExploreCellSubStyleGalleryGroupPic;
        }
    } else {
        return ExploreCellSubStyleGroupPic;
    }
}

@end
