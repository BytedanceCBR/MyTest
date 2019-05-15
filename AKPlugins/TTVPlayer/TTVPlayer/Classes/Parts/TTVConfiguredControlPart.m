//
//  TTVConfiguredControlPart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/30.
//

#import "TTVConfiguredControlPart.h"
#import "TTVPlayerState.h"
#import "TTVPlayer.h"
#import "TTVPlayerUtility.h"


@implementation TTVConfiguredControlPart

@synthesize controlViewFactory, configOfPart = _configOfPart;
;

- (instancetype)initWithPart:(NSObject <TTVPlayerPartProtocol> *)part config:(NSDictionary *)config controlFactory:(TTVPlayerControlViewFactory *)controlFactory {
    self = [super initWithPart:part config:config];
    if (self) {
        self.controlViewFactory = controlFactory;
    }
    return self;
}

- (instancetype)initWithPart:(NSObject <TTVPlayerPartProtocol> *)part controlFactory:(TTVPlayerControlViewFactory *)controlFactory {
    self = [super initWithPart:part];
    if (self) {
        self.controlViewFactory = controlFactory;
    }
    return self;
}

- (void)setConfigOfPart:(NSDictionary *)configOfPart {
    // 判断 config 是否相等，如果相等，则不做 apply，如果不等, 需要遍历 control 把多余的 control 去掉 TODO？
    [[self.configOfPart[@"Controls"] allValues] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
        TTVPlayerPartControlKey controlKey = [control[@"Tag"] integerValue];
        if ([configOfPart[@"Controls"] isKindOfClass:NSDictionary.class]) {
            __block BOOL controlKeyNotExist;
            [[configOfPart[@"Controls"] allValues] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TTVPlayerPartControlKey controlKeyNew = [obj[@"Tag"] integerValue];
                if (controlKey != controlKeyNew) {
                    controlKeyNotExist = YES;
                }
                else {
                    controlKeyNotExist = NO;
                    *stop = YES;
                }
            }];
            if (controlKeyNotExist) {
                UIView * control = [self.player partControlForKey:controlKey];
                [control removeFromSuperview];
                [self.part setControlView:nil forKey:controlKey];
            }
        }
    }];
    
    _configOfPart = configOfPart;
    // 更换 config 需要重新 apply 这个 config
    if (configOfPart.count > 0) {
        [self applyConfigOfPart];
    }
}

