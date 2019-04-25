//
//  ExploreListPureTitleCellView.m
//  Article
//
//  Created by Chen Hong on 14-9-9.
//
//

#import "ExploreArticlePureTitleCellView.h"
#import "ExploreArticleCellViewConsts.h"
#import "Article.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "NewsUserSettingManager.h"
#import "ExploreCellHelper.h"

#import "TTLabelTextHelper.h"
#import "NSString-Extension.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceHelper.h"

@implementation ExploreArticlePureTitleCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {}
    
    return self;
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
            [self updateTypeLabel];
            [self updateAbstract];
            [self updateCommentView];
            [self updateEntityWordView];
        } else {
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
    
    y += kCellTitleBottomPaddingToInfo;
    self.infoBarView.frame = CGRectMake(kCellLeftPadding, y, self.width - kCellLeftPadding - kCellRightPadding, kCellInfoBarHeight);
    
    [self layoutInfoBarSubViews];
    
    CGPoint origin = CGPointMake(self.titleLabel.left, self.infoBarView.bottom);

    [self layoutAbstractAndCommentView:origin];
    
    [self layoutEntityWordViewWithPic:NO];
    
    [self layoutBottomLine];
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
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
        CGFloat height = kCellTopPadding + kCellBottomPadding;
        CGFloat containWidth = width - kCellLeftPadding - kCellRightPadding;
        
        // 计算基本高度(titleLabel、infoBar)
        if (article.title) {
            CGFloat titleHeight = [article.title tt_sizeWithMaxWidth:containWidth font:[TTDeviceHelper isPadDevice]? [UIFont tt_boldFontOfSize:kCellTitleLabelFontSize] :[UIFont tt_fontOfSize:kCellTitleLabelFontSize] lineHeight:kCellTitleLineHeight numberOfLines:kCellTitleLabelMaxLine].height;
            height += titleHeight;
        }
        
        height += kCellTitleBottomPaddingToInfo + kCellInfoBarHeight;
        
        // 计算摘要高度
        BOOL hasAbstract = [ExploreCellHelper shouldDisplayAbstract:article listType:listType] && !isEmptyString(article.abstract);
        if (hasAbstract) {
            CGSize abstractSize = [ExploreCellHelper updateAbstractSize:article cellWidth:width];
            height += kCellAbstractVerticalPadding + abstractSize.height - kCellAbstractViewCorrect;
        }
        
        // 计算评论高度
        BOOL hasCommentView = [ExploreCellHelper shouldDisplayComment:article listType:listType];
        if (hasCommentView) {
            CGSize commentSize = [ExploreCellHelper updateCommentSize:article.commentContent cellWidth:width];
            height += kCellCommentTopPadding + commentSize.height;
        }
        
        // 计算实体词高度
        if (article.entityWordInfoDict) {
            height += kCellEntityWordTopPadding + kCellEntityWordViewHeight;
        }
        
        height = ceilf(height);
        
        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];
        
        return height;
    }
    
    return 0.f;
}

- (ExploreCellStyle)cellStyle {
    return ExploreCellStyleArticle;
}

- (ExploreCellSubStyle)cellSubStyle {
    return ExploreCellSubStylePureTitle;
}

@end
