//
//  WDListCellLayoutModel.m
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/16.
//
//

#import "WDListCellLayoutModel.h"
#import "WDAnswerEntity.h"
#import "WDSettingHelper.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import "TTTAttributedLabel.h"
#import "WDImageBoxView.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "WDListCellViewModel.h"
#import "WDListCellDataModel.h"
#import "WDWendaListCellUserHeaderView.h"
#import "WDWendaListCellActionFooterView.h"
#import <TTImage/TTImageInfosModel.h>

@interface WDListCellLayoutModel ()

@property (nonatomic, strong) WDListCellViewModel *viewModel;

@property (nonatomic, assign) CGFloat contentLabelHeight;  // 上次计算所得到的文字内容高度
@property (nonatomic, assign) CGFloat mediaViewHeight;  // 上次计算所得到的图片内容高度
@property (nonatomic, assign) CGFloat imageViewTopPadding;
@property (nonatomic, assign) CGFloat videoCoverTopPadding;
@property (nonatomic, assign) CGFloat bottomLabelTopPadding;
@property (nonatomic, assign) CGFloat bottomLabelBottomPadding;

@property (nonatomic, assign) BOOL isVideoMedia;  // 回答中是否包含视频
@property (nonatomic, assign) BOOL isImageMedia;  // 回答中是否包含图片

@property (nonatomic, assign) BOOL isSingleImage;  // 是否是单图

@property (nonatomic, assign) BOOL isShowAllAnswerText;
@property (nonatomic, assign) NSInteger answerLinesCount;

@property (nonatomic, assign) CGRect singleImageFrame;
@property (nonatomic, assign) CGFloat imagesBgViewHeight;
@property (nonatomic, strong) NSArray<NSValue *> *imageViewRects;
@property (nonatomic, assign) CGRect largeVideoFrame;

@property (nonatomic, assign) CGFloat cellWidth; // 上次计算缓存高度时所用的宽度

@property (nonatomic, assign) BOOL needCalculateLayout; // 是否需要计算：首次／iPad旋转屏幕／用户调整字体／日夜间模式切换

@end

@implementation WDListCellLayoutModel

- (instancetype)initWithDataModel:(WDListCellDataModel *)dataModel {
    if (self = [super init]) {
        self.viewModel = [[WDListCellViewModel alloc] initWithDataModel:dataModel];
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
            self.cellCacheHeight = [self calculateLayoutLightAnswerWithCellWidth:cellWidth];
        } else {
            self.bottomLabelTopPadding = 8;
            self.bottomLabelBottomPadding = 12;
            if (![TTDeviceHelper isScreenWidthLarge320]) {
                self.bottomLabelTopPadding = 7;
                self.bottomLabelBottomPadding = 11;
            }
            self.cellCacheHeight = [self calculateLayoutNormalAnswerWithCellWidth:cellWidth];
        }
        self.cellCacheHeight += [WDListCellLayoutModel heightForFooterView];
        self.needCalculateLayout = NO;
    }
}

- (void)setNeedReCalculateLayout {
    self.needCalculateLayout = YES;
}

- (CGFloat)calculateLayoutNormalAnswerWithCellWidth:(CGFloat)cellWidth {
    CGFloat totalHeight = [WDWendaListCellUserHeaderView userHeaderHeight];
    
    CGFloat textHeight = [self heightForNormalAnswerLabelWithCellWidth:cellWidth];
    totalHeight += textHeight;
    
    CGFloat mediaBoxHeight = [self heightForMediaBoxWithCellWidth:cellWidth];
    if (mediaBoxHeight > 0) {
        totalHeight += 10 + mediaBoxHeight;
    }
    
    totalHeight += self.bottomLabelTopPadding + [self heightForBottomLabel] + self.bottomLabelBottomPadding;
    
    return totalHeight;
}

