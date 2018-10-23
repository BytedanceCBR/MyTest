//
//  TTLayOutUnifyADCellBaseModel.m
//  Article
//
//  Created by 王双华 on 16/10/24.
//
//

#import "TTLayOutUnifyADCellBaseModel.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTLayOutUnifyADCellBaseModel

- (void)calculateNeedUpdateFrame
{
    if (self.infoBarOriginY > 0 && self.infoBarContainWidth > 0) {
        [self calculateBottomLineFrame];
        [self heightForInfoRegionWithTop:self.infoBarOriginY containWidth:self.infoBarContainWidth];
    }
}

- (void)calculateBottomLineFrame
{
    if (![self.orderedData nextCellHasTopPadding]) {
        self.bottomLineViewFrame = CGRectMake(kPaddingLeft(), self.cellCacheHeight - [TTDeviceHelper ssOnePixel], self.containWidth, [TTDeviceHelper ssOnePixel]);
        self.bottomLineViewHidden = NO;
    }
}

- (CGFloat)heightForTitleRegionWithTop:(CGFloat)top
{
    CGFloat x = self.originX;
    CGFloat height = 0;
    
    CGSize titleSize = CGSizeMake(self.containWidth, 0);
    NSString *titleStr = [TTLayOutCellDataHelper getTitleStringWithOrderedData:self.orderedData];
    NSAttributedString *titleAttributedStr = [TTLabelTextHelper attributedStringWithString:titleStr fontSize:kTitleViewFontSize() lineHeight:kTitleViewLineHeight() lineBreakMode:NSLineBreakByTruncatingTail];
    self.titleAttributedStr = titleAttributedStr;
    titleSize.height = [TTLabelTextHelper heightOfText:titleStr fontSize:kTitleViewFontSize() forWidth:self.containWidth forLineHeight:kTitleViewLineHeight() constraintToMaxNumberOfLines:kTitleViewLineNumber()];
    CGFloat titlePadding = kTitleViewLineHeight() - kTitleViewFontSize();
    CGFloat titleY = top - titlePadding / 2;
    if (titleSize.height - titlePadding > 0) {
        height = titleSize.height - titlePadding;
    }
    CGRect titleFrame = CGRectMake(x, titleY, titleSize.width, titleSize.height);
    self.titleLabelFrame = titleFrame;
    self.titleLabelHidden = NO;
    self.titleLabelNumberOfLines = kTitleViewLineNumber();
    
    return height;
}

