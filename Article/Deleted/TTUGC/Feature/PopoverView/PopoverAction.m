

#import "PopoverAction.h"

@interface PopoverAction ()

@property (nonatomic, strong, readwrite) UIImage *image; ///< 图标
@property (nonatomic, copy, readwrite) NSString *title; ///< 标题
@property (nonatomic, strong, readwrite) UIFont *titleFont; ///< 标题的字体
@property (nonatomic, strong, readwrite) UIImage *titleImage; ///< 标题后的背景图
@property (nonatomic, copy, readwrite) NSArray *colors; ///< 颜色数组
@property (nonatomic, copy, readwrite) void(^handler)(PopoverAction *action); ///< 选择回调
@property (nonatomic, assign, readwrite) BOOL showRedDot; ///< 小红点是否展示

@end

@implementation PopoverAction

+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^)(PopoverAction *action))handler {
    return [self actionWithImage:nil title:title handler:handler];
}

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)(PopoverAction *action))handler {
    return [self actionWithImage:image title:title colors:nil showRedDot:NO handler:handler];
}

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title colors:(NSArray *)colors showRedDot:(BOOL)showRedDot handler:(void (^)(PopoverAction *action))handler {
    return [self actionWithImage:image title:title titleFont:nil titleImage:nil colors:colors showRedDot:showRedDot handler:handler];
}

+ (instancetype)actionWithImage:(UIImage *)image title:(NSString *)title titleFont:(UIFont *)titleFont titleImage:(UIImage *)titleImage colors:(NSArray *)colors showRedDot:(BOOL)showRedDot handler:(void (^)(PopoverAction *action))handler {
    PopoverAction *action = [[self alloc] init];
    
    action.image = image;
    action.colors = colors;
    action.titleImage = titleImage;
    action.titleFont = titleFont;
    action.title = title ? : @"";
    action.showRedDot = showRedDot;
    action.handler = handler ? : NULL;
    
    return action;
}

@end