- (CGFloat)calculateLayoutLightAnswerWithCellWidth:(CGFloat)cellWidth {
    CGFloat totalHeight = [WDWendaListCellUserHeaderView userHeaderHeight];
    
    [self judgeMediaInfoInModel:self.viewModel.ansEntity];
    
    CGFloat textHeight = [self heightForLightAnswerLabelWithCellWidth:cellWidth];
    totalHeight += textHeight;
    
    if (self.isVideoMedia) {
        CGFloat mediaBoxHeight = [self heightForMediaBoxWithCellWidth:cellWidth];
        self.videoCoverTopPadding = ((textHeight == 0) ? 4 : 5);
        totalHeight += self.videoCoverTopPadding;
        self.largeVideoFrame = CGRectMake(kWDCellLeftPadding, totalHeight, cellWidth - kWDCellLeftPadding - kWDCellRightPadding, mediaBoxHeight);
        totalHeight += mediaBoxHeight;
        self.bottomLabelTopPadding = 7;
        self.bottomLabelBottomPadding = 7;
        if (![TTDeviceHelper isScreenWidthLarge320]) {
            self.bottomLabelTopPadding = 6;
            self.bottomLabelBottomPadding = 6;
        }
    } else if (self.isImageMedia) {
        CGFloat mediaBoxHeight = 0;
        self.imageViewTopPadding = 5;
        // 这里是用问答规则显示
        if (self.isSingleImage) {
            mediaBoxHeight = [self heightForMediaBoxWithCellWidth:cellWidth];
            CGRect newFrame = self.singleImageFrame;
            newFrame.origin.x = kWDCellLeftPadding;
            newFrame.origin.y = totalHeight + self.imageViewTopPadding;
            self.singleImageFrame = newFrame;
        } else {
            mediaBoxHeight = [self heightForLightAnswerImageViewsWithCellWidth:cellWidth top:totalHeight + self.imageViewTopPadding];
        }
        totalHeight += self.imageViewTopPadding + mediaBoxHeight;
        self.bottomLabelTopPadding = 7;
        self.bottomLabelBottomPadding = 7;
        if (![TTDeviceHelper isScreenWidthLarge320]) {
            self.bottomLabelTopPadding = 6;
            self.bottomLabelBottomPadding = 6;
        }
    } else {
        self.bottomLabelTopPadding = 6;
        self.bottomLabelBottomPadding = 7;
        if (![TTDeviceHelper isScreenWidthLarge320]) {
            self.bottomLabelTopPadding = 5;
            self.bottomLabelBottomPadding = 6;
        }
    }
    
    totalHeight += self.bottomLabelTopPadding + [self heightForBottomLabel] + self.bottomLabelBottomPadding;
    
//    totalHeight += [WDWendaListCellActionFooterView actionFooterHeight];
    
    return totalHeight;
}

- (void)judgeMediaInfoInModel:(WDAnswerEntity *)entity {
    WDVideoInfoStructModel *videoModel;
    NSUInteger fullCount = [entity.contentAbstract.thumb_image_list count];
    if (entity.contentAbstract.video_list.count > 0) {
        videoModel = entity.contentAbstract.video_list.firstObject;
    }
    // 有视频 则忽略图片
    if (videoModel && !isEmptyString(videoModel.video_id)) {
        self.isVideoMedia = YES;
    } else if (fullCount > 0) {
        if (fullCount == 1) {
            self.isSingleImage = YES;
        }
        self.isImageMedia = YES;
    }
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
    CGFloat fontSize = [WDListCellLayoutModel answerAbstractContentFontSize];
    CGFloat lineHeight = [WDListCellLayoutModel answerAbstractContentLineHeight];
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
    NSInteger numbers = 0;
    if (self.viewModel.ansEntity && [self.viewModel.ansEntity.contentAbstract.thumb_image_list count] > 0) {
        numbers = [[WDSettingHelper sharedInstance_tt] listAnswerHasImgTextMaxCount];
    } else {
        numbers = [[WDSettingHelper sharedInstance_tt] listCellContentMaxLine];
    }
    self.answerLinesCount = numbers;
    return numbers;
}

#pragma mark - Light Answer

- (CGFloat)heightForLightAnswerLabelWithCellWidth:(CGFloat)cellWidth {
    if (isEmptyString(self.viewModel.answerContentAbstract)) {
        return 0;
    }
    CGFloat contentWidth = cellWidth - kWDCellLeftPadding - kWDCellRightPadding + 2;
    CGFloat fontSize = [WDListCellLayoutModel lightAnswerAbstractContentFontSize];
    CGFloat lineHeight = [WDListCellLayoutModel lightAnswerAbstractContentLineHeight];
    CGFloat paraSpace = [WDListCellLayoutModel lightAnswerAbstractContentParaSpace];
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
        self.answerLinesCount = lineCount;
        self.isShowAllAnswerText = YES;
    } else {
        self.answerLinesCount = self.dataModel.showLines;
        height = [TTTAttributedLabel sizeThatFitsAttributedString:attributedStr
                                                  withConstraints:CGSizeMake(contentWidth, 0.0f)
                                           limitedToNumberOfLines:self.answerLinesCount].height;
    }
    self.contentLabelHeight = ceilf(height) + 1;
    return self.contentLabelHeight;
}

