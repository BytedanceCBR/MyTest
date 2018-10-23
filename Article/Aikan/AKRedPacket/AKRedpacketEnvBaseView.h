//
//  AKRedpacketEnvBaseView.h
//  Article
//
//  Created by 冯靖君 on 2018/3/8.
//

#import <UIKit/UIKit.h>
#import <SSThemed.h>

@protocol AKRedPacketBaseViewDelegate <NSObject>

- (void)redPacketDidClickCloseButton;
- (void)redPacketDidClickOpenRedPacketButton;
- (void)redPacketWillStartTransitionAnimation;
- (void)redPacketDidStartTransitionAnimation;
- (void)redPacketDidFinishTransitionAnimation;

@end

@interface AKRedpacketEnvViewModel : NSObject

@property (nonatomic, copy) NSString *title;                    // 红包封皮标题
@property (nonatomic, copy) NSString *amount;                   // 红包封皮金额
@property (nonatomic, strong) NSDictionary *customDetailInfo;   // 红包详情页需要的业务字段
@property (nonatomic, strong) NSDictionary *shareInfo;          // 红包详情页需要的分享信息

- (instancetype)initWithAmount:(NSInteger)amount
                    detailInfo:(NSDictionary *)detailInfo
                     shareInfo:(NSDictionary *)shareInfo;

@end

@interface AKRedpacketEnvBaseView : SSThemedView <CAAnimationDelegate>

@property (nonatomic, strong) SSThemedView *containerView; // 整体容器
@property (nonatomic, strong) SSThemedView *headerView; // 头部容器，供子类自定义
@property (nonatomic, strong) SSThemedView *footerView; // 底部容器，供子类自定义
@property (nonatomic, strong) SSThemedButton *openRedPacketButton; // 红包打开按钮
@property (nonatomic, strong) SSThemedButton *closeButton; // 关闭按钮
@property (nonatomic, weak) id<AKRedPacketBaseViewDelegate> delegate;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLayer;
@property (nonatomic, strong) CAShapeLayer *bottomLayer;
//@property (nonatomic, strong) UIImageView *coinsAnimationImageView;

- (instancetype)initWithFrame:(CGRect)frame
                    viewModel:(AKRedpacketEnvViewModel *)viewModel;

///**
// * 执行红包打开等待动画
// */
//- (void)startLoadingAnimation;
//
///**
// * 暂停红包打开等待动画
// */
//- (void)stopLoadingAnimation;

/**
 * 执行红包转场动画
 */
- (void)startTransitionAnimation;

/**
 绘制红包
 */
- (void)drawRedPacketLayer;

@end
