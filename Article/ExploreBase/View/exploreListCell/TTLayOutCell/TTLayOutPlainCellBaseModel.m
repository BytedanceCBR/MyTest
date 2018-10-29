//
//  TTLayOutPlainCellBaseModel.m
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//


#import "TTLayOutPlainCellBaseModel.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTAdFeedModel.h"
#import "TTUGCEmojiParser.h"
#import "TTVerifyIconHelper.h"

@implementation TTLayOutPlainCellBaseModel

- (void)calculateNeedUpdateFrame
{
    if (self.infoBarOriginY > 0 && self.infoBarContainWidth > 0) {
        [self calculateBottomLineFrame];
        [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    }
}

- (void)calculateBottomLineFrame
{
    if (![self.orderedData nextCellHasTopPadding]){
        self.bottomLineViewFrame = CGRectMake(kCellLeftPadding, self.cellCacheHeight - [TTDeviceHelper ssOnePixel], self.containWidth, [TTDeviceHelper ssOnePixel]);
        self.bottomLineViewHidden = NO;
    }
}

//cell 顶部间距
- (CGFloat)heightForCellTopPadding
{
    return kCellTopPadding;
}
//cell 底部间距
- (CGFloat)heightForCellBottomPadding
{
    return kCellBottomPaddingWithPic;
}

//infoBar上边距
- (CGFloat)heightForInfoBarTopPadding
{
    return kCellInfoBarTopPadding;
}

- (CGFloat)heightForTitleRegionForPlainCellWithTop:(CGFloat)top
{
    CGFloat height = 0;
    NSString *titleStr = [TTLayOutCellDataHelper getTitleStringWithOrderedData:self.orderedData];
    if (!isEmptyString(titleStr)) {
        NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kCellTitleLabelFontSize lineHeight:kCellTitleLineHeight lineBreakMode:NSLineBreakByTruncatingTail];
        CGSize titleSize = CGSizeMake(self.containWidth, 0);
        titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kCellTitleLabelFontSize forWidth:self.containWidth forLineHeight:kCellTitleLineHeight constraintToMaxNumberOfLines:kCellTitleLabelMaxLine];
        CGFloat titlePadding = kCellTitleLineHeight - kCellTitleLabelFontSize;
        //上下剪去行高导致的留白
        CGFloat titleY = top - titlePadding / 2;
        height = titleSize.height - titlePadding;
        CGRect titleFrame = CGRectMake(self.originX, titleY, titleSize.width, titleSize.height);
        
        self.titleAttributedStr = titleAttributedStr;
        self.titleLabelFrame = titleFrame;
        self.titleLabelHidden = NO;
        self.titleLabelNumberOfLines = kCellTitleLabelMaxLine;
    }
    return height;
}

#pragma mark Height for ArticleInfo region

