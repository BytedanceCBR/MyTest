//
//  WDMoreListCellLayoutModel.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/22.
//
//

#import <Foundation/Foundation.h>
#import "WDSettingHelper.h"
#import "WDListCellRouterCenter.h"

/*
 * 8.22 用于折叠列表页cell布局的类
 */

@class WDAnswerEntity;
@class WDListCellDataModel;
@class WDMoreListCellViewModel;

@interface WDMoreListCellLayoutModel : NSObject<WDListCellLayoutModelBaseProtocol>

@property (nonatomic, strong, readonly) WDListCellDataModel *dataModel;

@property (nonatomic, assign) CGFloat cellCacheHeight;

@property (nonatomic, strong, readonly) WDMoreListCellViewModel *viewModel;

@property (nonatomic, assign, readonly) CGFloat contentLabelHeight;

@property (nonatomic, assign, readonly) CGFloat bottomLabelTopPadding;

@property (nonatomic, assign, readonly) CGFloat bottomLabelBottomPadding;

@property (nonatomic, assign, readonly) NSInteger answerLinesCount;

- (void)setNeedReCalculateLayout;

+ (CGFloat)lightAnswerAbstractContentFontSize;

+ (CGFloat)lightAnswerAbstractContentLineHeight;

+ (CGFloat)lightAnswerAbstractContentParaSpace;

+ (CGFloat)answerAbstractContentFontSize;

+ (CGFloat)answerAbstractContentLineHeight;

+ (CGFloat)answerReadCountsFontSize;

+ (CGFloat)answerReadCountsLineHeight;

+ (CGFloat)heightForFooterView;

@end
