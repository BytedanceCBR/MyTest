//
//  TTArticleCellHelper.h
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "TTArticlePicView.h"

// MARK: - TTArticleCellHelper
@interface TTArticleCellHelper : NSObject

/** 单例 */
+ (instancetype)shareHelper;

// MARK: 控件尺寸
/**
 获取顶部功能区控件尺寸
 
 - parameter orderedData: OrderedData数据
 - parameter width:       应占宽度
 
 - returns: 顶部功能区尺寸
 */
+ (CGSize)getFunctionSize:(ExploreOrderedData *)orderedData width:(CGFloat)width;
    
/**
 获取标题控件尺寸
 
 - parameter title:           标题文字
 - parameter width:           应占宽度
 - parameter fontSize:        字体大小(默认标题字体大小)
 - parameter lineHeight:      行高(默认标题行高)
 - parameter isBold:          是否加粗(默认不加粗)
 - parameter numberOfLines:   行数限制(默认标题行数限制)
 - parameter firstLineIndent: 首行缩进(默认0)
 
 - returns: (标题控件尺寸, 行数)
 */
+ (CGSize)getTitleSize:(NSString *)title width:(CGFloat)width fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight isBold:(BOOL)isBold numberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)firstLineIndent;
+ (CGSize)getTitleSize:(NSString *)title width:(CGFloat)width;
+ (CGSize)getTitleSize:(NSString *)title width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;
    
/**
 获取摘要控件尺寸
 
 - parameter article: Article数据
 - parameter width:   应占宽度
 
 - returns: 摘要控件尺寸
 */
+ (CGSize)getAbstractSize:(Article *)article width:(CGFloat)width  numberOfLines:(NSInteger)numberOfLines;
+ (CGSize)getAbstractSize:(Article *)article width:(CGFloat)width;

/**
 是否显示摘要控件
 
 - parameter article:  Article数据
 - parameter listType: 列表样式
 
 - returns: 是否显示摘要控件
 */
+ (BOOL)shouldDisplayAbstractView:(Article *)article listType: (ExploreOrderedDataListType)listType mustShow:(BOOL)mustShow;
    
/**
 获取评论控件尺寸
 
 - parameter article: Article数据
 - parameter width:   应占宽度
 
 - returns: 评论控件尺寸
 */
+ (CGSize)getCommentSize:(Article *)article width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines;
+ (CGSize)getCommentSize:(Article *)article width:(CGFloat)width;

/**
 是否显示评论控件
 
 - parameter article:  Article数据
 - parameter listType: 列表样式
 
 - returns: 是否显示评论控件
 */
+ (BOOL)shouldDisplayCommentView:(Article *)article listType:(ExploreOrderedDataListType)listType;
    
/**
 获取图片(视频)控件尺寸
 
 - parameter article:  Article数据
 - parameter picStyle: 图片(视频)控件样式
 - parameter width:    应占宽度
 
 - returns: 图片(视频)控件尺寸
 */
+ (CGSize)getPicSizeByOrderedData:(ExploreOrderedData *)orderedData adModel:(TTImageInfosModel *)adModel picStyle:(TTArticlePicViewStyle)picStyle width:(CGFloat)width;
+ (CGSize)getPicSizeByOrderedData:(ExploreOrderedData *)orderedData picStyle:(TTArticlePicViewStyle)picStyle width:(CGFloat)width;

//轮播广告图片尺寸计算
+ (CGSize)getLoopPicSizeWithOrderData:(ExploreOrderedData *)orderData WithContainWidth:(CGFloat)containWidth WithPicPadding:(CGFloat)picPadding WithEdgePadding:(CGFloat)edgePadding;

/**
 获取小图尺寸
 
 - parameter width: 三小图应占宽度
 
 - returns: 小图尺寸
 */
+ (CGSize)resizablePicSize:(CGFloat)width;
    
/**
 获取正方形小图尺寸
 
 - parameter width: 横排三图的总宽度
 
 - returns:正方形小图尺寸
 */
+ (CGSize)resizableSquareMultiPicsSize:(CGFloat)width;
    
/**
 获取信息栏控件尺寸
 
 - parameter width: 应占宽度
 
 - returns: 信息栏控件尺寸
 */
+ (CGSize)getInfoSize:(CGFloat)width;

+ (CGSize)getADActionSize:(CGFloat)width;

/** 可变字号 */
+ (CGFloat)mutableFontSize:(CGFloat)size;

/** 固定字号 */
+ (CGFloat)fontSize:(CGFloat)size;

+ (CGFloat)settingSize:(CGFloat)size;

/** 根据设备对字号进行调整 */
+ (CGFloat)deviceChangeSize:(CGFloat)size;

/** 对行高进行调整 */
+ (CGFloat)lineHeight:(CGFloat)size;

/** 根据设备对间距进行调整 */
+ (CGFloat)padding:(CGFloat)size;

/**过滤F项目来源字符串*/
+ (NSString *)fitlerSourceStr:(NSString *)sourceStr;

@end

@interface UIFont (TTFont)

+ (UIFont *)tt_boldFontOfSize:(CGFloat)size;

+ (UIFont *)tt_fontOfSize:(CGFloat)size;

@end

@interface UIColor (TTColor)

+ (UIColor *)colorForKey:(NSString *)colorKey;

@end
