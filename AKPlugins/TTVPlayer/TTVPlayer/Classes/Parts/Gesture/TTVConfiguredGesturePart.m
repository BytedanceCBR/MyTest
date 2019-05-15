//
//  TTVConfiguredGesturePart.m
//  TTVPlayerPod
//
//  Created by lisa on 2019/3/30.
//

#import "TTVConfiguredGesturePart.h"
#import "TTVGesturePart.h"
#import "TTVGestureState.h"

@interface TTVConfiguredGesturePart ()


@end

@implementation TTVConfiguredGesturePart

- (instancetype)initWithConfig:(NSDictionary *)config {
    TTVGesturePart * part = [[TTVGesturePart alloc] init];
    self = [super initWithPart:part config:config];
    return self;
}

- (instancetype)init {
    TTVGesturePart * part = [[TTVGesturePart alloc] init];
    self = [super initWithPart:part];
    return self;
}

- (void)applyConfigOfPart {
    if (self.configOfPart.count == 0) {
        return;
    }
    NSDictionary * normal = self.configOfPart;
    NSDictionary * full = normal;
    
    TTVGestureState * inlineSetting;
    TTVGestureState * fullScreenSetting;
    
    inlineSetting = [[TTVGestureState alloc] init];
    inlineSetting.panGestureEnabled = [normal[@"PanEnabled"] boolValue];
    inlineSetting.supportPanDirection = [normal[@"PanSupportDirection"] integerValue];
    inlineSetting.singleTapEnabled = [normal[@"SingleTapEnabled"] boolValue];
    inlineSetting.doubleTapEnabled = [normal[@"DoubleTapEnabled"] boolValue];

    fullScreenSetting = [[TTVGestureState alloc] init];
    fullScreenSetting.panGestureEnabled = [full[@"PanEnabled"] boolValue];
    fullScreenSetting.supportPanDirection = [full[@"PanSupportDirection"] integerValue];
    fullScreenSetting.singleTapEnabled = [full[@"SingleTapEnabled"] boolValue];
    fullScreenSetting.doubleTapEnabled = [full[@"DoubleTapEnabled"] boolValue];
    
    // 同步配置
    NSMutableDictionary * dic = @{}.mutableCopy;
    dic[@"inline"] = inlineSetting;
    dic[@"fullscreen"] = fullScreenSetting;
    [self.playerStore dispatch:[[TTVReduxAction alloc] initWithType:TTVPlayerActionType_InitGestureSetting info:dic]];

}

@end
