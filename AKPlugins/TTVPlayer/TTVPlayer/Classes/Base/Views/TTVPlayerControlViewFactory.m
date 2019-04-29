//
//  TTVPlayerControlViewFactory.m
//  ScreenRotate
//
//  Created by lisa on 2019/3/26.
//  Copyright © 2019 zuiye. All rights reserved.
//

#import "TTVPlayerControlViewFactory.h"
#import "TTVLPlayerLoadingView.h"
#import "TTVNetFlowTipView.h"
#import "TTVPlayerErrorView.h"
#import "TTVSliderControlView.h"
#import "TTVProgressHudOfSlider.h"
#import "TTVPlayerNavigationBar.h"
#import "TTVPlayerBottomToolBar.h"
#import "TTVToggledButton.h"
#import "TTVButton.h"

@implementation TTVPlayerControlViewFactory

// 单例
+ (instancetype _Nonnull)sharedInstance {
    static dispatch_once_t onceToken;
    static TTVPlayerControlViewFactory *instance;
    dispatch_once(&onceToken, ^{
        instance = [[TTVPlayerControlViewFactory alloc] init];
    });
    return instance;
}

- (UIView<TTVButtonProtocol> *)createButtonForKey:(TTVPlayerPartControlKey)key {
    UIView<TTVButtonProtocol> * button;
    if ([self.customViewDelegate respondsToSelector:@selector(customButtonForKey:)]) {
        button = [self.customViewDelegate customButtonForKey:key];
        if (!button) {
            button = [self customButtonForKey:key];
        }
    }
    else {
        button = [self customButtonForKey:key];
    }
    button.tag = key;
    return button;
}

- (UIView<TTVToggledButtonProtocol> *)createToggledButtonForKey:(TTVPlayerPartControlKey)key {
    UIView<TTVToggledButtonProtocol> * button;
    if ([self.customViewDelegate respondsToSelector:@selector(customToggledButtonForKey:)]) {
        button = [self.customViewDelegate customToggledButtonForKey:key];
        if (!button) {
            button = [self customToggledButtonForKey:key];
        }
    }
    else {
        button = [self customToggledButtonForKey:key];
    }
    button.tag = key;
    return button;
}

- (UILabel *)createLabelForKey:(TTVPlayerPartControlKey)key {
    UILabel * label;
    if ([self.customViewDelegate respondsToSelector:@selector(customLabelForKey:)]) {
        label = [self.customViewDelegate customLabelForKey:key];
        if (!label) {
            label = [self customLabelForKey:key];
        }
    }
    else {
        label = [self customLabelForKey:key];
    }
    label.tag = key;
    return label;
}

- (UIView <TTVPlayerLoadingViewProtocol> *)createLoadingView {
    UIView <TTVPlayerLoadingViewProtocol> * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customLoadingView)]) {
        control = [self.customViewDelegate customLoadingView];
        if (!control)  {
            control =  [self customLoadingView];
        }
    }
    else {
        control = [self customLoadingView];
    }
    control.tag = TTVPlayerPartControlKey_LoadingView;
    return control;
}
- (UIView <TTVPlayerErrorViewProtocol> *)createPlayerErrorFinishView {
    UIView <TTVPlayerErrorViewProtocol> * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customPlayerErrorFinishView)]) {
        control = [self.customViewDelegate customPlayerErrorFinishView];
        if (!control) {
            control = [self customPlayerErrorFinishView];
        }
    }
    else {
        control = [self customPlayerErrorFinishView];
    }
    control.tag = TTVPlayerPartControlKey_PlayerErrorStayView;
    return control;
}
- (UIView <TTVFlowTipViewProtocol> *)createCellularNetTipView {
    UIView <TTVFlowTipViewProtocol> * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customCellularNetTipView)]) {
        control = [self.customViewDelegate customCellularNetTipView];
        if (!control) {
            control = [self customCellularNetTipView];
        }
    }
    else {
        control = [self customCellularNetTipView];
    }
    control.tag = TTVPlayerPartControlKey_FlowTipView;
    return control;
}

