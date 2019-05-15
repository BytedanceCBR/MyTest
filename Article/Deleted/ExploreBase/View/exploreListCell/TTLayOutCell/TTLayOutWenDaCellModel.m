//
//  TTLayOutWenDaCellModel.m
//  Article
//
//  Created by 王双华 on 2017/5/12.
//
//

#import "TTLayOutWenDaCellModel.h"
#import "TTArticleCellConst.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCellHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTLayOutCellDataHelper.h"
#import "TTLabelTextHelper.h"
#import "TTThreadCellHelper.h"

@implementation TTLayOutWenDaCellModel

- (void)calculateAllFrame
{
    self.originX = kPaddingLeft();
    CGFloat top = 16;
    self.containWidth = self.cellWidth - kPaddingLeft() - kPaddingRight();
    CGFloat height = top + [self heightForCellContentWithTop:top];
    self.cellCacheHeight = height;
    [self calculateBottomLineFrame];
}

- (void)calculateNeedUpdateFrame
{
    //
}

- (void)calculateBottomLineFrame
{
    self.bottomLineViewFrame = CGRectMake(0, self.cellCacheHeight - [TTDeviceHelper ssOnePixel], self.cellWidth, [TTDeviceHelper ssOnePixel]);
    self.bottomLineViewHidden = NO;
}

- (CGFloat)heightForCellContentWithTop:(CGFloat)top
{
    CGFloat height = 0;
    height += [self heightForWenDaHeaderInfoRegionWithDislikeWithTop:top];
    height += [self heightForCommentRegionWithTop:top + height];
    height += KUFPaddingCommentPicTop();
    height += [self heightForCommentCellLeftPicViewRegionWithTop:top + height];
    height += 14;
    return height;
}

- (CGFloat)heightForCommentCellLeftPicViewRegionWithTop:(CGFloat)top
{
    self.backgroundViewFrame = CGRectMake(self.originX, top, self.containWidth, kUFBackgroundViewHeight());
    self.backgroundViewHidden = NO;
    self.backgroundViewBackgroundColorThemeKey = kColorBackground3;
    
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData picStyle:TTArticlePicViewStyleLeftSmall width:self.containWidth];
    CGRect picViewFrame = CGRectMake(self.originX + kUFLeftPicViewLeftPadding(), top + kUFLeftPicViewTopPadding(), picSize.width, picSize.height);
    self.picViewFrame = picViewFrame;
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleLeftSmall;
    self.picViewHiddenMessage = YES;
    self.picViewUserInteractionEnabled = NO;
    
    if ([TTLayOutCellDataHelper shouldShowPlayButtonWithOrderedData:self.orderedData]) {
        self.playButtonFrame = CGRectMake(0, 0, picSize.width, picSize.height);
        self.playButtonHidden = NO;
        self.playButtonImageName = @"u11_play";
        self.playButtonUserInteractionEnable = NO;
    }
    
    CGFloat titleX = self.originX + kUFLeftPicViewLeftPadding() + kUFLeftPicViewSide() + kUFLeftPicViewRightPadding();
    CGFloat titleContainWidth = self.containWidth - kUFLeftPicViewLeftPadding() - kUFLeftPicViewSide() - kUFLeftPicViewRightPadding() - kUFTitleRightPaddingToBack();
    NSString *titleStr = self.orderedData.article.title;
    NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kUFDongtaiTitleFontSize() lineHeight:kUFDongtaiTitleLineHeight() lineBreakMode:NSLineBreakByTruncatingTail isBoldFontStyle:YES];
    self.newsTitleAttributedStr = titleAttributedStr;
    CGFloat titleHeight = [TTLabelTextHelper heightOfText:titleStr fontSize:kUFDongtaiTitleFontSize() forWidth:titleContainWidth forLineHeight:kUFDongtaiTitleLineHeight() constraintToMaxNumberOfLines:kUFDongtaiTitleLineNumber()
                                                   isBold:YES];
    CGFloat titleY = top + (kUFBackgroundViewHeight() - titleHeight) / 2;
    CGRect titleLabelFrame = CGRectMake(titleX, titleY, titleContainWidth, titleHeight);
    self.newsTitleLabelFrame = titleLabelFrame;
    self.newsTitleLabelHidden = NO;
    
    return kUFBackgroundViewHeight();
}

- (CGFloat)heightForCommentRegionWithTop:(CGFloat)top
{
    CGFloat height = 0;
    NSString *commentStr = self.orderedData.article.abstract;
    if (!isEmptyString(commentStr)) {
        CGFloat commentPadding = kUFCommentContentLineHeight() - kUFCommentContentFontSize();
        CGFloat commentY = top - commentPadding / 2;
        
        NSUInteger numberOfLines = [self.orderedData.article.showMaxLine integerValue];
        
        [self updateCommentAttr];
        
        CGSize size = [TTThreadCellHelper sizeThatFitsAttributedString:self.commentAttrLabelAttributedStr
                                                       withConstraints:CGSizeMake(self.containWidth, FLT_MAX)
                                                      maxNumberOfLines:numberOfLines
                                                limitedToNumberOfLines:&numberOfLines];
        self.commentLabelNumberOfLines = numberOfLines;
        self.commentLabelHidden = NO;
        self.commentLabelFrame = CGRectMake(self.originX, commentY, self.containWidth, size.height);
        self.commentLabelUserInteractionEnabled = NO;
        
        height = size.height - commentPadding;
    } else{
        self.commentLabelHidden = YES;
    }
    return height;
}

