//
//  TTTopTabViewConfig.h
//  Article
//
//  Created by fengyadong on 16/4/12.
//
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, TTTopTabViewAlignment) {
    TTTopTabViewAlignmentCenter,    //等分居中
    TTTopTabViewAlignmentLeft       //左对齐
};
@interface TTTopTabViewConfig : NSObject

@property (nonatomic, assign) CGFloat  height;//控件高度
@property (nonatomic, assign) CGFloat  width;//控件宽度
@property (nonatomic, assign) CGFloat  titleFont;//标题字体大小
@property (nonatomic, assign) CGFloat  indicatorLineHeight; //底部分割线高度
@property (nonatomic, strong) NSString *backgroundColorThemeKey;//默认颜色
@property (nonatomic, strong) NSString *titleNormalColorThemeKey;//默认颜色
@property (nonatomic, strong) NSString *titleHightLightColorThemeKey;//高亮颜色
@property (nonatomic, strong) NSString *indicatorBackgroundThemeKey;//背景颜色
@property (nonatomic, strong) NSString *bottomLineBackgroundThemeKey;//背景颜色
@property (nonatomic, assign) BOOL isindicatorLineEqualWidth;//是否等分分割线，默认是
@property (nonatomic, assign) NSUInteger indicatorLineMargin;//分割线比文字宽度多多少，默认是0
@property (nonatomic, assign) TTTopTabViewAlignment alignment;//对齐方式 默认居中

@end