- (void)applyConfigOfPart {
    // 设置当前状态下的 config，当切换的时候，可以修改 config，改了 config 需要重新加载
    [[self.configOfPart[@"Controls"] allValues] enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull control, NSUInteger idx, BOOL * _Nonnull stop) {
        TTVPlayerPartControlKey controlKey = [control[@"Tag"] integerValue];
        if (controlKey > 0 && [self.part respondsToSelector:@selector(viewForKey:)]) { // 说明有效
            UIView * controlView = [self.part viewForKey:controlKey];
            NSString * controlType = control[@"Type"];
            if (!controlView) {
                if ([controlType isEqualToString:TTVPlayerPartControlType_ToggledButton]) {
                    controlView = [self.controlViewFactory createToggledButtonForKey:controlKey];
                }
                else if ([controlType isEqualToString:TTVPlayerPartControlType_Label]) {
                    controlView = [self.controlViewFactory createLabelForKey:controlKey];
                }
                else if ([controlType isEqualToString:TTVPlayerPartControlType_Slider]) {
                    controlView = [self.controlViewFactory createSliderView];
                }
                else if ([controlType isEqualToString:TTVPlayerPartControlType_SliderHUD]) {
                    controlView = [self.controlViewFactory createSliderHUDView];
                }
                else if ([controlType isEqualToString:TTVPlayerPartControlType_Button]) {
                    controlView = [self.controlViewFactory createButtonForKey:controlKey];
                }
                else if ([controlType isEqualToString:TTVPlayerPartControlType_ProgressView]) {
                    controlView = [self.controlViewFactory createProgressView];
                }
                else if (isEmptyString(controlType)) {
                    controlView = [self.controlViewFactory createOtherViewForKey:controlKey];
                }
                
                // control 跟 redux 结合
                if ([controlView respondsToSelector:@selector(setStore:)]) {
                    [controlView performSelector:@selector(setStore:) withObject:self.playerStore];
                }
            }
            // apply config
            if ([controlType isEqualToString:TTVPlayerPartControlType_ToggledButton]) {
                [self toggleButton:(UIView<TTVToggledButtonProtocol> *)controlView applyConfig:control];
            }
            else if ([controlType isEqualToString:TTVPlayerPartControlType_Button]) {
                [self button:(UIView<TTVButtonProtocol> *)controlView applyConfig:control];
            }
            else if ([controlType isEqualToString:TTVPlayerPartControlType_Label]) {
                [self label:(UILabel *)controlView applyConfig:control];
            }
            else if ([controlType isEqualToString:TTVPlayerPartControlType_Slider]) {
                [self slider:(UIView<TTVSliderControlProtocol> *)controlView applyConfig:control];
            }
            else if ([controlType isEqualToString:TTVPlayerPartControlType_SliderHUD]) {
                [self sliderHUD:(UIView<TTVProgressHudOfSliderProtocol> *)controlView applyConfig:control];
            }
            else if ([controlType isEqualToString:TTVPlayerPartControlType_ProgressView]) {
                [self progressView:(UIView<TTVProgressViewOfSliderProtocol> *)controlView applyConfig:control];
            }
            // 设置给 control
            [self.part setControlView:controlView forKey:controlKey];
            
            // add to superview
            NSString * bar = control[@"AddTo"];
            
            if ([bar isEqualToString:TTVPlayerPartControlType_TopNavBar] && controlView.superview != self.player.controlView.topBar) { // 添加到 bottom
                [self.player addPlaybackControl:controlView addToContainer:TTVPlayerPartControlType_TopNavBar];
            }
            else if ([bar isEqualToString:TTVPlayerPartControlType_BottomToolBar] && controlView.superview != self.player.controlView.bottomBar) { // 添加到 top
                [self.player addPlaybackControl:controlView addToContainer:TTVPlayerPartControlType_BottomToolBar];
            }
            else if ([bar isEqualToString:TTVPlayerPartControlType_OverlayControl] && controlView.superview != self.player.containerView.controlOverlayView) {
                // 添加到 overlay
                [self.player addViewOverlayPlaybackControls:controlView];
            }
            else if ([bar isEqualToString:TTVPlayerPartControlType_UnderlayControl] && controlView.superview != self.player.containerView.controlUnderlayView) {
                [self.player addViewUnderlayPlaybackControls:controlView];
            }
            else if ([bar isEqualToString:TTVPlayerPartControlType_None]) {
                // 什么都不做，交给 part 自己控制
            }
            else if ((isEmptyString(bar) || [bar isEqualToString:TTVPlayerPartControlType_Content]) &&
                controlView.superview != self.player.controlView.contentView) {
                // 加载到 playbackControl 的 contentView 上
                [self.player addPlaybackControl:controlView addToContainer:TTVPlayerPartControlType_Content];
            }

        }
    }];
}

- (UIView *)viewForKey:(NSUInteger)key {
    return [self.part viewForKey:key];
}