- (void)updateCommentAttr {
    NSString *commentStr = self.orderedData.article.abstract;
    if (!isEmptyString(commentStr)) {
        NSDictionary * attrDic = [self commentLabelAttributedDictionaryWithOrderedData:self.orderedData containReadStatus:YES];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithString:commentStr
                                                                       attributes:attrDic];
        self.commentAttrLabelAttributedStr = attrStr;
        self.commentAttrTruncationToken = [TTThreadCellHelper truncationFont:[attrDic objectForKey:NSFontAttributeName]
                                                                contentColor:attrDic[NSForegroundColorAttributeName]
                                                                       color:[UIColor tt_themedColorForKey:kColorText5]
                                                                     linkUrl:nil];
    }
}

- (NSDictionary *)commentLabelAttributedDictionaryWithOrderedData:(ExploreOrderedData *)data containReadStatus:(BOOL)containReadStatus {
    NSMutableDictionary * attributeDictionary = @{}.mutableCopy;
    [attributeDictionary setValue:[UIFont tt_fontOfSize:kUFThreadContentFontSize()] forKey:NSFontAttributeName];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if ([TTDeviceHelper OSVersionNumber] < 8) {
        paragraphStyle.minimumLineHeight = kUFThreadContentLineHeight();
        paragraphStyle.maximumLineHeight = kUFThreadContentLineHeight();
        paragraphStyle.lineHeightMultiple = kUFThreadContentLineHeight() - kUFThreadContentFontSize();
    }else {
        paragraphStyle.minimumLineHeight = kUFThreadContentFontSize();
        paragraphStyle.maximumLineHeight = kUFThreadContentFontSize();
        paragraphStyle.lineSpacing = kUFThreadContentLineHeight() - kUFThreadContentFontSize();
    }
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [attributeDictionary setValue:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    if (containReadStatus && [data hasRead]) {
        [attributeDictionary setValue:[UIColor tt_themedColorForKey:kTitleViewHasReadTextColor()] forKey:NSForegroundColorAttributeName];
    }else {
        [attributeDictionary setValue:[UIColor tt_themedColorForKey:kTitleViewTextColor()] forKey:NSForegroundColorAttributeName];
    }
    return attributeDictionary.copy;
    
}

/**
 *  icon 问答  你关注的问题有了新回答  dislike按钮
 */
- (CGFloat)heightForWenDaHeaderInfoRegionWithDislikeWithTop:(CGFloat)top
{
    CGFloat infoRegionHeight = kUFWenDaButtonHeight() + 18;
    
    CGFloat left = self.originX;
    CGFloat containWidth = self.containWidth;
    CGFloat sourceMaxWidth = containWidth;
    
    CGFloat unInterestedBtnX = 0,unInterestedBtnY = 0;
    CGFloat unInterestedBtnWidth = 60;
    CGFloat unInterestedBtnHeight = 44;
    unInterestedBtnX = ceil(left + self.containWidth - kCellUninterestedButtonWidth / 2 - unInterestedBtnWidth / 2);
    unInterestedBtnY = ceilf(top + (kUFWenDaButtonHeight() - unInterestedBtnHeight) / 2);
    CGRect unInterestedBtnFrame = CGRectMake(unInterestedBtnX, unInterestedBtnY, unInterestedBtnWidth, unInterestedBtnHeight);
    self.unInterestedButtonFrame = unInterestedBtnFrame;
//    if (self.listType == ExploreOrderedDataListTypeFavorite ||
//        self.listType == ExploreOrderedDataListTypeReadHistory ||
//        self.listType == ExploreOrderedDataListTypePushHistory ||
//        (self.orderedData.showDislike && ![self.orderedData.showDislike boolValue])){
//        self.unInterestedButtonHidden = YES;
//    }
//    else{
//        self.unInterestedButtonHidden = NO;
//    }
    self.unInterestedButtonHidden = YES;
    
    self.wenDaButtonFrame = CGRectMake(left, top, kUFWenDaButtonWidth(), kUFWenDaButtonHeight());
    sourceMaxWidth -= self.wenDaButtonFrame.size.width;
    self.wenDaButtonHidden = NO;
    left += self.wenDaButtonFrame.size.width + kUFWenDaSourceLabelLeftPadding();
    sourceMaxWidth -= kUFWenDaSourceLabelLeftPadding();
    
    if (!self.unInterestedButtonHidden) {
        sourceMaxWidth -= ceilf((kCellUninterestedButtonWidth / 2 + unInterestedBtnWidth / 2));
    }
    sourceMaxWidth -= 30.f;//右边留30pi
    
    NSString *sourceStr = self.orderedData.article.sourceDesc;
    CGSize sourceSize = [sourceStr sizeWithAttributes:@{NSFontAttributeName :[UIFont tt_fontOfSize:kUFWenDaSourceLabelFontSize()]}];
    sourceSize = CGSizeMake(ceilf(sourceSize.width), ceilf(sourceSize.height));
    if (sourceMaxWidth > 0 && sourceSize.width > 0) {
        CGFloat sourceY = ceilf(top + (kUFWenDaButtonHeight() - sourceSize.height) / 2);
        self.sourceLabelFrame = CGRectMake(left, sourceY, sourceMaxWidth, sourceSize.height);
        self.sourceLabelHidden = NO;
        self.sourceLabelStr = sourceStr;
        self.sourceLabelFontSize = kUFWenDaSourceLabelFontSize();
        self.sourceLabelTextColorThemeKey = kColorText2;
        self.sourceLabelUserInteractionEnabled = YES;
    }

    return infoRegionHeight;
}

@end