- (CGFloat)heightForLightAnswerImageViewsWithCellWidth:(CGFloat)cellWidth top:(CGFloat)top {
    NSUInteger fullCount = [self.viewModel.ansEntity.contentAbstract.thumb_image_list count];
    if (fullCount == 1) { // 单图 暂时没用上
        WDImageUrlStructModel *largeImageModel = self.viewModel.ansEntity.contentAbstract.large_image_list.firstObject;
        CGSize imageSize;
        CGFloat largeImageWidth = MAX(largeImageModel.width.floatValue, 1.f);
        CGFloat largeImageHeight = MAX(largeImageModel.height.floatValue, 1.f);
        double ratio = (double) largeImageModel.height.doubleValue / (double) largeImageModel.width.doubleValue;
        if (ratio < 125.f / 375.f) { // 通栏显示125:375图, 超出的部分裁掉（裁右侧部分）, 且右下角显示横图标志
            imageSize = CGSizeMake(cellWidth, largeImageModel.height.floatValue);
        } else if (ratio >= 125.f / 375.f && ratio <= 400.f / 375.f) { // 按原图比例通栏显示
            imageSize = CGSizeMake(cellWidth, (cellWidth * largeImageHeight / largeImageWidth));
        } else if (ratio > 400.f / 375.f && ratio <= 750.f / 375.f) { // 通栏显示400:375图, 超出的部分裁掉（智能裁图／裁上下，留中间）
            imageSize = CGSizeMake(cellWidth, (cellWidth * 400.f / 375.f));
        } else { // 通栏显示400：375图, 超出的部分裁掉（裁下方部分）, 且右上角显示长图标志
            imageSize = CGSizeMake(cellWidth, (cellWidth * 400.f / 375.f));
        }
        self.singleImageFrame = CGRectMake(0, top, imageSize.width, imageSize.height);
        return imageSize.height;
    } else if (fullCount > 1) { // 多图
        CGFloat space = 3;
        CGFloat positionX = kWDCellLeftPadding;
        CGFloat positionY = 0;
        CGFloat imageWidth = (cellWidth - space*2 - kWDCellLeftPadding*2) / 3;
        CGFloat imageHeight = imageWidth;
        CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
        NSInteger displayCount = MIN(fullCount, 3);
        NSMutableArray<NSValue *> *rects = [NSMutableArray arrayWithCapacity:displayCount];
        for (NSUInteger i = 0; i < displayCount; i++) {
            CGRect rect = CGRectMake(positionX, positionY, imageSize.width, imageSize.height);
            if (CGRectGetMaxX(rect) > cellWidth) {
                positionX = kWDCellLeftPadding;
                positionY = CGRectGetMaxY(rect) + space;
                rect = CGRectMake(positionX, positionY, imageSize.width, imageSize.height);
            }
            positionX = CGRectGetMaxX(rect) + space;
            [rects addObject:[NSValue valueWithCGRect:rect]];
        }
        self.imageViewRects = rects;
        self.imagesBgViewHeight = positionY + imageSize.height;
        return self.imagesBgViewHeight;
    }
    return 0;
}

#pragma mark - Both

- (CGFloat)heightForMediaBoxWithCellWidth:(CGFloat)cellWidth {
    WDAnswerEntity *entity = self.viewModel.ansEntity;
    WDVideoInfoStructModel *videoModel ;
    if (entity.contentAbstract.video_list.count > 0) {
        videoModel = entity.contentAbstract.video_list.firstObject;
    }
    // 有视频
    if (videoModel && !isEmptyString(videoModel.video_id)) {
        if (self.dataModel.layoutType == WDWendaListLayoutTypeLIGHT_ANSWER) {
            self.mediaViewHeight = ceilf((cellWidth - kWDCellLeftPadding - kWDCellRightPadding) * 9/16);
        }
        else {
            self.mediaViewHeight = ceilf((cellWidth - kWDCellLeftPadding - kWDCellRightPadding) * 388/690);
        }
        
        return self.mediaViewHeight;
    }
    CGFloat height = 0;
    NSUInteger total = [entity.contentAbstract.thumb_image_list count];
    // 有图片
    if (total > 0) {
        WDImageUrlStructModel *model = [entity.contentAbstract.thumb_image_list firstObject];
        CGSize size = {model.width.floatValue, model.height.floatValue};
        CGSize returnSize;
        if (model.type == WDImageTypeGif) {
            returnSize = [WDImageBoxView limitedSizeForGif:size maxLimit:cellWidth - kWDCellLeftPadding - kWDCellRightPadding];
        } else {
            returnSize = [WDImageBoxView limitedSizeWithSize:size maxLimit:(cellWidth - kWDCellLeftPadding - kWDCellRightPadding)/2];
        }
        height += returnSize.height;
        self.singleImageFrame = CGRectMake(0, 0, returnSize.width, returnSize.height);
    }
    self.mediaViewHeight = ceilf(height);
    return self.mediaViewHeight;
}

- (CGFloat)heightForBottomLabel {
    return [WDListCellLayoutModel answerReadCountsLineHeight];
}

#pragma mark - Layout

+ (CGFloat)lightAnswerAbstractContentFontSize {
    CGFloat fontSize = [TTDeviceHelper isScreenWidthLarge320] ? 16.f : 15.f;
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
    return ceilf([WDListCellLayoutModel answerAbstractContentFontSize] * 1.4);
}

+ (CGFloat)answerReadCountsFontSize {
    return WDConstraintFontSize(12.0);
}

+ (CGFloat)answerReadCountsLineHeight {
    return WDConstraintPadding(16.0);
}

+ (CGFloat)moreImageCountsFontSize {
    return WDConstraintFontSize(12.0f);
}

+ (CGFloat)moreImageCountsLineHeight {
    return WDConstraintPadding(12.0f);
}

+ (CGFloat)heightForFooterView {
    if ([TTDeviceHelper isPadDevice]) {
        return [TTDeviceHelper ssOnePixel];
    }
    CGFloat footerPadding = [TTDeviceHelper isScreenWidthLarge320] ? 6 : 5;
    return [TTDeviceUIUtils tt_padding:footerPadding];
}

@end