- (CGFloat)heightForArticleInfoRegionWithTop:(CGFloat)top containWidth:(CGFloat)containWidth
{
    CGFloat left = self.originX;
    CGFloat labelY = top + floor((kCellInfoBarHeight - kCellTypeLabelHeight) / 2) + 4;
    CGFloat margin = 4;
    NSString *typeString = [TTLayOutCellDataHelper getTypeStringWithOrderedData:self.orderedData];
    
    CGFloat sourceMaxWidth = containWidth - kCellUninterestedButtonWidth - 4;
    
    if (!isEmptyString(typeString)) {
        //优化，字符串相同时避免重复计算
        if (![self.typeLabelStr isEqualToString:typeString]) {
            CGSize typeSize = [typeString sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellTypeLabelFontSize]}];
            typeSize = CGSizeMake(ceilf(typeSize.width), ceilf(typeSize.height));
            CGRect typeLabelFrame = CGRectMake(left, labelY, typeSize.width + kCellTypeLabelInnerPadding * 2, kCellTypeLabelHeight);
            self.typeLabelFrame = typeLabelFrame;
            self.typeLabelStr = typeString;
        }
        left += self.typeLabelFrame.size.width + kCellTypelabelRightPaddingToInfoLabel;
        sourceMaxWidth -= (self.typeLabelFrame.size.width + kCellTypelabelRightPaddingToInfoLabel);
        self.typeLabelHidden = NO;
    }
    TTAdFeedModel* rawAdModel = self.orderedData.raw_ad;
    if ([rawAdModel hasLocationInfo] && rawAdModel.adType == ExploreActionTypeWeb) {
        [self layoutLocationArticleInfoRegionWidth:sourceMaxWidth left:left top:top margin:margin];
    }
    else{
        [self layoutNormalArticleInfoRegionWidth:sourceMaxWidth - 6 left:left top:top labelY:labelY containWidth:containWidth];
    }
    
    CGFloat unInterestedBtnWidth = 60;
    CGFloat unInterestedBtnHeight = 44;
    CGFloat unInterestedBtnX = ceil(self.originX + containWidth - kCellUninterestedButtonWidth / 2 - unInterestedBtnWidth / 2);
    CGFloat unInterestedBtnY = ceil(top + kCellInfoBarHeight / 2 - unInterestedBtnHeight / 2);
    CGRect unInterestedBtnFrame = CGRectMake(unInterestedBtnX, unInterestedBtnY, unInterestedBtnWidth, unInterestedBtnHeight);
    self.unInterestedButtonFrame = unInterestedBtnFrame;

    if ([self.orderedData isInCard] ||
        self.listType == ExploreOrderedDataListTypeFavorite ||
        self.listType == ExploreOrderedDataListTypeReadHistory ||
        self.listType == ExploreOrderedDataListTypePushHistory ||
        (self.orderedData.showDislike && ![self.orderedData.showDislike boolValue])){
        self.unInterestedButtonHidden = YES;
    }
    else{
        self.unInterestedButtonHidden = NO;
    }
    
    return kCellInfoBarHeight;
}

- (void)layoutNormalArticleInfoRegionWidth:(CGFloat)sourceMaxWidth left:(CGFloat)left top:(CGFloat)top labelY:(CGFloat)labelY containWidth:(CGFloat)containWidth
{
    CGFloat infoMaxWidth = sourceMaxWidth;
    BOOL hideSource = [self.orderedData isAdButtonUnderPic] && ![TTLayOutCellDataHelper isAdShowSourece:self.orderedData];
    if (sourceMaxWidth > 0 && !isEmptyString(self.orderedData.article.source) && [self.orderedData isShowSourceLabel] && !hideSource) {
        NSString *sourceString = [TTArticleCellHelper fitlerSourceStr:self.orderedData.article.source];
        NSString *fixedSourceString = [sourceString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //优化，字符串相同时避免重复计算
        if (![self.sourceLabelStr isEqualToString:fixedSourceString]) {
            CGSize sourceSize = [fixedSourceString sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kCellInfoLabelFontSize]}];
            sourceSize = CGSizeMake(MIN(sourceMaxWidth, ceilf(sourceSize.width)), ceilf(sourceSize.height));
            self.sourceLabelFrame = CGRectMake(left, labelY, sourceSize.width, kCellTypeLabelHeight);
            self.sourceLabelStr = fixedSourceString;
        } else {
            self.sourceLabelFrame = CGRectMake(left, labelY, self.sourceLabelFrame.size.width, kCellTypeLabelHeight);
        }
        
        self.sourceLabelFontSize = kCellInfoLabelFontSize;
        self.sourceLabelTextColorThemeKey = kFHColorCoolGrey2;
        self.sourceLabelHidden = NO;
        left += self.sourceLabelFrame.size.width;
        infoMaxWidth -= self.sourceLabelFrame.size.width;
        
        left += [TTDeviceHelper isPadDevice] ? 14.f : 8.f;
        infoMaxWidth -= [TTDeviceHelper isPadDevice] ? 14.f : 8.f;
    }
    
    CGRect infoLabelFrame = CGRectZero;
    NSArray *infoArray = [TTLayOutCellDataHelper getInfoStringWithOrderedData:self.orderedData hideTimeLabel:self.hideTimeForRightPic];
    if (infoMaxWidth > 0 && infoArray.count > 0) {
        NSString *infoString = [infoArray lastObject];
        //优化，字符串相同时避免重复计算
        if (![self.infoLabelStr isEqualToString:infoString]) {
            NSString *fixedInfoStr = [infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            CGSize infoSize = [fixedInfoStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellInfoLabelFontSize]}];
            infoSize = CGSizeMake(ceilf(infoSize.width), ceilf(infoSize.height));
            
            int index = (int)infoArray.count - 1;
            while (infoSize.width > infoMaxWidth && index > 0) {
                index -= 1;
                infoString = [infoArray objectAtIndex:index];
                fixedInfoStr = [infoString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                infoSize = [fixedInfoStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellInfoLabelFontSize]}];
                infoSize = CGSizeMake(ceilf(infoSize.width), ceilf(infoSize.height));
            }
            if (infoSize.width <= infoMaxWidth) {
                self.infoLabelStr = infoString;
                infoLabelFrame = CGRectMake(left, labelY, infoSize.width, kCellTypeLabelHeight);
            }
            else{
                self.infoLabelStr = @"";
                infoLabelFrame = CGRectMake(left, labelY, 0, kCellTypeLabelHeight);
            }
        } else {
            infoLabelFrame = self.infoLabelFrame;
            infoLabelFrame.origin.x = left;
        }
    } else {
        self.infoLabelStr = @"";
        infoLabelFrame = CGRectMake(left, labelY, 0, kCellTypeLabelHeight);
    }
    
    self.infoLabelFontSize = kCellInfoLabelFontSize;
    self.infoLabelTextColorThemeKey = kFHColorCoolGrey2;
    self.infoLabelFrame = infoLabelFrame;
    self.infoLabelHidden = NO;
    
}

