//
//  ExploreAvatarView.h
//  Article
//
//  Created by SunJiangting on 14-9-11.
//
//

// TTImage
#import "TTImageView.h"

// TTThemed
#import "SSThemed.h"

/**
 * ExploreAvatarView
 */

@interface ExploreAvatarView : SSThemedView

/**
 实际展示头像的ImageView
 */
@property (nonatomic, strong) TTImageView *imageView;

/**
 展示点击态的view
 */
@property (nonatomic, strong) SSThemedView *highlightedMaskView;

/**
 5%的黑色遮罩
 */
@property (nonatomic, strong) SSThemedView *blackMaskView;
/** 默认图片的name */
@property (nonatomic, copy) NSString *placeholder;
/** 是否开启圆角图 */
@property (nonatomic, assign) BOOL enableRoundedCorner;
/** 是否关闭夜间图 */
@property (nonatomic, assign) BOOL disableNightMode;
/** 是否开启5%的黑色遮罩 */
@property (nonatomic, assign) BOOL enableBlackMaskView;
/**
 展示网络下载的头像

 @param URLString 头像的URL
 */
- (void)setImageWithURLString:(NSString *)URLString;


/**
 添加响应点击事件

 @param target 处理点击事件的对象
 @param action 调用的方法
 */
- (void)addTouchTarget:(id) target action:(SEL)action;

/**
 移除响应点击事件

 @param target 处理点击事件的对象
 @param action 调用的方法
 */
- (void)removeTouchTarget:(id) target action:(SEL) action;

@end
