//
//  ExploreArticleTitleRightPicCellView.m
//  Article
//
//  Created by Chen Hong on 14-9-14.
//
//

#import "ExploreArticleTitleRightPicCellView.h"
#import "NewsUserSettingManager.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreCellHelper.h"
#import "TTLabelTextHelper.h"
#import "TTImageView+TrafficSave.h"

#import "NetworkUtilities.h"
#import "ExploreListHelper.h"
#import "Article.h"
//#import "TTRNView.h"
#import "TTArticleCellHelper.h"
#import "NSString-Extension.h"
#import "TTDeviceHelper.h"

@interface ExploreArticleTitleRightPicCellView ()
//@property(nonatomic, strong)TTRNView *rnview;
@end

@implementation ExploreArticleTitleRightPicCellView

+ (CGSize)picSizeWithCellWidth:(CGFloat)cellWidth
{
    static CGSize size;
    static CGFloat cellW = 0;
    if (size.height < 1 || cellW != cellWidth) {
        cellW = cellWidth;
        if ([TTDeviceHelper is736Screen] || [TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]) {
            size = [ExploreCellHelper resizablePicSizeByWidth:cellWidth];
        } else {
            float picW = cellRightPicWidth(cellWidth);
            float picH = cellRightPicHeight(cellWidth);
            size = CGSizeMake(picW, picH);
        }
    }
    return size;
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
            self.picView.style = TTArticlePicViewStyleRight;
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
    
//    if (!_rnview) {
//        _rnview = [[TTRNView alloc] initWithFrame:self.bounds];
//        [_rnview loadRNViewWithModuleName:@"RNCellView" initialProperties:@{@"title":self.orderedData.article.title}];
//        [self addSubview:_rnview];
//    } else {
//        [_rnview updateProperties:@{@"title":self.orderedData.article.title}];
//    }
}

- (void)refreshUI
{
    CGFloat containWidth = self.width - kCellLeftPadding - kCellRightPadding;
    
    //右图、标题、infoBar
    CGFloat x = kCellLeftPadding;
    CGFloat y = kCellTopPaddingWithRightPic;
    
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:nil picStyle:TTArticlePicViewStyleRight width:containWidth];
    self.picView.frame = CGRectMake(self.width - kCellRightPadding - picSize.width, y, picSize.width, picSize.height);
    
    
    CGFloat leftWidth = containWidth - kCellTitleRightPaddingToPic - self.picView.width;
    if (self.orderedData.article.title) {
        self.titleLabel.numberOfLines = kCellRightPicTitleLabelMaxLine;
        [self.titleLabel sizeToFit:leftWidth];
        self.titleLabel.origin = CGPointMake(x, y);
        y += self.titleLabel.height;
    }
    
    if ([self titleAndSourceHeightLargerThanPicH]) {
        if (self.titleLabel.height > self.picView.height) {
            // 标题与图片y方向居中对齐
            self.picView.centerY = ceil(self.titleLabel.centerY);
        }
        else {
            self.titleLabel.centerY = ceil(self.picView.centerY);
        }
        
        y = MAX(self.titleLabel.bottom, self.picView.bottom) + kCellInfoBarTopPadding;
        
        self.hideTimeLabel = NO;
        
        self.infoBarView.frame = CGRectMake(kCellLeftPadding, y, self.width - kCellLeftPadding - kCellRightPadding, kCellInfoBarHeight);
        
        y = self.infoBarView.bottom;
    }
    else {
        
        self.titleLabel.top = ceil(self.picView.top + (self.picView.height - [self titleAndSourceHeight]) / 2);
        y = self.titleLabel.bottom + kCellTitleBottomPaddingToInfo;
        self.hideTimeLabel = YES;
        
        CGFloat padding = kCellUninterestedButtonRightPadding;
        
        self.infoBarView.frame = CGRectMake(kCellLeftPadding, y, self.picView.left - kCellLeftPadding - padding,kCellInfoBarHeight);
        
        y = self.picView.bottom;
    }
        
    [self layoutInfoBarSubViews];
    
    [self layoutAbstractAndCommentView:CGPointMake(x, y)];
    
    BOOL isNotIPhone5 = ![TTDeviceHelper is568Screen];
    
    [self layoutEntityWordViewWithPic:isNotIPhone5];
    
    [self layoutBottomLine];
    
//    _rnview.frame = self.bounds;
}

- (CGFloat)titleAndSourceHeight
{
    float H = self.titleLabel.height + kCellInfoBarHeight + kCellTitleBottomPaddingToInfo;
    return H;
}

- (BOOL)titleAndSourceHeightLargerThanPicH
{
    CGFloat containWidth = self.width - kCellLeftPadding - kCellRightPadding;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:nil picStyle:TTArticlePicViewStyleRight width:containWidth];
    float H = [self titleAndSourceHeight];
    return H > picSize.height;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            return cacheH;
        }
        
        Article *article = orderedData.article;
        CGFloat containWidth = width - kCellLeftPadding - kCellRightPadding;
        
        //右图、标题、infoBar
        CGFloat height;
        CGFloat sourceLabelHeight = kCellInfoBarHeight;
        CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:nil adModel:nil picStyle:TTArticlePicViewStyleRight width:containWidth];
        CGFloat leftWidth = containWidth - kCellTitleRightPaddingToPic - picSize.width;
        CGFloat titleHeight = 0;
        if (article.title != nil) {
            titleHeight = [article.title tt_sizeWithMaxWidth:leftWidth font:[TTDeviceHelper isPadDevice]? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] :[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellRightPicTitleLabelMaxLine].height;
        }
        
        height = kCellTopPaddingWithRightPic + kCellBottomPaddingWithPic;
        CGFloat contentH = titleHeight + sourceLabelHeight + kCellTitleBottomPaddingToInfo;
        if (contentH > picSize.height) {
            if (titleHeight <= picSize.height) {
                contentH = picSize.height + kCellInfoBarTopPadding + sourceLabelHeight;
                height = height - kCellBottomPaddingWithPic + kCellBottomPadding;
            }
        } else {
            contentH = picSize.height;
        }
        
        height = height + contentH;
        
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
        
        return height;
    }
    
    return 0.f;
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
    if ([self.orderedData.article.hasVideo boolValue]) {
        return ExploreCellStyleVideo;
    }
    else if (self.orderedData.article.isImageSubject) {
        return ExploreCellStylePhoto;
    }
    else {
        return ExploreCellStyleArticle;
    }
}

- (ExploreCellSubStyle)cellSubStyle {
    if ([self.orderedData.article.hasVideo boolValue]) {
        return ExploreCellSubStyleVideoRightPic;
    }
    else if (self.orderedData.article.isImageSubject) {
        return ExploreCellSubStyleGalleryRightPic;
    }
    else {
        return ExploreCellSubStyleRighPic;
    }
}

@end