- (void)layoutLocationArticleInfoRegionWidth:(CGFloat)sourceMaxWidth left:(CGFloat)left top:(CGFloat)top margin:(CGFloat)margin
{
    self.sourceLabelHidden = YES;
    self.infoLabelHidden = YES;
    self.adLocationIconHidden = NO;
    self.adLocationLabelHidden = NO;
    TTAdFeedModel* rawAdModel = self.orderedData.raw_ad;
    
    CGFloat adLocationIconOriginY = ceilf(top + (kCellInfoBarHeight - KCellADLocationIconHeight) / 2);
    left = left + 1;
    self.adLocationIconFrame = CGRectMake(left, adLocationIconOriginY, KCellADLocationIconWidth, KCellADLocationIconHeight);
    CGFloat locationMaxWidth = sourceMaxWidth - self.adLocationIconFrame.size.width + margin;
    left = left + self.adLocationIconFrame.size.width + margin;
    self.adLocationLabelFontSize = kCellInfoLabelFontSize;
    self.adLocationLabelTextColorThemeKey = kCellInfoLabelTextColor;
    
    NSString *district = !isEmptyString(rawAdModel.locationDistrict)? rawAdModel.locationDistrict: @"";
    NSString *street = !isEmptyString(rawAdModel.locationStreet)? rawAdModel.locationStreet: @"";
    NSString *source = !isEmptyString(self.orderedData.article.source)? self.orderedData.article.source: @"";
    NSString *distance = !isEmptyString(rawAdModel.locationDisdance)? rawAdModel.locationDisdance: @"";
    
    NSString* locationStr = [NSString stringWithFormat:@"%@ %@ %@ %@", district, street, source, distance];
    CGSize locationSize = [locationStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellInfoLabelFontSize]}];
    if (locationSize.width > locationMaxWidth) {
        locationStr = [NSString stringWithFormat:@"%@ %@ %@", street, source, distance];
        locationSize = [locationStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellInfoLabelFontSize]}];
        if (locationSize.width > locationMaxWidth) {
            locationStr = [NSString stringWithFormat:@"%@ %@", source, distance];
            locationSize = [locationStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellInfoLabelFontSize]}];
        }
        if (locationSize.width > locationMaxWidth) {
            locationStr = [NSString stringWithFormat:@"%@", source];
            locationSize = [locationStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellInfoLabelFontSize]}];
        }
    }
    self.adLocationLabelStr = locationStr;
    
    CGFloat adLocationLabelOriginY = ceilf(top + (kCellInfoBarHeight - locationSize.height)/2);
    CGFloat locationFrameWidth = locationSize.width < locationMaxWidth ? locationSize.width:locationMaxWidth;
    //这里加3 是为了兼容string sizeWithAttributes方法计算不正确(在有- / +等字符时)
    self.adLocationLabelFrame = CGRectMake(left, adLocationLabelOriginY, locationFrameWidth + 3, locationSize.height);
}

#pragma mark Height for Abstract Region

