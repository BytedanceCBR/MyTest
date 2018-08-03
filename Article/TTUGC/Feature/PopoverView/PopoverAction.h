

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PopoverViewStyle) {
    PopoverViewStyleDefault = 0, // 默认风格, 白色
    PopoverViewStyleDark, // 黑色风格
};

@interface PopoverAction : NSObject

@property (nonatomic, strong, readonly) UIImage *image; ///< 图标 (建议使用 60pix*60pix 的图片)
@property (nonatomic, copy, readonly) NSString *title; ///< 标题
@property (nonatomic, strong, readonly) UIFont *titleFont; ///< 标题的字体
@property (nonatomic, strong, readonly) UIImage *titleImage; ///< 标题后的背景图
@property (nonatomic, copy, readonly) NSArray *colors; ///< 颜色数组
@property (nonatomic, copy, readonly) void(^handler)(PopoverAction *action); ///< 选择回调, 该Block不会导致内存泄露, Block内代码无需刻意去设置弱引用.
@property (nonatomic, assign, readonly) BOOL showRedDot; ///< 小红点是否展示

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(PopoverAction *action))handler;

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(PopoverAction *action))handler;

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title colors:(NSArray *)colors showRedDot:(BOOL)showRedDot handler:(void (^)(PopoverAction *action))handler;

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title titleFont:(UIFont *)titleFont titleImage:(UIImage *)titleImage colors:(NSArray *)colors showRedDot:(BOOL)showRedDot handler:(void (^)(PopoverAction *action))handler;

@end