- (void)removeAllControlView {
    [self.part removeAllControlView];
}
#pragma mark - button
- (void)toggleButton:(UIView<TTVToggledButtonProtocol> *)button applyConfig:(NSDictionary *)config {
    // title
    NSDictionary * buttonTile = config[@"ButtonTitle"];
    [button setTitle:buttonTile[@"Title"] forStatus:TTVToggledButtonStatus_Normal];
    [button setTitle:config[@"ToggledTitle"] forStatus:TTVToggledButtonStatus_Toggled];
    
    // image
    NSDictionary * buttonImage = config[@"ButtonImage"];
    [button setImage:[self imageOfName:buttonImage[@"ImageName"]] forStatus:TTVToggledButtonStatus_Normal];
    [button setImage:[self imageOfName:buttonImage[@"ToggledImageName"]] forStatus:TTVToggledButtonStatus_Toggled];
    
    // buttonTitleColor
    NSDictionary * buttonTitleColor = config[@"ButtonTitleColor"];
    [button setTitleColor:[TTVPlayerUtility colorWithHexString:buttonTitleColor[@"TitleColor"]] forStatus:TTVToggledButtonStatus_Normal];
    [button setTitleColor:[TTVPlayerUtility colorWithHexString:buttonTitleColor[@"ToggledTitleColor"]] forStatus:TTVToggledButtonStatus_Toggled];
    
    // action
    NSDictionary * buttonAction = config[@"ButtonAction"];
    NSString * actionStr = buttonAction[@"Action"];
    NSString * toggleActionStr = buttonAction[@"ToggledAction"];
    // 如果能找到 action 的, 有可能是自定义的 action
    TTVReduxAction * action = [self.playerAction actionForKey:actionStr];
    if (!action && !isEmptyString(actionStr)) {
        action = [[TTVReduxAction alloc] initWithType:actionStr];
    }
    if (action) {
        [button setAction:action forStatus:TTVToggledButtonStatus_Normal];
    }

    TTVReduxAction * actionT = [self.playerAction actionForKey:toggleActionStr];
    if (!actionT && !isEmptyString(toggleActionStr)) {
        actionT = [[TTVReduxAction alloc] initWithType:toggleActionStr];
    }
    if (actionT) {
        [button setAction:actionT forStatus:TTVToggledButtonStatus_Toggled];
    }
    
    // button
    button.tintColor = [TTVPlayerUtility colorWithHexString:config[@"TintColor"]];
}
- (void)button:(UIView<TTVButtonProtocol> *)button applyConfig:(NSDictionary *)config {
    // title
    button.title = config[@"Title"];
    button.titleColor = [TTVPlayerUtility colorWithHexString:config[@"TitleColor"]];
    
    // image
    UIImage * image = [self imageOfName:config[@"ImageName"]];
    button.image = image;
    
    // action
    NSString * actionStr = config[@"Action"];
    TTVReduxAction * action = [self.playerAction actionForKey:actionStr];
    if (!action && !isEmptyString(actionStr)) {
        action = [[TTVReduxAction alloc] initWithType:actionStr];
    }
    if (action) {
        [button setAction:action];
    }
    
    button.tintColor = [TTVPlayerUtility colorWithHexString:config[@"TintColor"]];
}