- (CGFloat)heightForInfoRegionWithTop:(CGFloat)top containWidth:(CGFloat)containWidth
{
    CGFloat regionHeight = kInfoViewHeight();
    CGFloat left = 0.f;
    CGFloat right = 0.f;
    CGFloat margin = 6;
    CGFloat locationMargin = 4.f;
    const CGFloat space = [TTDeviceHelper isPadDevice] ? 14.f : 8.f;
    
    NSString *typeString = [TTLayOutCellDataHelper getTypeStringWithOrderedData:self.orderedData];
    if (!isEmptyString(typeString)) {
        CGSize typeSize = [typeString sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kTagViewFontSize()]}];
        typeSize = CGSizeMake(ceilf(typeSize.width), ceilf(typeSize.height));
        typeSize.width = ceilf(typeSize.width + kTagViewPaddingHorizontal() * 2);
        typeSize.height = kTagViewHeight();
        CGFloat typeLabelOriginY = ceilf(top + (regionHeight - typeSize.height) / 2);
        CGRect typeLabelFrame = CGRectMake(self.originX + left, typeLabelOriginY, typeSize.width, typeSize.height);
        self.typeLabelFrame = typeLabelFrame;
        self.typeLabelHidden = NO;
        left += typeSize.width + margin;
    }
    else{
        self.typeLabelHidden = YES;
    }
    
    CGFloat unInterestedBtnX = 0, unInterestedBtnY = 0;
    CGFloat unInterestedBtnWidth = 30;
    CGFloat unInterestedBtnHeight = 25;
    
    if ([self.orderedData isInCard] ||
        self.listType == ExploreOrderedDataListTypeFavorite ||
        self.listType == ExploreOrderedDataListTypeReadHistory ||
        (self.orderedData.showDislike && ![self.orderedData.showDislike boolValue])){
    } else {
        unInterestedBtnX = ceil(self.originX + containWidth - kCellUninterestedButtonWidth / 2 - unInterestedBtnWidth / 2);
        unInterestedBtnY = ceil(top + regionHeight / 2 - unInterestedBtnHeight / 2);
        CGRect unInterestedBtnFrame = CGRectMake(unInterestedBtnX, unInterestedBtnY, unInterestedBtnWidth, unInterestedBtnHeight);
        self.unInterestedButtonFrame = unInterestedBtnFrame;
        right += unInterestedBtnWidth;
        right += margin;
        self.unInterestedButtonHidden = NO;
    }
    
    self.adLocationIconHidden = YES;
    self.adLocationLabelHidden = YES;
    
    
    BOOL isShowLocationStr = [TTLayOutCellDataHelper isAdShowLocation:self.orderedData];
    if (isShowLocationStr) {
        
        CGFloat adLocationIconMaxWidth = containWidth - left - right;
        
        if (adLocationIconMaxWidth > KCellADLocationIconWidth) {
            
            CGFloat adLocationIconOriginY = ceilf(top + (regionHeight - KCellADLocationIconHeight) / 2);
            self.adLocationIconFrame = CGRectMake(self.originX + left, adLocationIconOriginY, KCellADLocationIconWidth, KCellADLocationIconHeight);
            
            left += KCellADLocationIconWidth;
            left += locationMargin;
        }
        
        self.adLocationLabelFontSize = kCellInfoLabelFontSize;
        self.adLocationLabelTextColorThemeKey = kCellInfoLabelTextColor;
        
        for (NSInteger index = 0; index <= 2; index++) {
            
            NSString *adLocationStr = [TTLayOutCellDataHelper getAdLocationStringForUnifyADCellWithOrderData:self.orderedData WithIndex:index];
            
            if (!isEmptyString(adLocationStr)) {
                CGFloat adLocationLabelMaxWidth = containWidth - left - right;
                
                NSString *fixAdLocationStr =  [adLocationStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if (adLocationLabelMaxWidth > 0 && !isEmptyString(fixAdLocationStr)) {
                    
                    CGSize adLocationLabelSize =  [fixAdLocationStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kCellInfoLabelFontSize]}];
                    
                    if (adLocationLabelMaxWidth >= adLocationLabelSize.width || index == 2) {
                        
                        CGFloat adLocationLabelOriginY = ceilf(top + (regionHeight - adLocationLabelSize.height) / 2);
                        adLocationLabelSize = CGSizeMake(MIN(adLocationLabelMaxWidth, ceilf(adLocationLabelSize.width)), ceilf(adLocationLabelSize.height));
                        
                        self.adLocationLabelFrame = CGRectMake(self.originX +left, adLocationLabelOriginY, adLocationLabelSize.width, adLocationLabelSize.height);
                        self.adLocationLabelStr = fixAdLocationStr;
                        
                        self.adLocationLabelHidden = NO;
                        self.adLocationIconHidden = NO;
                        
                        left += adLocationLabelSize.width;
                        left += locationMargin;
                        
                        break;
                    }
                }
            }
        }
    }
    
    else {
        
        NSString *sourceStr = [TTLayOutCellDataHelper getADSourceStringWithOrderedDada:self.orderedData];
        if (isEmptyString(sourceStr) || ![TTLayOutCellDataHelper isAdShowSourece:self.orderedData]) {
            self.sourceLabelStr = @"";
            self.sourceLabelHidden = YES;
        } else {
            CGFloat sourceMaxWidth = containWidth - left - right;
            NSString *fixedSourceString = [sourceStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            CGSize sourceSize = [fixedSourceString sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kCellInfoLabelFontSize]}];
            sourceSize = CGSizeMake(MIN(sourceMaxWidth, ceilf(sourceSize.width)), ceilf(sourceSize.height));
            CGFloat sourceLabelOriginY = ceilf(top + (regionHeight - sourceSize.height) / 2);
            self.sourceLabelFrame = CGRectMake(self.originX +left, sourceLabelOriginY, sourceSize.width, sourceSize.height);
            self.sourceLabelFontSize = kCellInfoLabelFontSize;
            self.sourceLabelTextColorThemeKey = kCellInfoLabelTextColor;
            self.sourceLabelStr = fixedSourceString;
            self.sourceLabelHidden = NO;
            left += sourceSize.width;
            left += space;
        }
        
        while (YES) {
            NSString *infoStr = [TTLayOutCellDataHelper getInfoStringForUnifyADCellWithOrderedData:self.orderedData];
            if (isEmptyString(infoStr)) {
                break;
            }
            CGFloat infoLabeMaxWidth = containWidth - left - right;
            CGSize infoLabelSize = [infoStr sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:kCellInfoLabelFontSize]}];
            infoLabelSize.width = ceilf(infoLabelSize.width);
            if (infoLabeMaxWidth < infoLabelSize.width) {
                infoStr = [TTLayOutCellDataHelper getCommentStringForUnifyADCellWithOrderedData:self.orderedData];
                if (isEmptyString(infoStr)) {
                    break;
                }
                infoLabelSize = [infoStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kCellInfoLabelFontSize]}];
                infoLabelSize.width = ceilf(infoLabelSize.width);
                if (infoLabeMaxWidth < infoLabelSize.width) {
                    break;
                }
            }
            infoLabelSize = CGSizeMake(MIN(infoLabeMaxWidth, infoLabelSize.width), ceilf(infoLabelSize.height));
            CGFloat infolLabelOriginY = ceilf(top + (regionHeight - infoLabelSize.height) / 2);
            CGRect infoLabelFrame = CGRectMake(self.originX + left, infolLabelOriginY, infoLabelSize.width, infoLabelSize.height);
            self.infoLabelFrame = infoLabelFrame;
            self.infoLabelFontSize = kCellInfoLabelFontSize;
            self.infoLabelTextColorThemeKey = kCellInfoLabelTextColor;
            self.infoLabelStr = infoStr;
            self.infoLabelHidden = NO;
            left += infoLabelSize.width + margin;
            break;
        }
    }
    
    return regionHeight;
}

