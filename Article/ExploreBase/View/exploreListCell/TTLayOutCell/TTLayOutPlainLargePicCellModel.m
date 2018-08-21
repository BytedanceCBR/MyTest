//
//  TTLayOutPlainLargePicCellModel.m
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutPlainLargePicCellModel.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTAdFeedModel.h"
@implementation TTLayOutPlainLargePicCellModel

- (CGFloat)heightForLargePicRegionWithTop:(CGFloat)top
{
    CGFloat regionHeight = 0;
    top += kCellGroupPicTopPadding;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData adModel:nil picStyle:TTArticlePicViewStyleLarge width:self.cellWidth];
    self.picViewFrame = CGRectMake(0, top, picSize.width, picSize.height);
    self.picViewHidden = NO;
    self.picViewStyle = TTArticlePicViewStyleLarge;
    self.picViewHiddenMessage = NO;
    self.picViewUserInteractionEnabled = YES;
    
    top += picSize.height;
    regionHeight += kCellGroupPicTopPadding + picSize.height;
    if ([[self.orderedData.article hasVideo] boolValue]){
        if ([TTLayOutCellDataHelper shouldShowPlayButtonWithOrderedData:self.orderedData]) {
            self.playButtonFrame = CGRectMake(0, 0, picSize.width, picSize.height);
            self.playButtonHidden = NO;
            self.playButtonImageName = @"feed_play_icon";
            self.playButtonUserInteractionEnable = ![self.orderedData isPlayInDetailView];
        }
        
        if ([self.orderedData isAdButtonUnderPic]) {//视频广告按钮在下的样式
            CGSize ADActionSize = [TTArticleCellHelper getADActionSize:self.containWidth];
            self.adBackgroundViewFrame = CGRectMake(self.originX, top, ADActionSize.width, ADActionSize.height);
            self.adBackgroundViewHidden = NO;
            
            NSString *adSubtitleStr = [TTLayOutCellDataHelper getSubtitleStringWithOrderedData:self.orderedData];
            CGSize adSubtitleSize = [adSubtitleStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:14]}];
            adSubtitleSize = CGSizeMake(ceilf(adSubtitleSize.width), ceilf(adSubtitleSize.height));
            CGRect adSourceFrame = CGRectMake(self.originX + 9, top + floor((ADActionSize.height - adSubtitleSize.height) / 2), ADActionSize.width - 115, adSubtitleSize.height);

            self.adSubtitleLabelFrame = adSourceFrame;
            self.adSubtitleLabelHidden = NO;
            self.adSubtitleLabelFontSize = [TTDeviceUIUtils tt_newFontSize:15.f];
            self.adSubtitleLabelTextColorHex = @"999999";
            self.adSubtitleLabelStr = adSubtitleStr;
            self.adSubtitleLabelUserInteractionEnabled = [TTLayOutCellDataHelper isADSubtitleUserInteractive:self.orderedData];
            
            self.separatorViewHidden = YES;
            
            self.actionButtonFrame = CGRectMake(self.originX + ADActionSize.width - 72 - 8, top + floor((ADActionSize.height - 28) / 2), 72, 28);
            self.actionButtonHidden = NO;
            self.actionButtonFontSize = 14;
            self.actionButtonBorderWidth = 1.f;
            
            
            top += ADActionSize.height;
            regionHeight += ADActionSize.height;
        }
    }
    
    return regionHeight;
}

@end