- (CGFloat)heightForAbstractRegionWithTop:(CGFloat)top
{
    CGFloat height = 0;
    NSString *abstractStr = [TTLayOutCellDataHelper getAbstractStringWithOrderedData:self.orderedData];
    if ([ExploreCellHelper shouldDisplayAbstract:[self.orderedData article] listType:self.listType]  && ![self.orderedData isVideoPGCCard] && !isEmptyString(abstractStr)) {
        NSAttributedString *abstractAttributedStr = [TTLabelTextHelper attributedStringWithString:abstractStr fontSize:kCellAbstractViewFontSize lineHeight:kCellAbstractViewLineHeight];
        self.abstractAttributedStr = abstractAttributedStr;
        CGFloat abstractHeight = [TTLabelTextHelper heightOfText:abstractStr fontSize:kCellAbstractViewFontSize forWidth:self.containWidth forLineHeight:kCellAbstractViewLineHeight];
        CGRect abstractLabelFrame = CGRectMake(self.originX, top + kCellAbstractVerticalPadding - kCellAbstractViewCorrect, self.containWidth, abstractHeight);
        height = kCellAbstractVerticalPadding - kCellAbstractViewCorrect + abstractLabelFrame.size.height;
        self.abstractLabelNumberOfLines = 0;
        self.abstractLabelTextColorThemeKey = kColorText3;
        self.abstractLabelFrame = abstractLabelFrame;
        self.abstractLabelHidden = NO;
    }
    else{
        self.abstractLabelHidden = YES;
    }
    return height;
}

- (CGFloat)heightForCommentRegionWithTop:(CGFloat)top
{
    CGFloat height = 0;
    NSString *commentStr = [TTLayOutCellDataHelper getCommentStringWithOrderedData:self.orderedData];
    if ([ExploreCellHelper shouldDisplayComment:[self.orderedData article] listType:self.listType] && !isEmptyString(commentStr)) {
        NSAttributedString *commentAttributedStr = [TTLabelTextHelper attributedStringWithString:commentStr fontSize:kCellCommentViewFontSize lineHeight:kCellCommentViewLineHeight lineBreakMode:NSLineBreakByTruncatingTail];

        NSAttributedString *emojiCommentStr = [TTUGCEmojiParser parseInTextKitContext:commentStr fontSize:kCellCommentViewFontSize];
        if (!emojiCommentStr) {
            self.commentLabelHidden = YES;
            return height;
        }

        NSMutableAttributedString *mutableAttributedString = [emojiCommentStr mutableCopy];
        NSDictionary *attributes = [commentAttributedStr attributesAtIndex:0 effectiveRange:NULL];
        if (attributes) {
            [mutableAttributedString addAttributes:attributes range:NSMakeRange(0, emojiCommentStr.length)];
        }

        self.commentAttributedStr = [mutableAttributedString copy];
        CGFloat commentHeight = [TTLabelTextHelper heightOfText:commentStr fontSize:kCellCommentViewFontSize forWidth:self.containWidth forLineHeight:kCellCommentViewLineHeight constraintToMaxNumberOfLines:kCellCommentViewMaxLine];
        CGRect commentFrame = CGRectMake(self.originX, top + kCellCommentTopPadding - cellCommentViewCorrect(), self.containWidth, commentHeight);
        height = kCellCommentTopPadding - cellCommentViewCorrect() + commentFrame.size.height;
        self.commentLabelFrame = commentFrame;
        self.commentLabelHidden = NO;
        self.commentLabelNumberOfLines = kCellCommentViewMaxLine;
        self.commentLabelTextColorThemeKey = kCellCommentViewTextColor;
        self.commentLabelUserInteractionEnabled = YES;
    }
    else{
        self.commentLabelHidden = YES;
    }
    return height;
}

- (CGFloat)heightForEntityWordViewRegionWithTop:(CGFloat)top
{
    CGFloat height = 0;
    if (self.orderedData.article.entityWordInfoDict) {
        top += kCellEntityWordTopPadding;
        CGRect entityWordFrame = CGRectMake(self.originX, top, self.containWidth, kCellEntityWordViewHeight);
        height = kCellEntityWordTopPadding + kCellEntityWordViewHeight;
        self.entityWordViewFrame = entityWordFrame;
        self.entityWordViewHidden = NO;
    }
    else{
        self.entityWordViewHidden = YES;
    }
    return height;
}
@end
