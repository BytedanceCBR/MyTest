//
//  AKUILayout.h
//  Article
//
//  Created by chenjiesheng on 2018/3/13.
//

#import <UIKit/UIKit.h>

@interface AKUILayout : NSObject


/**
 将subViews进行水平布局，间距为viewPadding
 最终返回一个UIView，该方法会改变view的superView，如果superView不是AKUILayoutContainerView的话
 
 @param subViews 需要进行布局的UIView
 @param viewPadding 间距
 @param viewSize 是否要指定view的大小，只能指定都一样大，如果传入的不是一个CGSize的NSValue，或者为空，则不调整大小
 @return 返回一个包含了这些布局完成视图的view
 */
+ (UIView *)horizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                             padding:(CGFloat)viewPadding
                            viewSize:(NSValue *)viewSize;

/**
 将subViews进行垂直布局，间距为viewPadding
 最终返回一个UIView，该方法会改变view的superView，如果superView不是AKUILayoutContainerView的话
 
 @param subViews 需要进行布局的UIView
 @param viewPadding 间距
 @param viewSize 是否要指定view的大小，只能指定都一样大，如果传入的不是一个CGSize的NSValue，或者为空，则不调整大小
 @return 返回一个包含了这些布局完成视图的view
 */
+ (UIView *)verticalLayoutViewWith:(NSArray<UIView *> *)subViews
                             padding:(CGFloat)viewPadding
                            viewSize:(NSValue *)viewSize;

/**
 将subViews进行水平布局，间距为viewPadding
 该方法不会访问subView的superView
 
 @param subViews 需要进行布局的UIView
 @param viewPadding 间距
 @param viewSize 是否要指定view的大小，只能指定都一样大，如果传入的不是一个CGSize的NSValue，或者为空，则不调整大小
 @return 返回size，用于业务布局
 */
+ (CGSize)sizeWithHorizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                                   padding:(CGFloat)viewPadding
                                  viewSize:(NSValue *)viewSize;

/**
 将subViews进行水平布局，间距为viewPadding
 该方法不会访问subView的superView
 
 @param subViews 需要进行布局的UIView
 @param viewPadding 间距
 @param viewSize 是否要指定view的大小，只能指定都一样大，如果传入的不是一个CGSize的NSValue，或者为空，则不调整大小
 @param firstPadding  第一个左边的间距
 @return 返回size，用于业务布局
 */
+ (CGSize)sizeWithHorizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                                   padding:(CGFloat)viewPadding
                                  viewSize:(NSValue *)viewSize
                              firstPadding:(CGFloat)firstPadding;
/**
 将subViews进行水平布局，间距为viewPadding
 
 @param subViews 需要进行布局的UIView
 @param viewPadding 间距
 @param viewSize 是否要指定view的大小，只能指定都一样大，如果传入的不是一个CGSize的NSValue，或者为空，则不调整大小
 @param firstPadding  第一个左边的间距
 @param centerY  中心y
 */
+ (void)horizontalLayoutViewWith:(NSArray<UIView *> *)subViews
                         padding:(CGFloat)viewPadding
                        viewSize:(NSValue *)viewSize
                    firstPadding:(CGFloat)firstPadding
                         centerY:(CGFloat)centerY;

/**
 将subViews进行垂直布局，间距为viewPadding
 该方法不会访问subView的superView
 
 @param subViews 需要进行布局的UIView
 @param viewPadding 间距
 @param viewSize 是否要指定view的大小，只能指定都一样大，如果传入的不是一个CGSize的NSValue，或者为空，则不调整大小
 @return 返回size，用于业务布局
 */
+ (CGSize)sizeWithVerticalLayoutViewWith:(NSArray<UIView *> *)subViews
                                 padding:(CGFloat)viewPadding
                                viewSize:(NSValue *)viewSize;

/**
 将subViews进行垂直布局，间距为viewPadding
 该方法不会访问subView的superView
 
 @param subViews 需要进行布局的UIView
 @param viewPadding 间距
 @param viewSize 是否要指定view的大小，只能指定都一样大，如果传入的不是一个CGSize的NSValue，或者为空，则不调整大小
 @param firstPadding  第一个顶部的间距
 @return 返回size，用于业务布局
 */
+ (CGSize)sizeWithVerticalLayoutViewWith:(NSArray<UIView *> *)subViews
                                 padding:(CGFloat)viewPadding
                                viewSize:(NSValue *)viewSize
                            firstPadding:(CGFloat)firstPadding;
@end