- (CGFloat)heightForADActionRegionWithTop:(CGFloat)top
{
    CGSize ADActionSize = [TTArticleCellHelper getADActionSize:self.containWidth];
    self.adBackgroundViewFrame = CGRectMake(self.originX, top, ADActionSize.width, ADActionSize.height);
    self.adBackgroundViewHidden = NO;
    
    CGFloat actionButtonWidth = 90;
    if (self.orderedData) {
        id<TTAdFeedModel> adModel = self.orderedData.adModel;
        if ([adModel showActionButtonIcon]) {
            actionButtonWidth = 108.f;
        }
    }
    
    NSString *adSubtitleStr = [TTLayOutCellDataHelper getSubtitleStringWithOrderedData:self.orderedData];
    CGSize adSubtitleSize = [adSubtitleStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:15]}];
    adSubtitleSize = CGSizeMake(ceilf(adSubtitleSize.width), ceilf(adSubtitleSize.height));
    CGRect adSubtitleFrame = CGRectMake(self.originX + 8, top + floor((ADActionSize.height - adSubtitleSize.height) / 2), ADActionSize.width - 8 - 20 - 1 - actionButtonWidth , adSubtitleSize.height);
    self.adSubtitleLabelFrame = adSubtitleFrame;
    self.adSubtitleLabelHidden = NO;
    self.adSubtitleLabelFontSize = 15;
    self.adSubtitleLabelTextColorThemeKey = kColorText3;
    self.adSubtitleLabelStr = adSubtitleStr;
    self.adSubtitleLabelUserInteractionEnabled = [TTLayOutCellDataHelper isADSubtitleUserInteractive:self.orderedData];
    
    self.separatorViewFrame = CGRectMake(self.originX + ADActionSize.width - actionButtonWidth - 1, top + floor((ADActionSize.height - 16) / 2), 1, 16);
    self.separatorViewBackgroundColorThemeKey = kColorLine1;
    self.separatorViewHidden = NO;
    
    self.actionButtonFrame = CGRectMake(self.originX + ADActionSize.width - actionButtonWidth, top, actionButtonWidth, ADActionSize.height);
    self.actionButtonHidden = NO;
    self.actionButtonFontSize = 15;
    self.actionButtonBorderWidth = 0.f;
    
    return ADActionSize.height;
}

@end
