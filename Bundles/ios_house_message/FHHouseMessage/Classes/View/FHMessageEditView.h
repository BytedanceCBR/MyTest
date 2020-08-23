//
//  FHMessageEditView.h
//  FHHouseMessage
//
//  Created by xubinbin on 2020/7/28.
//

#import <UIKit/UIKit.h>

typedef void (^ClickBtn)(void);

typedef NS_ENUM(NSInteger,SliderMenuState) {
    SliderMenuClose, // 关闭
    SliderMenuSlider, // 滑动中
    SliderMenuOpen // 打开
};

@interface FHMessageEditView : UIView

@property (nonatomic, copy) ClickBtn clickDeleteBtn;

@end

