//
//  TTRedPacketBaseView.h
//  Article
//  红包基类，用于继承使用
//
//  Created by Jiyee Sheng on 8/1/17.
//
//


#import "SSThemed.h"

@protocol TTRedPacketBaseViewDelegate <NSObject>

- (void)redPacketDidClickCloseButton;
- (void)redPacketDidClickOpenRedPacketButton;
- (void)redPacketWillStartTransitionAnimation;
- (void)redPacketDidStartTransitionAnimation;
- (void)redPacketDidFinishTransitionAnimation;

@end


@interface TTRedPacketBaseView : SSThemedView

@property (nonatomic, strong) SSThemedView *containerView; // 整体容器
@property (nonatomic, strong) SSThemedView *headerView; // 头部容器，供子类自定义
@property (nonatomic, strong) SSThemedView *footerView; // 底部容器，供子类自定义
@property (nonatomic, strong) SSThemedButton *openRedPacketButton; // 红包打开按钮
@property (nonatomic, strong) SSThemedButton *closeButton; // 关闭按钮
@property (nonatomic, weak) id<TTRedPacketBaseViewDelegate> delegate;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) CAShapeLayer *bottomLayer;
@property (nonatomic, strong) UIImageView *coinsAnimationImageView;
/**
 * 执行红包打开等待动画
 */
- (void)startLoadingAnimation;

/**
 * 暂停红包打开等待动画
 */
- (void)stopLoadingAnimation;

/**
 * 执行红包转场动画
 */
- (void)startTransitionAnimation;

/**
 绘制红包
 */
- (void)drawRedPacketLayer;

@end

