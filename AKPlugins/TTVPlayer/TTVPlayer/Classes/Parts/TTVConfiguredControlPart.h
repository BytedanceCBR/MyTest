//
//  TTVConfiguredControlPart.h
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/30.
//

#import "TTVConfiguredPart.h"
#import "TTVReduxKit.h"
#import "TTVPlayerCustomViewDelegate.h"
#import "TTVPlayerContextNew.h"

NS_ASSUME_NONNULL_BEGIN

/**
 本类是可以有控件配置的config 的基类
 他只专注处理所有需要配置的 control 的配置，以及unlock 下的 playbackControlView 的统一添加
 但是 lock，immersive 等状态下的默认不处理，交给 part 自己处理
 */
@interface TTVConfiguredControlPart : TTVConfiguredPart<TTVReduxStateObserver, TTVPlayerContextNew>

- (instancetype)initWithPart:(NSObject <TTVPlayerPartProtocol> *)part config:(NSDictionary *)config controlFactory:(TTVPlayerControlViewFactory *)controlFactory;
- (instancetype)initWithPart:(NSObject <TTVPlayerPartProtocol> *)part controlFactory:(TTVPlayerControlViewFactory *)controlFactory;

//- (void)button:(UIView<TTVButtonProtocol> *)button applyConfig:(NSDictionary *)config;
//- (void)toggleButton:(UIView<TTVToggledButtonProtocol> *)button applyConfig:(NSDictionary *)config;
//- (void)label:(UILabel *)label applyConfig:(NSDictionary *)config;
//- (void)slider:(TTPlayerSliderControlView *)slider applyConfig:(NSDictionary *)config;
//- (void)sliderHUD:(TTPlayerProgressHUDView *)hud applyConfig:(NSDictionary *)config;
- (UIImage *)imageOfName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
