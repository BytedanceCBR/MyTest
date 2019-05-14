//
//  TTVSliderControlView.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/4/21.
//

#import <Foundation/Foundation.h>
#import "TTVProgressViewOfSlider.h"
#import "TTVPlayerCustomViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTVSliderControlView : UIView<TTVSliderControlProtocol>

/**
 初始化方法

 @param customThumbView 自定义滑块 view
 @return  默认滑块宽高的 slider
 */
- (instancetype)initWithCustomThumbView:(UIView *)customThumbView;

/**
 初始化

 @param customThumbView 自定义滑块
 @param thumbViewWidth 滑块宽度
 @param thumbViewHeight 滑块高度
 @param sliderHeight slider 整体的高度
 @return slider
 */
- (instancetype)initWithCustomThumbView:(UIView *)customThumbView
                         thumbViewWidth:(CGFloat)thumbViewWidth
                        thumbViewHeight:(CGFloat)thumbViewHeight
                           sliderHeight:(CGFloat)sliderHeight;



/// 设置 thumb 的填充色
@property (nonatomic, copy) NSString * thumbColorString;
/// 设置 thumbbackground 的填充色
@property (nonatomic, copy) NSString * thumbBackgroundColorString;
/// 设置进度滑块 Image
@property (nonatomic, strong) UIImage * thumbImage;
/// 设置进度滑块背景 Image
@property (nonatomic, strong) UIImage * thumbBackgroundImage;   // 趁在进度点后面的 image


@end

NS_ASSUME_NONNULL_END
