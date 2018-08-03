//
//  WDMoreListCellLayoutModel.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/22.
//
//

#import "WDMoreListCellLayoutModel.h"
#import "WDAnswerEntity.h"
#import "WDSettingHelper.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import "TTTAttributedLabel.h"
#import "WDDefines.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "WDMoreListCellViewModel.h"
#import "WDListCellDataModel.h"
#import "WDWendaListCellUserHeaderView.h"
#import "WDWendaListCellActionFooterView.h"

@interface WDMoreListCellLayoutModel ()

@property (nonatomic, strong) WDMoreListCellViewModel *viewModel;

@property (nonatomic, assign) CGFloat contentLabelHeight;  // 上次计算所得到的文字内容高度

@property (nonatomic, assign) CGFloat bottomLabelTopPadding;

@property (nonatomic, assign) CGFloat bottomLabelBottomPadding;

@property (nonatomic, assign) CGFloat cellWidth; // 上次计算缓存高度时所用的宽度

@property (nonatomic, assign) NSInteger answerLinesCount;

@property (nonatomic, assign) BOOL needCalculateLayout; // 是否需要计算：首次／iPad旋转屏幕／用户调整字体／日夜间模式切换

@end

@implementation WDMoreListCellLayoutModel

- (instancetype)initWithDataModel:(WDListCellDataModel *)dataModel {
    if (self = [super init]) {
        self.viewModel = [[WDMoreListCellViewModel alloc] initWithDataModel:dataModel];
    }
    return self;
}

- (void)calculateLayoutIfNeedWithCellWidth:(CGFloat)cellWidth {
    if (self.cellWidth != cellWidth) {
        self.cellWidth = cellWidth;
        self.needCalculateLayout = YES;
    }
    if (self.needCalculateLayout) {
        if (self.viewModel.isInvalidData) {
            self.cellCacheHeight = 0;
            self.needCalculateLayout = NO;
            return;
        }
        
        if (self.dataModel.layoutType == WDWendaListLayoutTypeLIGHT_ANSWER) {
            self.bottomLabelTopPadding = 6;
            self.bottomLabelBottomPadding = 7;
            if (![TTDeviceHelper isScreenWidthLarge320]) {
                self.bottomLabelTopPadding = 5;
                self.bottomLabelBottomPadding = 6;
            }
            self.cellCacheHeight = [self calculateLayoutTypeLightAnswerWithCellWidth:cellWidth];
        } else {
            self.bottomLabelTopPadding = 8;
            self.bottomLabelBottomPadding = 12;
            if (![TTDeviceHelper isScreenWidthLarge320]) {
                self.bottomLabelTopPadding = 7;
                self.bottomLabelBottomPadding = 11;
            }
            self.cellCacheHeight = [self calculateLayoutNormalAnswerWithCellWidth:cellWidth];
        }
//        self.cellCacheHeight += [WDMoreListCellLayoutModel heightForFooterView];
        self.needCalculateLayout = NO;
    }
}

- (void)setNeedReCalculateLayout {
    self.needCalculateLayout = YES;
}

- (CGFloat)calculateLayoutNormalAnswerWithCellWidth:(CGFloat)cellWidth {
    CGFloat totalHeight = [WDWendaListCellUserHeaderView userHeaderHeight];
    
    totalHeight += [self heightForNormalAnswerLabelWithCellWidth:cellWidth];
    
    totalHeight += self.bottomLabelTopPadding + [self heightForBottomLabel] + self.bottomLabelBottomPadding;
    
    return totalHeight;
}

- (CGFloat)calculateLayoutTypeLightAnswerWithCellWidth:(CGFloat)cellWidth {
    CGFloat totalHeight = [WDWendaListCellUserHeaderView userHeaderHeight];
    
    totalHeight += [self heightForTypeLightAnswerLabelWithCellWidth:cellWidth];
    
    totalHeight += self.bottomLabelTopPadding + [self heightForBottomLabel] + self.bottomLabelBottomPadding;
    
//    totalHeight += [WDWendaListCellActionFooterView actionFooterHeight];
    
    return totalHeight;
}

- (WDListCellDataModel *)dataModel {
    return self.viewModel.dataModel;
}

#pragma mark - Calculate

#pragma mark - Normal Answer