@implementation TTLayOutPlainLargePicCellModelS0

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
    height += [self heightForInfoBarTopPadding];
    self.infoBarOriginY = height;
    self.infoBarContainWidth = self.containWidth;
    height += [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    height += [self heightForAbstractRegionWithTop:height];
    height += [self heightForCommentRegionWithTop:height];
    height += [self heightForEntityWordViewRegionWithTop:height];
    height += [self heightForCellBottomPadding];
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

@end

@implementation TTLayOutPlainLargePicCellModelS0AD

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
    height += [self heightForInfoBarTopPadding];
    self.infoBarOriginY = height;
    self.infoBarContainWidth = self.containWidth;
    height += [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    height += [self heightForAbstractRegionWithTop:height];
    height += [self heightForCommentRegionWithTop:height];
    height += [self heightForEntityWordViewRegionWithTop:height];
    height += [self heightForCellBottomPadding];
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

- (CGFloat)heightForArticleInfoRegionWithTop:(CGFloat)top containWidth:(CGFloat)containWidth
{
    TTAdFeedModel* rawAdModel = self.orderedData.raw_ad;
    CGFloat left = self.originX;
    CGFloat labelY = top + floor((kCellInfoBarHeight - kCellTypeLabelHeight) / 2);;
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
    if ([rawAdModel hasLocationInfo] && rawAdModel.adType == ExploreActionTypeWeb) {
        [self layoutLocationArticleInfoRegionWidth:sourceMaxWidth left:left top:top margin:margin];
    }
    else{
        [self layoutNormalArticleInfoRegionWidth:sourceMaxWidth left:left top:top labelY:labelY containWidth:containWidth];
    }
    
    self.unInterestedButtonHidden = YES;
    return kCellInfoBarHeight;
}

- (void)layoutLocationArticleInfoRegionWidth:(CGFloat)sourceMaxWidth left:(CGFloat)left top:(CGFloat)top margin:(CGFloat)margin
{
    self.sourceLabelHidden = NO;
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


- (void)layoutNormalArticleInfoRegionWidth:(CGFloat)sourceMaxWidth left:(CGFloat)left top:(CGFloat)top labelY:(CGFloat)labelY containWidth:(CGFloat)containWidth
{
    CGFloat infoMaxWidth = sourceMaxWidth;
    BOOL hideSource = [self.orderedData isAdButtonUnderPic] && ![TTLayOutCellDataHelper isAdShowSourece:self.orderedData];
    if (sourceMaxWidth > 0 && !isEmptyString(self.orderedData.article.source) && [self.orderedData isShowSourceLabel] && !hideSource) {
        NSString *sourceString = self.orderedData.article.source;
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
        self.sourceLabelTextColorThemeKey = kCellInfoLabelTextColor;
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
    self.infoLabelTextColorThemeKey = kCellInfoLabelTextColor;
    self.infoLabelFrame = infoLabelFrame;
    self.infoLabelHidden = NO;
    
}


@end

@implementation TTLayOutPlainLargePicCellModelS1

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionWithTop:height];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
    height += [self heightForInfoBarTopPadding];
    self.infoBarOriginY = height;
    self.infoBarContainWidth = self.containWidth;
    height += [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    height += [self heightForAbstractRegionWithTop:height];
    height += [self heightForCommentRegionWithTop:height];
    height += [self heightForEntityWordViewRegionWithTop:height];
    height += [self heightForCellBottomPadding];
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

@end

@implementation TTLayOutPlainLargePicCellModelS2

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForHeaderInfoRegionInTwoLinesWithTop:height needLayoutDislike:NO];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
    height += [self heightForInfoBarTopPadding];
    self.infoBarOriginY = height;
    self.infoBarContainWidth = self.containWidth;
    height += [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    height += [self heightForAbstractRegionWithTop:height];
    height += [self heightForCommentRegionWithTop:height];
    height += [self heightForEntityWordViewRegionWithTop:height];
    height += [self heightForCellBottomPadding];
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

- (void)calculateNeedUpdateFrame
{
    if (self.infoBarOriginY > 0 && self.infoBarContainWidth > 0) {
        [self calculateBottomLineFrame];
        [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
        [self heightForHeaderInfoRegionInTwoLinesWithTop:self.sourceImageViewFrame.origin.y needLayoutDislike:NO];
    }
}

@end

@implementation TTLayOutPlainPanoramaCellModel

- (void)calculateAllFrame
{
    self.originX = kCellLeftPadding;
    self.containWidth = self.cellWidth - kCellLeftPadding - kCellRightPadding;
    self.hideTimeForRightPic = NO;
    
    CGFloat height = 0;
    
    height += [self heightForCellTopPadding];
    height += [self heightForTitleRegionForPlainCellWithTop:height];
    height += [self heightForLargePicRegionWithTop:height];
    height += [self heightForInfoBarTopPadding];
    self.infoBarOriginY = height;
    self.infoBarContainWidth = self.containWidth;
    height += [self heightForArticleInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    height += [self heightForAbstractRegionWithTop:height];
    height += [self heightForCommentRegionWithTop:height];
    height += [self heightForEntityWordViewRegionWithTop:height];
    height += [self heightForCellBottomPadding];
    
    self.cellCacheHeight = ceilf(height);
    
    [self calculateBottomLineFrame];
}

- (CGFloat)heightForLargePicRegionWithTop:(CGFloat)top
{
    CGFloat height = [super heightForLargePicRegionWithTop:top];
    
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData adModel:nil picStyle:TTArticlePicViewStyleLarge width:self.containWidth];
    // 全景广告
    top += kCellGroupPicTopPadding;
    self.motionViewFrame = CGRectMake(self.originX, top, picSize.width, picSize.height);
    self.motionViewHidden = NO;
    self.picViewHidden = YES;

    return height;
}

@end

