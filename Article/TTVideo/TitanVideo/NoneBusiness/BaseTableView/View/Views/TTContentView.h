
#import <UIKit/UIKit.h>
#import "TTContentViewDelegate.h"
#import "SSThemed.h"


@interface TTContentView : SSThemedView<TTContentViewDelegate>
/**
 *  如果使用的是contentViewClass属性,在contentView初始化的时候改frame无效,frame是自动根据当前的NavigtionBar是否隐藏的状态自动计算的.
 */
@end
