//
//  WDListCellLayoutModel.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/16.
//
//

#import <Foundation/Foundation.h>
#import "WDSettingHelper.h"
#import "WDListCellRouterCenter.h"

/*
 * 8.16 用于列表页cell布局的类
 * 9.15 2.0 Plan B：有图片时：文字不超过1行时不显示图片，最多显示三行，图片固定在右侧，多张图片时右下角显示数字
 * 9.26 需求修改：有图片就显示图片，无需判断文字是否超过一行; 并且回答点赞数和摘要保持固定间距
 */

@class WDAnswerEntity;
@class WDListCellDataModel;
@class WDListCellViewModel;

@interface WDListCellLayoutModel : NSObject<WDListCellLayoutModelBaseProtocol>

@property (nonatomic, strong, readonly) WDListCellDataModel *dataModel;

@property (nonatomic, assign) CGFloat cellCacheHeight;

@property (nonatomic, strong, readonly) WDListCellViewModel *viewModel;

@property (nonatomic, assign, readonly) CGFloat contentLabelHeight;
@property (nonatomic, assign, readonly) CGFloat mediaViewHeight;

@property (nonatomic, assign, readonly) CGFloat imageViewTopPadding;
@property (nonatomic, assign, readonly) CGFloat videoCoverTopPadding;
@property (nonatomic, assign, readonly) CGFloat bottomLabelTopPadding;
@property (nonatomic, assign, readonly) CGFloat bottomLabelBottomPadding;

@property (nonatomic, assign, readonly) BOOL isVideoMedia;
@property (nonatomic, assign, readonly) BOOL isImageMedia;

@property (nonatomic, assign, readonly) BOOL isShowAllAnswerText;
@property (nonatomic, assign, readonly) NSInteger answerLinesCount;

@property (nonatomic, assign, readonly) CGRect singleImageFrame;
@property (nonatomic, assign, readonly) CGFloat imagesBgViewHeight;
@property (nonatomic, strong, readonly) NSArray<NSValue *> *imageViewRects;
@property (nonatomic, assign, readonly) CGRect largeVideoFrame;

- (void)setNeedReCalculateLayout;

+ (CGFloat)lightAnswerAbstractContentFontSize;

+ (CGFloat)lightAnswerAbstractContentLineHeight;

+ (CGFloat)lightAnswerAbstractContentParaSpace;

+ (CGFloat)answerAbstractContentFontSize;

+ (CGFloat)answerAbstractContentLineHeight;

+ (CGFloat)answerReadCountsFontSize;

+ (CGFloat)answerReadCountsLineHeight;

+ (CGFloat)moreImageCountsFontSize;

+ (CGFloat)moreImageCountsLineHeight;

+ (CGFloat)heightForFooterView;

@end