- (UIImage *)imageOfName:(NSString *)name {
    NSBundle * bundle = self.customBundle;
    if ([name hasSuffix:@"_default_player"]) { // 说明是默认 bundle 加载
        name = [name substringToIndex:name.length - 15];
        bundle = [NSBundle bundleWithPath:TTVPlayerBundlePath];
    }
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

- (void)label:(UILabel *)label applyConfig:(NSDictionary *)config {
    label.textColor = [TTVPlayerUtility colorWithHexString:config[@"FontColor"]];
    label.textAlignment = [self alignmentFromString:config[@"Alignment"]];
    label.numberOfLines = [config[@"NumberOfLines"] integerValue];
    
    NSString * fontName = config[@"FontName"];
    if (isEmptyString(fontName)) {
        label.font = [UIFont systemFontOfSize:[config[@"FontSize"] floatValue]];
    }
    else {
        label.font = [UIFont fontWithName:fontName size:[config[@"FontSize"] floatValue]];
    }
    if (config[@"ShadowOffset-Width"] && config[@"ShadowOffset-Height"]) {
        label.layer.shadowOffset = CGSizeMake([config[@"ShadowOffset-Width"] floatValue], [config[@"ShadowOffset-Height"] floatValue]);
    }
    if (config[@"ShadowOpacity"]) {
        label.layer.shadowOpacity = [config[@"ShadowOpacity"] floatValue];
    }
    if (config[@"ShadowRadius"]) {
        label.layer.shadowRadius = [config[@"ShadowRadius"] floatValue];
    }
    
    NSString * shadowColor = config[@"ShadowColor"];
    if (!isEmptyString(shadowColor)) {
        label.layer.shadowColor = [TTVPlayerUtility colorWithHexString:shadowColor].CGColor;
    }
}

- (NSTextAlignment)alignmentFromString:(NSString *)string {
    if ([string isEqualToString:@"left"]) {
        return NSTextAlignmentLeft;
    }
    else if ([string isEqualToString:@"right"]) {
        return NSTextAlignmentRight;
    }
    else if ([string isEqualToString:@"center"]) {
        return NSTextAlignmentCenter;
    }
    return NSTextAlignmentLeft;
}

- (void)slider:(UIView<TTVSliderControlProtocol> *)slider applyConfig:(NSDictionary *)config {
    if ([slider respondsToSelector:@selector(setThumbColorString:)]) {
        slider.thumbColorString = config[@"SliderIndicatorColor"];;
    }
    if ([slider respondsToSelector:@selector(setThumbBackgroundColorString:)]) {
        slider.thumbBackgroundColorString = config[@"SliderIndicatorBackgroundColor"];
    }

    NSString * indicatorImageName = config[@"SliderIndicatorImageName"];
    if (!isEmptyString(indicatorImageName) && [slider respondsToSelector:@selector(setThumbImage:)]) {
        slider.thumbImage = [self imageOfName:indicatorImageName];
    }
    NSString * indicatorBackgroundImageName = config[@"SliderIndicatorBackgroundImageName"];
    if (!isEmptyString(indicatorBackgroundImageName) && [slider respondsToSelector:@selector(setThumbBackgroundView:)]) {
        slider.thumbBackgroundImage = [self imageOfName:indicatorImageName];
    }
    [self progressView:slider.progressView applyConfig:config];
}
- (void)sliderHUD:(UIView<TTVProgressHudOfSliderProtocol> *)hud applyConfig:(NSDictionary *)config {
    if ([hud respondsToSelector:@selector(progressView)]) {
        [self progressView:hud.progressView applyConfig:config];
    }
    
    if ([hud respondsToSelector:@selector(setCurrentTimeTextColorString:)]) {
        hud.currentTimeTextColorString = config[@"FontColorOfCurrentTime"];
    }
    
    if ([hud respondsToSelector:@selector(setTotalTimeTextColorString:)]) {
        hud.totalTimeTextColorString = config[@"FontColorOfTotalTime"];
    }
    
    if ([hud respondsToSelector:@selector(setTextSize:)]) {
        hud.textSize = [config[@"FontSize"] floatValue];
    }
    NSString * colorString = config[@"BackgroundColor"];
    if (!isEmptyString(colorString)) {
        hud.backgroundView.backgroundColor = [TTVPlayerUtility colorWithHexString:colorString];
    }
}
- (void)progressView:(UIView<TTVProgressViewOfSliderProtocol> *)progressView applyConfig:(NSDictionary *)config {
    UIColor * backgroundColor = [TTVPlayerUtility colorWithHexString:config[@"SliderBarColor"]];
    if (backgroundColor) {
        progressView.backgroundColor = backgroundColor;
    }
    UIColor * cacheColor = [TTVPlayerUtility colorWithHexString:config[@"CachedProgressColor"]];
    if (cacheColor) {
        progressView.cacheProgressView.backgroundColor = cacheColor;
    }
    UIColor * watcheColor = [TTVPlayerUtility colorWithHexString:config[@"WatchedProgressColor"]];
    if (watcheColor) {
        progressView.trackProgressView.backgroundColor = watcheColor;
    }
}

@end
