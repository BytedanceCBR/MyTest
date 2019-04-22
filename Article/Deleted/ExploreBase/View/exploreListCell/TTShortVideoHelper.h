//
//  TTShortVideoHelper.h
//  Article
//
//  Created by 邱鑫玥 on 2017/8/17.
//

#import <Foundation/Foundation.h>

@class ExploreOrderedData;
@class TTShortVideoModel;
@class HorizontalCard;

typedef NS_ENUM(NSUInteger, TTHorizontalCardStyle){
    TTHorizontalCardStyleOne,       //  1.5 图
    TTHorizontalCardStyleTwo,       //  双图
    TTHorizontalCardStyleThree,     //  三图
    TTHorizontalCardStyleFour,      //  四图
};

typedef NS_ENUM(NSUInteger, TTHorizontalCardContentCellStyle){
    TTHorizontalCardContentCellStyle1,  //  线上UI 标题在外，
    TTHorizontalCardContentCellStyle2,  //  15 标题在外，（顶部可跳转）
    TTHorizontalCardContentCellStyle3,  //  16 标题在里，（标题在底部 + 顶部有标题 + 底部放更多入口）
    TTHorizontalCardContentCellStyle4,  //  17 标题在里，（标题在顶部 + 顶部有标题 + 底部放更多入口）
    TTHorizontalCardContentCellStyle5,  //  18 标题在里，（标题在顶部 + 顶部有标题 + 底部放更多入口）
    TTHorizontalCardContentCellStyle6,  //  21 1.5图UI (看起来和双图一样，遮罩比例不一样～)
    TTHorizontalCardContentCellStyle7,  //  22 3图UI
    TTHorizontalCardContentCellStyle8,  //  23 4图UI (看起来和双图一样，遮罩比例不一样～)
};

@interface TTShortVideoHelper : NSObject

+ (BOOL)canOpenShortVideoTab;

+ (void)openShortVideoTab;

+ (BOOL)canOpenShortVideoCategory;

+ (void)openShortVideoCategory;

+ (BOOL)shouldHandleClickWithData:(ExploreOrderedData *)orderedData;

+ (void)handleClickWithData:(ExploreOrderedData *)orderedData;

+ (NSString *)groupSourceForDownloadWithHorizontalCard:(HorizontalCard *)horizontalCard;

+ (TTHorizontalCardStyle)cardStyleWithData:(ExploreOrderedData *)orderedData;

+ (TTHorizontalCardContentCellStyle)contentCellStyleWithItemData:(ExploreOrderedData *)itemData;

+ (void)uninterestFormView:(UIView *)view point:(CGPoint)point withOrderedData:(ExploreOrderedData *)orderedData;
@end
