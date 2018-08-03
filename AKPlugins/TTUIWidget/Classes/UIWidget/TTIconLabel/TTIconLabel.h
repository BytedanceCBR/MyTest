//
//  TTIconLabel.h
//  Article
//
//  Created by lizhuoli on 17/1/18.
//
//

#import "SSThemed.h"

@interface TTIconLabel : SSViewBase

/** 获取保存图标组的ContainerView */
@property (nonatomic, strong, readonly) UIView *iconContainerView;
/** 获取真实的Label，需要使用者判断是否AsyncLabel */
@property (nonatomic, strong, readonly) UIView *label;
/** 获取当前计算得到的图标组的宽度 */
@property (nonatomic, assign, readonly) CGFloat iconContainerWidth;

// 所有配置项
/** 图标的占位图，默认为灰色遮罩，一般不需要提供 */
@property (nonatomic, strong) UIImage *placeholderImage;
/** Label的最大宽度，超过会显示LineBreak，默认为0（表示不设置限制） */
@property (nonatomic, assign) CGFloat labelMaxWidth;
/** 图标组的最高高度，默认等于font的高度-1。且不会超过该高度 */
@property (nonatomic, assign) CGFloat iconMaxHeight;
/** 图标组距文字的左边距，默认为[TTDeviceUIUtils tt_padding:3] */
@property (nonatomic, assign) CGFloat iconLeftPadding;
/** 图标组距边缘的右边距，默认为0 */
@property (nonatomic, assign) CGFloat iconRightPadding;
/** 图标组每个图标的间距，默认为[TTDeviceUIUtils tt_padding:3] */
@property (nonatomic, assign) CGFloat iconSpacing;
/** 禁用在不提供nightIcon的时候自动添加的夜间遮罩，默认为NO */
@property (nonatomic, assign) BOOL disableNightMode;
/** 是否禁用在refresh时对Label进行sizeToFit */
@property (nonatomic, assign) BOOL disableLabelSizeToFit;
/** 使用TTAsyncLabel而不是SSThemedLabel，默认NO，使用SSThemedLabel */
@property (nonatomic, assign) BOOL enableAsync;

// UILabel的属性
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *textColorThemeKey;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, assign) NSInteger numberOfLines;
@property (nonatomic, assign) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) BOOL highlighted;
@property (nonatomic, assign) ArticleVerticalAlignment verticalAlignment;

/** 添加图标，使用imageName，对应本地日夜间图（不会使用nightMask），size如果为Zero会使用默认最高高度来处理 */
- (void)addIconWithImageName:(NSString *)imageName size:(CGSize)size;
/** 添加图标，dayIcon必选，在nightIcon传入nil时使用nightMask来处理，size如果为Zero会使用默认最高高度来处理*/
- (void)addIconWithDayIcon:(UIImage *)dayIcon nightIcon:(UIImage *)nightIcon size:(CGSize)size;
/** 添加图标，dayIconURL必选，在nightIconURL传入nil时使用nightMask来处理，size如果为Zero会使用默认最高高度来处理 */
- (void)addIconWithDayIconURL:(NSURL *)dayIconURL nightIconURL:(NSURL *)nightIconURL size:(CGSize)size;

/** 在指定Index插入图标，使用imageName，对应本地日夜间图（不会使用nightMask），size如果为Zero会使用UIImage themedImageName的大小 */
- (void)insertIconWithImageName:(NSString *)imageName size:(CGSize)size atIndex:(NSUInteger)index;
/** 在指定Index插入图标，dayIcon必选，在nightIcon传入nil时使用nightMask来处理，size如果为Zero会使用UIImage的大小 */
- (void)insertIconWithDayIcon:(UIImage *)dayIcon nightIcon:(UIImage *)nightIcon size:(CGSize)size atIndex:(NSUInteger)index;
/** 在指定Index插入图标，dayIconURL必选，在nightIconURL传入nil时使用nightMask来处理，size如果为Zero会使用默认的最高高度以正方形设置大小 */
- (void)insertIconWithDayIconURL:(NSURL *)dayIconURL nightIconURL:(NSURL *)nightIconURL size:(CGSize)size atIndex:(NSUInteger)index;

/** 删除指定Index的图标 */
- (void)removeIconAtIndex:(NSUInteger)index;
/** 删除所有图标 */
- (void)removeAllIcons;

/** 重新刷新整个图标组ImageView，触发sizeToFit(可以关闭)和layoutSubViews，适用于在更改Icon后刷新ImageView使用，如cell的复用时 */
- (void)refreshIconView;

/** 获取指定DayIconURL的图标Index */
- (NSUInteger)indexOfDayIconURL:(NSURL *)iconURL;
/** 获取指定DayIcon的图标Index */
- (NSUInteger)indexOfDayIcon:(UIImage *)icon;
/** 获取指定imageName的图标Index */
- (NSUInteger)indexOfImageName:(NSString *)imageName;

/** 图标组的个数 */
- (NSUInteger)countOfIcons;

@end