- (CGFloat)heightForNormalAnswerLabelWithCellWidth:(CGFloat)cellWidth {
    if (isEmptyString(self.viewModel.answerContentAbstract)) {
        return 0;
    }
    NSInteger numberLines = [self answerAbstractMaxNumber];
    CGFloat fontSize = [WDMoreListCellLayoutModel answerAbstractContentFontSize];
    CGFloat lineHeight = [WDMoreListCellLayoutModel answerAbstractContentLineHeight];
    NSDictionary *attribute = [WDLayoutHelper
                               attributesWithFontSize:fontSize
                               isBoldFont:NO
                               lineHeight:lineHeight];
    
    NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:self.viewModel.answerContentAbstract attributes:attribute];
    CGFloat height = [TTTAttributedLabel sizeThatFitsAttributedString:attributedStr
                                                      withConstraints:CGSizeMake(cellWidth - kWDCellLeftPadding - kWDCellRightPadding, 0.0f)
                                               limitedToNumberOfLines:numberLines].height;
    self.contentLabelHeight = ceilf(height);
    return self.contentLabelHeight;
}

- (NSInteger)answerAbstractMaxNumber {
    return [[WDSettingHelper sharedInstance_tt] moreListAnswerTextMaxCount];
}

#pragma mark - Light Answer

- (CGFloat)heightForTypeLightAnswerLabelWithCellWidth:(CGFloat)cellWidth {
    if (isEmptyString(self.viewModel.answerContentAbstract)) {
        return 0;
    }
    CGFloat contentWidth = cellWidth - kWDCellLeftPadding - kWDCellRightPadding + 2;
    CGFloat fontSize = [WDMoreListCellLayoutModel lightAnswerAbstractContentFontSize];
    CGFloat lineHeight = [WDMoreListCellLayoutModel lightAnswerAbstractContentLineHeight];
    CGFloat paraSpace = [WDMoreListCellLayoutModel lightAnswerAbstractContentParaSpace];
    NSDictionary *attribute = [WDLayoutHelper
                               attributesWithFontSize:fontSize
                               isBoldFont:NO
                               lineHeight:lineHeight
                               paragraphSpace:paraSpace];
    
    NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:self.viewModel.answerContentAbstract attributes:attribute];
    CGFloat height = [TTTAttributedLabel sizeThatFitsAttributedString:attributedStr
                                                      withConstraints:CGSizeMake(contentWidth, 0.0f)
                                               limitedToNumberOfLines:0].height;
    NSInteger lineCount = (ceilf(height) / lineHeight);
    if (lineCount < self.dataModel.maxLines) {
        self.answerLinesCount = 0;
    } else {
        self.answerLinesCount = self.dataModel.showLines;
        height = [TTTAttributedLabel sizeThatFitsAttributedString:attributedStr
                                                  withConstraints:CGSizeMake(contentWidth, 0.0f)
                                           limitedToNumberOfLines:self.answerLinesCount].height;
    }
    self.contentLabelHeight = ceilf(height) + 1;
    return self.contentLabelHeight;
}

#pragma mark - Both

- (CGFloat)heightForBottomLabel {
    return [WDMoreListCellLayoutModel answerReadCountsLineHeight];
}

#pragma mark - Layout

+ (CGFloat)lightAnswerAbstractContentFontSize {
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 17.f : 15.f;
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize];
}

+ (CGFloat)lightAnswerAbstractContentLineHeight {
    CGFloat lineHeight = [TTDeviceHelper isScreenWidthLarge320] ? 24.f : 21.f;
    return [WDUIHelper wdUserSettingTransferWithLineHeight:lineHeight];
}

+ (CGFloat)lightAnswerAbstractContentParaSpace {
    return [TTDeviceHelper isScreenWidthLarge320] ? 10 : 9;
}

+ (CGFloat)answerAbstractContentFontSize {
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 17.f : 15.f;
    return [WDUIHelper wdUserSettingFontSizeWithFontSize:fontSize];
}

+ (CGFloat)answerAbstractContentLineHeight {
    return ceilf([WDMoreListCellLayoutModel answerAbstractContentFontSize] * 1.4);
}

+ (CGFloat)answerReadCountsFontSize {
    return WDConstraintFontSize(12.0);
}

+ (CGFloat)answerReadCountsLineHeight {
    return WDConstraintPadding(16.0);
}

+ (CGFloat)heightForFooterView {
    if ([TTDeviceHelper isPadDevice]) {
        return [TTDeviceHelper ssOnePixel];
    }
    CGFloat footerPadding = [TTDeviceHelper isScreenWidthLarge320] ? 6 : 5;
    return [TTDeviceUIUtils tt_padding:footerPadding];
}

@end