- (UIView<TTVSliderControlProtocol> *)createSliderView {
    UIView<TTVSliderControlProtocol> * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customSliderControl)]) {
        control = [self.customViewDelegate customSliderControl];
        if (!control) {
            control = [self customSliderControl];
        }
    }
    else {
        control = [self customSliderControl];
    }
    control.tag = TTVPlayerPartControlKey_Slider;
    return control;
}
- (UIView<TTVProgressHudOfSliderProtocol> *)createSliderHUDView {
    UIView<TTVProgressHudOfSliderProtocol> * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customSliderHUDView)]) {
        control = [self.customViewDelegate customSliderHUDView];
        if (!control) {
            control = [self customSliderHUDView];
        }
    }
    else {
        control = [self customSliderHUDView];
    }
    control.tag = TTVPlayerPartControlKey_SeekingHUD;
    return control;
}
- (UIView<TTVProgressViewOfSliderProtocol> *)createProgressView {
    UIView<TTVProgressViewOfSliderProtocol> * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customProgressViewOfImmersive)]) {
        control = [self.customViewDelegate customProgressViewOfImmersive];
        if (!control) {
            control = [self customProgressViewOfImmersive];
        }
    }
    else {
        control = [self customProgressViewOfImmersive];
    }
    control.tag = TTVPlayerPartControlKey_ImmersiveSlider;
    return control;
}
- (TTVTouchIgoringView<TTVBarProtocol> *)createTopNavBar {
    TTVTouchIgoringView<TTVBarProtocol> * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customTopNavbar)]) {
        control = [self.customViewDelegate customTopNavbar];
        if (!control) {
            control = [self customTopNavbar];
        }
    }
    else {
        control = [self customTopNavbar];
    }
    control.tag = TTVPlayerPartControlKey_TopBar;
    return control;
}
- (TTVTouchIgoringView<TTVBarProtocol> *)createBottomToolBar {
    TTVTouchIgoringView<TTVBarProtocol> * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customBottomToolbar)]) {
        control = [self.customViewDelegate customBottomToolbar];
        if (!control) {
            control = [self customBottomToolbar];
        }
    }
    else {
        control = [self customBottomToolbar];
    }
    control.tag = TTVPlayerPartControlKey_BottomBar;
    return control;
}
- (UIView *)createOtherViewForKey:(TTVPlayerPartControlKey)key {
    UIView * control;
    if ([self.customViewDelegate respondsToSelector:@selector(customOtherViewForKey:)]) {
        control = [self.customViewDelegate customOtherViewForKey:key];
        if (!control) {
            control = [self customOtherViewForKey:key];
        }
    }
    else {
        control = [self customOtherViewForKey:key];
    }
    control.tag = key;
    return control;
}
#pragma mark - TTVPlayerCustomViewDelegate
- (UIView<TTVButtonProtocol> *)customButtonForKey:(TTVPlayerPartControlKey)key {
    TTVButton * button = [TTVButton buttonWithType:UIButtonTypeCustom];
    return button;
}

- (UIView<TTVToggledButtonProtocol> *)customToggledButtonForKey:(TTVPlayerPartControlKey)key {
    TTVToggledButton * button = [TTVToggledButton buttonWithType:UIButtonTypeCustom];
    return button;
}

- (UILabel *)customLabelForKey:(TTVPlayerPartControlKey)key {
    UILabel * label = [[UILabel alloc] init];
    return label;
}

// loading
- (UIView <TTVPlayerLoadingViewProtocol> *)customLoadingView {
    UIView <TTVPlayerLoadingViewProtocol> * control = [[TTVLPlayerLoadingView alloc] init];
    return control;
}
- (UIView <TTVPlayerErrorViewProtocol> *)customPlayerErrorFinishView {
    UIView <TTVPlayerErrorViewProtocol> * control = [[TTVPlayerErrorView alloc] init];
    return control;
}
- (UIView <TTVFlowTipViewProtocol> *)customCellularNetTipView {
    UIView <TTVFlowTipViewProtocol> * control = [[TTVNetFlowTipView alloc] initWithFrame:CGRectZero tipText:@"正在使用非WiFi网络\n「继续播放」将消耗%.2fMB流量" isSubscribe:NO];
    return control;
}
// slider TODO
- (UIView *)customSliderIndicatorView {
//    return [[UIView alloc] init];
    return nil;
}

- (UIView<TTVSliderControlProtocol> *)customSliderControl {
    UIView * customSliderIndicatorView = [self.customViewDelegate respondsToSelector:@selector(customSliderHUDView)]?[self.customViewDelegate customSliderIndicatorView]:[self customSliderIndicatorView];
    customSliderIndicatorView.backgroundColor = [UIColor redColor];
    TTVSliderControlView * control = [[TTVSliderControlView alloc] initWithCustomThumbView:customSliderIndicatorView thumbViewWidth:13 thumbViewHeight:13 sliderHeight:2];
    return control;
}

- (UIView<TTVProgressHudOfSliderProtocol> *)customSliderHUDView {
    UIView<TTVProgressHudOfSliderProtocol> * control = [[TTVProgressHudOfSlider alloc] init];
    return control;
}

- (TTVTouchIgoringView<TTVBarProtocol> *)customTopNavbar {
    return [[TTVPlayerBottomToolBar alloc] init];
}
- (TTVTouchIgoringView<TTVBarProtocol> *)customBottomToolbar {
    return [[TTVPlayerBottomToolBar alloc] init];
}
- (UIView<TTVProgressViewOfSliderProtocol> *)customProgressViewOfImmersive {
    TTVProgressViewOfSlider * control = [[TTVProgressViewOfSlider alloc] init];
    return control;
}
- (UIView *)customOtherViewForKey:(TTVPlayerPartControlKey)key {
    if (key == TTVPlayerPartControlKey_SpeedChangeButton) {
        return [TTVButton buttonWithType:UIButtonTypeCustom];
    }
    return nil;
}
@end
